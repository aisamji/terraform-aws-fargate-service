resource "aws_ecs_service" "default" {
  name            = var.name
  task_definition = aws_ecs_task_definition.default.arn
  launch_type     = "FARGATE"
  cluster         = var.cluster_arn
  desired_count   = local.use_load_balancer ? var.scaling.desired : 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  deployment_maximum_percent         = local.use_load_balancer ? var.scaling.max_count / var.scaling.desired * 100 : null
  deployment_minimum_healthy_percent = local.use_load_balancer ? var.scaling.min_count / var.scaling.desired * 100 : null
  health_check_grace_period_seconds  = local.use_load_balancer ? var.scaling.grace_period : null

  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"

  dynamic "load_balancer" {
    for_each = var.target_group_arns
    iterator = group

    content {
      target_group_arn = group.value
      container_name   = var.name
      container_port   = var.container_port
    }
  }
}

locals {
  use_load_balancer = length(var.target_group_arns) == 0 ? false : true
}
