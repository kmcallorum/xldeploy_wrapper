# Project Roadmap

This roadmap outlines the planned improvements and future directions for the **XLDeploy GitHub Action**.

---

## ✅ Completed
- Reusable GitHub Action for XL Deploy deployments
- Sequential multi-env workflow (DEV → TST → STG → PRD)
- Microsoft Teams integration for notifications
- ServiceNow ticket validation for PROD
- IssueOps integration with mock server
- Prometheus metrics publishing
- Deployment summary artifacts
- Rollback with retry & exponential backoff
- Documentation site with MkDocs + GitHub Pages
- Project automation (issues/PRs → board)
- Semantic release automation
- Dependabot for dependency updates
- Pre-commit hooks + CI linting + tests with coverage

---

## 🚧 In Progress
- Expanded test coverage for edge cases in `entrypoint.sh`
- Integration tests with real XL Deploy (staging)
- Advanced Prometheus metrics (deployment duration, rollback counts)
- Grafana dashboards (pre-built JSON panels)
- Multi-approver validation with external API hooks

---

## 📅 Planned
- Support for multi-tenant XL Deploy servers
- Automated rollback approval flows
- Enhanced ServiceNow integration (change request auto-create)
- Support for additional chat platforms (Slack fallback, Mattermost)
- Terraform module for provisioning required secrets & config
- GitHub Marketplace publication of the Action

---

## 💡 Ideas (Future Exploration)
- AI-powered deployment risk analysis
- Policy-as-code integration (OPA/Conftest)
- Integration with Sentry or Datadog for post-deployment monitoring
- Auto-remediation workflows

---

## Contributions
We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.
