-- added new item to book table

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

--update the existing record
SELECT * FROM members;

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

SELECT * FROM members

--DELETE a record
SELECT * FROM issued_status;
SELECT * FROM return_status;


DELETE FROM issued_status
WHERE issued_id = 'IS140';
SELECT * FROM issued_status;

--Retrieve all book issued by the employee with employee id = 'E101'
SELECT * FROM issued_status

SELECT 
	issued_emp_id,
	issued_book_name
FROM
	issued_status
WHERE issued_emp_id = 'E101'

--retrieve data of a member who have more than 1 book issued

SELECT 
	issued_member_id, 
	COUNT(issued_book_name) as issued_book
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_book_name) >1


--create summary table: use CTAS to generate new table based on query results - each book and total book issued count
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

--Retrieve all book in specific category

SELECT 
	category, 
	book_title 
FROM books
GROUP BY category,book_title
ORDER BY 1

--TOTAL Rental income by each category
SELECT 
	category, 
	SUM(rental_price) 
FROM books
GROUP BY category

--List member who registered in last 360 days
SELECT 
	member_name,
	reg_date,
FROM
	members
WHERE  (CURRENT_DATE - reg_date) < 360  -- today 19/02/2025

--List the employees with branch manager name and address details

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

-- create a seperate table who's rental price is above 6$
CREATE TABLE abv_6_rent
AS
(
	SELECT 
		*
	FROM
		books
	WHERE rental_price > 6
)	
	
--Retreive list of book not yet returned
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

