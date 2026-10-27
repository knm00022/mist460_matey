if OBJECT_ID('dbo.procRecordEvent', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procRecordEvent;

if OBJECT_ID('dbo.trgUpdateRoomStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trgUpdateRoomStatus; 

if OBJECT_ID('dbo.procUpdateRoomStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procUpdateRoomStatus;

GO

CREATE OR ALTER PROCEDURE procRecordEvent
    @MacAddress nvarchar(17), -- e.g. '00:1A:7D:DA:71:13'
    @EventType nvarchar(5) -- 'Enter' or 'Exit'
AS
BEGIN

    declare @SensorID int;

    select @SensorID = SensorID from Sensor where MacAddress = @MacAddress;

    INSERT INTO SensorLog (SensorID, EventType, EventDateTime)
    --VALUES (@SensorID, @EventType, GETDATE() AT TIME ZONE 'Eastern Standard Time');
    values (@SensorID, @EventType, SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time')
END;
GO

/*
select * from SensorLog where SensorID = 2 order by EventDateTime desc;
select * from Room;
execute procRecordEvent 1, 'Enter';
*/

GO

create or alter PROCEDURE procUpdateRoomStatus
    @RoomID int, 
    @RoomStatus NVARCHAR(20)
AS
BEGIN
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

    declare @EventType nvarchar(5), @RoomID int;
    select @EventType = I.EventType, @RoomID = S.RoomID
    from inserted I inner join Sensor S 
        on I.SensorID = S.SensorID;


    -- trigger action
    if (@EventType = 'Enter')
    begin
    execute procUpdateRoomStatus @RoomID, 'Occupied';
        --update Room
        --set CurrentStatus = 'Occupied'
       -- where RoomID = @RoomID
    end
    else if (@EventType = 'Exit')
    begin
    execute procUpdateRoomStatus @RoomID, 'Available';
       -- update Room
        --set CurrentStatus = 'Available'
        --where RoomID = @RoomID
    end

end;

GO

CREATE OR ALTER PROCEDURE procHoldRoomAvailability
(
    @RoomAvailabilityID INT,
    @AppUserID INT
)
AS
BEGIN
    UPDATE RoomAvailability
    SET AvailabilityStatus = 'Held',
        HoldAppUserID = @AppUserID,
        HoldExpirationDateTime = DATEADD(MINUTE, 10, GETDATE())
    WHERE RoomAvailabilityID = @RoomAvailabilityID
      AND AvailabilityStatus = 'Available';
END;
GO

GO

CREATE OR ALTER PROCEDURE procReleaseExpiredHolds
AS
BEGIN
    UPDATE RoomAvailability
    SET AvailabilityStatus = 'Available',
        HoldAppUserID = NULL,
        HoldExpirationDateTime = NULL
    WHERE AvailabilityStatus = 'Held'
      AND HoldExpirationDateTime <= GETDATE();
END;
GO


/*
GO

create or alter PROCEDURE procUpdateRoomStatus
    @RoomID int, 
    @RoomStatus NVARCHAR(20)
AS
BEGIN
    update Room
    set CurrentStatus = @RoomStatus
    where RoomID = @RoomID

end;
*/
-- execute procUpdateRoomStatus 1, 'Enter';
