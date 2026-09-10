
go
- AppUser (5 rows)
insert into AppUser (Email, Password) values
('mrm00045@mix.wvu.edu', 'Passw0rd!1'),
('ac00012@mix.wvu.edu', 'Passw0rd!2'),
('lb00098@mix.wvu.edu', 'Passw0rd!3'),
('sturner@mail.wvu.edu', 'Passw0rd!4'),
('nreed@mail.wvu.edu', 'Passw0rd!5');

go

-- Room (5 rows)
insert into Room (RoomNumber, Floor, Seats, Whiteboard, CurrentStatus) values
('101', 1, 4, 1, 'Available'),
('102', 1, 6, 0, 'Available'),
('201', 2, 8, 1, 'In use'),
('202', 2, 4, 0, 'Available'),
('301', 3, 10, 1, 'Available');

go

-- Reservation (10 rows)
insert into Reservation (AppUserID, ReservationDateTime, CheckInDateTime, CheckOutDateTime, TotalTime, ReservationStatus) values
(1, '2026-09-10 10:00', '2026-09-10 10:02', '2026-09-10 10:58', 56, 'Completed'),
(2, '2026-09-10 13:00', null, null, null, 'Confirmed'),
(3, '2026-09-11 09:00', '2026-09-11 09:00', '2026-09-11 09:59', 59, 'Completed'),
(4, '2026-09-11 15:00', null, null, null, 'Cancelled'),
(5, '2026-09-12 11:00', null, null, null, 'Confirmed'),
(1, '2026-09-12 14:00', null, null, null, 'Cancelled'),
(2, '2026-09-13 08:00', '2026-09-13 08:03', '2026-09-13 09:00', 57, 'Completed'),
(3, '2026-09-13 16:00', null, null, null, 'Confirmed'),
(4, '2026-09-14 10:00', null, null, null, 'Confirmed'),
(5, '2026-09-14 12:00', null, null, null, 'Confirmed');

go

-- RoomAvailability (25 rows -- 5 slots per room)
insert into RoomAvailability (RoomID, ReservationID, AvailableDate, AvailableStartTime, AvailableEndTime, AvailabilityStatus) values
(1, 1, '2026-09-10', '10:00', '11:00', 'Booked'),
(1, null, '2026-09-10', '11:00', '12:00', 'Available'),
(1, 6, '2026-09-12', '14:00', '15:00', 'Booked'),
(1, null, '2026-09-13', '09:00', '10:00', 'Available'),
(1, null, '2026-09-14', '13:00', '14:00', 'Available'),
(2, 2, '2026-09-10', '13:00', '14:00', 'Booked'),
(2, 7, '2026-09-13', '08:00', '09:00', 'Booked'),
(2, null, '2026-09-10', '14:00', '15:00', 'Available'),
(2, null, '2026-09-11', '10:00', '11:00', 'Available'),
(2, null, '2026-09-14', '15:00', '16:00', 'Available'),
(3, 3, '2026-09-11', '09:00', '10:00', 'Booked'),
(3, 8, '2026-09-13', '16:00', '17:00', 'Booked'),
(3, null, '2026-09-11', '10:00', '11:00', 'Available'),
(3, null, '2026-09-12', '09:00', '10:00', 'Available'),
(3, null, '2026-09-13', '11:00', '12:00', 'Available'),
(4, 4, '2026-09-11', '15:00', '16:00', 'Booked'),
(4, 9, '2026-09-14', '10:00', '11:00', 'Booked'),
(4, null, '2026-09-10', '09:00', '10:00', 'Available'),
(4, null, '2026-09-12', '13:00', '14:00', 'Available'),
(4, null, '2026-09-13', '14:00', '15:00', 'Available'),
(5, 5, '2026-09-12', '11:00', '12:00', 'Booked'),
(5, 10, '2026-09-14', '12:00', '13:00', 'Booked'),
(5, null, '2026-09-10', '08:00', '09:00', 'Available'),
(5, null, '2026-09-11', '16:00', '17:00', 'Available'),
(5, null, '2026-09-13', '10:00', '11:00', 'Available');


