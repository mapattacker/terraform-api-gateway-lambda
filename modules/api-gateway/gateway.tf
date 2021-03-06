# API gateway timeout is 30s by default, non-configurable


resource "aws_api_gateway_rest_api" "main" {
  # naming api gateway
  name        = "api-gateway-${var.project}-${var.env}"
  description = "API gateway for ${var.project}"
  tags        = var.tags
}

resource "aws_api_gateway_resource" "main" {
  # define API endpoint
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}


# method, authentication & authorization ------

resource "aws_api_gateway_method" "main" {
  # define the method(s), e.g. GET / POST / etc.
  # add api key & cognito requirements
  resource_id = aws_api_gateway_resource.main.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  # authorization    = "NONE"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.main.id
  api_key_required = true
  http_method      = "ANY"
}

resource "aws_api_gateway_authorizer" "main" {
  # link to cognito user pool
  name          = "cognito-authorizer-${var.project}"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.cognito_user_pool_arn]
}


# integration ------

resource "aws_api_gateway_integration" "main" {
  # link with a lambda function
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}


# deployment to stage ------

resource "aws_api_gateway_deployment" "main" {
  # deploy API to a stage
  rest_api_id = aws_api_gateway_rest_api.main.id
  depends_on = [
    aws_api_gateway_integration.main
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  # define a stage
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.env
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway-${var.project}-${var.env}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}


# API keys & Usage Plans ------

resource "aws_api_gateway_usage_plan" "main" {
  name = var.project

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  quota_settings {
    limit  = 50000
    period = "WEEK"
  }
  throttle_settings {
    burst_limit = 5
    rate_limit  = 50
  }

  tags = var.tags
}

resource "aws_api_gateway_api_key" "main" {
  # create multiple api-keys
  count = length(var.key_names)
  name  = "api-key-${var.project}-${var.env}-${var.key_names[count.index]}"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  # attach each key to the project usage plan
  count         = length(var.key_names)
  key_id        = aws_api_gateway_api_key.main.*.id[count.index]
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}


# output ------

output "api_stage_url" {
  value = aws_api_gateway_stage.main.invoke_url
}
