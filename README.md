# Infrastructure-as-Code-AWS-Deployment-with-Terraform-and-Ansible

This project demonstrates the seamless integration of Terraform and Ansible to automate AWS infrastructure deployment, including VPC setup, EC2 provisioning, and dynamic Apache web server configuration. It showcases the efficiency of event-driven automation with EventBridge and use of an Application Load Balancer for traffic management.

## Project Overview
The project achieves the following objectives with help of Terraform & Ansible:

1. **Provisioning Network Resources**:
   - Terraform code sets up a custom VPC with public and private subnets, an internet gateway, a NAT gateway, and associated route tables.
   - It also configures security groups to manage traffic for load balancers, Ansible control nodes, and web servers, ensuring proper network segmentation and secure access.

2. **Creating IAM Roles**:
   - Defines IAM roles and policies for managing EC2 instances via SSM, enabling an Ansible controller to access S3 and EC2, and allowing EventBridge to trigger SSM RunCommand.
   - It creates roles with specific permissions and associates them with instance profiles or EventBridge for secure and automated management of infrastructure.

3. **Provisioning EventBridge and Systems Manager(SSM)**:
   - Terraform code creates an AWS Systems Manager (SSM) document named custom_run_ansible_playbook that automates running an Ansible playbook on a controller node. The document is configured to execute shell commands that run a specific playbook (config_webserver.yml) on the EC2 instance.
   - Also sets up an EventBridge rule that triggers an SSM RunCommand when an EC2 instance is successfully launched by the Auto Scaling Group for web servers. The rule captures the event and automatically initiates web server configuration using an Ansible playbook, ensuring new instances are properly set up.

4. **Provisioning Compute Resources**:
   - creates AWS Launch Templates and Auto Scaling Groups for an Ansible control node and web servers.
   - The Ansible node is always kept at one instance, while the web servers are set to two instances, with a dependency ensuring the Ansible node is deployed first. The web servers are then attached to a load balancer target group.

5. **Provisioning Loadbalancer**:
   - Terraform code sets up an internet-facing load balancer with a target group and listener.
   - The load balancer distributes traffic across instances in the target group, with dependencies ensuring the web server Auto Scaling Group is in place before the load balancer is created.

## File Structure
   - root/:
     - main.tf: The main Terraform configuration file that sets up the core infrastructure.
     - outputs.tf: Contains output values that can be used to retrieve information about the deployed infrastructure.
     - variables.tf: Defines input variables for customizing the infrastructure setup.
     - ansible_cn_config.sh: A user data script for configuring the Ansible control node.

   - modules/: This directory contains reusable Terraform modules for different components of your infrastructure:
     - compute/:
       - main.tf: Configuration for computing resources like EC2 instances.
       - variables.tf: Input variables specific to compute resources.
       - outputs.tf: Outputs related to compute resources.
     - networking/:
       - main.tf: Configuration for networking components such as VPC, subnets, and security groups.
       - variables.tf: Input variables for networking configurations.
       - outputs.tf: Outputs related to networking.
     - loadbalancing/:
       - main.tf: Configuration for load balancers (likely an ALB or NLB).
       - variables.tf: Input variables for the load balancer setup.
       - outputs.tf: Outputs related to load balancing.
     - eventbridge/:
       - main.tf: Configuration for AWS EventBridge to manage event-driven workflows.
       - variables.tf: Input variables for EventBridge configurations.
     - systemsmanager/:
       - main.tf: Configuration for AWS Systems Manager, which may include automation and patch management.
       - outputs.tf: Outputs related to Systems Manager.
     - roles/:
       - main.tf: Configuration for IAM roles and policies.
       - outputs.tf: Outputs related to IAM roles and access management.
## Getting Started

To use this project, follow these steps:

1. **Prerequisites**:
   - Install Terraform on your control node.
   - Get code by cloning this repository.
   - Configure AWS CLI with access and secret keys having appropriate permissions.

2. **Change Variables**:
   - In root dir change "access_ip" to your IP and ec2_instance_connect_ip to IP range wrt. aws region set in main.tf file
   - In main.tf change local and modules variables accordingly.

3. **Apply Terraform**:
   - Open CMD and get inside root dir of project

   - Initializing
     ```bash
     terraform init
     ```
     - Purpose: Prepares your working directory for use with Terraform by downloading necessary plugins and initializing the backend (where Terraform's state file is stored).
     - What Happens:
       - Downloads the required provider plugins specified in your configuration (provider "aws", provider "azurerm", etc.).
       - Configures the backend, where the Terraform state file is stored (e.g., S3 for AWS, a local file, etc.).
       - Ensures that the working directory is ready for further operations.

   - Generating a Plan
     ```bash
     terraform plan
     ```
     - Purpose: Creates an execution plan, showing you what Terraform will do when you apply the configuration.
     - What Happens:
       - Terraform compares the current state of your infrastructure (from the state file) with the desired state described in your configuration files.
       - It generates an action plan, detailing the changes it will make to your infrastructure, including what resources will be added, modified, or destroyed.
       - No changes are made during this step; it only provides a preview of the potential changes.

   - Applying the Plan
     ```bash
     terraform apply
     ```
     - Purpose: Executes the plan generated by terraform plan, making the specified changes to your infrastructure.
     - What Happens:
       - Terraform applies the changes outlined in the plan to your cloud or on-premises environment.
       - It creates, updates, or destroys resources according to the desired state defined in your configuration files.
       - After applying, Terraform updates the state file to reflect the current state of the infrastructure.
