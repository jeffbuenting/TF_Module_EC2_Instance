# Terraform module to create an EC2 Insance

data "aws_key_pair" "kp" {
  key_name = var.kp_name
  #key_name           = "InstanceKey"
  include_public_key = true
}

# Key Pair for instance
# data "terraform_remote_state" "kp" {
#   backend = "local"

#   config = {
#     path = "${path.module}/buildtestservers/keypair/terraform.tfstate"
#   }
# }

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "instance" {
  count = var.num_instances

  ami                  = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.SSMInstanceProfile.name

  vpc_security_group_ids = [aws_security_group.instance.id]
  get_password_data      = true
  # key_name               = kp.name
  key_name = "InstanceKey"

  tags = {
    Name       = "${var.instance_name}-${count.index}"
    PatchGroup = "${var.patchgroup}"
  }
}

resource "aws_security_group" "instance" {
  name = "Test-instance"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instance.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_rdp_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_iam_role" "SSMManagedInstance_Role" {
  name = "SSMManagedInstance-Role"

  assume_role_policy = <<EOF
    {
      "Version" : "2012-10-17",
      "Statement" : {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com",
            "ssm.amazonaws.com"
          ]
        }
      }
    }
  EOF

  tags = {
    tag-key = "Deployed-Terraform"
  }
}

resource "aws_iam_instance_profile" "SSMInstanceProfile" {
  name = "SSM-Instance-Profile"
  role = aws_iam_role.SSMManagedInstance_Role.name
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "AmazonSSMAutomationRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_role_policy_attachment" "SSMInstancePolicy" {
  role = aws_iam_role.SSMManagedInstance_Role.name

  for_each = toset([
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
    data.aws_iam_policy.AmazonSSMAutomationRole.arn
  ])

  policy_arn = each.key
}



