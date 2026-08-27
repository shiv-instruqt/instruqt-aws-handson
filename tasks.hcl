# ==============================================================
# tasks.hcl — Interactive Task Definitions
#
# Task 1: build_and_push  (runs in Builder container)
#   Condition 1 — ECR repository created
#   Condition 2 — Docker image built and pushed to ECR
#
# Task 2: pull_and_run  (runs in Consumer container)
#   Condition 1 — Image pulled from ECR
#   Condition 2 — Container running from ECR image
# ==============================================================


# --------------------------------------------------------------
# TASK 1 — Build & Push to ECR
# Target: Builder container
# --------------------------------------------------------------
resource "task" "build_and_push" {
  config {
    target = resource.container.builder
    user   = "root"
  }

  # --- Condition 1: ECR repo must exist ---
  condition "ecr_repo_created" {
    description = "Create an ECR repository named 'my-lab-app'"

    check {
      script          = "scripts/check_ecr_repo.sh"
      failure_message = "ECR repository 'my-lab-app' not found. Run: aws ecr create-repository --repository-name my-lab-app --region us-east-1"
    }

    solve {
      script = "scripts/solve_ecr_repo.sh"
    }
  }

  # --- Condition 2: Image must be in ECR ---
  condition "image_built_and_pushed" {
    description = "Build the Dockerfile and push the image to ECR"

    check {
      script          = "scripts/check_image_pushed.sh"
      failure_message = "No image found in ECR. Build your Dockerfile and push it: docker build, docker tag, docker push."
    }

    solve {
      script = "scripts/solve_image_pushed.sh"
    }
  }
}


# --------------------------------------------------------------
# TASK 2 — Pull & Run from ECR
# Target: Consumer container
# --------------------------------------------------------------
resource "task" "pull_and_run" {
  config {
    target = resource.container.consumer
    user   = "root"
  }

  # --- Condition 1: Image must be pulled locally in consumer ---
  condition "image_pulled" {
    description = "Pull the image from ECR into the Consumer container"

    check {
      script          = "scripts/check_image_pulled.sh"
      failure_message = "ECR image not found locally in Consumer. Authenticate to ECR then run: docker pull <ECR_REGISTRY>/my-lab-app:latest"
    }

    solve {
      script = "scripts/solve_image_pulled.sh"
    }
  }

  # --- Condition 2: Container must be running from that image ---
  condition "container_running" {
    description = "Run the pulled ECR image as a container"

    check {
      script          = "scripts/check_container_running.sh"
      failure_message = "No running container from ECR image found. Run: docker run -d -p 80:80 <ECR_REGISTRY>/my-lab-app:latest"
    }

    solve {
      script = "scripts/solve_container_running.sh"
    }
  }
}
