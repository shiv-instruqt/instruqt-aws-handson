# Chapter 1 — Build & Push to AWS ECR

> **Work in the Builder terminal tab for this chapter.**

Your Builder container comes pre-configured with Docker and AWS CLI. The AWS credentials are already set up from your sandbox account.

---

## Step 1: Load Environment Variables

Open the **Builder** tab and run:

```sh
source /etc/profile
```

Then verify your environment:

```sh
# Confirm Docker is running
docker version --format "Docker version: {{.Server.Version}}"

# Confirm AWS CLI
aws --version

# Confirm your AWS identity
aws sts get-caller-identity

# See your pre-computed ECR registry URL
echo "ECR Registry: ${ECR_REGISTRY}"
```

---

## Step 2: Create an ECR Repository

Create a private Docker repository named `my-lab-app` in ECR:

```sh
aws ecr create-repository \
  --repository-name my-lab-app \
  --region us-east-1 \
  --image-scanning-configuration scanOnPush=true
```

You will see a JSON response. Look for `repositoryUri` — that is your full ECR image path.

<instruqt-task id="ecr_repo_created"></instruqt-task>

---

## Step 3: Write Your Dockerfile

Create a working directory and a Dockerfile:

```sh
mkdir -p ~/app && cd ~/app

cat > Dockerfile << 'EOF'
# Base image: lightweight nginx on Alpine
FROM nginx:alpine

# Create a custom homepage
RUN printf '<html>\n\
<head><title>Hello from AWS ECR!</title></head>\n\
<body>\n\
  <h1>Docker Image from AWS ECR</h1>\n\
  <p>Built in the <strong>Builder</strong> container.</p>\n\
  <p>Pushed to <strong>AWS Elastic Container Registry</strong>.</p>\n\
  <p>To be pulled and run by the <strong>Consumer</strong> container.</p>\n\
</body>\n\
</html>' > /usr/share/nginx/html/index.html

EXPOSE 80
EOF
```

View your Dockerfile:

```sh
cat Dockerfile
```

---

## Step 4: Build the Docker Image

```sh
docker build -t my-lab-app:latest .
```

Verify the image was built:

```sh
docker images my-lab-app
```

You should see `my-lab-app` with tag `latest` and a size around 40–60 MB.

---

## Step 5: Authenticate Docker to ECR

Docker needs a temporary ECR login token to push/pull:

```sh
aws ecr get-login-password --region us-east-1 \
  | docker login \
      --username AWS \
      --password-stdin \
      ${ECR_REGISTRY}
```

Expected output: `Login Succeeded`

> **How this works:** `aws ecr get-login-password` fetches a 12-hour token. It's piped into `docker login` so your credentials never appear in command history.

---

## Step 6: Tag & Push the Image

Tag your local image with the full ECR URI, then push:

```sh
# Tag
docker tag my-lab-app:latest ${ECR_REGISTRY}/my-lab-app:latest

# Push
docker push ${ECR_REGISTRY}/my-lab-app:latest
```

You will see layer upload progress. When complete, verify it landed in ECR:

```sh
aws ecr describe-images \
  --repository-name my-lab-app \
  --region us-east-1 \
  --output table
```

<instruqt-task id="image_built_and_pushed"></instruqt-task>

---

## Summary

You have:
- Created an ECR repository
- Written a Dockerfile
- Built a Docker image locally
- Authenticated Docker to AWS ECR
- Pushed the image to ECR

The image is now stored in your AWS account's private registry, ready to be pulled from anywhere with valid credentials — including the Consumer container in Chapter 2.

Click **Next** to continue.
