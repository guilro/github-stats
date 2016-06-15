# this is to generate dataset for the whole year (without periodic desagregation)
# this can be run in R (even if it takes a few minutes, it should work)

con = dbConnect(RMySQL::MySQL(), dbname="econometrics_epog", username="root", password="root")

dbListTables(con)

# we can also copy the table from users_2012_random to use same data in agregate and disagregate version
res = dbSendQuery(con, "DROP TABLE IF EXISTS users_random;")
res = dbSendQuery(con, "CREATE TABLE users_random SELECT * FROM users WHERE type = 'USR' ORDER BY RAND() LIMIT 10000;")

dbClearResult(res)

res = dbSendQuery(con, "DROP TABLE IF EXISTS users_random_stats;")
res = dbSendQuery(con, "
CREATE table users_random_stats
SELECT
	users_sub1.*,
  IFNULL(projects_sub3.repositories, 0) AS repositories,
  IFNULL(projects_sub3.watchers, 0) AS watchers,
  IFNULL(projects_sub3.forks, 0) AS forks
FROM (
  SELECT
    users_random.id,
    IF(users_random.company IS NULL, 0, 1) AS company,
    IF(users_random.location IS NULL, 0, 1) AS location,
    IF(users_random.email IS NULL, 0, 1) AS email,
    users_random.created_at,
    COUNT(followers.follower_id) AS followers
  FROM users_random
  LEFT JOIN followers ON followers.user_id = users_random.id
  GROUP BY users_random.id
) AS users_sub1
LEFT JOIN (
  SELECT
    projects_sub2.owner_id,
    COUNT(projects_sub2.id) AS repositories,
    SUM(projects_sub2.watchers) AS watchers,
    SUM(projects_sub2.forks) AS forks
  FROM (
    SELECT projects_sub1.*, COUNT(forks.forked_project_id) AS forks
    FROM (
      SELECT projects.id, projects.owner_id, COUNT(watchers.user_id) AS watchers
      FROM projects
      LEFT JOIN watchers ON watchers.repo_id = projects.id
      GROUP BY projects.id
    ) AS projects_sub1
    LEFT JOIN forks ON forks.forked_from_id = projects_sub1.id
    GROUP BY projects_sub1.id
  ) AS projects_sub2
  GROUP BY projects_sub2.owner_id
) AS projects_sub3 ON projects_sub3.owner_id = users_sub1.id
")
dbClearResult(res)

res = dbSendQuery(con, "
  SELECT
    users_random_stats.*,
    IFNULL(commits_stats.contributions, 0) AS contributions,
    IFNULL(commits_stats.own_projects, 0) AS own_projects
  FROM users_random_stats
  LEFT JOIN (
    SELECT
      users_random_stats.id,
      SUM(IF(projects.owner_id = commits.author_id && projects.forked_from IS NULL, 0, 1)) AS contributions,
      SUM(IF(projects.owner_id = commits.author_id && projects.forked_from IS NULL, 1, 0)) AS own_projects
    FROM users_random_stats
    INNER JOIN commits ON commits.author_id = users_random_stats.id
    JOIN projects ON commits.project_id = projects.id
    GROUP BY users_random_stats.id
  ) AS commits_stats ON commits_stats.id = users_random_stats.id
")

users = dbFetch(res, n=-1)
beep("mario")
dbClearResult(res)

