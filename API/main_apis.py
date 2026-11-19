from fastapi import FastAPI
from create_room_availability_between_dates import create_room_availability_between_dates
from record_event import record_event
from get_occupancy_status_for_all_rooms import get_occupancy_status_for_all_rooms
from check_room_availability import check_room_availability
from start_reservation import start_reservation
from hold_slot import hold_slot
from confirm_reservation import confirm_reservation
from cancel_reservation import cancel_reservation
from get_user_reservations import get_user_reservations
from get_reservation_details import get_reservation_details
from register_user import register_user
from authenticate_user import authenticate_user
from check_in import check_in
from check_out import check_out
from get_usage_statistics import get_usage_statistics


app = FastAPI()

@app.post("/create_room_availability_between_dates/")
def create_room_availability_between_dates_endpoint(start_date: str, end_date: str):
    return create_room_availability_between_dates(start_date, end_date)

@app.post("/record_event/")
def record_event_endpoint(micro_controller_mac_address: str, event_type: str):
    return record_event(micro_controller_mac_address, event_type)

@app.get("/get_occupancy_status_for_all_rooms/")
def get_occupancy_status_for_all_rooms_endpoint():
    return get_occupancy_status_for_all_rooms()

@app.post("/start_reservation/")
def start_reservation_endpoint(app_user_id: int):
    return start_reservation(app_user_id)

@app.post("/hold_slot/")
def hold_slot_endpoint(reservation_id: int, room_availability_id: int):
    return hold_slot(reservation_id, room_availability_id)

@app.post("/confirm_reservation/")
def confirm_reservation_endpoint(reservation_id: int):
    return confirm_reservation(reservation_id)

@app.post("/cancel_reservation/")
def cancel_reservation_endpoint(reservation_id: int):
    return cancel_reservation(reservation_id)

@app.get("/get_user_reservations/")
def get_user_reservations_endpoint(app_user_id: int):
    return get_user_reservations(app_user_id)

@app.get("/get_reservation_details/")
def get_reservation_details_endpoint(reservation_id: int):
    return get_reservation_details(reservation_id)

@app.post("/register_user/")
def register_user_endpoint(
        first_name: str,
        last_name: str,
        email: str,
        password: str):
    return register_user(first_name, last_name, email, password)

@app.get("/authenticate_user/")
def authenticate_user_endpoint(email: str, password: str):
    return authenticate_user(email, password)

@app.get("/check_room_availability/")
def check_room_availability_endpoint(
        available_date: str | None = None,
        start_time: str | None = None,
        end_time: str | None = None,
        floor: int | None = None,
        seats: int | None = None,
        whiteboard: bool | None = None):
    return check_room_availability(available_date, start_time, end_time, floor, seats, whiteboard)

@app.post("/check_in/")
def check_in_endpoint(reservation_id: int):
    return check_in(reservation_id)

@app.post("/check_out/")
def check_out_endpoint(reservation_id: int):
    return check_out(reservation_id)

@app.get("/get_usage_statistics/")
def get_usage_statistics_endpoint(start_date: str | None = None, end_date: str | None = None):
    return get_usage_statistics(start_date, end_date)
