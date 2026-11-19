from fastapi import HTTPException
from get_db_connection import get_db_connection
from db_errors import db_error_message

def create_room_availability_between_dates(
        start_date: str,
        end_date: str
    ):

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute("exec procCreateRoomAvailabilityBetweenDates %s, %s", (start_date, end_date))
        conn.commit()
        return {"status_message": "Room availability created successfully."}
    except Exception as e:
        conn.rollback()
        message = db_error_message(e)
        if "UQ_RoomAvailability_Slot" in message:
            message = "Availability already exists for one or more of these dates. Nothing was created."
        raise HTTPException(status_code=400, detail=message)
    finally:
        cursor.close()
        conn.close()
