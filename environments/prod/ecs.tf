resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${local.env_prefix}-cluster"
  tags = {
    Name        = "${local.env_prefix}-ecs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${local.env_prefix}-logs"
  retention_in_days = var.aws_cloudwatch_retention_in_days

  tags = {
    Application = local.env_prefix
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${local.env_prefix}-task"

  container_definitions = <<TASK_DEFINITION
  [
    {
      "name": "${local.env_prefix}-container",
      "image": "${local.app_image}",
      "entryPoint": ["python"],
      "command": ["app.py"],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${local.env_prefix}"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  TASK_DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn

  tags = {
    Name        = "${local.env_prefix}-ecs-td"
    Environment = var.environment
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}

### ECS service
resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${local.env_prefix}-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = module.vpc_networking.public_subnet_ids
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${local.env_prefix}-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.listener]
}
