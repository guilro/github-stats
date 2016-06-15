commits = railsCommits
commits = sqldf('SELECT * FROM commits WHERE type="incremental"', drv='SQLite')
commits$day = trunc((commits$timestamp)/(1000*60*60*24*7))

commits = data.table(commits)
setkey(commits, name, day)
commits[,diff:=c(NA,diff(day)), by=name]
mean(commits$diff, na.rm = TRUE)
median(commits$diff, na.rm = TRUE)
quantile(commits$diff, na.rm = TRUE)

commitsday = sqldf('SELECT name, day FROM commits GROUP BY name, day', drv='SQLite')
commitsday = data.table(commitsday)
setkey(commitsday, name, day)
commitsday[,diff:=c(NA,diff(day)), by=name]
mean(commitsday$diff, na.rm = TRUE)
median(commitsday$diff, na.rm = TRUE)
quantile(commitsday$diff, na.rm = TRUE)

commitsday[diff>1,event:="WAKEUP"]
commitsday[diff==1,event:="ACTIVE"]
commitsday[is.na(diff),event:="NEW"]
# Now we have TSE data (see TraMineR doc)

sequence = seqecreate(id = commitsday$name, timestamp = commitsday$day, event = commitsday$event)
seqefsub(sequence, minSupport = 250)

beep("sword")

