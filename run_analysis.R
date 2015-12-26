# Create data directory and download project files
if(!file.exists("./data")) {dir.create("./data")}
fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/activityData.zip", method="curl")

# Unzip files
unzip("./data/activityData.zip", exdir = "./data")

# Load features dataset containing variable data for the x datasets
features <- read.table("./data/UCI HAR Dataset/features.txt")


## Test Dataset
# Load x, y, and subject test datasets 
x.test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y.test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject.test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Use colnames to set variable names for x, y, and subject test datasets
colnames(x.test) <- gsub('[.]','',make.names(as.vector(features$V2), unique = TRUE))
colnames(y.test) <- c("activity.id")
colnames(subject.test) <- c("volunteer")

# Use cbind to merge x, y, and subject datasets 
mergedData.test <- cbind(x.test, y.test, subject.test)


## Train Dataset
# Load x, y, and subject train datasets 
x.train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y.train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject.train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# Use colnames to set variable names for x, y, and subject train datasets
colnames(x.train) <- gsub('[.]','',make.names(as.vector(features$V2), unique = TRUE))
colnames(y.train) <- c("activity.id")
colnames(subject.train) <- c("volunteer")

# Use cbind to merge x, y, and subject datasets 
mergedData.train <- cbind(x.train, y.train, subject.train)

# Use rbind to merge test and train datasets 
mergedData <- rbind(mergedData.test, mergedData.train)

# Extract only the mean and std variables along with activity id and volunteer
library(dplyr)
mergedData <- select(mergedData, 
                     matches("std|mean"), activity.id, 
                     volunteer, -(matches("meanFreq|angle")))

# Load activity labels dataset containing english descriptions for activity id
activity.labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
colnames(activity.labels) <- c("activity.id","activity.label")

# Add english descriptions using activity.id to merge activity 
# labels with main merged dataset
mergedData <- merge(mergedData, activity.labels)


## Finalize cleanup of variable names 
names(mergedData) <- gsub('^t','t.',names(mergedData))
names(mergedData) <- gsub('^f','f.',names(mergedData))

names(mergedData) <- gsub('Body','Body.',names(mergedData))
names(mergedData) <- gsub('Gravity','Gravity.',names(mergedData))

names(mergedData) <- gsub('Acc','Acc.',names(mergedData))
names(mergedData) <- gsub('Gyro','Gyro.',names(mergedData))

names(mergedData) <- gsub('Jerk','Jerk.',names(mergedData))
names(mergedData) <- gsub('Mag','Mag.',names(mergedData))

names(mergedData) <- gsub('X$','.X',names(mergedData))
names(mergedData) <- gsub('Y$','.Y',names(mergedData))
names(mergedData) <- gsub('Z$','.Z',names(mergedData))


### Tidy Dataset
# Group mergedData by activity and subject
activity.subject <- group_by(mergedData, activity.label, volunteer)

# Apply the mean function along all variables in the grouped data
tidy.means <- summarise_each(activity.subject, funs(mean))
tidy.means <- as.data.frame(tidy.means)
str(tidy.means)

# Write Table
write.table(tidy.means,file = "./data/mytidydata.txt", row.names = FALSE)
