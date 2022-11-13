# Get Latest AMI for Amazon Linux 2 x86_64
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*-x86_64*"]
  }
}

# Import Terraform EC2 modules - Create EC2 Instances - Bootstrap Nodejs app deployment
module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 3.0"
  for_each                    = local.ec2_nodes
  name                        = "${upper(var.project_name)}-${upper(each.value["alpha"])}"
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  subnet_id                   = each.value["subnet_id"]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.id
  monitoring                  = true
  associate_public_ip_address = true
  ebs_optimized               = true
  key_name                    = var.create_keypair ? aws_key_pair.generated_key[0].key_name : var.keypair_name
  user_data                   = <<-EOF_user_data
    #!/bin/bash
    yum update -y
    yum install -y git docker
    usermod -a -G docker ec2-user
    systemctl start docker
    systemctl enable docker
    su - ec2-user -s /bin/bash -c "cd ~;
    git clone https://github.com/ferzconnect01/quest.git;
    cd quest;
    docker build -t quest:v1 .;
    docker run -d --restart=unless-stopped --env="SECRET_WORD=`/usr/bin/aws --region=${var.aws_region} ssm get-parameters --with-decryption --names /nva-quest-01/docker/secret --query "Parameters[*].Value" --output text`" -p 3000:3000 quest:v1"
    EOF_user_data

  root_block_device = [{
    encrypted   = true
    volume_size = each.value["volume_size"]
    volume_type = each.value["volume_type"]
  }]
}

# Create EC2 SG
resource "aws_security_group" "ec2" {
  name   = "${upper(var.project_name)}-EC2"
  vpc_id = var.vpc_id[var.aws_region]

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = var.instance_application_port
    to_port         = var.instance_application_port
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${upper(var.project_name)}-EC2"
  }
}
