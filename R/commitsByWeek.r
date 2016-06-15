commitsByWeekFn = function(commits) {
  commits = linuxCommits
  # 1104534000000 is the timestamp of 01-01-2005 00:00 GMT
  # 1262304000000 is the timestamp of 01-01-2010 00:00 GMT
  commits = sqldf('SELECT * FROM commits WHERE type="incremental"')
  commits$week = trunc((commits$timestamp)/(1000*60*60*24*7))
  commitsCByWeek = sqldf(
    'SELECT
    COUNT(*) AS commits
    FROM commits
    GROUP BY week
    ORDER BY week')
  
  plot(1:nrow(commitsCByWeek), commitsCByWeek$commits)
  
  return(commitsCByWeek$commits)
}

plot(commitsByWeek)
commitsByWeek = commitsByWeekFn(commits)
commitsByWeekTs = ts(commitsByWeek)
adf.test(commitsByWeekTs)

fit <- stl(commitsByWeekTs, s.window="period")
fit = arma(commitsByWeekTs, c(12, 1))
fit
