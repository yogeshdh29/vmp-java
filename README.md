# Java SpringBoot with Terraform(AWS)+Docker+AWS+Github Actions(CI/CD)

## Overview
This repository contains the source code and configuration for the Marketplace Platform built with Java SpringBoot Microservices. It includes setup for Docker, Terraform to provision AWS services, and GitHub Actions for Continuous Integration/Continuous Deployment (CI/CD).

## Local Setup with Docker

To run the project locally using Docker, follow these steps:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yogeshdh29/vmp-java.git
   cd vmp-java
2. Build the Docker Image In the root directory of the project, run the following command:
    ```
    docker build -t vmp-java .
    ```
3. Run the Docker Container You can run the container using:
    ```
   docker run -d -p 8080:8080 vmp-java
   ```
4. Docker Compose If you are using docker-compose, follow these steps:
   ```
   docker-compose up --build
   ```
This will build and start the application and any required services as defined in the docker-compose.yml file.

## Terraform Setup for AWS Services
Terraform is used to provision the required AWS services for the project. Follow the steps below to set up the infrastructure:

1. Install Terraform If you don't have Terraform installed, you can install it by following the instructions here: https://www.terraform.io/downloads.


2. Initialize Terraform Navigate to the terraform-ec2-docker directory and initialize Terraform:
    ``` 
    cd terraform-ec2-docker
    terraform init
    ```
3. Apply the Terraform Configuration Apply the configuration to create the necessary AWS resources:
    ```
    terraform apply
    ```
   Follow the prompts to approve the creation of resources.AWS Credentials stored via ```aws cli```. Using ```aws configure list``` ```cat ~/.aws/credentials``` - has AWS access_key + secret_key for terraform to apply ```cat ~/.aws/config```

#### main.tf explained

✅ 1. AWS Provider Configuration
```javascript
provider "aws" {
   region = "us-east-1"
}
```
* This tells Terraform: "Use AWS services in the us-east-1 region.".
* Terraform uses your AWS credentials (from ~/.aws/credentials) to authenticate.

🌐 2. VPC (Virtual Private Cloud)
```javascript
resource "aws_vpc" "main" {
   cidr_block = "10.0.0.0/16"
   enable_dns_support = true
   enable_dns_hostnames = true

   tags = {
      Name = "main-vpc"
   }
}
```
* Creates a private isolated network (CIDR: 10.0.0.0/16) to launch your EC2 and RDS instances.
* enable_dns_support and enable_dns_hostnames are enabled so your instances can resolve domain names.

🌉 3. Internet Gateway
```javascript
resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.main.id
   
   tags = {
      Name = "main-igw"
   }
}
```
* This allows instances in the VPC to access the internet (e.g., install packages, connect to ECR).

🛣️ 4. Route Table
```javascript
resource "aws_route_table" "public_rt" {
   vpc_id = aws_vpc.main.id
   
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
   }
   
   tags = {
      Name = "public-route-table"
   }
}
```
* Creates a route table that sends all outbound traffic to the Internet Gateway.

🔗 5. Route Table Associations
```javascript
resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet_a.id
   route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
   subnet_id      = aws_subnet.subnet_b.id
   route_table_id = aws_route_table.public_rt.id
}
```
* Associates the route table with the two subnets, making them public (internet-accessible).

🧱 6. Subnets
```javascript
resource "aws_subnet" "subnet_a" {
   vpc_id                  = aws_vpc.main.id
   cidr_block              = "10.0.1.0/24"
   availability_zone       = "us-east-1a"
   
   tags = {
      Name = "subnet-a"
   }
}


resource "aws_subnet" "subnet_b" {
   vpc_id                  = aws_vpc.main.id
   cidr_block              = "10.0.2.0/24"
   availability_zone       = "us-east-1b"
   
   tags = {
      Name = "subnet-b"
   }
}
```
* Creates two subnets in different availability zones for high availability.
* Both are part of your VPC and will host EC2 or RDS.

🔒 7. Security Group for EC2
```javascript
resource "aws_security_group" "sg" {
   name        = "allow_http"
   description = "Allow HTTP inbound traffic"
   vpc_id      = aws_vpc.main.id
   
   ingress {
      description = "HTTP"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   
   ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
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
```
* Allows incoming HTTP traffic on port 8080 (your app).

* Allows SSH access on port 22.

* Allows all outbound traffic.

🔐 8. SSH Key Pair
```javascript
resource "aws_key_pair" "deployer" {
   key_name   = "vm-key"
   public_key = file("~/.ssh/id_rsa.pub")
}
```
* This key pair allows you to SSH into the EC2 instance using your local id_rsa key.

🖥️ 9. EC2 Instance to Run Your App
```javascript
resource "aws_instance" "spring_app" {
   ami                    = "ami-0a38b8c18f189761a" # Amazon Linux 2 AMI
   instance_type          = "t2.micro"
   subnet_id              = aws_subnet.subnet_a.id
   vpc_security_group_ids = [aws_security_group.sg.id]
   key_name               = aws_key_pair.deployer.key_name
   
   associate_public_ip_address = true
   
   user_data = <<-EOF
   #!/bin/bash
   yum update -y
   amazon-linux-extras install docker -y
   service docker start
   usermod -a -G docker ec2-user
   docker run -d \
   -p 8080:8080 \
   --name vendor-marketplace \
   --env SPRING_DATASOURCE_URL=jdbc:mysql://${aws_db_instance.spring_db.address}:3306/springdb \
   --env SPRING_DATASOURCE_USERNAME=${aws_db_instance.spring_db.username} \
   --env SPRING_DATASOURCE_PASSWORD=${aws_db_instance.spring_db.password} \
   --env SPRING_JPA_HIBERNATE_DDL_AUTO=update \
   --env SPRING_JPA_SHOW_SQL=true \
   --env SPRING_PROFILES_ACTIVE=aws \
   yogeshdhdocker/github-vm-place-app:latest
   EOF
   
   tags = {
      Name = "SpringApp"
   }
}
```
* Launches a Linux EC2 instance with Docker installed.

* user_data is a startup script:
  * Installs Docker. 
  * Runs your Spring Boot Docker container. 
  * Passes database connection info via environment variables (from RDS).
  

🛢️ 10. RDS Subnet Group
```javascript
resource "aws_db_subnet_group" "main" {
   name       = "main-db-subnet-group"
   subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
   
   tags = {
      Name = "Main DB Subnet Group"
   }
}
```

* RDS needs this to launch instances in multiple subnets for high availability.

🔐 11. Security Group for RDS
```javascript
resource "aws_security_group" "db_sg" {
   name        = "db-security-group"
   description = "Allow MySQL access"
   vpc_id      = aws_vpc.main.id
   
   ingress {
      description = "MySQL from anywhere"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   
   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
   
   tags = {
      Name = "db-security-group"
   }
}
```

* Allows MySQL access on port 3306 from anywhere

🗃️ 12. RDS MySQL Instance
```javascript
resource "aws_db_instance" "spring_db" {
   allocated_storage    = 20
   storage_type         = "gp2"
   engine               = "mysql"
   engine_version       = "8.0"
   instance_class       = "db.t3.micro"
   db_name              = "springdb"
   username             = "root"
   password             = "password123"
   publicly_accessible  = true
   skip_final_snapshot  = true
   db_subnet_group_name = aws_db_subnet_group.main.name
   vpc_security_group_ids = [aws_security_group.db_sg.id]

    depends_on = [
      aws_internet_gateway.igw,
      aws_route_table_association.a,
      aws_route_table_association.b
    ]

    tags = {
      Name = "spring-db"
    }
}
```
* Launches a MySQL 8.0 database instance.

* Terraform injects its connection info into your app via user_data above.

* Marked as publicly_accessible = true (which again, be cautious with in production).

🧠 Final Picture (High Level Diagram)
```declarative
                 +----------------+
                 |    Internet    |
                 +--------+-------+
                          |
               +----------v-----------+
               |  Internet Gateway    |
               +----------+-----------+
                          |
         +------------------------------+
         |       VPC (10.0.0.0/16)      |
         |                              |
+--------v--------+        +-----------v---------+
| Subnet A        |        | Subnet B            |
| - EC2 Instance  |        | - RDS MySQL         |
+-----------------+        +---------------------+
        |                            |
  Security Group               Security Group
  (HTTP + SSH)                 (MySQL 3306)
```

## GitHub Actions for CI/CD
GitHub Actions is used to automate the CI/CD pipeline. The workflows are defined in the .github/workflows directory.

To set up GitHub Actions:
1. Configure Secrets: Ensure the necessary secrets (like AWS credentials) are configured in the GitHub repository settings.

2. Workflows: The repository includes several workflows for testing, building, and deploying the application. These workflows are triggered on events like pushes to the main branch. 
   Example of a typical workflow:

   3. Build and Test Workflow: This workflow runs tests and builds the Docker image when code is pushed to the repository.

    
You can view and edit the workflows in the .github/workflows directory.

### GitHub Actions CI/CD (deploy.yml)
#### Trigger: When you push to the main branch.

#### 🔄 What Happens:

Step  | Action
------------- | -------------
✅ Checkout  | Gets your code into the CI server.
⚙️ Java Setup  | Installs Java 17 (Temurin distribution).
🛠️ Maven Build | Compiles Java code, skips tests for speed..
🔐 AWS Credentials  | Authenticates with AWS using GitHub secrets..
🔑 ECR Login  | Logs into AWS ECR (Elastic Container Registry)..
🐳 Build & Push Docker  | Builds Docker image, tags it as latest, pushes it to ECR..
🔌 SSH to EC2  | Uses SSH to log into EC2 and trigger deployment script..


## 🔁 Bringing It All Together

Step  | Action
------------- | -------------
📁 | You push code to GitHub → 
⚙️ | GitHub Actions runs deploy.yml → 
🐳 | Builds Docker image → 
☁️ | Pushes image to AWS ECR →
🔐 | SSHs into EC2 →
🚀 | Runs deploy.sh →
📦 | Pulls new image and restarts container →
🌐 | Java SpringBoot App live on EC2

## Sample REST Endpoint deployed on AWS 
http://54.86.164.83:8080/api/v1/categories/all