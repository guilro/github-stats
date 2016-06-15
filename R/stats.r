sqldf('SELECT COUNT(*), commits.email
        FROM commits
        WHERE type = "merge"
        GROUP BY commits.email
        ORDER BY count(id) DESC
        LIMIT 20')

sqldf('SELECT COUNT(*), commits.email
        FROM commits
        WHERE type = "incremental"
        GROUP BY commits.email
        ORDER BY count(id) DESC
        LIMIT 20')

sqldf('SELECT
        COUNT(CASE WHEN type="incremental" THEN 1 ELSE null END) AS incremental,
        COUNT(CASE WHEN type="merge" THEN 1 ELSE null END) AS merge,
        date
      FROM commits
      GROUP BY date
      LIMIT 20')

sqldf('SELECT id, date, name, email FROM commits LIMIT 10')
