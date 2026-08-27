#!/bin/sh
# ==============================================================
# check_container_running.sh
# Task: pull_and_run / Condition: container_running
# Runs inside: Consumer container
# Checks that a container from the ECR image is currently running.
# ==============================================================

REPO_NAME="my-lab-app"
REGION="us-east-1"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ -z "${AWS_ACCOUNT_ID}" ]; then
  echo "AWS credentials not configured."
  exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Count running containers whose image matches the ECR image
RUNNING=$(docker ps --format "{{.Image}}" | grep -c "${ECR_REGISTRY}/${REPO_NAME}" 2>/dev/null || echo "0")

if [ "${RUNNING}" -gt 0 ] 2>/dev/null; then
  echo "Container from ECR image '${REPO_NAME}' is running. "
  exit 0
else
  echo "No running container found from ECR image."
  echo "Run: docker run -d -p 80:80 ${ECR_REGISTRY}/${REPO_NAME}:latest"
  exit 1
fi
