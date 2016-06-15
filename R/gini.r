myGini = function(commits) {
  commits = sqldf('SELECT * FROM commits WHERE type="incremental"', drv='SQLite')
  commiters = sqldf(
    'SELECT
  COUNT(*) AS commits,
  name,
  email
  FROM commits
  GROUP BY name', drv='SQLite')

  print(nrow(commits))
  print(nrow(commiters))
  
  sortedCommiters = sqldf('SELECT * FROM commiters ORDER BY commits', drv='SQLite')
  sortedCommiters$cumCommits = cumsum(sortedCommiters$commits)
  gini = 1 - ((2*sum(sortedCommiters$cumCommits))/nrow(commits))/nrow(sortedCommiters)
  plot((1:nrow(sortedCommiters))/nrow(sortedCommiters), sortedCommiters$cumCommits/nrow(commits))
  gini

  return(round(gini, digits= 2))
}

myGini(angularJsCommits)
myGini(bootstrapCommits)
myGini(d3Commits)
myGini(dockerCommits)
myGini(html5BoilerplateCommits)
myGini(jqueryCommits)
myGini(laravelCommits)
myGini(linuxCommits)
myGini(nodeCommits)
myGini(railsCommits)
myGini(reactCommits)
myGini(symfonyCommits)
beep("mario")
