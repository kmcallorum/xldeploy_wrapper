# Security Policy

## Supported Versions
We actively support the latest version of this GitHub Action. Older versions may not receive security updates.

| Version | Supported          |
| ------- | ------------------ |
| v1.x    | ✅                 |
| < v1.0  | ❌                 |

---

## Reporting a Vulnerability

If you discover a security vulnerability, **please do not open a public GitHub issue**.  
Instead, report it privately:

- Email: security@your-org.com
- Or use GitHub's [Security Advisories](https://docs.github.com/en/code-security/security-advisories/repository-security-advisories/creating-a-security-advisory)

We will work with you to confirm the issue and release a patch as soon as possible.

---

## Handling Secrets

This project uses several sensitive values as **GitHub Secrets**:

- `XLD_USER` / `XLD_PASS` → Credentials for XL Deploy
- `XLD_SERVER` → XL Deploy server endpoint
- `TEAMS_WEBHOOK_URL` → Microsoft Teams webhook URL
- `SERVICENOW_TICKET` → Required only for PROD deployments
- `ISSUEOPS_API_TOKEN` → Token for IssueOps integration
- `PROMETHEUS_PUSHGATEWAY_URL` → Optional Prometheus endpoint

### Best Practices
- Never hardcode secrets in workflows or source code.
- Use GitHub **Secrets** to store sensitive values securely.
- Rotate secrets periodically.
- Use different secrets for test vs. production environments.
- Limit permissions of service accounts (principle of least privilege).

---

## Deployment Approvals

- **DEV/TST**: No or minimal approvals required.
- **STG**: 2 approvers required.
- **PRD**: 2 approvers + valid ServiceNow ticket required.

All approvals and change tickets are logged in XL Deploy for audit compliance.

---

## Monitoring & Alerts

Prometheus metrics are exposed for deployment results.  
It is recommended to configure Grafana alerts on failed deployments to detect issues early.

---

## Responsible Disclosure

We encourage responsible disclosure. Please allow us time to investigate and fix issues before making them public.
