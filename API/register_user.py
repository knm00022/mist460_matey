from fastapi import HTTPException
from get_db_connection import get_db_connection
from db_errors import db_error_message

def register_user(
        first_name: str,
        last_name: str,
        email: str,
        password: str):

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute(
            """
            declare @appUserID int;
            exec procRegisterUser
                @FirstName = %s,
                @LastName = %s,
                @AppUserEmail = %s,
                @AppUserPassword = %s,
                @AppUserID = @appUserID output;
            select @appUserID as appUserID;
            """,
            (first_name, last_name, email, password),
        )
        row = cursor.fetchone()
        conn.commit()
        return {
            "status_message": "User registered successfully.",
            "app_user_id": row["appUserID"]
        }
    except Exception as e:
        conn.rollback()
        message = db_error_message(e)
        if "duplicate" in message.lower() or "unique" in message.lower():
            raise HTTPException(status_code=400, detail="An account with this email already exists.")
        raise HTTPException(status_code=500, detail=f"Error occurred: {message}")
    finally:
        cursor.close()
        conn.close()
