-- 1
SELECT d.name
FROM dogs AS d INNER JOIN users AS u
ON d.ownerid = u.userid
WHERE u.name = "Josh Hug"

-- 2
SELECT d.name
FROM dogs AS d, users AS u
WHERE d.ownerid = u.userid AND u.name = "Josh Hug"

-- 3
SELECT u.name, COUNT(*) AS dognums
FROM dogs AS d INNER JOIN users AS u
GROUP BY d.ownerid, u.name
ORDER BY dognums DESC
LIMIT 1

-- 4
SELECT u.name, COUNT(*) -- Initially, I labeled COUNT(*) AS dognums, but this was incorrect because the 'select' clause in SQL hadn't been executed when accessing the 'group'.
FROM dogs AS d INNER JOIN users AS u
ON d.ownerid = u.userid
GROUP BY u.userid, u.name
HAVING COUNT(*) >= ALL(
    SELECT COUNT(*)
    FROM dogss
    GROUP BY ownerid)
