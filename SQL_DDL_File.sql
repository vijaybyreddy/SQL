#CREATE DATABASE
CREATE DATABASE employee
USE employee
#CREATE DEPARTMENTS TABLE
CREATE TABLE Departments
(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
)
CREATE TABLE Location
(
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL UNIQUE
)
CREATE TABLE Employees
(
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    gender CHAR(1),
    age INT,
    hire_date DATE DEFAULT (CURRENT_DATE),
    designation VARCHAR(30),
    department_id INT,
    location_id INT,
    CONSTRAINT chk_employee_age
        CHECK (age >= 18),
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES Departments(department_id),
    CONSTRAINT fk_employee_location
        FOREIGN KEY (location_id)
        REFERENCES Location(location_id)
)
#Insert Departments
INSERT INTO Departments
    (department_id, department_name)
VALUES
    (101, 'Human Resources'),
    (102, 'Finance'),
    (103, 'Information Technology'),
    (104, 'Sales'),
    (105, 'Marketing')
    
INSERT INTO Location
    (location_name)
VALUES
    ('Hyderabad'),
    ('Bangalore'),
    ('Chennai'),
    ('Mumbai'),
    ('Delhi')
    
INSERT INTO Employees
    (employee_name, gender, age, designation, department_id, location_id)
VALUES
    ('Rahul Sharma', 'M', 28, 'Software Developer', 103, 1),
    ('Priya Reddy', 'F', 31, 'HR Executive', 101, 1),
    ('Arun Kumar', 'M', 35, 'Finance Manager', 102, 2),
    ('Sneha Rao', 'F', 26, 'Sales Executive', 104, 3),
    ('Vikram Singh', 'M', 40, 'Marketing Manager', 105, 4)

#ALTER TABLE Commands
ALTER TABLE Employees
ADD COLUMN email VARCHAR(150)

ALTER TABLE Employees
MODIFY COLUMN designation VARCHAR(100)

ALTER TABLE Employees
DROP COLUMN age

ALTER TABLE Employees
DROP CONSTRAINT chk_employee_age

ALTER TABLE Employees
DROP COLUMN age

ALTER TABLE Employees
RENAME COLUMN hire_date TO date_of_joining

DESCRIBE Employees
#RENAME TABLES
RENAME TABLE Departments TO Departments_Info
RENAME TABLE Location TO Locations

#TRUNCATE EMPLOYEES
TRUNCATE TABLE Employees
SELECT * FROM Employees
#DROP
DROP TABLE Employees
Drop Employee Database
DROP DATABASE employee
#Employee Relationships
SELECT
    e.employee_id,
    e.employee_name,
    e.gender,
    e.age,
    e.hire_date,
    e.designation,
    d.department_name,
    l.location_name
FROM Employees e
INNER JOIN Departments d
    ON e.department_id = d.department_id
INNER JOIN Location l
    ON e.location_id = l.location_id
