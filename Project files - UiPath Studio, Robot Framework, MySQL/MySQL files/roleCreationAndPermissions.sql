-- Creating a user
CREATE USER 'robotuser'@'localhost' IDENTIFIED BY 'password';

-- Creating the role
CREATE ROLE robotrole;

-- Granting role to user
GRANT robotrole to 'robotuser'@'localhost';

-- Set role to be enabled by default when logging in 
SET DEFAULT ROLE ALL TO 'robotuser'@'localhost';

-- Granting permissions
USE rpa;
GRANT SELECT, INSERT, UPDATE ON invoiceheader TO robotrole;
GRANT SELECT, INSERT, UPDATE ON invoicerow TO robotrole;
GRANT SELECT ON invoicestatus TO robotrole;

SELECT * FROM invoicestatus;
SELECT * FROM invoiceheader;
SELECT * FROM invoicerow;

DELETE FROM invoiceheader;
DELETE FROM invoicerow;