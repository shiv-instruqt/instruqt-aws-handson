#!/bin/sh
# ==============================================================
# solve_image_pulled.sh
# Task: pull_and_run / Condition: image_pulled (solve)
# Authenticates to ECR and pulls the image into Consumer.
# ==============================================================
set -e

REPO_NAME="my-lab-app"
REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Authenticate
aws ecr get-login-password --region "${REGION}" | \
  docker login --username AWS --password-stdin "${ECR_REGISTRY}"

# Pull
docker pull "${ECR_REGISTRY}/${REPO_NAME}:latest"

echo "Image pulled: ${ECR_REGISTRY}/${REPO_NAME}:latest"
