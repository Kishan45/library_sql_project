-- Library manangement system project 2

DROP TABLE IF EXISTS branch; 

CREATE TABLE branch
(
	branch_id VARCHAR(6) PRIMARY KEY,
	manager_id	VARCHAR(6),
	branch_address	TEXT,
	contact_no NUMERIC(12)

);

DROP TABLE IF EXISTS employees; 
CREATE TABLE employees
(
	emp_id	VARCHAR(6) PRIMARY KEY,
	emp_name VARCHAR(35),
	position VARCHAR(20),	
	salary	NUMERIC(10),
	branch_id VARCHAR(6)      --FK
);

DROP TABLE IF EXISTS books; 

CREATE TABLE books
(
	isbn VARCHAR(20) PRIMARY KEY,
	book_title	VARCHAR(70),
	category VARCHAR(25),
	rental_price NUMERIC(1,2),
	status	VARCHAR(10),
	author	VARCHAR(35),
	publisher VARCHAR(55)
)

ALTER TABLE books
ALTER COLUMN rental_price type float

DROP TABLE IF EXISTS members; 

CREATE TABLE members
(
	member_id	VARCHAR(10) PRIMARY KEY,	
	member_name	VARCHAR(35),
	member_address	TEXT,
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


--Foreign KEY

ALTER TABLE return_status
ADD CONSTRAINT fk_return
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_return2
FOREIGN KEY (return_book_isbn) 
REFERENCES books(isbn);

ALTER TABLE return_status
DROP CONSTRAINT fk_return2

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued1
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued2
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued3
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_emp1
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

--



