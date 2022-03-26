
--Loading data from csv into a relation named titanic_data

titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);

--Splitting the data using Split command, creating two relations in result of total survived and total died.

Splitting the data using Split command, creating two relations in result of total survived and total died.

--Grouping Survived and Died data by Sex

survived_gender_grp = GROUP total_survived by Sex;
died_gender_grp = GROUP total_died by Sex;

--Generating Average Age for each Sex for died and survived people

sur_count_age = foreach survived_gender_grp generate CONCAT('Survived_',group) ,COUNT(total_survived) as total_count; 
died_count_age = foreach died_gender_grp generate CONCAT('Died_',group) ,COUNT(total_died) as total_count; 

--Merge the sur_count_age and died_count_age relation using UNION command

requirement_2_m2 = UNION sur_count_age,died_count_age;

--Storing the result of requirement_2_2 relation in HDFS/titanic_analysis/output folder

STORE requirement_2_m2 INTO 'titanic_analysis/output/requirement_2_m2.txt' using PigStorage(',');

--Printing the saved result into pig shell.

requirement_2_m2_print= load '/user/hdoop/titanic_analysis/output/requirement_2_m2.txt' using PigStorage(',');
dump requirement_2_m2_print;


