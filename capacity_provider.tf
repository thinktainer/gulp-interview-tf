resource "aws_autoscaling_group" "mongo-instances" {
  min_size = 1
  max_size = 1

  vpc_zone_identifier = [aws_subnet.database-az-a.id]
  protect_from_scale_in = false
  launch_template {
    id = aws_launch_template.amzn-latest-micro.id
  }

  tag {
    key = "AmazonECSManaged"
    value = ""
    propagate_at_launch = true
  }
}

data "aws_ami" "amzn-linux-latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "amzn-latest-micro" {
  image_id      = data.aws_ami.amzn-linux-latest.id
  instance_type = "t3.micro"
}

resource "aws_ecs_capacity_provider" "mongo-ec2" {
  name = "mongo-ec2"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.mongo-instances.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status = "ENABLED"
    }
  }
}
