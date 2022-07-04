variable "project" { type = string }
variable "company" { type = string }
variable "department" { type = string }
variable "team" { type = string }
variable "env" { type = string }
variable "key_names" { type = list(any) }
variable "email" { type = string }
variable "id_expiry" { type = number }

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}
