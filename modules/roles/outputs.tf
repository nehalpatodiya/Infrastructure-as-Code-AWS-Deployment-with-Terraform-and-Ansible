output "terraform_webserver_ssm_instance_profile" {
  value = aws_iam_instance_profile.terraform_webserver_ssm_instance_profile.id
}

output "terraform_ansible_ssm_s3_instance_profile" {
  value = aws_iam_instance_profile.terraform_ansible_ssm_s3_instance_profile.id
}

output "custom_asg_event_role_arn" {
  value = aws_iam_role.custom_asg_event_role.arn
}




