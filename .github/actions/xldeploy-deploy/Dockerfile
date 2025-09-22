# Containerized GitHub Action for XLDeploy
FROM ubuntu:22.04

LABEL maintainer="your-org"
LABEL description="Containerized GitHub Action for XLDeploy deployments with Teams, ServiceNow, IssueOps, and Prometheus integration"

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    ca-certificates \ 
    bash \ 
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default command
ENTRYPOINT ["/entrypoint.sh"]
