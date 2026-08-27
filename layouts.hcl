# ==============================================================
# layouts.hcl — Lab UI Layout
#
# Left column  (40%) : Lab instructions
# Right column (60%) : Builder terminal, Consumer terminal, AWS Creds
# ==============================================================

resource "layout" "main" {
  column {
    width = "40"

    instructions {}
  }

  column {
    width = "60"

    tab "builder" {
      target = resource.terminal.builder_shell
      title  = "Builder"
      active = true
    }

    tab "consumer" {
      target = resource.terminal.consumer_shell
      title  = "Consumer"
    }

    tab "aws_credentials" {
      target = resource.cloud_credentials.aws_creds
      title  = "AWS Credentials"
    }
  }
}
