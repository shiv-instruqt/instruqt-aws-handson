# ==============================================================
# sandbox.hcl — Infrastructure Resources
# AWS ECR: Docker Build, Push & Pull Lab
# 2 Containers  |  1 AWS Account  |  1 Network
# ==============================================================


# --------------------------------------------------------------
# NETWORK
# Shared isolated subnet — both containers communicate here
# --------------------------------------------------------------
resource "network" "main" {
  subnet = "10.10.0.0/24"
}


# --------------------------------------------------------------
# AWS ACCOUNT
# Provisions a sandboxed AWS account with ECR Full Access.
# Instruqt auto-injects credentials as env vars into containers:
#   INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_ACCESS_KEY_ID
#   INSTRUQT_AWS_ACCOUNT_LAB_AWS_AWS_SECRET_ACCESS_KEY
#   INSTRUQT_AWS_ACCOUNT_LAB_AWS_ACCOUNT_ID
# --------------------------------------------------------------
resource "aws_account" "lab_aws" {
  regions  = ["us-east-1"]
  services = ["ecr", "sts"]

  tags = {
    Environment = "Lab"
    Purpose     = "ECR-Docker-Lab"
    Team        = "Xebia"
  }

  # Student user — full ECR access (push + pull)
  user "student" {
    managed_policies = [
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    ]
  }
}


# --------------------------------------------------------------
# CONTAINER — Builder
# Learner writes a Dockerfile, builds the image, and pushes to ECR.
# Uses docker:dind (Docker-in-Docker) on Alpine.
# Requires privileged = true for the Docker daemon to run inside.
# --------------------------------------------------------------
resource "container" "builder" {
  image {
    name = "docker:dind"
  }

  privileged = true

  resources {
    cpu    = 1000   # 1 vCPU
    memory = 1024   # 1 GB RAM
  }

  environment = {
    DOCKER_TLS_CERTDIR = ""   # Disable TLS — required for DinD in privileged mode
  }

  network {
    id = resource.network.main.meta.id
  }

  depends_on = [
    "resource.network.main",
    "resource.aws_account.lab_aws"
  ]
}


# --------------------------------------------------------------
# CONTAINER — Consumer
# Completely isolated from Builder. Learner authenticates to ECR,
# pulls the image built by Builder, and runs it.
# --------------------------------------------------------------
resource "container" "consumer" {
  image {
    name = "docker:dind"
  }

  privileged = true

  resources {
    cpu    = 1000
    memory = 1024
  }

  environment = {
    DOCKER_TLS_CERTDIR = ""
  }

  network {
    id = resource.network.main.meta.id
  }

  depends_on = [
    "resource.network.main",
    "resource.aws_account.lab_aws"
  ]
}


# --------------------------------------------------------------
# EXEC — Bootstrap Builder
# Runs inside the builder container at sandbox start.
# Installs AWS CLI, configures credentials, waits for Docker daemon.
# --------------------------------------------------------------
resource "exec" "setup_builder" {
  target  = resource.container.builder
  script  = "scripts/setup_builder.sh"
  timeout = "300s"

  depends_on = ["resource.container.builder"]
}


# --------------------------------------------------------------
# EXEC — Bootstrap Consumer
# Mirrors setup_builder — same tooling, same AWS account credentials.
# The consumer has NO local Docker images until it pulls from ECR.
# --------------------------------------------------------------
resource "exec" "setup_consumer" {
  target  = resource.container.consumer
  script  = "scripts/setup_consumer.sh"
  timeout = "300s"

  depends_on = ["resource.container.consumer"]
}
