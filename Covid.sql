use Covid_19;
CREATE TABLE Worlds_Data (
    Country TEXT,
    Continent TEXT,
    Population INT,
    Total_Cases INT,
    Total_Deaths INT,
    Total_Recovered INT,
    Active_Cases INT,
    Critical_Cases INT,
    Total_Cases_Per_Million INT,
    Deaths_Per_Million INT,
    Total_Tests INT
);
CREATE TABLE Country_Data (
    Country TEXT,
    Confirmed_Cases INT,
    Deaths INT,
    Recovered INT,
    Active INT,
    New_Cases INT,
    New_Deaths INT,
    New_Recovered INT,
    Deaths_Per_100_Cases INT,
    Recovered_Per_100_Cases INT,
    Deaths_Per_100_Recovered INT,
    Confirmed_Cases_Last_Week INT,
    One_Week_Change INT,
    One_Week_Change_Percentage FLOAT
);
CREATE TABLE Per_Day_Datas (
    Date DATE,
    Country TEXT,
    Confirmed_Cases INT,
    Deaths INT,
    Recovered INT,
    Active INT,
    New_Cases INT,
    New_Deaths INT,
    New_Recovered INT,
    WHO_Region TEXT
);

-- o	What are the top 10 countries with the highest total cases, deaths, and recoveries?
create view Total_cases as
select Country,Total_Cases 
from worlds_data
order by Total_Cases desc limit 10;
select * from Total_cases;

create view Total_deaths as
select Country,Total_Deaths 
from worlds_data
order by Total_Deaths desc limit 10;

create view Total_recovered as
select Country,Total_Recovered 
from worlds_data
order by Total_Recovered desc limit 10;

-- o	Which continents have the highest and lowest transmission rates?
create view Highest_Total_cases_Continent as
select Continent, sum(Total_Cases) as Total_Cases
from worlds_data
group  by Continent
order by sum(Total_Cases) desc limit 1;

create view Lowest_Total_cases_Continent as
select Continent, sum(Total_Cases) as Total_Cases
from worlds_data
group  by Continent
order by sum(Total_Cases) limit 2;

-- o	How does the death rate compare across continents (deaths per 1M population)?
create view Deaths_per_million_continent as
select Continent, sum(Deaths_Per_Million) as Deaths_Per_Million
from worlds_data
group  by Continent
order by Deaths_Per_Million desc ;

-- 	What are the trends in total, new, and active cases from January to mid-August 2020?
create view Trends_in_cases as
select date_format(Date, '%Y-%m') AS Month, sum(Confirmed_Cases) as Total_Cases,
sum(New_Cases) as Total_New_Cases, sum(Active) as Total_Active_Cases
from per_day_datas group by Month 
order by Month;

-- o	Which month had the highest escalation in cases for each continent?
create view Highest_cases_month_continent as
WITH Monthly_Cases AS (
    SELECT worlds_data.Continent, MONTH(per_day_datas.Date) AS Month, SUM(per_day_datas.Confirmed_Cases) AS Total_Cases
    FROM worlds_data 
    JOIN per_day_datas ON worlds_data.Country = per_day_datas.Country
    GROUP BY worlds_data.Continent, MONTH(per_day_datas.Date)
)
SELECT Continent, Month, Total_Cases
FROM Monthly_Cases
WHERE (Continent, Total_Cases) IN (
    SELECT Continent, MAX(Total_Cases)
    FROM Monthly_Cases
    GROUP BY Continent
    order by Total_Cases desc
);

-- o	How did recovery and death rates change over time?
create view Death_Recovery_rate as
select date_format(Date, '%Y-%m') AS Month, sum(Recovered) as Recovered, sum(Deaths) as Deaths
from per_day_datas
group by Month;

-- o	Identify countries with the highest ratio of critical cases to total cases.
create view Critical_To_Total_Case_Ratio as
select Country, (Critical_Cases/Total_Cases) as Critical_To_Total_Case_Ratio
from worlds_data
order by Critical_To_Total_Case_Ratio desc;

-- o	Which countries have the highest recovery rate (recovered per 100 cases)?
create view Recovery_Rate as
select Country, Recovered_Per_100_Cases as Recovery_Rate
from country_data
order by Recovery_Rate desc;

-- o	What is the week-over-week confirmed cases globally?
create view Weekly_confirmed_cases as 
select week(Date), Confirmed_Cases
from per_day_datas
order by Confirmed_Cases desc;

-- o	Identify countries with the highest one-week change in cases and analyze trends.
create view One_Week_Change_Cases_Percentage as
select Country, One_Week_Change_Percentage
from country_data
order by One_Week_Change_Percentage desc;

-- o	Which countries have the highest number of cases per 1M population?
create view Total_Cases_Per_Million as
select Country, Total_Cases_Per_Million
from worlds_data
order by Total_Cases_Per_Million desc;

-- o	Are there countries with low population but disproportionately high cases?
SELECT Country, 
       Population, 
       Total_Cases, 
       ROUND(Total_Cases / Population * 100, 2) AS Cases_Percentage,
       Total_Cases_Per_Million
FROM worlds_data
WHERE Population < (SELECT AVG(Population) FROM worlds_data) 
  AND Total_Cases_Per_Million > (SELECT AVG(Total_Cases_Per_Million) FROM worlds_data)
ORDER BY Total_Cases_Per_Million DESC;













