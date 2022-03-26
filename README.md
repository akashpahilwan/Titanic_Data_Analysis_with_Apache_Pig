This project is about analyzing the Titanic data set using Apache Pig. Apache Pig is an abstraction over MapReduce. It is a tool/platform which is used to analyze larger sets of data representing them as data flows. Pig is generally used with Hadoop; we can perform all the data manipulation operations in Hadoop using Apache Pig.

Pre-requisites
====================
Apache Hadoop framework installed [ :superhero: Hadoop Installation Tutorial](https://github.com/akashpahilwan/Hadoop-Installtion-on-Linux) </br></br>
Apache Pig installed
:superhero: 

Data set Description 
====================
Column 1 : PassengerId </br>
Column 2 : Survived (survived=0 & died=1)</br>
Column 3 : Pclass</br>
Column 4 : Name</br>
Column 5 : Sex</br>
Column 6 : Age</br>
Column 7 : SibSp</br>
Column 8 : Parch</br>
Column 9 : Ticket</br>
Column 10 : Fare</br>
Column 11 : Cabin</br>
Column 12 : Embarked</br>
</br>

You can download the titanic_data.csv datset from input folder or with the below link from Kaggle:</br>
[Kaggle Link Titanic data](https://www.kaggle.com/competitions/titanic/data?select=train.csv) </br>

NOTE: Column 4: "Name" has been dropped while moving data to HDFS as the Name field contains commas it disrupts the format while import data into Pig (Instead of dropping you can also save csv with different delimiter and use that delimiter while importing data in pig).

NOTE: Header row has also been dropped.

In this project I will find out the following results from titanic data.

    1.  The total number of people survived and the total number of people died.
    
    2.  The total number of the people with Sex(both male and female) who survided and died.

    3.  The Average Age of the people with Sex(both male and female) who survided and died.
    
    4.  How many persons survived and died– traveling class wise.

    5. The Average fair for each travelling class and minimum and maximun fair.

</br>

Loading the data from local to HDFS Directory
====================
I will be creating a folder in HDFS directory named "titanic_analysis" and create another folder named "input" in that directory.  The datset will be uploaded into "titanic_analysis/input" in HDFS Storage.
</br>
</br>
```
hadoop fs -mkdir titanic_analysis
hadoop fs -mkdir titanic_analysis/input
hadoop fs -put /home/hdoop/Desktop/data/titanic_data.csv titanic_analysis/input/
```
Below we can see the datset has been uploaded to the HDFS path mentioned above.</br></br>
![plot](../Titanic_Data_Analysis_with_Apache_Pig/images/input.PNG)</br></br>

Launching Apache Pig shell and Importing data into a Relation in Pig.
====================

Use the below command to launch Apache pig shell.
```
pig
```
Loading data from csv into a relation named titanic_data
```
titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);
```

Requirement 1: 
================

Method 1: 
----------------

Splitting the data using Split command, creating two relations in result of total survived and total died.
```
split titanic_data INTO total_survived IF(Survived==1), total_died IF(Survived==0);
```
Creating group and counting record in each group which will result in row counts in each relation.

```
total_survived_grp= group total_survived all;
total_survived_count= foreach total_survived_grp generate 'Total_Survived', COUNT(total_survived);
```
```
total_died_grp= group total_died all;
total_died_count= foreach total_died_grp generate 'Total_Died', COUNT(total_died);
```
Appending both the relation into a single relation using UNION
```
requirement_1 = UNION total_survived_count,total_died_count;
```
Storing the result of requirement_1 relation in HDFS/titanic_analysis/output folder
```
STORE requirement_1 INTO 'titanic_analysis/output/requirement_1.txt' using PigStorage(',');
```
Printing the saved result into pig shell.
```
requirement_1_print= load '/user/hdoop/titanic_analysis/output/requirement_1.txt' using PigStorage(',');
dump requirement_1_print;
```
Method 2:
---------------------

Grouping the data by Survived column
```
titanic_grouped_data_by_sur = group titanic_data by Survived;
```
Counting records in each group which will result in row counts in each group.
```
titanic_group_counts= foreach titanic_grouped_data_by_sur generate group,COUNT(titanic_data);
```
We need to create a sepearte file for column mapping like 0 -> Died and 1-> Survived
Below file was created and stored in input folder.
```
0,Died
1,Survived
```
Loading the above file intoa relation named header_col
```
header_col= load 'titanic_analysis/input/header_col' using PigStorage(',') as (Survived:int,s_str:chararray);
```
Joining the header_col file and titanic_group_counts relation by Survived column
```
joined_data = join titanic_group_counts by group,header_col by Survived;
```
Taking only relevant columns in final result
```
requirement_1_m2= foreach joined_data generate header_col::s_str, $1;
```
Here $1 is the 2nd column of relation joined data which contains Counts of records for eacg group.  
</br>
Storing the result of requirement_1_m2 relation in HDFS/titanic_analysis/output folder
```
STORE requirement_1_m2 INTO 'titanic_analysis/output/requirement_1_m2.txt' using PigStorage(',');
```
Printing the saved result into pig shell.
```
requirement_1_m2_print= load '/user/hdoop/titanic_analysis/output/requirement_1_m2.txt' using PigStorage(',');
dump requirement_1_m2_print;
```
Requirement 2:
================

Method 1:
----------------
Grouping the dataset by Sex and Survived
```
titanic_by_age_sur = group titanic_data by (Sex,Survived);
```
Counting records in each group which will result in row counts in each group.
```
titanic_by_age_sur_counts= foreach titanic_by_age_sur generate group.Survived,group.Sex,COUNT(titanic_data);
```
We need to create a sepearte file for column mapping like 0 -> Died and 1-> Survived
Below file was created and stored in input folder.
```
0,Died
1,Survived
```
Loading the above file into a relation named header_col
```
header_col= load 'titanic_analysis/input/header_col' using PigStorage(',') as (Survived:int,s_str:chararray);
```
Joining the header_col file and titanic_by_age_sur_counts relation by Survived column
```
merged_data = join titanic_by_age_sur_counts by Survived, header_col by Survived;
```
Taking only relevant columns in final result
```
requirement_2 = foreach merged_data generate header_col::s_str,titanic_by_age_sur_counts::Sex,$2;
```
Here $2 is the 3nd column of relation joined data which contains Counts of records for eacg group. </br>

Storing the result of requirement_2 relation in HDFS/titanic_analysis/output folder
```
STORE requirement_2 INTO 'titanic_analysis/output/requirement_2.txt' using PigStorage(',');
```
Printing the saved result into pig shell.
```
requirement_2_print= load '/user/hdoop/titanic_analysis/output/requirement_2.txt' using PigStorage(',');
dump requirement_2_print;
```
Method 2:
----------------

Splitting the data using Split command, creating two relations in result of total survived and total died.
```
split titanic_data INTO total_survived IF(Survived==1), total_died IF(Survived==0);
```
Grouping Survived and Died data by Sex
```
survived_gender_grp = GROUP total_survived by Sex;
died_gender_grp = GROUP total_died by Sex;
```
Generating Average Age for each Sex for died and survived people
```
sur_count_age = foreach survived_gender_grp generate CONCAT('Survived_',group) ,COUNT(total_survived) as total_count; 
died_count_age = foreach died_gender_grp generate CONCAT('Died_',group) ,COUNT(total_died) as total_count; 
```
Merge the sur_count_age and  died_count_age relation using UNION command

```
requirement_2_m2 = UNION sur_count_age,died_count_age;
```
Storing the result of requirement_2_2 relation in HDFS/titanic_analysis/output folder
```
STORE requirement_2_m2 INTO 'titanic_analysis/output/requirement_2_m2.txt' using PigStorage(',');
```
Printing the saved result into pig shell.
```
requirement_2_m2_print= load '/user/hdoop/titanic_analysis/output/requirement_2_m2.txt' using PigStorage(',');
dump requirement_2_m2_print;
```
Requirement 3:
================

This requirement is similar to requirement 2.Instead of counting the number of rows we will be taking average of column age.
Below is the whole script for this requirement.
```
--Splitting the data

split titanic_data INTO total_survived IF(Survived==1), total_died IF(Survived==0);

--Grouping by Sex

survived_gender_grp = GROUP total_survived by Sex;
died_gender_grp = GROUP total_died by Sex;

-- Aggregating data for AVG Age

sur_avg_age = foreach survived_gender_grp generate CONCAT('Survived_',group) ,AVG(total_survived.Age) as total_count; 
died_avg_age = foreach died_gender_grp generate CONCAT('Died_',group) ,AVG(total_died.Age) as total_count; 

--Merging data

requirement_3 = UNION sur_avg_age,died_avg_age;

--Storing data in HDFS

STORE requirement_3 INTO 'titanic_analysis/output/requirement_3.txt' using PigStorage(',');

-- Loading data from HDFS
requirement_3_print= load '/user/hdoop/titanic_analysis/output/requirement_3.txt' using PigStorage(',');

-- Printing the loaded Final Result

dump requirement_3_print;
```
Requirement 4:
==============

Taking only required columns
```
feature_data = FOREACH titanic_data generate Survived,Pclass;
```
Splittin data into two relations of Survived and Dead 
```
SPLIT feature_data into total_died IF(Survived==0), total_survived IF(Survived==1);
```
Groups realtions by Pclass
```
died_group = GROUP total_died by Pclass;
survived_group = GROUP total_survived by Pclass;
```
Aggregating data for Counting total people in each group in each relation
```
count_died = foreach died_group generate 'Died',(chararray)group,COUNT(total_died);
count_survived = foreach survived_group generate 'Survived',(chararray)group,COUNT(total_survived);
```
Merging data from count_survived and count_died relation
```
requirement_4 = UNION count_died,count_survived;
```

Storing the result of requirement_4 relation in HDFS/titanic_analysis/output folder
```
STORE requirement_4 INTO 'titanic_analysis/output/requirement_4.txt' using PigStorage(',');
```
Printing the saved result into pig shell.
```
requirement_4_print= load '/user/hdoop/titanic_analysis/output/requirement_4.txt' using PigStorage(',');
dump requirement_4_print;
```
Requirement 5:
================

Grouping the data by PClaass
```
group_pclass= group titanic_data by Pclass;
```
Aggregating the data for Avg, Max and Min Fare in Each Pclass group

```
requirement_5= foreach group_pclass generate CONCAT('Pclass_',(chararray)group),AVG(titanic_data.Fare),MAX(titanic_data.Fare),MIN(titanic_data.Fare);
```

Storing the result of requirement_5 relation in HDFS/titanic_analysis/output folder
```
STORE requirement_5 INTO 'titanic_analysis/output/requirement_5.txt' using PigStorage(',');
```
Printing the saved result into pig shell.
```
requirement_5_print= load '/user/hdoop/titanic_analysis/output/requirement_5.txt' using PigStorage(',');
dump requirement_5_print;
```