# Chapter 2 — Pull & Run from AWS ECR

> **Switch to the Consumer terminal tab for this chapter.**
>
> The Consumer container is completely isolated from Builder. It has no local Docker images — it must pull from ECR.

---

## Step 1: Load Environment Variables

Open the **Consumer** tab and run:

```sh
source /etc/profile
```

Verify the Consumer environment:

```sh
# Confirm Docker daemon
docker version --format "Docker version: {{.Server.Version}}"

# Confirm AWS CLI
aws --version

# Confirm AWS identity (same AWS account as Builder)
aws sts get-caller-identity

# Confirm ECR registry URL (same account, same registry)
echo "ECR Registry: ${ECR_REGISTRY}"
```

Confirm there are no local images:

```sh
docker images
# Should show an empty list or only the base docker:dind images — NOT your my-lab-app
```

---

## Step 2: Authenticate Docker to ECR

The Consumer must authenticate independently — it has no shared Docker session with Builder:

```sh
aws ecr get-login-password --region us-east-1 \
  | docker login \
      --username AWS \
      --password-stdin \
      ${ECR_REGISTRY}
```

Expected: `Login Succeeded`

---

## Step 3: Pull the Image from ECR

```sh
docker pull ${ECR_REGISTRY}/my-lab-app:latest
```

Docker will download the image layers from ECR. After completion:

```sh
docker images
```

You should now see `${ECR_REGISTRY}/my-lab-app` with tag `latest` — the exact same image the Builder created.

<instruqt-task id="image_pulled"></instruqt-task>

---

## Step 4: Run the Container

```sh
docker run -d \
  --name ecr-app \
  -p 80:80 \
  ${ECR_REGISTRY}/my-lab-app:latest
```

Verify the container is running:

```sh
docker ps
```

You should see `ecr-app` with status `Up`.

---

## Step 5: Test the Running Container

```sh
curl http://localhost:80
```

You should see the HTML you wrote in the Builder's Dockerfile — served from a completely separate container that had never seen that image until it pulled it from ECR.

<instruqt-task id="container_running"></instruqt-task>

---

## Lab Complete!

You have successfully completed the full Docker + AWS ECR workflow:

| Step | What Happened |
|------|--------------|
| Builder: Create Repo | `aws ecr create-repository` |
| Builder: Write Dockerfile | Defined the image contents |
| Builder: Build Image | `docker build` created a local image |
| Builder: Push to ECR | Image uploaded to AWS ECR |
| Consumer: Pull from ECR | Image downloaded from AWS ECR |
| Consumer: Run Container | Container started from the ECR image |

---

## Real-World Application

This pattern maps directly to:

```
Developer Machine / CI Runner   =   Builder Container
AWS ECR                         =   AWS ECR (same service)
Kubernetes Pod / EC2 / ECS      =   Consumer Container
```

In production:
1. A CI pipeline builds and pushes on every merge to `main`
2. Kubernetes pulls the new image tag on deployment
3. Old containers are replaced with the new version

Congratulations — you now understand the full container image lifecycle on AWS!
