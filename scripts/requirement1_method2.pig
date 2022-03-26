
--Loading data from csv into a relation named titanic_data

titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);

--Grouping the data by Survived column

titanic_grouped_data_by_sur = group titanic_data by Survived;

--Counting records in each group which will result in row counts in each group.

titanic_group_counts= foreach titanic_grouped_data_by_sur generate group,COUNT(titanic_data);

--header column

header_col= load 'titanic_analysis/input/header_col' using PigStorage(',') as (Survived:int,s_str:chararray);

--Joining the header_col file and titanic_group_counts relation by Survived column

joined_data = join titanic_group_counts by group,header_col by Survived;

--Taking only relevant columns in final result

requirement_1_m2= foreach joined_data generate header_col::s_str, $1;
--Here $1 is the 2nd column of relation joined data which contains Counts of records for eacg group.

--Storing the result of requirement_1_m2 relation in HDFS/titanic_analysis/output folde

STORE requirement_1_m2 INTO 'titanic_analysis/output/requirement_1_m2.txt' using PigStorage(',');

--Printing the saved result into pig shell.

requirement_1_m2_print= load '/user/hdoop/titanic_analysis/output/requirement_1_m2.txt' using PigStorage(',');
dump requirement_1_m2_print;