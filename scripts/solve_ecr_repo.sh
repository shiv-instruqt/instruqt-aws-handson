#!/bin/sh
# ==============================================================
# solve_ecr_repo.sh
# Task: build_and_push / Condition: ecr_repo_created (solve)
# Auto-creates the ECR repository if learner skips the step.
# ==============================================================

REPO_NAME="my-lab-app"
REGION="us-east-1"

aws ecr create-repository \
  --repository-name "${REPO_NAME}" \
  --region "${REGION}" \
  --image-scanning-configuration scanOnPush=true \
  >/dev/null 2>&1 || true

echo "ECR repository '${REPO_NAME}' created in ${REGION}."
