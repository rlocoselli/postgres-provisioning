variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
    default = "us-east-1"
}

variable "bucket_name" {}

variable "acl" {
    default = "private"
}
