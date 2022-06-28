# Policy used for AWS Loadbalancer Controller inside EKS
resource "aws_iam_policy" "aws_loadbalancer_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("files/aws-loadbalancer-controller-policy.json")
}

resource "aws_iam_policy" "external_dns" {
  name   = "ExternalDNSIAMPolicy"
  policy = file("files/external-dns-policy.json")
}

resource "aws_iam_role" "external_dns" {
  name = "ExternalDNSIAMRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:external-dns:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

data "aws_iam_policy" "csi_ebs" {
  name = "AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "csi_ebs" {
  name = "AmazonEBSCSIDriverRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "csi_ebs" {
  role       = aws_iam_role.csi_ebs.name
  policy_arn = data.aws_iam_policy.csi_ebs.arn
}
