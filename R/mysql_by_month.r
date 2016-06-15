# this is to generate disagregate data by month

con = dbConnect(RMySQL::MySQL(), dbname="econometrics_epog", username="root", password="root")

dbListTables(con)

# take random 10000 users
res = dbSendQuery(con, "DROP TABLE IF EXISTS users_2012random;")
res = dbSendQuery(con, "CREATE TABLE users_2012random SELECT * FROM users WHERE type = 'USR' AND YEAR(created_at) < 2013 ORDER BY RAND() LIMIT 10000;")
# insert into if already exist
dbClearResult(res)

# run create_tables.sql to create table, this is too heavy computation to be done in R
res = dbSendQuery(con, "SELECT * FROM users_2012random_stats")

usersByMonthAndBefore = dbFetch(res, n=-1)
usersByMonthAndBefore = data.table(usersByMonthAndBefore)
setkey(usersByMonthAndBefore, user_id, month)
usersByMonthAndBefore[,followers:=cumsum(new_followers), by=user_id]
usersByMonthAndBefore[,watchers:=cumsum(new_watchers), by=user_id]
usersByMonthAndBefore[,forks:=cumsum(new_forks), by=user_id]
usersByMonthAndBefore[,repos:=cumsum(new_repos), by=user_id]

usersByMonth = usersByMonthAndBefore[usersByMonthAndBefore$month > 0,]

users = usersByMonth[usersByMonth$month == 12,]
users = usersByMonth[usersByMonth[, .I[which.max(month)], by=user_id]$V1]
beep("mario")
dbClearResult(res)

