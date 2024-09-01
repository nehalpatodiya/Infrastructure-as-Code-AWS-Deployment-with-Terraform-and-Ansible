# --- systemsmanager/main.tf ---

## CUSTOM DOCUMENT FOR RUNNING ANSIBLE PLAYBOOK

resource "aws_ssm_document" "custom_document" {
  name            = "custom_run_ansible_playbook"
  document_format = "YAML"
  document_type   = "Command"

  content = <<DOC
schemaVersion: '2.2'
description: run ansible playbook in controller node.
mainSteps:
- action: aws:runShellScript
  name: run_ansible_cn_playbook
  inputs:
    runCommand:
    - 'sudo ansible-playbook /home/ec2-user/data/config_webserver.yml'
    - 'sudo touch /home/ec2-user/data/hi'
DOC
}