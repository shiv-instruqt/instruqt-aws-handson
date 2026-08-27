#!/bin/sh
# ==============================================================
# check_image_pushed.sh
# Task: build_and_push / Condition: image_built_and_pushed
# Runs inside: Builder container
# Checks that at least 1 image exists in the ECR repo.
# ==============================================================

REPO_NAME="my-lab-app"
REGION="us-east-1"

COUNT=$(aws ecr describe-images \
  --repository-name "${REPO_NAME}" \
  --region "${REGION}" \
  --query "length(imageDetails)" \
  --output text 2>/dev/null)

if [ -z "${COUNT}" ]; then
  echo "Could not query ECR. Is the repository created?"
  exit 1
fi

if [ "${COUNT}" -gt 0 ] 2>/dev/null; then
  echo "Found ${COUNT} image(s) in ECR repository '${REPO_NAME}'. Well done!"
  exit 0
else
  echo "No images found in ECR repository '${REPO_NAME}'."
  exit 1
fi
