-- drop in FK-dependency order
drop table if exists SensorLog;
drop table if exists Sensor;
drop table if exists RoomAvailability;
drop table if exists Reservation;
drop table if exists AppUser;
drop table if exists Room;

/*
go

create table Room
(
    RoomID int identity(1,1) primary key,
    RoomNumber varchar(10) not null unique,
    Floor int not null,
    Seats int not null,
    Whiteboard bit not null, -- for true or false
    CurrentStatus varchar(20) not null default 'Available'
    constraint CK_Room_CurrentStatus check (CurrentStatus in ('Available', 'Occupied')),
    contraint PK_Room primary key (RoomID),
    contraint UQ_Room_RoomNumber unique (RoomNumber)
);

create table Sensor
(
    SensorID int identity(1,1),
    SensorName varchar(50) not null,
    TransmitterName varchar(50) not null,
    DateInstalled datetime not null default getdate(),
    DateRemoved datetime null,
    RoomID int not null,
    constraint PK_Sensor primary key (SensorID),
    constraint FK_Sensor_Room foreign key (RoomID) references Room(RoomID)
)

go

create table SensorLog
(
    SensorLogID int identity(1,1),
    SensorID int not null,
    EventType nvarchar(5) not null,
    ExitDateTime datetime2 not null,
    constraint PK_SensorLog primary key (SensorLogID),
    constraint CK_SensorLog_EventType check (EventType in ('Enter', 'Exit')),
    constraint FK_SensorLog_Sensor foreign key (SensorID) references Sensor(SensorID)
)

go

create table AppUser
(
    AppUserID int identity(1,1) primary key,
    FirstName nvarchar(50) not null,
    LastName nvarchar(50) not null,
    AppUserEmail nvarchar(100) not null unique,
    AppUserPassword nvarchar(200) not null -- store a hash, never plain text
    AppUserRole nvarchar(20) not null default 'User', -- 'User' or 'Admin'
    constraint CK_AppUser_Role check (AppUserRole in ('User', 'Admin')),
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
    TotalTime as datediff(minute, CheckInDateTime, CheckOutDateTime), -- minutes, computed
    ReservationStatus nvarchar(20) not null default 'Reserved'
    constraint PK_Reservation primary key (ReservationID),
    constraint CK_Reservation_Status check (ReservationStatus in ('Reserved', 'CheckedIn', 'CheckedOut', 'Cancelled')),
    constraint FK_Reservation_AppUser foreign key (AppUserID) references AppUser(AppUserID),
    constraint CK_Reservation_CheckOutAfterCheckIn check (CheckOutDateTime is null or CheckOutDateTime >= CheckInDateTime)
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
        constraint CK_RoomAvailability_Status check (AvailabilityStatus in ('Available', 'Reserved')),
    ReservationID int null, -- null until this 15-min slot is included in a reservation
    constraint FK_RoomAvailability_Room foreign key (RoomID) references Room(RoomID),
    constraint FK_RoomAvailability_Reservation foreign key (ReservationID) references Reservation(ReservationID),
    constraint UQ_RoomAvailability_Slot unique (RoomID, AvailableDate, StartTime),
    constraint CK_RoomAvailability_TimeOrder check (EndTime > StartTime),
    constraint CK_RoomAvailability_15MinSlot check (datediff(minute, StartTime, EndTime) = 15) -- atomic 15-minute increments
);
*/



GO

CREATE TABLE Room
(
    RoomID int IDENTITY(1,1) NOT NULL,
    RoomNumber varchar(10) NOT NULL,
    Floor int NOT NULL,
    Seats int NOT NULL,
    Whiteboard bit NOT NULL,
    CurrentStatus varchar(20) NOT NULL DEFAULT 'Available',

    CONSTRAINT PK_Room PRIMARY KEY (RoomID),
    CONSTRAINT UQ_Room_RoomNumber UNIQUE (RoomNumber),
    CONSTRAINT CK_Room_CurrentStatus
        CHECK (CurrentStatus IN ('Available', 'Occupied'))
);
GO

CREATE TABLE Sensor
(
    SensorID int IDENTITY(1,1) NOT NULL,
    SensorName varchar(50) NOT NULL,
    TransmitterName varchar(50) NOT NULL,
    DateInstalled datetime NOT NULL DEFAULT GETDATE(),
    DateRemoved datetime NULL,
    RoomID int NOT NULL,

    CONSTRAINT PK_Sensor PRIMARY KEY (SensorID),
    CONSTRAINT FK_Sensor_Room
        FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);
GO

CREATE TABLE SensorLog
(
    SensorLogID int IDENTITY(1,1) NOT NULL,
    SensorID int NOT NULL,
    EventType nvarchar(5) NOT NULL,
    ExitDateTime datetime2 NOT NULL,

    CONSTRAINT PK_SensorLog PRIMARY KEY (SensorLogID),
    CONSTRAINT CK_SensorLog_EventType
        CHECK (EventType IN ('Enter', 'Exit')),
    CONSTRAINT FK_SensorLog_Sensor
        FOREIGN KEY (SensorID) REFERENCES Sensor(SensorID)
);
GO

CREATE TABLE AppUser
(
    AppUserID int IDENTITY(1,1) NOT NULL,
    FirstName nvarchar(50) NOT NULL,
    LastName nvarchar(50) NOT NULL,
    AppUserEmail nvarchar(100) NOT NULL,
    AppUserPassword nvarchar(200) NOT NULL,
    AppUserRole nvarchar(20) NOT NULL DEFAULT 'User',

    CONSTRAINT PK_AppUser PRIMARY KEY (AppUserID),
    CONSTRAINT UQ_AppUser_Email UNIQUE (AppUserEmail),
    CONSTRAINT CK_AppUser_Role
        CHECK (AppUserRole IN ('User', 'Admin'))
);
GO

CREATE TABLE Reservation
(
    ReservationID int IDENTITY(1,1) NOT NULL,
    AppUserID int NOT NULL,
    ReservationDateTime datetime2 NOT NULL DEFAULT GETDATE(),
    CheckInDateTime datetime2 NULL,
    CheckOutDateTime datetime2 NULL,
    TotalTime AS DATEDIFF(MINUTE, CheckInDateTime, CheckOutDateTime),
    ReservationStatus nvarchar(20) NOT NULL DEFAULT 'Reserved',

    CONSTRAINT PK_Reservation PRIMARY KEY (ReservationID),
    CONSTRAINT CK_Reservation_Status
        CHECK (ReservationStatus IN
            ('Reserved', 'CheckedIn', 'CheckedOut', 'Cancelled')),
    CONSTRAINT FK_Reservation_AppUser
        FOREIGN KEY (AppUserID) REFERENCES AppUser(AppUserID),
    CONSTRAINT CK_Reservation_CheckOutAfterCheckIn
        CHECK (
            CheckOutDateTime IS NULL
            OR (
                CheckInDateTime IS NOT NULL
                AND CheckOutDateTime >= CheckInDateTime
            )
        )
);
GO

CREATE TABLE RoomAvailability
(
    RoomAvailabilityID int IDENTITY(1,1) NOT NULL,
    RoomID int NOT NULL,
    AvailableDate date NOT NULL,
    StartTime time NOT NULL,
    EndTime time NOT NULL,
    AvailabilityStatus nvarchar(20) NOT NULL DEFAULT 'Available',
    ReservationID int NULL,

    CONSTRAINT PK_RoomAvailability
        PRIMARY KEY (RoomAvailabilityID),
    CONSTRAINT FK_RoomAvailability_Room
        FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT FK_RoomAvailability_Reservation
        FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID),
    CONSTRAINT UQ_RoomAvailability_Slot
        UNIQUE (RoomID, AvailableDate, StartTime),
    CONSTRAINT CK_RoomAvailability_Status
        CHECK (AvailabilityStatus IN ('Available', 'Reserved')),
    CONSTRAINT CK_RoomAvailability_TimeOrder
        CHECK (EndTime > StartTime),
    CONSTRAINT CK_RoomAvailability_15MinSlot
        CHECK (DATEDIFF(MINUTE, StartTime, EndTime) = 15)
);
