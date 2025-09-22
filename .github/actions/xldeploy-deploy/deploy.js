#!/usr/bin/env node

const { execSync } = require("child_process");
const fs = require("fs");
const axios = require("axios");

// -------------------------------
// Inputs (from env variables)
// -------------------------------
const {
  ENV,
  APP_NAME,
  PACKAGE_VERSION,
  OVERRIDE_VERSION,
  REQUIRED_APPROVERS = "2",
  SERVICENOW_TICKET,
  PROMETHEUS_PUSHGATEWAY_URL,
  ISSUEOPS_API_URL,
  ISSUEOPS_API_TOKEN,
  ISSUEOPS_ISSUE_ID,
  XLD_USER,
  XLD_PASS,
  XLD_SERVER,
  TEAMS_WEBHOOK_URL
} = process.env;

// -------------------------------
// ENV Validation
// -------------------------------
const ENV_DICT = { DEV: "lower", TST: "lower", STG: "upper", PRD: "upper" };
if (!ENV_DICT[ENV]) {
  console.error(`❌ Environment ${ENV} not found.`);
  process.exit(1);
}
const ENV_TYPE = ENV_DICT[ENV];
console.log(`✅ ${ENV} is of type ${ENV_TYPE}`);

// -------------------------------
// Determine Package Version
// -------------------------------
let PACKAGE_ID;

function getLatestVersion() {
  try {
    const result = execSync(
      `curl -s -u ${XLD_USER}:${XLD_PASS} "${XLD_SERVER}/deployit/query?application=${APP_NAME}&sortBy=version&order=desc&limit=1"`
    ).toString();
    const parsed = JSON.parse(result);
    return parsed[0]?.package || null;
  } catch {
    return null;
  }
}

if (OVERRIDE_VERSION) {
  PACKAGE_ID = `${APP_NAME}:${OVERRIDE_VERSION}`;
} else if (PACKAGE_VERSION) {
  PACKAGE_ID = `${APP_NAME}:${PACKAGE_VERSION}`;
} else {
  const latest = getLatestVersion();
  let major = 1, minor = 0, patch = 0;

  if (latest) {
    const currentVersion = latest.split(":")[1];
    [major, minor, patch] = currentVersion.split(".").map(Number);
  }

  const lastCommit = execSync("git log -1 --pretty=%B").toString();

  if (/BREAKING CHANGE/.test(lastCommit)) {
    major++; minor = 0; patch = 0;
  } else if (/^feat:/.test(lastCommit)) {
    minor++; patch = 0;
  } else {
    patch++;
  }

  PACKAGE_ID = `${APP_NAME}:${major}.${minor}.${patch}`;
}
console.log(`PACKAGE_ID=${PACKAGE_ID}`);

// -------------------------------
// Helpers
// -------------------------------
async function notifyTeams(message) {
  if (!TEAMS_WEBHOOK_URL) return;
  await axios.post(TEAMS_WEBHOOK_URL, { text: message });
}

async function issueopsUpdateStatus(status) {
  if (!ISSUEOPS_API_URL || !ISSUEOPS_API_TOKEN || !ISSUEOPS_ISSUE_ID) {
    console.log("⚠️ IssueOps details not provided, skipping issue update");
    return;
  }
  await axios.patch(
    `${ISSUEOPS_API_URL}/issues/${ISSUEOPS_ISSUE_ID}`,
    {
      status,
      deployment_env: ENV,
      package: PACKAGE_ID
    },
    {
      headers: { Authorization: `Bearer ${ISSUEOPS_API_TOKEN}` }
    }
  );
  console.log(`📌 IssueOps issue ${ISSUEOPS_ISSUE_ID} updated to ${status}`);
}

// -------------------------------
// Prepare deployment summary
// -------------------------------
const summary = {
  environment: ENV,
  application: APP_NAME,
  package: PACKAGE_ID,
  previous_package: "",
  required_approvers: Number(REQUIRED_APPROVERS),
  approvals: [],
  deployed_at: new Date().toISOString(),
  result: "pending",
  retries: 0
};
fs.writeFileSync("deployment_summary.json", JSON.stringify(summary, null, 2));

// -------------------------------
// Validate ServiceNow Ticket for PROD
// -------------------------------
if (ENV === "PRD") {
  if (!SERVICENOW_TICKET) {
    console.error("❌ ServiceNow change ticket is required for PROD deployments");
    process.exit(1);
  }
  console.log(`📄 Using ServiceNow ticket: ${SERVICENOW_TICKET}`);
}

// -------------------------------
// IssueOps: mark deployment started
// -------------------------------
issueopsUpdateStatus("Deployment Started");

// -------------------------------
// Push Prometheus Metric
// -------------------------------
async function pushPrometheusMetric() {
  if (!PROMETHEUS_PUSHGATEWAY_URL) {
    console.log("⚠️ Prometheus Pushgateway URL not provided, skipping metric push");
    return;
  }

  const summaryData = JSON.parse(fs.readFileSync("deployment_summary.json"));
  const deployResult = summaryData.result;

  let metric = `# HELP deployment_status Deployment result metric (0=failure, 1=success)
# TYPE deployment_status gauge
deployment_status{environment="${ENV}", application="${APP_NAME}", package="${PACKAGE_ID}"}=${deployResult === "success" ? 1 : 0}
`;

  if (ENV === "PRD") {
    metric += `deployment_prod_info{approver1="${process.env.APPROVER1 || ""}", approver2="${process.env.APPROVER2 || ""}",servicenow_ticket="${SERVICENOW_TICKET}",issueops_issue="${ISSUEOPS_ISSUE_ID}"}=1
`;
  }

  const metricFile = "deployment_metric.prom";
  fs.writeFileSync(metricFile, metric);

  await axios.post(
    `${PROMETHEUS_PUSHGATEWAY_URL}/metrics/job/github_action_deploy/instance/${APP_NAME}-${ENV}`,
    fs.readFileSync(metricFile),
    { headers: { "Content-Type": "text/plain" } }
  );

  console.log(`📊 Prometheus metric pushed for ${PACKAGE_ID} in ${ENV}`);
}

// Example usage at end:
pushPrometheusMetric();
