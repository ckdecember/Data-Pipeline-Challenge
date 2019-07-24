# Data Pipeline Challenge

## Problem 
Located here https://www.kaggle.com/wendykan/lending-club-loan-data is loan origination data that we would like to process.

We need an infrastructure built using "infrastructure as code" that has 
+ cloud storage
+ cloud data pipeline / etl environment
+ cloud database engine

Furthermore, we need a production data pipeline that leverages this infrastructure with these key requirements
+ allows data scientists to explore and model data
+ model training and evaluation
+ handles and processes periodic updates in a robust, efficient way

Assume all work will be shared with engineers, data engineers, data scientists, and software engineers in a collaborative environment.

## Solution
We will be utilizing Amazon as our cloud provider and leverage their services.  For the "infrastructure as code" component, we will be using Terraform.  As for processing, we will use lambda functions alongside with S3 storage.  Users will upload the loan files to S3 and Lambda will process them immediately after they are successfully uploaded.
@@@




+ Amazon S3 - for storing the loan files  
+ Amazon RDS - Postgresql 11 (needed for S3 direct copy into RDS)  

### OS Requirements
Ubuntu 18 AMI on Amazon Web Services

### Additional Software Requirements
+ Terraform 0.12+

### Python Packages
psycopg2
python-dotenv

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

+ Run Terraform
```
cd Data-Pipeline-Challenge/terraform/
cp variables.tf.master variables.tf
[edit variables.tf]
```

Fill in the values of variables.tf to match what you desire in your new infrastructure
+ VPC has to be a superset of Subnet 1 and Subnet 2.  Both are needed for RDS. e.g.  10.0.0.0/16 VPC, 10.0.0.0/24 Sub1, 10.0.1.0/24 Sub2
+ DBUser is the DB master username 
+ DBPassword is the DB master password

```
cd ~/Data-Pipeline-Challenge/src
sudo apt-get -y install zip
cp env.master .env
[edit .env - just fill S3_REGION for now]
git clone https://github.com/jkehler/awslambda-psycopg2
cp awslambda-psycopg2/psycopg2-3.6 psycopg2
sudo pip3 install python-dotenv -t ./
./create_lambda_zip.sh
```

## Create initial lambda package
=======
+ DBName is the name of the database

```
terraform init
terraform plan
terraform apply
```

Get some coffee.  This might take some time.

## Application

+ Deploy the Lambda Function

```
cd ~/Data-Pipeline-Challenge/src
cp env.master .env
[edit .env]
git clone https://github.com/jkehler/awslambda-psycopg2
pip3 install python-dotenv -t ./

update_lambda.sh

```

## Getting the Loan Data 
+ Make a Kaggle account
+ Download loan.csv.zip
+ unzip loan.csv.zip
+ Upload to S3

## Run Script
- Check table / create table
- Load from S3 to RDS directly

## Future Data
+ load data to a temporary table
+ use insert 
INSERT into TARGETTABLE ([fields]) SELECT [fields] FROM SRCTABLE
+ trigger off of S3 uploads into a Lambda

## GPG
+ have all members use GPG
+ use GPG to transfer AWS credentials and PGSQL credentials securely

## Automating Kaggle Download
+ with cookies and some credentials, can automate this download
