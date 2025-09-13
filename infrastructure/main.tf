provider "aws" {
  region = "us-east-1"
}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "node-app-cluster"
}

# Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Task Definition (using existing IAM Role)
resource "aws_ecs_task_definition" "task" {
  family                   = "node-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  # Use your existing ECS Task Execution Role
  execution_role_arn = "arn:aws:iam::692859912964:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "node-app"
      image     = "docker.io/pravalika27/taskdev:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

# ECS Service (Fargate, public IP, no ALB)
resource "aws_ecs_service" "service" {
  name            = "node-app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
