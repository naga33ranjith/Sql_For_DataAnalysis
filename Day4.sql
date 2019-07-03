#1.	Show product class description, product id, total quantity and total amount for all shipped orders that have their total amount > 10000.
# Show <<Subtotal>> at each product class level and << Grand total>> at the end.

SELECT	IFNULL(PC.PRODUCT_CLASS_DESC,'GRAND TOTAL') PRODUCT_CLASS_DESC,
		IFNULL(P.PRODUCT_ID,'SUB TOTAL') PRODUCT_ID, 	
		SUM(OI.ORDERED_QTY) AS TOT_QTY
FROM 	PRODUCT P,
		ORDER_ITEMS OI,
        PRODUCT_CLASS PC,
        ORDER_HEADER OH
WHERE 	P.PRODUCT_ID = OI.PRODUCT_ID
AND 	P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
AND 	OI.ORDER_ID = OH.ORDER_ID 
AND 	OI.ORDERED_QTY*P.PRODUCT_PRICE >10000
GROUP BY PC.PRODUCT_CLASS_DESC,P.PRODUCT_ID WITH ROLLUP;


#2.	Show product id, product description, its total quantity sold, and total quantity available and % of total quantity sold over available quantity
# where this % is less than 50%.

SELECT 	P.PRODUCT_ID,
		P.PRODUCT_DESC,
        SUM(ORDERED_QTY) TOT_QUANTITY_SOLD,
        P.QTY_IN_STOCK,
        ROUND((SUM(ORDERED_QTY)/P.QTY_IN_STOCK)*100,2) SOLD_OUT_PERCENT
        
FROM 	PRODUCT P,
		ORDER_ITEMS OI
WHERE 	P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY 	P.PRODUCT_ID
HAVING SOLD_OUT_PERCENT < 50;

#3.	Create a view to store the details of customers outside India who have made the payments using credit cards, for shipped orders whose total amount is more than 1000.
# (Columns: Customer id, Customer full name, Order id, City, Country, Total amount).
#  Sort the output by customer id first and then by order id.
create view  credit_cards as
	select oc.customer_id,concat(oc.customer_fname, " ",oc.customer_lname) as Customer_FullName,oh.order_id,sum(oi.ORDERED_QTY*p.PRODUCT_PRICE) as TotalAmount  from online_customer oc
	inner join order_header oh on oc.customer_id=oh.customer_id and oh.payment_mode='credit card' and oh.order_status='shipped'
	inner join address ad on ad.address_id=oc.address_id and ad.country != 'india'
	inner join order_items oi on oi.order_id=oh.order_id
	inner join product p on p.product_id=oi.product_id
	group by oc.customer_id,oh.order_id
	having sum(oi.ORDERED_QTY*p.PRODUCT_PRICE)>1000
	order by oc.customer_id asc;
    
    
#4Create a view to store the details of the customers outside India who have not purchased any product during last year but purchased during its previous year.
# (Columns: Customer id, Phone number in 999-999-9999 format, Email, City, Country). 

CREATE VIEW CUSTOMER_CONTACT1 AS
SELECT	OC.CUSTOMER_ID,
        CONCAT_WS('-',SUBSTR(OC.CUSTOMER_PHONE,1,3),SUBSTR(OC.CUSTOMER_PHONE,4,3),SUBSTR(OC.CUSTOMER_PHONE,7,7)) CUSTOMER_PHONE,
        OC.CUSTOMER_EMAIL,
        A.CITY,
        A.COUNTRY
FROM 	ONLINE_CUSTOMER OC,
		ADDRESS A,
        ORDER_HEADER OH
WHERE 	OC.ADDRESS_ID = A.ADDRESS_ID
AND 	OC.CUSTOMER_ID = OH.CUSTOMER_ID
AND 	A.COUNTRY <> 'INDIA'
AND 	OH.ORDER_DATE >SUBDATE(CURRENT_DATE(),INTERVAL 2 YEAR)
AND 	OH.ORDER_DATE <SUBDATE(CURRENT_DATE(),INTERVAL 1 YEAR);





#5.	Company wants to ship some of its products from a warehouse in one city to another. For this, it uses large containers of size 600 mm x 450 mm x 300 mm. 
# Write a query to show how many such containers will be full if all available quantities of a given product are packed into it.

SELECT CEIL(SUM(QTY_IN_STOCK*LEN*WIDTH*HEIGHT)/(600*450*300) ) NO_OF_CONTAINERS_NEEDED
FROM PRODUCT;

    
#6.	Given a shipper name, write a query to return the total quantity of products they have shipped outside India so far.
SELECT 	S.SHIPPER_NAME,
		SUM(ORDERED_QTY)
FROM 	ONLINE_CUSTOMER OC,
		ORDER_HEADER 	OH,
        ORDER_ITEMS		OI,
        ADDRESS 		A,
        SHIPPER S
WHERE 	OC.CUSTOMER_ID = OH.CUSTOMER_ID
AND 	OH.ORDER_ID = OI.ORDER_ID
AND 	OC.ADDRESS_ID = A.ADDRESS_ID
AND 	OH.SHIPPER_ID = S.SHIPPER_ID
AND 	A.COUNTRY  <> 'INDIA' 
AND		OH.ORDER_STATUS ='SHIPPED'
GROUP BY S.SHIPPER_NAME ;


#7.	Who is the earliest customer (creation date-wise) who haven't purchased any product?


SELECT * FROM ONLINE_CUSTOMER
WHERE CUSTOMER_ID NOT IN 	(SELECT	CUSTOMER_ID 
							FROM	ORDER_HEADER 
							WHERE	ORDER_STATUS = 'Shipped'
                            OR 		ORDER_STATUS = 'IN PROCESS'
							ORDER BY CUSTOMER_ID)
ORDER BY CREATION_DATE LIMIT 1;
    

    
#8.	Write a query which reports month-year wise summary of order details (no. of orders, count of each product ordered, subtotal of product price.
# Rollup the output at each subgroup level).


select month(oh.order_date) as Month1,year(oh.order_date) as year1,count(oh.order_id),sum(oi.ORDERED_QTY),sum(oi.ORDERED_QTY*p.PRODUCT_PRICE) from order_header oh
inner join order_items oi on oi.order_id=oh.order_id
inner join product p on p.product_id=oi.product_id
group by month(oh.order_date),year(oh.order_date) with rollup



