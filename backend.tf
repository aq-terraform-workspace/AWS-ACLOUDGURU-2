terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "aq-tf-cloud"

    workspaces {
      name = "AWS-ACLOUDGURU"
    }
  }
}