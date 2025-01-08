resource "aws_wafv2_web_acl" "this" {
  count = var.waf_enabled != false ? 1 : 0

  name  = var.waf_name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  custom_response_body {
    key          = var.custom_response_body.key
    content      = var.custom_response_body.content
    content_type = var.custom_response_body.content_type
  }

  dynamic "rule" {
    for_each = var.allow_ips_rule_enabled ? [1] : []
    content {
      name     = "allow-ips"
      priority = 1

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.ips_to_allow.arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "allow-ips"
        sampled_requests_enabled   = true
      }
    }
  }


  dynamic "rule" {
    for_each = var.bot_control_rule_enabled ? [1] : []

    content {
      name     = "AWS-AWSManagedRulesBotControlRuleSet"
      priority = 10

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesBotControlRuleSet"
          vendor_name = "AWS"

          managed_rule_group_configs {
            aws_managed_rules_bot_control_rule_set {
              inspection_level = "COMMON"
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesBotControlRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.bot_control_rule_enabled ? [1] : []

    content {
      name     = "AWS-AWSManagedRulesBotControlRuleSet-CustomResponse"
      priority = 11

      action {
        block {
          custom_response {
            custom_response_body_key = var.custom_response_body.key
            response_code            = var.custom_response_body.code

            response_header {
              name  = var.custom_response_body.response_header.key
              value = var.custom_response_body.response_header.value
            }
          }
        }
      }

      statement {
        or_statement {
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:advertising"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:archiver"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:content_fetcher"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:email_client"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:http_library"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:link_checker"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:miscellaneous"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:monitoring"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:scraping_framework"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:search_engine"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:security"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:seo"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:social_media"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:category:ai"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:signal:automated_browser"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:signal:known_bot_data_center"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:signal:non_browser_user_agent"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:volumetric:ip:token_absent"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:volumetric:session:high"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:volumetric:session:medium"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:volumetric:session:low"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:signal:automated_browser"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:signal:browser_inconsistency"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:volumetric:session:token_reuse:ip"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:coordinated_activity:medium"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:coordinated_activity:high"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:targeted:aggregate:coordinated_activity:low"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:token:absent"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:bot-control:bot:verified"
              scope = "LABEL"
            }
          }

        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesBotControlRuleSet-CustomResponse"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_reputation_rule_enabled ? [1] : []

    content {
      name     = "AWS-AWSManagedRulesAmazonIpReputationList"
      priority = 20

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_reputation_rule_enabled ? [1] : []

    content {
      name     = "AWS-AWSManagedRulesAmazonIpReputationList-CustomResponse"
      priority = 21

      action {
        block {
          custom_response {
            custom_response_body_key = var.custom_response_body.key
            response_code            = var.custom_response_body.code

            response_header {
              name  = var.custom_response_body.response_header.key
              value = var.custom_response_body.response_header.value
            }
          }
        }
      }

      statement {
        or_statement {
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:amazon-ip-list:AWSManagedIPReputationList"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:amazon-ip-list:AWSManagedReconnaissanceList"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:amazon-ip-list:AWSManagedIPDDoSList"
              scope = "LABEL"
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList-CustomResponse"
        sampled_requests_enabled   = true
      }
    }
  }


  dynamic "rule" {
    for_each = var.anonymous_ip_rule_enabled ? [1] : []

    content {
      name     = "AWS-AWSManagedRulesAnonymousIpList"
      priority = 30

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAnonymousIpList"
          vendor_name = "AWS"
          version     = null
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesAnonymousIpList"
        sampled_requests_enabled   = true
      }
    }
  }


  dynamic "rule" {
    for_each = var.anonymous_ip_rule_enabled ? [1] : []

    content {
      name     = "AWS-AWSManagedRulesAnonymousIpList-CustomResponse"
      priority = 31

      action {
        block {
          custom_response {
            custom_response_body_key = var.custom_response_body.key
            response_code            = var.custom_response_body.code

            response_header {
              name  = var.custom_response_body.response_header.key
              value = var.custom_response_body.response_header.value
            }
          }
        }
      }

      statement {
        or_statement {
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:anonymous-ip-list:HostingProviderIPList"
              scope = "LABEL"
            }
          }
          statement {
            label_match_statement {
              key   = "awswaf:managed:aws:anonymous-ip-list:AnonymousIPList"
              scope = "LABEL"
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesAnonymousIpList-CustomResponse"
        sampled_requests_enabled   = true
      }
    }
  }


  dynamic "rule" {
    for_each = var.known_bad_inputs_rule_enabled ? [1] : []

    content {
      name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      priority = 40

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }


  dynamic "rule" {
    for_each = var.sql_injection_rule_enabled ? [1] : []

    content {

      name     = "AWS-AWSManagedRulesSQLiRuleSet"
      priority = 50

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.unix_rule_enabled ? [1] : []

    content {

      name     = "AWS-AWSManagedRulesUnixRuleSet"
      priority = 60

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesUnixRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesUnixRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.block_ips_rule_enabled ? [1] : []

    content {
      name     = "block-ips"
      priority = 70

      action {
        block {
          custom_response {
            custom_response_body_key = var.custom_response_body.key
            response_code            = var.custom_response_body.code

            response_header {
              name  = var.custom_response_body.response_header.key
              value = var.custom_response_body.response_header.value
            }
          }
        }
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.ips_to_block.arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.rate_limit_rule_enabled ? [1] : []

    content {
      name     = "RateLimitRule"
      priority = 7

      action {
        block {
          custom_response {
            custom_response_body_key = var.custom_response_body.key
            response_code            = var.custom_response_body.code

            response_header {
              name  = var.custom_response_body.response_header.key
              value = var.custom_response_body.response_header.value
            }
          }
        }
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit # 30 requests per second (600 requests per 5 minutes)
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimitRule"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.waf_name
    sampled_requests_enabled   = true
  }
}
