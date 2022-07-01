terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
  }
  required_version = ">= 1.2.2"
}

provider "aws" {
  region     = var.region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

module "lambda" {
  source  = "./modules/lambda"
  project = var.project
  env     = var.env
  tags    = local.tags
}

module "api-gateway" {
  source      = "./modules/gateway"
  lambda_arn  = module.lambda.lambda_arn
  lambda_name = module.lambda.lambda_name
  key_names   = var.key_names
  project     = var.project
  env         = var.env
  tags        = local.tags
}
