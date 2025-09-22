# Contributing Guidelines

Thank you for considering contributing to the **XLDeploy GitHub Action** project! 🚀

## Contribution Process

1. **Fork the repository** and create your branch:
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes** with clear commit messages:
   - Use [Conventional Commits](https://www.conventionalcommits.org/) where possible (`feat:`, `fix:`, `docs:`).

3. **Run local tests** before submitting a PR:
   - Use the **Mock IssueOps API** for testing deployments without hitting production systems.

4. **Submit a Pull Request (PR)** with a clear description of:
   - What you changed
   - Why the change is needed
   - Any additional considerations

---

## Approval Guidelines

- **DEV/TST**: Automatic deploys with no or minimal approvals.
- **STG**: Requires **2 approvers** before deployment continues.
- **PRD**: Requires **2 approvers** AND a valid **ServiceNow ticket**.

Approvals should be handled via Teams notifications or by updating the `approvals.json` artifact.

---

## ServiceNow Integration

- A valid **ServiceNow ticket** is mandatory for **PROD** deployments.
- The ticket ID will be stored in XL Deploy for auditing.

---

## IssueOps Integration

- Each deployment should be linked to an **IssueOps issue**.
- The issue status is automatically updated by the pipeline (`Deployment Started`, `Deployed Successfully`, etc.).
- For testing, use the provided **mock IssueOps server**.

---

## Local Testing

Use the **mock-issueops** server to simulate IssueOps locally:

```bash
cd mock-issueops
npm install
npm start
```

Endpoints:
- `GET /issues/:id` → fetch issue details
- `PATCH /issues/:id` → update status, environment, and package

Example:
```bash
curl -X PATCH http://localhost:3000/issues/123   -H "Content-Type: application/json"   -d '{"status":"Deployed Successfully","deployment_env":"DEV","package":"my-app:1.0.0"}'
```

---

## Monitoring

Prometheus metrics are pushed after deployments:
- `deployment_status{environment, application, package}`
- `deployment_prod_info{approver1, approver2, servicenow_ticket, issueops_issue}`

These can be visualized in Grafana dashboards for CI/CD monitoring.

---

## Code of Conduct

- Be respectful and constructive in code reviews.
- Keep security and compliance in mind (especially around PROD).

---

## License

By contributing, you agree that your contributions will be licensed under the project’s existing license.
