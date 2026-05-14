data "aws_ami" "ubuntu_22" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_integer" "subnet_index" {
  min = 0
  max = length(var.public_subnet_ids) - 1
}

resource "aws_security_group" "kubectl_sg" {
  name        = "${var.eks_cluster_name}-kubectl-sg"
  description = "Allow SSH inbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_kubectl_to_eks" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id = var.eks_cluster_security_group_id
  source_security_group_id = aws_security_group.kubectl_sg.id
  description              = "Allow management server to access EKS Private API"
}

resource "aws_instance" "kubectl_server" {
  ami                         = data.aws_ami.ubuntu_22.id
  instance_type               = "t3.nano"
  subnet_id                   = var.public_subnet_ids[random_integer.subnet_index.result]
  vpc_security_group_ids      = [aws_security_group.kubectl_sg.id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.kubectl_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              apt-get update -y
              apt-get install -y unzip curl

              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x ./kubectl
              mv ./kubectl /usr/local/bin/

              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              echo "Waiting for EKS cluster to be ACTIVE..."
              for i in {1..20}; do
                STATUS=$(aws eks describe-cluster --name ${var.eks_cluster_name} --region ${var.aws_region} --query "cluster.status" --output text)
                if [ "$STATUS" == "ACTIVE" ]; then
                  echo "Cluster is ACTIVE!"
                  break
                fi
                echo "Current status: $STATUS. Waiting..."
                sleep 10
              done

              mkdir -p /home/ubuntu/.kube/
              sudo -u ubuntu /usr/local/bin/aws eks update-kubeconfig --region ${var.aws_region} --name ${var.eks_cluster_name}
              chown ubuntu:ubuntu /home/ubuntu/.kube/config
              EOF

  tags = {
    Name = "${var.eks_cluster_name}-kubectl-ubuntu"
  }

  depends_on = [
    aws_iam_instance_profile.kubectl_profile,
    aws_eks_access_policy_association.kubectl_admin_policy
  ]
}