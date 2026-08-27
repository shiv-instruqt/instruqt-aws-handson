resource "lab" "main" {
  title       = "AWS ECR: Docker Build, Push and Pull"
  description = "Build a Docker image in one container, push it to AWS Elastic Container Registry, then pull and run it from a completely isolated consumer container."

  layout = resource.layout.main

  settings {
    idle {
      enabled = true
      timeout = "1h"
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
      title = "Build and Push to ECR"

      page "build_push" {
        reference = resource.page.build_push
      }
    }

    chapter "pull_and_run" {
      title = "Pull and Run from ECR"

      page "pull_run" {
        reference = resource.page.pull_run
      }
    }
  }
}
