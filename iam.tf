# Policy used for AWS Loadbalancer Controller inside EKS
resource "aws_iam_policy" "aws_loadbalancer_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("files/aws-loadbalancer-controller-policy.json")
}