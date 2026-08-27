# ==============================================================
# main.hcl — Lab Definition
# AWS ECR: Docker Build, Push & Pull
# ==============================================================

resource "lab" "main" {
  title       = "AWS ECR: Docker Build, Push & Pull"
  description = "Build a Docker image in one container, push it to AWS Elastic Container Registry (ECR), then pull and run it from a completely isolated consumer container — a real-world CI/CD workflow."

  layout = resource.layout.main

  settings {
    idle_timeout {
      enabled = true
      timeout = 3600   # Auto-stop after 1 hour of inactivity
    }
  }

  content {
    chapter "introduction" {
      title = "Introduction"

      page "welcome" {
        reference = resource.page.welcome
      }
    }

    chapter "build_and_push" {
      title = "Build & Push to ECR"

      page "build_push" {
        reference = resource.page.build_push
      }
    }

    chapter "pull_and_run" {
      title = "Pull & Run from ECR"

      page "pull_run" {
        reference = resource.page.pull_run
      }
    }
  }
}
