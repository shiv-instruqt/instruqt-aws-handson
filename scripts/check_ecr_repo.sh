#!/bin/sh
# ==============================================================
# check_ecr_repo.sh
# Task: build_and_push / Condition: ecr_repo_created
# Runs inside: Builder container
# Checks that the learner created ECR repository 'my-lab-app'
# ==============================================================

REPO_NAME="my-lab-app"
REGION="us-east-1"

if aws ecr describe-repositories \
     --repository-names "${REPO_NAME}" \
     --region "${REGION}" \
     >/dev/null 2>&1; then
  echo "ECR repository '${REPO_NAME}' found."
  exit 0
else
  echo "ECR repository '${REPO_NAME}' does NOT exist in ${REGION}."
  exit 1
fi
