provider "aws" {
  region = "us-east-1"
  
}

variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
 
}

resource "aws_key_pair" "example" {
    key_name   = "tf-provisioner-key"
    public_key = file("~/.ssh/id_rsa.pub")
    
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
  
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MySubnet"
  }
  
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "MyRouteTable"
  }
}
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_security_group" "my_security_group" {
  name        = "MySecurityGroup"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere  
    }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere  
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
    }
  tags = {
    Name = "MySecurityGroup"
  }
}
resource "aws_instance" "my_instance" {
  ami           = "ami-084568db4383264d4" # Replace with a valid AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

    connection {
        type        = "ssh"
        user        = "ubuntu" # Adjust based on the AMI
        private_key = file("~/.ssh/id_rsa") # Path to your private key
        host        = self.public_ip
    }

    provisioner "file" {
        source      = "app.py" # Path to your local script
        destination = "/home/ubuntu/app.py" # Path on the instance
        
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y python3", # Install Python if not already installed
            "sudo apt-get install -y python3-pip", # Install pip if not already installed
            "sudo pip3 install flask", # Install Flask or any other dependencies
            "sudo python3 /home/ubuntu/app.py &" # Adjust based on your script
        ]
      
    }
  tags = {
    Name = "MyInstance"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
