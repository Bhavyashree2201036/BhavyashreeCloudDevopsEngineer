# Project Title
EC2 launching through Linux Shell scripting

## Table of Contents
 [About](#about )
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

##About      
 1.To Launch EC2 instance based on user provided parameters .
 2.To create temprorary test servers to deploy the QA testers build and run integration tests. 
 3.Termination of EC2 instance after completion of  testing cycle 
 4.It works in this way :
        Linux Server → AWS CLI/SDK → HTTPS call → AWS EC2 Regional Endpoint → AWS validates IAM → Control Plane provisions EC2 → Instance boots 
        → You connect (SSH/RDP).
 Indepth internal code execution details -->
    Bash script (orchestrator)
        |
        | calls
        v
    AWS CLI (executor)
        |
        | sends API request (API (Application Programming Interface) is essentially a set of rules and protocols that allows 
        |  one software application to communicate with another
        v
    AWS Service (EC2, S3, etc.)
        |
        | response
        v
    AWS CLI outputs data
        |
        v
    Bash captures output, decides next steps

##Features
 1 Launches an EC2 instance with a predefined AMI, instance type, key pair, and security group.
 2 Tags the instance with a project or user ID (e.g., Project=QA-Test).
 3 Waits until the instance is running, then prints the public IP for SSH access.
 4 Optionally, sets a TTL (time-to-live) and terminates the instance automatically after X hours to save costs.
- Usage

- Project Structure
 .
  ├── Readme.md
  ├── docs
  │   ├── screenshot.md
  │   └── use-case.md
  ├── scripts
  │   └── verify_connectivity.sh
  └── terraform
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    └── variables.tf
 










