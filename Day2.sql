use ordmgmt;

#1.	Display the product details as per the following criteria and sort them in descending order of category:
#a.	If the category is 2050, increase the price by 2000
#b.	If the category is 2051, increase the price by 500
#c.	If the category is 2052, increase the price by 600

SELECT 
    PRODUCT_ID,
    PRODUCT_DESC,
    PRODUCT_CLASS_CODE,
    PRODUCT_PRICE,
  case PRODUCT_CLASS_CODE
	When 2050 then PRODUCT_PRICE+2000
    when 2051 then PRODUCT_PRICE+500
    when 2052 then PRODUCT_PRICE+600
    else PRODUCT_PRICE
    end as increased_price
FROM
    product
ORDER BY increased_price desc;

#2.	List the product description, class description and price of all products which are shipped.

SELECT 
    p.Product_desc,
    pc.product_class_desc,
    p.PRODUCT_PRICE,
    oh.order_status
FROM
    order_header oh
        INNER JOIN
    order_items oi ON oi.order_id = oh.order_id
        AND oh.order_status = 'shipped'
        INNER JOIN
    product p ON p.product_id = oi.product_id
        INNER JOIN
    product_class pc ON pc.product_class_code = p.product_class_code;

#3.	List details of customers who have not placed any order.

SELECT 
    *
FROM
    online_customer
WHERE
    customer_id NOT IN (SELECT 
            customer_id
        FROM
            order_header
        WHERE
            order_status = 'shipped');

#4.	List customer name, email and order details (order id, product desc, qty, subtotal) for all customers even if they have not ordered any item


SELECT  
    CONCAT(customer_fname, ' ', customer_lname) AS Customer_Name,
    CUSTOMER_EMAIL,
    oi.ORDER_ID,
    p.PRODUCT_DESC,
    IFNULL(oi.oRDERED_QTY, 0) AS Ordered_Quantity,
    IFNULL(oi.ORDERED_QTY * p.PRODUCT_PRICE, 0) AS SubTotal
FROM
    online_customer oc
        LEFT JOIN
    order_header oh ON oh.customer_id = oc.customer_id
        LEFT JOIN
    order_items oi ON oi.order_id = oh.order_id
        LEFT JOIN
    product p ON p.product_id = oi.product_id
ORDER BY Customer_Name;



#55.	Show inventory status of products as below as per their available quantity:
#a.	For Electronics and Computer categories, if available quantity is < 10, show 'Low stock', 11 < qty < 30, show 'In stock', > 31, show 'Enough stock'
#b.	For Stationery and Clothes categories, if qty < 20, show 'Low stock', 21 < qty < 80, show 'In stock', > 81, show 'Enough stock'
#c.	Rest of the categories, if qty < 15 – 'Low Stock', 16 < qty < 50 – 'In Stock', > 51 – 'Enough stock'
#For all categories, if available quantity is 0, show 'Out of stock'.

SELECT 
    p.PRODUCT_DESC,
    p.QTY_IN_STOCK,
    CASE
        WHEN
            pc.PRODUCT_CLASS_DESC = 'Electronics'
                OR pc.PRODUCT_CLASS_DESC = 'Computer'
        THEN
            CASE
                WHEN p.QTY_IN_STOCK < 10 THEN 'OutOfStock'
                WHEN p.QTY_IN_STOCK BETWEEN 11 AND 30 THEN 'In Stock'
                WHEN p.QTY_IN_STOCK > 30 THEN 'In Stock'
            END
        WHEN
            pc.PRODUCT_CLASS_DESC = 'Stationery'
                OR pc.PRODUCT_CLASS_DESC = 'Clothes'
        THEN
            CASE
                WHEN p.QTY_IN_STOCK < 20 THEN 'LOwStock'
                WHEN p.QTY_IN_STOCK BETWEEN 21 AND 80 THEN 'In Stock'
                WHEN p.QTY_IN_STOCK > 81 THEN 'In Stock'
            END
        ELSE CASE
            WHEN p.QTY_IN_STOCK < 20 THEN 'LOwStock'
            WHEN p.QTY_IN_STOCK BETWEEN 21 AND 80 THEN 'In Stock'
            WHEN p.QTY_IN_STOCK > 81 THEN 'In Stock'
        END
    END AS InventoryLevel
FROM
    product p
        INNER JOIN
    product_class pc ON pc.product_class_code = p.product_class_code;


#6List customer full name and order details (order no, date, product class desc, product desc, subtotal, shipper name) for orders shipped to cities whose pin codes do not have any 0s in them.
# Sort the output on customer name, order date and subtotal.
SELECT 
    oc.customer_id,
    CONCAT(oc.customer_fname,
            ' ',
            oc.customer_lname) AS Customer_Name,
    oh.ORDER_ID,
    oh.ORDER_DATE,
    p.PRODUCT_DESC,
    pc.PRODUCT_CLASS_DESC,
    IFNULL(oi.ordered_qty * p.product_price, 0) AS SubTotal,
    sh.SHIPPER_NAME
FROM
    online_customer oc
        INNER JOIN
    order_header oh ON oh.customer_id = oc.customer_id
        INNER JOIN
    address ad ON ad.address_id = oc.address_id
        AND CAST(ad.pincode AS CHAR) NOT LIKE '%0%'
        INNER JOIN
    order_items oi ON oh.order_id = oi.order_id
        AND oh.order_status = 'shipped'
        INNER JOIN
    product p ON p.product_id = oi.product_id
        INNER JOIN
    product_class pc ON pc.product_class_code = p.product_class_code
        INNER JOIN
    shipper sh ON oh.shipper_id = oh.shipper_id
ORDER BY Customer_Name , oh.order_date , SubTotal;

#7.	List customers from outside Karnataka who haven’t bought any toys or books.

select  distinct concat(oc.customer_fname," ",oc.customer_lname) as Customer_FullName from online_customer oc
inner join address ad on ad.address_id=oc.address_id and ad.state != 'karnataka'
inner join order_header oh on oh.customer_id=oc.customer_id
inner join order_items oi on oi.order_id=oh.order_id
inner join product p on p.product_id=oi.product_id
inner join product_class pc on pc.product_class_code=pc.product_class_code  and pc.product_class_desc not in ('books','toys');


#8.	List the details of customers who bought more than ten (i.e. total order qty) products per order.

SELECT oc.customer_id, 
CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS fullname,
oh.order_id, SUM(oi.ordered_qty) AS tot_qty
FROM online_customer oc INNER JOIN order_header oh
	ON oc.customer_id = oh.customer_id
    AND oh.order_status = 'Shipped'
INNER JOIN order_items oi
	ON oh.order_id = oi.order_id
GROUP BY oc.customer_id, fullname, oh.order_id
HAVING tot_qty > 10;


#9.	Show full name and total order value of premium customers (i.e. the customers who bought items total worth > Rs. 1 lakh.) 

 
SELECT oc.customer_id, 
CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS fullname,
SUM(oi.ordered_qty * p.product_price) AS tot_ord_value
FROM online_customer oc INNER JOIN order_header oh
	ON oc.customer_id = oh.customer_id
    AND oh.order_status = 'Shipped'
INNER JOIN order_items oi
	ON oh.order_id = oi.order_id
INNER JOIN product p
	ON oi.product_id = p.product_id
GROUP BY oc.customer_id, fullname
HAVING tot_ord_value > 100000;

#10.	Show id and names of customers along with total quantity of products ordered for order ids > 10060


SELECT  oc.customer_id, 
CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS fullname,
SUM(oi.ordered_qty) AS tot_qty
FROM online_customer oc INNER JOIN order_header oh
	ON oc.customer_id = oh.customer_id
    AND oh.order_status = 'Shipped'
INNER JOIN order_items oi
	ON oh.order_id = oi.order_id
WHERE oh.order_id > 10060
GROUP BY oc.customer_id, fullname
order by  tot_qty asc;










