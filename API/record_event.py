from get_db_connection import get_db_connection

def record_event(
        micro_controller_mac_address: str,
        event_type: str
    ):

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    try:
        cursor.execute("exec procRecordEvent %s, %s", (micro_controller_mac_address, event_type))
        conn.commit()
        return {"status_message": "Event recorded successfully."}
    except Exception as e:
        conn.rollback()
        return {"status_message": f"Error occurred: {e}"}
    finally:
        cursor.close()
        conn.close()
