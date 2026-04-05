data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
      name = "virtualization-type"
      values = [ "hvm" ]
    }
}

resource "aws_launch_template" "budget_app_lt" {
  name_prefix = "budget_app_lt_"
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Hello from my private Budget App server!</h1>" > /var/www/html/index.html
              EOF
  )
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.web_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {Name = "BudgetTracker_AGS_Server"}
  }
}

resource "aws_lb_target_group" "TargetGroup" {
  name = "budget-app-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.Budget_app.id

  health_check {
    path = "/"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
  }
}

resource "aws_lb" "App_lb" {
  name = "budget-app-elb"
  internal = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.web_sg.id]
  subnets = [aws_subnet.app_subnet1.id,aws_subnet.app_subnet2.id]
}

resource "aws_lb_listener" "ELB_listener" {
  load_balancer_arn = aws_lb.App_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.TargetGroup.arn
  }
}

resource "aws_autoscaling_group" "App_AutoScaling" {
  name = "budget_app_AG"
  vpc_zone_identifier = [aws_subnet.app_subnet1.id,aws_subnet.app_subnet2.id]
  target_group_arns = [aws_lb_target_group.TargetGroup.arn]
  min_size = 1
  desired_capacity = 2
  max_size = 4
  launch_template {
    id = aws_launch_template.budget_app_lt.id
    version = "$Latest"
  }
}

