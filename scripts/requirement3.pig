--Loading data from csv into a relation named titanic_data

titanic_data = load '/user/hdoop/titanic_analysis/input/titanic_data.csv' using PigStorage(',') as(PassengerId:int,Survived:int,Pclass:int,Sex:chararray,Age:int,SibSp:int,Parch:int,Ticket:chararray,Fare:float,Cabin:chararray,Embarked:chararray);

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