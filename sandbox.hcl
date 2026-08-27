resource "network" "main" {
  subnet = "10.10.0.0/24"
}

resource "aws_account" "lab_aws" {
  regions  = ["us-east-1"]
  services = ["ecr", "sts"]

  tags = {
    Environment = "Lab"
    Purpose     = "ECR-Docker-Lab"
    Team        = "Xebia"
  }

  user "student" {
    managed_policies = [
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    ]
  }
}

resource "container" "builder" {
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

resource "exec" "setup_builder" {
  target  = resource.container.builder
  script  = "scripts/setup_builder.sh"
  timeout = "300s"

  depends_on = ["resource.container.builder"]
}

resource "exec" "setup_consumer" {
  target  = resource.container.consumer
  script  = "scripts/setup_consumer.sh"
  timeout = "300s"

  depends_on = ["resource.container.consumer"]
}
