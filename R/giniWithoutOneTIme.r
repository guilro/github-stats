myGiniWithoutOneTime = function(commits) {
  commits = sqldf('SELECT * FROM commits WHERE type="incremental"', drv='SQLite')
  commiters = sqldf(
    'SELECT
    COUNT(*) AS commits,
    name,
    email
    FROM commits
    GROUP BY name', drv='SQLite')

#   COUNT(CASE WHEN type="incremental" THEN 1 ELSE null END) AS incremental,
#   COUNT(CASE WHEN type="merge" THEN 1 ELSE null END) AS merge,
  
  
  sortedCommiters = sqldf('SELECT * FROM commiters WHERE commits > 1 ORDER BY commits', drv='SQLite')
  commitsCountWithoutOneTimeContributors = sqldf('SELECT SUM(commits) as result FROM sortedCommiters', drv='SQLite')$result
  sortedCommiters$cumCommits = cumsum(sortedCommiters$commits)
  
  giniCoef = 1 - ((2*sum(sortedCommiters$cumCommits))/commitsCountWithoutOneTimeContributors)/nrow(sortedCommiters)
  plot((1:nrow(sortedCommiters))/nrow(sortedCommiters), sortedCommiters$cumCommits/commitsCountWithoutOneTimeContributors)
  giniCoef
  
  return(round(giniCoef, digits=2))
}

myGiniWithoutOneTime(angularJsCommits)
myGiniWithoutOneTime(bootstrapCommits)
myGiniWithoutOneTime(d3Commits)
myGiniWithoutOneTime(dockerCommits)
myGiniWithoutOneTime(html5BoilerplateCommits)
myGiniWithoutOneTime(jqueryCommits)
myGiniWithoutOneTime(laravelCommits)
myGiniWithoutOneTime(linuxCommits)
myGiniWithoutOneTime(nodeCommits)
myGiniWithoutOneTime(railsCommits)
myGiniWithoutOneTime(reactCommits)
myGiniWithoutOneTime(symfonyCommits)
beep("mario")
