# --- compute/main.tf ---


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR ANSIBLE CN

resource "aws_launch_template" "custom_ansiblecn" {
  name_prefix            = "custom_ansiblecn"
  instance_type          = var.instance_type
  image_id               = "ami-013168dc3850ef002"
  vpc_security_group_ids = [var.custom_ansible_sg]
  user_data              = filebase64("ansible_cn_config.sh")
  iam_instance_profile {
    name = var.ansible_instance_profile
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Service = "custom_ansiblecn"
      Name = "custom_ansiblecn"
    }
  }
}

resource "aws_autoscaling_group" "custom_ansiblecn" {
  name                = "custom_ansiblecn"
  vpc_zone_identifier = var.private_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.custom_ansiblecn.id
    version = "$Latest"
  }
}
#depends_on = [var.custom_ngw]

# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR WEBSERVERS

resource "aws_launch_template" "custom_webserver" {
  name_prefix            = "custom_webserver"
  instance_type          = var.instance_type
  image_id               = "ami-013168dc3850ef002"
  vpc_security_group_ids = [var.custom_webserver_sg]
  key_name               = var.key_name
  iam_instance_profile {
    name = var.webserver_instance_profile
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Service = "custom_webserver"
      Name = "custom_webserver"
    }
  }
}


resource "time_sleep" "wait_200_seconds" {
  depends_on = [aws_autoscaling_group.custom_ansiblecn]

  create_duration = "200s"
}

resource "aws_autoscaling_group" "custom_webserver" {
  name                = "custom_webserver"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 2
  desired_capacity    = 2

  target_group_arns = [var.lb_tg_arn]

  launch_template {
    id      = aws_launch_template.custom_webserver.id
    version = "$Latest"
  }

  depends_on = [
     time_sleep.wait_200_seconds
  ]
}


resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.custom_webserver.id
  lb_target_group_arn    = var.lb_tg_arn
}
