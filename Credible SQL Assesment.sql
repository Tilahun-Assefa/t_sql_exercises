--Credible SQL Developer Assesment
--No.1 
USE TSQL2012; 
 
IF OBJECT_ID('dbo.#CourseSales', 'U') IS NOT NULL DROP TABLE dbo.#CourseSales; 

CREATE TABLE #CourseSales
(
	Course VARCHAR(50), 
	YEAR INT, 
	Earning MONEY
);
GO
--Insert sample records
INSERT INTO #CourseSales VALUES('.NET', 2012, 10000)
INSERT INTO #CourseSales VALUES('Java', 2012, 20000)
INSERT INTO #CourseSales VALUES('.NET', 2012, 5000)
INSERT INTO #CourseSales VALUES('.NET', 2013, 48000)
INSERT INTO #CourseSales VALUES('Java', 2013, 30000);
GO

SELECT * 
FROM #CourseSales
 PIVOT(SUM(Earning)
  FOR Course
   IN([.NET], Java) ) AS PVTTable
/*****************************************************************************/
--2.
CREATE TABLE #Student
(
	ID INT,
	Name VARCHAR(50), 
	Mark INT
);
GO
--Insert sample records
INSERT INTO #Student
	(ID, Name, Mark)
VALUES
(001, 'Student1', 88),
(002, 'Student2', 56),
(003, 'Student3', 98),
(004, 'Student4', 74),
(005, 'Student5', 81),
(006, 'Student6', 65),
(007, 'Student7', 54);
GO
CREATE TABLE #Grade
(
	Grade INT,
	Min_mark INT, 
	Max_mark INT
);
GO
--Insert sample records
INSERT INTO #Grade
	(Grade, Min_mark, Max_mark)
VALUES
(1, 0, 8),
(2, 10, 19),
(3, 20, 29),
(4, 30, 39),
(5, 40, 49),
(6, 50, 59),
(7, 60, 69),
(8, 70, 79),
(9, 80, 89),
(10, 90, 100);
GO
--a. Don't report the names of the students whose grade is less than 8
SELECT S.Name, G.Grade, S.Mark
FROM #Student AS S
INNER JOIN
#Grade AS G
ON S.Mark >= G.Min_mark AND S.Mark <= G.Max_mark
WHERE G.Grade >= 8

SELECT 
	CASE
	  WHEN G.Grade >=8 THEN S.Name
	  ELSE ''
	END AS Name, G.Grade, S.Mark 
FROM #Student AS S
INNER JOIN
#Grade AS G
ON S.Mark BETWEEN G.Min_mark AND G.Max_mark


--b. Order descending by grade. if there is more than one student with the same grade 
--order those particular student by their name alphabetically
SELECT S.Name, G.Grade, S.Mark
FROM #Student AS S
INNER JOIN
#Grade AS G
ON S.Mark >= G.Min_mark AND S.Mark <= G.Max_mark
ORDER BY G.Grade DESC , S.Name 

--C. If grade is lower than 8 Use 'NULL' as their name and list them by their grades in 
--descending order. If there is more than one one student with the the same Grade
--(1-7) assigned to them order those particular students by their marks in ascending order
SELECT 
	CASE
	  WHEN G.Grade >=8 THEN S.Name
	  ELSE 'NULL'
	END AS Name, G.Grade, S.Mark 
FROM #Student AS S
INNER JOIN
#Grade AS G
ON S.Mark BETWEEN G.Min_mark AND G.Max_mark
ORDER BY G.Grade DESC, S.Mark 
/**************************************************************************************/
--3. Query to output the start and end date of projects listed by the numbers of days it
--took to complete projects in ascending orders.
GO
CREATE TABLE #Projects
(
	Task_ID INT,
	Start_Date Date, 
	End_Date Date
);
GO
--Insert sample records
INSERT INTO #Projects
	(Task_ID, Start_Date, End_Date)
VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');
GO

SET NOCOUNT ON;

DECLARE @Result TABLE
	(
		Task_ID INT,
		Start_Date Date, 
		End_Date Date,
		Project_ID INT,
		PRIMARY KEY (Task_ID)
	);
DECLARE
	@taskID AS INT,
	@startdate AS DATE,
	@enddate AS DATE,
	@prvenddate AS DATE,
	@projectID AS INT;

DECLARE C CURSOR FAST_FORWARD /* read only, forward only */
FOR 
	SELECT Task_ID, Start_Date, End_Date
	FROM #Projects
	ORDER BY End_Date;

OPEN C;
FETCH NEXT FROM C INTO @taskID, @startdate, @enddate;

SELECT @prvenddate = @enddate,  @projectID = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
	IF DAY(@enddate) <> DAY(@prvenddate) + 1		
		SET @projectID +=1;	
		
	SELECT @prvenddate = @enddate;
	INSERT INTO @Result VALUES(@taskID, @startdate, @enddate, @projectID);
	FETCH NEXT FROM C INTO @taskID, @startdate, @enddate;
END

CLOSE C;
DEALLOCATE C;

SELECT Task_ID, Start_Date, End_Date, Project_ID
FROM @Result
ORDER BY End_Date
/*****************************************************************************/
--Quiz4. Code that would first output Customer Mobile but Customer Phone if Customer mobile is Null
CREATE TABLE #Customer
(
	Phone VARCHAR(50),
	Mobile VARCHAR(50)
);
GO
INSERT INTO #Customer
VALUES
('1245', '5789'),
('1245', '5789'),
('1245', NULL),
(NULL, '5789')

SELECT COALESCE(Mobile, Phone) AS [Phone Number]
FROM #Customer;
SELECT ISNULL(Mobile, Phone) AS [Phone Number]
FROM #Customer;

/**************************************************************************/
--5. table 
CREATE TABLE #Customers
(
	first_name VARCHAR(50),
	dd16 INT,
	dd7 INT
);
GO
INSERT INTO #Customers
VALUES
('John', 1235, 1235),
('Jane', 1238, 1235),
('Mary', 1234, 1237)

CREATE TABLE #OtherData
(
	id INT,
	data_category VARCHAR(50),
	data_value VARCHAR(50),
	is_deleted BIT
);
GO
INSERT INTO #OtherData
VALUES
(1234,'Lorem ipsum dolor', 'aaaa', 0),
(1235,'Lorem ipsum dolor', 'bbbb', 0),
(1235, 'Sit amet', 'cccc', 0),
(1237, 'Sit amet', 'dddd', 0),
(1238,'Lorem ipsum dolor', 'eeee', 1)

SELECT C.first_name, O.data_value, C.dd16, C.dd7, O.id, O.data_category, O.is_deleted
FROM #Customers AS C
	JOIN #OtherData AS O
	ON C.dd16 = O.id AND O. data_category ='Lorem ipsum dolor' or C.dd7 = O.id AND O.data_category = 'Sit amet'

SELECT C.first_name, O.data_value
FROM #Customers AS C
	JOIN #OtherData AS O
	ON C.dd16 = O.id or C.dd7 = O.id 
GO
/******************************************************************************************/
--6. Query******************
USE NursingModelTest;
IF OBJECT_ID('tempdb.dbo.#Customers1', 'U') IS NOT NULL DROP TABLE tempdb.dbo.#Customers1; 
GO
CREATE TABLE #Customers1
(
	id INT,
	name VARCHAR(10),
	is_deleted bit
);
GO
INSERT INTO #Customers1
VALUES
	(1,'John', 0),
	(2,'Jane', 0),
	(3,'Mary', 1),
	(4,'Adam', 1),
	(5,'Craig', 0),
	(6,'Steve', 0)

IF OBJECT_ID('tempdb.dbo.#OtherData1', 'U') IS NOT NULL DROP TABLE tempdb.dbo.#OtherData1; 
GO
CREATE TABLE #OtherData1
(
	id INT,
	c_id INT
);
GO
INSERT INTO #OtherData1
VALUES
(100, 6),
(101, 2),
(102, 4),
(103, 5)
GO
--List of customer name ordered alphabetically with the direction(Ascending or Descending)
--based on an input parameter
IF OBJECT_ID('dbo.List', 'P') IS NOT NULL DROP PROC List
GO
CREATE PROC List
--Input param A for ascending and else descending
	@Order AS VARCHAR(2)

AS
SET NOCOUNT ON;
	IF(@Order = 'A')
		SELECT name FROM #Customers1 ORDER BY name
	ELSE
		SELECT name FROM #Customers1 ORDER BY name DESC
	
EXEC List A
EXEC List M
--Exclude any customer that exist in otherdata table who have been marked as deleted
SELECT C.name, O.id
FROM #Customers1 AS C
		LEFT JOIN #OtherData1 AS O
		ON C.id = O.c_id 
WHERE is_deleted = 0 AND O.id IS NULL

SELECT C.name, C.id
FROM #Customers1 AS C
		NOT EXIST 	ON C.id = O.c_id 
WHERE is_deleted = 0 AND O.id IS NULL
GO
/*******************************************************************************/
--7. Using the given table output the values of all columns into one line
--delimetd with a pipe (|) Lorem ipsum dolor ||1235|6
USE NursingModelTest;

IF OBJECT_ID('tempdb.dbo.#Customers2', 'U') IS NOT NULL DROP TABLE tempdb.dbo.#Customers2; 
GO
CREATE TABLE #Customers2
(
	text100 VARCHAR(100),
	dd16 SMALLINT,
	dd7 SMALLINT,
	num21 float
);
GO
INSERT INTO #Customers2
VALUES
	('Lorem ipsum dolor', NULL, '1235', 6)

SELECT CONCAT(text100, '|', dd16, '|', dd7, '|', num21) FROM #Customers2
/**************************************************************************************/
--8.
IF OBJECT_ID('tempdb.dbo.#Customers3', 'U') IS NOT NULL DROP TABLE tempdb.dbo.#Customers3; 
GO
CREATE TABLE #Customers3
(
	id INT,
	credential VARCHAR(3)
);
GO
INSERT INTO #Customers3
VALUES
	(1, 'MD'),
	(1, 'DO'),
	(1, 'DDS'),
	(1, 'DVM'),
	(1, 'PhD')

SELECT * FROM #Customers3

SET NOCOUNT ON;

DECLARE @Result1 TABLE
	(
		id INT,
		credentials VARCHAR(50)
	);
DECLARE
	@first AS INT,
	@credential AS VARCHAR(5),
	@t AS VARCHAR(50),
	@ID AS INT

DECLARE C CURSOR FAST_FORWARD /* read only, forward only */
FOR 
	SELECT id, credential
	FROM #Customers3
	ORDER BY id;
OPEN C;
FETCH NEXT FROM C INTO @ID, @credential;

SELECT @t = @credential,  @first = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @first = 0
		SET @t = @t
	ELSE
		SELECT @t = @t + ',' + @credential ;
	SET @first = 1;			
	FETCH NEXT FROM C INTO @ID, @credential;
END
INSERT INTO @Result1 VALUES(@ID, @t);
CLOSE C;
DEALLOCATE C;

SELECT id, credentials
FROM @Result1

/************************************************************************************/
--9.Write a stored procedure that returns the employee data sorted by a user speciified column
USE NursingModelTest;
IF OBJECT_ID('tempdb.dbo.#Employee', 'U') IS NOT NULL DROP TABLE tempdb.dbo.#Employee; 
GO
CREATE TABLE #Employee
(
	Id INT,
	Name VARCHAR(10),
	Gender INT,
	Salary INT,
	City INT,
	Age INT
);
GO
INSERT INTO #Employee
VALUES
	(001,'Emp1', 1212, 55000, 98, 35),
	(002,'Emp2', 1212, 35000, 92, 98),
	(003,'Emp3', 1213, 60000, 95, 29),
	(004,'Emp4', 1214, 55000, 91, 45),
	(005,'Emp5', 1213, 65412, 95, 32)

IF OBJECT_ID('tempdb.dbo.#lookuptbl', 'U') IS NOT NULL DROP TABLE tempdb.dbo.#lookuptbl; 
GO
CREATE TABLE #lookuptbl
(
	Lookup_id INT,
	Lookup_category VARCHAR(20),
	Lookup_code VARCHAR(20),
	Lookup_desc VARCHAR(20),
	Ext_id INT
);
GO
INSERT INTO #lookuptbl
VALUES
(001, 'Gender', 'M', 'Male', 1212),
(002, 'Gender', 'F', 'Female', 1213),
(003, 'Gender', 'T', 'Trasgender', 1214),
(004, 'City', 'CITY', 'London', 98),
(005, 'City', 'CITY', 'New York', 92),
(006, 'City', 'CITY', 'Baltimore', 95),
(007, 'City', 'CITY', 'Laurel', 91)

GO
--The result will display each employees name, gender description, salary, city discription, and age
IF OBJECT_ID('dbo.EmpData', 'P') IS NOT NULL DROP PROC EmpData
GO
CREATE PROC EmpData
--Input param column name for ordering 
	@Order AS VARCHAR(20)
AS
SET NOCOUNT ON;
	IF(@Order = 'Id')
		SELECT Name, L.Lookup_desc AS Gender, B.Lookup_desc AS City, Salary, Age  
		FROM #Employee AS E
		JOIN #lookuptbl AS L
		ON E.Gender = L.Ext_id 
		JOIN #lookuptbl AS B
		ON E.City = B.Ext_id
		ORDER BY Id
	ELSE IF (@Order = 'Name')
		SELECT * FROM #Employee ORDER BY Name
	ELSE IF (@Order = 'Gender')
		SELECT * FROM #Employee ORDER BY Gender
	ELSE IF (@Order = 'Salary')
		SELECT * FROM #Employee ORDER BY Salary
	ELSE IF (@Order = 'City')
		SELECT * FROM #Employee ORDER BY City
	ELSE IF (@Order = 'Age')
		SELECT * FROM #Employee ORDER BY Age
		
/**********************************************************************/

--10. Query that returns only the 4th highest salary from the above table.
-- Do not use SELECT TOP
DECLARE @StartingRowNumber tinyint = 3, @PageSize tinyint = 1;  
SELECT Id, Name, Salary, RANK() OVER( ORDER BY SALARY ) AS rn  
FROM #Employee  
ORDER BY Salary DESC   
    OFFSET @StartingRowNumber ROWS   
    FETCH NEXT @PageSize ROWS ONLY;  
/***********************************************/
SELECT Id, Name, Salary, RANK() OVER( ORDER BY SALARY DESC ) AS rn  
FROM #Employee  

BEGIN TRANSACTION;  
GO  
-- Declare and set the variables for the OFFSET and FETCH values.  
DECLARE @StartingRowNumber int = 1  
      , @RowCountPerPage int = 3;  
  
-- Create the condition to stop the transaction after all rows have been returned.  
WHILE (SELECT COUNT(*) FROM #Employee) >= @StartingRowNumber  
BEGIN  
  
-- Run the query until the stop condition is met.  
SELECT  Name, Gender  
FROM #Employee  
ORDER BY Id ASC   
    OFFSET @StartingRowNumber - 1 ROWS   
    FETCH NEXT @RowCountPerPage ROWS ONLY;  
  
-- Increment @StartingRowNumber value.  
SET @StartingRowNumber = @StartingRowNumber + @RowCountPerPage;  
CONTINUE  
END;  
GO  
COMMIT TRANSACTION;  
GO  