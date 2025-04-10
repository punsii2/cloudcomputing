resource "aws_security_group" "app" {
  name        = "${local.env}-app"
  description = "Security Group for the App-Instances"
  vpc_id      = module.vpc.vpc_id
  tags        = local.standard_tags
}

resource "aws_security_group_rule" "app_ingress_ssh_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allows SSH from everywhere"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ToDo: Allow Ingress from the Security Group of the Load Balancer to the App Security Group in port 8080
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule

# resource "aws_security_group_rule" "app_ingress_http_lb" {
#   security_group_id        =
#   description              = "Allows HTTP access from the load balancer"
#   type                     = "ingress"
#   from_port                =
#   to_port                  =
#   protocol                 = "tcp"
#   source_security_group_id =
# }

resource "aws_security_group_rule" "app_egress_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allows all outgoing traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_launch_template" "app" {
  name                                 = local.env
  image_id                             = "ami-07cb013c9ecc583f0"
  instance_initiated_shutdown_behavior = "terminate"
  update_default_version               = true
  instance_type                        = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.standard_tags
  }

  user_data = base64encode(
    templatefile(
      "${path.module}/init.sh", { message = local.config.message }
    )
  )
}

# ToDo: Create an AutoScaling Group that manages 0 to 4 instances, with a default of 1
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group

# resource "aws_autoscaling_group" "app" {
#   name                = local.env
#   min_size            =
#   max_size            =
#   desired_capacity    =
#   vpc_zone_identifier = module.vpc.public_subnets
#   health_check_type   =
#   target_group_arns   = []

#   launch_template {
#     id =
#   }

#   dynamic "tag" {
#     for_each = local.standard_tags_asg
#     content {
#       key                 = tag.value.key
#       propagate_at_launch = tag.value.propagate_at_launch
#       value               = tag.value.value
#     }
#   }
# }
