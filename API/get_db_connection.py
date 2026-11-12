import os
import pymssql
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    input_server = os.getenv("DB_SERVER")
    input_database = os.getenv("DB_NAME")
    input_user = os.getenv("DB_LOGIN")
    input_password = os.getenv("DB_PASSWORD")
    input_port = os.getenv("DB_PORT", 1433)
    input_tds_version = os.getenv("DB_TDS_VERSION", '7.4')
    return pymssql.connect(server=input_server, user=input_user, password=input_password, database=input_database, port=int(input_port), tds_version=input_tds_version)