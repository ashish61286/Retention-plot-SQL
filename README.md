# Retention-plot-SQL
1. In this project Given an Order Table with the schema (id, user_id, total, created). 
Write a SQL Query to create a retention plot. The format for the raw data and 
output are given.  Refer to Q1.xlsx file.

Week Start Date is the 1st Week in which the User_Id Placed the order, 
Week 0 is Unique User ids who placed their 1st Order in this week. 
Out of those ids, Week 1 is unique users who placed an order in 1st Week + 1, 
Then Week 2 is 1st Week + 2 and so on till Week 10.

2. Given the tables Order_Timeline(schema id,order_id,  message, created) & 
Order_Shipment  Table(schema id, order_id,actual_dispatch_date,created) , 
write a SQL Query to find-

% orders shipped before first message date(OTIF)
% orders shipped on first message date+1(OTIF+1)
% orders shipped on first message date+2(OTIF+2)
%orders shipped after that(OTIF+>2)

Order_Timeline contains the message for expected dispatch date, Order_shipment 
gives you the real dispatch date. They are combined using order_id. 
Refer to Q2.xlsx file.

3. A company record its employees movement In and Out of office in a table with 3 columns

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
* No data gaps and, employee can work across days
