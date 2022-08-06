# The Technical Building Blocks of Zero Trust
This project contains workshop modules for the 2022 Black Hat Workshop "The Technical Building Blocks of Zero Trust"

## Requirements
- [Terraform](https://www.terraform.io/downloads)
- [Boundary Desktop Client](https://www.boundaryproject.io/downloads)
- [AWS Account](https://aws.amazon.com/free/)

## Setup
1. Install Terraform
2. Install Boundary Desktop
3. Sign up for AWS

## Deploy
To deploy this example:

If you want to change your AWS region, navigate to `aws/aws/net.tf` and change `region = <new-region>`
Ensure that AWS is configured for this same region


    ```
    export AWS_ACCESS_KEY_ID="MY ACCESS KEY"
    export AWS_SECRET_ACCESS_KEY="MY SECRET KEY"
    export AWS_REGION="us-west-2"
    ```
   
Run `terraform init`

Ensure that `vars.tf` points to the correct ssh key paths

Run each terraform apply command for each workshop module