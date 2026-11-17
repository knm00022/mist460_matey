from fastapi import HTTPException
from get_db_connection import get_db_connection

def authenticate_user(
        email: str,
        password: str
    ):

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.callproc("procAuthenticateUser", (email, password))
        row = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    if row is None:
        raise HTTPException(status_code=401, detail="Invalid email or password.")

    return {
        "status_message": "User authenticated successfully.",
        "data": {
            "AppUserID": row["AppUserID"],
            "FirstName": row["FirstName"],
            "LastName": row["LastName"],
            "AppUserRole": row["AppUserRole"]
        }
    }
