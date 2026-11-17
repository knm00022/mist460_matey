from fastapi import HTTPException
from get_db_connection import get_db_connection
from db_errors import db_error_message

def hold_slot(
        reservation_id: int,
        room_availability_id: int
    ):

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute("exec procHoldSlot %s, %s", (reservation_id, room_availability_id))
        conn.commit()
        return {"status_message": "room availability added to reservation successfully."}
    except Exception as e:
        conn.rollback()
        # 400 tells the UI the slot was NOT added (taken, over 2 hours, or double-booked)
        raise HTTPException(status_code=400, detail=db_error_message(e))
    finally:
        cursor.close()
        conn.close()
