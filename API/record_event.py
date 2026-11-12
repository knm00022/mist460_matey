from get_db_connection import get_db_connection

def record_event(mcu_mac_address: str, event_type: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "exec procRecordEvent %s, %s",
            (mcu_mac_address, event_type)
        )
        conn.commit()
        return {"status": "success", "message": "Event recorded successfully."}
    except Exception as e:
        print(f"Error recording event: {e}")
        return {"status": "error", "message": str(e)}
    finally:
        cursor.close()

        conn.close()