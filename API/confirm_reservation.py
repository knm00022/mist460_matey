from fastapi import HTTPException
from get_db_connection import get_db_connection

def confirm_reservation(reservation_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute(
            """
            declare @Confirmed int;
            exec procConfirmReservation %s, @Confirmed output;
            select @Confirmed as Confirmed;
            """,
            (reservation_id,),
        )
        row = cursor.fetchone()
        conn.commit()
        confirmed = row["Confirmed"]
        if confirmed:
            status_message = "Reservation confirmed successfully."
        else:
            status_message = (
                "Reservation could not be confirmed. The 10-minute hold has expired "
                "or the reservation is no longer pending."
            )
        return {
            "status_message": status_message,
            "confirmed": confirmed,
        }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error occurred: {e}")
    finally:
        cursor.close()
        conn.close()
