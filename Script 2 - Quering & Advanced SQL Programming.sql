/* This is a script for querying the database, manipulating its data and using advanced programming in order to achieve different objectives */

USE Library;

####################################################################################
############################## QUERYING THE DATABASE ###############################
####################################################################################

###############################################################################
############################## SQL DATA QUERY 1 ###############################
###############################################################################

# This query shows all books and their authors.

SELECT GROUP_CONCAT(Author.AuthorID SEPARATOR ', ') AS AuthorIds,
       GROUP_CONCAT(CONCAT(Author.FirstName,' ', Author.LastName) SEPARATOR ', ') AS AuthorNames,
       Writes.BookID,
       Book.Title BookTitle
FROM Writes
JOIN Author on Writes.AuthorID = Author.AuthorID
JOIN Book on Writes.BookID = Book.BookID
GROUP BY Writes.BookID;

###############################################################################
############################## SQL DATA QUERY 2 ###############################
###############################################################################

# This query shows the number of books the Library has from each author. Shows the author with the most books first, and so on.

SELECT   Author.AuthorID,
         CONCAT(Author.FirstName,' ', Author.LastName) AS FullName,
         COUNT(*) AS NumberOfBooks
FROM     Author
JOIN     Writes ON Author.AuthorID = Writes.AuthorID
GROUP BY FullName
ORDER BY NumberOfBooks DESC;

###############################################################################
############################## SQL DATA QUERY 3 ###############################
###############################################################################

# This query gives an overview of all loans for each library user and the status of these.

SELECT LibraryUser.UserID,
        CONCAT(LibraryUser.FirstName,' ', LibraryUser.LastName) AS FullName,
       SUM(LoanedStatus LIKE 'LOANED') AS ActiveLoans,
       SUM(LoanedStatus LIKE 'RETURNED') AS Returned,
       SUM(LoanedStatus LIKE 'FINED') AS Fined,
       COUNT(*) AS Total
FROM LibraryUser
JOIN Loans on LibraryUser.UserID = Loans.UserID
GROUP BY UserID;



#######################################################################################
############################## ADVANCED SQL PROGRAMMING ###############################
#######################################################################################

#######################################################################
############################## FUNCTION ###############################
#######################################################################

DROP FUNCTION IF EXISTS LoanedQuantity;

DELIMITER //
CREATE FUNCTION LoanedQuantity(vBookID INTEGER) RETURNS INTEGER
BEGIN
    DECLARE LoanedQuantity INTEGER DEFAULT 0;
    SELECT COUNT(*) INTO LoanedQuantity FROM Loans L
    WHERE L.BookID = vBookID AND L.LoanedStatus != 'RETURNED' GROUP BY BookID;
    RETURN LoanedQuantity;
END //
DELIMITER ;

# Testing the function:

SELECT Title, TotalQuantity, LoanedQuantity(BookID) AS LoanedQuantity
FROM Book;


########################################################################
############################## PROCEDURE ###############################
########################################################################

DROP PROCEDURE IF EXISTS LoanBook;

DELIMITER //
CREATE PROCEDURE LoanBook(IN vUserID INTEGER, IN vBookID INTEGER)
BEGIN
    INSERT Loans(UserID, BookID, LoanedDate, UntilDate, ReturnedDate, LoanedStatus)
        VALUES (vUserID, vBookID, NOW(), ADDDATE(CURDATE(), INTERVAL 30 DAY), NULL, 'LOANED');
END //
DELIMITER ;

# Testing the procedure:

# BEFORE:
SELECT B.Title, L.LoanedDate, L.UntilDate, L.LoanedStatus
FROM Book B
NATURAL JOIN Loans L
WHERE L.UserID = 4;

# CALLING THE PROCEDURE:
CALL LoanBook(4, 1);

# AFTER:
SELECT B.Title, L.LoanedDate, L.UntilDate, L.LoanedStatus
FROM Book B
NATURAL JOIN Loans L
WHERE L.UserID = 4;


#########################################################################################
############################## PROCEDURE WITH TRANSACTION ###############################
#########################################################################################

DROP PROCEDURE IF EXISTS CreateFines;

DELIMITER //
CREATE PROCEDURE CreateFines()
BEGIN
    START TRANSACTION;
        INSERT INTO Fine (UserID, Amount, IssuedDate, PaymentStatus)
            SELECT UserID, 100.00, CURDATE(), 'NOT PAID' FROM Loans L
            WHERE L.LoanedStatus = 'LOANED' AND DATEDIFF(L.UntilDate, CURDATE()) < 0;

        UPDATE Loans L SET LoanedStatus = 'FINED'
        WHERE L.LoanedStatus = 'LOANED' AND DATEDIFF(L.UntilDate, CURDATE()) < 0;
    COMMIT;
END; //
DELIMITER ;

# Testing the procedure with transaction:

# BEFORE:
SELECT B.Title, L.LoanedDate, L.UntilDate, L.LoanedStatus
FROM Book B
NATURAL JOIN Loans L
WHERE L.UserID = 4;

SELECT * FROM Fine F WHERE F.UserID = 4;

# CREATE TEST CONDITIONS:
UPDATE Loans L SET L.LoanedDate = ADDDATE(CURDATE(), -40)
WHERE L.UserID = 4 AND L.BookID = 1;

UPDATE Loans L SET L.UntilDate = ADDDATE(CURDATE(), -10)
WHERE L.UserID = 4 AND L.BookID = 1;

# CALLING THE PROCEDURE:
CALL CreateFines();

# AFTER:
SELECT B.Title, L.LoanedDate, L.UntilDate, L.LoanedStatus
FROM Book B
NATURAL JOIN Loans L
WHERE L.UserID = 4;

SELECT * FROM Fine F WHERE F.UserID = 4;


######################################################################
############################## TRIGGER ###############################
######################################################################

DROP TRIGGER IF EXISTS Loans_Before_INSERT;

DELIMITER //
CREATE TRIGGER Loans_Before_INSERT
BEFORE INSERT ON Loans FOR EACH ROW
BEGIN
	DECLARE LoanedQuantity, TotalQuantity, ActiveLoansOfBook INTEGER DEFAULT 0;
	SELECT LoanedQuantity(NEW.BookID) INTO LoanedQuantity;
	SELECT B.TotalQuantity INTO TotalQuantity FROM Book B WHERE B.BookID = NEW.BookID;
	IF (LoanedQuantity >= TotalQuantity)
		THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Book not available to loan';
	END IF;
	SELECT COUNT(*) INTO ActiveLoansOfBook FROM Loans L
	WHERE L.BookID = NEW.BookID AND L.UserID = NEW.UserID AND L.LoanedStatus != 'RETURNED'
	GROUP BY L.BookID;
	IF (ActiveLoansOfBook != 0)
		THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'User already loaned book';
	END IF;
END; //
DELIMITER ;

# Testing Trigger by calling the previous procedure:

CALL LoanBook(4, 2); 
# CALL LoanBook(4, 2); Error (already loaned)
CALL LoanBook(6, 2);
CALL LoanBook(1, 2);
# CALL LoanBook(2, 2); Error (no books left)


####################################################################
############################## EVENT ###############################
####################################################################

SET GLOBAL event_scheduler = 1;
DROP EVENT IF EXISTS CreateFinesEvent;

DELIMITER //
CREATE EVENT CreateFinesEvent ON SCHEDULE EVERY 1 DAY 
DO
BEGIN
	CALL CreateFines();
END; //
DELIMITER ;

# SET GLOBAL event_scheduler = 0;


######################################################################################
############################## SQL TABLE MODIFICATIONS ###############################
######################################################################################

#################################################################################
############################## SQL UPDATE COMMAND ###############################
#################################################################################

# The library decides to buy more copies of a book that's seeing particularly high demand among library users

SET SQL_SAFE_UPDATES = 0;

# BEFORE:
SELECT * FROM BOOK;

UPDATE Book SET TotalQuantity = 10
WHERE Title = 'Database System Concepts, Sixth Edition';

# AFTER:
SELECT * FROM BOOK;


#################################################################################
############################## SQL DELETE COMMAND ###############################
#################################################################################

# Say a library user wants to be deleted from the database, 
# and because of GDPR, the library obliges to do so, 
# as long as the user doesn't have any unpaid fines

# This user does not have any active fines, therefore it will be deleted
DELETE FROM LibraryUser
WHERE LoanerNumber = '154399'
AND NOT EXISTS
(SELECT FineID
FROM Fine LEFT JOIN LibraryUser
ON LibraryUser.UserID = Fine.UserID
WHERE LoanerNumber = '154399' AND PaymentStatus = 'NOT PAID');


# This user has outstanding fines, therefore it will not be removed from the database
DELETE FROM LibraryUser
WHERE LoanerNumber = '203442'
AND NOT EXISTS
(SELECT FineID
FROM Fine LEFT JOIN LibraryUser
ON LibraryUser.UserID = Fine.UserID
WHERE LoanerNumber = '203442' AND PaymentStatus = 'NOT PAID');

