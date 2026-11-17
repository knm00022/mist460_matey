from fastapi import HTTPException
from get_db_connection import get_db_connection

def start_reservation(app_user_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute(
            """
            declare @ReservationID int;
            exec procStartReservation %s, @ReservationID output;
            select @ReservationID as ReservationID;
            """,
            (app_user_id,),
        )
        row = cursor.fetchone()
        conn.commit()
        return {
            "status_message": "Reservation started successfully.",
            "reservation_id": row["ReservationID"],
        }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error occurred: {e}")
    finally:
        cursor.close()
        conn.close()
