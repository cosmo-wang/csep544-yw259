-- Problem 4: Querying the Raw Data
-- Part 1:
SELECT p AS publication_type, COUNT(*) FROM pub GROUP BY p;
-- Result:
--  publication_type |  count  
-- ------------------+---------
--  article          | 2526072
--  book             |   18686
--  incollection     |   66447
--  inproceedings    | 2791221
--  mastersthesis    |      12
--  phdthesis        |   80376
--  proceedings      |   46847
--  www              | 2722322
-- (8 rows)

-- Part 2:
-- get all filed names
SELECT DISTINCT Field.p AS field_type FROM Field
EXCEPT
-- get all field names that are not in all publication_types
SELECT fields_not_in_all_publications.field_type AS field_type
  FROM (
    -- get cross product of all publication_type and field_type
    -- pt & ft are dummy aliases used for syntax purpose
    SELECT *
      FROM (SELECT DISTINCT Pub.p AS publication_type FROM Pub) AS pt,
           (SELECT DISTINCT Field.p AS field_type FROM Field) AS ft
    EXCEPT
    -- get pairs of all existing publication_type and field_type
    SELECT pub.p AS publication_type, field.p AS field_type
      FROM pub, field WHERE pub.k = field.k
  ) AS fields_not_in_all_publications;
-- Result:
--  field_type 
-- ------------
--  year
--  title
--  ee
--  author
--  note

-- Part 3:
CREATE UNIQUE INDEX Pub_k ON Pub(k);
CREATE INDEX Pub_p ON Pub(p);
CREATE INDEX Field_k ON Field(k);
CREATE INDEX Field_p ON Field(p);
CREATE INDEX Field_v ON Field(v);


--------------------------------------------------------------------
-- Problem 6: Run Data Analytic Queries
-- Part 1:
-- Top 20 authors with the largest number of publications
SELECT a.name, COUNT(*) AS pub_count
FROM Author a, Authored a_ed
WHERE a.id = a_ed.id
GROUP BY a.id
ORDER BY pub_count DESC
LIMIT 20;
-- Result:
--          name         | pub_count 
-- ----------------------+-----------
--  H. Vincent Poor      |      2175
--  Mohamed-Slim Alouini |      1691
--  Philip S. Yu         |      1540
--  Wei Zhang            |      1465
--  Wei Wang             |      1416
--  Lajos Hanzo          |      1411
--  Lei Zhang            |      1353
--  Yu Zhang             |      1352
--  Wen Gao 0001         |      1288
--  Yang Liu             |      1287
--  Victor C. M. Leung   |      1279
--  Xin Wang             |      1250
--  Zhu Han              |      1234
--  Lei Wang             |      1220
--  Hai Jin 0001         |      1215
--  Witold Pedrycz       |      1198
--  Dacheng Tao          |      1180
--  Jing Wang            |      1147
--  Luca Benini          |      1134
--  Thomas S. Huang      |      1132
-- (20 rows)

-- Part 2:
-- a. Find the top 20 authors with the largest number of publications in STOC.
SELECT a.name, COUNT(*) AS pub_count
FROM Author a, Authored a_ed, Publication pub
WHERE a.id = a_ed.id AND pub.pubid = a_ed.pubid AND pub.pubkey LIKE '%stoc%'
GROUP BY a.id
ORDER BY pub_count DESC
LIMIT 20;
-- Result
--            name            | pub_count 
-- ---------------------------+-----------
--  Alexandr V. Kostochka     |       109
--  Daniel Bienstock          |        69
--  Avi Wigderson             |        58
--  Robert Endre Tarjan       |        33
--  Ran Raz                   |        30
--  Moni Naor                 |        28
--  Noam Nisan                |        28
--  Uriel Feige               |        28
--  Rafail Ostrovsky          |        27
--  Marinos Themistocleous    |        27
--  Santosh S. Vempala        |        26
--  Mihalis Yannakakis        |        26
--  Venkatesan Guruswami      |        26
--  Oded Goldreich 0001       |        25
--  Frank Thomson Leighton    |        25
--  Christos H. Papadimitriou |        24
--  Prabhakar Raghavan        |        24
--  Moses Charikar            |        23
--  Mikkel Thorup             |        23
--  Rocco A. Servedio         |        22
-- (20 rows)

-- b. Find the top 20 authors with the largest number of publications in SIGMOD.
SELECT a.name, COUNT(*) AS pub_count
FROM Author a, Authored a_ed, Publication pub
WHERE a.id = a_ed.id AND pub.pubid = a_ed.pubid AND pub.pubkey LIKE 'conf/sigmod/%'
GROUP BY a.id
ORDER BY pub_count DESC
LIMIT 20;
-- Result
--          name          | pub_count 
-- -----------------------+-----------
--  Surajit Chaudhuri     |        59
--  Divesh Srivastava     |        57
--  H. V. Jagadish        |        50
--  Michael Stonebraker   |        48
--  Jeffrey F. Naughton   |        47
--  Michael J. Franklin   |        47
--  Michael J. Carey 0001 |        46
--  Jiawei Han 0001       |        41
--  Samuel Madden         |        40
--  David J. DeWitt       |        40
--  Beng Chin Ooi         |        40
--  Hector Garcia-Molina  |        38
--  Dan Suciu             |        38
--  Tim Kraska            |        38
--  Johannes Gehrke       |        38
--  Donald Kossmann       |        38
--  Joseph M. Hellerstein |        38
--  Raghu Ramakrishnan    |        37
--  Carsten Binnig        |        33
--  Kian-Lee Tan          |        33
-- (20 rows)

-- c. Find the top 20 authors with the largest number of publications in PODS.
SELECT a.name, COUNT(*) AS pub_count
FROM Author a, Authored a_ed, Publication pub
WHERE a.id = a_ed.id AND pub.pubid = a_ed.pubid AND pub.pubkey LIKE 'conf/pods/%'
GROUP BY a.id
ORDER BY pub_count DESC
LIMIT 20;
-- Result
--            name            | pub_count 
-- ---------------------------+-----------
--  Leonid Libkin             |        38
--  Georg Gottlob             |        32
--  Victor Vianu              |        31
--  Yehoshua Sagiv            |        31
--  Dan Suciu                 |        30
--  Moshe Y. Vardi            |        30
--  Phokion G. Kolaitis       |        29
--  Serge Abiteboul           |        29
--  Benny Kimelfeld           |        28
--  Tova Milo                 |        23
--  Ronald Fagin              |        22
--  Dirk Van Gucht            |        21
--  Christos H. Papadimitriou |        20
--  Jan Van den Bussche       |        19
--  Frank Neven               |        19
--  Michael Benedikt          |        18
--  Wenfei Fan                |        17
--  Luc Segoufin              |        16
--  Jeffrey D. Ullman         |        16
--  Marcelo Arenas            |        15
-- (20 rows)

-- Part 3:
-- Create temperary view with author names and their number of publications in PODS
CREATE VIEW PODS_Publication AS
  SELECT DISTINCT pub.pubkey FROM Publication pub WHERE pub.pubkey LIKE 'conf/pods/%';
-- Creating it as materialized view because this is used more than once
CREATE MATERIALIZED VIEW PODS_Pub_Count AS
  SELECT a_ed.id, COUNT(a_ed.pubid) AS pub_count
  FROM Authored AS a_ed JOIN Publication AS pub ON a_ed.pubid = pub.pubid JOIN PODS_Publication AS p_pub ON p_pub.pubkey = pub.pubkey
  GROUP BY a_ed.id
  ORDER BY pub_count DESC;
-- Create temperary view with author names and their number of publications in SIGMOD
CREATE VIEW SIGMOD_Publication AS
  SELECT DISTINCT pub.pubkey FROM Publication pub WHERE pub.pubkey LIKE 'conf/sigmod/%';
-- Creating it as materialized view because this is used more than once
CREATE MATERIALIZED VIEW SIGMOD_Pub_Count AS
  SELECT a_ed.id, COUNT(a_ed.pubid) AS pub_count
  FROM Authored AS a_ed JOIN Publication AS pub ON a_ed.pubid = pub.pubid JOIN SIGMOD_Publication AS s_pub ON s_pub.pubkey = pub.pubkey
  GROUP BY a_ed.id
  ORDER BY pub_count DESC;
-- (a) All authors who published at least 10 SIGMOD papers but never published a PODS paper
SELECT a.name, s_pub_c.pub_count
FROM SIGMOD_Pub_Count AS s_pub_c
  LEFT OUTER JOIN PODS_Pub_Count AS p_pub_c ON s_pub_c.id = p_pub_c.id
  LEFT OUTER JOIN Author AS a ON s_pub_c.id = a.id
WHERE s_pub_c.pub_count >= 10 AND p_pub_c.pub_count IS NULL
ORDER BY s_pub_c.pub_count DESC;
-- Result:
--            name           | pub_count 
-- --------------------------+-----------
--  Michael Stonebraker      |        48
--  Jiawei Han 0001          |        41
--  Samuel Madden            |        40
--  Donald Kossmann          |        38
--  Tim Kraska               |        38
--  Guoliang Li 0001         |        33
--  Carsten Binnig           |        33
--  Elke A. Rundensteiner    |        31
--  Xiaokui Xiao             |        30
--  Jeffrey Xu Yu            |        29
--  Gautam Das 0001          |        27
--  Stratos Idreos           |        26
--  Alfons Kemper            |        26
--  Volker Markl             |        25
--  Anastasia Ailamaki       |        24
--  Feifei Li 0001           |        24
--  Juliana Freire           |        24
--  Jignesh M. Patel         |        22
--  Sourav S. Bhowmick       |        21
--  Lei Chen 0002            |        21
--  Bin Cui 0001             |        21
--  Eugene Wu 0002           |        21
--  Anthony K. H. Tung       |        20
--  Ihab F. Ilyas            |        20
--  Nan Tang 0001            |        19
--  AnHai Doan               |        19
--  Gao Cong                 |        19
--  Mourad Ouzzani           |        19
--  Jian Pei                 |        18
--  Kevin Chen-Chuan Chang   |        18
--  David B. Lomet           |        18
--  Jun Yang 0001            |        18
--  Jim Gray 0001            |        18
--  Guy M. Lohman            |        17
--  Arun Kumar 0001          |        17
--  Peter A. Boncz           |        17
--  Barzan Mozafari          |        17
--  Andrew Pavlo             |        17
--  Sihem Amer-Yahia         |        17
--  Ion Stoica               |        17
--  Daniel J. Abadi          |        16
--  Nick Roussopoulos        |        16
--  Nicolas Bruno            |        15
--  Badrish Chandramouli     |        15
--  Stanley B. Zdonik        |        15
--  Krithi Ramamritham       |        15
--  Aditya G. Parameswaran   |        15
--  Louiqa Raschid           |        14
--  Wook-Shin Han            |        14
--  Kaushik Chakrabarti      |        14
--  Ahmed K. Elmagarmid      |        14
--  Carlos Ordonez 0001      |        14
--  Jiannan Wang             |        14
--  Zachary G. Ives          |        14
--  Jingren Zhou             |        14
--  Ugur etintemel           |        14
--  Lu Qin                   |        14
--  Suman Nath               |        14
--  James Cheng              |        14
--  Georgia Koutrika         |        13
--  Dirk Habich              |        13
--  Xifeng Yan               |        13
--  Goetz Graefe             |        13
--  Hans-Arno Jacobsen       |        13
--  Raymond Chi-Wing Wong    |        13
--  Stefano Ceri             |        13
--  Ashraf Aboulnaga         |        13
--  Kevin S. Beyer           |        13
--  M. Tamer zsu             |        13
--  Chengkai Li              |        13
--  Jianhua Feng             |        12
--  Jayavel Shanmugasundaram |        12
--  Ioana Manolescu          |        12
--  Cong Yu 0001             |        12
--  Boon Thau Loo            |        12
--  Zhifeng Bao              |        12
--  Michael J. Cafarella     |        12
--  Wei Wang 0011            |        12
--  Sudipto Das              |        12
--  Tilmann Rabl             |        12
--  Torsten Grust            |        11
--  Alvin Cheung             |        11
--  Anisoara Nica            |        11
--  Bolin Ding               |        11
--  Carlo Curino             |        11
--  Christian S. Jensen      |        11
--  Clement T. Yu            |        11
--  Lijun Chang              |        11
--  Luis Gravano             |        11
--  Mohamed F. Mokbel        |        11
--  Nan Zhang 0004           |        11
--  Nectarios Koziris        |        11
--  Olga Papaemmanouil       |        11
--  Peter Bailis             |        11
--  Rajasekar Krishnamurthy  |        11
--  Themis Palpanas          |        11
--  Vladislav Shkapenyuk     |        11
--  Xiaofang Zhou 0001       |        11
--  Yinghui Wu               |        11
--  K. Seluk Candan          |        10
--  Alexandros Labrinidis    |        10
--  Theodoros Rekatsinas     |        10
--  Jos A. Blakeley          |        10
--  Jens Teubner             |        10
--  Aaron J. Elmore          |        10
--  Immanuel Trummer         |        10
--  Vasilis Vassalos         |        10
--  Arash Termehchy          |        10
--  Gang Chen 0001           |        10
--  Dimitrios Tsoumakos      |        10
--  Chee Yong Chan           |        10
--  Zhenjie Zhang            |        10
--  Bruce G. Lindsay 0001    |        10
--  Bingsheng He             |        10
--  Xin Luna Dong            |        10
--  Yanlei Diao              |        10
--  Sailesh Krishnamurthy    |        10
--  Qiong Luo 0001           |        10
--  Martin L. Kersten        |        10
--  Lawrence A. Rowe         |        10
-- (120 rows)

--(b) All authors who published at least 5 PODS papers but never published a SIGMOD paper
SELECT a.name, p_pub_c.pub_count
FROM PODS_Pub_Count AS p_pub_c
  LEFT OUTER JOIN SIGMOD_Pub_Count AS s_pub_c ON s_pub_c.id = p_pub_c.id
  LEFT OUTER JOIN Author AS a ON p_pub_c.id = a.id
WHERE s_pub_c.pub_count IS NULL AND p_pub_c.pub_count >= 5
ORDER BY p_pub_c.pub_count DESC;
-- Result:
--           name           | pub_count 
-- -------------------------+-----------
--  David P. Woodruff       |        15
--  Thomas Schwentick       |        11
--  Andreas Pieris          |        11
--  Rasmus Pagh             |        10
--  Reinhard Pichler        |        10
--  Nicole Schweikardt      |        10
--  Giuseppe De Giacomo     |         9
--  Martin Grohe            |         8
--  Stavros S. Cosmadakis   |         8
--  Eljas Soisalon-Soininen |         7
--  Francesco Scarcello     |         6
--  Juan L. Reutter         |         6
--  Jef Wijsen              |         6
--  Alan Nash               |         5
--  Matthias Niewerth       |         5
--  Kari-Jouko Rih          |         5
--  Mikolaj Bojanczyk       |         5
--  Vassos Hadzilacos       |         5
--  Kobbi Nissim            |         5
--  Hubie Chen              |         5
--  Marco A. Casanova       |         5
--  Srikanta Tirthapura     |         5
--  Miguel Romero 0001      |         5
--  Nancy A. Lynch          |         5
--  Michael Mitzenmacher    |         5
--  Cristian Riveros        |         5
-- (26 rows)
-- Drop temperary views
DROP MATERIALIZED VIEW SIGMOD_Pub_Count;
DROP MATERIALIZED VIEW PODS_Pub_Count;
-- The other two views are not dropped because they are used in a later problem.

-- Part 4:
-- Compute the total number of publications in DBLP in that decade
CREATE TABLE Decade_Pub_Count (
  year INTEGER,
  pub_count INTEGER
);

INSERT INTO Decade_Pub_Count (
  SELECT CAST(year AS INTEGER), COUNT(pubid)
  FROM Publication
  WHERE year IS NOT NULL
  GROUP BY year
);

SELECT d1.year AS decade, SUM(d2.pub_count)
FROM Decade_Pub_Count d1, Decade_Pub_Count d2
WHERE d1.year <= d2.year AND d1.year > d2.year - 10
GROUP BY d1.year
ORDER BY d1.year;
-- Result:
--  decade |   sum   
-- --------+---------
--    1936 |     113
--    1937 |     132
--    1938 |     127
--    1939 |     157
--    1940 |     191
--    1941 |     207
--    1942 |     215
--    1943 |     236
--    1944 |     340
--    1945 |     501
--    1946 |     651
--    1947 |     844
--    1948 |    1083
--    1949 |    1355
--    1950 |    1830
--    1951 |    2284
--    1952 |    2973
--    1953 |    3958
--    1954 |    4754
--    1955 |    5480
--    1956 |    6379
--    1957 |    7405
--    1958 |    8719
--    1959 |   10417
--    1960 |   11799
--    1961 |   13312
--    1962 |   15212
--    1963 |   17479
--    1964 |   20342
--    1965 |   23792
--    1966 |   27291
--    1967 |   31095
--    1968 |   34949
--    1969 |   39023
--    1970 |   43276
--    1971 |   48378
--    1972 |   53327
--    1973 |   58714
--    1974 |   64602
--    1975 |   71271
--    1976 |   78929
--    1977 |   88580
--    1978 |   98821
--    1979 |  111875
--    1980 |  127338
--    1981 |  145674
--    1982 |  166724
--    1983 |  190672
--    1984 |  218941
--    1985 |  249917
--    1986 |  282049
--    1987 |  316286
--    1988 |  353619
--    1989 |  394904
--    1990 |  440475
--    1991 |  490694
--    1992 |  543205
--    1993 |  602250
--    1994 |  671022
--    1995 |  757342
--    1996 |  863033
--    1997 |  982980
--    1998 | 1113158
--    1999 | 1248158
--    2000 | 1395807
--    2001 | 1539893
--    2002 | 1699373
--    2003 | 1860761
--    2004 | 2023294
--    2005 | 2174388
--    2006 | 2313337
--    2007 | 2443623
--    2008 | 2583286
--    2009 | 2743624
--    2010 | 2923375
--    2011 | 3093963
--    2012 | 2921296
--    2013 | 2668262
--    2014 | 2399029
--    2015 | 2119628
--    2016 | 1830641
--    2017 | 1531466
--    2018 | 1208634
--    2019 |  852873
--    2020 |  458277
--    2021 |   67953
--    2022 |      20
-- (87 rows)
DROP TABLE Decade_Pub_Count;

-- Part 5
-- Find the top 20 most collaborative authors
CREATE TABLE Coauthor (
  id1 INTEGER,
  id2 INTEGER
);

INSERT INTO Coauthor (
  SELECT a_ed1.id, a_ed2.id
  FROM Authored a_ed1, Authored a_ed2
  WHERE a_ed1.pubid = a_ed2.pubid AND a_ed1.id <> a_ed2.id
);

SELECT a.name, COUNT(DISTINCT c.id2) AS collaborator_count
FROM Coauthor c, Author a
WHERE c.id1 = a.id
GROUP BY a.name
ORDER BY collaborator_count DESC
LIMIT 20;
-- Result:
--     name    | collaborator_count 
-- ------------+--------------------
--  Wei Wang   |               3766
--  Wei Zhang  |               3723
--  Yang Liu   |               3606
--  Lei Zhang  |               3584
--  Yu Zhang   |               3475
--  Wei Li     |               3196
--  Lei Wang   |               3194
--  Xin Wang   |               2849
--  Jing Wang  |               2790
--  Yan Li     |               2777
--  Wei Liu    |               2726
--  Yi Zhang   |               2718
--  Li Zhang   |               2707
--  Xin Li     |               2657
--  Jian Wang  |               2556
--  Yang Li    |               2551
--  Wei Chen   |               2543
--  Yan Zhang  |               2534
--  Jing Zhang |               2534
--  Jing Li    |               2534
-- (20 rows)
-- Not dropping table because will use it in Problem 7 of the homework.

-- Part 6
-- For each decade, find the most prolific author in that decade
CREATE TABLE Year_Author_Pub_Count (
  year INTEGER,
  id INTEGER,
  pub_count INTEGER
);

INSERT INTO Year_Author_Pub_Count (
  SELECT CAST(pub.year AS INTEGER), a_ed.id, COUNT(pub.pubkey)
  FROM Publication pub, Authored a_ed
  WHERE pub.pubid = a_ed.pubid AND pub.year IS NOT NULL
  GROUP BY pub.year, a_ed.id
);

CREATE VIEW Decade_Author_Pub_Count AS
  SELECT y1.year, y1.id, SUM(y2.pub_count) AS total_pub_count
  FROM Year_Author_Pub_Count y1, Year_Author_Pub_Count y2
  WHERE y1.id = y2.id AND y1.year <= y2.year AND y1.year > y2.year - 10 AND y1.year <= 2021
  GROUP BY y1.year, y1.id;

SELECT d1.year, a.name
FROM Decade_Author_Pub_Count d1, Author a
WHERE (d1.year, d1.total_pub_count) IN (
  SELECT d2.year, MAX(d2.total_pub_count) FROM Decade_Author_Pub_Count d2 GROUP BY d2.year
) AND d1.id = a.id
GROUP BY d1.year, a.name;
-- Result:
--  year |          name           
-- ------+-------------------------
--  1936 | Willard Van Orman Quine
--  1937 | Willard Van Orman Quine
--  1938 | Willard Van Orman Quine
--  1939 | J. C. C. McKinsey
--  1940 | Willard Van Orman Quine
--  1941 | Frederic Brenton Fitch
--  1941 | Willard Van Orman Quine
--  1942 | Frederic Brenton Fitch
--  1943 | Nelson Goodman
--  1943 | R. M. Martin
--  1944 | Frederic Brenton Fitch
--  1945 | Willard Van Orman Quine
--  1946 | Willard Van Orman Quine
--  1947 | Willard Van Orman Quine
--  1948 | Hao Wang 0001
--  1949 | Claude E. Shannon
--  1949 | John R. Myhill
--  1950 | Hao Wang 0001
--  1951 | John R. Myhill
--  1952 | Hao Wang 0001
--  1953 | Hao Wang 0001
--  1954 | Harry D. Huskey
--  1955 | Boleslaw Sobocinski
--  1956 | Nelson M. Blachman
--  1957 | Saul Gorn
--  1958 | Seymour Ginsburg
--  1959 | Seymour Ginsburg
--  1960 | Henry C. Thacher Jr.
--  1961 | Henry C. Thacher Jr.
--  1962 | Seymour Ginsburg
--  1963 | Seymour Ginsburg
--  1964 | Seymour Ginsburg
--  1965 | Jeffrey D. Ullman
--  1966 | Jeffrey D. Ullman
--  1967 | Jeffrey D. Ullman
--  1968 | Jeffrey D. Ullman
--  1969 | Jeffrey D. Ullman
--  1970 | Azriel Rosenfeld
--  1970 | Jeffrey D. Ullman
--  1971 | Grzegorz Rozenberg
--  1972 | Grzegorz Rozenberg
--  1973 | Grzegorz Rozenberg
--  1974 | Azriel Rosenfeld
--  1975 | Azriel Rosenfeld
--  1976 | Azriel Rosenfeld
--  1977 | Azriel Rosenfeld
--  1978 | Azriel Rosenfeld
--  1979 | Azriel Rosenfeld
--  1980 | Azriel Rosenfeld
--  1981 | Azriel Rosenfeld
--  1982 | Azriel Rosenfeld
--  1983 | Azriel Rosenfeld
--  1984 | Micha Sharir
--  1985 | Micha Sharir
--  1986 | Micha Sharir
--  1987 | Micha Sharir
--  1988 | David J. Evans 0001
--  1989 | David J. Evans 0001
--  1990 | Toshio Fukuda
--  1991 | Toshio Fukuda
--  1992 | Toshio Fukuda
--  1993 | Toshio Fukuda
--  1994 | Thomas S. Huang
--  1995 | Thomas S. Huang
--  1996 | Thomas S. Huang
--  1997 | Thomas S. Huang
--  1998 | Wen Gao 0001
--  1999 | Wen Gao 0001
--  2000 | Wen Gao 0001
--  2001 | H. Vincent Poor
--  2002 | H. Vincent Poor
--  2003 | H. Vincent Poor
--  2004 | H. Vincent Poor
--  2005 | H. Vincent Poor
--  2006 | H. Vincent Poor
--  2007 | H. Vincent Poor
--  2008 | H. Vincent Poor
--  2009 | H. Vincent Poor
--  2010 | H. Vincent Poor
--  2011 | H. Vincent Poor
--  2012 | H. Vincent Poor
--  2013 | H. Vincent Poor
--  2014 | H. Vincent Poor
--  2015 | H. Vincent Poor
--  2016 | H. Vincent Poor
--  2017 | H. Vincent Poor
--  2018 | Yang Liu
--  2019 | Yang Liu
--  2020 | Yang Liu
--  2021 | Yang Liu
-- (90 rows)
DROP VIEW Decade_Author_Pub_Count;

-- Part 7
-- Find the institutions that have published most papers in STOC
CREATE VIEW Author_Institution AS
  SELECT id, SPLIT_PART(homepage, '/', 3) AS institution
  FROM Author
  WHERE homepage IS NOT NULL;

CREATE VIEW STOC_Publication AS
  SELECT DISTINCT pub.pubkey FROM Publication pub WHERE pub.pubkey LIKE 'conf/stoc/%';

SELECT a_i.institution, COUNT(DISTINCT a_ed.pubid) AS pub_count
FROM STOC_Publication s_pub, Publication pub, Authored a_ed, Author_Institution a_i
WHERE s_pub.pubkey = pub.pubkey AND pub.pubid = a_ed.pubid AND a_ed.id = a_i.id
GROUP BY a_i.institution
ORDER BY pub_count DESC
LIMIT 20;
-- Result:
--         institution        | pub_count 
-- ---------------------------+-----------
--  orcid.org                 |       512
--  mathgenealogy.org         |       445
--  www.wikidata.org          |       443
--  scholar.google.com        |       391
--  en.wikipedia.org          |       371
--  zbmath.org                |       338
--  id.loc.gov                |       298
--  dl.acm.org                |       245
--  isni.org                  |       160
--  viaf.org                  |       119
--  d-nb.info                 |        93
--  www.cs.cmu.edu            |        58
--  www1.cs.columbia.edu      |        50
--  www-2.cs.cmu.edu          |        37
--  www.cs.princeton.edu      |        37
--  www.wisdom.weizmann.ac.il |        35
--  research.microsoft.com    |        34
--  www.researcherid.com      |        30
--  www.cs.brown.edu          |        29
--  www-cse.ucsd.edu          |        28
-- (20 rows)

-- Find the institutions that have published most papers in PODS
SELECT a_i.institution, COUNT(DISTINCT a_ed.pubid) AS pub_count
FROM PODS_Publication p_pub, Publication pub, Authored a_ed, Author_Institution a_i
WHERE p_pub.pubkey = pub.pubkey AND pub.pubid = a_ed.pubid AND a_ed.id = a_i.id
GROUP BY a_i.institution
ORDER BY pub_count DESC
LIMIT 20;
-- Result:
--      institution     | pub_count 
-- ---------------------+-----------
--  scholar.google.com  |       207
--  dl.acm.org          |       173
--  orcid.org           |       169
--  www.wikidata.org    |       162
--  en.wikipedia.org    |       153
--  mathgenealogy.org   |       104
--  id.loc.gov          |        89
--  isni.org            |        89
--  zbmath.org          |        43
--  www.soe.ucsc.edu    |        36
--  openlibrary.org     |        32
--  twitter.com         |        32
--  viaf.org            |        26
--  www.cs.indiana.edu  |        22
--  www.cs.huji.ac.il   |        22
--  www.cs.rutgers.edu  |        21
--  www.comlab.ox.ac.uk |        19
--  www.cs.duke.edu     |        19
--  www.cs.cmu.edu      |        19
--  www.linkedin.com    |        18
