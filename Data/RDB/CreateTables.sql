go

drop table if exists RoomAvailability;
go
drop table if exists Reservation;
go
drop table if exists Room;
go
drop table if exists AppUser;
go


create table Room (
    RoomID int identity(1,1) primary key,
    RoomNumber varchar(10) not null,
    Floor int not null,
    Seats int not null,
    Whiteboard bit not null,
    CurrentStatus varchar(20) not null
);
go


create table AppUser (
    AppUserID int identity(1,1) primary key,
    Email varchar(100) not null,
    Password varchar(100) not null
);
go


create table Reservation (
    ReservationID int identity(1,1) primary key,
    AppUserID int not null,
    ReservationDateTime datetime not null,
    CheckInDateTime datetime,
    CheckOutDateTime datetime,
    TotalTime int,
    ReservationStatus varchar(20) not null,
    constraint FK_Reservation_AppUser foreign key (AppUserID) references AppUser(AppUserID)
);
go


create table RoomAvailability (
    RoomAvailabilityID int identity(1,1) primary key,
    RoomID int not null,
    ReservationID int,
    AvailableDate date not null,
    AvailableStartTime time not null,
    AvailableEndTime time not null,
    AvailabilityStatus varchar(20) not null,
    constraint FK_RoomAvailability_Room foreign key (RoomID) references Room(RoomID),
    constraint FK_RoomAvailability_Reservation foreign key (ReservationID) references Reservation(ReservationID)
);











