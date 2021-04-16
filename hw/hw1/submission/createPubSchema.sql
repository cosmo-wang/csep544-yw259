-- drop tables (for debugging)
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS Publication;
DROP TABLE IF EXISTS Authored;
DROP TABLE IF EXISTS Article;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Incollection;
DROP TABLE IF EXISTS Inproceedings;

-- create tables
CREATE TABLE Author (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    homepage TEXT
);

CREATE TABLE Publication (
    pubid SERIAL PRIMARY KEY,
    pubkey TEXT NOT NULL,
    title TEXT,
    year INTEGER
);

CREATE TABLE Authored (
    id INTEGER NOT NULL,
    pubid INTEGER NOT NULL
);

CREATE TABLE Article (
    pubid INTEGER NOT NULL,
    journal TEXT,
    month TEXT,
    volume TEXT,
    number TEXT
);

CREATE TABLE Book (
    pubid INTEGER NOT NULL,
    publisher TEXT,
    isbn TEXT
);

CREATE TABLE Incollection (
    pubid INTEGER NOT NULL,
    booktitle TEXT,
    publisher TEXT,
    isbn TEXT
);

CREATE TABLE Inproceedings (
    pubid INTEGER NOT NULL,
    booktitle TEXT,
    editor TEXT
);
