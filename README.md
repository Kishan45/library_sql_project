# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System   
**Database**: `library_project_p2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_project_p2`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
DROP TABLE IF EXISTS branch; 

CREATE TABLE branch
(
	branch_id VARCHAR(6) PRIMARY KEY,
	manager_id VARCHAR(6),
	branch_address TEXT,
	contact_no NUMERIC(12)

);

DROP TABLE IF EXISTS employees; 
CREATE TABLE employees
(
	emp_id VARCHAR(6) PRIMARY KEY,
	emp_name VARCHAR(35),
	position VARCHAR(20),	
	salary NUMERIC(10),
	branch_id VARCHAR(6)      --FK
);

DROP TABLE IF EXISTS books; 

CREATE TABLE books
(
	isbn VARCHAR(20) PRIMARY KEY,
	book_title VARCHAR(70),
	category VARCHAR(25),
	rental_price NUMERIC(1,2),
	status VARCHAR(10),
	author VARCHAR(35),
	publisher VARCHAR(55)
)

ALTER TABLE books
ALTER COLUMN rental_price type float

DROP TABLE IF EXISTS members; 

CREATE TABLE members
(
	member_id VARCHAR(10) PRIMARY KEY,	
	member_name	VARCHAR(35),
	member_address TEXT,
	reg_date DATE
)


DROP TABLE IF EXISTS issued_status; 

CREATE TABLE issued_status
(
	issued_id VARCHAR(10) PRIMARY KEY,	
	issued_member_id VARCHAR(10),           --FK
	issued_book_name VARCHAR(70),
	issued_date	DATE,
	issued_book_isbn  VARCHAR(20),          --FK
	issued_emp_id VARCHAR(6)                 --FK
);

DROP TABLE IF EXISTS return_status; 

CREATE TABLE return_status
(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10),                    --FK
	return_book_name VARCHAR(70),
	return_date	DATE,
	return_book_isbn VARCHAR(20)                

);


```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books
(
	isbn,
	book_title,
	category,
	rental_price,
	status,
	author,
	publisher
)
VALUES
(
	'978-1-60129-456-2',
	'To Kill A Mockingbird',
	'Classic',
	6.00,
	'yes',
	'Harper Lee',
	'J.b.Lippincott & Co.'
)

```
**Task 2: Update an Existing Member's Address**

```sql
SELECT * FROM members;

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

SELECT * FROM members
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS140' from the issued_status table.

```sql
SELECT * FROM issued_status;
SELECT * FROM return_status;


DELETE FROM issued_status
WHERE issued_id = 'IS140';
SELECT * FROM issued_status;

```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status

SELECT 
	issued_emp_id,
	issued_book_name
FROM
	issued_status
WHERE issued_emp_id = 'E101'

```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
      issued_member_id, 
      COUNT(issued_book_name) as issued_book
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_book_name) >1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issue_cnt
AS
SELECT 
	b.book_title,
	COUNT(ist.issued_id) as total_book_issued
FROM
	books b 
INNER JOIN
	issued_status as ist ON b.isbn = ist.issued_book_isbn
GROUP BY b.book_title
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
	category, 
	SUM(rental_price) 
FROM books
GROUP BY category
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT 
	member_name,
	reg_date,
FROM
	members
WHERE  (CURRENT_DATE - reg_date) < 360  -- today 19/02/2025
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
	e.emp_id,
	e.emp_name,
	e2.emp_name as manager_name,  --b.manager_id,
	branch_address
FROM
	employees e 
INNER JOIN 
	branch b ON e.branch_id = b.branch_id
JOIN 
	employees e2 on b.manager_id = e2.emp_id

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE abv_6_rent
AS
(
	SELECT 
                        *
	FROM
		books
	WHERE rental_price > 6
)	
	
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT
	i.issued_id,
	i.issued_book_name
FROM
	issued_status i
LEFT JOIN 
	return_status r
ON
	i.issued_id = r.issued_id
WHERE 
	r.issued_id IS NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
WITH due 
AS
(
SELECT 
	m.member_id,
	m.member_name,
	i.issued_book_name,
	i.issued_date,
	(i.issued_date +30) as overdue
FROM 
	members m 
INNER JOIN 
	issued_status i ON m.member_id = i.issued_member_id 
LEFT JOIN 
	return_status r ON r.issued_id = i.issued_id
WHERE
	r.issued_id is NULL
)

SELECT 
	*,
	(CURRENT_DATE - overdue) AS due_date_expired
FROM due
WHERE 
	(CURRENT_DATE - overdue) > 30
ORDER BY 1
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
CREATE OR REPLACE PROCEDURE return_book_update(p_return_id VARCHAR(10),p_issued_id VARCHAR(10),p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(20);
	v_book_name VARCHAR(70);
BEGIN

	INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
	VALUES (p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);

	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO 
		v_isbn, v_book_name
	FROM
		issued_status
	WHERE
		issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'THANK YOU FOR RETURNING BOOK: %',v_book_name;
END;
$$

--calling procedure
CALL return_book_update('RS119','IS130','Good');


-- testing procedure return book_update
SELECT * FROM 
issued_status
WHERE issued_book_isbn = '978-0-451-52994-2';

SELECT * FROM 
books
WHERE isbn = '978-0-451-52994-2';


SELECT * FROM 
return_status 
WHERE issued_id = 'IS130';

DELETE FROM return_status

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_wise
AS
(
SELECT 
	e.branch_id,
	COUNT(i.issued_id) AS Total_book_issued,
	COUNT(r.issued_id) AS Total_return_book,
	SUM(b.rental_price) AS Rental
FROM
	issued_status i
FULL OUTER JOIN
	employees e
ON	i.issued_emp_id = e.emp_id
LEFT JOIN 
	return_status r
ON	i.issued_id = r.issued_id 
JOIN 
	books b
ON	i.issued_book_name = b.book_title
GROUP BY e.branch_id
ORDER BY rental DESC
)

SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

DROP TABLE IF EXISTS Latest_issued_2m; 
CREATE TABLE Latest_issued_2m
AS
SELECT
	i.issued_date,
	m.member_name
FROM 
	issued_status i
JOIN
	members m
ON	i.issued_member_id = m.member_id
WHERE
	 i.issued_date >= CURRENT_DATE - INTERVAL '2 month'  ;
```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
	e.emp_name,
	e.branch_id,
	COUNT(i.issued_id) as book_processed
FROM
	issued_status i
JOIN
	employees e
ON
	e.emp_id = i.issued_emp_id
	
GROUP BY e.emp_name,2
ORDER BY book_processed DESC
LIMIT 3

```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE OR REPLACE PROCEDURE p_book_yes_no(p_issued_id VARCHAR (10), p_issued_mem_id VARCHAR(10), p_issued_isbn VARCHAR(20), p_issued_emp_id VARCHAR(6) )
LANGUAGE plpgsql
AS $$

DECLARE 
	v_status VARCHAR(10);
	v_book_title VARCHAR(70);
BEGIN

	SELECT 
		status,
		book_title
	INTO
		v_status, v_book_title
	FROM
		books
	WHERE 
		isbn = p_issued_isbn;

	IF v_status = 'yes' THEN
	
		INSERT INTO issued_status (issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
		VALUES (p_issued_id,p_issued_mem_id,v_book_title,CURRENT_DATE,p_issued_isbn,p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_isbn ;
		RAISE NOTICE 'The % is successfully issued',v_book_title;
	ELSE
		RAISE EXCEPTION 'The % is currently not available',v_book_title;
	END IF;


END;
$$
	
CALL p_book_yes_no('IS200','C118','978-0-553-29698-2','E101');	

```





## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## Author - Kishan

