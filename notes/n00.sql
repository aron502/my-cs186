-- 1
SELECT name FROM dogs
WHERE ownerid = 3;

-- 2
SELECT name, age FROM dogs
ORDER BY age DESC, name
LIMIT 5;

-- 3
SELECT breed, COUNT(*)
FROM dogs
GROUP BY breed
HAVING COUNT(*) > 1;