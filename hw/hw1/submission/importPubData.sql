-- Problem 5: Data Transformation
-- Populate Publication table
INSERT INTO Publication (pubkey, title, year) (
  SELECT DISTINCT ON (pub_raw.k) pub_raw.k, title_field.v, CAST(year_field.v AS INT)
  FROM Pub AS pub_raw
    LEFT OUTER JOIN Field as title_field
    ON (pub_raw.k = title_field.k AND title_field.p = 'title')
    LEFT OUTER JOIN Field AS year_field
    ON (pub_raw.k = year_field.k AND year_field.p = 'year')
  WHERE pub_raw.p = 'article' OR pub_raw.p = 'book' OR pub_raw.p = 'incollection' OR pub_raw.p ='inproceedings'
);
CREATE UNIQUE INDEX Publication_pubkey ON Publication(pubkey);

-- Populate Article Table
INSERT INTO Article (pubid, journal, month, volume, number) (
  SELECT DISTINCT ON (pub_pro.pubid) pub_pro.pubid, journal_field.v, month_field.v, volume_field.v, number_field.v
  FROM Publication AS pub_pro JOIN Pub ON (pub_pro.pubkey = Pub.k AND Pub.p = 'article')
    LEFT OUTER JOIN Field as journal_field
    ON (pub_pro.pubkey = journal_field.k AND journal_field.p = 'journal')
    LEFT OUTER JOIN Field as month_field
    ON (pub_pro.pubkey = month_field.k AND month_field.p = 'month')
    LEFT OUTER JOIN Field as volume_field
    ON (pub_pro.pubkey = volume_field.k AND volume_field.p = 'volume')
    LEFT OUTER JOIN Field as number_field
    ON (pub_pro.pubkey = number_field.k AND number_field.p = 'number')
);
CREATE INDEX Article_pubid ON Article(pubid);
ALTER TABLE Article ADD FOREIGN KEY (pubid) REFERENCES Publication(pubid);

-- Populate Book Table
INSERT INTO Book (pubid, publisher, isbn) (
  SELECT DISTINCT ON (pub_pro.pubid) pub_pro.pubid, publisher_field.v, isbn_field.v
  FROM Publication AS pub_pro JOIN Pub ON (pub_pro.pubkey = Pub.k AND Pub.p = 'book')
    LEFT OUTER JOIN Field as publisher_field
    ON (pub_pro.pubkey = publisher_field.k AND publisher_field.p = 'publisher')
    LEFT OUTER JOIN Field as isbn_field
    ON (pub_pro.pubkey = isbn_field.k AND isbn_field.p = 'isbn')
);
CREATE INDEX Book_pubid ON Book(pubid);
ALTER TABLE Book ADD FOREIGN KEY (pubid) REFERENCES Publication(pubid);

-- Populate Incollection Table
INSERT INTO Incollection (pubid, booktitle, publisher, isbn) (
  SELECT DISTINCT ON (pub_pro.pubid) pub_pro.pubid, booktitle_field.v, publisher_field.v, isbn_field.v
  FROM Publication AS pub_pro JOIN Pub ON (pub_pro.pubkey = pub.k AND Pub.p = 'incollection')
    LEFT OUTER JOIN Field as booktitle_field
    ON (pub_pro.pubkey = booktitle_field.k AND booktitle_field.p = 'booktitle')
    LEFT OUTER JOIN Field as publisher_field
    ON (pub_pro.pubkey = publisher_field.k AND publisher_field.p = 'publisher')
    LEFT OUTER JOIN Field as isbn_field
    ON (pub_pro.pubkey = isbn_field.k AND isbn_field.p = 'isbn')
);
CREATE INDEX Incollection_pubid ON Incollection(pubid);
ALTER TABLE Incollection ADD FOREIGN KEY (pubid) REFERENCES Publication(pubid);

-- Populate Inproceedings Table
INSERT INTO Inproceedings (pubid, booktitle, editor) (
  SELECT DISTINCT ON (pub_pro.pubid) pub_pro.pubid, booktitle_field.v, editor_field.v
  FROM Publication AS pub_pro JOIN Pub ON (pub_pro.pubkey = pub.k AND Pub.p = 'inproceedings')
    LEFT OUTER JOIN Field as booktitle_field
    ON (pub_pro.pubkey = booktitle_field.k AND booktitle_field.p = 'booktitle')
    LEFT OUTER JOIN Field as editor_field
    ON (pub_pro.pubkey = editor_field.k AND editor_field.p = 'editor')
);
CREATE INDEX Inproceedings_pubid ON Inproceedings(pubid);
ALTER TABLE Inproceedings ADD FOREIGN KEY (pubid) REFERENCES Publication(pubid);

-- Populate Author Table
CREATE TABLE AuthorNames (
  name TEXT NOT NULL
);
INSERT INTO AuthorNames (SELECT v FROM Field WHERE p = 'author');
CREATE INDEX AuthorNames_name ON AuthorNames(Name);
CREATE TABLE Homepage (
  name TEXT NOT NULL UNIQUE,
  homepage TEXT
);
INSERT INTO Homepage (name, homepage) (
  SELECT DISTINCT ON (a.Name) a.Name, z.v
  FROM AuthorNames a, Pub x, Field y, Field z
  WHERE x.k=y.k and y.k=z.k and x.p='www' and y.p='author' and y.v=a.Name and z.p='url'
);
INSERT INTO Author (name, homepage) (
	SELECT DISTINCT ON (n.name) n.name, h.homepage
  FROM (SELECT DISTINCT name FROM AuthorNames) AS n
    LEFT OUTER JOIN Homepage AS h ON h.name = n.name
);
DROP TABLE AuthorNames;
DROP TABLE Homepage;
CREATE INDEX Author_name ON Author(name);

-- Populate Authored Table
INSERT INTO Authored (id, pubid) (
	SELECT DISTINCT a.id, p.pubid
  FROM Author AS a
    JOIN Field AS f ON (a.name = f.v AND f.p = 'author')
    JOIN Publication AS p ON (p.pubkey = f.k)
);
CREATE INDEX Authored_id_pubid ON Authored(id, pubid);
ALTER TABLE Authored ADD FOREIGN KEY (id) REFERENCES Author(id);
ALTER TABLE Authored ADD FOREIGN KEY (pubid) REFERENCES Publication(pubid);