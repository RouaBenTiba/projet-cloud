resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.frontend.id]

  user_data = base64encode(templatefile("user_data_frontend.sh", {
    github_repo = var.github_repo
    alb_dns     = aws_lb.main.dns_name
  }))

  tags = {
    Name    = "${var.project_name}-frontend"
    Project = var.project_name
  }
}
