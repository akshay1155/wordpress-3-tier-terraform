resource "aws_lb_target_group" "lb-wordpress-tg" {
  name     = "lb-wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo_vpc.id
}
resource "aws_lb_target_group_attachment" "aws_lb_attachment1" {
  target_group_arn = aws_lb_target_group.lb-wordpress-tg.arn
  target_id        = aws_instance.private_instance_server.id
  port             = 80
}
resource "aws_lb" "lb-wordpress" {
  name               = "lb-wordpress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = [aws_subnet.private_subnet_server.id,aws_subnet.public_subnet.id]
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb-wordpress.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-wordpress-tg.arn
  }
}

resource "aws_security_group" "load_balancer_sg" {
  name   = "load_balancer_sg"
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_security_group_rule" "allow_http_lb" {
  type              = "ingress"
  description       = "HTTP ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer_sg.id
}
resource "aws_security_group_rule" "allow_egress_lb" {
  type              = "egress"
  description       = "all traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer_sg.id
}