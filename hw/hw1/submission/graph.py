import psycopg3
import math
import matplotlib.pyplot as plt

# Connect to an existing database
with psycopg3.connect("dbname=dblp user=cosmo") as conn:

    # Open a cursor to perform database operations
    with conn.cursor() as cur:
      collaborator_query = """
        SELECT collaborator_count, COUNT(id)
        FROM (
          SELECT id1 AS id, COUNT(DISTINCT id2) AS collaborator_count
          FROM Coauthor
          GROUP BY id1
        ) AS Collaborator_Count
        GROUP BY collaborator_count
        ORDER BY collaborator_count;
        """
      cur.execute(collaborator_query)
      rows = cur.fetchall()
      x = [row[0] for row in rows]
      y = [math.log(row[1]) for row in rows]
      plt.plot(x, y)
      plt.xlabel("Number of Collaborators")
      plt.ylabel("Number of Authors")
      plt.savefig("collaborators.png")

      

      publication_query = """
        SELECT publication_count, COUNT(id)
        FROM (
          SELECT id, COUNT(DISTINCT pubid) AS publication_count
          FROM Authored
          GROUP BY id
        ) AS Publication_Count
        GROUP BY publication_count
        ORDER BY publication_count;
        """
      cur.execute(publication_query)
      rows = cur.fetchall()
      x = [row[0] for row in rows]
      y = [math.log(row[1]) for row in rows]
      plt.plot(x, y)
      plt.xlabel("Number of Publications")
      plt.ylabel("Number of Authors")
      plt.savefig("publications.png")