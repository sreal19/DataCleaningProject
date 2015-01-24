run_analysis <- function(){
##make sure all the packages are in memory  
  library(data.table)
  library(dplyr)
  library(plyr)
  library(reshape2)
  
##Load Test Data Files in data tables
  TestSubjects <- fread('subject_test.txt')
  setnames(TestSubjects, names(TestSubjects), "subjectID")
  TestActivities <- fread('y_test.txt')
  setnames(TestActivities, names(TestActivities), "activityID")

  TestMetricsDF <- read.table('X_test.txt') ##read.table is used because the file is too big for fread
  TestMetrics <- data.table(TestMetricsDF)
  remove(TestMetricsDF)

##Read Features and clean up the names
  Features <- fread('features.txt')
  clean1 <- gsub("fBody","FrequencyBody",Features$V2)
  clean2 <- gsub("tBody","TimeBody",clean1)
  clean3 <- gsub("tGravity","TimeGravity",clean2)
  clean4 <- gsub("()","",clean3,fixed=TRUE)
  clean5 <- gsub("(",".",clean4,fixed=TRUE)
  clean6 <- gsub(")","",clean5,fixed=TRUE)
  Features$V2 <- clean6

##Use clean features data.table to provide names to Metrics File
  setnames(TestMetrics, names(TestMetrics), Features$V2)
  
##find Metrics columns that are mean or standard deviations
  meanMetrics <- select(TestMetrics,contains("mean"))
  stdMetrics <- select(TestMetrics,contains("std"))

##combine all the Test Data keeping only the metrics that are means and standard deviations
  FullTestData <- cbind(TestSubjects,TestActivities,meanMetrics,stdMetrics)

##Load Train Data Files
  TrainSubjects <- fread('subject_train.txt')
  setnames(TrainSubjects, names(TrainSubjects), "subjectID")
  TrainActivities <- fread('y_train.txt')
  setnames(TrainActivities, names(TrainActivities), "activityID")
  TrainMetricsDF <- read.table('X_train.txt')  ##read.table is used because fread chokes on this big file
  TrainMetrics <- data.table(TrainMetricsDF)
  remove(TrainMetricsDF)
  setnames(TrainMetrics, names(TrainMetrics), Features$V2)

##find Metrics columns that are mean or standard deviations (reusing meanMetrics and stdMetrics)
  meanMetrics <- select(TrainMetrics,contains("mean"))
  stdMetrics <- select(TrainMetrics,contains("std"))

##combine all the columns of Train Data the same as Test above
  FullTrainData <- cbind(TrainSubjects,TrainActivities,meanMetrics,stdMetrics)

##row bind Test and Train
AllData <- rbind(FullTestData,FullTrainData)


##Get Activity Names into the dataset
ActivityNames <- fread('activity_labels.txt')
setnames(ActivityNames,c("activityID","ActivityName"))
NewAllData <- arrange(join(AllData,ActivityNames),activityID)

#Create a vector of Feature Names to use in next (melt) step
x <- names(NewAllData)
meanx <- grep("mean",x)
stdx <- grep("std",x)
featureVec <- c(meanx,stdx)

##Melt the combined data into tall dataset and cast into array
allMelt <- melt(NewAllData,id=c("subjectID","ActivityName"),measure.vars=x[featureVec])
setnames(allMelt,"variable","Feature")
setnames(allMelt,"value","Measure")
ans <- acast(allMelt, subjectID ~ ActivityName ~ Feature, fun.aggregate=mean)

##return a tidy dataset
return(ans)
}
