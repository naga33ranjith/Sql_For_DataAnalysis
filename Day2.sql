use hr;


select employee_id as Employee_Number,concat(first_name,last_name) as Employee_Name,salary as Salary,
round((salary/500),0) as FiveHundred_Denominations, mod(salary,500) as Hundrend_Denominations from employees where department_id =30;


select mod(12345,144) as Cartons_Required ;

select concat(first_name,last_name) as Full_Name from employees 
where substr(first_name,-1) in('a','e','i','o','u') and substr(last_name,-1) in('a','e','i','o','u');

select * from employees
