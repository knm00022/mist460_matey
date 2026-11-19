from fastapi import HTTPException
from get_db_connection import get_db_connection
from db_errors import db_error_message

def check_out(reservation_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute("exec procCheckOut %s", (reservation_id,))
        conn.commit()
        return {"status_message": "Checked out successfully."}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=db_error_message(e))
    finally:
        cursor.close()
        conn.close()
