/* This is a script for creating the Library database, its tables and views, and for populating them with data */

# Drop the database and tables, if they exist

##################################################################################
############################# CREATING THE DATABASE ##############################
##################################################################################

DROP DATABASE IF EXISTS Library;
CREATE DATABASE Library;
USE Library;

##################################################################################
############################## CREATING THE TABLES ###############################
############################## FOR THE ENTITY SETS ###############################
##################################################################################


# Here, we will first create the tables for all the necessary Entity Sets:

CREATE TABLE LibraryUser (
	UserID		    INTEGER NOT NULL UNIQUE AUTO_INCREMENT,
	FirstName		VARCHAR(255) NOT NULL,
    LastName		VARCHAR(255) NOT NULL,
	BirthDate		DATE NOT NULL,
    LoanerNumber 	VARCHAR(6) NOT NULL UNIQUE,
    UserStatus		ENUM('ACTIVE', 'TERMINATED', 'BLOCKED') NOT NULL,		# Can be ACTIVE, TERMINATED, or BLOCKED

	PRIMARY KEY(UserID)
);

CREATE TABLE Author (
	AuthorID		INTEGER NOT NULL UNIQUE AUTO_INCREMENT,
	FirstName		VARCHAR(255) NOT NULL,
    LastName		VARCHAR(255) NOT NULL,
	Nationality    	VARCHAR(255),

	PRIMARY KEY(AuthorID)
);

CREATE TABLE Genre (
	GenreID 		INTEGER NOT NULL UNIQUE AUTO_INCREMENT,
	GenreType 		VARCHAR(255) NOT NULL,
    GenreSubtype 	VARCHAR(255) NOT NULL,

	PRIMARY KEY(GenreID)
);

CREATE TABLE Publisher (
	PublisherID		INTEGER NOT NULL UNIQUE AUTO_INCREMENT,
	PublisherName	VARCHAR(255) NOT NULL UNIQUE,
	HQCountry 		VARCHAR(255),

	PRIMARY KEY(PublisherID)
);

CREATE TABLE Book (
    BookID		    INTEGER NOT NULL UNIQUE AUTO_INCREMENT,
	Title		    VARCHAR(255) NOT NULL,
	ReleaseYear    	YEAR,
    PageCount		INTEGER,
	TotalQuantity   INTEGER NOT NULL,
	TextLanguage    VARCHAR(255),
    PublisherID		INTEGER,
    GenreID			INTEGER,

	PRIMARY KEY(BookID),
	FOREIGN KEY(PublisherID) REFERENCES Publisher(PublisherID) ON DELETE CASCADE,
    FOREIGN KEY(GenreID) REFERENCES Genre(GenreID) ON DELETE CASCADE
);

CREATE TABLE Fine (
	FineID			INTEGER NOT NULL UNIQUE AUTO_INCREMENT,
	Amount			DECIMAL(8, 2) NOT NULL,
    UserID			INTEGER NOT NULL,
    IssuedDate		DATE NOT NULL,
    PaymentStatus	ENUM('PAID', 'NOT PAID') NOT NULL,		# Can be PAID or NOT PAID

	PRIMARY KEY(FineID),
	FOREIGN KEY(UserID) REFERENCES LibraryUser(UserID) ON DELETE CASCADE
);


##################################################################################
############################## CREATING THE TABLES ###############################
####################### FOR THE MANY-TO-MANY RELATIONSHIPS #######################
##################################################################################


# Now, we will create the tables for all the necessary many-to-many Relationship Sets:

CREATE TABLE Loans (
	UserID			INTEGER NOT NULL,
	BookID		    INTEGER NOT NULL,
	LoanedDate   	DATE NOT NULL,
    UntilDate   	DATE NOT NULL,										# Must always be 30 days after the LoanedDate
    ReturnedDate	DATE,
	LoanedStatus 	ENUM('LOANED', 'FINED', 'RETURNED') NOT NULL,		# Can be LOANED, FINED, or RETURNED

	PRIMARY KEY(UserID, BookID, LoanedDate),
	FOREIGN KEY(UserID) REFERENCES LibraryUser(UserID) ON DELETE CASCADE,
	FOREIGN KEY(BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);

CREATE TABLE Reserves (
	UserID			INTEGER NOT NULL,
	BookID		    INTEGER NOT NULL,
    ReservedDate   	DATE NOT NULL,
    ReservedStatus 	ENUM('RESERVED', 'CANCELLED', 'COMPLETED') NOT NULL,  # Can be RESERVED, CANCELLED OR COMPLETED

	PRIMARY KEY(UserID, BookID, ReservedDate),
	FOREIGN KEY(UserID) REFERENCES LibraryUser(UserID) ON DELETE CASCADE,
	FOREIGN KEY(BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);

CREATE TABLE Writes (
	AuthorID		INT NOT NULL,
    BookID			INT NOT NULL,

    PRIMARY KEY(AuthorID, BookID),
    FOREIGN KEY(AuthorID) REFERENCES Author(AuthorID) ON DELETE CASCADE,
	FOREIGN KEY(BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);


##################################################################################
############################## CREATING THE VIEWS ###############################
##################################################################################

# Drop views, if they exist
DROP VIEW IF EXISTS BookAuthorsView;
DROP VIEW IF EXISTS TotalAmountDueView;


# Create the necessary views

CREATE VIEW BookAuthorsView AS
    SELECT B.BookId, B.Title, GROUP_CONCAT(CONCAT(A.FirstName, ' ', A.LastName) SEPARATOR ', ') AS Author
    FROM Book B
        NATURAL JOIN Writes W
        NATURAL JOIN Author A
    GROUP BY B.BookId;


CREATE VIEW TotalAmountDueView AS
    SELECT U.UserId, CONCAT(U.FirstName, ' ', U.LastName) AS Name, SUM(F.Amount) AS Total
    FROM LibraryUser U
        NATURAL JOIN Fine F
    WHERE F.PaymentStatus = 'NOT PAID'
    GROUP BY U.UserId;

#####################################################################################
############################ POPULATING THE ENTITY SETS #############################
#####################################################################################

INSERT LibraryUser (UserID, FirstName, LastName, BirthDate, LoanerNumber, UserStatus) VALUES
(1, 'Sule', 	 'Altintas',  '1995-08-30', '154399', 'ACTIVE'),		# The jewel of the group, ermmm... I meant crown!
(2, 'Fahad', 	 'Sajad', 	  '1990-05-09', '160344', 'ACTIVE'),		# Our kind second group member
(3, 'Sebastian', 'Sbirna', 	  '1997-05-04', '190553', 'ACTIVE'),		# That's him alright
(4, 'Kåre',		 'Jørgensen', '1994-05-09', '144852', 'ACTIVE'),		# Yup, our only Kåre
(5, 'Mary', 	 'Little', 	  '2013-05-07', '100115', 'ACTIVE'),		# Mary Little is too little to read books suitable for a grown-up audience
(6, 'Humphrey',  'Oldman', 	  '1942-01-01', '997953', 'TERMINATED'), 	# Humphrey Oldman is so retired that he retired his library account as well :)
(7, 'Billy', 	 'Bully', 	  '2007-04-25', '203442', 'BLOCKED');  		# Billy Bully didn't bring back his books :)

INSERT Publisher (PublisherID, PublisherName, HQCountry) VALUES
(1, 'Klim', 			 	'Denmark'),
(2, 'Samleren', 			'Denmark'),
(3, 'Lindhardt og Ringhof',	'Denmark'),
(4, 'Gyldendal', 			'Denmark'),
(5, 'Textmaster', 			'USA'),
(6, 'McGraw-Hill', 		 	'USA'),
(7, 'Faber and Faber', 	 	'United Kingdom');

# For inserting Genres into the database, we used the following website as source reference:
# https://reference.yourdictionary.com/books-literature/different-types-of-books.html
INSERT Genre (GenreID, GenreType, GenreSubtype) VALUES
(1, 'Fiction', 		'Romance'),
(2, 'Fiction', 		'Horror'),
(3, 'Fiction', 		'Thriller'),
(4, 'Fiction', 		'Science Fiction'),
(5, 'Non-fiction', 	'Guide'),
(6, 'Non-fiction', 	'Textbook'),
(7, 'Fiction', 		'Crime'),
(8, 'Fiction', 		'Fantasy'),
(9, 'Non-fiction', 	'Prayer');

INSERT Book (BookID, Title, ReleaseYear, PageCount, TotalQuantity, TextLanguage, PublisherID, GenreID) VALUES
(1, 'Kafka på stranden', 						'2007', 505, 	5,  'Danish',  1,	4),
(2, '1Q84', 									'2011', 928, 	4,  'Danish',  1,	1),
(3, 'Rødby-Puttgarden', 						'2011', NULL, 	1,  'Danish',  2,	3),
(4, 'Maigret', 									'2017', 144, 	10, 'Danish',  3,	7),
(5, 'Windows 8.1 - Effektiv uden touch', 		'2014', 255, 	1,  'Danish',  5,	5),
(6, 'Database System Concepts, Sixth Edition',	'2010', 1349, 	5,  'English', 6,	6),
(7, 'The New Tork Trilogy', 					'1985', 478, 	2,  'English', 7,	7);

INSERT Author (AuthorID, FirstName, LastName, Nationality) VALUES
(1, 'Haruki', 	'Murakami', 	'Japan'),
(2, 'Helle', 	'Helle', 		'Denmark'),
(3, 'Ernest', 	'Hemingsway', 	'USA'),
(4, 'Georges', 	'Simenon', 		'Belgium'),
(5, 'Martin', 	'Simon', 		'Denmark'),
(6, 'Avi',		'Silberschatz', 'USA'),
(7, 'Henry', 	'Korth', 		'USA'),
(8, 'S.', 		'Sudarshan', 	'USA'),
(9, 'Paul',		'Auster', 		'USA');

INSERT Fine (FineID, Amount, UserID, IssuedDate, PaymentStatus) VALUES
(1, 100.00, 7, '2019-09-17', 'NOT PAID'),
(2, 100.00, 7, '2019-10-20', 'NOT PAID'),
(3, 100.00, 7, '2019-12-14', 'NOT PAID');

#######################################################################################
############################ POPULATING THE RELATIONSHIPS #############################
#######################################################################################

INSERT Loans (UserID, BookID, LoanedDate, UntilDate, ReturnedDate, LoanedStatus) VALUES
(5, 4, '2019-01-05', TIMESTAMPADD(DAY, 30, '2019-01-05'), '2019-01-24', 	'RETURNED'),
(5, 3, '2019-01-17', TIMESTAMPADD(DAY, 30, '2019-01-17'), '2019-02-13', 	'RETURNED'),
(7, 4, '2019-08-17', TIMESTAMPADD(DAY, 30, '2019-08-17'),	NULL, 			'FINED'),
(7, 7, '2019-09-20', TIMESTAMPADD(DAY, 30, '2019-09-20'),	NULL, 			'FINED'),
(7, 2, '2019-11-14', TIMESTAMPADD(DAY, 30, '2019-11-14'),	NULL, 			'FINED'),
(1, 6, '2020-03-29', TIMESTAMPADD(DAY, 30, '2020-03-29'),	NULL, 			'LOANED'),
(2, 6, '2020-03-29', TIMESTAMPADD(DAY, 30, '2020-03-29'),	NULL, 			'LOANED'),
(3, 6, '2020-03-29', TIMESTAMPADD(DAY, 30, '2020-03-29'),	NULL, 			'LOANED'),
(4, 6, '2020-03-29', TIMESTAMPADD(DAY, 30, '2020-03-29'),	NULL, 			'LOANED'),
(3, 5, '2020-03-12', TIMESTAMPADD(DAY, 30, '2020-03-12'),	NULL, 			'LOANED');

INSERT Reserves (UserID, BookID, ReservedDate, ReservedStatus) VALUES
(2, 5, '2020-03-20', 'RESERVED');

INSERT Writes (AuthorID, BookID) VALUES
(1, 1),
(1, 2),
(2, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 6),
(8, 6),
(9, 7);


#########################################################################################
############################ SHOWING THE RELATION INSTANCES #############################
############################### USING SQL SELECT QUERIES ################################
#########################################################################################

SELECT * FROM LibraryUser;
SELECT * FROM Author;
SELECT * FROM Genre;
SELECT * FROM Publisher;
SELECT * FROM Book;
SELECT * FROM Fine;

SELECT * FROM Loans;
SELECT * FROM Reserves;
SELECT * FROM Writes;

SELECT * FROM BookAuthorsView;
SELECT * FROM TotalAmountDueView;
 
