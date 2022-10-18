region = "us-east-1"
env    = "dev"

ses_source              = "#{ses_source}#"
ses_destination         = "#{ses_destination}#"
lambda_zip              = "lambda.zip"
lambda_runtime          = "python3.7"
dynamodb_read_capacity  = 10
dynamodb_write_capacity = 10
dynamodb_hash_key       = "UserId"
dynamodb_range_key      = "OrderType"
ttl                     = 30

s3_acl_privacy            = "private"
geo_restriction_whitelist = ["US", "IN"]
index_document            = "index.html"

ip = [""]