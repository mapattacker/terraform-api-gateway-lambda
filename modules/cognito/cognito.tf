
resource "aws_cognito_user_pool" "main" {
  name = "cup-${var.department}-main-api-${var.project}-${var.env}"
  tags = var.tags
}

resource "aws_cognito_user_pool_client" "client" {
  # app integration client, default token expiry 1 hr
  name                = "${var.project}-${var.env}"
  user_pool_id        = aws_cognito_user_pool.main.id
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  id_token_validity   = var.id_expiry_hours
}

resource "aws_cognito_user" "main" {
  # one client, but many users
  count        = length(var.key_names)
  user_pool_id = aws_cognito_user_pool.main.id
  username     = "${var.project}-${var.key_names[count.index]}"

  attributes = {
    email          = var.email
    email_verified = true
  }
}


# output ------

output "user_pool_arn" {
  value = aws_cognito_user_pool.main.arn
}
output "user_pool_id" {
  value = aws_cognito_user_pool.main.id
}
output "client_id" {
  value = aws_cognito_user_pool_client.client.id
}
output "user_names" {
  value = [aws_cognito_user.main.*.username]
}
