"""
Load Postgresql DB from S3 
"""

import logging
import os
import sys

import psycopg2

__version__ = "0.01"
__author__ = "Carroll Kong"

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

class S3Loader:
    def __init__(self):
        self.conn = psycopg2.connect(host=os.environ['POSTGRES_HOST'], database=os.environ['POSTGRES_DB'], \
            user=os.environ['POSTGRES_USER'], password=os.environ['POSTGRES_PASSWORD'])

    def create_table(self):
        """ make initial tables """
        sqlquery = ''

        with open("createtable.sql", "r") as fh:
            tmpLines = fh.readlines()

        sqlquery = "".join(tmpLines)
        cursor = self.conn.cursor()
        try:
            cursor.execute(sqlquery)
        except psycopg2.errors.DuplicateTable as e:
            print (e)
            sys.exit(1)
            

    def s3_load(self):
        """ import data from S3 """
        cursor = self.conn.cursor()
        sqlquery = """
            SELECT aws_s3.table_import_from_s3(
            'loan', '', '(format csv)',
            'bulkdata1', 'loan.csv', 'us-east-2'
            );
        """
        cursor.execute(sqlquery)
        self.conn.commit()

def main():
    print ("S3 Loader {}".format(__version__))
    s = S3Loader()
    s.create_table()
    s.s3_load()

if __name__ == "__main__":
    main()
