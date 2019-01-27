
----------------------------------- Data Defination Language ------------------------

-- CREATE TABLE queries

CREATE TABLE PEOPLE (
	id INTEGER NOT NULL,
    name VARCHAR(50) not NULL,
    AGE integer not null,
    sex varchar(10) not null,
    designation varchar(50) not null,
    PRIMARY KEY (id) );

-- CREATE TABLE queries with a foreign key constraint
CREATE TABLE PEOPLE (
	id INTEGER NOT NULL,
    CUSTID INTEGER NOT NULL,
    name VARCHAR(50) not NULL,
    AGE integer not null,
    sex varchar(10) not null,
    designation varchar(50) not null,
    PRIMARY KEY (id),
    CONSTRAINT FOREIGN KEY (CUSTID) REFERENCES table2 (CUSTID));


-- CREATING INDEXES INTO THE TABLE (Helps the query to run faster as it uses only index columns 
-- to find a value)

CREATE INDEX IDX ON PEOPLE USING (custid);


----------------------------------- Data Manipulation Language ---------------------------------

-- INSERT INTO queries

INSERT INTO PEOPLE
	(id, name, AGE, sex, designation)
    VALUES (1, "SHAKTI", 26, "M", "Student");

INSERT INTO PEOPLE
	(id, name, AGE, sex, designation)
    VALUES (2, "JAY", 21, "M", "Employed");



-- SELECT QUERIES examples
use invoices; -- Changing the database to the invoices database

-- Getting all rows from a table with a max value of a column
-- Approach 1 - Subquery
SELECT * FROM invoices WHERE 
	invoice_total = (SELECT MAX(invoice_total) FROM invoices);

-- Approach 2 - Order by
SELECT * FROM invoices ORDER BY invoice_total DESC LIMIT 1;


-- Getting Min and Max invoice totals for each distinct vendors
SELECT vendor_id, MIN(invoice_total), MAX(invoice_total) 
	FROM invoices GROUP BY vendor_id;


-- Simple Statistical functions

SELECT invoice_sequence, SUM(line_item_amt) as Total,
	AVG(line_item_amt) as Average, 
    MIN(line_item_amt) as Minimum, MAX(line_item_amt) as Maximum
    FROM invoice_line_items GROUP BY invoice_sequence;


-- Rounding the decimal places and using Variance and Standard Deviation
SELECT invoice_sequence, SUM(line_item_amt) as Total,
	ROUND(AVG(line_item_amt),2) as Average, 
    MIN(line_item_amt) as Minimum, MAX(line_item_amt) as Maximum,
    ROUND(VAR_POP(line_item_amt),2) as Variance, 
    ROUND(stddev(line_item_amt),2) as StandardDeviation
    FROM invoice_line_items GROUP BY invoice_sequence;



-- Concatenating the content of two columns (CONCAT function)
SELECT
	CONCAT(vendor_address1," , ", vendor_address2) Vendor_Full_Address
    FROM vendors WHERE vendor_address1 IS NOT NULL 
    AND vendor_address2 IS NOT NULL;


-- --------------------------------------------SUBQUERIES -------------------------------------------

-- SUBQUERY IN SELECT CLAUSE

-- Distinct vendors having total invoice amount greater than 1000
SELECT vendor_id, 
	(SELECT vendor_name FROM vendors v WHERE v.vendor_id = i.vendor_id) vendor_name, 
    count(invoice_id) Number_of_Invoices, invoice_total
    FROM invoices i GROUP BY vendor_id 
    HAVING invoice_total >1000 
    ORDER BY invoice_total DESC;


-- SUBQUERY IN 'FROM' CLAUSE & INNER JOIN

SELECT s1.vendor_id, s2.vendor_name, COUNT(s1.invoice_id) Number_of_Invoices, 
s1.invoice_total FROM 
	(SELECT vendor_id, invoice_id, invoice_total
	FROM invoices WHERE invoice_total > 1000) s1
INNER JOIN vendors s2 USING (vendor_id) 
GROUP BY s1.vendor_id ORDER BY invoice_total DESC;


-- CREATING A VIEW

CREATE VIEW top_vendors AS 
SELECT s1.vendor_id, s2.vendor_name, COUNT(s1.invoice_id) Number_of_Invoices, 
s1.invoice_total FROM 
	(SELECT vendor_id, invoice_id, invoice_total
	FROM invoices WHERE invoice_total > 1000) s1
INNER JOIN vendors s2 USING (vendor_id) 
GROUP BY s1.vendor_id ORDER BY invoice_total DESC;

-- SUBQUERY IN 'WHERE' CLAUSE USING THE VIEW CREATED
-- Getting the vendor having the highest total invoice amount

SELECT * FROM top_vendors
WHERE invoice_total = (SELECT MAX(invoice_total) from top_vendors);



-- --------------------------------------------JOINS------------------------------------------------- 

-- INNER JOIN
SELECT invoice_number,
		vendor_name, line_item_description, line_item_amt 
	FROM invoices AS i
	INNER JOIN vendors  AS v
	ON i.vendor_id = v.vendor_id
	INNER JOIN invoice_line_items AS il
	ON il.invoice_id = i.invoice_id;


-- LEFT OUTER JOIN
SELECT vendor_name, 
		SUM(invoice_total) AS total_invoice_amount
        FROM vendors AS v
        LEFT JOIN invoices AS i ON v.vendor_id = i.vendor_id
        GROUP BY vendor_name
        ORDER BY vendor_name;


-- --------------------------------------WINDOW FUNCTIONS----------------------------------

-- PARTITION BY
SELECT DISTINCT account_number, line_item_amt,
ROUND(AVG(line_item_amt) OVER (PARTITION BY account_number),2) AS 'Average Line Item Amount'
FROM invoice_line_items;

-- The same output as above using a subquery
SELECT account_number, line_item_amt, (select avg(p.line_item_amt) from invoice_line_items p
where p.account_number = i.account_number) as 'Average Line Item Amount'
from invoice_line_items i
group by account_number,line_item_amt order by account_number;

-- The same output as above using self joining
select i.account_number, i.line_item_amt, round(avg(p.line_item_amt),2) as 'Average Line Item Amount'
from invoice_line_items i
join invoice_line_items p on i.account_number = p.account_number
group by account_number, i.line_item_amt order by account_number;


-- RANK FUNCTION

SELECT DISTINCT account_number, line_item_description, line_item_amt,
RANK() OVER (PARTITION BY account_number ORDER BY line_item_amt DESC) Ranked
FROM invoice_line_items;

-- NTILE FUNCTION (CREATING BUCKETS)

SELECT DISTINCT account_number, line_item_description, line_item_amt,
NTILE(4) OVER (PARTITION BY account_number ORDER BY line_item_amt DESC) Ranked
FROM invoice_line_items;

