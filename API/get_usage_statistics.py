from get_db_connection import get_db_connection


def get_usage_statistics(start_date: str | None = None, end_date: str | None = None):
    """Reserved slots (planned use) and sensor 'Enter' events (actual use)
    per room, date and hour. The UI turns these into peak-usage charts."""
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)
    try:
        cursor.callproc("procGetReservationUsage", (start_date, end_date))
        reservation_rows = cursor.fetchall()
        cursor.callproc("procGetSensorUsage", (start_date, end_date))
        sensor_rows = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    return {
        "reservations": [
            {
                "AvailableDate": r["AvailableDate"],
                "DayName": r["DayName"],
                "HourOfDay": r["HourOfDay"],
                "RoomID": r["RoomID"],
                "RoomNumber": r["RoomNumber"],
                "TotalSlots": r["TotalSlots"],
                "ReservedSlots": r["ReservedSlots"]
            }
            for r in reservation_rows
        ],
        "sensor": [
            {
                "AvailableDate": r["AvailableDate"],
                "DayName": r["DayName"],
                "HourOfDay": r["HourOfDay"],
                "RoomID": r["RoomID"],
                "RoomNumber": r["RoomNumber"],
                "EnterEvents": r["EnterEvents"]
            }
            for r in sensor_rows
        ]
    }
