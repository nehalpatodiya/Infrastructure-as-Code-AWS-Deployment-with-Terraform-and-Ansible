#! /bin/bash
yum install ansible python3-pip -y
pip3 install boto3
cd /etc/ansible/

cat <<EOF >ansible.cfg
[defaults]
inventory = my_inventory
host_key_checking = false
private_key_file = /home/ec2-user/key/K8.pem
remote_user = ec2-user
roles_path = /home/ec2-user/roles
[inventory]
enable_plugins = aws_ec2
EOF

mkdir my_inventory
cd my_inventory

cat <<EOF >aws_ec2.yml
---
plugin: aws_ec2
regions:
  - ap-south-1

filters:
  tag:Service:
    - custom_webserver

  instance-state-name: 
    - running

hostnames:
  - name: 'private-ip-address'

keyed_groups:
  - prefix: tag
    key: tags
EOF

cd /home/ec2-user/
mkdir key
mkdir data
aws s3 sync s3://custom-data-store/data /home/ec2-user/data
aws s3 sync s3://custom-data-store/key /home/ec2-user/key
cd key
chmod 400 K8.pem
date > date.txt
instance_id=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 create-tags --resources "$instance_id" --tags 'Key=user-data-complete,Value=true'