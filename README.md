# Data Pipeline Challenge

Amazon S3 - for storing the files (encrypted)  
Amazon RDS - for postgresql 11 (needed for S3 direct copy into RDS)  
Amazon KMS - for encryption for S3  

### OS Requirements
Ubuntu 18 AMI on Amazon Web Services

### Additional Software Requirements
+ Terraform 0.12+

### Python Packages
psycopg2

## Amazon Web Services (AWS)
+ Create an AWS account
+ Go to the IAM Management Console
+ Add a User
  - Select Programmatic Access
  - Next: Permissions
+ Create Group
  - Creators
  - Select Administrator Access for Policy
+ Creators should be selected as your group
  - Next:Tags
+ Feel free to add a tag if you wish
  - Next:Review
+ Download the .csv file in a safe place

These credentials will be needed to build the infrastructure using Terraform.

## Create EC2 Instance if needed
+ AWS EC2 t2.micro
+ Ubuntu 18
+ Must exist in the same subnet as the RDS

## Terraform
+ Download Terraform
```
wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip
sudo apt-get -y install unzip
unzip -d . terraform_0.12.5_linux_amd64.zip
sudo install terraform /usr/local/bin/terraform
rm terraform*
```
If you have any problems downloading this version, try this URL to find a newer package https://www.terraform.io/downloads.html

```
git clone https://github.com/ckdecember/Data-Pipeline-Challenge
```

+ Install AWSCLI
```
sudo apt-get update
sudo apt-get -y install python3-pip
sudo pip3 install awscli
aws configure
```

For the access/secret keys refer to the ACCESS_KEY and SECRET_ACCESS_KEY in the credentials file from the Amazon Web Services section.
For region, use your current Amazon region and 'json' for the output format.

+ Create additional AWS roles and policies
```
cd ~/Data-Pipeline-Challenge/terraform/
./aws-rds-s3-role-create.sh
./aws-rds-s3-policy-create.sh
```

Use the output of policy-create's "ARN" in the next script
```
./aws-rds-s3-role-attach.sh [POLICY-ARN]
```

Create
KMS

Create 
S3 bucket

+ Run Terraform
```
cp variables.tf.master variables.tf
```

Fill in the values of variables.tf to match what you desire in your new infrastructure
+ VPC has to be a superset of Subnet 1 and Subnet 2.  Both are needed for RDS. e.g.  10.0.0.0/16 VPC, 10.0.0.0/24 Sub1, 10.0.1.0/24 Sub2
+ MyIP is your local IP so you can test
+ MyIP2 is another local IP
+ DBUser is the DB master username 
+ DBPassword is the DB master password
+ dev-keyname is the IAM key name in AWS


```
terraform init
terraform plan
terraform apply
```

## Application

+ Install psycopg2
```
sudo pip3 install psycopg2-binary
```

+ Initialize the environment variables

```
cd ~/Data-Pipeline-Challenge/src
cp env.master .env
[edit .env]
source .env

```
Run terraform to build the AWS network

## Getting the Loan Data 
+ Make a Kaggle account
+ Download loan.csv.zip
+ unzip loan.csv.zip
+ Upload to S3

## Run Script
- Check table / create table
- Load from S3 to RDS directly
