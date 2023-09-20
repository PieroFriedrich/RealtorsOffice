-- DROP DATABASE IF EXISTS RealtorsOffice;
-- CREATE DATABASE RealtorsOffice;
-- USE RealtorsOffice;

SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Tenant;
DROP TABLE IF EXISTS Non_Tenant;
DROP TABLE IF EXISTS Reservations;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Facility;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Apartment;
DROP TABLE IF EXISTS Building;


-- Create Table --
CREATE TABLE Building ( 
  Building_Number VARCHAR(2) NOT NULL,
  Building_Name VARCHAR(25) NOT NULL,
  Address VARCHAR(40) NOT NULL,
  PRIMARY KEY (Building_Number)
);

CREATE TABLE Apartment (
	Building_Number VARCHAR(2) NOT NULL,
	Apartment_Number VARCHAR(4) NOT NULL,
    PRIMARY KEY (Apartment_Number, Building_Number),
    FOREIGN KEY (Building_Number) REFERENCES Building(Building_Number)
);

CREATE TABLE Person (
	SSN INT NOT NULL,
    Person_Name VARCHAR(30) NOT NULL,
    Email VARCHAR(30),
    Phone_Number VARCHAR(10) NOT NULL,
    YEAR_Of_Birth CHAR(4) NOT NULL,
    Building_Number VARCHAR(2),
    Apartment_Number VARCHAR(4),
    PRIMARY KEY (SSN),
	FOREIGN KEY (Building_Number) REFERENCES Building(Building_Number),
    FOREIGN KEY (Apartment_Number) REFERENCES Apartment(Apartment_Number)
);

CREATE TABLE Tenant (
	SSN INT NOT NULL,
    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES Person(SSN)
);

CREATE TABLE Non_Tenant (
	SSN INT NOT NULL,
    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES Person(SSN)
);

CREATE TABLE Facility (
	Facility_Name VARCHAR(20) NOT NULL,
    Facility_Description VARCHAR(30),
    Facility_Type VARCHAR(30) NOT NULL,
    Hours_Of_Operation CHAR(4) NOT NULL,
    Location VARCHAR(30) NOT NULL,
    PRIMARY KEY (Facility_Name)
);

CREATE TABLE Employee (
	Employee_ID INT NOT NULL,
    Employee_Name VARCHAR(30) NOT NULL,
    PRIMARY KEY (Employee_ID)
);

CREATE TABLE Reservations (
	Reservation_ID INT NOT NULL,
    Attended CHAR(1) NOT NULL,
    Number_Of_Guest VARCHAR(2) NOT NULL,
    SSN INT NOT NULL,
    Employee_ID INT NOT NULL,
    Facility_Name VARCHAR(20) NOT NULL,
    Start_Date DATE NOT NULL,
    Start_Time INT NOT NULL,
    End_Date DATE NOT NULL,
    End_Time INT NOT NULL,
    
    PRIMARY KEY (Reservation_ID),
    FOREIGN KEY (SSN) REFERENCES Person(SSN),
    FOREIGN KEY (Facility_Name) REFERENCES Facility(Facility_Name),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    CONSTRAINT Check_Date CHECK (End_Date >= Start_Date),
    CONSTRAINT Check_Time CHECK (End_Time >= Start_Time)
);

-- Insert Table --
INSERT INTO Building VALUES ('12','Apollo North','Westend Ave');
INSERT INTO Building VALUES ('13','Apollo West','Westend Ave');
INSERT INTO Building VALUES ('14','Apollo South','Westend Ave');
INSERT INTO Building VALUES ('15','Apollo East','Westend Ave');

INSERT INTO Apartment VALUES ('12', '807');
INSERT INTO Apartment VALUES ('14', '508');
INSERT INTO Apartment VALUES ('14', '807');

INSERT INTO Person VALUES ('809456421', 'Bob Green', 'bobgreen@gmail.com', '4561237899', '2015', '12', '807');
INSERT INTO Person VALUES ('789456123', 'Gordon Ramsey', 'gordonr@outlook.com', '7894561233', '1949', NULL, NULL);
INSERT INTO Person VALUES ('456456453', 'Michael Myers', NULL, '7894561233', '1975', '12', '807');
INSERT INTO Person VALUES ('778643453', 'Richard Frank', NULL, '7894123122', '1945', '14', '508');
INSERT INTO Person VALUES ('781231223', 'Bruno T', NULL, '4567864533', '2013', '14', '508');

INSERT INTO Tenant VALUES ('809456421');
INSERT INTO Tenant VALUES ('456456453');
INSERT INTO Tenant VALUES ('778643453');
INSERT INTO Tenant VALUES ('781231223');

INSERT INTO Non_Tenant VALUES ('789456123');

INSERT INTO Facility VALUES ('Studio', 'Hall near entrance', 'Events', '0822', 'Third Street');
INSERT INTO Facility VALUES ('Soccer Field', 'Playground 1', 'Sports', '0820', 'Fifth Street');
INSERT INTO Facility VALUES ('Gym', 'Beside Garage', 'Sports', '0821', 'First Street');

INSERT INTO Employee VALUES ('419', 'Steven Bale');
INSERT INTO Employee VALUES ('29', 'Rodrick Phillips');

INSERT INTO Reservations VALUES ('124578', 'Y', '87', '809456421', '419', 'Studio','2023-07-01', 10, '2023-07-01', 20);
INSERT INTO Reservations VALUES ('124579', 'Y', '83', '809456421', '419', 'Studio','2023-07-02', 0, '2023-07-02', 15);
INSERT INTO Reservations VALUES ('159753', 'N', '10', '778643453', '419', 'Soccer Field', '2023-07-15', 13, '2023-07-15', 23);
INSERT INTO Reservations VALUES ('154513', 'Y', '10', '781231223', '419', 'Soccer Field', '2023-07-15', 13, '2023-07-15', 23);
INSERT INTO Reservations VALUES ('166653', 'Y', '10', '789456123', '419', 'Gym', '2023-07-15', 13, '2023-07-15', 23);

-- SQL Queries --
-- 1. Most used facility
SELECT Facility_Name, COUNT(Facility_Name) AS Total_Reservations
FROM Reservations
GROUP BY Facility_Name
ORDER BY Total_Reservations DESC
LIMIT 1;

/** 2. Show the average age of persons. */
SELECT 2023 - AVG(Year_Of_Birth) AS 'Average Age'
FROM Person;

/** 3. Show the number of people who are tenants or non-tenants. **/
SELECT COUNT(T.SSN) AS Tenants, COUNT(NT.SSN) AS 'Non-Tenants'
FROM Person P
LEFT JOIN Tenant T ON P.SSN = T.SSN
LEFT JOIN Non_Tenant NT ON P.SSN = NT.SSN;

/** 4. Compare the number of reservations attended vs reservations not attended. **/
SELECT
    SUM(Attended = 'Y') AS 'Attended Reservations',
    SUM(Attended = 'N') AS 'Non-attended Reservations'
FROM Reservations;

/** 5. Delete the reservations where they did not attend.  **/
DELETE 
FROM Reservations
WHERE Attended = 'N';

/** 6. Delete non-tenants that did not attend their reservation or never created any reservation**/
DELETE 
FROM Non_Tenant NT
WHERE NT.SSN NOT IN (SELECT SSN FROM Reservations R WHERE Attended = 'Y' OR CURDATE() < R.End_Date);

/** 7. Update the reservation to indicate it was attended **/
UPDATE Reservations
SET Attended = 'Y'
WHERE Reservation_ID = 434343;

/** 8. Using the specified facility, determine the average time booked per reservation**/

SELECT F.Facility_Name, R.Facility_Name, AVG(R.End_Time - R.Start_Time)
FROM Facility F, Reservations R
GROUP BY F.Facility_Name, R.Facility_Name
HAVING F.Facility_Name = R.Facility_Name;

/** 9. Show all contact info from the person who made a reservation **/
SELECT Reservation_ID, P.Person_Name, P.SSN, P.Phone_Number, P.Email
FROM Reservations R LEFT JOIN Person P ON R.SSN = P.SSN;

-- 10. Show all the employees responsible for the reservations
SELECT E.Employee_ID, R.Reservation_ID
FROM Employee E 
RIGHT JOIN Reservations R ON E.Employee_ID = R.Employee_ID;

-- 11. Average people living in the same apartment
SELECT COUNT(DISTINCT T.SSN) / COUNT(DISTINCT P.Apartment_Number) AS Average_Tenants_Per_Apartment
FROM Tenant T, Person P;

-- 12. Max number of tenants living in the same apartment
SELECT COUNT(P.SSN) AS Max_Tenants, P.Building_Number, P.Apartment_Number
FROM Person P
JOIN Apartment A ON P.Apartment_Number = A.Apartment_Number
JOIN Building B ON P.Building_Number = B.Building_Number
GROUP BY P.Building_Number, P.Apartment_Number
HAVING COUNT(P.SSN) = (
    SELECT MAX(TenantCount) 
    FROM (
        SELECT COUNT(SSN) AS TenantCount
        FROM Person
        GROUP BY Building_Number, Apartment_Number
    ) AS Counts
);

-- 13. Count of reservations done by kids under 13 to each facility that were attended
SELECT COUNT(R.SSN) AS Kids_Reservations, F.Facility_Name
FROM Facility F
LEFT JOIN Reservations R ON F.Facility_Name = R.Facility_Name
LEFT JOIN Person P ON R.SSN = P.SSN
WHERE 2023 - P.Year_Of_Birth <= 13
GROUP BY F.Facility_Name;

-- 14. Count how many times a facility was booked, using view
CREATE VIEW facility_booking_records AS
SELECT Facility_Name, COUNT(Facility_Name) AS Times_Booked
FROM Reservations
GROUP BY Facility_Name;

SELECT * FROM facility_booking_records;
DROP VIEW facility_booking_records;

-- 15. Most Number of Reservations per day
SELECT Start_Date, COUNT(Reservation_ID)
FROM Reservations
GROUP BY Start_Date
ORDER BY COUNT(Reservation_ID) DESC;

-- 16. Seniors living in the building complex
SELECT COUNT(P.SSN), A.Building_Number
FROM Apartment A
JOIN Person P ON P.Apartment_Number = A.Apartment_Number AND P.Building_Number = A.Building_Number
WHERE 2023 - P.Year_Of_Birth >= 65
GROUP BY A.Building_Number;

-- 17. Show all the non-tenants who are registered with both authentication factors (PhoneNumber and E-mail)
SELECT P.Person_Name, P.Phone_Number, P.Email
FROM Person P RIGHT JOIN Non_Tenant NT ON P.SSN = NT.SSN
WHERE P.Phone_Number AND P.Email IS NOT NULL;

-- 18. Least used facility
SELECT Facility_Name, COUNT(Facility_Name) AS Total_Reservations
FROM Reservations
GROUP BY Facility_Name
ORDER BY Total_Reservations
LIMIT 1;

-- 19. View number of tenants living per building
CREATE VIEW People_Living_Per_Building AS
SELECT COUNT(T.SSN), P.Building_Number
FROM Person P RIGHT JOIN Tenant T ON P.SSN = T.SSN
GROUP BY Building_Number;

SELECT * FROM People_Living_Per_Building;
DROP VIEW People_Living_Per_Building;

-- 20. Show facilities and each operating hours in a day
SELECT Facility_Name, SUM(SUBSTRING(Hours_Of_Operation, 3, 2) - SUBSTRING(Hours_Of_Operation, 1, 2)) AS Daily_Hours_Of_Operation
FROM Facility
GROUP BY Facility_Name;
