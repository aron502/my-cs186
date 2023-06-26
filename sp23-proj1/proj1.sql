-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %' -- now I know single quote vs double quote in sql
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*) as count -- At the end, I found I shouldn't write so many AS
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT *
  FROM q1iii
  WHERE avgheight > 70;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, yearid
  FROM people p INNER JOIN halloffame h
  ON p.playerid = h.playerid
  WHERE inducted = 'Y'
  ORDER BY yearid DESC, p.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q.playerid, s.schoolid, yearid
  FROM q2i q INNER JOIN collegeplaying c
  ON q.playerid = c.playerid
  INNER JOIN schools s
  ON c.schoolid = s.schoolid
  WHERE s.schoolstate = 'CA'
  ORDER BY yearid DESC, s.schoolid, q.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, namefirst, namelast, schoolid
  FROM q2i q LEFT OUTER JOIN collegeplaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerid, namefirst, namelast, yearid, (h + h2b + 2 * h3b + 3 * hr) * 1.0 / ab AS slg
  FROM batting b INNER JOIN people p
  ON b.playerid = p.playerid
  WHERE b.ab > 50
  ORDER BY slg DESC, yearid, b.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT b.playerid, namefirst, namelast, (SUM(h) + SUM(h2b) + 2 * SUM(h3b) + 3 * SUM(hr)) * 1.0 / SUM(ab) as lslg
  FROM batting b INNER JOIN people p
  ON b.playerid = p.playerid
  GROUP BY b.playerid
  HAVING SUM(ab) > 50
  ORDER BY lslg DESC, b.playerid
  LIMIT 10
;

-- Question 3iii
-- CREATE VIEW allslg(playerid, namefirst, namelast, lslg)
-- AS
--   SELECT b.playerid, namefirst, namelast, (SUM(h) + SUM(h2b) + 2 * SUM(h3b) + 3 * SUM(hr)) * 1.0 / SUM(ab) as lslg
--   FROM batting b INNER JOIN people p
--   ON b.playerid = p.playerid
--   GROUP BY b.playerid
--   HAVING SUM(ab) > 50
--   ORDER BY lslg DESC, b.playerid
-- ;

CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg
  FROM allslg
  WHERE lslg > (
    SELECT lslg
    FROM allslg
    WHERE playerid = 'mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary) AS min, MAX(salary) AS max, AVG(salary) AS avg
  FROM people p INNER JOIN salaries s
  ON p.playerid = s.playerid
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
-- CREATE VIEW salary_range(min, max, width)
-- AS
--   SELECT MIN(salary) AS min, MAX(salary) AS max, CAST( (max - min) / 10 AS INT)
--   FROM salaries
--   WHERE yearid = 2016
-- ;
-- min = 507500, max = 33000000, width = 3249250

CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, 507500.0 + binid * 3249250, 3756750.0 + binid * 3249250, COUNT(*)
  FROM binids, salaries
  WHERE (salary between 507500.0 + binid * 3249250 AND 3756750.0 + binid * 3249250) and yearid = 2016
  GROUP BY binid
;

-- Question 4iii
-- CREATE VIEW allyear(yearid, min, max, avg)
-- AS
--   SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
--   FROM salaries
--   GROUP BY yearid
--   ORDER BY yearid
-- ;


CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT a1.yearid, a1.min - a2.min, a1.max - a2.max, a1.avg - a2.avg
  FROM allyear a1 INNER JOIN allyear a2
  ON a1.yearid - 1 = a2.yearid
  ORDER BY a1.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT s.playerid, namefirst, namelast, salary, yearid
  FROM salaries s INNER JOIN people p
  ON s.playerid = p.playerid
  WHERE (yearid = 2000 AND salary = (
    SELECT MAX(salary)
    FROM salaries
    WHERE yearid = 2000))
    OR
    (yearid = 2001 AND salary = (
    SELECT MAX(salary)
    FROM salaries
    WHERE yearid = 2001))
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(salary) - MIN(salary)
  FROM allstarfull a INNER JOIN salaries s
  ON a.playerid = s.playerid AND a.yearid = s.yearid
  WHERE s.yearid = 2016
  GROUP BY a.teamid
;

