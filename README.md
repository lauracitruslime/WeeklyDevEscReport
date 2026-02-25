# Dev Escalations Report

Automated weekly report of support team escalations from Jira.

## Setup

1. Create a `.env` file with your Jira API token:
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

# Re-run without dropping resolved entries (use when you haven't emailed the report yet)
.\Update-EscReport.ps1 -NoDrop

# Combine flags
.\Update-EscReport.ps1 -Days 14 -NoDrop
```

## How it works

The script queries Jira for issues with the `SupportTeamEscalation` label across CLOUDPOS, DEVOP, and CLECOM boards.

**Each run:**
1. **Pulls** latest from GitHub
2. Reads the existing `escalations-report.md` (table format)
3. **Drops** entries with a communicated fix version (unless `-NoDrop` is set)
4. **Updates** remaining Jira-linked entries with current Fix Version
5. **Adds** new escalations found in the last N days
6. Saves the report and a dated archive copy to `reports/`
7. **Commits and pushes** to GitHub

**Lifecycle:**
- New issue tagged in Jira → added with `TBC` fix version
- Fix version added in Jira → shown in that week's report
- Next run → dropped (fix version was already communicated)
- Entries with freetext fix versions (TBC, WIP, Monitoring, Awaiting, Investigating, Ongoing) are preserved

**Editing the report:** Edit `escalations-report.md` either on GitHub or locally. Manually edited descriptions are preserved across runs. If editing on GitHub, the script will pull your changes automatically before running.

## Report format

The report uses markdown table format with four sections:
- **Ecommerce Escalations** (CLECOM)
- **Cloud POS Escalations** (CLOUDPOS)
- **DevOps Escalations** (DEVOP)
- **Issues with no ETA on Last Report**

Columns: Title, Description, Fix Version, Jira Key

## Files

- `Update-EscReport.ps1` — main script
- `Load-Env.ps1` — loads `.env` variables
- `escalations-report.md` — working report (table format, editable)
- `reports/` — dated archive copies
- `.env` — Jira API token (not committed)
