# BS-DE-DO-CC

Amazon S3 - for storing the files (encrypted)
Amazon RDS - for postgresql 11 (needed for S3 direct copy into RDS)
Amazon KMS - for encryption for S3

Python Packages
psycopg2

Upload data to S3
Run Script
- Check table / create table
- Load from S3 to RDS directly
