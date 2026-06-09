data "aws_vpc" "corp_vpc" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

resource "aws_subnet" "corp_subnet" {
  vpc_id            = data.aws_vpc.corp_vpc.id
  cidr_block        = "10.0.1.0/24"
}