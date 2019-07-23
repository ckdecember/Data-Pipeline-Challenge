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
sudo apt update
sudo apt-get -y install awscli
aws configure
```

For the access/secret keys refer to the ACCESS_KEY and SECRET_ACCESS_KEY in the credentials file from the Amazon Web Services section.


Run terraform to build the AWS network

## Getting the Loan Data 
+ Make a Kaggle account

Upload data to S3

Run Script
- Check table / create table
- Load from S3 to RDS directly
