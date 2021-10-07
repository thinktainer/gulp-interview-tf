resource "aws_ecs_cluster" "main" {
  name = "main"
  capacity_providers = [ "FARGATE" , "mongo-ec2"]
  depends_on = [aws_ecs_capacity_provider.mongo-ec2]
}

resource "aws_ecs_task_definition" "mongo" {
  container_definitions = file("${path.module}/mongo_container.json")
  family = "mongo"
  network_mode = "awsvpc"
}

resource "aws_ecs_task_definition" "web-server" {
  container_definitions =  file("${path.module}/hello_world_container.json")
  family = "web-server"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
}

resource "aws_ecs_service" "web-server" {
  name = "web-server"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web-server.arn
  desired_count = 2

  capacity_provider_strategy {
    base = 1
    capacity_provider = "FARGATE"
    weight = 100
  }

  network_configuration {
    subnets = [aws_subnet.web-az-a.id, aws_subnet.web-az-b.id]
    security_groups = [aws_security_group.lb.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web-public.arn
    container_name = "helloworld"
    container_port = 80
  }
}

resource "aws_ecs_service" "mongo" {
  name = "mongodb"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count = 1

  capacity_provider_strategy {
    base = 1
    capacity_provider = "mongo-ec2"
    weight = 100
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [aws_subnet.database-az-a.id]
  }
}
