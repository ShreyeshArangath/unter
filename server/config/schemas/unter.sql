DROP DATABASE IF EXISTS Unter;
CREATE DATABASE Unter;
USE Unter; 

DROP TABLE IF EXISTS DRIVER; 
CREATE TABLE DRIVER(
	fname varchar(25) NOT NULL, 
	lname varchar(25) NOT NULL, 
	dob date NOT NULL, 
	userID varchar(50) NOT NULL, 
	CONSTRAINT pk_driver primary key(userID) 
);

DROP TABLE IF EXISTS PASSENGER; 
CREATE TABLE PASSENGER(
	fname varchar(25) NOT NULL, 
	lname varchar(25) NOT NULL, 
	dob date NOT NULL, 
	userID varchar(50) NOT NULL, 
	CONSTRAINT pk_passenger primary key(userID)
);

DROP TABLE IF EXISTS TRIP; 
CREATE TABLE TRIP(
	tripID int NOT NULL AUTO_INCREMENT, 
	price int NOT NULL DEFAULT 0, 
	state ENUM('IN_PROGRESS', 'IN_QUEUE', 'COMPLETED') NOT NULL DEFAULT 'IN_QUEUE', 
	toAddress varchar(50) NOT NULL, 
	fromAddress varchar(50) NOT NULL, 
	tripRequestedTime datetime NOT NULL, 
    numPassengers int NOT NULL DEFAULT 1, 
    driverRating decimal(3, 2) DEFAULT 5.00,
    passengerRating decimal(3, 2) DEFAULT 5.00,
	CONSTRAINT pk_trip PRIMARY KEY(tripID)
);

DROP TABLE IF EXISTS PASSENGER_TRIPS; 
CREATE TABLE PASSENGER_TRIPS(
	tripID int NOT NULL, 
	passengerID varchar(50) NOT NULL,
	CONSTRAINT pk_pass_trip PRIMARY KEY(tripID, passengerID), 
	CONSTRAINT fk_passengerTrips_passengerID FOREIGN KEY (passengerID) references PASSENGER(userID), 
	CONSTRAINT fk_passengerTrips_tripID FOREIGN KEY (tripID) references TRIP(tripID) ON DELETE CASCADE ON UPDATE CASCADE 
);

DROP TABLE IF EXISTS DRIVER_TRIPS; 
CREATE TABLE DRIVER_TRIPS(
	tripID int NOT NULL, 
	driverID varchar(50) NOT NULL,
	CONSTRAINT pk_driver_trip PRIMARY KEY(tripID, driverID), 
	CONSTRAINT fk_driverTrips_driverID FOREIGN KEY (driverID) references DRIVER(userID), 
	CONSTRAINT fk_driverTrips_tripID FOREIGN KEY (tripID) references TRIP(tripID) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PAYMENT_METHODS; 
CREATE TABLE PAYMENT_METHODS(
	userID varchar(50) NOT NULL, 
	paymentMethod varchar(20) NOT NULL DEFAULT "Wire Transfer", 
	CONSTRAINT pk_payment_methods PRIMARY KEY(userID, paymentMethod), 
	CONSTRAINT fk_paymentMethods_userID  FOREIGN KEY(userID) references PASSENGER(userID) ON DELETE CASCADE ON UPDATE CASCADE 
);

DROP TABLE IF EXISTS Payment; 
CREATE TABLE Payment(
	transactionID int NOT NULL AUTO_INCREMENT, 
	tripID int NOT NULL, 
	paymentMethod varchar(20) NOT NULL DEFAULT "Wire Transfer", 
	CONSTRAINT pk_payment PRIMARY KEY(transactionID, tripID), 
	CONSTRAINT fk_payment_tripID FOREIGN KEY(tripID) references TRIP(tripID) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE VIEW passengerRating 
AS 
SELECT p.userID, COUNT(*) as totalTrips, AVG(t.driverRating) as rating FROM PASSENGER p, TRIP t 
	WHERE p.userID IN (SELECT passengerID FROM PASSENGER_TRIPS WHERE tripID = t.tripID) 
    GROUP BY p.userID; 

CREATE VIEW driverRating 
AS 
SELECT d.userID, COUNT(*) AS totalTrips, AVG(t.passengerRating) as rating FROM DRIVER d, TRIP t 
	WHERE d.userID IN (SELECT driverID FROM DRIVER_TRIPS WHERE tripID = t.tripID) 
    GROUP BY d.userID; 
    