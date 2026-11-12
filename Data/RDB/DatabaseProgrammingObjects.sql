if OBJECT_ID('dbo.procRecordEvent', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procRecordEvent;

if OBJECT_ID('dbo.trgUpdateRoomOccupancyStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trgUpdateRoomOccupancyStatus;

if OBJECT_ID('dbo.procUpdateRoomOccupancyStatus', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procUpdateRoomOccupancyStatus;

if OBJECT_ID('dbo.procGetOccupancyStatusForAllRooms', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procGetOccupancyStatusForAllRooms;

if OBJECT_ID('dbo.procCreateRoomAvailabilityForOneDay', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCreateRoomAvailabilityForOneDay;

if OBJECT_ID('dbo.procCreateRoomAvailabilityBetweenDates', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCreateRoomAvailabilityBetweenDates;

if OBJECT_ID('dbo.procMakeReservation', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procMakeReservation;

if OBJECT_ID('dbo.procAddReservationDetails', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procAddReservationDetails;

if Object_ID('dbo.procGetUserReservations', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procGetUserReservations;

if Object_ID('dbo.procGetReservationDetails', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procGetReservationDetails;

if OBJECT_ID('dbo.procCancelReservation', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCancelReservation;

if OBJECT_ID('dbo.trgUpdateRoomReservationAvailabilityOnCancel', 'TR') IS NOT NULL
	DROP TRIGGER dbo.trgUpdateRoomReservationAvailabilityOnCancel;

if OBJECT_ID('dbo.procCheckIn', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCheckIn;

if OBJECT_ID('dbo.procCheckOut', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCheckOut;

if Object_ID('dbo.procCheckRoomAvailability', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procCheckRoomAvailability;

if Object_ID('dbo.procRegisterUser', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procRegisterUser;

if Object_ID('dbo.procAuthenticateUser', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procAuthenticateUser;

if Object_ID('dbo.procGetReservationUsage', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procGetReservationUsage;

if Object_ID('dbo.procGetSensorUsage', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procGetSensorUsage;

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
            insert into RoomAvailability (RoomID, AvailableDate, StartTime, EndTime, RoomReservationAvailabilityStatus)
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
-- execute procCreateRoomAvailabilityBetweenDates '2026-11-11', '2026-11-14';
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

create or alter PROCEDURE procUpdateRoomOccupancyStatus
	@RoomID int,
	@RoomOccupancyStatus nvarchar(20)
AS
begin
		update Room
		set RoomOccupancyStatus = @RoomOccupancyStatus
		where RoomID = @RoomID
end;

go

create or alter trigger trgUpdateRoomOccupancyStatus
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
		execute procUpdateRoomOccupancyStatus @RoomID, 'Occupied'; -- 'Enter';
	end
	else if (@EventType = 'Exit')
	begin
		execute procUpdateRoomOccupancyStatus @RoomID, 'Vacant'; -- 'Exit';
	end
end

go

-- execute procUpdateRoomOccupancyStatus 1, 'Enter';

create or alter PROCEDURE procGetOccupancyStatusForAllRooms
AS
begin
	select RoomID, RoomOccupancyStatus
	from Room;
end;
-- execute procGetOccupancyStatusForAllRooms;

