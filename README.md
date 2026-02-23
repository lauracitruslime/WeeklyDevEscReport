# Dev Escalations Report

Automated weekly report of support team escalations from Jira.

## Setup

1. Copy `.env.example` to `.env` and add your Jira API token:
   ```
   JIRA_TOKEN="your-jira-api-token-here"
   ```

2. Generate a token at: https://id.atlassian.com/manage-profile/security/api-tokens

## Usage

```powershell
# Default: look back 7 days for new escalations
.\Update-EscReport.ps1

# Look back 14 days
.\Update-EscReport.ps1 -Days 14

# Use a different report file
.\Update-EscReport.ps1 -ReportPath "my-report.md"
```

## How it works

The script queries Jira for issues with the `SupportTeamEscalation` tag across CLOUDPOS, DEVOP, and CLECOM boards.

**Each run:**
1. Reads the existing `escalations-report.md`
2. **Drops** entries that had a fix version in the previous report (already communicated)
3. **Updates** remaining entries with current Status and Fix Version from Jira
4. **Adds** new escalations found in the last N days
5. Saves the report and a dated archive copy to `reports/`

**Lifecycle:**
- New issue → added with `TBC` fix version
- Fix version added → shown in that week's report
- Next run → dropped (fix version was already communicated)

**Description column:** Initially populated from the Jira description. If you manually edit it in the report, your edits are preserved on future runs.

## Files

- `escalations-report.md` — working report (latest version)
- `reports/` — dated archive of previous reports
- `.env` — Jira API token (not committed)
