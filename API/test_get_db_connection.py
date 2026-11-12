from get_db_connection import get_db_connection

import os
import pymssql
from dotenv import load_dotenv

load_dotenv()

def test_get_db_connection():

  # Test 1: Check env vars are loaded

  required_vars = ["DB_SERVER", "DB_NAME", "DB_LOGIN", "DB_PASSWORD"]

  missing = [v for v in required_vars if not os.getenv(v)]

  assert not missing, f"Missing env vars: {missing}"

  print("✅ Env vars loaded")



  # Test 2: Connection returns a pyodbc.Connection object

  conn = get_db_connection()
  
  assert isinstance(conn, pymssql.Connection), "Expected a pymssql.Connection"

  print("✅ Connection object returned")

  # Test 3: Connection is usable (run a simple query)

  cursor = conn.cursor()

  cursor.execute("SELECT 1")

  result = cursor.fetchone()

  assert result[0] == 1, "Expected query result of 1"

  print("✅ Connection is live and queryable")

  conn.close()

  print("✅ Connection closed cleanly")

  print("\n🎉 All tests passed!")



if __name__ == "__main__":

  test_get_db_connection()