# Project 1: Deployment of a Web Application on AWS

##  Overview
This project demonstrates the deployment of a highly available and scalable
 web application on AWS, achieving **99.9% uptime** with DNS failover and load balancing.

### Key Highlights
- **Secure VPC** with 2 public + 2 private subnets across multiple AZs.
- **5+ EC2 instances** with custom AMIs.
- **Auto Scaling + ALB**.
- **Route 53 domain integration** 
- **CloudWatch monitoring**.

## 📂 Project Structure
- `infrastructure/` → Terraform/CloudFormation templates.
- `application/` → Sample web application + Dockerfile.
- `deployment/` → Scripts + CI/CD pipeline definitions.
- `tests/` → Load/stress test configs, monitoring dashboards.
- `docs/` → Reports on availability & scalability.

## ⚡ Deployment Steps
1. Clone repo
   




