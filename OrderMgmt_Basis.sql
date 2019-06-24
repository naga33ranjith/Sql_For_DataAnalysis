use ordmgmt;

#1.	List the details of customers whose creation date is before ’12-Jan-2006’
# and email address contains ‘gmail’ or ‘yahoo’ and user name starts with ‘dave’.

select * from online_customer oc
where oc.creation_date < '2006-01-12' and
(oc.customer_email like '%gmail%' or oc.customer_email like '%yahoo%') and
oc.customer_username like '%dave%';

#2.	List the details of products with class code 2050 
#where price is in the range of 10000 and 30000 and available quantity is more than 15

select * from product
where product_class_code = 2050 and
product_price between 10000 and 30000 and
qty_in_stock>=15;

#3.	Display the details of products where the product category is any of 2050, 2053 or 2055.
select * from product
where product_class_code in(2050,2053,2055)
order by product_class_code desc;

#4.	Show order details which are yet to be shipped.
select * from order_header
where order_status ='in process';

#5.	Show product id, description and total worth of each product.
select  product_id as product_number, product_desc as Product_Descripition, 
(qty_in_stock*product_price) as Total_Worth 
from product
order by Total_Worth desc;


#6.	Display details of customer who have Gmail account, as below:
#<Customer full name> (<customer user name>) created on <date>. Contact Phone: <Phone no.> E-mail: <E-mail id>

select concat("Customer_FullName is :",concat(customer_fname,customer_lname),'and  user Name is :',
customer_username," . Created on :",creation_date," Contact Phone Number is :",customer_phone,"E-Mail is :",customer_email) 
as Customers_Having_GmailAccount 
from online_customer
where customer_email like '%gmail%';

#7.	Display the product Id, product description and total revenue for each product, if all the products are considered sold

select  product_id as product_number, product_desc as Product_Descripition, 
(qty_in_stock*product_price) as Total_Worth 
from product
order by Total_Worth desc;



#8.	Display the distinct id’s of the products which have been sold.
select distinct product_id  from order_items;


#9.	Show order id, order_date and shipment dates of all shipped orders in an ascending order of customer ids and descending order of order dates.
select order_id as Order_Number,Order_Date as Ordered_Date,shipment_date as Shipment_Date ,customer_id from order_header
where order_status ='shipped'
order by customer_id asc,order_date desc;

#10.	Show order id, order_date and shipment dates of all orders. For those orders which are yet to be shipped,
# show shipment date as 3 days from order date. (Use NULL related function).

SELECT customer_id, order_id, order_date, 
IFNULL(shipment_date, ADDDATE(order_date, 3)) AS shipment_date
FROM Order_header
WHERE payment_mode = 'Net Banking';



