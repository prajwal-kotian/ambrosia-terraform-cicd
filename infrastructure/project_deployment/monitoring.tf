# CLoudWatch Dashboard
resource "aws_cloudwatch_dashboard" "backend_metrics" {
  dashboard_name = format("%s_%s", local.project_prefix, "backend_metrics")

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda",
            "Invocations",
            "FunctionName",
            "${aws_lambda_function.lambda.function_name}"
          ],
          [
            "AWS/Lambda",
            "Errors",
            "FunctionName",
            "${aws_lambda_function.lambda.function_name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Lambda Metrics"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/DynamoDB",
            "ConsumedReadCapacityUnits",
            "TableName",
            "${aws_dynamodb_table.dynamodb-table.name}"
          ],
          [
            "AWS/DynamoDB",
            "ProvisionedReadCapacityUnits",
            "TableName",
            "${aws_dynamodb_table.dynamodb-table.name}"
          ],
          [
            "AWS/DynamoDB",
            "ConsumedWriteCapacityUnits",
            "TableName",
            "${aws_dynamodb_table.dynamodb-table.name}"
          ],
          [
            "AWS/DynamoDB",
            "ProvisionedWriteCapacityUnits",
            "TableName",
            "${aws_dynamodb_table.dynamodb-table.name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "DynamoDB Metrics"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApiGateway",
            "Latency",
            "ApiName",
            "${aws_api_gateway_rest_api.rest_api.name}"
          ],
          [
            "AWS/ApiGateway",
            "IntegrationLatency",
            "ApiName",
            "${aws_api_gateway_rest_api.rest_api.name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "API Gateway Latency Metrics"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApiGateway",
            "Count",
            "ApiName",
            "${aws_api_gateway_rest_api.rest_api.name}"
          ],
          [
            "AWS/ApiGateway",
            "4XXError",
            "ApiName",
            "${aws_api_gateway_rest_api.rest_api.name}"
          ],
          [
            "AWS/ApiGateway",
            "5XXError",
            "ApiName",
            "${aws_api_gateway_rest_api.rest_api.name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "API Gateway Metrics"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_dashboard" "website_metrics" {
  dashboard_name = format("%s_%s", local.project_prefix, "website_metrics")

  dashboard_body = <<EOF
{

    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [
              "AWS/CloudFront",
              "Request",
              "DistributionId",
              "${aws_cloudfront_distribution.s3_distribution.id}"
            ],
            [
              "AWS/CloudFront",
              "4XXErrorRate",
              "DistributionId",
              "${aws_cloudfront_distribution.s3_distribution.id}"
            ],
            [
              "AWS/CloudFront",
              "5XXErrorRate",
              "DistributionId",
              "${aws_cloudfront_distribution.s3_distribution.id}"
            ]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "CloudFront Metrics"
        }
      }
    ]
}  

EOF
}

resource "aws_cloudwatch_dashboard" "security_metrics" {
  dashboard_name = format("%s_%s", local.project_prefix, "security_metrics")

  dashboard_body = <<EOF
{

    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [
              "AWS/WAFV2",
              "AllowedRequests",
              "WebACL",
              "${aws_wafv2_web_acl.api_gateway_web_acl.id}"
            ],
            [
              "AWS/WAFV2",
              "BlockedRequests",
              "WebACL",
              "${aws_wafv2_web_acl.api_gateway_web_acl.id}"
            ]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Api Gateway WAF Metrics"
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [
              "AWS/WAFV2",
              "AllowedRequests",
              "${aws_wafv2_web_acl.cloudfront_web_acl.id}",
              "ip_filterting_rule"

            ],
            [
              "AWS/WAFV2",
              "BlockedRequests",
              "${aws_wafv2_web_acl.cloudfront_web_acl.id}",
              "ip_filterting_rule"
            ]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Cloudfront WAF Metrics"
        }
      }
    ]
}  

EOF
}

