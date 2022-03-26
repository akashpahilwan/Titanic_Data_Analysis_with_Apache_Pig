--Loading data from csv into a relation named titanic_data

titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);

--Grouping the data by PClass

group_pclass= group titanic_data by Pclass;

--Aggregating the data for Avg, Max and Min Fare in Each Pclass group

requirement_5= foreach group_pclass generate CONCAT('Pclass_',(chararray)group),AVG(titanic_data.Fare),MAX(titanic_data.Fare),MIN(titanic_data.Fare);

--Storing the result of requirement_5 relation in HDFS/titanic_analysis/output folder

STORE requirement_5 INTO 'titanic_analysis/output/requirement_5.txt' using PigStorage(',');

--Printing the saved result into pig shell.

requirement_5_print= load '/user/hdoop/titanic_analysis/output/requirement_5.txt' using PigStorage(',');
dump requirement_5_print;

