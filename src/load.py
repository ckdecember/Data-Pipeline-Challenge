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

ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")

ch.setFormatter(formatter)
logger.addHandler(ch)

class S3Loader:
    def __init__(self):
        self.conn = psycopg2.connect(host=os.environ['POSTGRES_HOST'], database=os.environ['POSTGRES_DB'], \
            user=os.environ['POSTGRES_USER'], password=os.environ['POSTGRES_PASSWORD'])
        return

    def create_table(self):
        """ make initial table """

        table_exists = self.check_if_table_exists(os.environ['LOAN_TABLE'])

        if table_exists:
            print ("Table exists - deleting")
            #sys.exit(1)
            self.drop_table(os.environ['LOAN_TABLE'])

        self.read_sql_from_file('createtable.sql')
        return
    
    def drop_table(self, table_name):
        cursor = self.conn.cursor()
        sql_query = "DROP TABLE {}".format(table_name)
        cursor.execute(sql_query)
        self.conn.commit()
    
    def create_extension(self):
        """ check if extension exists, otherwise create it """
        extension_exists = self.check_if_extension_exists(os.environ['AWS_S3_EXTENSION'])

        if not extension_exists:
            self.read_sql_from_file('aws_pg_extension.sql')
        return

    def check_if_table_exists(self, table_name):
        """ checks if table exists by looking at the postgresql metadata tables """
        cursor = self.conn.cursor()
        checkQuery = "SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_name='{}')".format(table_name)
        cursor.execute(checkQuery)
        self.conn.commit()
        return cursor.fetchone()[0]

    def check_if_extension_exists(self, extension):
        """ checks if db extension exists by looking at the postgresql metadata tables """
        cursor = self.conn.cursor()
        checkQuery = "SELECT EXISTS(SELECT * FROM pg_extension WHERE extname = '{}')".format(extension)
        cursor.execute(checkQuery)
        self.conn.commit()
        return cursor.fetchone()[0]        

    def create_s3_extensions(self):
        self.read_sql_from_file('aws_pg_extension.sql')
        return

    def s3_load(self):
        """ import data from S3 - requires extensions """
        cursor = self.conn.cursor()
        sqlquery = """
            SELECT aws_s3.table_import_from_s3(
            '{}', '', '(format csv)',
            '{}', '{}', '{}'
            );
        """.format(os.environ["LOAN_TABLE"], os.environ["S3_BUCKET_NAME"], os.environ["S3_FILENAME"], \
            os.environ["S3_REGION"])

        print ("Loading data ...")
        cursor.execute(sqlquery)
        self.conn.commit()
        return
    
    def read_sql_from_file(self, filename):
        """ Helper function that reads .sql snippets from files and executes them """
        tmpLines = ''
        logger.info("Reading from {}".format(filename))

        with open(filename, 'r') as fh:
            tmpLines = fh.readlines()
        
        sqlquery = "".join(tmpLines)
        cursor = self.conn.cursor()

        try:
            cursor.execute(sqlquery)
        except Exception as e:
            logger.info(e)
            sys.exit(1)
        return

def main():
    print ("S3 Loader {}".format(__version__))
    s = S3Loader()
    s.create_table()
    s.create_extension()
    s.s3_load()
    return

if __name__ == "__main__":
    main()
