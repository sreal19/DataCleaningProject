run_analysis.r is coded as an R function without any arguments. To run it load the 
function code into your working session and invoke it with command:
r_analysis(). 

The steps in the script can also be executed one at a time if it is useful
to view interim results. Please see comments in the script which describe the processing
in more detail.

The function returns a tidy dataset called ans which contains the mean results sorted by 
activity with in subject

In order to run the run_analysis.R script successfully be sure that the following files
are in your working directory:

run_analysis.R
subject_test.txt
y_test.txt
X_test.txt
features.txt
subject_train.txt
y_train.txt
X_train.txt
activity_labels.txt

Also, be sure to install the following packages:
data.table
dplyr
plyr
reshape2
