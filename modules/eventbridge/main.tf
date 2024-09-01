# --- eventbridge/main.tf ---

## CUSTOM EVENTBRIDGE EVENT RULE FOR AUTOMATING WEBSERVER CONFIGURATION BY ANSIBLE WHEN LAUNCHED BY ASG

resource "aws_cloudwatch_event_rule" "custom_asg_event" {
  name        = "custom_asg_event"
  description = "capture event fro asg when new ec2 launched"
  event_pattern = jsonencode({
  "source": ["aws.autoscaling"]
  "detail-type": ["EC2 Instance Launch Successful"]
  "detail": {
    "AutoScalingGroupName": ["custom_webserver"]
  }
})

}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_target" "custom_asg_event_target" {
  target_id = "ConfigureWebserver"
  arn       = "arn:aws:ssm:ap-south-1:${data.aws_caller_identity.current.account_id}:document/${var.document_name}"
  rule      = aws_cloudwatch_event_rule.custom_asg_event.name
  role_arn  = var.custom_asg_event_role_arn

  run_command_targets {
    key    = "tag:Service"
    values = ["custom_ansiblecn"]
  }
}