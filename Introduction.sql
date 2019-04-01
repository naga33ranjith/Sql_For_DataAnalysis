Use hr;

#1.	Select all job titles whose maximum salary is > 10000 
Select   Job_Title from jobs
where  max_salary>10000 ;

#2.	Select all job titles whose minimum salary is > 8000 and max salary < 20000
Select  Job_Title from jobs
where min_salary > 8000 and max_salary<20000;

#3.	Select all locations (id, city) which do not have any state province mentioned
Select location_id as Location,city as City from locations
where state_province is null;

#4.	List all IT related departments where there are no managers 
select department_id as Dept_Number,department_name as Department_Name from departments
where department_name like 'IT%' and manager_id is null;

#5.	List all departments with managers for location id 1700 
select department_id,department_name,manager_id from departments
where location_id =1700 and manager_id is not null;
 
 #6.	For how many years did employee 101 work as Account Manager?
select datediff(end_date,start_date)/365 as Years from job_history 
where employee_id =101 and job_id = 'AC_MGR';

#7.	List employee id, first name and their GROSS salaries whose monthly GROSS salary > 15000. Show least to highest gross salaries in the output (6 rows)
select employee_id as Employee_Number,concat(first_name,' ',last_name) as  EmployeeName , (salary+(salary*commission_pct)) as Salary 
from employees where (salary+(salary*commission_pct))>15000
order by Salary asc;

#8.	Show location id and cities of US or UK whose city name starts from 'S' but not from 'South'. 
select * from locations 
where country_id in ('US' ,'UK') and city  like 'S%' and city  not like 'So%';

#9.	Print a bonafide certificate for an employee (say for emp. id 123) as below
select concat("This is to certify that ",concat(first_name,last_name),"With employee id ",employee_id,'is Working as ',
job_id,'in dept ',department_id,'. Since ',hire_date,'. His/Her annual salary  is  ',salary) as Bonafide_Certificate
from employees
where employee_id = 101;

# 10.	Write a query to show employee id, full name, annual salary, tax rate, the tax amount and the net annual salary for employees with first name 'Peter'. Consider tax rate as 30%.

select employee_id as Employee_Number,concat(first_name,last_name) as Employee_FullName,
(salary*12) as Annual_Salary ,(salary/0.3) as Monthly_Tax_Deduction, 
round(((salary*12) - (salary/0.3)),0)as Total_Netpay from  employees
where first_name='Peter';

