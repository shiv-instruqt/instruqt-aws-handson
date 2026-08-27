#!/bin/sh
# ==============================================================
# setup_builder.sh — Bootstrap the Builder Container
# Runs via exec resource at sandbox start (inside builder container)
# ==============================================================
set -e

echo "============================================"
echo "  Setting up Builder Container"
echo "============================================"

# --- Wait for Docker daemon (DinD takes a few seconds to start) ---
echo "--> Waiting for Docker daemon..."
RETRIES=30
while [ $RETRIES -gt 0 ]; do
  if docker info >/dev/null 2>&1; then
    echo "    Docker is ready."
    break
  fi
  RETRIES=$((RETRIES - 1))
  sleep 2
done

if [ $RETRIES -eq 0 ]; then
  echo "ERROR: Docker daemon did not start in time."
  exit 1
fi

# --- Install AWS CLI (Alpine package manager) ---
echo "--> Installing AWS CLI..."
apk add --no-cache aws-cli curl bash >/dev/null

# --- Configure AWS credentials from Instruqt-injected env vars ---
echo "--> Configuring AWS credentials..."
mkdir -p /root/.aws

cat > /root/.aws/credentials << EOF
[default]
aws_access_key_id = ${INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_SECRET_ACCESS_KEY}
EOF

cat > /root/.aws/config << EOF
[default]
region = us-east-1
output = json
EOF

# --- Compute helper variables ---
AWS_ACCOUNT_ID="${INSTRUQT_AWS_ACCOUNT_LAB_AWS_ACCOUNT_ID}"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"

# --- Persist env vars for interactive shell sessions ---
echo "--> Writing environment helpers to /etc/profile..."
echo "export AWS_DEFAULT_REGION=us-east-1"                                           >> /etc/profile
echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}"                                       >> /etc/profile
echo "export ECR_REGISTRY=${ECR_REGISTRY}"                                           >> /etc/profile
echo "export AWS_ACCESS_KEY_ID=${INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_ACCESS_KEY_ID}"   >> /etc/profile
echo "export AWS_SECRET_ACCESS_KEY=${INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_SECRET_ACCESS_KEY}" >> /etc/profile

# --- Verify AWS identity ---
echo "--> Verifying AWS credentials..."
aws sts get-caller-identity

echo ""
echo "============================================"
echo "  Builder setup complete!"
echo "  AWS Account ID : ${AWS_ACCOUNT_ID}"
echo "  ECR Registry   : ${ECR_REGISTRY}"
echo "  Run 'source /etc/profile' to load env vars"
echo "============================================"
