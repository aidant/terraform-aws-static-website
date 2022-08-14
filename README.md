# Terraform AWS Static Website

## Quick Setup

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>= 4.25.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>= 4.31.0"
    }
  }
}

module "aws_static_website" {
  source = "github.com/aidant/terraform-aws-static-website"
}
```
