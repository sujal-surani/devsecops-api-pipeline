resource "aws_security_group" "k3s-sg" {
  name = "devsecops-k3s-sg"
  description = "Allow inbound traffics for k3s cluster"

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0"]
  }

  ingress{
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0"]
  }
  
  egress{
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0"]
  }
}