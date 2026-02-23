<#
.SYNOPSIS
    Updates the weekly Dev Escalations Report from Jira.
.DESCRIPTION
    Queries Jira for issues tagged with SupportTeamEscalation across CLOUDPOS, DEVOP, and CLECOM boards.
    Maintains a Markdown report with lifecycle management:
    - New escalations are added with TBC fix version
    - Existing entries are updated with current Status/Fix Version
    - Entries that had a fix version in the previous report are dropped
    Each run saves a dated copy to the reports/ folder.
.PARAMETER Days
    Number of days to look back for new escalations (default: 7)
.PARAMETER ReportPath
    Path to the working report file (default: escalations-report.md)
.EXAMPLE
    .\Update-EscReport.ps1
    .\Update-EscReport.ps1 -Days 14
#>
param(
    [int]$Days = 7,
    [string]$ReportPath = "escalations-report.md"
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot

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
    $startAt = 0
    $maxResults = 50
    do {
        $body = @{
            jql        = $Jql
            maxResults = $maxResults
            startAt    = $startAt
            fields     = $Fields
        }
        $result = Invoke-JiraApi -Endpoint "search/jql" -Method Post -Body $body
        $allIssues += $result.issues
        $startAt += $maxResults
    } while ($startAt -lt $result.total)
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

# ── Parse existing report ──────────────────────────────────────────────────
function Read-EscReport {
    param([string]$Path)
    $entries = @()
    if (-not (Test-Path $Path)) { return $entries }

    $lines = Get-Content $Path
    foreach ($line in $lines) {
        # Match table rows: | Title | Description | Status | Fix Version | [Key](url) |
        if ($line -match '^\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*\[([A-Z]+-\d+)\]\((.+?)\)\s*\|$') {
            $title = $matches[1].Trim()
            # Skip header row
            if ($title -eq "Title") { continue }

            $entries += [PSCustomObject]@{
                Title       = $title
                Description = $matches[2].Trim()
                Status      = $matches[3].Trim()
                FixVersion  = $matches[4].Trim()
                Key         = $matches[5].Trim()
                Url         = $matches[6].Trim()
            }
        }
    }
    return $entries
}

# ── Write report to markdown ───────────────────────────────────────────────
function Write-EscReport {
    param(
        [string]$Path,
        [object[]]$Entries
    )
    $date = Get-Date -Format "yyyy-MM-dd"
    $lines = @()
    $lines += "# Dev Escalations Report — $date"
    $lines += ""
    $lines += "| Title | Description | Status | Fix Version | Jira Key |"
    $lines += "|-------|-------------|--------|-------------|----------|"

    foreach ($entry in $Entries) {
        $title = $entry.Title -replace '\|', '¦'
        $desc = $entry.Description -replace '\|', '¦'
        $status = $entry.Status -replace '\|', '¦'
        $fix = $entry.FixVersion -replace '\|', '¦'
        $link = "[$($entry.Key)]($($entry.Url))"
        $lines += "| $title | $desc | $status | $fix | $link |"
    }

    $lines += ""
    $lines += "---"
    $lines += "*Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') by Update-EscReport.ps1*"

    Set-Content -Path $Path -Value ($lines -join "`n") -Encoding UTF8
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

Write-Host "`n══ Dev Escalations Report Update ══" -ForegroundColor Cyan
Write-Host "Looking back $Days day(s) for new escalations`n" -ForegroundColor Cyan

# 1. Read existing report
$existingEntries = @(Read-EscReport -Path $ReportPath)
Write-Host "Existing entries in report: $($existingEntries.Count)" -ForegroundColor Yellow

# 2. Remove entries that had a fix version in the previous report (already communicated)
$keepEntries = @()
$droppedCount = 0
foreach ($entry in $existingEntries) {
    if ($entry.FixVersion -ne "TBC") {
        # This entry had a fix version last time — drop it
        Write-Host "  Dropping (fix version communicated): $($entry.Key) — $($entry.FixVersion)" -ForegroundColor DarkGray
        $droppedCount++
    } else {
        $keepEntries += $entry
    }
}
if ($droppedCount -gt 0) {
    Write-Host "Dropped $droppedCount resolved entries`n" -ForegroundColor Yellow
}

# 3. Update existing entries from Jira
$updatedEntries = @()
$existingKeys = @{}
foreach ($entry in $keepEntries) {
    $existingKeys[$entry.Key] = $true
    Write-Host "  Updating $($entry.Key)..." -ForegroundColor Gray -NoNewline
    try {
        $issue = Get-JiraIssue -Key $entry.Key
        $entry.Title = $issue.fields.summary
        # Preserve manually edited description — only set if it was empty
        if ([string]::IsNullOrWhiteSpace($entry.Description) -or $entry.Description -eq "-") {
            $entry.Description = Get-PlainTextFromAdf -Adf $issue.fields.description
            if ([string]::IsNullOrWhiteSpace($entry.Description)) { $entry.Description = "-" }
        }
        $entry.Status = $issue.fields.status.name
        $entry.FixVersion = Get-FixVersionText -FixVersions $issue.fields.fixVersions
        Write-Host " $($entry.Status) / $($entry.FixVersion)" -ForegroundColor Green
    } catch {
        Write-Host " Failed to fetch: $_" -ForegroundColor Red
    }
    $updatedEntries += $entry
}

# 4. Find new escalations
$projectList = $jiraProjects -join ", "
$jql = "project in ($projectList) AND labels = `"$jiraTag`" AND created >= -${Days}d ORDER BY created DESC"
Write-Host "`nSearching for new escalations..." -ForegroundColor Cyan
Write-Host "  JQL: $jql" -ForegroundColor DarkGray

$fields = @("summary", "status", "created", "fixVersions", "labels", "description")
$newIssues = @(Search-JiraIssues -Jql $jql -Fields $fields)
Write-Host "  Found $($newIssues.Count) issue(s) matching query" -ForegroundColor Yellow

$addedCount = 0
foreach ($issue in $newIssues) {
    $key = $issue.key
    if ($existingKeys.ContainsKey($key)) {
        Write-Host "  Skipping $key (already in report)" -ForegroundColor DarkGray
        continue
    }
    $existingKeys[$key] = $true

    $desc = Get-PlainTextFromAdf -Adf $issue.fields.description
    if ([string]::IsNullOrWhiteSpace($desc)) { $desc = "-" }

    $newEntry = [PSCustomObject]@{
        Title       = $issue.fields.summary
        Description = $desc
        Status      = $issue.fields.status.name
        FixVersion  = Get-FixVersionText -FixVersions $issue.fields.fixVersions
        Key         = $key
        Url         = "$jiraBase/browse/$key"
    }
    $updatedEntries += $newEntry
    Write-Host "  + $key — $($newEntry.Title)" -ForegroundColor Green
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

Write-Host "`n══ Report Updated ══" -ForegroundColor Cyan
Write-Host "  Working report: $ReportPath" -ForegroundColor Green
Write-Host "  Archived copy:  $archivePath" -ForegroundColor Green
Write-Host "  Total entries:   $($updatedEntries.Count)" -ForegroundColor Green
Write-Host ""
