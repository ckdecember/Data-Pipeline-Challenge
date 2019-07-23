# Data Pipeline Challenge

Amazon S3 - for storing the files (encrypted)  
Amazon RDS - for postgresql 11 (needed for S3 direct copy into RDS)  
Amazon KMS - for encryption for S3  

## OS Requirements
Ubuntu 18

## Python Packages
psycopg2

## Amazon Web Services (AWS)
+ Create an AWS account
+ Go to the IAM Management Console
+ Add a User
  - Select Programmatic Access

AWS EC2 t2.micro
Ubuntu 18


Make a Kaggle account

git clone https://ckdecember.com/Data-Pipeline-Challenge

Run terraform to build the AWS network

Upload data to S3

Run Script
- Check table / create table
- Load from S3 to RDS directly
