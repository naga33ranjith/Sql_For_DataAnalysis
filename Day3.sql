use ordmgmt;
set sql_mode = only_full_group_by;

#1.	List customers who have not purchased any product. (19 rows)
SELECT 
    *
FROM
    online_customer oc
WHERE
    oc.customer_id NOT IN (SELECT 
            oh.customer_id
        FROM
            order_header oh
        WHERE
            order_status = 'shipped');


#2
select oi.product_id from order_items oi, (select oi.order_id,p.PRODUCT_ID from order_items oi
													    inner join product p on p.product_id=oi.product_id
														where p.product_id=201
														group by oi.order_id,p.product_id
                                                        ) oi1
where oi.product_id!=oi1.product_id
group by oi.product_id;


 ##3.	Which are the most and least sold products (quantity-wise)? Show their id, description and total quantities (3 rows).
 
SELECT 	P.PRODUCT_ID,
		P.PRODUCT_DESC,
        SUM(ORDERED_QTY) TOT_QUANTITY
FROM 	PRODUCT P,
		ORDER_ITEMS OI
WHERE 	P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY 	P.PRODUCT_ID
HAVING 		SUM(ORDERED_QTY) = 	(SELECT 	SUM(ORDERED_QTY) TOT_SUM 
										FROM 	ORDER_ITEMS											#UPPER LIMIT
										GROUP BY PRODUCT_ID
										ORDER BY TOT_SUM DESC
										LIMIT 1)
OR 			SUM(ORDERED_QTY) = 	(SELECT 	SUM(ORDERED_QTY) TOT_SUM 
										FROM 	ORDER_ITEMS											#LOWER LIMIT
										GROUP BY PRODUCT_ID
										ORDER BY TOT_SUM
										LIMIT 1);
                       
                        
                        

#4.	Who is the most valued customer (customer who made the highest sales)? Show customer id, full name and total value of all his/her orders. (Anita Goswami, 157648.00)


select oc.customer_id,concat(oc.customer_fname," ",customer_lname) as FullName , sum(oi.ORDERED_QTY*p.PRODUCT_PRICE) as TotalValue  from online_customer oc
inner join order_header oh on oh.customer_id=oc.customer_id
inner join order_items oi on oi.order_id=oh.order_id and oh.order_status='shipped'
inner join product p on p.product_id=oi.product_id
group by oc.customer_id 
order by TotalValue desc limit 1;


SET SQL_MODE = ONLY_FULL_GROUP_BY;
#5.	List the most expensive products in their respective classes. (16 rows)
SELECT * 
FROM 	PRODUCT P, 
		(SELECT 	PRODUCT_CLASS_CODE,
					MAX(PRODUCT_PRICE) COSTLY_ITEM
			FROM 	PRODUCT 
			GROUP BY PRODUCT_CLASS_CODE) P1
WHERE 	P.PRODUCT_CLASS_CODE = P1.PRODUCT_CLASS_CODE
AND 	P.PRODUCT_PRICE = P1.COSTLY_ITEM;



#66.	Which shipper has shipped highest volume (in m3) of items? (Hint: Each product has L x W x H dimensions in mm) (Flipkart, 4.4799 m3)


SELECT 	S.SHIPPER_NAME,
		SUM(TVOL.ORD_VOL) TOT_VOL
FROM 	SHIPPER S LEFT JOIN ORDER_HEADER OH
		ON S.SHIPPER_ID =OH.SHIPPER_ID
		LEFT JOIN ONLINE_CUSTOMER OC
		ON OH.CUSTOMER_ID = OC.CUSTOMER_ID JOIN
		(SELECT 	ORDER_ID, SUM(OI.ORDERED_QTY*P.LEN*P.WIDTH*P.HEIGHT)/1000000000 AS ORD_VOL			
			FROM 	PRODUCT P,				#INNER QUERY CACULATES VOLUME OF EACH ORDER
					ORDER_ITEMS OI
			WHERE 	P.PRODUCT_ID = OI.PRODUCT_ID
			GROUP BY ORDER_ID) TVOL
		ON 	OH.ORDER_ID = TVOL.ORDER_ID
WHERE 	OH.ORDER_STATUS NOT IN ('In process','Cancelled')
GROUP BY S.SHIPPER_ID
ORDER BY TOT_VOL DESC LIMIT 3;


#7.	Assume all items of an order are packed into one single carton (box). 
#Write a query to identify the optimum carton (carton with the least volume whose volume is greater than the total volume of all items) 
#for a given order. (Carton id 30 for Order id: 10001)

SELECT 	OT.ORDER_ID,
		SUM(OT.ORDERED_QTY*P.LEN*P.WIDTH*P.HEIGHT) AS PRD_VOL,
		(SELECT 	CARTON_ID 
			FROM CARTON 
            WHERE LEN*WIDTH*HEIGHT>SUM(OT.ORDERED_QTY*P.LEN*P.WIDTH*P.HEIGHT) 
            ORDER BY LEN*WIDTH*HEIGHT LIMIT 1) AS CARTOON
FROM 	PRODUCT P,
		ORDER_ITEMS OT
WHERE 	P.PRODUCT_ID = OT.PRODUCT_ID
GROUP BY OT.ORDER_ID;
##THE LIST OF ALL BOXES THAT FITS THE GIVEN ORDER 
SELECT CARTON_ID  
FROM CARTON
WHERE EXISTS (SELECT 1 FROM ORDER_ITEMS 
			WHERE LEN*WIDTH*HEIGHT>ANY (SELECT SUM(OT.ORDERED_QTY*P.LEN*P.WIDTH*P.HEIGHT)
										FROM PRODUCT P,
												ORDER_ITEMS OT
										WHERE P.PRODUCT_ID = OT.PRODUCT_ID
										AND OT.ORDER_ID = 10001
										GROUP BY OT.ORDER_ID));




#8.	Write queries to identify Top 5 orders (show total product quantity & total order value along with the individual ids below): 
#a.	Customer-wise
#b.	Product-wise
#c.	Product class-wise

#a
SELECT 	CONCAT(OC.CUSTOMER_FNAME,'  ',OC.CUSTOMER_LNAME) AS MOST_VALUED_CUSTOMER ,
		OH.CUSTOMER_ID,
        SUM(PROD.TOT_COST) TOT_SALES
FROM 	ORDER_HEADER OH LEFT JOIN ONLINE_CUSTOMER OC
		ON OH.CUSTOMER_ID = OC.CUSTOMER_ID JOIN
		(SELECT 	ORDER_ID, SUM(OI.ORDERED_QTY*P.PRODUCT_PRICE) AS TOT_COST			
			FROM 	PRODUCT P,				#INNER QUERY CACULATES ORDERED QUANTITY *  PRODUCT PRICE FOR EACH ORDER
					ORDER_ITEMS OI
			WHERE 	P.PRODUCT_ID = OI.PRODUCT_ID
			GROUP BY ORDER_ID) PROD
ON 	OH.ORDER_ID = PROD.ORDER_ID
WHERE 	OH.ORDER_STATUS NOT IN ('In process','Cancelled')
GROUP BY OH.CUSTOMER_ID
ORDER BY TOT_SALES DESC LIMIT 5;



#b
select  p.PRODUCT_ID,sum(oi.ORDERED_QTY) as Qty,sum(oi.ORDERED_QTY*p.PRODUCT_PRICE) as Totalordervalue from order_header oh
inner join order_items oi on oi.order_id=oh.order_id
inner join product p on p.product_id=oi.product_id
group by p.PRODUCT_ID
order by Qty desc limit 5;



#c
select  pc.product_class_code,pc.PRODUCT_CLASS_DESC,sum(oi.ORDERED_QTY) as Ordered_Qty,sum(oi.ORDERED_QTY*p.PRODUCT_PRICE) as Totalordervalue from order_header oh
inner join order_items oi on oi.order_id=oh.order_id
inner join product p on p.product_id=oi.product_id
inner join product_class pc on pc.product_class_code=p.product_class_Code
group by pc.product_class_code
order by Ordered_Qty desc limit 5;






















                        

SELECT employee_id, last_name, job_id, salary
FROM   Employees
WHERE  salary < ANY (SELECT salary
                     FROM   Employees
                     WHERE  job_id = 'IT_PROG')
AND    job_id <> 'IT_PROG';

SELECT employee_id, salary, last_name 
FROM employees m
WHERE EXISTS (SELECT employee_id FROM employees e
 WHERE e.manager_id = m.employee_id 
AND e.salary > 10000);
