## Database Design, Modeling and Programming of a National Library Catalog System
### _By Sebastian Sbirna, Kåre Jørgensen, Fahad Sajad & Şule Altıntaş_
---

## **Table of Contents:**

[**1.** **Statement of Requirements**](#statement-of-requirements)

[**2.** **Conceptual Design**](#conceptual-design)

[**3.** **Logical Design**](#logical-design)

[**4.** **Normalization**](#normalization)

[**5.** **Implementation**](#implementation)

[**6.** **Database Instance**](#database-instance)

[**7.** **SQL Data Queries**](#sql-data-queries)

[**8.** **SQL Table Modifications**](#sql-table-modifications)

[**9.** **SQL Programming**](#sql-programming)

---
<a id='statement-of-requirements'></a>
## **1. Statement of Requirements**

The purpose of this project is to design, model and program a database
which resembles one of the many real-life scenarios for which a database
would be needed.

Our project has selected the case study of a Library database, which is
meant to model the core properties of a book management system within a
library. We have chosen this task, since it is an example that many of
us students can relate to, and which has a real practical application
within the daily lives of librarians. Almost every library in the world
runs now on a customized form of a complex DBMS. For our project, we
have only selected some core attributes of the library that should be
presented, and the next chapters will describe in detail which entities
and relationships are being modeled in our case study.

A **Library User** is any person that has a unique account within the
database system. Each Library User has a unique identifier, a name, a
birth date (from which we may know the age of the user) and the status
of the user in our system, representing whether the account is active,
terminated or blocked. Also, each user has a unique Loaner Number, which
the user can choose himself and is different than their unique table ID.
This modeling decision has been done, since, in Danish libraries, Loaner
Number is something that the user itself has knowledge of and will
choose, and a user will always be aware of his own Loaner Number, but
the user will never be aware of his table ID in the database. Thus,
these attributes are different.

Library users come to the public library to loan **Books**, which belong
to a specific **Genre** that the users like. Each book has a name, an
**Author**, a **Publisher**, a release year for the book, a page count
and specified language of the text, as well as a total amount of books
that the library has in its possession (since the library can own more
than one copy of the same book). Every Author **writes** at least a
book, and a book can be written by many authors.

Library users can borrow books, thereby creating a **Loan**. Each loan
has a date of loaning and a due date, which is calculated by default to
be 30 days from the loan date, however depending on the necessity, it
can be longer. Loans will also store a returned date for a book, and a
status which indicates whether the book is still loaned, is returned or
if the owner has not returned it by its due date, thus generating a
**Fine**. A user may be assigned a number of **Fines** for not returning
their books on time. If a user has more than 3 fines, they account will
be blocked in the library system until they pay some of the fines.

If a book is unavailable (because all copies have been loaned), users
may choose to **reserve** it. A reserved book will be available to loan
for that user once there is at least one copy of the book in the
library's inventory. The reservations will have a date and a status
indicating whether the reservation is still in progress, is completed or
has been cancelled.

---
<a id='conceptual-design'></a>
## **2. Conceptual Design**

After the statement of requirements has been set into place, we now
understand what are the main concepts that our database will be working
with. These concepts have been text-bolded in the previous section.

From there, in order to get a better conceptual understanding of our 
database and model it properly, we will draw a relevant Entity-Relationship 
diagram (aka. E-R diagram), which must capture the necessary requirements. 
Within this diagram, which can be seen below, all the concepts are 
linked together in some form, and later, these considerations will be the 
start of the modeling of our database tables.

![](.//media/image2.jpeg)

Let us now explain the choices made in modeling our case-study database:

**1. Entity Sets (including attributes and primary key choices)**

-   The library user becomes an entity named **LibraryUser**. Initially,
    this name was set to user, but was modified due to a reserved
    keyword naming conflict with the SQL word "USER". The Library User
    has, as primary key, a unique ID identifying a user within the
    relation. Other attributes include: the composite attribute "Name",
    separated into the components "FirstName" and "LastName", the user's
    BirthDate, the users account status within the library and its
    selected LoanerNumber which is printed on the library card. Here, we
    could have also mentioned the derived attribute "age()", however we
    chose not to present it, as we never compute it or use it within our
    database later on.

-   The library books become the entity set **Book**, with a primary key
    consisting of a unique ID, and other attributes being related to
    different properties of a book, such as ReleaseYear, PageCount or
    TextLanguage. We store the total number of copies of a book in the
    variable TotalQuanity() in order to always know what is the total
    number of books our library can loan out. There is also a derived
    attribute, LoanedQuantity(), which represents how many copies of a
    specific book are already loaned at a certain time.

-   The available book genres have been stored in an entity set called
    **Genre**, with a unique ID as primary key, an overall Type which
    can be either 'Fiction' or 'Non-fiction', and a Subtype representing
    the more specific genre, such as 'Romance' or 'Thriller'. If we
    would not have a unique ID for each relation tuple, then the primary
    key would have been (Type, Subtype).

-   Publishers of a book are gathered in an entity set called
    **Publisher**. The primary key is a unique tuple ID, and other
    attributes stored are the publisher's name and the headquarters
    country of operation. If we would not have a unique ID for each
    relation tuple, the primary key would then be (Name), since we never
    expect two publishers to be named exactly the same. The reason why
    we introduced a unique ID here is because, in good-practice and in
    industry applications, it's the safest way to make sure that primary
    key constraints are always satisfied. Also, if a publisher company
    decides to change their name, then the publisher attribute of the
    book (to be discussed later on) will need to be carefully changed,
    and this can create problems, however a unique ID would never have
    any reason to become changed, therefore eliminating such issues.

-   Authors of books have been stored in the **Author** entity set. The
    primary key is a unique ID, and other attribute include a composite
    Name variable, and the nationality of the author.

-   The fines received by library users are stored in the **Fine**
    entity set. The fine will have a unique ID as primary key, and other
    attributes include the amount of the fine, the date of issue and the
    payment status (whether it has been paid or not-paid yet). One thing
    to note is that the fine of a user is only linked to the user
    itself, and not to a specific book loaned by the user. This has been
    carefully considered, in order to avoid a ternary many-to-many
    relationship between LibraryUser, Fine and Book. As a consequence,
    the amount of a fine will in our example always be equal to 100, as
    we do not link the fine directly to a specific loan date. We argue
    that, for the constraints of this case study, this is sufficient,
    however, were more time be given, we would have made more complex
    relations between all three involved entity sets.

-   We mention shortly that all the previous entity sets are strong
    entity sets, and that this database model does not contain any weak
    entity sets.

**2. Relationship Sets (including cardinality, participation, attributes and PK choices)**

-   When a LibraryUser wants to borrow a Book, one **Loans** a Book,
    indicating a binary relationship between LibraryUser and Book. Not
    all users need to loan a book, and not all books need to be loaned
    by at least a user, therefore participation of both Entity sets is
    partial. A user can loan many books at the same time, and a book
    (i.e. multiple copies) can be loaned by many users at the same time.
    Therefore, this is a many-to-many relationship, which will translate
    into a separate table within the Database Schema Diagram. The
    primary key is made out of the primary keys of the two connecting
    entity sets, together with a relationship attribute LoanedDate,
    since the same user might loan the same book multiple times, and
    what differentiates these loans is the date in which the book was
    loaned. It is considered that the same user cannot loan the same
    book two or more times within the same day. Other attributes
    included a date until which the book must be returned, a date
    placeholder for when the book will be returned and a Loan status,
    indicating an active, terminated or a fined loan.

-   When a LibraryUser decides to borrow a Book but the library does not
    have any available copies of the specific book, a user **Reserves**
    the book, indicating a binary relationship set. Not all users need
    to reserve a book, and not all books need to be reserved at least
    once, therefore participation of both Entity sets is partial. A user
    can reserve multiple books, and a book (i.e. multiple copies) can be
    reserved by multiple users. Therefore, this is a many-to-many
    relationship, which will translate into a separate table within the
    Database Schema Diagram. The primary key is, again, made out of the
    primary keys of the two connecting entity sets together with a
    relationship attribute ReservedDate, which indicates the date of
    reservation of a book by a user. Just like before, it is assumed
    that the same user cannot reserve more than one copy of a specific
    book during a day. There is also a ReservedStatus attribute,
    indicating whether the reservation has been finalized, cancelled or
    pending.

-   An author **Writes** a book, indicating a binary relationship set. A
    book must be written by at least one author, which means
    participation of Book is total, but not every author must write at
    least one book, since we consider that there exist authors from
    which our library does not have books yet, or that there used to be
    books by this author which the library does not possess anymore, so
    participation of Author is partial. An author can write many books
    and a book can be written by many authors. This will indicate that
    the relationship is many-to-many and will be translated into a
    separate table within the Database Schema Diagram. The primary key
    is made out of the primary keys of the two connecting entity sets,
    with no additional attributes.

-   A library user **Receives** a fine when the user does not return the
    books in time. As argued before, since a fine is only connected to a
    user, and not to a specific loaned book, this relationship is
    binary. All fines must have a corresponding library user, so
    participation of Fine is total, however not all users must have a
    Fine, so LibraryUser only participates partially. A fine is only
    connected to one single user, however a user can have many fines.
    This makes the LibraryUser-Fine a one-to-many relationship.
    Therefore, a separate logical schema does not need to be
    constructed, and instead, the primary key of LibraryUser will become
    a foreign key attribute in the Fine table.

-   There is a binary relationship between a Book and its Publisher
    (named **BookPublisher**). A book must have at least one publisher,
    so participation is total for Book. However, a Publisher does not
    need to have minimum a book in the database, since we consider the
    case scenario that there are publishers from which we used to
    receive books but don't have them anymore, or that there are
    publishers from which we don't have any books yet for our library.
    Therefore, participation of Publisher is partial. A certain book can
    only be published by one single publisher, but a publisher can
    distribute many books. This makes the Book-Publisher relationship
    many-to-one. Therefore, a separate logical schema does not need to
    be constructed, and instead, the primary key of Publisher will
    become a foreign key attribute in the Book table.

-   There is also a binary relationship between a Book and its Genre
    (named **BookGenre**). Every book must have attributed a genre, but
    a genre does not need to be attributed at least book, considering
    that there are genres for which the library does not have books yet.
    Therefore, participation of Book is total, and of Genre is partial.
    Since our Genre definition contains both a fiction/nonfiction Type
    and a specific Subtype, a book must have only one specific genre,
    however a genre can belong to many books. This indicates that the
    Book-Genre relationship is a many-to-one relationship. Therefore, a
    separate logical schema does not need to be constructed, and
    instead, the primary key of Genre will become a foreign key
    attribute in the Book table.

---
<a id='logical-design'></a>
## **3. Logical Design**

Once the Entity-Relationship Diagram has been fully structured and
understood, we will convert the E-R diagram to a set of Relation
Schemas, which will allow us to set an outline for the database
implementation later. These relation schemas will be converted into a
visual representation using a Database Schema Diagram, shown in the
figure at the end of this report.

Following the method described in the Database System Concepts, 6th 
Edition, as well as in our course supervisor's slides, we will map the
E-R diagram into the following relation schemas:

-   LibraryUser(<ins>UserID</ins>, FirstName, LastName, BirthDate, LoanNumber, UserStatus)

-   Author(<ins>AuthorID</ins>, FirstName, LastName, Nationality)

-   Genre(<ins>GenreID</ins>, Type, Subtype)

-   Publisher(<ins>PublisherID</ins>, Name, HQCountry)

-   Book(<ins>BookID</ins>, PublisherID, GenreID, Title, ISBN, ReleaseYear, PageCount, TotalQuantity, TextLanguage) **foreign key** (PublisherId, GenreID) **references** (Publisher(PublisherID), Genre(GenreID)) **on delete cascade**

-   Fine(<ins>FineID</ins>, UserID, Amount, IssuedDate, PaymentStatus) **foreign key** (UserID) **references** (LibraryUser(UserID)) **on delete cascade**

-   Loans(<ins>UserID</ins>, <ins>BookID</ins>, <ins>LoanedDate</ins>, UntilDate, ReturnedDate, LoanedStatus) **foreign key** (UserID, BookID) **references** (LibraryUser(UserID), Book(BookID)) **on delete cascade**

-   Reserves(<ins>UserID</ins>, <ins>BookID</ins>, <ins>ReservedDate</ins>, ReservedStatus) **foreign key** (UserID, BookID) **references** (LibraryUser(UserID), Book(BookID)) **on delete cascade**

-   Writes(<ins>AuthorID</ins>, <ins>BookID</ins>) **foreign key** (AuthorID, BookID) **references** (Author(AuthorID), Book(BookID)) **on delete cascade**

We have decided to make a separate Primary Key for each table coming from
an Entity, in order to successfully identify every row without relying
on the data in the row. For many-to-many relationship tables, the
primary keys are composite primary keys, consisting of the Foreign Keys,
as well as some date attributes, as in the case of Loans and Reserves.

<p align="center">
  <img src=".//media/image3.jpeg"/>
</p>

On every foreign key, the DELETE cascades, since all our Foreign Keys
reference only unique ID identifiers, and there is no further need to
keep referenced data for the deleted tuple. For instance, if a user is
deleted, their fines are deleted likewise; or if a genre is deleted from
the database, the referenced books are deleted as well, and so on. The
Foreign Key relations between tables can be seen from the arrows in the
database schema diagram, shown in the figure above.

---
<a id='normalization'></a>
## **4. Normalization**

Lastly before we delve into the implementation of the database into SQL,
we will first check for functional dependencies and normalization
issues. All tables must be in at least the third Normal Form (3NF) in
order to proceed. Below, we will take each table in part and will
analyze it with respect to normalization:

-   **LibraryUser**

The Library User table fulfills the requirements for being in the fourth
normal form. We see that each attribute is atomic, hence, the table
fulfills the conditions to be in the first normal form. Since the
primary key only consists of one attribute the table is also in the
second normal form. Furthermore, the table does not have transitive
dependency as all non-primary key attributes depend directly and only on
the primary key. Finally, we can argue that the table is also in the
fourth normal form as the conditions for a multivalued dependency are
not met.

-   **Book**

First and foremost, we would argue that the Book table is in the first
normal form, as all attributes are intended to be single-valued. One
could argue that a book could have multiple values for the language it
is written in, but we would consider that a completely different book.
In addition to this, the primary key only consists only of one attribute
thus the table is in the second normal form. Finally, as there are no
transitive or multivalued dependencies, we can hereby conclude that the
Book table is in the fourth normal form.

-   **Genre**

The attributes of the Genre table are single-valued, hence it is in the
first normal form. Also, it is in the second normal form as the primary
key only consists of one attribute. The table is in the third normal
form, as there are no transitive dependencies. Finally, none of the
conditions for a multivalued dependency are met, therefore it is in the
fourth normal form.

-   **Publisher**

The attributes of the Genre table are single-valued, hence it is in the
first normal form. Also, it is in the second normal form as the primary
key only consists of one attribute. The table is in the third normal
form, as there are no transitive dependencies. Finally, none of the
conditions for a multivalued dependency are met, therefore it is in the
fourth normal form.

-   **Author**

The author table has no multivalued attributes, only one primary key,
and each attribute depends directly on the primary key only (no
transitive dependency). Therefore, we can conclude that the table is in
the third normal form. The table is also in the fourth normal form, as
there are no multivalued dependencies.

-   **Fine**

The attributes in the Fine table are single valued, therefore it is in
the first normal form. As there is only one primary key it is also in
the second normal form. Furthermore, all non-primary key attributes are
directly dependent on the primary key, hence it is in the third normal
form. Finally, as there are no multi valued dependencies we can conclude
that the table is in the fourth normal form.

-   **Loans**

We would argue that the Loans table is in the fourth normal form. Its
attributes are atomic, and all non-primary key attributes depend on the
entire primary key. In addition to this, no non-primary key depends
transitively via. a different non-primary key. Finally, there are no
multivalued dependencies.

-   **Reserves**

This table's attributes are single valued, and the only non-primary key
attribute depends on the entire primary key, therefore it is in the
second normal form. The Reserves table has only one non-primary
attribute which is why it is in the third normal form. Finally, we would
argue that it is also in the fourth normal form as there is no
multivalued dependency.

-   **Writes**

The Writes table consists of two attributes, which also together form
the primary key, meaning it is in the third normal form. Furthermore,
there cannot exist any multivalued dependency in a table with less than
three attributes. Therefore, we can conclude that the Writes table is in
the fourth normal form.

---
<a id='implementation'></a>
## **5. Implementation**

After the database has been logically and conceptually designed, and
also checked for normalization issues, it is now time to create it, with
appropriate Tables and Views, as seen in the E-R and Database Schema
diagrams.

When creating the tables, we paid special attention to the type of each
individual attribute, so that it would suit the kind of data that one
would input in a real-life Library database. As such, most of our
attributes will be `VARCHAR(255)`, since they are related to text fields
of long book titles, author names or genre types, and many others. A
modeling decision has been made that all ID attributes (one for each
relation, helping identifying tuples within a relation) will be made
`INTEGER`, in order to use the `AUTO_INCREMENT` property of `INTEGER`
attributes. This allows for safe progression of the unique internal ID
identifier of a new set of data within a relation, and it seemed
reasonable to use for our purpose. Still, this choice is mentioned,
since, besides using the incremental function, IDs will behave as if
they were string attributes, never performing mathematical operations
upon them.

Some examples of the implementation of Tables for some of the Entities
and Relationships, as well as an example of Views implementation, can be
seen in the two tables below. The full list of SQL statement used to
create the database can be viewed in the SQL script attached to this
report.

---
### 1. Examples of Entity table implementation:
---

![](.//media/image4.png)
  
![](.//media/image6.png)
  
![](.//media/image8.png)
  
---
### 2. Examples of Relationship table implementation:
---

![](.//media/image5.png)

![](.//media/image7.png)

![](.//media/image9.png)

---
### 3. Examples of View table implementation:
---

![](.//media/image10.png)

---
<a id='database-instance'></a>
## **6. Database Instance**

With this report chapter, we will take the empty tables and views from
above, and populate them with appropriate data using the SQL command
INSERT. We make sure that all data inserted at this stage fulfills the
logical requirements that we have set for our data modeling, such as
setting the UntilDate for which a book must be returned by, to be 30
days from the initial loaning of a book.

The inserted data for library users and their loaned books have been
selected to reflect a small story from the data. Moreover, the books we
have chosen, their authors, number of pages and publisher are all
authentic data which has extracted off library websites and online
bookstores. We invite the reader to read the SQL script and understand
the small story behind the users of the database.

Here are some examples of how the data has been inserted using the INSERT statement:

![](.//media/image12.png)

The full list of data populating statements can be found in the attached
scripts. Here, we will show the relation instance of all our Tables and
Views, which now have gone through the creation and population steps, 
in the following order: a SQL SELECT QUERY image followed by its 
corresponding Relation Instance:

---

![](.//media/image16.png)  
![](.//media/image17.png)
  
---

![](.//media/image18.png)
![](.//media/image19.png)
  
---
  
![](.//media/image20.png)
![](.//media/image21.png)
  
---
  
![](.//media/image22.png)
![](.//media/image23.png)
    
---  

![](.//media/image24.png)
![](.//media/image25.png)

---

![](.//media/image26.png)
![](.//media/image27.png)

---

![](.//media/image28.png)
![](.//media/image29.png)

---

![](.//media/image30.png)
![](.//media/image31.png)

---

![](.//media/image32.png)
![](.//media/image33.png)

---

![](.//media/image34.png)
![](.//media/image35.png)

---

![](.//media/image36.png)
![](.//media/image37.png)

---
<a id='sql-data-queries'></a>
## **7. SQL Data Queries**

The database is now modeled, created and populated, which means that it
is ready to use in the daily life of a librarian. Below, we present
three SQL data queries that show typical tasks one can do with this
database, along with their outputs:

---
### **1. SQL Data Query 1**

The following query shows all books in the library and their respective
authors:

![](.//media/image38.png)

Its output upon the initial database instance is:

![](.//media/image39.png)

---
### **2. SQL Data Query 2**

The next query shows the number of unique books the library has from each author. This
does not refer to the total number of copies of each book, but strictly
to the number of different book titles present from each author. The
authors are ordered descendingly according to the number of unique books
present in the database:

![](.//media/image40.png)

Its output upon the initial database instance is:

![](.//media/image41.png)

---
### **3. SQL Data Query 3**

This last query gives an overview of all loans for each library user, separated into
categories by their status:

![](.//media/image42.png)

Its output upon the initial database instance is:

![](.//media/image43.png)

---
<a id='sql-table-modifications'></a>
## **8. SQL Table Modifications**

For the table modifications part, we will show some examples of SQL
table commands: UPDATE and DELETE.

---
### **1. UPDATE statement**

For this example, we will explain that the library decides to buy more copies of
a book that is seeing particularly high demand among its users. This is
the Book relation instance, before any update:

![](.//media/image44.png)

And this is the UPDATE statement:

![](.//media/image47.png)

After the purchase, the number of copies (TotalQuantity)
of the fan-favorite book 'Database System Concepts, Sixth Edition' is
simply updated from 5 to 10 in the Book table, as seen below:

![](.//media/image46.png)

---
### **2. DELETE statement**

A reasonable example for our DELETE case scenario is that a user
requests that their data be deleted from the library database. Because
of GDPR, the library chooses to comply - as long as the user doesn't
have any unpaid fines. The user with LoanerNumber 154399 (Sule Altintas)
is deleted from the table LibraryUser as long as no fines with
PaymentStatus NOT PAID exist belonging to their LoanerNumber.

The DELETE statement is:

![](.//media/image48.png)

The database relation instance data before the DELETE statement looks like this:

![](.//media/image49.png)

Because Sule has been good and not accumulated any fines, her data has now been deleted
from LibraryUser as well as any table where her UserID is a foreign key,
as they are all set to `CASCADE ON DELETE`. These tables are Fine, Loans,
and Reserves. Note that of these, only Loans has changed, as Sule did
not have any entries in the other tables in the first place.

![](.//media/image53.png)

If we try instead to remove Billy Bully (who has LoanerNumber 203442) 
we see the following output, because Billy has been not paid three of his fines. 
Before his data is deleted, he must pay all the outstanding fines.

![](.//media/image57.png)

---
<a id='sql-programming'></a>
## **9. SQL Programming**

In this last part of the report, regarding SQL programming, we will show
examples of the five types of programming structures that are required,
and will explain, for each of them, how their behavior works.

---
### **1. Functions**

Given a book ID, the function returns how
many are currently loaned out. The LoanedQuantity variable defaults to
0, so that NULL is not returned from the function.

![](.//media/image58.png)

The function used in a SELECT query to
find the number of loans for each book:

![](.//media/image59.png)

This statement gives out in the following result:

![](.//media/image60.png)

---
### **2. Procedures**

Given a Book ID and a User ID, create a
new loan for the user, with the book. Set the LoanedDate to the actual
date of the loan, and the UntilDate to be 30 days later than the loan
date. Set the initial status to 'LOANED'.

![](.//media/image61.png)

Before the call to the procedure, the
user with UserID 4 only has a single book borrowed, as it can be seen
from the following execution:

![](.//media/image62.png)
![](.//media/image63.png)

After the procedure call, the book 'Kafka på stranden',
with BookID 1, has now been loaned by the user.

![](.//media/image64.png)
![](.//media/image65.png)

---
### **3. Transactions**

Create fines for every overdue loan that has a status of 'LOANED'. After
the fines are created, set the status for the loans to 'FINED' to
indicate that the loan has been fined. The transaction only contains a
COMMIT, and not a ROLLBACK. The reason for this is that, by default, the
queries in the transaction will cause the transaction to fail if any of
the queries fails. Therefore, it is not necessary to manually implement
the rollback. Furthermore, the transaction serves an important purpose,
as we are ensured that an accidental database crash does not disrupt the
fining procedure.

If the payment of the fines was modeled in
the database, a check of the paid amount could be implemented, and
thereby a manual rollback added. However, the current design of the
database does not require any transactions with a manual rollback.

![](.//media/image66.png)

Continuing with our previous example with
the loaning of books by UserID 4, we can see from the Procedure
subsection that the book "Kafka på stranden" was loaned on the 2nd of
April, thus not requiring a fine at the moment of writing this report.
In order to test the procedure with Transaction enabled, `CreateFines()`,
we will change the loan date of the 'Kafka på stranden' book to go a few
months back. After changing the dates for the loan, the table looks like
this:

![](.//media/image67.png)

In order to be sure that the user with UserID 4 has no
fines, let us run a SELECT query, and verify that the query returns an
empty table result:

![](.//media/image69.png)
![](.//media/image68.png)

After calling the `CreateFines()` procedure
with transaction, the status of the loan is changed from LOANED to
FINED, and a fine for UserID 4 is created:

![](.//media/image71.png)
![](.//media/image70.png)

---
### **4. Triggers**

Here, we create a Trigger that, for each new insert in
Loans, checks if there exist enough books for a new Loan, and also
whether or not the user already has a copy of the book. If either
constraint is broken, the '45000' signal is raised, and a custom message
text is set.

![](.//media/image72.png)

If user with UserID 4 attempts to borrow 
the book with BookID 2 several times, the first call will succeed:

![](.//media/image74.png)
![](.//media/image73.png)

However, the second call does not, and the table will remain unchanged:

![](.//media/image76.png)
![](.//media/image75.png)
![](.//media/image73.png)

Furthermore, if a user tries to borrow a book with no available copies, 
the following error occurs:

![](.//media/image77.png)

---
### **5. Events**

Here we create an Event that is scheduled
to run every day, and utilizes the previously-created `CreateFines()`
Procedure in order to check loans, update the fine status for each loan,
and create eventual necessary fines. The procedure `CreateFines()` is used
for modularity.

![](.//media/image78.png)

In order for the above event to be scheduled, we also need to run the
command `SET GLOBAL event_scheduler = 1;` before running the
previous event statement. By testing the `CreateFines()` procedure, the
event has effectively been tested as well.
