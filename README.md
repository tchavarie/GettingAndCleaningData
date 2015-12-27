=======================================================================
Mean Summary from Human Activity Recognition Using Smartphones Dataset
=======================================================================

For information about the source dataset please see the attached activityData.zip file. There is a README.txt in that file that describes the source data and how it was collected. 

To produce my summary dataset I created the attached run_anlysis.R script that uses the following methodology.
    
1 - Loaded features.txt containing the variable names for the data in X_test.txt, X_test.txt containing the 
observations captured by Accelerometer and Gyroscope for each of the test subjects and activities, y_test.txt 
containing numeric ids indicating measured activity for each observation, and subject_test.txt containing the 
numeric unique id of the subject (which I labeled volunteer to help me think about the data) for each observation. 

After loading these files I added column names to the x.test, y.test, and subject.test datasets and then used 
cbind to combine the 3 datasets. 

Next I performed the exact same steps for the _train.txt files and .train variables. 

Finally I used rbind to merge the mergedData.test and mergedData.train datasets, creating one mergedData dataset. 

2 - The final tidy dataset includes the means for each mean and each standard deviation variable for the subjects 
(volunteers) and activities. In order to extract only these variable types I looked for the pattern "std" or 
"mean" in the variable names. I also excluded meanFreq and angle variables because I felt those were measurements 
of something other than the mean or standard deviation. 

3 - Loaded activity_labels.txt containing descriptive activity names and then used merge to join the mergedData 
dataset with activity.labels using the activity.id column. 

4 - In order to clean up the variable names and make them I bit easier to understand I added a "." character 
between the different terms that make up the variable description. Given the number of terms
in the variable names I felt either a delimiter character or use of a mixed case (camel case)
variable name would be necessary in order to make the names understandable as a glance when 
reviewing the dataset. 

The specific terms are:
    
        time or fft: variables are prefixed with either time or fft indicating whether they are "time domain measurements" 
			or measurements that had a Fast Fourier Transform (FFT) applied to them respectively 

        body or gravity: indicates the signal measured was a body or gravity signal

        accel or gyro: indicates whether the signal was captured by the accelerometer or gyroscope

        jerk and / or mag: indicates the variable is a measure of a derived Jerk or Magnitude 

        std or mean: indicates whether the variable is the standard deviation or mean of the captured signal

        x, y, z: these are the breakouts of the 3-axial signal data

        #### More information is available in the features_info.txt file included with the original dataset 
		used for this analysis in the attached activityData.zip file. 

5 - Finally, in order to produce my tidy dataset I grouped the mergedData by activity level and volunteer (subject) 
and then applied the mean function on the std and mean variables for each unique volunteer / activity combination.

Please see my code and descriptive comments below that further break out and explains how I accomplished the above steps. Also I have included a file, CODEBOOK.txt that lists all the columns in my final tidy dataset, their datatype, as well as a sample of what data will be found in each field. 

=======================================================================


### Create data directory and download project files

    if(!file.exists("./data")) {dir.create("./data")}
    fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = "./data/activityData.zip", method="curl")

### Unzip files

    unzip("./data/activityData.zip", exdir = "./data")

### Load features dataset containing variable data for the x datasets

    features <- read.table("./data/UCI HAR Dataset/features.txt")

## Test Dataset
============

### Load x, y, and subject test datasets

    x.test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
    y.test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
    subject.test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

### Use colnames to set variable names for x, y, and subject test datasets

    colnames(x.test) <- gsub('[.]','',make.names(as.vector(features$V2), unique = TRUE))
    colnames(y.test) <- c("activity.id")
    colnames(subject.test) <- c("volunteer")

### Use cbind to merge x, y, and subject datasets

    mergedData.test <- cbind(x.test, y.test, subject.test)

## Train Dataset
=============

### Load x, y, and subject train datasets

    x.train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
    y.train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
    subject.train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

### Use colnames to set variable names for x, y, and subject train datasets

    colnames(x.train) <- gsub('[.]','',make.names(as.vector(features$V2), unique = TRUE))
    colnames(y.train) <- c("activity.id")
    colnames(subject.train) <- c("volunteer")

### Use cbind to merge x, y, and subject datasets

    mergedData.train <- cbind(x.train, y.train, subject.train)

### Use rbind to merge test and train datasets

    mergedData <- rbind(mergedData.test, mergedData.train)

### Extract only the mean and std variables along with activity id and volunteer

    library(dplyr)
    mergedData <- select(mergedData, 
                         matches("std|mean"), activity.id, 
                         volunteer, -(matches("meanFreq|angle")))

### Load activity labels dataset containing english descriptions for activity id

    activity.labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
    colnames(activity.labels) <- c("activity.id","activity.label")

### Add english descriptions using activity.id to merge activity labels with
### main merged dataset

    mergedData <- merge(mergedData, activity.labels)

## Finalize cleanup of variable names
==================================

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

## Tidy Dataset
------------

### Group mergedData by activity and subject

    activity.subject <- group_by(mergedData, activity.label, volunteer)

### Apply the mean function along all variables in the grouped data

    tidy.means <- summarise_each(activity.subject, funs(mean))
    tidy.means <- as.data.frame(tidy.means)

### Write dataset to file

    write.table(tidy.means,file = "./data/mytidydata.txt", row.names = FALSE)
