# ==============================================================
# pages.hcl — Content Pages
# Each page maps to a markdown instruction file and
# optionally embeds an interactive task.
# ==============================================================


# Welcome / Intro page (no task)
resource "page" "welcome" {
  title = "Welcome & Lab Overview"
  file  = "instructions/welcome.md"
}


# Chapter 1 page — build and push task embedded
resource "page" "build_push" {
  title = "Chapter 1 — Build & Push to ECR"
  file  = "instructions/build-push.md"

  activities = {
    build_and_push = resource.task.build_and_push
  }
}


# Chapter 2 page — pull and run task embedded
resource "page" "pull_run" {
  title = "Chapter 2 — Pull & Run from ECR"
  file  = "instructions/pull-run.md"

  activities = {
    pull_and_run = resource.task.pull_and_run
  }
}
