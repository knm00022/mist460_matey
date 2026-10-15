insert into Room (RoomNumber, Floor, Seats, Whiteboard) values
('301', 3, 4, 1),
('302', 3, 6, 0),
('401', 4, 4, 1),
('402', 4, 8, 0),
('403', 4, 2, 1),
('501', 5, 4, 1),
('502', 5, 6, 0);

go

insert into Sensor (SensorName, TransmitterName, RoomID) values
('LD2410C', 'ESP32-S3-WRoom-1', 1),
('LD2410C', 'ESP32-S3-WRoom-2', 2),
('LD2410C', 'ESP32-S3-WRoom-3', 3),
('LD2410C', 'ESP32-S3-WRoom-4', 4),
('LD2410C', 'ESP32-S3-WRoom-5', 5),
('LD2410C', 'ESP32-S3-WRoom-6', 6),
('LD2410C', 'ESP32-S3-WRoom-7', 7);

go

insert into AppUser (FirstName, LastName, AppUserEmail, AppUserPassword, AppUserRole) values
('John', 'Doe', 'student1@school.edu', 'hashed_password_1', 'User'),
('Jane', 'Smith', 'student2@school.edu', 'hashed_password_2', 'User'),
('Alice', 'Johnson', 'student3@school.edu', 'hashed_password_3', 'Admin'),
('Charlie', 'Brown', 'student4@school.edu', 'hashed_password_4', 'User');

go
-- Create room availability for the next 7 days
Create or alter PROCEDURE procCreateRoomAvailabilityForNext7Days
AS
BEGIN
declare @numberOfDays int = 0;
declare @CurrentDate date = getdate();
while @numberOFDays < 7
    execute procCreateRoomAvailabilityForOneDay @CurrentDate;
    set @numberOfDays = @numberOfDays + 1;
    set @CurrentDate = dateadd(day, 1, @CurrentDate);
end;


 -- execute procCreateRoomAvailabilityForNext7Days;

go

-- execute procCreateRoomAvailabilityForOneDay = getdate();

create or alter PROCEDURE procCreateRoomAvailabilityForOneDay
    @CurrentDate date

AS
begin 

-- generate 15-minute RoomAvailability slots from 8 AM to 6 PM on 8/28 for every room
declare @AvailableDate date = @CurrentDate; -- today's date, change as needed
declare @SlotStart time;
declare @RoomID int;

declare room_cursor cursor for select RoomID from Room;
open room_cursor;
fetch next from room_cursor into @RoomID;

while @@FETCH_STATUS = 0 -- loop through each room (1, 2, 3, 4)
begin
    set @SlotStart = '08:00:00';
    while @SlotStart < '20:00:00' -- loop through each 15-min time slot from 8 AM to 8PM
    begin
        insert into RoomAvailability (RoomID, AvailableDate, StartTime, EndTime, AvailabilityStatus)
        values (@RoomID, @AvailableDate, @SlotStart, dateadd(minute, 15, @SlotStart), 'Available');

        set @SlotStart = dateadd(minute, 15, @SlotStart);
    end
    fetch next from room_cursor into @RoomID;
end

close room_cursor;
deallocate room_cursor;
end;
go

/*
declare @CurrentDate date = getdate();
execute procCreateRoomAvailabilityForOneDay @CurrentDate;
select * from RoomAvailability
*/













/*
-- sample reservation: AppUser 1 books room 401 (4th floor) on 8/28 from 10:00 to 11:00
declare @NewReservationID int;

insert into Reservation (AppUserID, ReservationDateTime, ReservationStatus)
values (1, getdate(), 'Reserved');

set @NewReservationID = scope_identity();

update RoomAvailability
set AvailabilityStatus = 'Reserved', ReservationID = @NewReservationID
where RoomID = (select RoomID from Room where RoomNumber = '401')
    and AvailableDate = '2026-08-28'
    and StartTime >= '10:00:00'
    and EndTime <= '11:00:00';

update Room
set CurrentStatus = 'In Use'
where RoomNumber = '401';

go
*/