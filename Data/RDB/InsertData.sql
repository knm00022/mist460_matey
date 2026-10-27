insert into Room (RoomNumber, Floor, Seats, Whiteboard) values
('REH 4213', 4, 4, 1),
('REH 4225', 4, 6, 0),
('REH 5213', 5, 4, 1),
('REH 5225', 5, 6, 0);

go

insert into Sensor (SensorName, TransmitterName, RoomID) values
('LD2410C', 'ESP32-S3-WROOM-1', 1),
('LD2410C', 'ESP32-S3-WROOM-1', 2),
('LD2410C', 'ESP32-S3-WROOM-1', 3),
('LD2410C', 'ESP32-S3-WROOM-1', 4);


go


insert into AppUser (FirstName, LastName, AppUserEmail, AppUserPassword, AppUserRole) values
('Alice', 'Smith', 'alice.smith@school.edu', 'hashed_password_1', 'Admin'),
('Bob', 'Johnson', 'bob.johnson@school.edu', 'hashed_password_2', 'User'),
('Charlie', 'Brown', 'charlie.brown@school.edu', 'hashed_password_3', 'User'),
('David', 'Williams', 'david.williams@school.edu', 'hashed_password_4', 'User');


go


create or alter PROCEDURE procCreateRoomAvailabilityForOneDay
    @CurrentDate date
as
begin
-- generate 15-minute RoomAvailability slots from 8 AM to 8 PM on current date for every room
    declare @AvailableDate date = @CurrentDate;
    declare @SlotStart time;
    declare @RoomID int;
    declare @NumberOfRooms int, @Counter int;
    set @NumberOfRooms = (select count(*) from Room);
    set @RoomID = 1;
    set @Counter = 0;

    while @Counter < @NumberOfRooms -- loop through each room (1, 2, 3, 4 )
    begin
        set @SlotStart = '08:00:00';
        while @SlotStart < '20:00:00' -- loop through each 15-minute slot (8:00, 8:15, 8:30, ..., 19:45)
        begin
            insert into RoomAvailability (RoomID, AvailableDate, StartTime, EndTime, AvailabilityStatus)
            values (@RoomID, @AvailableDate, @SlotStart, dateadd(minute, 15, @SlotStart), 'Available');

            set @SlotStart = dateadd(minute, 15, @SlotStart);
        end
        set @RoomID = @RoomID + 1;
        set @Counter = @Counter + 1;
    end

end;

/*
declare @currentDate date = getdate();
print @currentDate;
execute procCreateRoomAvailabilityForOneDay @currentDate;
select * from RoomAvailability;
*/

go

-- Create room availability for the next 7 days
create or alter PROCEDURE procCreateRoomAvailabilityForNext7Days
AS
begin
    declare @numberOfDays int = 0;
    declare @currentDate date = getdate(); -- dateadd(day, 1, getdate()); -- start from tomorrow
    while @numberOfDays < 7
    begin
        execute procCreateRoomAvailabilityForOneDay @currentDate;
        set @numberOfDays = @numberOfDays + 1;
        set @currentDate = dateadd(day, 1, @currentDate);
    end
end
-- execute procCreateRoomAvailabilityForNext7Days;
-- select * from RoomAvailability;


go


-- Create room availability for between the specified start and end dates
-- create or alter PROCEDURE procCreateRoomAvailabilityBetweenDates

create or alter PROCEDURE procCreateRoomAvailabilityBetweenDates
    @StartDate date,
    @EndDate date
AS
begin
    declare @numberOfDays int, @counter int;
    set @numberOfDays = datediff(day, @StartDate, @EndDate) + 1; -- include end date
    declare @currentDate date; 
    set @currentDate = @StartDate;
    set @counter = 0; 
    while @counter < @numberOfDays
    begin
        execute procCreateRoomAvailabilityForOneDay @currentDate;
        set @counter = @counter + 1;
        set @currentDate = dateadd(day, 1, @currentDate);
    end
end

-- execute procCreateRoomAvailabilityBetweenDates '2026-10-19', '2026-10-22';
-- select * from RoomAvailability;














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