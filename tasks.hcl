resource "task" "build_and_push" {
  description     = "Build a Docker image and push it to AWS ECR"
  success_message = "Image successfully pushed to ECR!"

  config {
    target = resource.container.builder
    user   = "root"
  }

  condition "ecr_repo_created" {
    description = "Create an ECR repository named my-lab-app"

    check {
      script          = "scripts/check_ecr_repo.sh"
      failure_message = "ECR repository not found. Run: aws ecr create-repository --repository-name my-lab-app --region us-east-1"
    }

    solve {
      script = "scripts/solve_ecr_repo.sh"
    }
  }

  condition "image_built_and_pushed" {
    description = "Build the Dockerfile and push the image to ECR"

    check {
      script          = "scripts/check_image_pushed.sh"
      failure_message = "No image found in ECR. Build your Dockerfile and push it."
    }

    solve {
      script = "scripts/solve_image_pushed.sh"
    }
  }
}

resource "task" "pull_and_run" {
  description     = "Pull the image from ECR and run it in the consumer container"
  success_message = "Image pulled from ECR and running successfully!"

  config {
    target = resource.container.consumer
    user   = "root"
  }

  condition "image_pulled" {
    description = "Pull the image from ECR into the Consumer container"

    check {
      script          = "scripts/check_image_pulled.sh"
      failure_message = "ECR image not found locally. Authenticate to ECR and pull the image."
    }

    solve {
      script = "scripts/solve_image_pulled.sh"
    }
  }

  condition "container_running" {
    description = "Run the pulled ECR image as a container"

    check {
      script          = "scripts/check_container_running.sh"
      failure_message = "No running container found. Use docker run to start the pulled image."
    }

    solve {
      script = "scripts/solve_container_running.sh"
    }
  }
}
