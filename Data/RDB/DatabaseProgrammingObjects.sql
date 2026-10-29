if OBJECT_ID('dbo.procRecordEvent', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procRecordEvent;

if OBJECT_ID('dbo.trgUpdateRoomStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trgUpdateRoomStatus;

if OBJECT_ID('dbo.procUpdateRoomStatus', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procUpdateRoomStatus;

if OBJECT_ID('dbo.procCreateRoomAvailabilityForOneDay', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCreateRoomAvailabilityForOneDay;

if OBJECT_ID('dbo.procCreateRoomAvailabilityBetweenDates', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCreateRoomAvailabilityBetweenDates;

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
-- execute procCreateRoomAvailabilityBetweenDates '2026-10-24', '2026-10-31';
-- select * from RoomAvailability;


go

create or alter procedure procRecordEvent
	@MicrocontrollerMacAddress nvarchar(17),
    @EventType nvarchar(5)
as
begin	
	declare @SensorNodeID int;

	select @SensorNodeID = SensorNodeID 
	from SensorNode where MicrocontrollerMacAddress = @MicrocontrollerMacAddress;

	insert into SensorLog (SensorNodeID, EventType, EventDateTime)
	values (@SensorNodeID, @EventType, SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time' );

end;

/*
select * from SensorNode;
select * from SensorLog order by EventDateTime desc;
select * from Room;

execute procRecordEvent '58:E6:C5:69:93:30', 'Enter'; //1

execute procRecordEvent '58:E6:C5:73:31:74', 'Exit'; //2
*/

go

create or alter PROCEDURE procUpdateRoomStatus
	@RoomID int,
	@RoomStatus nvarchar(20)
AS
begin
		update Room
		set CurrentStatus = @RoomStatus
		where RoomID = @RoomID
end;

go

create or alter trigger trgUpdateRoomStatus
on SensorLog
after insert
as
begin

	declare @EventType nvarchar(5), @RoomID int

	select @EventType = I.EventType, @RoomID = S.RoomID
	from Inserted I inner join SensorNode S
		on I.SensorNodeID = S.SensorNodeID;

	-- trigger action
	if (@EventType = 'Enter')
	begin
		execute procUpdateRoomStatus @RoomID, 'Occupied'; -- 'Enter';
	end
	else if (@EventType = 'Exit')
	begin
		execute procUpdateRoomStatus @RoomID, 'Available'; -- 'Exit';
	end
end
go

-- execute procUpdateRoomStatus 1, 'Enter';