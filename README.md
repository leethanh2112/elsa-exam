# Diagram 
![exam](https://github.com/user-attachments/assets/60069bdf-0b16-4e7c-8769-ebfbcf4dfee0)

# Terraform
## Resource to deploy:
- VPC, Subnet
- Internet Gateway, Nat Gateway
- Route53
- ALB, Target Group
- EC2
  
## Terraform Core Directory:
- terraform/prod
- terraform/sandbox

## Terraform Modules Directory
- terraform_modules

## Terraform Pipeline:
- Using the Gitlab-CI pipeline: terraform-ci-cd.yaml
- Stages:
  - quality
  - plan
  - deploy


# Build & Deploy Webapp to Kubernetes
- Using the Gitlab-CI pipeline: web-ci-cd.yaml
- Stages:
  - build
  - helm package
  - deploy
