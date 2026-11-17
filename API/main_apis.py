from fastapi import FastAPI
from record_event import record_event
from check_room_availability import check_room_availability
from start_reservation import start_reservation
from hold_slot import hold_slot
from confirm_reservation import confirm_reservation
from cancel_reservation import cancel_reservation

app = FastAPI()

@app.post("/record_event")
def create_record_event(mcu_mac_address: str, event_type: str):
    return record_event(mcu_mac_address, event_type)

@app.post("/check_room_availability")
def check_room_availability_endpoint(room_id: int, start_time: str, end_time: str):
    return check_room_availability(room_id, start_time, end_time)   

@app.post("/start_reservation")
def start_reservation_endpoint(room_id: int, start_time: str, end_time: str):
    return start_reservation(room_id, start_time, end_time) 

@app.post("/hold_slot") 
def hold_slot_endpoint(room_id: int, start_time: str, end_time: str):
    return hold_slot(room_id, start_time, end_time)

@app.post("/confirm_reservation")
def confirm_reservation_endpoint(reservation_id: int):
    return confirm_reservation(reservation_id)

@app.post("/cancel_reservation")
def cancel_reservation_endpoint(reservation_id: int):
    return cancel_reservation(reservation_id)
