# TERRAFORM DEPLOY EKS ON AWS
## Prequisites
### Required tools
- aws-cli installed and configure with profile named `demo`

### Configure the backend inside `backend.tf`

### Apply terraform
```
terraform init
terraform plan -out=terraform.tfplan
terraform apply terraform.tfplan
```

### Accessing k8s cluster  
- SSH to bastion Note your privare key must be avaiable in the directory
```
ssh ubuntu@<bastion_ip_address" -p 443 -L 8888:127.0.0.1:8888 -i private_key.pem
```
- Open new terminal tab 
```
export HTTPS_PROXY=http://localhost:8888
```
- Export AWS credential
```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_REGION="us-west-2"
```
- Get EKS credential
```
aws eks --region us-west-2 update-kubeconfig --name demo-prod-eks
``` 
- Get nodes and other EKS resources
```
kubectl get nodes
```