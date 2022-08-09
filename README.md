# The Technical Building Blocks of Zero Trust
This project contains workshop modules for the 2022 Black Hat Workshop "The Technical Building Blocks of Zero Trust"

## Requirements
- [Terraform](https://www.terraform.io/downloads)
- [Boundary Desktop Client](https://www.boundaryproject.io/downloads)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [AWS Account](https://aws.amazon.com/free/)
- [Git](https://git-scm.com/download/win)

## Setup
1. Install Terraform
2. Install Boundary Desktop
3. Sign up for AWS
4. Generate an ssh key and note the path


## Read Me
https://www.boundaryproject.io/docs/concepts/security/connections-tls

## Deploy
To deploy this example:

If you want to change your AWS region, navigate to `aws/aws/net.tf` and change `region = <new-region>`
Ensure that AWS is configured for this same region

```
export AWS_ACCESS_KEY_ID="AKIA2KMZODAMASUQTC7B"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_REGION="us-west-2"
```
   
Run `terraform init`

Ensure that `vars.tf` points to the correct ssh key paths

Run each terraform apply command for each workshop module

## Windows Line End Fix
The cotroller will not deploy with DOS style line ends. These commands fix the repo so that the line ends are preserved
```
git config core.autocrlf false 
git rm --cached -r . 
git reset --hard
```

## Delete command
There is a bit of a chicken and egg gotcha about this repo. Because the terraform provider for boundary is pointed to a ELB created in AWS by the same repo, we cannot delete with a standard delete command. This is the proper delete command

### Windows
```
./terraform.exe destroy -auto-approve -target module.rickroll -auto-approve && \
./terraform.exe destroy -auto-approve -target module.web-target -auto-approve && \
./terraform.exe destroy -auto-approve -target module.catalog -auto-approve && \
./terraform.exe destroy -auto-approve -target module.roles -auto-approve && \
./terraform.exe destroy -auto-approve -target module.users -auto-approve && \
./terraform.exe destroy -auto-approve -target module.controller-config -auto-approve && \
./terraform.exe destroy -auto-approve -target module.worker -auto-approve && \
./terraform.exe destroy -auto-approve -target module.controller && \
./terraform.exe destroy -auto-approve -target module.target && \
./terraform.exe destroy -auto-approve -target module.network
```

### Unix
```
terraform destroy -auto-approve -target module.rickroll -auto-approve && \
terraform destroy -auto-approve -target module.web-target -auto-approve && \
terraform destroy -auto-approve -target module.catalog -auto-approve && \
terraform destroy -auto-approve -target module.roles -auto-approve && \
terraform destroy -auto-approve -target module.users -auto-approve && \
terraform destroy -auto-approve -target module.controller-config -auto-approve && \
terraform destroy -auto-approve -target module.worker -auto-approve && \
terraform destroy -auto-approve -target module.controller && \
terraform destroy -auto-approve -target module.target && \
terraform destroy -auto-approve -target module.network
```