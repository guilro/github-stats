CREATE table users_2012random_stats
SELECT
	users_all_stats.*,
  IFNULL(all_projects_stats.new_projects, 0) AS repositories,
  IFNULL(all_projects_stats.new_watchers, 0) AS watchers,
  IFNULL(all_projects_stats.new_forks, 0) AS forks
# start users_all_stats (id, created_at, month, new_followers)
FROM (
  SELECT
    users_random.id,
    #IF(users_random.company IS NULL, 0, 1) AS company,
    #IF(users_random.location IS NULL, 0, 1) AS location,
    #IF(users_random.email IS NULL, 0, 1) AS email,
    users_random.created_at,
		CASE
			WHEN YEAR(followers.created_at) < 2012 THEN 0
			ELSE MONTH(followers.created_at)
		END AS month,
    COUNT(followers.follower_id) AS new_followers
  FROM users_random
  LEFT JOIN followers ON followers.user_id = users_random.id
  GROUP BY
		CASE
			WHEN YEAR(followers.created_at) < 2012 THEN 0
			ELSE MONTH(followers.created_at)
		END,
		users_random.id
) AS users_all_stats
# end users_all_stats
# start all_projects_stats (owner_id, month, new_projects, new_watchers, new_forks)
LEFT JOIN (
  SELECT
		projects.owner_id,
    by_project_stats.month,
		IFNULL(new_projects_count.new_projects, 0) AS new_projects,
    SUM(by_project_stats.new_watchers) AS new_watchers,
    SUM(by_project_stats.new_forks) AS new_forks
	# start by_project_stats (repo_id, month, new_watchers, new_forks)
  FROM(
    SELECT
      projects_count_watchers.repo_id,
      projects_count_watchers.month,
      IFNULL(projects_count_watchers.new_watchers, 0) AS new_watchers,
      IFNULL(projects_count_forks.new_forks, 0) AS new_forks
		# start count watchers
    FROM (
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
    ) AS projects_count_watchers
		# end count watchers
		# start count forks
    LEFT JOIN (
      SELECT
				forks.forked_from_id,
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
    ) AS projects_count_forks
			ON (projects_count_watchers.repo_id = projects_count_forks.forked_from_id)
      	AND (projects_count_watchers.month = projects_count_forks.month)
		# end count forks
  ) AS by_project_stats
	# end by_project_stats
	# just to find back owner id
	LEFT JOIN projects ON by_project_stats.repo_id = projects.id
	# start count projects
	LEFT JOIN (
		SELECT
			projects.owner_id,
			CASE
				WHEN YEAR(projects.created_at) < 2012 THEN 0
				ELSE MONTH(projects.created_at)
			END AS month,
			COUNT(projects.id) AS new_projects
			FROM projects
			WHERE YEAR(projects.created_at) <= 2012
			GROUP BY
				CASE
					WHEN YEAR(projects.created_at) < 2012 THEN 0
					ELSE MONTH(projects.created_at)
				END,
				projects.owner_id
	) AS new_projects_count
		ON (new_projects_count.owner_id = projects.owner_id)
			AND (new_projects_count.month = by_project_stats.month)
	# end count projects
	GROUP BY projects.owner_id, by_project_stats.month
) AS all_projects_stats ON all_projects_stats.owner_id = users_all_stats.id AND all_projects_stats.month = users_all_stats.month
# end all_rpoject_stats

FROM (
	SELECT
	*,
	COUNT(DISTINCT watchers.user_id) AS new_watchers,
	COUNT(DISTINCT forks.fork_id) AS new_forks
	FROM users_random
	LEFT JOIN followers ON followers.user_id = users_random.id
	LEFT JOIN projects ON users_random.id = projects.owner_id
	LEFT JOIN watchers ON projects.id = watchers.repo_id
	LEFT JOIN forks ON projects.id = forks.forked_from_id
	WHERE
		YEAR(projects.created_at) <= 2012
		AND YEAR(watchers.created_at) <= 2012
		AND YEAR(forks.created_at) <= 2012
	GROUP BY
		CASE
			WHEN YEAR(projects.created_at) < 2012 THEN 0
			ELSE MONTH(projects.created_at)
		END,
		CASE
			WHEN YEAR(watchers.created_at) < 2012 THEN 0
			ELSE MONTH(watchers.created_at)
		END,
		CASE
			WHEN YEAR(watchers.created_at) < 2012 THEN 0
			ELSE MONTH(watchers.created_at)
		END,
		projects.owner_id
) AS all_data
