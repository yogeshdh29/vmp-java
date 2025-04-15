# Java SpringBoot with Terraform(AWS)+Docker+AWS+Github Actions(CI/CD)

## Overview
This repository contains the source code and configuration for the Vendor Marketplace Platform (VMP) built with Java. It includes setup for Docker, Terraform to provision AWS services, and GitHub Actions for Continuous Integration/Continuous Deployment (CI/CD).

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
   Follow the prompts to approve the creation of resources.

## GitHub Actions for CI/CD
GitHub Actions is used to automate the CI/CD pipeline. The workflows are defined in the .github/workflows directory.

To set up GitHub Actions:
1. Configure Secrets: Ensure the necessary secrets (like AWS credentials) are configured in the GitHub repository settings.

2. Workflows: The repository includes several workflows for testing, building, and deploying the application. These workflows are triggered on events like pushes to the main branch. 
   Example of a typical workflow:

   3. Build and Test Workflow: This workflow runs tests and builds the Docker image when code is pushed to the repository.

    
You can view and edit the workflows in the .github/workflows directory.
