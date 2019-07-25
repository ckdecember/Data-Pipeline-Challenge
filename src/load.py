"""
Load Postgresql DB from S3 
"""

import datetime
import json
import logging
import os
import sys

from dotenv import load_dotenv
import psycopg2
import psycopg2.sql

__version__ = "0.02"
__author__ = "Carroll Kong"

load_dotenv()

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
        self.restricted_table = "meta_loan_tables"
        return

    def create_table(self):
        """ make initial table """
        table_exists = self.check_if_table_exists(os.environ['LOAN_TABLE'])

        if table_exists and (os.environ['LOAN_TABLE'] != self.restricted_table):
            print ("Table exists - deleting")
            #sys.exit(1)
            self.drop_table(os.environ['LOAN_TABLE'])
            self.remove_from_loan_tables(os.environ['LOAN_TABLE'])

        self.read_sql_from_file('createtable.sql')
        return
    
    def create_meta_loan_table(self):
        """ make initial meta loan tables """
        table_exists = self.check_if_table_exists("meta_loan_tables")

        if not table_exists:
            self.read_sql_from_file('create_meta_loan_tables.sql')
        return

    def create_master_table(self):
        """ make initial master table, or rename first table into master one? """
        self.read_sql_from_file('createmastertable.sql')
        return

    def drop_table(self, table_name):
        """ drop table """
        cursor = self.conn.cursor()
        cursor.execute(
            psycopg2.sql.SQL("DROP TABLE {}").format(psycopg2.sql.Identifier(table_name)))
        self.conn.commit()
        return

    def insert_into_loan_tables(self, table_name):
        """ insert into metatable to keep track of loan tables """
        cursor = self.conn.cursor()
        cursor.execute(
            psycopg2.sql.SQL("""INSERT INTO {} ("table_name", "start_date") VALUES (%s, %s)""")
                .format(psycopg2.sql.Identifier(self.restricted_table)), [table_name, datetime.datetime.now()])
        self.conn.commit()
        return
    
    def remove_from_loan_tables(self, table_name):
        """ remove table from the metatable that lists existing loan tables """
        cursor = self.conn.cursor()
        cursor.execute(
            psycopg2.sql.SQL("DELETE FROM {} WHERE table_name = %s").format(psycopg2.sql.Identifier(self.restricted_table)), [table_name])
        self.conn.commit()
        return
    
    def create_extension(self):
        """ check if extension exists, otherwise create it """
        extension_exists = self.check_if_extension_exists(os.environ['AWS_S3_EXTENSION'])

        if not extension_exists:
            self.read_sql_from_file('aws_pg_extension.sql')
        return

    def check_if_table_exists(self, table_name):
        """ checks if table exists by looking at the postgresql metadata tables """
        cursor = self.conn.cursor()
        cursor.execute("SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_name=%s)", (table_name,)), 
        self.conn.commit()
        return cursor.fetchone()[0]

    def check_if_extension_exists(self, extension):
        """ checks if db extension exists by looking at the postgresql metadata tables """
        cursor = self.conn.cursor()
        cursor.execute("SELECT EXISTS(SELECT * FROM pg_extension WHERE extname = %s)", (extension,))
        self.conn.commit()
        return cursor.fetchone()[0]        

    def create_s3_extensions(self):
        """ to read from s3 to pgsql directly, we need these extensions """
        self.read_sql_from_file('aws_pg_extension.sql')
        return

    def s3_load(self, bucket_name, file_name, region):
        """ import data from S3 - requires extensions """
        cursor = self.conn.cursor()

        table_name = file_name.split(".")[0]

        cursor.execute("""SELECT aws_s3.table_import_from_s3(\
            %s, '', '(format csv)', 
            %s, %s, %s
            );
        """, (table_name, bucket_name, file_name, region))
        
        print ("Loading data ...")
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
    
    def insert_select(self, src_table, dst_table):
        # do an insert select into the master table
        # maybe add a field to determine src table
        cursor = self.conn.cursor()
        sqlquery = """INSERT INTO {} ( "source_table", """.format(dst_table)
        with open('headers.csv') as fh:
            headers = fh.readlines()
        headers = ",".join(headers)
        sqlquery += headers
        sqlquery += " ) SELECT '{}', ".format(src_table)
        sqlquery += headers 
        sqlquery += " FROM {}".format(src_table)

        logger.debug(sqlquery)
        cursor.execute(sqlquery)
        self.conn.commit()
        return

def main():
    print ("S3 Loader {}".format(__version__))
    return

def lambda_handler(event, context):

    print ("S3 Loader {}".format(__version__))

    # ensure filename, ensure uncompressed (or compressed)

    region = event['Records'][0]['awsRegion']
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_name = event['Records'][0]['s3']['object']['key']
    table_name = file_name.split('.')[0]

    s = S3Loader()
    s.create_master_table()
    s.create_table()
    s.create_extension()
    s.create_meta_loan_table()
    s.s3_load(bucket_name, file_name, region)
    s.insert_into_loan_tables(table_name)
    s.insert_select(table_name, "master_loan")
    return

if __name__ == "__main__":
    main()
