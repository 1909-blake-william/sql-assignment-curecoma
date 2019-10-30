--1.0 Setting up Oracle Chinook
--In this section you will begin the process of working with the Oracle Chinook database
--Task ?Open the Chinook_Oracle.sql file and execute the scripts within.
--2.0 SQL Queries
--In this section you will be performing various queries against the Oracle Chinook database.
--2.1 SELECT
--Task ?Select all records from the Employee table.
SELECT * FROM EMPLOYEE;
--Task ?Select all records from the Employee table where last name is King.
SELECT * FROM EMPLOYEE WHERE LASTNAME = 'King';
--Task ?Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM EMPLOYEE WHERE FIRSTNAME = 'Andrew' AND REPORTSTO IS NULL;
--2.2 ORDER BY
--Task ?Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM ALBUM ORDER BY TITLE DESC;
--Task ?Select first name from Customer and sort result set in ascending order by city
SELECT FIRSTNAME FROM CUSTOMER ORDER BY CITY ASC;
--2.3 INSERT INTO
--Task ?Insert two new records into Genre table
INSERT INTO genre VALUES (25, 'Breakcore'); 
INSERT INTO genre VALUES (30, 'Mashcore'); 
--Task ?Insert two new records into Employee table
/
INSERT INTO employee 
VALUES (50,'Shinohara','Takumi','Manager',1,'05-APR-96','01-MAY-16','69 Greenview Lane','Bath','NC','USA','27808','252-945-5784',NULL,'takumi@mail.com');
/
INSERT INTO employee(EMPLOYEEID,LASTNAME,FIRSTNAME)
VALUES (100,'Shinohara','Satoru');
/
--Task ?Insert two new records into Customer table
INSERT INTO customer VALUES (1000,'Ageha','Trivane','Amazon','55 spring drive','Wilmington','VA','USA','19198','555-555-5555','n/a','ageha@mail.net',5);
INSERT INTO customer VALUES (1001,'Tronto','Tororo','Bobs shop','10 Applefield St','Pikachu','HW','USA','77227','555-555-5555','n/a','tororoto@mail.net',4);
--2.4 UPDATE
--Task ?Update Aaron Mitchell in Customer table to Robert Walter
UPDATE CUSTOMER SET firstname = 'Robert', lastname = 'Walter'
WHERE firstname = 'Aaron' AND lastname = 'Mitchell';
--Task ?Update name of artist in the Artist table ?reedence Clearwater Revival?to ?CR?
UPDATE artist SET artist = 'CCR'
WHERE artist = 'Creedence Clearwater Revival';
--2.5 LIKE
--Task ?Select all invoices with a billing address like ?%?
SELECT * FROM invoice WHERE BILLINGADDRESS LIKE 'T%'; 
--2.6 BETWEEN
--Task ?Select all invoices that have a total between 15 and 50
SELECT * FROM invoice WHERE total BETWEEN 15 AND 50;
--Task ?Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee WHERE hiredate BETWEEN '01-JUN-03' AND '01-MAR-04';
--2.7 DELETE
--Task ?Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM customer CASCADE WHERE firstname = 'Robert' AND lastname = 'Walter';
--cascading deletes
--3.0 SQL Functions
--In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
--3.1 System Defined Functions
--Task ?Create a function that returns the current time.
SELECT TO_CHAR (SYSDATE, 'MM-DD-YYYY HH24:MI:SS') "NOW" FROM DUAL;
--Task ?create a function that returns the length of a mediatype from the mediatype table
SELECT COUNT (mediatypeid) FROM mediatype;
--3.2 System Defined Aggregate Functions
--Task ?Create a function that returns the average total of all invoices
SELECT AVG(total) FROM invoice;
--Task ?Create a function that returns the most expensive track
SELECT MAX(unitprice) FROM TRACK;
--3.3 User Defined Scalar Functions
--Task ?Create a function that returns the average price of invoiceline items in the invoiceline table
/
CREATE OR REPLACE FUNCTION average_inv
RETURN number IS
average number;
BEGIN
    SELECT AVG(i.unitprice)
    into average
    FROM invoiceline i;
    RETURN average;
END;
--3.4 User Defined Table Valued Functions
--Task ?Create a function that returns all employees who are born after 1968.

/
CREATE OR REPLACE FUNCTION emp1968 
(bd IN DATE)
RETURN SYS_REFCURSOR
AS
my_cursor sys_refcursor;
BEGIN
   OPEN my_cursor FOR
   SELECT * FROM employee
   WHERE birthdate >= bd;
   RETURN my_cursor;
END;
/
SELECT emp1968('01-JAN-68') FROM DUAL;
/
SET SERVEROUTPUT ON;
DECLARE
   EMPLOYEEID	NUMBER;    LASTNAME	VARCHAR2(20 BYTE);    FIRSTNAME	VARCHAR2(20 BYTE);
    TITLE	VARCHAR2(30 BYTE);    REPORTSTO	NUMBER;    BIRTHDATE	DATE;
    HIREDATE	DATE;    ADDRESS	VARCHAR2(70 BYTE);    CITY	VARCHAR2(40 BYTE);
    STATE	VARCHAR2(40 BYTE);    COUNTRY	VARCHAR2(40 BYTE);    POSTALCODE	VARCHAR2(10 BYTE);
    PHONE	VARCHAR2(24 BYTE);    FAX	VARCHAR2(24 BYTE);    EMAIL	VARCHAR2(60 BYTE);    my_cursor sys_refcursor;
BEGIN
   MY_CURSOR := emp1968('01-JAN-68');
   LOOP
       FETCH my_cursor INTO employeeid,LASTNAME,FIRSTNAME,TITLE,REPORTSTO,BIRTHDATE,HIREDATE,ADDRESS,CITY,STATE,COUNTRY,POSTALCODE,PHONE,FAX,EMAIL;
       EXIT WHEN my_cursor%notfound;
       dbms_output.put_line(employeeid|| ' | ' ||LASTNAME|| ' | ' ||FIRSTNAME|| ' | ' ||TITLE|| ' | ' ||REPORTSTO|| ' | ' ||BIRTHDATE|| ' | ' ||HIREDATE|| ' | ' ||ADDRESS|| ' | ' ||CITY|| ' | ' ||STATE|| ' | ' ||COUNTRY|| ' | ' ||POSTALCODE|| ' | ' ||PHONE|| ' | ' ||FAX|| ' | ' ||EMAIL);
   END LOOP;
END;
/--4.33 PM 10/29
--4.0 Stored Procedures
-- In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
--4.1 Basic Stored Procedure
--Task ?Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE PROCEDURE fullname
(c_out OUT sys_refcursor)
AS
BEGIN
   OPEN c_out FOR
   SELECT  FirstName, LastName
   FROM    Employee;
END;
/
SET     SERVEROUTPUT ON
DECLARE c_out sys_refcursor;
       first_name varchar2(20);
       last_name varchar2(20);
BEGIN
   fullname(c_out);
   LOOP
       FETCH c_out
       INTO  first_name, last_name;
       EXIT WHEN c_out%NOTFOUND;
   DBMS_OUTPUT.PUT_LINE(first_name || ' ' || last_name);
 END LOOP;
 CLOSE c_out;
END;
/

--4.2 Stored Procedure Input Parameters
--Task ?Create a stored procedure that updates the personal information of an employee.

CREATE OR REPLACE PROCEDURE update_employee
(eid IN number,newlastname IN varchar2,newtitle IN varchar2,newaddress IN varchar2,
newcity IN varchar2,newstates IN varchar2,newnation IN varchar2,newpostal IN varchar2,
newphone  IN varchar2,newfax IN varchar2,newemail IN varchar2)
IS
BEGIN
    UPDATE EMPLOYEE 
    SET lastname = newlastname, title=newtitle, address = newaddress, city = newcity, state = newstates,
        COUNTRY = newnation, postalcode = newpostal, phone = newphone, fax = newfax, email = newemail
    WHERE employeeID = eid;
END;
/
--Task ?Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE PROCEDURE manager_name
(c_out OUT sys_refcursor)
AS
BEGIN
   OPEN c_out FOR
   SELECT  em1.firstName, em1.lastName, em2.firstname, em2.lastname
   FROM employee em1 LEFT JOIN employee em2 ON em1.reportsto = em2.employeeid
   WHERE em1.reportsto IS NOT NULL;
END;
/
SET     SERVEROUTPUT ON
DECLARE c_out sys_refcursor;
       first_emp varchar2(20);
       last_emp varchar2(20);
       first_man varchar2(20);
       last_man varchar2(20);
BEGIN
   manager_name(c_out);
   LOOP
       FETCH c_out
       INTO  first_emp, last_emp,first_man,last_man;
       EXIT WHEN c_out%NOTFOUND;
   DBMS_OUTPUT.PUT_LINE(first_emp || ' ' || last_emp || ' reports to ' || first_man || ' '  || last_man);
 END LOOP;
 CLOSE c_out;
END;
/


--4.3 Stored Procedure Output Parameters
--Task ?Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE PROCEDURE company_and_name
(c_out OUT sys_refcursor)
AS
BEGIN
   OPEN c_out FOR
   SELECT  firstname, lastname, company
   FROM customer ;
END;
/
SET     SERVEROUTPUT ON
DECLARE c_out sys_refcursor;
       fn varchar2(20);
       ln varchar2(20);
       comp varchar2(70);
BEGIN
   company_and_name(c_out);
   LOOP
       FETCH c_out
       INTO  fn, ln, comp;
       EXIT WHEN c_out%NOTFOUND;
   DBMS_OUTPUT.PUT_LINE(fn || ' ' || ln || ' is from company ' || comp);
 END LOOP;
 CLOSE c_out;
END;
/



--6.0 Triggers
--In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE OR REPLACE TRIGGER after_insert
AFTER INSERT
   ON employee
   FOR EACH ROW
DECLARE
BEGIN
   DBMS_OUTPUT.PUT_LINE('stuff has been inserted');
END;
/
--Task ?Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE OR REPLACE TRIGGER after_update
AFTER UPDATE
   ON album
   FOR EACH ROW
DECLARE
BEGIN
   DBMS_OUTPUT.PUT_LINE('stuff has been updated');
END;
/
--Task ?Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE OR REPLACE TRIGGER after_delete
AFTER DELETE
   ON customer
   FOR EACH ROW
DECLARE
BEGIN
   DBMS_OUTPUT.PUT_LINE('stuff has been deleted');
END;
/
--Task ?Create a trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE OR REPLACE TRIGGER after_delete_50
AFTER DELETE
   ON invoice
   FOR EACH ROW
DECLARE
BEGIN
    IF :OLD.total >=50 THEN
        DBMS_OUTPUT.PUT_LINE('stuff above $50 has been deleted');
    end if;
END;
/
--7.0 JOINS
--In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
--7.1 INNER
--Task ?Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
   SELECT cu.Firstname, cu.lastname, invoiceid FROM customer cu INNER JOIN invoice inv ON cu.customerid = inv.customerid;
/
--7.2 OUTER
--Task ?Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT cu.customerID, cu.Firstname, cu.lastname, inv.invoiceid, inv.total FROM customer cu FULL OUTER JOIN invoice inv ON cu.customerid = inv.customerid;
/
--7.3 RIGHT
--Task ?Create a right join that joins album and artist specifying artist name and title.
SELECT  alb.title, art.name
   FROM album alb right JOIN artist art ON alb.artistid = art.artistid;
/
--7.4 CROSS
--Task ?Create a cross join that joins album and artist and sorts by artist name in ascending order.
   SELECT  alb.title, art.name FROM album alb CROSS JOIN artist art ORDER BY art.name ASC;
/
--7.5 SELF
--Task ?Perform a self-join on the employee table, joining on the reportsto column.
   SELECT  em1.firstName, em1.lastName, em2.firstname, em2.lastname
   FROM employee em1 LEFT JOIN employee em2 ON em1.reportsto = em2.employeeid
/