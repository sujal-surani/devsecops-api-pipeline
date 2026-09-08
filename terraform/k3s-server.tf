resource "aws_instance" "k3s_server" {
  ami = "ami-01a00762f46d584a1"
  instance_type = "t3.small"
  vpc_security_group_ids = [ aws_security_group.k3s-sg.id ]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags={
    Name = "devsecops-k3s-server"
  }
}