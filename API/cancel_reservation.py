from fastapi import HTTPException
from get_db_connection import get_db_connection
from db_errors import db_error_message

def cancel_reservation(reservation_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute(
            "select ReservationID from Reservation where ReservationID = %s",
            (reservation_id,),
        )
        if cursor.fetchone() is None:
            raise HTTPException(status_code=404, detail="Reservation not found.")

        # trgUpdateRoomReservationAvailabilityOnCancel frees the reserved slots
        cursor.execute("exec procCancelReservation %s", (reservation_id,))
        conn.commit()
        return {"status_message": "Reservation cancelled successfully."}
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=db_error_message(e))
    finally:
        cursor.close()
        conn.close()
