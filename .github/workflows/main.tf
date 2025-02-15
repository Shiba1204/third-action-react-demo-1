provider "aws" { 
  region = "us-east-2"  # Change this to your region 
} 

resource "aws_instance" "apm_ec2" { 
  ami                    = "ami-0c55b159cbfafe1f0"  # Change based on your region 
  instance_type          = "t2.micro" 
  key_name               = "your-key-name"  # Ensure you have an SSH key 
  iam_instance_profile   = aws_iam_instance_profile.apm_profile.name 
  security_groups        = [aws_security_group.apm_sg.name] 

  tags = { 
    Name = "APM-EC2-Instance" 
  } 
} 

resource "aws_security_group" "apm_sg" { 
  name        = "apm-security-group" 
  description = "Allow inbound access" 

  ingress { 
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 

ingress { 
    from_port   = 80 
    to_port     = 80 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 

  ingress { 
    from_port   = 3000 
    to_port     = 3000 
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

resource "aws_iam_role" "apm_role" { 
  name = "APMRole" 

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
} 

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" { 
  role       = aws_iam_role.apm_role.name 
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" 
} 

resource "aws_iam_instance_profile" "apm_profile" { 
  name = "APMInstanceProfile" 
  role = aws_iam_role.apm_role.name 
} 

output "ec2_public_ip" { 
  value = aws_instance.apm_ec2.public_ip 
}