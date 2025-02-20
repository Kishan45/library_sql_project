--SQL Project library management system N2

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
                                         

/*
query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

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

/*
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/

SELECT * FROM 
books
WHERE isbn = '978-0-451-52994-2'

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2'

SELECT * FROM 
issued_status
WHERE issued_book_isbn = '978-0-451-52994-2'

SELECT * FROM 
return_status 
WHERE issued_id = 'IS130'

/* Actually here we can add return books manually  by insert statement and then update id manually 
in book table but we are not doing that,
Instead we are using store procedure
*/

-- STORE PROCEDURE

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

/*
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/

--total no of book issued
--CTAS

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

/*
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.*/


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
	
--OR

SELECT *
FROM
members
WHERE member_id IN (
SELECT 
	issued_member_id
FROM
	issued_status
WHERE 
	issued_date >= CURRENT_DATE - INTERVAL '2 month'
)

/*
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

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


SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

/*
 Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
 Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
 The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
 The procedure should first check if the book is available (status = 'yes'). 
 If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
 If the book is not available (status = 'no'), 
 the procedure should return an error message indicating that the book is currently not available.
 */


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