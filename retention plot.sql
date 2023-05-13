/* 1. Given an Order Table with the schema (id, user_id, total, created). 
Write a SQL Query to create a retention plot. The format for the raw data and 
output are given.  Refer to Q1.xlsx file

Week Start Date is the 1st Week in which the User_Id Placed the order, 
Week 0 is Unique User ids who placed their 1st Order in this week. 
Out of those ids, Week 1 is unique users who placed an order in 1st Week + 1, 
Then Week 2 is 1st Week + 2 and so on till Week 10.*/
create table Q1(
id int,
userId int,
total int,
created DATETIMESTAMP)

COPY Q1 from 'C:\Program Files\PostgreSQL\15\data\New folder\Q1 - Sheet1.csv' DELIMITER ',' CSV HEADER;

select * from q1;

create temporary table t1 as
select userid, min(DATE_PART('week', created)) as first_week from q1
group by userid

select * from t1;

create temporary table all_week as
select userid, DATE_PART('week', created) as login_week from q1
group by userid, login_week

select * from all_week order by userid;

create temporary table week_diff as
select a.userid, a.login_week, t.first_week,(a.login_week - t.first_week) as week_num  from all_week a
join t1 t
on a.userid = t.userid

select * from week_diff

select first_week, sum(case when week_num = 0 then 1 else 0 end) as w0,
                   sum(case when week_num = 1 then 1 else 0 end) as w1,
                   sum(case when week_num = 2 then 1 else 0 end) as w2,
				   sum(case when week_num = 3 then 1 else 0 end) as w3,
				   sum(case when week_num = 4 then 1 else 0 end) as w4,
				   sum(case when week_num = 5 then 1 else 0 end) as w5,
				   sum(case when week_num = 6 then 1 else 0 end) as w6,
				   sum(case when week_num = 7 then 1 else 0 end) as w7,
				   sum(case when week_num = 8 then 1 else 0 end) as w8,
				   sum(case when week_num = 9 then 1 else 0 end) as w9,
				   sum(case when week_num = 10 then 1 else 0 end) as w10
from week_diff
group by first_week
order by first_week

/* 2. Given the tables Order_Timeline(schema id,order_id,  message, created) & 
Order_Shipment  Table(schema id, order_id,actual_dispatch_date,created) , 
write a SQL Query to find

% orders shipped before first message date(OTIF)
% orders shipped on first message date+1(OTIF+1)
% orders shipped on first message date+2(OTIF+2)
%orders shipped after that(OTIF+>2)

Order_Timeline contains the message for expected dispatch date, Order_shipment 
gives you the real dispatch date. They are combined using order_id. 
Refer to Q2.xlsx file*/
create table timeline(
id int,
order_Id int,
message DATE,
created TIMESTAMP)

COPY timeline from 'C:\Program Files\PostgreSQL\15\data\New folder\Q2 - order_timeline2.csv' DELIMITER ',' CSV HEADER;

select * from timeline;

create table shipment(
id int,
order_Id int,
actual_dispatch_date DATE)

COPY shipment from 'C:\Program Files\PostgreSQL\15\data\New folder\Q2 - order_shipment.csv' DELIMITER ',' CSV HEADER;

select * from shipment;

create temporary table message_date as
select t.order_id, t.message, s.actual_dispatch_date  from timeline t
join shipment s
on t.order_id = s.order_id
where s.actual_dispatch_date is not null;

select * from message_date;

select sum(case when message >= actual_dispatch_date then 1 else 0 end)*100.00/count(*) as OTIF1,
       sum(case when message + 1= actual_dispatch_date then 1 else 0 end)*100.00/count(*) as OTIF2,
	   sum(case when message + 2= actual_dispatch_date then 1 else 0 end)*100.00/count(*) as OTIF3,
	   sum(case when message + 2< actual_dispatch_date then 1 else 0 end)*100.00/count(*) as OTIF4
from message_date;

/* 3. A company record its employees movement In and Out of office in a table with 3 columns

(Employee id, Action (In/Out), Created)

There is NO sample data for this question. You only need to submit the queries

Employee ID
Action
Created
1
In
2019-04-01 12:00:00
1
Out
2019-04-01 15:00:00
1
In
2019-04-01 17:00:00
1
Out
2019-04-01 21:00:00

* First entry for each employee is “In”
* Every “In” is succeeded by an “Out”
* No data gaps and, employee can work across days*/

create table employee(
employeeid int,
action varchar,
created TIMESTAMP)

insert into employee(employeeid, action, created)
values(1, 'In', '2019-04-01 12:00:00'),
      (1, 'out', '2019-04-01 15:00:00'),
	  (1, 'In', '2019-04-01 17:00:00'),
	  (1, 'Out', '2019-04-01 19:00:00');
	 
select * from employee;

/* Q1 Find number of employees inside the Office at current time.*/
SELECT COUNT(*) AS emp_inside_office
FROM (
  SELECT employeeid, action
  FROM employee
  WHERE created = (
    SELECT MAX(created)
    FROM employee
  )) e
WHERE action = 'In';

/* Q2 Find number of employees inside the Office at “2019-05-01 19:05:00”.*/
SELECT COUNT(*) AS employees_inside_office
FROM (
  SELECT employeeid, action
  FROM employee
  WHERE created = (
    SELECT MAX(created)
    FROM employee
    WHERE created <= '2019-05-01 19:05:00')) e
WHERE action = 'In';

/* Q3 Measure amount of hours spent by each employee inside the office since 
the day they started (Account for current  shift if she/he is working).*/

WITH in_out_times AS (
  SELECT 
    employeeid, 
    action, 
    created, 
    LAG(created) OVER (PARTITION BY employeeid ORDER BY created) AS prev_created,
    LEAD(created) OVER (PARTITION BY employeeid ORDER BY created) AS next_created
  FROM employee
),
shifts AS (
  SELECT 
    employeeid, 
    DATE_TRUNC('day', created) AS shift_date, 
    DATE_PART('hour', created) AS shift_start, 
    DATE_PART('hour', COALESCE(next_created, NOW())) AS shift_end
  FROM in_out_times
  WHERE action = 'In'
),
shift_durations AS (
  SELECT 
    employeeid, 
    shift_date, 
    GREATEST(0, LEAST(shift_end, 24) - shift_start) AS shift_duration
  FROM shifts
),
employee_durations AS (
  SELECT 
    io.employeeid, 
    DATE_TRUNC('day', MIN(io.created)) AS start_date, 
    SUM(sd.shift_duration) AS total_duration_seconds
  FROM in_out_times io
  JOIN shift_durations sd ON sd.employeeid = io.employeeid AND sd.shift_date = DATE_TRUNC('day', io.created)
  WHERE io.action = 'In'
  GROUP BY io.employeeid
)
SELECT 
  employeeid, 
  start_date, 
  CONCAT(
    FLOOR(total_duration_seconds / 3600), ' hours ',
    FLOOR(MOD(total_duration_seconds::integer, 3600) / 60), ' minutes ',
    MOD(total_duration_seconds::integer, 60), ' seconds'
  ) AS total_duration
FROM employee_durations
ORDER BY employeeid;

/* Q4 Measure amount of hours spent by each employee inside the office between “2019-04-01 14:00:00” and “2019-04-02 10:00:00”.*/
SELECT employeeid, 
  CAST(SUM(
      CASE 
        WHEN action = 'Out' THEN -1 * DATE_PART('hour', created) 
        WHEN action = 'In' THEN DATE_PART('hour', created) 
      END
      * 3600 
      + CASE 
        WHEN action = 'Out' THEN -1 * DATE_PART('minute', created) * 60 
        WHEN action = 'In' THEN DATE_PART('minute', created) * 60 
      END
      + CASE 
        WHEN action = 'Out' THEN -1 * DATE_PART('second', created) 
        WHEN action = 'In' THEN DATE_PART('second', created) 
      END
      * 1.0 / 3600
    )
    AS NUMERIC(10, 2)
  ) AS total_hours
FROM employee
WHERE created BETWEEN '2019-04-01 14:00:00' AND '2019-04-02 10:00:00'
GROUP BY employeeid;