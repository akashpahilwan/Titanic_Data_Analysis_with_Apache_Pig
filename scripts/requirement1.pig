
--Loading data from csv into a relation named titanic_data

titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);

--Splitting the data using Split command, creating two relations in result of total survived and total died.

split titanic_data INTO total_survived IF(Survived==1), total_died IF(Survived==0);

--Creating group and counting record in each group which will result in row counts in each relation.

total_survived_grp= group total_survived all;
total_survived_count= foreach total_survived_grp generate 'Total_Survived', COUNT(total_survived);

total_died_grp= group total_died all;
total_died_count= foreach total_died_grp generate 'Total_Died', COUNT(total_died);

--Appending both the relation into a single relation using UNION

requirement_1 = UNION total_survived_count,total_died_count;

--Storing the result of requirement_1 relation in HDFS/titanic_analysis/output folder

STORE requirement_1 INTO 'titanic_analysis/output/requirement_1.txt' using PigStorage(',');

--Printing the saved result into pig shell.

requirement_1_print= load '/user/hdoop/titanic_analysis/output/requirement_1.txt' using PigStorage(',');
dump requirement_1_print;