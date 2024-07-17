Here is a great SQL project you can make as part of your portfolio. 


Project Title: User Activity Analysis Using SQL 

--Project Overview:
--This project focuses on analyzing user activity data from two tables,
--`users_id` and `logins`. The goal is to provide valuable insights into user engagement, 
--activity patterns, and overall usage trends over time. 

--Analytical Questions: 

--1. Which users did not log in during the past 5 months?

--2. How many users and sessions were there in each quarter, ordered from newest to oldest?

--3. Which users logged in during January 2024 but did not log in during November 2023?

--4. What is the percentage change in sessions from the last quarter?

--5. Which user had the highest session score each day?

--6. Which users have had a session every single day since their first login?

--7. On what dates were there no logins at all?



--using database sql_project
use sql_project

--displaying data of 2 table users and logins
select * from users
select * from logins
select user_id , count(1) as total from logins
group by USER_ID

select year(cast(LOGIN_TIMESTAMP as date)) as year,
month(cast(LOGIN_TIMESTAMP as date)) as month , count(*) as total from logins
group by year(cast(LOGIN_TIMESTAMP as date)) ,month(cast(LOGIN_TIMESTAMP as date))

select GETDATE()
select SYSDATETIME()
select CURRENT_TIMESTAMP



--1. Which users did not log in during the past 5 months?
select USER_ID, max(login_timestamp) as max
from logins
group by USER_ID
having max(login_timestamp) < DATEADD(month, -5, GETDATE())

--or 

select distinct USER_ID 
from logins 
where USER_ID not in(
select USER_ID 
from logins
where login_timestamp > DATEADD(MONTH, -5, GETDATE()) ) 



--2. How many users and sessions were there in each quarter, ordered from newest to oldest?
--return first day of quarter , user_cnt , session_cnt

select DATETRUNC(quarter, min(login_timestamp) ) as first_day_of_quarter,
count(*) as session_cnt, count(distinct user_id) as user_cnt 
from logins 
group by datepart(quarter,login_timestamp)


--3. Which users logged in during January 2024 but did not log in during November 2023?
with nov as (
select * from logins 
where year(LOGIN_TIMESTAMP) =2023 and month(login_timestamp) =11 )
,jan as (
select * from logins 
where year(LOGIN_TIMESTAMP) =2024 and month(login_timestamp) =1)

select distinct user_id from jan 
where user_id not in ( select user_id from nov )




--4. What is the percentage change in sessions from the last quarter?

with cte as (
select DATETRUNC(quarter, min(login_timestamp) ) as first_day_of_quarter,
count(*) as session_cnt, count(distinct user_id) as user_cnt 
from logins 
group by datepart(quarter,login_timestamp) )

select * , 
lag(session_cnt) over(order by first_day_of_quarter asc ) as Prev_session_cnt ,
(session_cnt - lag(session_cnt) over(order by first_day_of_quarter asc )) * 100.0
/ lag(session_cnt) over(order by first_day_of_quarter asc )
as perchange
from cte






--5. Which user had the highest session score each day?
with cte as (
select  USER_ID , cast(login_timestamp as date) as login_date , sum(session_score) 
as session_score  
from logins
group by USER_ID,cast(login_timestamp as date) )

select * from (
select * , 
ROW_NUMBER() over(partition by login_date order by session_score desc) as rn 
from cte ) a 
where rn = 1 



--6. Which users have had a session every single day since their first login?

select user_id from (
select user_id , min(login_timestamp) as first_login ,
datediff(day, min(login_timestamp), GETDATE() ) as no_of_days,
count(distinct login_timestamp) as distinct_logins
from logins
group by user_id ) a 
where no_of_days = distinct_logins


--7. On what dates were there no logins at all?

SELECT * FROM
CALENDAR_DIM AS C
INNER JOIN 
 (SELECT MIN(login_timestamp) AS FIRST_LOGIN , GETDATE() AS LAST_LOGIN FROM logins) AS D 
 ON C.cal_date BETWEEN FIRST_LOGIN AND LAST_LOGIN

 WHERE C.cal_date NOT IN 
 ( SELECT DISTINCT CAST(login_timestamp AS DATE) AS DATE FROM LOGINS ) 



