# Changelog

All notable changes to this project will be documented in this file.  
This project adheres to [Conventional Commits](https://www.conventionalcommits.org/) for versioning.

---

## [Unreleased]

### Added
- Initial reusable GitHub Action for XL Deploy
- Sequential workflow: DEV → TST → STG → PRD
- Microsoft Teams integration for notifications
- ServiceNow ticket validation for PROD
- IssueOps integration with mock server
- Prometheus metrics publishing to Pushgateway
- Deployment summary artifacts (JSON + Markdown)
- Retry with exponential backoff + rollback support
- GitHub Actions workflow badge in README
- Mock IssueOps API server (Node.js/Express)
- CONTRIBUTING.md with guidelines
- SECURITY.md with vulnerability reporting + secret handling
- CODEOWNERS for auto-review assignment
- Issue templates: bug, feature, deployment issue
- Pull Request template

### Changed
- N/A

### Fixed
- N/A

---

## [1.0.0] - YYYY-MM-DD
### Added
- First production-ready release of XLDeploy GitHub Action
