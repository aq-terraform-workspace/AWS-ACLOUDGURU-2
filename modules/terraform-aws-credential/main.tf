locals {
  public_ssh_key  = var.type == "ssh" ? tls_private_key.linux_ssh_key[0].public_key_openssh : null
  private_ssh_key = var.type == "ssh" ? tls_private_key.linux_ssh_key[0].private_key_pem : null
  random_password = var.type == "password" ? random_password.random_password[0].result : null
}

resource "random_password" "random_password" {
  count            = var.type == "password" ? 1 : 0
  length           = var.length
  special          = var.special
  min_special      = 1
  min_lower        = 1
  min_numeric      = 1
  min_upper        = 1
  override_special = var.override_special
}

resource "tls_private_key" "linux_ssh_key" {
  count     = var.type == "ssh" ? 1 : 0
  algorithm = "RSA"
}

resource "aws_ssm_parameter" "credential" {
  name      = var.parameter_name
  type      = "SecureString"
  value     = var.type == "password" ? random_password.random_password[0].result : tls_private_key.linux_ssh_key[0].private_key_pem
  overwrite = true
  tags      = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_key_pair" "linux_public_key" {
  key_name   = var.key_name
  count      = var.type == "ssh" ? 1 : 0
  public_key = tls_private_key.linux_ssh_key[0].public_key_openssh
  tags       = var.tags
}
