# ==============================================================
# tabs.hcl — User Interface Tabs
# Terminals for both containers + AWS Credentials panel
# ==============================================================


# Builder terminal — learner works here in Chapter 1
resource "terminal" "builder_shell" {
  target = resource.container.builder
  shell  = "/bin/sh"
}


# Consumer terminal — learner works here in Chapter 2
resource "terminal" "consumer_shell" {
  target = resource.container.consumer
  shell  = "/bin/sh"
}


# AWS Credentials panel — shows account_id, access key, secret key
resource "cloud_credentials" "aws_creds" {
  aws_account {
    target = resource.aws_account.lab_aws
    users  = ["student"]
  }
}
