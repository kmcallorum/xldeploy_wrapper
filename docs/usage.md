# Usage

## Workflow Example

```yaml
jobs:
  deploy:
    uses: your-org/xldeploy-github-action/.github/workflows/deploy.yml@v1
```

## Required Secrets
- `XLD_USER`, `XLD_PASS`, `XLD_SERVER`
- `TEAMS_WEBHOOK_URL`
- `PROMETHEUS_PUSHGATEWAY_URL` (optional)
- `ISSUEOPS_API_URL` + `ISSUEOPS_API_TOKEN` (optional)
- `SERVICENOW_TICKET` (required for PROD)
