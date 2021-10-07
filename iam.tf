data "aws_partition"  "current" {}

resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs_instance_role"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs-instance-role.name
}

resource "aws_iam_role_policy_attachment" "ecs-ec2-role" {
  role = aws_iam_role.ecs-instance-role.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam:aws/policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

