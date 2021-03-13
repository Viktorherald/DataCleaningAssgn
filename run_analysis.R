## --- Load Package
library(dplyr)
library(reshape2)

## --- Reading files to variables ---

setwd("UCI HAR Dataset")
col_names <- read.table("features.txt")[[2]]
act_names <- read.table("activity_labels.txt")[[2]]

setwd("test")
test_subj <- read.table("subject_test.txt")
test_x <- read.table("X_test.txt")
test_y <- read.table("Y_test.txt")

setwd("..")
setwd("train")
train_subj <- read.table("subject_train.txt")
train_x <- read.table("X_train.txt")
train_y <- read.table("Y_train.txt")

## --- Merge and rename column name of test & train dataframe together

test_df <- cbind(test_subj, test_y, test_x)
train_df <- cbind(train_subj, train_y, train_x)

full_df <- rbind(test_df, train_df)

## --- After append, rename column name, extract required column, 
## --- Reformat column name and change activity value

names(full_df) <- make.names(c("indv_no", "activity", col_names), unique = TRUE)

full_df <- full_df %>% 
    select("indv_no", "activity", matches("mean"), matches("std"))

names(full_df) <- gsub("\\.", "", names(full_df))

full_df <- full_df %>% 
  mutate(activity = act_names[activity]) 

setwd("..\\..\\..")
write.table(full_df, file = "tidyData.txt", row.names = FALSE)
## --- Analysis of mean of var

molten_df <- melt(full_df, id = c("indv_no", "activity"), 
                  measure.vars = names(full_df)[3:ncol(full_df)])

molten_df <- molten_df %>% mutate(key = paste(indv_no, "_", activity, sep = ""))

final_summary_df <- dcast(data = molten_df, key ~ variable,mean)
