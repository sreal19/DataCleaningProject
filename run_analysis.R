run_analysis <- function(){
  library(data.table)
  library(dplyr)
  library(plyr)
  library(reshape2)
##Load Test Data Files
  TestSubjects <- fread('subject_test.txt')
  setnames(TestSubjects, names(TestSubjects), "subjectID")
  TestActivities <- fread('y_test.txt')
  setnames(TestActivities, names(TestActivities), "activityID")
  TestMetricsDF <- read.table('X_test.txt')
  TestMetrics <- data.table(TestMetricsDF)
  remove(TestMetricsDF)
  Features <- fread('features.txt')
  setnames(TestMetrics, names(TestMetrics), Features$V2)
  
##remove Metrics columns that are not mean or sdv
  meanMetrics <- select(TestMetrics,contains("mean"))
  stdMetrics <- select(TestMetrics,contains("std"))
##combine all the Test Data
  FullTestData <- cbind(TestSubjects,TestActivities,meanMetrics,stdMetrics)

##Load Train Data Files
  TrainSubjects <- fread('subject_train.txt')
  setnames(TrainSubjects, names(TrainSubjects), "subjectID")
  TrainActivities <- fread('y_train.txt')
  setnames(TrainActivities, names(TrainActivities), "activityID")
  TrainMetricsDF <- read.table('X_train.txt')
  TrainMetrics <- data.table(TrainMetricsDF)
  remove(TrainMetricsDF)
  setnames(TrainMetrics, names(TrainMetrics), Features$V2)

##remove Metrics columns that are not mean or sdv (reusing meanMetrics and stdMetrics)
  meanMetrics <- select(TrainMetrics,contains("mean"))
  stdMetrics <- select(TrainMetrics,contains("std"))

##combine all the Train Data
  FullTrainData <- cbind(TrainSubjects,TrainActivities,meanMetrics,stdMetrics)

##row bind Test and Train and clean up the names
AllData <- rbind(FullTestData,FullTrainData)


##Get Activity Names into the dataset
ActivityNames <- fread('activity_labels.txt')
setnames(ActivityNames,c("activityID","ActivityName"))
NewAllData <- arrange(join(AllData,ActivityNames),activityID)

#Create a vector of Feature Names containing only "mean" or "std" to use in next (melt) step
x <- Features$V2
meanx <- grep("mean",x)
stdx <- grep("std",x)
featureVec <- c(meanx,stdx)

##Melt the combined data into tall dataset and cast into array
allMelt <- melt(NewAllData,id=c("subjectID","ActivityName"),measure.vars=x[featureVec])
setnames(allMelt,"variable","Feature")
setnames(allMelt,"value","Measure")
ans <- acast(allMelt, subjectID ~ ActivityName ~ Feature, fun.aggregate=mean)
return(ans)
}
