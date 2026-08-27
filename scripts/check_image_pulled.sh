#!/bin/sh
# ==============================================================
# check_image_pulled.sh
# Task: pull_and_run / Condition: image_pulled
# Runs inside: Consumer container
# Checks that an ECR image (my-lab-app) exists locally.
# ==============================================================

REPO_NAME="my-lab-app"
REGION="us-east-1"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ -z "${AWS_ACCOUNT_ID}" ]; then
  echo "AWS credentials not configured. Run 'source /etc/profile' first."
  exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Check if the ECR image exists in local Docker image store
if docker images --format "{{.Repository}}" | grep -q "${ECR_REGISTRY}/${REPO_NAME}"; then
  echo "ECR image '${REPO_NAME}' found locally in Consumer. "
  exit 0
else
  echo "ECR image not found locally. Pull it with:"
  echo "  docker pull ${ECR_REGISTRY}/${REPO_NAME}:latest"
  exit 1
fi
