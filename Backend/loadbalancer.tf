resource "aws_lb" "public_nlb" {
  name = "budget_public_nlb"
  internal = false
  load_balancer_type = "network"
  subnets = [aws_subnet.public_subnet1.id,aws_subnet.public_subnet2.id]
  tags = {Name = "Public_NLB"}
}

resource "aws_lb_target_group" "nlb_tg" {
  name = "nlg-tg"
  target_type = "alb"
  port = 80
  protocol = "TCP"
  vpc_id = aws_vpc.Budget_app.id
}

resource "aws_lb_target_group_attachment" "nlb_to_elb" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id = aws_lb.App_lb.arn
  port = 80
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.public_nlb.arn
  port = "80"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}