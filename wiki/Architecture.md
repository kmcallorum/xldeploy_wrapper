# Architecture

This action orchestrates deployments across environments (DEV → TST → STG → PRD).

## Components
- **Reusable Action**: Defined in `action.yml`, wraps `entrypoint.sh`
- **XL Deploy**: Executes deployments and approvals
- **Microsoft Teams**: Sends notifications at key stages
- **ServiceNow**: Validates change tickets for PROD
- **IssueOps**: Tracks deployment lifecycle in issues
- **Prometheus**: Publishes metrics to Pushgateway

## Flow
1. Trigger workflow
2. Validate environment + version
3. Run lower env deploys automatically
4. Require approvals for upper envs
5. Push metrics + update IssueOps + log approvals
