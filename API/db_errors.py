def db_error_message(e: Exception) -> str:
    """Pull the readable message out of a pymssql error.

    pymssql errors look like:
        (50004, b"This time slot is no longer available. ... DB-Lib error message ...")
    We keep only the SQL Server message so the UI can show it to the user.
    """
    if len(e.args) >= 2 and isinstance(e.args[1], (bytes, bytearray)):
        message = e.args[1].decode("utf-8", errors="replace")
        return message.split("DB-Lib error message")[0].strip()
    return str(e)
