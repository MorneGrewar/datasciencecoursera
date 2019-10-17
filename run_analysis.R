## Import required libraries
library(dplyr)
library(reshape2)
library(data.table)



## Code to read in Activity labels and Feature data
activity_labels <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/activity_labels.txt"),col.names = c("Index", "ActivityDescription"))
feature_labels <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/features.txt"),col.names = c("Feature_Index", "FeatureDescription"))
feature_filter <- grep("(mean|std)\\(\\)",feature_labels[,FeatureDescription])
measured <- feature_labels[feature_filter,FeatureDescription]
measured <- gsub("[()]","",measured)

## Load train datasets for X and Y
Xtrian_dat <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/train/X_train.txt"))
Xtrian_dat <- Xtrian_dat[, feature_filter, with = FALSE]
data.table::setnames(Xtrian_dat, colnames(Xtrian_dat), measured)
Ytrian_dat <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/train/y_train.txt"),col.names = c("Activity_Index"))
VolunteerTrian_dat <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/train/subject_train.txt"),col.names = c("Volunteer_Index"))
Xtrian_dat <- cbind(VolunteerTrian_dat, Ytrian_dat, Xtrian_dat)

## Load test datasets for X and Y
Xtest_dat <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/test/X_test.txt"))
Xtest_dat <- Xtest_dat[, feature_filter, with = FALSE]
data.table::setnames(Xtest_dat, colnames(Xtest_dat), measured)
Ytest_dat <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/test/y_test.txt"),col.names = c("Activity_Index"))
VolunteerTest_dat <- fread(file.path("C:/Users/Morne Grewar/Documents/Coursera Course/UCI HAR Dataset/test/subject_test.txt"),col.names = c("Volunteer_Index"))
Xtest_dat <- cbind(VolunteerTest_dat, Ytest_dat, Xtest_dat)

## Combine Train and Test data tables

combine_dat <- rbind(Xtrian_dat,Xtest_dat)
combine_dat <- arrange(combine_dat,Activity_Index)%>%arrange(Volunteer_Index)


## Average values for each activity per Volunteer
combine_dat[["Activity_Index"]] <- factor(combine_dat[, "Activity_Index"],levels = activity_labels[["Index"]],labels = activity_labels[["ActivityDescription"]])
combine_dat[["Volunteer_Index"]] <- as.factor(combine_dat[,"Volunteer_Index"])
combine_dat <- reshape2::melt(data = combine_dat, id = c("Volunteer_Index", "Activity_Index"))
combine_dat <- reshape2::dcast(data = combine_dat, Volunteer_Index + Activity_Index ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combine_dat, file = "Tidy_Data.csv", quote = FALSE)
