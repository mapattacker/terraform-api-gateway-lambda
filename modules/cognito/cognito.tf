
resource "aws_cognito_user_pool" "main" {
  name = "cup-${var.department}-main-api-${var.project}-${var.env}"
  tags = var.tags
}

resource "aws_cognito_user" "example" {
  count         = length(var.key_names)
  user_pool_id = aws_cognito_user_pool.main.id
  username     = "${var.project}-${var.key_names[count.index]}"
}
