# IssueOps Integration

Each deployment is linked to an **IssueOps issue**.

### Supported Status Updates
- Deployment Started
- Deployed Successfully
- Deployment Failed
- PROD Deployment Approved

### Mock Testing
Run the mock server:

```bash
cd mock-issueops
npm install
npm start
```

Then test:
```bash
curl -X PATCH http://localhost:3000/issues/123 -H "Content-Type: application/json"   -d '{"status":"Deployed Successfully","deployment_env":"DEV","package":"my-app:1.0.0"}'
```
