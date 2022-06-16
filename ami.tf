data "aws_ami" "ec2_ami_regex" {
  owners      = [var.ami_owner]
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_regex_value]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}