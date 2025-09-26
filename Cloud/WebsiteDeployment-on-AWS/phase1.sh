#!/bin/bash
## Phase 1: AWS Core Infrastructure Setup using AWS CLI
#
## ---------- Variables ----------
REGION="ap-south-1"
AZ1="ap-south-1a"
AZ2="ap-south-1b"
AMI_ID="ami-0abcdef1234567890"   # Replace with your AMI ID
KEY_NAME="MyKeyPair"
#
## ---------- Step 1: Create VPC ----------
VPC_ID=$(aws ec2 create-vpc   --cidr-block 10.0.0.0/16   --query 'Vpc.VpcId'   --output text --region $REGION)
echo "Created VPC: $VPC_ID"
#
 aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames --region $REGION
#
## ---------- Step 2: Create Subnets ----------
 PUB1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone $AZ1 --query 'Subnet.SubnetId' --output text --region $REGION)
 PUB2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone $AZ2 --query 'Subnet.SubnetId' --output text --region $REGION)
 PRIV1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.101.0/24 --availability-zone $AZ1 --query 'Subnet.SubnetId' --output text --region $REGION)
 PRIV2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.102.0/24 --availability-zone $AZ2 --query 'Subnet.SubnetId' --output text --region $REGION)
#
 echo "Public Subnets: $PUB1, $PUB2"
 echo "Private Subnets: $PRIV1, $PRIV2"
#
## ---------- Step 3: Internet Gateway + Route Tables ----------
 IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text --region $REGION)
 aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region $REGION
#
 PUB_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text --region $REGION)
 aws ec2 create-route --route-table-id $PUB_RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION
 aws ec2 associate-route-table --subnet-id $PUB1 --route-table-id $PUB_RT --region $REGION
 aws ec2 associate-route-table --subnet-id $PUB2 --route-table-id $PUB_RT --region $REGION
#
## ---------- Step 4: NAT Gateway + Private Route Table ----------
 EIP_ALLOC=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text --region $REGION)
 NAT_ID=$(aws ec2 create-nat-gateway --subnet-id $PUB1 --allocation-id $EIP_ALLOC --query 'NatGateway.NatGatewayId' --output text --region $REGION)
#
#aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_ID --region $REGION
#
 PRIV_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text --region $REGION)
 aws ec2 create-route --route-table-id $PRIV_RT --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_ID --region $REGION
 aws ec2 associate-route-table --subnet-id $PRIV1 --route-table-id $PRIV_RT --region $REGION
 aws ec2 associate-route-table --subnet-id $PRIV2 --route-table-id $PRIV_RT --region $REGION
#
## ---------- Step 5: Security Group + EC2 Instances ----------
 SEC_GROUP=$(aws ec2 create-security-group --group-name my-sg --description "App SG" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION)
 aws ec2 authorize-security-group-ingress --group-id $SEC_GROUP --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION
 aws ec2 authorize-security-group-ingress --group-id $SEC_GROUP --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION
#
INSTANCE_ID=$(aws ec2 run-instances   --image-id $AMI_ID   --count 2   --instance-type t3.micro   --key-name $KEY_NAME   --security-group-ids $SEC_GROUP   --subnet-id $PRIV1   --query 'Instances[0].InstanceId'   --output text --region $REGION)
echo "Launched EC2 Instance: $INSTANCE_ID"
#
## ---------- Step 6: Application Load Balancer ----------
ALB_SG=$(aws ec2 create-security-group --group-name alb-sg --description "ALB SG" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION)
aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION
#
TG_ARN=$(aws elbv2 create-target-group --name my-tg --protocol HTTP --port 80 --vpc-id $VPC_ID --query 'TargetGroups[0].TargetGroupArn' --output text --region $REGION)
#
ALB_ARN=$(aws elbv2 create-load-balancer   --name my-alb   --subnets $PUB1 $PUB2   --security-groups $ALB_SG   --query 'LoadBalancers[0].LoadBalancerArn'   --output text --region $REGION)
#
aws elbv2 create-listener --load-balancer-arn $ALB_ARN --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$TG_ARN --region $REGION
aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=$INSTANCE_ID --region $REGION
#
echo "ALB and Target Group configured successfully."
#
