resource "aws_lb" "front_end" {
  name               = "front-end-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main_sg.id]
  subnets            = aws_subnet.public_subnets.*.id

  enable_deletion_protection = false

  tags = {
    Environment = "test"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "front-end-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "front_end" {
  count            = length(aws_subnet.public_subnets)
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.front_end[count.index].id
  port             = 80
}
