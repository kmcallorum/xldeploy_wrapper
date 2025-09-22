# Usage Guide

This page explains how to use the **XLDeploy GitHub Action**.

## Quick Start
1. Add the workflow `.github/workflows/deploy.yml` to your repo.
2. Configure secrets: `XLD_USER`, `XLD_PASS`, `XLD_SERVER`, `TEAMS_WEBHOOK_URL`, etc.
3. Trigger the workflow with `workflow_dispatch`.

## Inputs
- `ENV`: Environment (DEV, TST, STG, PRD)
- `PACKAGE_VERSION`: Optional specific version
- `OVERRIDE_VERSION`: Optional override version
- `SERVICENOW_TICKET`: Required for PROD
- `ISSUEOPS_ISSUE_ID`: IssueOps tracking ID

## Outputs
- Deployment summary artifacts (`deployment_summary.json`, `deployment_summary.md`)
