module "base_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace      = var.project
  stage          = var.stage
  delimiter      = "-"
  labels_as_tags = ["namespace", "stage", "attributes"]

  tags = var.common_tags
}