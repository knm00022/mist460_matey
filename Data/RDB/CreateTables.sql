-- drop in FK-dependency order
drop table if exists SensorLog;
drop table if exists SensorNode;
drop table if exists RoomAvailability;
drop table if exists Reservation;
drop table if exists AppUser;
drop table if exists Room;
go

create table Room
(
    RoomID int identity(1,1),
    RoomNumber nvarchar(10) not null,
    Floor int not null,
    Seats int not null,
    Whiteboard bit not null, -- for true or false
    CurrentStatus nvarchar(20) not null default 'Available',
    constraint CK_Room_CurrentStatus check (CurrentStatus in ('Available', 'Occupied', 'On Temporary Hold')),
    constraint PK_Room primary key (RoomID),
    constraint UQ_Room_RoomNumber unique (RoomNumber)
);

go

CREATE TABLE SensorNode (
    SensorNodeID     int identity(1,1),
    SensorName       nvarchar(50),   -- e.g. 'LD2410C'
    SensorMacAddress       nvarchar(17), -- e.g. '00:1A:2B:3C:4D:5E'
    Microcontroller  nvarchar(50),   -- e.g. 'ESP32-S3-WROOM-1'
    MicrocontrollerMacAddress  nvarchar(17), -- e.g. '00:1A:2B:3C:4D:5E'
    DateInstalled     date NOT NULL DEFAULT getdate(),
    DateRemoved       date NULL,
    RoomID     INT,    -- which room this device watches
    constraint PK_SensorNode primary key (SensorNodeID),
    constraint FK_Sensor_Room foreign key (RoomID) references Room(RoomID),
    constraint UQ_SensorMacAddress unique (SensorMacAddress),
    constraint UQ_MicrocontrollerMacAddress unique (MicrocontrollerMacAddress)
);

go

create table SensorLog
(
    SensorLogID int identity(1,1),
    SensorNodeID int not null,
    EventType nvarchar(5) not null, -- e.g. 'Enter', 'Exit'
    EventDateTime datetime2 not null,
    constraint PK_SensorLog primary key (SensorLogID),
    constraint CK_SensorLog_EventType check (EventType in ('Enter', 'Exit')),
    constraint FK_SensorLog_SensorNode foreign key (SensorNodeID) references SensorNode(SensorNodeID)
)

go

create table AppUser
(
    AppUserID int identity(1,1),
    FirstName nvarchar(50) not null,
    LastName nvarchar(50) not null,
    AppUserEmail nvarchar(100) not null unique,
    AppUserPassword nvarchar(200) not null,
    AppUserRole nvarchar(20) not null default 'User', -- 'Admin' or 'User'
    constraint CK_AppUser_Role check (AppUserRole in ('Admin', 'User')),
    constraint PK_AppUser primary key (AppUserID)
);

go

create table Reservation
(
    ReservationID int identity(1,1),
    AppUserID int not null,
    ReservationDateTime datetime2 not null default getdate(), -- when the reservation was made
    CheckInDateTime datetime2 null,
    CheckOutDateTime datetime2 null,
    TotalTimeReserved int NOT NULL DEFAULT 0, -- total reserved time -- as datediff(minute, CheckInDateTime, CheckOutDateTime), -- minutes, computed
    ReservationStatus nvarchar(20) not null default 'Reserved',
    constraint PK_Reservation primary key (ReservationID),
    constraint CK_Reservation_Status check (ReservationStatus in ('Reserved', 'CheckedIn', 'CheckedOut', 'Cancelled')),
    constraint FK_Reservation_AppUser foreign key (AppUserID) references AppUser(AppUserID),
    constraint CK_Reservation_CheckOutAfterCheckIn check (CheckOutDateTime is null or CheckOutDateTime >= CheckInDateTime),
    constraint CK_Reservation_TotalTime check (TotalTimeReserved <= 120) -- maximum 2 hours
);

go

create table RoomAvailability
(
    RoomAvailabilityID int identity(1,1) primary key,
    RoomID int not null,
    AvailableDate date not null,
    StartTime time not null,
    EndTime time not null,
    AvailabilityStatus nvarchar(20) not null default 'Available'
        constraint CK_RoomAvailability_Status check (AvailabilityStatus in ('Available', 'Reserved', 'Held')),
    ReservationID int null, -- null until this 15-min slot is included in a reservation
    constraint FK_RoomAvailability_Room foreign key (RoomID) references Room(RoomID),
    constraint FK_RoomAvailability_Reservation foreign key (ReservationID) references Reservation(ReservationID),
    constraint UQ_RoomAvailability_Slot unique (RoomID, AvailableDate, StartTime),
    constraint CK_RoomAvailability_TimeOrder check (EndTime > StartTime),
    constraint CK_RoomAvailability_15MinSlot check (datediff(minute, StartTime, EndTime) = 15) -- atomic 15-minute increments
);

