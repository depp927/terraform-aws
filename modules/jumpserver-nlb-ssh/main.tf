resource "aws_security_group" "nlb" {
  name        = "${var.nlb_name}-sg"
  description = "Public NLB security group for JumpServer SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.nlb_name}-sg"
  })
}

resource "aws_lb" "this" {
  name               = var.nlb_name
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb.id]
  subnets            = var.subnet_ids

  tags = merge(var.tags, {
    Name = var.nlb_name
  })
}

resource "aws_lb_target_group" "ssh" {
  name        = "${var.nlb_name}-tg"
  port        = var.target_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = tostring(var.target_port)
  }

  tags = merge(var.tags, {
    Name = "${var.nlb_name}-tg"
  })
}

resource "aws_lb_target_group_attachment" "ssh" {
  target_group_arn = aws_lb_target_group.ssh.arn
  target_id        = var.target_id
  port             = var.target_port
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.this.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssh.arn
  }
}
