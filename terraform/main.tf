provider "aws" {
    region = "us-west-1"
}

resource "aws_vpc" "vpc-1" {
    cidr_block = "${var.var_vpc-1}"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "DEDO - VPC"
    }
}

resource "aws_route" "r" {
  route_table_id = "${aws_vpc.vpc-1.main_route_table_id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet-1" {
    vpc_id = "${aws_vpc.vpc-1.id}"
    cidr_block = "${var.var_subnet-1}"
    availability_zone = "us-west-1a"
    tags = {
        Name = "DEDO - Subnet"
    }
}

resource "aws_subnet" "subnet-1-b" {
    vpc_id = "${aws_vpc.vpc-1.id}"
    cidr_block = "${var.var_subnet-1-b}"
    availability_zone = "us-west-1b"
    tags = {
        Name = "DEDO - Subnet - B"
    }
}

resource "aws_db_instance" "postgresq" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.1"
  instance_class       = "db.t2.micro"
  name                 = "db1"
  username             = "${var.DBUser}"
  password             = "${var.DBPassword}"
  identifier           = "${var.DBName}"

  parameter_group_name = "default.postgres11"
  vpc_security_group_ids = ["${aws_security_group.allow_pgsql.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.name}"
  
  skip_final_snapshot  = true
  publicly_accessible = true
}

output "rds_endpoint" {
  value = "${aws_db_instance.postgresq.endpoint}"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = ["${aws_subnet.subnet-1.id}", "${aws_subnet.subnet-1-b.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "allow_pgsql" {
  name        = "allow_pgsql"
  description = "Allow Postgresql inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_pgsql"
  }
}

resource "aws_s3_bucket" "bucket_1" {

  bucket = "${var.s3_bucket_name}"

  force_destroy = true

}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_rds" {
  name = "iam_for_rds"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy_for_rds"  {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "s3integration",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
EOF
}

// attach
resource "aws_iam_role_policy_attachment" "rds-s3-attach" {
  role       = "${aws_iam_role.iam_for_rds.name}"
  policy_arn = "${aws_iam_policy.policy_for_rds.arn}"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.LoadTest2.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket_1.arn}"
}

resource "aws_lambda_function" "LoadTest2" {
  filename      = "../src/load.zip"
  function_name = "LoadTest2"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "load.lambda_handler"

  runtime = "python3.6"
  timeout = 600
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket_1.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.LoadTest2.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_db_instance_role_association" "db-role-assoc" {
  db_instance_identifier = "${aws_db_instance.postgresq.id}"
  feature_name           = "s3Import"
  role_arn               = "${aws_iam_role.iam_for_rds.id}"
}