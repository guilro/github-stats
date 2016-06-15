quantile(users$followers, probs = c(0, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999))
quantile(users$watchers, probs = c(0, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999))
quantile(users$repos, probs = c(0, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999))
quantile(users$forks, probs = c(0, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999))
quantile(users$contributions, probs = c(0, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999))
quantile(users$own_projects, probs = c(0, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999))

usersByMonthAndBefore[followers>=6, has_followers:='T']
usersByMonthAndBefore[followers<6, has_followers:='F']
usersByMonthAndBefore[watchers>=5, has_watchers:='T']
usersByMonthAndBefore[watchers<5, has_watchers:='F']
usersByMonthAndBefore[repos>=10, has_repos:='T']
usersByMonthAndBefore[repos<10, has_repos:='F']
usersByMonthAndBefore[contributions > 0 | own_projects > 0, is_active:='T']
usersByMonthAndBefore[contributions < 1 & own_projects < 1, is_active:='F']
usersByMonthAndBefore[contributions >= 5, is_contributor:='T']
usersByMonthAndBefore[contributions < 5, is_contributor:='F']

usersByMonthAndBefore[usersByMonthAndBefore$is_active == 'F' & usersByMonthAndBefore$has_followers == 'F', state:="Dead"]
usersByMonthAndBefore[usersByMonthAndBefore$is_active == 'F' & usersByMonthAndBefore$has_followers == 'T', state:= "Popular dead"]
usersByMonthAndBefore[usersByMonthAndBefore$is_active == 'T' & usersByMonthAndBefore$is_contributor == 'F' & usersByMonthAndBefore$has_followers == 'F', state:= "Active unkown low contributor"]
usersByMonthAndBefore[usersByMonthAndBefore$is_active == 'T' & usersByMonthAndBefore$is_contributor == 'F' & usersByMonthAndBefore$has_followers == 'T', state:= "Active kown low contributor"]
usersByMonthAndBefore[usersByMonthAndBefore$is_contributor == 'T' & usersByMonthAndBefore$has_followers == 'F', state:= "Active unkown big contributor"]
usersByMonthAndBefore[usersByMonthAndBefore$is_contributor == 'T' & usersByMonthAndBefore$has_followers == 'T', state:= "Active kown big contributor"]

shift <- function(x, n){
  c(x[-(seq(n))])
}


usersByMonthAndBefore$startMonth = usersByMonthAndBefore$month + 1
usersByMonthAndBefore[,endMonth:=c(shift(startMonth, 1), 14), by=user_id]
# usersByMonthAndBefore$endMonth = usersByMonthAndBefore$startMonth +1

seq.labels =  seqstatl(usersByMonthAndBefore$state)
seq.states =  1:length(seq.labels)
seq.seq = seqdef(usersByMonthAndBefore, var=c("user_id", "startMonth", "endMonth", "state"), states=seq.states, labels=seq.labels,
                    process=FALSE, informat="SPELL")
print(seq.seq[1:15, ], format="SPS")
seqiplot(seq.seq)
seqdplot(seq.seq)

# CONSTANT
ccost = seqsubm(seq.seq, method = "CONSTANT", cval = 2)
ccost
seq.OM = seqdist(seq.seq, method = "OM", sm = ccost)
clusterward = agnes(seq.OM, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2)
cluster4 = cutree(clusterward, k = 5)
cluster4 = factor(cluster3, labels = c("Popular", "Contributors", "Inactive users", "New low contributors"))
seqfplot(seq.seq, group = cluster4, pbarw = T)

# TRATE
couts = seqsubm(seq.seq, method = "TRATE")
couts
seq.OMTRATE = seqdist(seq.seq, method = "OM", sm = couts)
clusterwardTRATE = agnes(seq.OMTRATE, diss = TRUE, method = "ward")
plot(clusterwardTRATE, which.plots = 2)
cluster5 = cutree(clusterwardTRATE, k = 6)
cluster5 = factor(cluster5, labels = c("Big contributors", "New active users", "Inactive users", "Popular inactive users", "Users stopping contribution", "New contributors"))
seqfplot(seq.seq, group = cluster5, pbarw = T)

clusterwardTRATEalphabet(seq.seq)
