resource "terminal" "builder_shell" {
  target = resource.container.builder
  shell  = "/bin/sh"
}

resource "terminal" "consumer_shell" {
  target = resource.container.consumer
  shell  = "/bin/sh"
}

resource "cloud_credentials" "aws_creds" {
  aws_account {
    target = resource.aws_account.lab_aws
    users  = ["student"]
  }
}
