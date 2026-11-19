from get_db_connection import get_db_connection

def check_room_availability(
        available_date: str | None = None,
        start_time: str | None = None,
        end_time: str | None = None,
        floor: int | None = None,
        seats: int | None = None,
        whiteboard: bool | None = None,
    ):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)
    try:
        cursor.callproc(
            "procCheckRoomAvailability",
            (available_date, start_time, end_time, floor, seats, whiteboard),
        )
        rows = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    #Convert pymssql.Row objects to dicts
    results = [
        {
            "RoomAvailabilityID": row["RoomAvailabilityID"],
            "RoomID": row["RoomID"],
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
