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

if OBJECT_ID('dbo.procStartReservation', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procStartReservation;

if object_id('dbo.procReleaseExpiredHolds', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procReleaseExpiredHolds;

if object_id('dbo.procHoldSlot', 'P') IS NOT NULL
	DROP PROCEDURE dbo.procHoldSlot;

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
-- execute procCreateRoomAvailabilityBetweenDates '2026-11-17', '2026-11-24';
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

execute procRecordEvent '58:E6:C5:69:93:30', 'Exit'; --1

execute procRecordEvent '58:E6:C5:73:31:74', 'Enter'; --2
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
	select RoomID, RoomNumber, Floor, Seats, Whiteboard, RoomOccupancyStatus
	from Room
	order by Floor, RoomNumber;
end;
-- execute procGetOccupancyStatusForAllRooms;


go

create or alter procedure procStartReservation
(
	@AppUserID int,
	@ReservationID int output
)
as
begin
	insert into Reservation (AppUserID, ReservationDateTime, ReservationStatus)
		values (@AppUserID, SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time', 'Pending');

	set @ReservationID = SCOPE_IDENTITY();
end;

/*
declare @ReservationID int;
execute procStartReservation 1, @ReservationID output;
print @ReservationID;
select * from Reservation;
*/

go

create or alter procedure procReleaseExpiredHolds
as
begin
    -- free slots whose pending reservation is older than 10 minutes
    update RoomAvailability
    set RoomAvailability.RoomReservationAvailabilityStatus = 'Available', ReservationID = null
    from RoomAvailability RA inner join Reservation R
    on ra.ReservationID = r.ReservationID
    where r.ReservationStatus = 'Pending'
      and r.ReservationDateTime < dateadd(minute, -10, cast(SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time' as datetime2));

    -- then cancel those abandoned reservations (must run after the slot update above)
    update Reservation
    set ReservationStatus = 'Cancelled'
    where ReservationStatus = 'Pending'
      and ReservationDateTime < dateadd(minute, -10, cast(SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time' as datetime2));

end;

/*
select * from RoomAvailability where RoomReservationAvailabilityStatus = 'OnHold';
select * from Reservation where ReservationStatus = 'Pending';
execute procReleaseExpiredHolds;
*/

go


create or alter procedure procHoldSlot
(
	@ReservationID int,
	@RoomAvailabilityID int
)
as
begin
	-- xact_abort on: any error automatically rolls back the entire transaction,
	-- and the error message is passed back to the API (and shown in the UI).
	set nocount on;
	set xact_abort on;

	-- Requirement 5: free slots whose 10-minute hold has expired, so they can be held again
	exec procReleaseExpiredHolds;

	begin transaction;

		declare @AppUserID int, @TotalTimeReserved int, @ReservationStatus nvarchar(20);
		select @AppUserID = AppUserID,
			@TotalTimeReserved = TotalTimeReserved,
			@ReservationStatus = ReservationStatus
		from Reservation with (updlock)
		where ReservationID = @ReservationID;

		if @AppUserID is null
			throw 50001, 'Reservation not found.', 1;

		if @ReservationStatus <> 'Pending'
			throw 50002, 'Time slots can only be added to a reservation that is still in process of being made.', 1;

		declare @RoomReservationAvailabilityStatus nvarchar(20), @AvailableDate date, @StartTime time;
		select @RoomReservationAvailabilityStatus = RoomReservationAvailabilityStatus,
			@AvailableDate = AvailableDate,
			@StartTime = StartTime
		from RoomAvailability with (updlock, holdlock) -- lock the row to prevent another transaction
		-- from ADDING the same slot to a different reservation at the same time
		where RoomAvailabilityID = @RoomAvailabilityID;

		if @RoomReservationAvailabilityStatus is null
			throw 50003, 'Room availability slot not found.', 1;

		if @RoomReservationAvailabilityStatus <> 'Available'
			throw 50004, 'This time slot is no longer available. Please search again.', 1;

		-- Requirement 2: a reservation can be at most 2 hours (8 x 15-minute slots)
		if @TotalTimeReserved + 15 > 120
			throw 50005, 'A reservation cannot be longer than 2 hours (8 time slots).', 1;

		-- Requirement 3: a user cannot hold two rooms at the same time
		if exists (
			select 1
			from RoomAvailability RA join Reservation R on RA.ReservationID = R.ReservationID
			where R.AppUserID = @AppUserID
				and R.ReservationStatus in ('Reserved', 'Pending')
				and RA.AvailableDate = @AvailableDate
				and RA.StartTime = @StartTime
		)
			throw 50006, 'You already have a room reserved at this time.', 1;

		update RoomAvailability
		set ReservationID = @ReservationID,
			RoomReservationAvailabilityStatus = 'OnHold'
		where RoomAvailabilityID = @RoomAvailabilityID;

		if @@error <> 0
		begin
			rollback transaction;
			return;
		end

		update Reservation
		set TotalTimeReserved = TotalTimeReserved + 15
		where ReservationID = @ReservationID;

		if @@error <> 0
		begin
			rollback transaction;
			return;
		end

	commit transaction;
end;
/*
	execute procHoldSlot 1, 1;
	select * from RoomAvailability;
	select * from Reservation;
*/

go

create or alter procedure procConfirmReservation
    @ReservationID int,
    @Confirmed int output  -- 1 = confirmed, 0 = expired or not pending
as
begin
    exec procReleaseExpiredHolds;  -- an expired hold can't be confirmed

    update RoomAvailability
    set RoomReservationAvailabilityStatus = 'Reserved'
    where ReservationID = @ReservationID
      and RoomReservationAvailabilityStatus = 'OnHold';

    update Reservation
    set ReservationStatus = 'Reserved',
        TotalTimeReserved = (select count(*) * 15 
                            from RoomAvailability 
                            where ReservationID = @ReservationID)
    where ReservationID = @ReservationID
      and ReservationStatus = 'Pending';

    set @Confirmed = @@ROWCOUNT;  -- 1 = confirmed, 0 = expired or not pending

end;

go


create or alter procedure procGetUserReservations
(
	@AppUserID int
)
as
begin
	select ReservationID, ReservationDateTime, TotalTimeReserved, ReservationStatus
	from Reservation
	where AppUserID = @AppUserID;
end;

go

-- execute procGetUserReservations 1;

create or alter procedure procGetReservationDetails
(
	@ReservationID int
)
as
begin
	select RM.RoomNumber, RM.Floor, RM.Seats, RM.Whiteboard, 
		RA.AvailableDate, RA.StartTime, RA.EndTime
	from RoomAvailability RA join Room RM 
		on RA.RoomID = RM.RoomID
	where RA.ReservationID = @ReservationID;
end;

go

create or alter procedure procCancelReservation
(
	@ReservationID int
)
as
begin
	update Reservation
	set ReservationStatus = 'Cancelled'
	where ReservationID = @ReservationID;
end;

go

create or alter trigger trgUpdateRoomReservationAvailabilityOnCancel
on Reservation
after update
as
begin
	declare @ReservationID int, @ReservationStatus nvarchar(20);

	select @ReservationID = I.ReservationID,
		@ReservationStatus = I.ReservationStatus
	from Inserted I;

	if @ReservationStatus = 'Cancelled'
	begin
		update RoomAvailability
		set ReservationID = null,
			RoomReservationAvailabilityStatus = 'Available'
		where ReservationID = @ReservationID;
	end
end;

go

create or alter procedure procCheckIn
(
	@ReservationID int
)
as
begin
	update Reservation
	set CheckInDateTime = SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time',
		ReservationStatus = 'CheckedIn'
	where ReservationID = @ReservationID;
end;

go

create or alter procedure procCheckOut
(
	@ReservationID int
)
as
begin
	update Reservation
	set CheckOutDateTime = SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time',
		ReservationStatus = 'CheckedOut'
	where ReservationID = @ReservationID;
end;

go

create or alter procedure procCheckRoomAvailability
(
	@AvailableDate date = null,
	@StartTime time = null,
	@EndTime time = null,
	@Floor int = null,
	@Seats int = null,
	@Whiteboard bit = null
)
as
begin
	select RA.RoomAvailabilityID, RA.RoomID, R.RoomNumber, R.Floor, R.Seats, R.Whiteboard, 
		RA.AvailableDate, RA.StartTime, RA.EndTime
	from RoomAvailability RA join Room R on RA.RoomID = R.RoomID
	where RA.RoomReservationAvailabilityStatus = 'Available'
		and AvailableDate = IsNull(@AvailableDate, RA.AvailableDate)
		and StartTime >= IsNull(@StartTime, RA.StartTime)
		and EndTime <= IsNull(@EndTime, RA.EndTime)
		--and (@EndTime is null or RA.EndTime <= @EndTime)
		and (@Floor is null or R.Floor = @Floor)
		and (@Seats is null or R.Seats >= @Seats)
		and (@Whiteboard is null or R.Whiteboard = @Whiteboard);
end;
/*
execute procCheckRoomAvailability 
@AvailableDate = '2026-10-19', @StartTime = '10:00:00', @EndTime = '11:00:00', @Floor = 4, @Seats = 4, @Whiteboard = 1;

select * from RoomAvailability where RoomReservationAvailabilityStatus = 'Reserved';
*/

go

create or alter procedure procRegisterUser
(
	@FirstName nvarchar(50),
	@LastName nvarchar(50),
	@AppUserEmail nvarchar(100),
	@AppUserPassword nvarchar(200),
	@AppUserRole nvarchar(20) = 'User',
	@AppUserID int output
)
as
begin
	insert into AppUser (FirstName, LastName, AppUserEmail, AppUserPassword, AppUserRole)
	values (@FirstName, @LastName, @AppUserEmail, @AppUserPassword, @AppUserRole);
	set @AppUserID = SCOPE_IDENTITY();
end;
go

create or alter procedure procAuthenticateUser
(
	@AppUserEmail nvarchar(100),
	@AppUserPassword nvarchar(200)
)
as
begin
	select AppUserID, FirstName, LastName, AppUserRole
	from AppUser
	where AppUserEmail = @AppUserEmail and AppUserPassword = @AppUserPassword;
end;
go

-- =====================================================================
-- Usage analysis for admins (requirement 10)
-- =====================================================================

-- Reserved vs. total 15-minute slots, per room, date and hour of day.
-- The UI aggregates these rows into a day x hour heatmap and per-room totals.
create or alter procedure procGetReservationUsage
(
	@StartDate date = null,
	@EndDate date = null
)
as
begin
	set nocount on;

	select RA.AvailableDate,
		datename(weekday, RA.AvailableDate) as DayName,
		datepart(hour, RA.StartTime) as HourOfDay,
		R.RoomID,
		R.RoomNumber,
		count(*) as TotalSlots,
		sum(case when RA.RoomReservationAvailabilityStatus = 'Reserved' then 1 else 0 end) as ReservedSlots
	from RoomAvailability RA join Room R on RA.RoomID = R.RoomID
	where (@StartDate is null or RA.AvailableDate >= @StartDate)
		and (@EndDate is null or RA.AvailableDate <= @EndDate)
	group by RA.AvailableDate, datepart(hour, RA.StartTime), R.RoomID, R.RoomNumber
	order by RA.AvailableDate, HourOfDay, R.RoomNumber;
end;
-- execute procGetReservationUsage '2026-11-10', '2026-11-12';

go

-- Actual (sensor-detected) room entries, per room, date and hour of day.
create or alter procedure procGetSensorUsage
(
	@StartDate date = null,
	@EndDate date = null
)
as
begin
	set nocount on;

	select E.EventDate as AvailableDate,
		datename(weekday, E.EventDate) as DayName,
		E.HourOfDay,
		E.RoomID,
		R.RoomNumber,
		count(*) as EnterEvents
	from (
		select cast(SL.EventDateTime as date) as EventDate,
			datepart(hour, SL.EventDateTime) as HourOfDay,
			SN.RoomID
		from SensorLog SL join SensorNode SN on SL.SensorNodeID = SN.SensorNodeID
		where SL.EventType = 'Enter'
	) E join Room R on E.RoomID = R.RoomID
	where (@StartDate is null or E.EventDate >= @StartDate)
		and (@EndDate is null or E.EventDate <= @EndDate)
	group by E.EventDate, E.HourOfDay, E.RoomID, R.RoomNumber
	order by E.EventDate, E.HourOfDay, R.RoomNumber;
end;
-- execute procGetSensorUsage;
