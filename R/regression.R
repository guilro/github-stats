model = lm(contributions ~ own_projects + followers + watchers + forks + repos, data=users)
summary(model)

model = lm(contributions ~ own_projects + new_followers + new_watchers + new_forks + new_repos, data=usersByMonth)
summary(model)

model = lm(contributions ~ own_projects  + forks, data=usersByMonthAndBefore)
summary(model)


summary(lm(watchers ~ forks + repos, data=usersByMonthAndBefore))
