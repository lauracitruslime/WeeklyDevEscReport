<#
.SYNOPSIS
    Updates the weekly Dev Escalations Report from Jira.
.DESCRIPTION
    Queries Jira for issues tagged with SupportTeamEscalation across CLOUDPOS, DEVOP, and CLECOM boards.
    Maintains a Markdown report with lifecycle management:
    - New escalations are added with TBC fix version
    - Existing entries are updated with current Fix Version
    - Entries that had a fix version in the previous report are dropped
    Each run saves a dated copy to the reports/ folder.
.PARAMETER Days
    Number of days to look back for new escalations (default: 7)
.PARAMETER ReportPath
    Path to the working report file (default: escalations-report.md)
.PARAMETER NoDrop
    Skip dropping resolved entries. Use this when re-running before you have emailed the report.
.EXAMPLE
    .\Update-EscReport.ps1
    .\Update-EscReport.ps1 -Days 14
    .\Update-EscReport.ps1 -NoDrop
#>
param(
    [int]$Days = 7,
    [string]$ReportPath = "escalations-report.md",
    [switch]$NoDrop
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$emDash = [char]0x2014      # — (avoid literal non-ASCII in source)
$brokenBar = [char]0x00A6   # ¦ (pipe escape for markdown tables)

# ── Load environment variables ──────────────────────────────────────────────
. "$scriptDir\Load-Env.ps1"

if (-not $env:JIRA_TOKEN) {
    Write-Error "JIRA_TOKEN not set. Create a .env file (see .env.example) and re-run."
    exit 1
}

# ── Jira configuration ─────────────────────────────────────────────────────
$jiraBase = "https://citruslime.atlassian.net"
$jiraEmail = "laura@citruslime.com"
$jiraProjects = @("CLOUDPOS", "DEVOP", "CLECOM")
$jiraTag = "SupportTeamEscalation"

function Get-JiraHeaders {
    @{
        "Authorization" = "Basic " + [Convert]::ToBase64String(
            [Text.Encoding]::ASCII.GetBytes("${jiraEmail}:$($env:JIRA_TOKEN)")
        )
        "Content-Type" = "application/json"
    }
}

function Invoke-JiraApi {
    param(
        [string]$Endpoint,
        [string]$Method = "Get",
        [object]$Body = $null
    )
    $params = @{
        Uri     = "$jiraBase/rest/api/3/$Endpoint"
        Headers = (Get-JiraHeaders)
        Method  = $Method
    }
    if ($Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 10)
    }
    Invoke-RestMethod @params
}

function Search-JiraIssues {
    param([string]$Jql, [string[]]$Fields)
    $allIssues = @()
    $nextPageToken = $null
    $maxPages = 20  # safeguard against infinite pagination
    $page = 0
    do {
        $body = @{
            jql        = $Jql
            maxResults = 100
            fields     = $Fields
        }
        if ($nextPageToken) {
            $body.nextPageToken = $nextPageToken
        }
        $result = Invoke-JiraApi -Endpoint "search/jql" -Method Post -Body $body
        if ($result.issues) {
            $allIssues += $result.issues
        }
        $nextPageToken = $result.nextPageToken
        $page++
    } while ($nextPageToken -and $page -lt $maxPages)
    return $allIssues
}

function Get-JiraIssue {
    param([string]$Key)
    Invoke-JiraApi -Endpoint "issue/$Key"
}

# ── Extract plain text from Jira ADF description ───────────────────────────
function Get-PlainTextFromAdf {
    param([object]$Adf)
    if (-not $Adf -or -not $Adf.content) { return "" }
    $texts = @()
    foreach ($block in $Adf.content) {
        if ($block.content) {
            foreach ($inline in $block.content) {
                if ($inline.text) { $texts += $inline.text }
            }
        }
    }
    $full = ($texts -join " ").Trim()
    # Truncate to first 200 chars for the description column
    if ($full.Length -gt 200) { $full = $full.Substring(0, 200) + "..." }
    return $full
}

# ── Format fix version info ────────────────────────────────────────────────
function Get-FixVersionText {
    param([object]$FixVersions)
    if (-not $FixVersions -or $FixVersions.Count -eq 0) { return "TBC" }
    $parts = $FixVersions | ForEach-Object {
        $name = $_.name
        if ($_.releaseDate) { "$name ($($_.releaseDate))" } else { $name }
    }
    return ($parts -join ", ")
}

# ── Parse existing report (table format) ────────────────────────────────────
function Read-EscReport {
    param([string]$Path)
    $entries = @()
    if (-not (Test-Path $Path)) { return $entries }

    $currentSection = $null
    $lines = Get-Content $Path -Encoding UTF8

    foreach ($line in $lines) {
        # Track section headers
        if ($line -match '^##\s+(.+)$') {
            $currentSection = $matches[1].Trim()
            continue
        }

        # Skip non-table lines, header rows, and separator rows
        if ($line -notmatch '^\|') { continue }
        if ($line -match '^\|\s*Title\s*\|') { continue }
        if ($line -match '^\|\s*-') { continue }

        # Parse table row: | Title | Description | Fix Version | Jira Key |
        $cells = $line -split '\|'
        if ($cells.Count -lt 5) { continue }

        $titleCell = $cells[1].Trim() -replace [char]0x00A6, '|'   # unescape ¦
        $descCell  = $cells[2].Trim() -replace [char]0x00A6, '|'
        $fixCell   = $cells[3].Trim() -replace [char]0x00A6, '|'
        $jiraCell  = $cells[4].Trim()

        # Parse Jira key/url from the Jira Key column
        $key = $null; $url = $null; $hasLink = $false
        if ($jiraCell -match '^\[([A-Z]+-\d+)\]\((.+?)\)$') {
            $key = $matches[1]
            $url = $matches[2]
            $hasLink = $true
        }

        $entries += [PSCustomObject]@{
            Title       = $titleCell
            ReportedBy  = ""
            Description = $descCell
            FixVersion  = $fixCell
            Key         = $key
            Url         = $url
            Section     = $currentSection
            HasJiraLink = $hasLink
        }
    }

    return $entries
}

# ── Write report to markdown (table format) ────────────────────────────────
function Write-EscReport {
    param(
        [string]$Path,
        [object[]]$Entries
    )
    $date = Get-Date -Format "yyyy-MM-dd"
    $lines = @()
    $lines += "# Dev Escalations Report $emDash $date"

    # Group entries by section, preserving order
    $sections = [ordered]@{}
    foreach ($entry in $Entries) {
        $sec = if ($entry.Section) { $entry.Section } else { "Escalations" }
        if (-not $sections.Contains($sec)) {
            $sections[$sec] = @()
        }
        $sections[$sec] += $entry
    }

    foreach ($sectionName in $sections.Keys) {
        $lines += ""
        $lines += "## $sectionName"
        $lines += ""
        $lines += "| Title | Description | Fix Version | Jira Key |"
        $lines += "|-------|-------------|-------------|----------|"

        foreach ($entry in $sections[$sectionName]) {
            $title = $entry.Title -replace '\|', $brokenBar
            $desc = $entry.Description -replace '\|', $brokenBar
            $fix = $entry.FixVersion -replace '\|', $brokenBar
            if ($entry.HasJiraLink -and $entry.Url) {
                $jiraCol = "[$($entry.Key)]($($entry.Url))"
            } else {
                $jiraCol = if ($entry.Key) { $entry.Key } else { "-" }
            }
            $lines += "| $title | $desc | $fix | $jiraCol |"
        }
    }

    $lines += ""
    $lines += "---"
    $lines += "*Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') by Update-EscReport.ps1*"

    Set-Content -Path $Path -Value ($lines -join "`n") -Encoding UTF8
}

# =========================================================================
# MAIN
# =========================================================================

Write-Host "`n== Dev Escalations Report Update ==" -ForegroundColor Cyan
Write-Host "Looking back $Days day(s) for new escalations`n" -ForegroundColor Cyan

# 0. Pull latest from GitHub
Write-Host "Pulling latest from GitHub..." -ForegroundColor Cyan
$prevEAP = $ErrorActionPreference; $ErrorActionPreference = "Continue"
$pullOutput = git -C $scriptDir pull origin main 2>&1
$ErrorActionPreference = $prevEAP
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Done" -ForegroundColor Green
} else {
    Write-Host "  Warning: git pull failed (exit $LASTEXITCODE)" -ForegroundColor Yellow
}

# 1. Read existing report
$existingEntries = @(Read-EscReport -Path $ReportPath)
Write-Host "Existing entries in report: $($existingEntries.Count)" -ForegroundColor Yellow

# 2. Remove entries that had a fix version in the previous report (already communicated)
#    Only drop Jira-linked entries where the Fix Version is clearly not TBC.
#    (We treat any Fix Version containing 'TBC' as unresolved.)
$keepEntries = @()
$droppedKeys = @{}  # track dropped keys so they aren't re-added as new
$droppedCount = 0
if ($NoDrop) {
    Write-Host "  -NoDrop: skipping drop logic" -ForegroundColor Yellow
    $keepEntries = $existingEntries
} else {
    foreach ($entry in $existingEntries) {
        $fixText = ("$($entry.FixVersion)").Trim()
        # Only drop if Jira-linked AND fix version is a real version (not freetext notes)
        # Preserve entries with TBC, WIP, Monitoring, Awaiting, Investigating, Ongoing
        $isFreetext = $fixText -match '(?i)\b(TBC|WIP|Monitoring|Awaiting|Investigating|Ongoing)\b'
        $hasCommunicatedFixVersion = $entry.HasJiraLink -and -not [string]::IsNullOrWhiteSpace($fixText) -and -not $isFreetext

        if ($hasCommunicatedFixVersion) {
            Write-Host "  Dropping (fix version communicated): $($entry.Key) $emDash $($entry.FixVersion)" -ForegroundColor DarkGray
            if ($entry.Key) { $droppedKeys[$entry.Key] = $true }
            $droppedCount++
        } else {
            $keepEntries += $entry
        }
    }
    if ($droppedCount -gt 0) {
        Write-Host "Dropped $droppedCount resolved entries`n" -ForegroundColor Yellow
    }
}

# 3. Update existing entries from Jira (only those with Jira links)
$updatedEntries = @()
$existingKeys = @{}
foreach ($entry in $keepEntries) {
    if ($entry.Key) { $existingKeys[$entry.Key] = $true }
    if ($entry.HasJiraLink) {
        Write-Host "  Updating $($entry.Key)..." -ForegroundColor Gray -NoNewline
        try {
            $issue = Get-JiraIssue -Key $entry.Key
            $entry.Title = $issue.fields.summary
            # Preserve manually edited description - only set if it was empty
            if ([string]::IsNullOrWhiteSpace($entry.Description) -or $entry.Description -eq "-") {
                $entry.Description = Get-PlainTextFromAdf -Adf $issue.fields.description
                if ([string]::IsNullOrWhiteSpace($entry.Description)) { $entry.Description = "-" }
            }
            $entry.FixVersion = Get-FixVersionText -FixVersions $issue.fields.fixVersions
            Write-Host " $($entry.FixVersion)" -ForegroundColor Green
        } catch {
            Write-Host " Failed to fetch: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  Keeping manual entry: $($entry.Title)" -ForegroundColor Gray
    }
    $updatedEntries += $entry
}

# 4. Find new escalations
$projectList = $jiraProjects -join ", "
$jql = "project in ($projectList) AND labels = `"$jiraTag`" AND created >= -${Days}d ORDER BY created DESC"
Write-Host "`nSearching for new escalations..." -ForegroundColor Cyan
Write-Host "  JQL: $jql" -ForegroundColor DarkGray

$fields = @("summary", "created", "fixVersions", "labels", "description", "reporter")
$newIssues = @(Search-JiraIssues -Jql $jql -Fields $fields)
Write-Host "  Found $($newIssues.Count) issue(s) matching query" -ForegroundColor Yellow

$addedCount = 0
foreach ($issue in $newIssues) {
    $key = $issue.key
    if ($existingKeys.ContainsKey($key)) {
        Write-Host "  Skipping $key (already in report)" -ForegroundColor DarkGray
        continue
    }
    if ($droppedKeys.ContainsKey($key)) {
        Write-Host "  Skipping $key (dropped this run)" -ForegroundColor DarkGray
        continue
    }
    $existingKeys[$key] = $true

    $desc = Get-PlainTextFromAdf -Adf $issue.fields.description
    if ([string]::IsNullOrWhiteSpace($desc)) { $desc = "-" }

    # Determine section based on project key
    $project = $key -replace '-\d+$', ''
    $section = switch ($project) {
        "CLOUDPOS" { "Cloud POS Escalations" }
        "DEVOP"    { "DevOps Escalations" }
        default    { "Ecommerce Escalations" }
    }

    # Use Jira reporter as initial "Reported by"
    $reporter = if ($issue.fields.reporter) { $issue.fields.reporter.displayName } else { "-" }

    $newEntry = [PSCustomObject]@{
        Title       = $issue.fields.summary
        ReportedBy  = $reporter
        Description = $desc
        FixVersion  = Get-FixVersionText -FixVersions $issue.fields.fixVersions
        Key         = $key
        Url         = "$jiraBase/browse/$key"
        Section     = $section
        HasJiraLink = $true
    }
    $updatedEntries += $newEntry
    Write-Host "  + $key $emDash $($newEntry.Title)" -ForegroundColor Green
    $addedCount++
}

Write-Host "`nAdded $addedCount new escalation(s)" -ForegroundColor Yellow

# 5. Write updated report
Write-EscReport -Path $ReportPath -Entries $updatedEntries

# 6. Save dated archive copy
$reportsDir = Join-Path $scriptDir "reports"
if (-not (Test-Path $reportsDir)) {
    New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null
}
$dateStamp = Get-Date -Format "yyyy-MM-dd"
$archivePath = Join-Path $reportsDir "escalations-$dateStamp.md"
Copy-Item -Path $ReportPath -Destination $archivePath -Force

# 7. Commit and push to GitHub
Write-Host "`nPushing to GitHub..." -ForegroundColor Cyan
$prevEAP = $ErrorActionPreference; $ErrorActionPreference = "Continue"
git -C $scriptDir add escalations-report.md reports/ 2>&1 | Out-Null
$dateStampMsg = Get-Date -Format "yyyy-MM-dd HH:mm"
git -C $scriptDir commit -m "Report update $dateStampMsg`n`nCo-Authored-By: Oz <oz-agent@warp.dev>" 2>&1 | Out-Null
git -C $scriptDir push origin main 2>&1 | Out-Null
$ErrorActionPreference = $prevEAP
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Pushed to GitHub" -ForegroundColor Green
} else {
    Write-Host "  Warning: git push failed (exit $LASTEXITCODE)" -ForegroundColor Yellow
}

Write-Host "`n== Report Updated ==" -ForegroundColor Cyan
Write-Host "  Report:         $ReportPath" -ForegroundColor Green
Write-Host "  Archived copy:  $archivePath" -ForegroundColor Green
Write-Host "  Total entries:   $($updatedEntries.Count)" -ForegroundColor Green
Write-Host ""
