
// Simple IssueOps Mock API using Express.js
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Use a Map to avoid prototype pollution
let issues = new Map([
  ["123", { id: "123", status: "Open", deployment_env: null, package: null }]
]);

// Get issue by ID
app.get('/issues/:id', (req, res) => {
  const issue = issues.get(req.params.id);
  if (issue) res.json(issue);
  else res.status(404).json({ error: 'Issue not found' });
});

// Update issue by ID
app.patch('/issues/:id', (req, res) => {
  const issue = issues.get(req.params.id);
  if (!issue) return res.status(404).json({ error: 'Issue not found' });

  const { status, deployment_env, package: pkg } = req.body;
  if (status) issue.status = status;
  if (deployment_env) issue.deployment_env = deployment_env;
  if (pkg) issue.package = pkg;

  issues.set(req.params.id, issue);
  res.json(issue);
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ IssueOps Mock API running at http://localhost:${PORT}`);
});
