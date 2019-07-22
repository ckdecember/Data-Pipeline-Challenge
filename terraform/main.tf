provider "aws" {
    region = "us-west-1"
}

resource "aws_vpc" "vpc-1" {
    cidr_block = "${var.var_vpc-1}"
    enable_dns_hostnames = true
    tags = {
        Name = "DEDO - VPC"
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
    #vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
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
  username             = ""
  password             = ""
  parameter_group_name = "default.postgres11"
  vpc_security_group_ids = ["${aws_security_group.allow_pgsql.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.name}"
  identifier           = "dbx"
  skip_final_snapshot  = true
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
    cidr_blocks = ["${var.MyIP}"] # add your IP address here
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
    cidr_blocks = ["${var.MyIP}"] # add your IP address here
  }

  tags = {
    Name = "allow_pgsql"
  }
}


resource "aws_kms_key" "kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "bulkdatax" {
  bucket = "bulkdatax"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.kms_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
