insert into Room (RoomNumber, Floor, Seats, Whiteboard) values
('REH 4213', 4, 4, 1),
('REH 4225', 4, 6, 0),
('REH 5213', 5, 4, 1),
('REH 5225', 5, 6, 0),
('REH 2004', 2, 15, 0),
('REH 2008', 2, 15, 1),
('REH 2407', 2, 5, 0),
('REH 2408', 2, 5, 0);


go


insert into SensorNode (SensorName, SensorMacAddress, Microcontroller, MicrocontrollerMacAddress, RoomID) values
('LD2410C', 'A6:73:A2:79:F3:79', 'ESP32-S3-WROOM-1', '58:E6:C5:69:93:30', 1),
('LD2410C', '7E:A0:33:3D:02:6F', 'ESP32-S3-WROOM-1', '58:E6:C5:73:31:74', 2),
('LD2410C', '8F:7F:24:22:5D:0D', 'ESP32-S3-WROOM-1', '58:E6:C5:72:19:14', 3),
('LD2410C', '05:E5:D9:83:2F:88', 'ESP32-S3-WROOM-1', '14:C1:9F:D8:15:AC', 4),
('LD2410C', '45:A0:18:16:E2:C4', 'ESP32-S3-WROOM-1', '58:E6:C5:68:7E:48', 5),
('LD2410C', '9B:80:01:28:EA:36', 'ESP32-S3-WROOM-1', '14:C1:9F:DB:8E:04', 6),
('LD2410C', 'F0:A1:EE:A7:E3:BE', 'ESP32-S3-WROOM-1', '14:C1:9F:DB:8B:B8', 7),
('LD2410C', '56:84:96:B3:19:40', 'ESP32-S3-WROOM-1', '58:E6:C5:6E:74:1C', 8);



/*
insert into SensorNode (SensorName, SensorMacAddress, Microcontroller, MicrocontrollerMacAddress, RoomID) values
('LD2410C', '05:E5:D9:83:2F:88', 'ESP32-S3-WROOM-1', '14:C1:9F:D8:15:AC', 4); //for 5, 6, 7, 8 from students
*/

go


insert into AppUser (FirstName, LastName, AppUserEmail, AppUserPassword, AppUserRole) values
('Alice', 'Smith', 'alice.smith@school.edu', 'hashed_password_1', 'Admin'),
('Bob', 'Johnson', 'bob.johnson@school.edu', 'hashed_password_2', 'User'),
('Charlie', 'Brown', 'charlie.brown@school.edu', 'hashed_password_3', 'User'),
('David', 'Williams', 'david.williams@school.edu', 'hashed_password_4', 'User');


go

-- select * from AppUser;
