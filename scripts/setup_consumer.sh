#!/bin/sh
# ==============================================================
# setup_consumer.sh — Bootstrap the Consumer Container
# Mirrors setup_builder — same AWS credentials, NO local images.
# ==============================================================
set -e

echo "============================================"
echo "  Setting up Consumer Container"
echo "============================================"

# --- Wait for Docker daemon ---
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

# --- Install AWS CLI ---
echo "--> Installing AWS CLI..."
apk add --no-cache aws-cli curl bash >/dev/null

# --- Configure AWS credentials ---
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
echo "export AWS_DEFAULT_REGION=us-east-1"                                                 >> /etc/profile
echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}"                                             >> /etc/profile
echo "export ECR_REGISTRY=${ECR_REGISTRY}"                                                 >> /etc/profile
echo "export AWS_ACCESS_KEY_ID=${INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_ACCESS_KEY_ID}"         >> /etc/profile
echo "export AWS_SECRET_ACCESS_KEY=${INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_SECRET_ACCESS_KEY}" >> /etc/profile

# --- Verify AWS identity ---
echo "--> Verifying AWS credentials..."
aws sts get-caller-identity

echo ""
echo "============================================"
echo "  Consumer setup complete!"
echo "  AWS Account ID : ${AWS_ACCOUNT_ID}"
echo "  ECR Registry   : ${ECR_REGISTRY}"
echo "  No local images (you will pull from ECR)"
echo "  Run 'source /etc/profile' to load env vars"
echo "============================================"
