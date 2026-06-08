data "aws_vpc" "corp_vpc" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

