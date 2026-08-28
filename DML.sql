#DISTINCT SALARIES
SELECT DISTINCT salary FROM Employees ORDER BY salary
#ALIAS
SELECT age AS Employee_Age, salary AS Employee_Salary FROM Employees
#CLAUSE AND OPERATORS
SELECT
    employee_id,
    employee_name,
    salary,
    hire_date
FROM Employees
WHERE salary > 50000
  AND hire_date < '2016-01-01'
  
  #FIND MISSING DESIGNATIONS
  SELECT
    employee_id,
    employee_name,
    designation
FROM Employees
WHERE designation IS NULL

UPDATE Employees
SET designation = 'Data Scientist'
WHERE designation IS NULL

#ORDER BY
SELECT employee_id,employee_name,department_id,salary FROM Employees ORDER BY department_id ASC,
salary DESC
#LIMIT
SELECT employee_id,employee_name,hire_date,designation
FROM Employees
WHERE hire_date >= '2018-01-01'
  AND hire_date < '2019-01-01'
ORDER BY hire_date ASC
LIMIT 5
#SUM OF FINANCE SALARIES
SELECT d.department_name, SUM(e.salary) AS Total_Finance_Salary
FROM Employees AS e
INNER JOIN Departments AS d ON e.department_id = d.department_id
WHERE d.department_name = 'Finance'
GROUP BY d.department_name

#MINIMUM AGE
SELECT MIN(age) AS Minimum_Employee_Age
FROM Employees

#MAXIMUM SALARY BY LOCATION
SELECT l.location_name, MAX(e.salary) AS Maximum_Salary
FROM Location AS l
LEFT JOIN Employees AS e
    ON l.location_id = e.location_id
GROUP BY l.location_id, l.location_name
ORDER BY l.location_name

#AVERAGE SALARY FOR ANALYST DESIGNATIONS
SELECT designation, AVG(salary) AS Average_Salary FROM Employees WHERE designation LIKE '%Analyst%'
GROUP BY designation
ORDER BY designation

#DEPARTMENTS WITH <3 EMPLOYEES
SELECT d.department_id,d.department_name,COUNT(e.employee_id) AS Employee_Count FROM Departments AS d
LEFT JOIN Employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
HAVING COUNT(e.employee_id) < 3
ORDER BY Employee_Count ASC

#AVERAGE FEMALE AGE < 30
SELECT l.location_name,AVG(e.age) AS Average_Female_Age FROM Location AS l
INNER JOIN Employees AS e
    ON l.location_id = e.location_id
WHERE e.gender = 'F'
GROUP BY
    l.location_id,
    l.location_name
HAVING AVG(e.age) < 30
ORDER BY Average_Female_Age

#INNER JOIN
SELECT e.employee_name,e.designation,d.department_name
FROM Employees AS e
INNER JOIN Departments AS d
    ON e.department_id = d.department_id
ORDER BY d.department_name, e.employee_name

#LEFT JOIN
SELECT d.department_id,d.department_name, COUNT(e.employee_id) AS Total_Employees
FROM Departments AS d
LEFT JOIN Employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY d.department_id

#RIGHT JOIN
SELECT l.location_name,e.employee_name FROM Employees AS e
RIGHT JOIN Location AS l
    ON e.location_id = l.location_id
ORDER BY
    l.location_name,
    e.employee_name
    

  