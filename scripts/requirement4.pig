--Loading data from csv into a relation named titanic_data

titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);

--Taking only required columns

feature_data = FOREACH titanic_data generate Survived,Pclass;

--Splittin data into two relations of Survived and Dead

SPLIT feature_data into total_died IF(Survived==0), total_survived IF(Survived==1);

--Groups relations by Pclass

died_group = GROUP total_died by Pclass;
survived_group = GROUP total_survived by Pclass;

--Aggregating data for Counting total people in each group in each relation

count_died = foreach died_group generate 'Died',(chararray)group,COUNT(total_died);
count_survived = foreach survived_group generate 'Survived',(chararray)group,COUNT(total_survived);

--Merging data from count_survived and count_died relation

requirement_4 = UNION count_died,count_survived;

--Storing the result of requirement_4 relation in HDFS/titanic_analysis/output folder

STORE requirement_4 INTO 'titanic_analysis/output/requirement_4.txt' using PigStorage(',');

--Printing the saved result into pig shell.

requirement_4_print= load '/user/hdoop/titanic_analysis/output/requirement_4.txt' using PigStorage(',');
dump requirement_4_print;