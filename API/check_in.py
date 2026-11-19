from fastapi import HTTPException
from get_db_connection import get_db_connection
from db_errors import db_error_message

def check_in(reservation_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute("exec procCheckIn %s", (reservation_id,))
        conn.commit()
        return {"status_message": "Checked in successfully."}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=db_error_message(e))
    finally:
        cursor.close()
        conn.close()
