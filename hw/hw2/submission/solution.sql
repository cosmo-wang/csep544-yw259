-- Problem 4: Run Queries
-- 1
SELECT s.S_NAME AS supplier, COUNT(DISTINCT ps.PS_PARTKEY) AS count
FROM Partsupp ps, Supplier s
WHERE ps.PS_SUPPKEY = s.S_SUPPKEY
GROUP BY s.S_NAME;

-- 2
SELECT MAX(supplier_max_cost.max_cost)
FROM (
  SELECT MAX(ps.PS_SUPPLYCOST) AS max_cost
  FROM Partsupp ps
  GROUP BY ps.PS_SUPPKEY
) AS supplier_max_cost;

-- 3
SELECT s.S_NAME AS supplier, MAX(ps.PS_SUPPLYCOST) AS max_cost
FROM Partsupp ps, Supplier s
WHERE ps.PS_SUPPKEY = s.S_SUPPKEY
GROUP BY s.S_NAME;

-- 4
SELECT n.N_NAME AS nation, Count(c.C_CUSTKEY) AS customer_count
FROM Customer c, Nation n
WHERE c.C_NATIONKEY = n.N_NATIONKEY
GROUP BY n.N_NAME;

-- 5
SELECT s.S_NAME AS supplier, COUNT(DISTINCT l.L_PARTKEY) AS count
FROM Supplier s, Lineitem l
WHERE l.L_SUPPKEY = s.S_SUPPKEY AND l.L_SHIPDATE BETWEEN '1996-10-10 00:00:00' AND '1996-11-10 23:59:59'
GROUP BY s.S_NAME;
