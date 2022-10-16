#WAF
resource "aws_wafv2_ip_set" "cloudfront_allowed_ips" {
  name = format("%s%s", local.project_prefix, "cf_allowed_ips")

  description        = "Whitelisted IP set"
  scope              = var.waf_scope["cf"]
  ip_address_version = "IPV4"
  addresses          = var.ip
  tags               = local.tags
}

resource "aws_wafv2_ip_set" "api_gateway_allowed_ips" {
  name = format("%s%s", local.project_prefix, "api_gw_allowed_ips")

  description        = "Whitelisted IP set"
  scope              = var.waf_scope["regional"]
  ip_address_version = "IPV4"
  addresses          = var.ip
  tags               = local.tags
}

resource "aws_wafv2_web_acl" "cloudfront_web_acl" {
  name        = format("%s%s", local.project_prefix, "ambrosia_cf_web_acl")
  description = "Web ACL with IP filtering and Rate based restrictions."
  scope       = var.waf_scope["cf"]

  default_action {
    block {}
  }

  rule {
    name     = "ip_filterting_rule"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.cloudfront_allowed_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "cloudfront_waf_ip_filtering_rule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate_based_rule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = var.geo_restriction_whitelist
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "cloudfront_waf_rate_based_rule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfront_waf_rule"
    sampled_requests_enabled   = true
  }

  tags = local.tags

  depends_on = [
    aws_wafv2_ip_set.cloudfront_allowed_ips
  ]
}

resource "aws_wafv2_web_acl" "api_gateway_web_acl" {
  name        = format("%s%s", local.project_prefix, "ambrosia_api_gateway_web_acl")
  description = "Web ACL with IP filtering and Rate based restrictions."
  scope       = var.waf_scope["regional"]

  default_action {
    block {}
  }

  rule {
    name     = "ip_filterting_rule"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.api_gateway_allowed_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "api_gateway_ip_filtering_rule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate_based_rule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = var.geo_restriction_whitelist
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "api_gateway_waf_rate_based_rule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "api_gateway_waf_rule"
    sampled_requests_enabled   = true
  }

  tags = local.tags

  depends_on = [
    aws_wafv2_ip_set.api_gateway_allowed_ips
  ]
}

resource "aws_wafv2_web_acl_association" "api_gateway_web_acl_association" {
  resource_arn = aws_api_gateway_stage.stage.arn
  web_acl_arn  = aws_wafv2_web_acl.api_gateway_web_acl.arn

  depends_on = [
    aws_wafv2_web_acl.api_gateway_web_acl, aws_api_gateway_stage.stage
  ]
}
