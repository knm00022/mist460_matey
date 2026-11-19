from get_db_connection import get_db_connection

def get_user_reservations(app_user_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)
    cursor.callproc("procGetUserReservations", (app_user_id,))
    rows = cursor.fetchall()
    conn.close()

    #Convert pymssql.Row objects to dicts
    results = [
        {
            "ReservationID": row["ReservationID"],
            "ReservationDateTime": row["ReservationDateTime"],
            "TotalTimeReserved": row["TotalTimeReserved"],
            "ReservationStatus": row["ReservationStatus"]
        }
        for row in rows
    ]
    return {"data": results}
