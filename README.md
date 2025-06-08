# Terraform Provisioner Demo

This repository demonstrates how to use Terraform provisioners to automate the deployment and configuration of an application on an AWS EC2 instance.

## What This Demo Does
- Provisions a VPC, subnet, internet gateway, route table, and security group in AWS
- Launches an EC2 instance in the public subnet
- Uses Terraform provisioners to:
  - Copy a local `app.py` file to the EC2 instance
  - Install Python, pip, and Flask
  - Start the Flask application automatically

## How the Provisioner Works

### File Provisioner
Copies the `app.py` file from your local machine to `/home/ubuntu/app.py` on the EC2 instance after it is created.

### Remote-Exec Provisioner
Runs commands on the EC2 instance to:
- Update the package list
- Install Python 3 and pip
- Install Flask
- Start the Flask app in the background

This ensures your application is ready and running as soon as the instance is available.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- AWS CLI configured with credentials
- SSH key pair at `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
- `app.py` file in the project root

## Usage
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
# Confirm with 'yes' when prompted
```

After apply, Terraform will output the public IP of the EC2 instance. You can SSH into it:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<instance_public_ip>
```

The Flask app will be running on port 80.

## Cleanup
To destroy all resources:
```bash
terraform destroy
```

## Notes
- The AMI ID is set for Ubuntu in `us-east-1`. Change it if needed.
- Security group allows SSH and HTTP from anywhere (for demo purposes).

## License
MIT License
