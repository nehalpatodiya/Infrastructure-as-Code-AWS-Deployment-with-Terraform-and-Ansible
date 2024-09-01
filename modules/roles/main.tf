# --- roles/main.tf ---

## CUSTOM ROLE FOR EC2 TO BE MANAGED BY SSM

resource "aws_iam_role" "terraform_webserver_ssm" {
  name                = "terraform_webserver_ssm"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "1"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  }) 
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

resource "aws_iam_instance_profile" "terraform_webserver_ssm_instance_profile" {
  name = "terraform_webserver_ssm_instance_profile"
  role = aws_iam_role.terraform_webserver_ssm.name
}


## CUSTOM ROLE FOR ANSIBLE CONTROLLER TO GET DATA FORM S3

resource "aws_iam_policy" "custom_ansible_s3" {
  name = "custom_ansible_s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Action: ["s3:GetObject","s3:ListBucket"]
      Effect: "Allow"
			Resource: ["arn:aws:s3:::custom-data-store/*","arn:aws:s3:::custom-data-store"]
      },
    ]
  })
}

resource "aws_iam_policy" "custom_ansible_ec2" {
  name = "custom_ansible_ec2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Action: ["ec2:DescribeAddresses",
				"ec2:DescribeInstances",
				"ec2:DescribeTags",
				"ec2:DescribeInstanceTypes",
				"ec2:DescribeInstanceStatus",
				"ec2:DescribeInstanceAttribute",
        "ec2:CreateTags"]
      Effect: "Allow"
			Resource: "*"
      },
    ]
  })
}

resource "aws_iam_role" "terraform_ansible_ssm_s3" {
  name                = "terraform_ansible_ssm_s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "1"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  }) 
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",aws_iam_policy.custom_ansible_s3.arn,aws_iam_policy.custom_ansible_ec2.arn]
}

resource "aws_iam_instance_profile" "terraform_ansible_ssm_s3_instance_profile" {
  name = "terraform_ansible_ssm_s3_instance_profile"
  role = aws_iam_role.terraform_ansible_ssm_s3.name
}

## CUSTOM ROLE FOR EVENTBRIDGE TO RUN SSM RUNCOMMAND

resource "aws_iam_policy" "custom_asg_event_policy" {
  name = "custom_asg_event_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Action: ["ssm:SendCommand"]
      Effect: "Allow"
      Resource: ["arn:aws:ec2:ap-south-1:736343449883:instance/*"]
      Condition: {
        "StringEquals": {
            "ec2:ResourceTag/*": ["custom_ansiblecn"]
        }
      }
      },
      {
      Action: ["ssm:SendCommand"]
      Effect: "Allow"
      Resource: ["arn:aws:ssm:ap-south-1:*:document/custom_run_ansible_playbook"]
      },
    ]
  })
}

resource "aws_iam_role" "custom_asg_event_role" {
  name                = "custom_asg_event_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "1"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  }) 
  managed_policy_arns = [aws_iam_policy.custom_asg_event_policy.arn]
}