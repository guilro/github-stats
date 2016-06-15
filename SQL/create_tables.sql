DROP TABLE IF EXISTS tmp_new_watchers;
CREATE TABLE tmp_new_watchers
SELECT
	watchers.repo_id,
	CASE
		WHEN YEAR(watchers.created_at) < 2012 THEN 0
		ELSE MONTH(watchers.created_at)
	END AS month,
	COUNT(watchers.user_id) AS new_watchers
FROM watchers
WHERE YEAR(watchers.created_at) <= 2012
GROUP BY
	CASE
		WHEN YEAR(watchers.created_at) < 2012 THEN 0
		ELSE MONTH(watchers.created_at)
	END,
	watchers.repo_id
;

CREATE INDEX watchers_repo_id ON tmp_new_watchers (repo_id);
CREATE INDEX watchers_month ON tmp_new_watchers (month);

DROP TABLE IF EXISTS tmp_new_forks;
CREATE TABLE tmp_new_forks
SELECT
	forks.forked_from_id AS repo_id,
	CASE
		WHEN YEAR(forks.created_at) < 2012 THEN 0
		ELSE MONTH(forks.created_at)
	END AS month,
	COUNT(forks.fork_id) AS new_forks
FROM forks
WHERE YEAR(forks.created_at) <= 2012
GROUP BY
	CASE
		WHEN YEAR(forks.created_at) < 2012 THEN 0
		ELSE MONTH(forks.created_at)
	END,
	forks.forked_from_id
;

CREATE INDEX forks_repo_id ON tmp_new_forks (repo_id);
CREATE INDEX forks_month ON tmp_new_forks (month);

DROP TABLE IF EXISTS tmp_new_repos;
CREATE TABLE tmp_new_repos
SELECT
	projects.owner_id AS user_id,
	CASE
		WHEN YEAR(projects.created_at) < 2012 THEN 0
		ELSE MONTH(projects.created_at)
	END AS month,
	COUNT(projects.id) AS new_repos
FROM users_2012random
INNER JOIN projects ON projects.owner_id = users_2012random.id
WHERE YEAR(projects.created_at) <= 2012
GROUP BY
	CASE
		WHEN YEAR(projects.created_at) < 2012 THEN 0
		ELSE MONTH(projects.created_at)
	END,
	projects.owner_id
;

CREATE INDEX forks_repo_id ON tmp_new_repos (user_id);
CREATE INDEX forks_month ON tmp_new_repos (month);

DROP TABLE IF EXISTS tmp_new_followers;
CREATE TABLE tmp_new_followers
SELECT
	users_2012random.id AS user_id,
	CASE
		WHEN YEAR(followers.created_at) < 2012 THEN 0
		ELSE MONTH(followers.created_at)
	END AS month,
	COUNT(followers.follower_id) AS new_followers
FROM users_2012random
JOIN followers ON followers.user_id = users_2012random.id
WHERE YEAR(followers.created_at) <= 2012
GROUP BY
	CASE
		WHEN YEAR(followers.created_at) < 2012 THEN 0
		ELSE MONTH(followers.created_at)
	END,
	users_2012random.id
;

DROP TABLE IF EXISTS tmp_new_watchers_and_forks;
CREATE TABLE tmp_new_watchers_and_forks
SELECT tmp_new_forks.repo_id, tmp_new_forks.month, tmp_new_forks.new_forks, tmp_new_watchers.new_watchers
FROM tmp_new_forks
LEFT JOIN tmp_new_watchers
ON tmp_new_forks.month = tmp_new_watchers.month
	AND tmp_new_forks.repo_id = tmp_new_watchers.repo_id
UNION
SELECT tmp_new_watchers.repo_id, tmp_new_watchers.month, tmp_new_forks.new_forks, tmp_new_watchers.new_watchers
FROM tmp_new_forks
RIGHT JOIN tmp_new_watchers
ON tmp_new_watchers.month = tmp_new_forks.month
	AND tmp_new_watchers.repo_id = tmp_new_forks.repo_id
;
CREATE INDEX repo_id ON tmp_new_watchers_and_forks (repo_id);
CREATE INDEX month ON tmp_new_watchers_and_forks (month);



DROP TABLE IF EXISTS tmp_new_waf_per_user;
CREATE TABLE tmp_new_waf_per_user
SELECT users_2012random.id AS user_id,
			tmp_new_watchers_and_forks.month,
			IFNULL(SUM(tmp_new_watchers_and_forks.new_watchers), 0) AS new_watchers,
			IFNULL(SUM(tmp_new_watchers_and_forks.new_forks), 0) AS new_forks
FROM users_2012random
INNER JOIN projects ON projects.owner_id = users_2012random.id
INNER JOIN tmp_new_watchers_and_forks ON projects.id = tmp_new_watchers_and_forks.repo_id
WHERE YEAR(projects.created_at) <= 2012
GROUP BY owner_id, month;
CREATE INDEX repo_id ON tmp_new_waf_per_user (user_id);
CREATE INDEX month ON tmp_new_waf_per_user (month);

DROP TABLE IF EXISTS tmp_new_waff_per_user;
CREATE TABLE tmp_new_waff_per_user
SELECT tmp_new_followers.user_id,
			tmp_new_followers.month,
			tmp_new_followers.new_followers,
			IFNULL(tmp_new_waf_per_user.new_watchers, 0) AS new_watchers,
			IFNULL(tmp_new_waf_per_user.new_forks, 0) AS new_forks
FROM tmp_new_followers
LEFT JOIN tmp_new_waf_per_user
ON tmp_new_followers.user_id = tmp_new_waf_per_user.user_id
	AND tmp_new_followers.month = tmp_new_waf_per_user.month
UNION
SELECT tmp_new_waf_per_user.user_id AS user_id,
			tmp_new_waf_per_user.month,
			IFNULL(tmp_new_followers.new_followers, 0),
			tmp_new_waf_per_user.new_watchers,
			tmp_new_waf_per_user.new_forks
FROM tmp_new_followers
RIGHT JOIN tmp_new_waf_per_user
ON tmp_new_followers.user_id = tmp_new_waf_per_user.user_id
	AND tmp_new_followers.month = tmp_new_waf_per_user.month;

DROP TABLE IF EXISTS tmp_all_new_per_user;
CREATE TABLE tmp_all_new_per_user
SELECT tmp_new_waff_per_user.user_id,
			tmp_new_waff_per_user.month,
			tmp_new_waff_per_user.new_followers,
			tmp_new_waff_per_user.new_watchers,
			tmp_new_waff_per_user.new_forks,
			IFNULL(tmp_new_repos.new_repos, 0) AS new_repos
FROM tmp_new_waff_per_user
LEFT JOIN tmp_new_repos
ON tmp_new_waff_per_user.user_id = tmp_new_repos.user_id
	AND tmp_new_waff_per_user.month = tmp_new_repos.month
UNION
SELECT tmp_new_repos.user_id,
			tmp_new_repos.month,
			IFNULL(tmp_new_waff_per_user.new_followers, 0) AS new_followers,
			IFNULL(tmp_new_waff_per_user.new_watchers, 0) AS new_watchers,
			IFNULL(tmp_new_waff_per_user.new_forks, 0) AS new_forks,
			tmp_new_repos.new_repos AS new_repos
FROM tmp_new_waff_per_user
RIGHT JOIN tmp_new_repos
ON tmp_new_waff_per_user.user_id = tmp_new_repos.user_id
	AND tmp_new_waff_per_user.month = tmp_new_repos.month
;

DROP TABLE IF EXISTS tmp_commits_by_month;
CREATE TABLE tmp_commits_by_month
SELECT
	users_2012random.id AS user_id,
	CASE
		WHEN YEAR(commits.created_at) < 2012 THEN 0
		ELSE MONTH(commits.created_at)
	END AS month,
	IFNULL(SUM(IF(projects.owner_id = commits.author_id && projects.forked_from IS NULL, 0, 1)), 0) AS contributions,
	IFNULL(SUM(IF(projects.owner_id = commits.author_id && projects.forked_from IS NULL, 1, 0)), 0) AS own_projects
  FROM users_2012random
	JOIN commits ON commits.author_id = users_2012random.id
	JOIN projects ON commits.project_id = projects.id
	WHERE YEAR(commits.created_at) <= 2012
	GROUP BY
		CASE
			WHEN YEAR(commits.created_at) < 2012 THEN 0
			ELSE MONTH(commits.created_at)
		END,
		users_2012random.id
;

DROP TABLE IF EXISTS tmp_months;
CREATE TABLE tmp_months (id INT NOT NULL);
INSERT INTO tmp_months (id) VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

DROP TABLE IF EXISTS tmp_commits_with_all_month;
CREATE TABLE tmp_commits_with_all_month
SELECT user_month.user_id, user_month.month, IFNULL(tmp_commits_by_month.contributions, 0) AS contributions,
IFNULL(tmp_commits_by_month.own_projects, 0) AS own_projects
FROM tmp_commits_by_month
RIGHT JOIN (
	SELECT users_2012random.id AS user_id, tmp_months.id AS month
	FROM tmp_months
	JOIN users_2012random
) AS user_month ON tmp_commits_by_month.user_id = user_month.user_id AND tmp_commits_by_month.month = user_month.month;

DROP TABLE IF EXISTS users_2012random_stats;
CREATE TABLE users_2012random_stats
SELECT tmp_commits_with_all_month.user_id,
			tmp_commits_with_all_month.month,
			IFNULL(tmp_all_new_per_user.new_followers, 0) AS new_followers,
			IFNULL(tmp_all_new_per_user.new_watchers, 0) AS new_watchers,
			IFNULL(tmp_all_new_per_user.new_forks, 0) AS new_forks,
			IFNULL(tmp_all_new_per_user.new_repos, 0) AS new_repos,
			tmp_commits_with_all_month.contributions,
			tmp_commits_with_all_month.own_projects
FROM tmp_all_new_per_user
RIGHT JOIN tmp_commits_with_all_month
ON tmp_all_new_per_user.user_id = tmp_commits_with_all_month.user_id
	AND tmp_all_new_per_user.month = tmp_commits_with_all_month.month;
