# ── AMI：最新 Amazon Linux 2023 ───────────────────────────
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Security Group ────────────────────────────────────────
resource "aws_security_group" "jenkins" {
  name        = "${var.vpc_name}-jenkins-sg"
  description = "Jenkins server security group"
  vpc_id      = var.vpc_id          # ✅ 改为变量

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins Web UI"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]    # ✅ 改为变量
    description = "SSH from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-jenkins-sg"
  })
}

# ── IAM Role ──────────────────────────────────────────────
resource "aws_iam_role" "jenkins" {
  name = "${var.vpc_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.vpc_name}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}

# ── EC2 实例 ──────────────────────────────────────────────
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name

  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile("${path.module}/userdata.sh", {
    jenkins_version = var.jenkins_version
  })

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-jenkins"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}