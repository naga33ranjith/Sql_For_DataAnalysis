#1.	Maximum quantity of which product, other than the promotional product, (whose id starts with 9999) fits in a given carton (say, carton id 10)?


SELECT 
    p.product_id,
    FLOOR((c.LEN * c.WIDTH * c.HEIGHT) / (p.LEN * p.WIDTH * p.HEIGHT)) AS NumberOfUnits
FROM
    carton c,
    product p
WHERE
    c.carton_id = 10 AND p.product_id < 1000
        AND ((c.LEN * c.WIDTH * c.HEIGHT) / (p.LEN * p.WIDTH * p.HEIGHT)) = (SELECT 
            MAX((c.LEN * c.WIDTH * c.HEIGHT) / (p.LEN * p.WIDTH * p.HEIGHT))
        FROM
            carton c,
            product p
        WHERE
            c.carton_id = 10 AND p.product_id < 1000);
								
                                
#2.	Show product id, description and price of products that have the same price, other than the promotional products.

select p1.product_id,p1.product_desc,p1.product_price from product p1,product p2
where p1.product_price=p2.product_price
and p1.product_id!=p2.product_id
and p1.product_id<1000 and p2.product_id<1000
order by 3,1;

#3.Which class of products have been shipped highest, to countries outside India other than USA? Also show the total value of those items.

SELECT product_class_desc, SUM(oi.ordered_qty) AS total_qty, 
SUM(oi.ordered_qty * p.product_price) AS total_value
FROM Address a, Online_Customer oc, Order_Header oh, Order_Items oi, Product p, Product_class pc
WHERE a.country != 'India'
AND a.country != 'USA'
AND a.address_id = oc.address_id
AND oc.customer_id = oh.customer_id
AND oh.order_id = oi.order_id
AND oi.product_id = p.product_id
AND p.product_class_code = pc.product_class_code
GROUP BY product_class_desc
ORDER BY 2 DESC LIMIT 2;
;


#4.Show customer id, full name, locality & total sales (0 if they haven't purchased any item) made by customers who stay in the same locality 
#(i.e. same address_line2 & city). 



SELECT oc.customer_id, oc.customer_fname, a.address_line2, a.city,
IFNULL(SUM(oi.ordered_qty * p.product_price),0) as total_sales
FROM Address a INNER JOIN Online_Customer oc 
    ON (oc.address_id = a.address_id)
LEFT OUTER JOIN Order_Header oh
    ON oc.customer_id = oh.customer_id
    AND oh.order_status = 'Shipped'
LEFT OUTER JOIN Order_Items oi
    ON oh.order_id = oi.order_id
LEFT OUTER JOIN Product p
    ON oi.product_id = p.product_id
WHERE (address_line2, city) IN
 (SELECT address_line2, city FROM Address 
  GROUP BY address_line2, city
  HAVING COUNT(*) > 1)
GROUP BY oc.customer_id, oc.customer_fname, a.address_line2, a.city;

#5.	For a given item, which item has been bought along with it, maximum no. of times?

SELECT p.product_id, product_desc, SUM(ordered_qty) AS tot_qty
FROM Order_Items oi, Product p
WHERE order_id IN
 (SELECT order_id FROM Order_Items WHERE product_id = 201)
 AND p.product_id != 201
AND oi.product_id = p.product_id
GROUP BY p.product_id, product_desc
ORDER BY 3 desc LIMIT 5;  

#-- OR -- Use following query if there are more than one item


SELECT p.product_id, product_desc, SUM(ordered_qty) AS tot_qty
FROM Order_Items oi, Product p
WHERE order_id IN
				(SELECT order_id FROM Order_Items WHERE product_id = 202)
				AND p.product_id != 202
				AND oi.product_id = p.product_id
				GROUP BY p.product_id, product_desc
				HAVING SUM(ordered_qty) = (
											SELECT SUM(ordered_qty) AS tot_qty
											FROM Order_Items oi, Product p
											WHERE order_id IN (
																	SELECT order_id FROM Order_Items WHERE product_id = 202
																									)
											AND p.product_id != 202
											AND oi.product_id = p.product_id
										    GROUP BY p.product_id, product_desc
										    ORDER BY 1 DESC LIMIT 1
										);  
                                        
									
#6.During which month of the year do foreign customers tend to buy max. no. of products? (Dec)


SELECT DATE_FORMAT(order_date, '%m') AS month, 
SUM(ordered_qty) AS total_qty
FROM Order_items oi INNER JOIN Order_Header oh
	ON oi.order_id = oh.order_id
INNER JOIN Online_Customer oc
	ON oh.customer_id = oc.customer_id
INNER JOIN Address a
	ON oc.address_id = a.address_id
WHERE a.country != 'India'
GROUP BY month
HAVING total_qty =
	(SELECT SUM(ordered_qty) AS total_qty
	FROM Order_items oi INNER JOIN Order_Header oh
		ON oi.order_id = oh.order_id
	INNER JOIN Online_Customer oc
		ON oh.customer_id = oc.customer_id
	INNER JOIN Address a
		ON oc.address_id = a.address_id
	WHERE a.country != 'India'
	GROUP BY DATE_FORMAT(order_date, '%m')
	ORDER BY total_qty DESC LIMIT 1);


									