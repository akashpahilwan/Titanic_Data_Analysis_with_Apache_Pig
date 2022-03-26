
--Loading data from csv into a relation named titanic_data

titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);

--Grouping the dataset by Sex and Survived

titanic_by_age_sur = group titanic_data by (Sex,Survived);

--Counting records in each group which will result in row counts in each group

titanic_by_age_sur_counts= foreach titanic_by_age_sur generate group.Survived,group.Sex,COUNT(titanic_data);

--header_col 

header_col= load 'titanic_analysis/input/header_col' using PigStorage(',') as (Survived:int,s_str:chararray);

--Joining the header_col file and titanic_by_age_sur_counts relation by Survived column

merged_data = join titanic_by_age_sur_counts by Survived, header_col by Survived;

--Taking only relevant columns in final result

requirement_2 = foreach merged_data generate header_col::s_str,titanic_by_age_sur_counts::Sex,$2;
--Here $2 is the 3nd column of relation joined data which contains Counts of records for eacg group.

--Storing the result of requirement_2 relation in HDFS/titanic_analysis/output folder

STORE requirement_2 INTO 'titanic_analysis/output/requirement_2.txt' using PigStorage(',');

--Printing the saved result into pig shell.

requirement_2_print= load '/user/hdoop/titanic_analysis/output/requirement_2.txt' using PigStorage(',');
dump requirement_2_print;

