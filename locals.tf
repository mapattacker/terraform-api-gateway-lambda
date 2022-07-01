locals {
  tags = {
    project     = var.project
    terraform   = "true"
    division    = var.department
    team        = var.team
    environment = var.env
  }
}
