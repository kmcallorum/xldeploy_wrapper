# Troubleshooting

Common issues and solutions.

## 1. Deployment Fails in DEV
- Check XL Deploy credentials (`XLD_USER`, `XLD_PASS`)
- Ensure XL Deploy server is reachable (`XLD_SERVER`)

## 2. Approval Not Working
- Verify Teams webhook URL is correct
- Check that approvals are logged in XL Deploy

## 3. PROD Deployment Blocked
- Ensure `SERVICENOW_TICKET` is provided
- Confirm ticket is valid in ServiceNow

## 4. Metrics Missing
- Verify `PROMETHEUS_PUSHGATEWAY_URL` is set
- Check GitHub Action logs for metric push failures

## 5. IssueOps Not Updating
- Confirm `ISSUEOPS_API_URL` + `ISSUEOPS_API_TOKEN` are set
- Use mock server for local testing (`mock-issueops/`)
