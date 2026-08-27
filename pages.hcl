resource "page" "welcome" {
  title = "Welcome and Lab Overview"
  file  = "instructions/welcome.md"
}

resource "page" "build_push" {
  title = "Chapter 1 - Build and Push to ECR"
  file  = "instructions/build-push.md"

  activities = {
    build_and_push = resource.task.build_and_push
  }
}

resource "page" "pull_run" {
  title = "Chapter 2 - Pull and Run from ECR"
  file  = "instructions/pull-run.md"

  activities = {
    pull_and_run = resource.task.pull_and_run
  }
}
