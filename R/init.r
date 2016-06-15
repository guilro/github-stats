library(sqldf) # for SQL
library(tseries)
library(TraMineR)
library(plyr) # for ddply
library(beepr) # for beep
library(data.table) # for :=
library(RMySQL)
library(DBI)
library(xtable)
library(cluster)
beep('mario')

angularJsCommits = read.csv('dataCSV.noc/angular.js/commits.csv')
bootstrapCommits = read.csv('dataCSV.noc/bootstrap/commits.csv')
d3Commits = read.csv('dataCSV.noc/d3/commits.csv')
dockerCommits = read.csv('dataCSV.noc/docker/commits.csv')
html5BoilerplateCommits = read.csv('dataCSV.noc/html5-boilerplate/commits.csv')
jqueryCommits = read.csv('dataCSV.noc/jquery/commits.csv')
laravelCommits = read.csv('dataCSV.noc/laravel/commits.csv')
linuxCommits = read.csv('dataCSV.noc/linux/commits.csv')
nodeCommits = read.csv('dataCSV.noc/node/commits.csv')
railsCommits = read.csv('dataCSV.noc/rails/commits.csv')
reactCommits = read.csv('dataCSV.noc/react/commits.csv')
symfonyCommits = read.csv('dataCSV.noc/symfony/commits.csv')
beep('mario')
