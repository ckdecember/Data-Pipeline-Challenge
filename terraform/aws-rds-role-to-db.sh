aws rds add-role-to-db-instance \
--db-instance-identifier dbx \
--role-arn arn:aws:iam::823202860115:role/rds-s3-integration-role \
--feature-name s3Import 
