#Api Gateway
resource "aws_api_gateway_rest_api" "rest_api" {
  name = format("%s%s", local.project_prefix, "rest_api")

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.tags
}

resource "aws_api_gateway_method" "method" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id

  http_method   = "POST"
  authorization = "NONE"

  depends_on = [
    aws_api_gateway_rest_api.rest_api
  ]
}


resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id

  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn

  depends_on = [
    aws_api_gateway_method.method
  ]
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id

  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.integration
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.cors, aws_api_gateway_integration.integration, aws_api_gateway_method.method
  ]
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.env
}

module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.rest_api.id
  api_resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id

  depends_on = [
    aws_api_gateway_method.method, aws_api_gateway_integration.integration, aws_api_gateway_integration_response.integration_response
  ]
}

#SES
resource "aws_ses_email_identity" "ses_source" {
  email = var.ses_source
}

resource "aws_ses_email_identity" "ses_destination" {
  email = var.ses_destination
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/POST/"

  depends_on = [
    aws_api_gateway_method.method, aws_api_gateway_integration.integration, aws_api_gateway_integration_response.integration_response, aws_lambda_function.lambda
  ]
}

#DynamoDB
resource "aws_dynamodb_table" "dynamodb-table" {
  name = format("%s%s", local.project_prefix, "dynamodb")

  billing_mode   = var.dynamodb_billing_mode["provisioned"]
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_read_capacity
  hash_key       = var.dynamodb_hash_key
  range_key      = var.dynamodb_range_key

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "OrderType"
    type = "S"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  tags = local.tags
}

# Local resource
resource "local_file" "js" {
  content  = local.js_source
  filename = "./html/js/form.js"

  depends_on = [
    aws_api_gateway_deployment.deployment
  ]
}

data "archive_file" "lambda_zip" {
  type                    = "zip"
  source_content          = local.lambda_source
  source_content_filename = "lambda_zip.py"
  output_path             = "./lambda.zip"

  depends_on = [
    aws_dynamodb_table.dynamodb-table
  ]
}

# Lambda
resource "aws_lambda_function" "lambda" {
  function_name = format("%s%s", local.project_prefix, "lambda")

  filename = var.lambda_zip
  role     = aws_iam_role.lambda_role.arn
  handler  = "lambda.lambda_handler"
  runtime  = var.lambda_runtime

  environment {
    variables = {
      LAMBDA_SES_SOURCE      = aws_ses_email_identity.ses_source.email
      LAMBDA_SES_DESTINATION = aws_ses_email_identity.ses_destination.email
      TTL                    = var.ttl
    }
  }

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = local.tags

  depends_on = [
    aws_ses_email_identity.ses_source, aws_ses_email_identity.ses_destination, aws_dynamodb_table.dynamodb-table, data.archive_file.lambda_zip
  ]
}

# IAM
resource "aws_iam_role" "lambda_role" {
  name               = format("%s%s", local.project_prefix, "lambda_role")
  assume_role_policy = local.lambda_assume_role

  inline_policy {
    name   = format("%s%s", local.project_prefix, "lambda_inline_policy")
    policy = local.lambda_inline_policy
  }

  tags = local.tags
}