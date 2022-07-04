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


# modules ------

module "cognito" {
  source     = "./modules/cognito"
  department = var.department
  project    = var.project
  env        = var.env
  tags       = local.tags
  key_names  = var.key_names
  email      = var.email
  id_expiry  = var.id_expiry
}

module "lambda" {
  source  = "./modules/lambda"
  project = var.project
  env     = var.env
  tags    = local.tags
}

module "api-gateway" {
  source                = "./modules/gateway"
  lambda_arn            = module.lambda.lambda_arn
  lambda_name           = module.lambda.lambda_name
  cognito_user_pool_arn = module.cognito.user_pool_arn
  key_names             = var.key_names
  project               = var.project
  env                   = var.env
  tags                  = local.tags
}


# output ------

output "cognito-user-pool-arn" {
  value = module.cognito.user_pool_arn
}
output "cognito-user-pool-id" {
  value = module.cognito.user_pool_id
}
output "cognito-client-id" {
  value = module.cognito.client_id
}
output "cognito-usernames" {
  value = module.cognito.user_names
}
