if OBJECT_ID('dbo.procRecordEvent', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procRecordEvent;

if OBJECT_ID('dbo.trgUpdateRoomStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trgUpdateRoomStatus; 

if OBJECT_ID('dbo.procUpdateRoomStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procUpdateRoomStatus

GO

CREATE OR ALTER PROCEDURE procRecordEvent
    @SensorID int,
    @EventType nvarchar(5) -- 'Enter' or 'Exit'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO SensorLog (SensorID, EventType, ExitDateTime)
    --VALUES (@SensorID, @EventType, GETDATE() AT TIME ZONE 'Eastern Standard Time');
    values (@SensorID, @EventType, SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time')
END;
GO

/*
select * from SensorLog;
select * from Room;
execute procRecordEvent 1, 'Enter';
*/

GO

create or alter PROCEDURE procUpdateRoomStatus
    @RoomID int, 
    @EventType NVARCHAR(5)
AS
BEGIN
    update Room
    set CurrentStatus = @EventType
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
    execute procUpdateRoomStatus @RoomID, 'Enter';
        --update Room
        --set CurrentStatus = 'Occupied'
       -- where RoomID = @RoomID
    end
    else if (@EventType = 'Exit')
    begin
    execute procUpdateRoomStatus @RoomID, 'Exit';
       -- update Room
        --set CurrentStatus = 'Available'
        --where RoomID = @RoomID
    end

end;

/*
GO

create or alter PROCEDURE procUpdateRoomStatus
    @RoomID int, 
    @EventType NVARCHAR(5)
AS
BEGIN
    update Room
    set CurrentStatus = @EventType
    where RoomID = @RoomID

end;
*/
-- execute procUpdateRoomStatus 1, 'Enter';
