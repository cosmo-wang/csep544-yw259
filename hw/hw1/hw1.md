# CSE 544 Homework 1: Data Analytics Pipeline

**Objectives:** To get familiar with the main components of the data analytic pipeline: schema design, data acquisition, data transformation, querying, and visualizing.

**Assignment tools:** postgres, excel (or some other tool for visualization)

**Assigned date:** March 29, 2021

**Due date:** April 16, 2021

**Questions:**  on the [Ed discussion board](https://edstem.org/us/courses/4960/discussion/).

**What to turn in:** These files: `pubER.pdf`, `createPubSchema.sql`, `importPubData.sql`, `solution.sql`, `graph.py`, `graph.pdf`. Your `solution.sql` file should be executable using the command `psql -f solution.sql`

Turn in your solution on [CSE's GitLab](https://gitlab.cs.washington.edu). 
See [submission instructions](#submission) below.


**Motivation:** In this homework you will implement a basic data
analysis pipeline: data acquisition, transformation and extraction,
cleaning, analysis and sharing of results.  The data is
[DBLP](http://www.informatik.uni-trier.de/~ley/db/), the reference
citation website created and maintained by Michael Ley. The analysis
will be done in postgres. The visualization will be done in python.


**Resources:**

- [postgres](https://www.postgresql.org/)

- starter code



# Problems

## Problem 1: Conceptual Design

Design and create a database schema about publications.  We will refer to this schema as `PubSchema`, and to the data as `PubData`.
- E/R Diagram. Design the E/R diagram, consisting of the entity sets and relationships below. Draw the E/R diagram for this schema,  identify all keys in all entity sets, and indicate the correct type of all relationships (many-many or many-one); make sure you use the ISA box where needed.
  - `Author` has  attributes: `id` (a key; must be unique),  `name`, and `homepage` (a URL)
  - `Publication` has  attributes: `pubid` (the key -- an integer), `pubkey` (an alternative key, text; must be unique), `title`, and `year`. It has the following subclasses:
    - `Article` has additional attributes:  `journal`, `month`, `volume`, `number`
    - `Book`  has additional attributes:  `publisher`, `isbn`
    - `Incollection` has additional attributes:  `booktitle`, `publisher`, `isbn`
    - `Inproceedings` has additional attributes:  `booktitle`, `editor`
  - There is a many-many relationship `Authored` from `Author` to `Publication`
  - Refer to Chapter 2, "Introduction to Database Design," and Chapter 3.5, "Logical Database Design: ER to Relational" in R&G if you need additional references.

**Turn in** the file `pubER.pdf`

## Problem 2: Schema Design

Here you will create the SQL tables in a database in postgres.  First, check that you have installed postgres on your computer.  Then, create an empty database by running the following command:

```sh
$ createdb dblp
```

If you need to restart, then delete it by running:

```sh
$ dropdb dblp
```

To run queries in postgres, type:

```sh
$ psql dblp
```
then type in your SQL commands.  Remember three special commands:

```sh
\q -- quit psql
\h -- help
\? -- help for meta commands
```

Next, design the SQL tables that implement your conceptual schema (the E/R diagram).   We will call this database schema the  `PubSchema`.  Write `create Table` SQL statements, e.g.:

```sql
create Table Author (...);
...
```

Choose `int` and `text` for all data types.  Create keys, foreign
keys, and unique constraints, as needed; you may either do it within
`CREATE TABLE`, or postpone this for later and use `ALTER TABLE`.  Do
NOT use the `inherit` or `pivot` functionality in postgres, instead
use the simple design principles discussed in class.

Write all your commands in a file called  `createPubSchema.sql`.  You can execute them in two ways.  Start postgres interactively and copy/paste your commands one by one. Or, from the command line run:

```sh
psql -f createPubSchema.sql dblp
```

Hint: for debugging purposes, insert `drop Table` commands at the beginning of the `createPubSchema.sql` file:

```sql
drop table if exists Author;
...
```

**Turn in** the file  `createPubSchema.sql`.


## Problem 3: Data Acquisition

Typically, this step consists of downloading data, or extracting it with a
software tool, or inputting it manually, or all of the above.  Then it involves
writing and running some python script, called a *wrapper* that
reformats the data into some CSV format that we can upload to the database.

Download the DBLP data `dblp.dtd` and `dblp.xml.gz` from the dblp [website](http://dblp.uni-trier.de/xml/), then unzip the xml file.
Make sure you understand what data the  the big xml file contains: look inside by running:

```sh
more dblp.xml
```

If needed, edit the `wrapper.py` and update the   correct  location of `dblp.xml` and the output files `pubFile.txt`  and  `fieldFile.txt`, then run:

```sh
python wrapper.py
```

This will take several minutes, and produces two large files: `pubFile.txt` and `fieldFile.txt`. Before you proceed, make sure you understand what happened during this step, by looking inside these two files: they are tab-separated files, ready to be imported in postgres.

Next, edit the file `createRawSchema.sql` in the starter code to point to the correct path of `pubFile.txt` and `fieldFile.txt`: they  must be absolute paths, e.g. `/home/myname/mycourses/544/pubFile.txt`.   Then run:

```sh
psql -f createRawSchema.sql dblp
```

This creates two tables, `Pub` and `Field`, then imports the data (which may take a few minutes).  We will call these two tables `RawSchema` and  `RawData` respectively.


## Problem 4: Querying the Raw Data

During typical data ingestion, you sometimes need to discover the true schema of the data, and for that you need to query the  `RawData`.

Start `psql` then type the following commands:

```sql
select * from Pub limit 50;
select * from Field limit 50;
```

For example, go to the dblp [website](http://dblp.uni-trier.de/), check out this paper, search for `Henry M. Levy`, look for the "Vanish" paper, and export the entry in BibTeX format.  You should see the following in your browser

```bibtex
@inproceedings{DBLP:conf/uss/GeambasuKLL09,
  author    = {Roxana Geambasu and
               Tadayoshi Kohno and
               Amit A. Levy and
               Henry M. Levy},
  title     = {Vanish: Increasing Data Privacy with Self-Destructing Data},
  booktitle = {18th {USENIX} Security Symposium, Montreal, Canada, August 10-14,
               2009, Proceedings},
  pages     = {299--316},
  year      = {2009},
  crossref  = {DBLP:conf/uss/2009},
  url       = {http://www.usenix.org/events/sec09/tech/full_papers/geambasu.pdf},
  timestamp = {Thu, 15 May 2014 18:36:21 +0200},
  biburl    = {http://dblp.org/rec/bib/conf/uss/GeambasuKLL09},
  bibsource = {dblp computer science bibliography, http://dblp.org}
}
```


The **key** of this entry is `conf/uss/GeambasuKLL09`.  Try using this info by running this SQL query:

```sql
select * from Pub p, Field f where p.k='conf/uss/GeambasuKLL09' and f.k='conf/uss/GeambasuKLL09'
```


Write SQL Queries  to answer the following  questions using `RawSchema`:

- For each type of publication, count the total number of publications of that type. Your query should return a set of (publication-type, count) pairs. For example (article, 20000), (inproceedings, 30000), ... (not the real answer).

- We say that a field *occurs* in a publication type, if there exists at least one publication of that type having that field. For example, `publisher` occurs in `incollection`, but `publisher` does not occur in `inproceedings`. Find the fields that occur in *all* publications types. Your query should return a set of field names: for example it may return title, if  title occurs in all publication types (article, inproceedings, etc. notice that title does not have to occur in every publication instance, only in some instance of every type), but it should not return publisher (since the latter does not occur in any publication of type inproceedings).

- Your two queries above may be slow. Speed them up by creating appropriate indexes, using the CREATE INDEX statement. You also need indexes on `Pub` and `Field` for the next question; create all indices you need on `RawSchema`

**Turn in** a file  `solution.sql` consising of SQL queries and all their answers inserted as comments


## Problem 5: Data Transformation.

Next, you will transform the DBLP data from `RawSchema` to  `PubSchema`.  This step is sometimes done using an ETL tool, but we will just use several SQL queries.  You need to write queries to  populate the tables in `PubSchema`. For example, to populate `Article`, you will likely run a SQL query like this:

```sql
insert into Article (select ... from Pub, Field ... where ...);
```

The `RawSchema` and `PubSchema` are quite different, so you will need to go through some trial and error to get the transformation right.  Here are a few hints (but your approach may vary):

- create temporary tables (and indices) to speedup the data transformation. Remember to drop all your temp tables when you are done

- it is very inefficient to bulk insert into a table that contains a key and/or foreign keys (why?); to speed up, you may drop the key/foreign key constraints, perform the bulk insertion, then `alter Table` to create the constraints.

- `PubSchema` requires an  integer key for each author and each publication. Use a `sequence` in postgres. For example, try this and see what happens:

```sql
create table R(a text);
insert into R values ('a');
insert into R values ('b');
insert into R values ('c');
create table S(id int, a text);
create sequence q;
insert into S (select nextval('q') as id, a from R);
drop sequence q;
select * from S;
```
- DBLP knows the Homepage of some authors, and you need to store these in the Author table. But where do you find homepages in `RawData`? DBLP uses a hack. Some publications of type `www` are not publications, but instead represent homepages. For example Hank's official name in DBLP is 'Henry M. Levy'; to find his homepage, run the following query (this  should run  very fast,  1 second or less, if you created the right indices):

```sql
select z.* from Pub x, Field y, Field z where x.k=y.k and y.k=z.k and x.p='www' and y.p='author' and y.v='Henry M. Levy';
```

Get it? Now you know Hank's homepage. However, you are not there yet. Some www entries are not homepages, but are real publications. Try this:

```sql
select z.* from Pub x, Field y, Field z where x.k=y.k and y.k=z.k and x.p='www' and y.p='author' and y.v='Dan Suciu'
```

Your challenge is to find out how to identify each author's correct Homepage. (A small number of authors have two correct, but distinct homepages; you may choose any of them to insert in Author)

- What if a publication in `RawData` has two titles? Or two `publishers`? Or two `years`? (You will encounter duplicate fields, but not necessarily these ones.) You may pick any of them, but you need to work a little to write this in SQL.

**Turn in** the file `importPubData.sql` containing several `insert`, `create Table`, `alter Table`, etc  statements.

## Problem 6: Run Data Analytic Queries

Finally, you reached the fun part. Write SQL queries to answer the following questions:

- Find the top 20 authors with the largest number of publications. (Runtime: under 10s)

- Find the top 20 authors with the largest number of publications in STOC. Repeat this for two more conferences, of your choice.  Suggestions: top 20 authors in SOSP, or CHI, or SIGMOD, or SIGGRAPH; note that you need to do some digging to find out how DBLP spells the name of your conference. (Runtime: under 10s.)

- The two major database conferences are 'PODS' (theory) and 'SIGMOD Conference' (systems). Find
    - (a). all authors who published at least 10 SIGMOD papers but never published a PODS paper, and 
    - (b). all authors who published at least 5 PODS papers but never published a SIGMOD paper. (Runtime: under 10s)

- A decade is a sequence of ten consecutive years, e.g. 1982, 1983, ..., 1991. For each decade, compute the total number of publications in DBLP in that decade. Hint: for this and the next query you may want to compute a temporary table with all distinct years. (Runtime: under 1minute.)

- Find the top 20 most collaborative authors. That is, for each author determine its number of collaborators, then find the top 20. Hint: for this and some question below you may want to compute a temporary table of coauthors. (Runtime: a couple of minutes.)

- For each decade, find the most prolific author in that decade. Hint: you may want to first compute a temporary table, storing for each decade and each author the number of publications of that author in that decade. Runtime: a few minutes.

- Find the institutions that have published most papers in STOC; return the top 20 institutions. Then repeat this query with your favorite conference (SOSP or CHI, or ...), and see which are the best places and you didn't know about. Hint: where do you get information about institutions? Use the Homepage information: convert a Homepage like <http://www.cs.washington.edu/homes/levy/> to <http://www.cs.washington.edu>, or even to www.cs.washington.edu; now you have grouped all authors from our department, and we use this URL as surrogate for the institution.  Read about substring manipulation in postres, by looking up `substring`, `position`, and `trim`.


**Turn in** SQL queries in the file called `solution.sql`.

## Problem 7: Data Visualization.

Here you are asked to create some histograms (graphs), by writing a python script that first runs a query, then produces a graph using the result of the query.  

Construct two histograms: the histogram of the number of collaborators, and the histogram of the number of publications.  The first histograph will have these axes:

- the X axis is a number X=1,2,3,...
- the Y axis represents the number of authors with X collaborators: Y(0)= number of authors with 0 collaborators, Y(1) = number of authors with 1 collaborator, etc

Similarly for the second histogram.  Try using a log scale, or a log-log scale, and choose the most appropriate.  Feel free to produce a very nice graph (not necessarily a histogram).

Resources:
- Accessing postgres from python [tutorial](https://wiki.postgresql.org/wiki/Psycopg2_Tutorial); see also `pythonpsql.py` in the starter code
- [Plotpy library](https://plot.ly/python/)

**Turn in** a file `graph.py` and the output it generated in a file `graph.pdf`

# Submission Instructions
<a name="submission"></a>

We will be using `git`, a source code control tool, for distributing and submitting homework assignments in this class.
This will allow you to download the code and instruction for the homework, 
and also submit the labs in a standardized format that will streamline grading.

You will also be able to use `git` to commit your progress on the labs
as you go. This is **important**: Use `git` to back up your work. Back
up regularly by both committing and pushing your code as we describe below.

Course git repositories will be hosted as a repository in [CSE's
gitlab](https://gitlab.cs.washington.edu/), that is visible only to
you and the course staff.

## Getting started with Git

There are numerous guides on using `git` that are available. They range from being interactive to just text-based. 
Find one that works and experiment -- making mistakes and fixing them is a great way to learn. 
Here is a [link to resources](https://help.github.com/articles/what-are-other-good-resources-for-learning-git-and-github) 
that GitHub suggests starting with. If you have no experience with `git`, you may find this 
[web-based tutorial helpful](https://try.github.io/levels/1/challenges/1).

Git may already be installed in your environment; if it's not, you'll need to install it first. 
For `bash`/`Linux` environments, git should be a simple `apt-get` / `yum` / etc. install. 
More detailed instructions may be [found here](http://git-scm.com/book/en/Getting-Started-Installing-Git).
Git is already installed on the CSE linux machines.

If you are using Eclipse or IntelliJ, many versions come with git already configured. 
The instructions will be slightly different than the command line instructions listed but will work 
for any OS. For Eclipse, detailed instructions can be found at 
[EGit User Guide](http://wiki.eclipse.org/EGit/User_Guide) or the
[EGit Tutorial](http://eclipsesource.com/blogs/tutorials/egit-tutorial).


## Cloning your repository for homework assignments

We have created a git repository that you will use to commit and submit your the homework assignments. 
This repository is hosted on the [CSE's GitLab](https://gitlab.cs.washington.edu) , 
and you can view it by visiting the GitLab website at 
`https://gitlab.cs.washington.edu/csep544-2021sp/csep544-[your CSE or UW username]`. 

You'll be using this **same repository** for each of the homework assignments this quarter, 
so if you don't see this repository or are unable to access it, let us know immediately!

The first thing you'll need to do is set up a SSH key to allow communication with GitLab:

1.  If you don't already have one, generate a new SSH key. See [these instructions](http://doc.gitlab.com/ce/ssh/README.html) for details on how to do this.
2.  Visit the [GitLab SSH key management page](https://gitlab.cs.washington.edu/profile/keys). You'll need to log in using your CSE account.
3.  Click "Add SSH Key" and paste in your **public** key into the text area.

While you're logged into the GitLab website, browse around to see which projects you have access to. 
You should have access to `csep544-[your CSE or UW username]`. 
Spend a few minutes getting familiar with the directory layout and file structure. For now nothing will
be there except for the `hw1` directory with these instructions.

We next want to move the code from the GitLab repository onto your local file system. 
To do this, you'll need to clone the 544 repository by issuing the following commands on the command line:

```sh
$ cd [directory that you want to put your 544 assignments]
$ git clone git@gitlab.cs.washington.edu:csep544-2021sp/csep544-[your CSE or UW username].git
$ cd csep544-[your CSE or UW username]
```

This will make a complete replica of the repository locally. If you get an error that looks like:

```sh
Cloning into 'csep544-[your CSE or UW username]'...
Permission denied (publickey).
fatal: Could not read from remote repository.
```

... then there is a problem with your GitLab configuration. Check to make sure that your GitLab username matches the repository suffix, that your private key is in your SSH directory (`~/.ssh`) and has the correct permissions, and that you can view the repository through the website.

Cloning will make a complete replica of the homework repository locally. Any time you `commit` and `push` your local changes, they will appear in the GitLab repository.  Since we'll be grading the copy in the GitLab repository, it's important that you remember to push all of your changes!

## Adding an upstream remote

The repository you just cloned is a replica of your own private repository on GitLab. 
The copy on your file system is a local copy, and the copy on GitLab is referred to as the `origin` remote copy.  You can view a list of these remote links as follows:

```sh
$ git remote -v
```

There is one more level of indirection to consider.
When we created your `csep544-[your CSE or UW username]` repository, we forked a copy of it from another 
repository `csep544-2021sp`.  In `git` parlance, this "original repository" referred to as an `upstream` repository.
When we release bug fixes and subsequent homeworks, we will put our changes into the upstream repository, and you will need to be able to pull those changes into your own.  See [the documentation](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes) for more details on working with remotes -- they can be confusing!

In order to be able to pull the changes from the upstream repository, we'll need to record a link to the `upstream` remote in your own local repository:

```sh
$ # Note that this repository does not have your username as a suffix!
$ git remote add upstream git@gitlab.cs.washington.edu:suciu/csep544-2021sp.git
```

For reference, your final remote configuration should read like the following when it's setup correctly:

```sh
$ git remote -v
  origin  git@gitlab.cs.washington.edu:csep544-2021sp/csep544-[your CSE username].git (fetch)
  origin  git@gitlab.cs.washington.edu:csep544-2021sp/csep544-[your CSE username].git (push)
  upstream    git@gitlab.cs.washington.edu:suciu/csep544-2021sp.git (fetch)
  upstream    git@gitlab.cs.washington.edu:suciu/csep544-2021sp.git (push)
```

In this configuration, the `origin` (default) remote links to **your** repository 
where you'll be pushing your individual submission. The `upstream` remote points to **our** 
repository where you'll be pulling subsequent homework and bug fixes (more on this below).

Let's test out the origin remote by doing a push of your master branch to GitLab. Do this by issuing the following commands:

```sh
$ touch empty_file
$ git add empty_file
$ git commit empty_file -m 'Testing git'
$ git push # ... to origin by default
```

The `git push` tells git to push all of your **committed** changes to a remote.  If none is specified, `origin` is assumed by default (you can be explicit about this by executing `git push origin`).  Since the `upstream` remote is read-only, you'll only be able to `pull` from it -- `git push upstream` will fail with a permission error.

After executing these commands, you should see something like the following:

```sh
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 286 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
To git@gitlab.cs.washington.edu:csep544-2021sp/csep544-[your CSE or UW username].git
   cb5be61..9bbce8d  master -> master
```

We pushed a blank file to our origin remote, which isn't very interesting. Let's clean up after ourselves:

```sh
$ # Tell git we want to remove this file from our repository
$ git rm empty_file
$ # Now commit all pending changes (-a) with the specified message (-m)
$ git commit -a -m 'Removed test file'
$ # Now, push this change to GitLab
$ git push
```

If you don't know Git that well, this probably seemed very arcane. Just keep using Git and you'll understand more and more. We'll provide explicit instructions below on how to use these commands to actually indicate your final lab solution.

## Pulling from the upstream remote

If we release additional details or bug fixes for this homework, 
we'll push them to the repository that you just added as an `upstream` remote. You'll need to `pull` and `merge` them into your own repository. (You'll also do this for subsequent homeworks!) You can do both of these things with the following command:

```sh
$ git pull upstream master
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 2), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.
From gitlab.cs.washington.edu:csep544-2021sp/csep544-2021sp
 * branch            master     -> FETCH_HEAD
   7f81148..b0c4a3e  master     -> upstream/master
Merge made by the 'recursive' strategy.
 README.md | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Here we pulled and merged changes to the `README.md` file. Git may open a text editor to allow you to specify a merge commit message; you may leave this as the default. Note that these changes are merged locally, but we will eventually want to push them to the GitLab repository (`git push`).

Note that it's possible that there aren't any pending changes in the upstream repository for you to pull.  If so, `git` will tell you that everything is up to date.


## Collaboration

All CSE 544 assignments are to be completed **INDIVIDUALLY**! However, you may discuss your high-level approach to solving each lab with other students in the class.

## Submitting your assignment

You may submit your code multiple times; we will use the latest version you submit that arrives 
before the deadline. 
Put all your files(`pubER.pdf`, `createPubSchema.sql`, `solution.sql`, `importPubData.sql`, `graph.py`, `graph.pdf`) in `hw1/submission`. Your directory structure should 
look like this after you have completed the assignment: 

```sh
csep544-[your CSE or UW username]
\-- README.md
\-- hw1
    \-- hw1.md      # this is the file that you are currently reading
    \-- submission
        \-- pubER.pdf  # your solution to question 1
        \-- createPubSchema.sql  # your solution to question 2
        \-- solution.sql  # your solution to question 3
        ...
```

**Important**: In order for your write-up to be added to the git repo, you need to explicitly add it:

```sh
$ cd submission
$ git add pubER.pdf createPubSchema.sql ...
```

Or if you do
```sh
$ git add submission
```

Then it will add *all* the files inside the `submission` directory to the repo.

The criteria for your homework being submitted on time is that your code must
pushed by the due date and time. This means that if one of the TAs or the instructor were to open up GitLab, they would be able to see your solutions on the GitLab web page.

**Just because your code has been committed on your local machine does not mean that it has been submitted -- it needs to be on GitLab!**

## Final Word of Caution!

Git is a distributed version control system. This means everything operates offline until you run `git pull` or `git push`. This is a great feature.

The bad thing is that you may **forget to `git push` your changes**. This is why we strongly, strongly suggest that you **check GitLab to be sure that what you want us to see matches up with what you expect**.  As a second sanity check, you can re-clone your repository in a different directory to confirm the changes:

```sh
$ git clone git@gitlab.cs.washington.edu:csep544-2021sp/csep544-[your CSE or UW username].git confirmation_directory
$ cd confirmation_directory
$ # ... make sure everything is as you expect ...
```