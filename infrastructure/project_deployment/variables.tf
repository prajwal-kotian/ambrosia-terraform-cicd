variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Indicates the AWS environment resources are to be deployed to"
  type        = string
  default     = "test"
}

variable "ses_source" {
  description = "The id ses will control to send out emails."
  type        = string
}

variable "ses_destination" {
  description = "The id that will recieve emails."
  type        = string
}

variable "lambda_zip" {
  description = "Name of the zip file with lambda code."
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = map(string)
  default = {
    "pay_per_request" = "PAY_PER_REQUEST",
    "provisioned"     = "PROVISIONED"
  }
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB number of RCU."
  type        = number
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB number of WCU."
  type        = number
}

variable "dynamodb_hash_key" {
  description = "DynamoDB primary key."
  type        = string
}

variable "dynamodb_range_key" {
  description = "DynamoDB sort key."
  type        = string
}

variable "ttl" {
  description = "DynamoDB item TTL."
  type        = number
}

variable "s3_acl_privacy" {
  description = "s3 ACL privacy setting."
  type        = string
  default     = "private"
}

variable "cdn_price_class" {
  description = "CDN price class"
  type        = map(string)
  default = {
    "all" = "PriceClass_All",
    "100" = "PriceClass_100",
    "200" = "PriceClass_200"
  }
}

variable "geo_restriction_whitelist" {
  description = "List of whitelisted countires"
  type        = list(string)
}

variable "index_document" {
  description = "Index html document name"
  type        = string
}

variable "ip" {
  type = list(string)
}

variable "waf_scope" {
  description = "WAF scope"
  type        = map(string)
  default = {
    "cf"       = "CLOUDFRONT",
    "regional" = "REGIONAL"
  }
}