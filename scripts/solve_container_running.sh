#!/bin/sh
# ==============================================================
# solve_container_running.sh
# Task: pull_and_run / Condition: container_running (solve)
# Pulls if needed and runs the ECR image in Consumer.
# ==============================================================
set -e

REPO_NAME="my-lab-app"
REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
FULL_IMAGE="${ECR_REGISTRY}/${REPO_NAME}:latest"

# Authenticate and pull if image not present
if ! docker images --format "{{.Repository}}" | grep -q "${ECR_REGISTRY}/${REPO_NAME}"; then
  aws ecr get-login-password --region "${REGION}" | \
    docker login --username AWS --password-stdin "${ECR_REGISTRY}"
  docker pull "${FULL_IMAGE}"
fi

# Stop any previous containers from this image (cleanup)
docker ps -q --filter "ancestor=${FULL_IMAGE}" | xargs -r docker stop >/dev/null 2>&1 || true

# Run the container
docker run -d \
  --name ecr-consumer-app \
  -p 80:80 \
  "${FULL_IMAGE}"

echo "Container 'ecr-consumer-app' is now running from ${FULL_IMAGE}"
docker ps --filter "name=ecr-consumer-app"
