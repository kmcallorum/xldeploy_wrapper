# Monitoring

Prometheus metrics are published after each deployment.

### Metrics
- `deployment_status{environment, application, package}` → 0/1
- `deployment_prod_info{approver1, approver2, servicenow_ticket, issueops_issue}`

### Grafana Ideas
- Gauge panel for latest deployment status
- Time series of deployments over time
- Table panel of PROD approvals, ServiceNow, IssueOps
