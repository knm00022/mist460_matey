from get_db_connection import get_db_connection

def get_reservation_details(reservation_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)
    cursor.callproc("procGetReservationDetails", (reservation_id,))
    rows = cursor.fetchall()
    conn.close()

    #Convert pymssql.Row objects to dicts
    results = [
        {
            "RoomNumber": row["RoomNumber"],
            "Floor": row["Floor"],
            "Seats": row["Seats"],
            "Whiteboard": row["Whiteboard"],
            "AvailableDate": row["AvailableDate"],
            "StartTime": row["StartTime"],
            "EndTime": row["EndTime"]
        }
        for row in rows
    ]
    return {"data": results}
