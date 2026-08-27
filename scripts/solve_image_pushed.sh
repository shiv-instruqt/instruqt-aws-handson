#!/bin/sh
# ==============================================================
# solve_image_pushed.sh
# Task: build_and_push / Condition: image_built_and_pushed (solve)
# Auto-builds a sample Dockerfile and pushes to ECR.
# ==============================================================
set -e

REPO_NAME="my-lab-app"
REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Ensure the repo exists
aws ecr create-repository \
  --repository-name "${REPO_NAME}" \
  --region "${REGION}" \
  >/dev/null 2>&1 || true

# Create a minimal Dockerfile in /tmp
mkdir -p /tmp/solve-build
cat > /tmp/solve-build/Dockerfile << 'DOCKERFILE'
FROM nginx:alpine
RUN printf '<html>\n<head><title>Hello from ECR!</title></head>\n<body>\n  <h1>Docker Image from AWS ECR</h1>\n  <p>Built in the <strong>Builder</strong> container.</p>\n  <p>Pushed to <strong>AWS ECR</strong>.</p>\n  <p>Ready to be pulled by the <strong>Consumer</strong>.</p>\n</body>\n</html>' > /usr/share/nginx/html/index.html
EXPOSE 80
DOCKERFILE

# Authenticate to ECR
aws ecr get-login-password --region "${REGION}" | \
  docker login --username AWS --password-stdin "${ECR_REGISTRY}"

# Build, tag, push
cd /tmp/solve-build
docker build -t "${REPO_NAME}:latest" .
docker tag "${REPO_NAME}:latest" "${ECR_REGISTRY}/${REPO_NAME}:latest"
docker push "${ECR_REGISTRY}/${REPO_NAME}:latest"

echo "Image pushed: ${ECR_REGISTRY}/${REPO_NAME}:latest"
