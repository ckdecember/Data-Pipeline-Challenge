#!/bin/bash
. .env
zip -r load.zip .env *.sql load.py psycopg2 python_dotenv-0.10.3.dist-info dotenv
aws lambda update-function-code --region $S3_REGION --function-name "LoadTest2" --zip-file "fileb://load.zip"
