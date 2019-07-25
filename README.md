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

For Part 2, we will rely on temporary tables that are bulk loaded using a special feature of Amazon RDS and S3.  After loading we wil use insert select statements to load the master table.  The source table field will be added to the updates so you know where the data came from.  Data will be kept as is as this is the first phase so no validation is done.

## Amazon Technologies Used
+ Amazon S3 - for storing the loan files  
+ Amazon RDS - Postgresql 11 (needed for S3 direct copy into RDS)  
+ Amazon Lambda - to trigger a function after every S3 Upload

### OS Requirements
+ Ubuntu 18 AMI on Amazon Web Services

### Additional Software Requirements
+ Terraform 0.12+
+ unzip
+ zip

### Python Packages
+ psycopg2
+ python-dotenv

# Instructions
This walkthrough should cover everything you need to build the infrastructure.  While the requirements are listed, the instructions provided will help you install everything required.

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

These credentials will be needed to build the infrastructure using Terraform.  Keep note of this!

## Create EC2 Instance 
This server will execute Terraform to build out the infrastructure.  Build an EC2 Instance with these requirements

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

### Pull down the Data-Pipeline-Challenge

```
git clone https://github.com/ckdecember/Data-Pipeline-Challenge
```

## Install AWSCLI
```
sudo apt-get update
sudo apt-get -y install python3-pip
sudo pip3 install awscli
aws configure
```

For the access/secret keys refer to the ACCESS_KEY and SECRET_ACCESS_KEY in the credentials file from the Amazon Web Services section.
For region, use your current Amazon region and 'json' for the output format.

+ Preparations for Terraform
```
cd Data-Pipeline-Challenge/terraform/
cp variables.tf.master variables.tf
[edit variables.tf]
```

Fill in the values of variables.tf to match what you desire in your new infrastructure
+ VPC has to be a superset of Subnet 1 and Subnet 2.  Both are needed for RDS. e.g.  10.0.0.0/16 VPC, 10.0.0.0/24 Sub1, 10.0.1.0/24 Sub2
+ DBUser is the DB master username 
+ DBPassword is the DB master password
+ DBName is the name of the database

```
cd ~/Data-Pipeline-Challenge/src
sudo apt-get -y install zip
cp env.master .env
[edit .env - just fill S3_REGION for now]
git clone https://github.com/jkehler/awslambda-psycopg2
cp -r awslambda-psycopg2/psycopg2-3.6 psycopg2
sudo pip3 install python-dotenv -t ./
./create_zip.sh
```

# Terraform
```
cd ~/Data-Pipeline-Challenge/terraform/
terraform init
terraform plan
terraform apply
```

Get some coffee.  This might take some time.

## Application

+ Deploy the Lambda Function with proper configuration

```
cd ~/Data-Pipeline-Challenge/src
[edit .env]
update_lambda.sh

```

## Getting the Loan Data 
+ Make a Kaggle account
+ Download loan.csv.zip
+ unzip loan.csv.zip
+ Upload to loan.csv to S3 bucket

# Additional Features if I had more time
## GPG
+ have all members use GPG
+ use GPG to transfer AWS credentials and PGSQL credentials securely
This solves the problem of not allowing credentials over the cloud.

## Automating Kaggle Download
+ with cookies and some credentials, can automate this download

## Dealing with duplicates
The master loan table has the source table field so you can identify the source tables to uniquely identify fields that were in the previous batch.

## No data validation/cleaning
I felt it was more important to get the data inside the system than to worry about data validation.  Secondary tables can be made with purification/cleaning while the orignal master tables can be used as a hard reference point.  I didn't feel it was the job of the data architect to dictate what the data science/engineers needed or wanted -- just to make the data available to them.

## Perhaps better storage facility
There might be a faster storage facility for long term warehousing but I decided to go with what I knew best.  Furthermore, Postgresql can still be used as a temporary storage facility to migrate to other data warehouses to fit the data scientist's needs.  My research seemed to indicate Postgresql is suitable for moderate amounts of analysis.

## Additional Security
Amazon KMS was used to guard the S3 buckets, but I ran into some issues.  The kaggle data is public anyway so I figured this was a reasonable trade off but I'd like to enable it again.  More fine grained controls on IAM policies and SecurityGroups would be nice, but I wanted to press for features over security.

## Modules for Terraform
I would have liked to do this a well but as Terraform tests can take a while, I opted not to do this.

## Cost Analysis of Lambda vs EC2
While Lambda triggering off of S3 events is particular convenient, it is possible the data loader component did not need to be a Lamba.  I'd like to have done a cost analysis to see if a hybrid approach or pure lambda made more economical sense.

## Unit Tests
I would have liked to put some unit tests, but the lambda function was fairly simple.