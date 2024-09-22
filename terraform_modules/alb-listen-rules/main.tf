resource "aws_lb_listener_rule" "lb_listener_rule" {
  count = var.module_enabled ? 1 : 0

  listener_arn = var.listener_arn

  priority = var.priority

  # Add a single action
  action {
    type             = var.action.type
    target_group_arn = try(var.action.target_group_arn, null)

    dynamic "fixed_response" {
      for_each = try([var.action.fixed_response], [])

      content {
        message_body = try(fixed_response.value.message_body, null)
        content_type = fixed_response.value.content_type
        status_code  = try(fixed_response.value.status_code, null)
      }
    }

    dynamic "forward" {
      for_each = try([var.action.forward], [])

      content {
        dynamic "target_group" {
          for_each = forward.value.target_groups

          content {
            arn    = target_group.value.arn
            weight = try(target_group.value.weight, null)
          }
        }

        dynamic "stickiness" {
          for_each = try([forward.value.stickiness], [])

          content {
            duration = stickiness.value.duration
            enabled  = try(stickiness.value.enabled, false)
          }
        }
      }
    }
  }

  dynamic "condition" {
    for_each = var.conditions

    content {
      dynamic "host_header" {
        for_each = try([condition.value.host_header], [])

        content {
          values = host_header.value.values
        }
      }

      dynamic "http_header" {
        for_each = try([condition.value.http_header], [])

        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = try([condition.value.http_request_method], [])

        content {
          values = http_request_method.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = try([condition.value.path_pattern], [])

        content {
          values = path_pattern.value.values
        }
      }

      dynamic "query_string" {
        for_each = try([condition.value.query_string], [])

        content {
          key   = try(query_string.value.key, null)
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = try([condition.value.source_ip], [])

        content {
          values = source_ip.value.values
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags       = var.tags
  depends_on = [var.module_depends_on]
}