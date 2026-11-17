from get_db_connection import get_db_connection

def get_occupancy_status_for_all_rooms():
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)
    cursor.callproc("procGetOccupancyStatusForAllRooms")
    rows = cursor.fetchall()
    conn.close()

    #Convert pymssql.Row objects to dicts
    results = [
        {
            "RoomID": row["RoomID"],
            # .get() so the endpoint still works before the updated procedure is deployed
            "RoomNumber": row.get("RoomNumber"),
            "Floor": row.get("Floor"),
            "Seats": row.get("Seats"),
            "Whiteboard": row.get("Whiteboard"),
            "RoomOccupancyStatus": row["RoomOccupancyStatus"]
        }
        for row in rows
    ]
    return {"data": results}