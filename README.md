[![codecov](https://codecov.io/gh/your-org/xldeploy-github-action/branch/main/graph/badge.svg)](https://codecov.io/gh/your-org/xldeploy-github-action)
![XLDeploy Pipeline](https://github.com/your-org/xldeploy-github-action/actions/workflows/deploy.yml/badge.svg)

# XLDeploy GitHub Action

## Overview
This repository contains a reusable GitHub Action to deploy applications using Digital.AI XL Deploy through a secure workflow.

### Features
- Sequential deployments: DEV → TST → STG → PRD
- Automatic package versioning for DEV
- Approval gates for TST, STG, PRD
- Microsoft Teams notifications
- ServiceNow change ticket validation for PROD
- IssueOps integration (track deployment lifecycle in issues)
- Prometheus metrics push to Pushgateway
- Deployment summaries (JSON + Markdown) stored as artifacts
- Rollback with retry and exponential backoff

## Usage

### Workflow Example
```yaml
jobs:
  deploy:
    uses: your-org/xldeploy-github-action/.github/workflows/deploy.yml@v1
```

### Required Secrets
- `XLD_USER`
- `XLD_PASS`
- `XLD_SERVER`
- `TEAMS_WEBHOOK_URL`
- `PROMETHEUS_PUSHGATEWAY_URL` (optional)
- `ISSUEOPS_API_URL` (optional)
- `ISSUEOPS_API_TOKEN` (optional)

### Inputs
- `PACKAGE_VERSION`: specific version to deploy
- `OVERRIDE_VERSION`: override version from approvals
- `SERVICENOW_TICKET`: required for PROD
- `ISSUEOPS_ISSUE_ID`: linked IssueOps issue

## Monitoring
Prometheus metrics are pushed to Pushgateway:
- `deployment_status{environment, application, package}` → 0/1
- `deployment_prod_info{approver1, approver2, servicenow_ticket, issueops_issue}`

## Artifacts
Each deployment creates:
- `deployment_summary.json`
- `deployment_summary.md`

## Deployment Flow

The following diagram illustrates the sequential deployment pipeline with integrations:

![Deployment Diagram](docs/deployment-diagram.png)

## Monitoring with Prometheus & Grafana

The action pushes metrics to Prometheus Pushgateway after each deployment.

### Exposed Metrics
- `deployment_status{environment, application, package}` → `1` on success, `0` on failure
- `deployment_prod_info{approver1, approver2, servicenow_ticket, issueops_issue}` → metadata for PROD deployments

### Example Prometheus Queries
- Last deployment status per environment:
  ```promql
  deployment_status{application="my-application"} == 1
  ```

- Count of failed deployments in the last 24h:
  ```promql
  count_over_time(deployment_status{application="my-application"}[24h] == 0)
  ```

### Example Grafana Panels
1. **Gauge Panel** → Shows latest deployment status (success/failure) by environment.
2. **Time Series Panel** → Plots deployment_status over time to visualize stability.
3. **Table Panel** → Lists latest `deployment_prod_info` labels (approvers, ServiceNow ticket, IssueOps issue) for auditing.

## Local Testing with Mock IssueOps API

For local testing, this repo includes a **mock IssueOps API server** under `mock-issueops/`.

### Setup & Run
```bash
cd mock-issueops
npm install
npm start
```

The server will start at `http://localhost:3000`.

### Endpoints
- **GET /issues/:id** → Fetch an issue by ID (default: `123`).
- **PATCH /issues/:id** → Update issue status, deployment environment, or package.

### Example cURL
```bash
curl -X PATCH http://localhost:3000/issues/123   -H "Content-Type: application/json"   -d '{"status":"Deployed Successfully","deployment_env":"DEV","package":"my-app:1.0.0"}'
```

This will update the mock issue and return the updated JSON response.
