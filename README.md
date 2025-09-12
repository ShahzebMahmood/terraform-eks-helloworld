# Terraform AWS EKS Cluster

This Terraform project deploys a production-ready EKS cluster on AWS.

## Structure

The repository is structured using reusable modules for different components:

- `modules/vpc`: Creates the network infrastructure (VPC, Subnets, NAT Gateway, etc.).
- `modules/iam`: Creates the necessary IAM roles for the EKS cluster and nodes.
- `modules/eks`: Creates the EKS cluster and node groups.

## Prerequisites

- Terraform (v1.3.0 or newer)
- AWS CLI configured with appropriate credentials.

## Usage

1.  **Initialize Terraform:**
    ```sh
    terraform init
    ```

2.  **Plan the deployment:**
    ```sh
    terraform plan
    ```

3.  **Apply the changes:**
    ```sh
    terraform apply
    ```