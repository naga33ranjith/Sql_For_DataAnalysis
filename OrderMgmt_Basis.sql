use ordmgmt;

select * from online_customer oc
where oc.creation_date < '2006-01-12' and
(oc.customer_email like '%gmail%' or oc.customer_email like '%yahoo%') and
oc.customer_username like 'dave%';

select * from product
where product_class_code = 2050 and
product_price between 10000 and 30000 and
qty_in_stock>=15;


select * from product
where product_class_code in(2050,2053,2055)
order by product_class_code desc;


select * from order_header
where order_status ='in process';

select  product_id as product_number, product_desc as Product_Descripition, 
(qty_in_stock*product_price) as Total_Worth 
from product;


select concat("Customer_FullName is :",concat(customer_fname,customer_lname),'and  user Name is :',
customer_username," . Created on :",creation_date," Contact Phone Number is :",customer_phone,"E-Mail is :",customer_email) as Customers_Having_GmailAccount 
from online_customer
where customer_email like '%gmail%';

select  product_id as product_number, product_desc as Product_Descripition, 
(qty_in_stock*product_price) as Total_Worth 
from product;

select distinct product_id  from order_items;


select order_id as Order_Number,Order_Date as Ordered_Date,shipment_date as Shipment_Date ,customer_id from order_header
where order_status ='shipped'
order by customer_id asc,order_date desc;

select order_id as Order_Number,Order_Date as Ordered_Date,shipment_date as Shipment_Date ,customer_id ,order_status,
if(order_status='in process',adddate(order_date,3),shipment_date) as shipmentdate_for_Inprocess_Orders
from order_header


