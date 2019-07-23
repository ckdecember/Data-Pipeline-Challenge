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

resource "aws_instance" "i-1" {
    instance_type = "t2.micro"
    ami = "ami-068670db424b01e9a"
    subnet_id = "${aws_subnet.subnet-1.id}"
    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
    associate_public_ip_address = true
    key_name = "${var.dev-keyname}"
    tags = {
        Name = "Load Runner"
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
  parameter_group_name = "default.postgres11"
  vpc_security_group_ids = ["${aws_security_group.allow_pgsql.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.name}"
  identifier           = "dbx"
  skip_final_snapshot  = true
  publicly_accessible = true
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = ["${aws_subnet.subnet-1.id}", "${aws_subnet.subnet-1-b.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.MyIP}", "${var.MyIP2}"] # add your IP address here
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_security_group" "allow_pgsql" {
  name        = "allow_pgsql"
  description = "Allow Postgresql inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.MyIP}", "${var.var_subnet-1}", "${var.var_subnet-1-b}"] # add your IP address here
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

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic (outbound)"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_kms_key" "kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
/*
  policy = <<EOF
  {
    "Sid": "Allow use of the key",
    "Effect": "Allow",
    "Principal": {
        "AWS": [
            "arn:aws:iam::823202860115:role/rds-s3-integration-role"
        ]
    },
    "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ],
    "Resource": "*"
    }
  EOF*/
}

resource "aws_s3_bucket" "bulkdatax" {
  bucket = "bulkdatax"

  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.kms_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_db_instance_role_association" "s3import" {
  db_instance_identifier = "${aws_db_instance.postgresq.id}"
  feature_name           = "s3Import"
  role_arn               = "${var.rdss3integrationrole}"
}

/*
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

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
                "arn:aws:s3:::bulkdata1",
                "arn:aws:s3:::bulkdata1/*",
                "arn:aws:s3:::bulkdata2/*",
                "arn:aws:s3:::bulkdata2",
                "arn:aws:s3:::bulkdatax",
                "arn:aws:s3:::bulkdatax/*"
            ]
        }
    ]
}

*/

/*
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
*/

/*resource "aws_iam_policy" "TerraformRDSS3" {
  name        = "TerraformRDSS3"
  path        = "/"
  description = "allows a terraformer to build rds/s3/encryption"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "rds:*",
                "kms:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}*/
