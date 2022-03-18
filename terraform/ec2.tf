data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "front_end" {
  count                       = length(aws_subnet.public_subnets)
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets[count.index].id

  vpc_security_group_ids = [
    aws_security_group.main_sg.id,
  ]

  user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install -y httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    echo “Hello World from $(hostname -f)” > /var/www/html/index.html
        EOF

  tags = {
    Name = "HelloWorld_${count.index + 1}"
  }
}
