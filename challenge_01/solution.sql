-- Which tracks appeared in the most playlists? how many playlist did they appear in?
-- Solution
WITH previous_query AS (SELECT *
FROM playlist_track
JOIN tracks
ON playlist_track.TrackId = tracks.TrackId)

SELECT TrackId, Name, COUNT(PlaylistId) AS 'Number of Playlists'
FROM previous_query
GROUP BY TrackId
ORDER BY 3 DESC
LIMIT 41;


--Which track generated the most revenue? which album? which genre?
--A query that will return the top 5 most profitable tracks.

WITH previous_query AS (SELECT *
FROM invoice_items
JOIN tracks
ON invoice_items.TrackId = tracks.TrackId)


SELECT TrackId, Name, (UnitPrice * SUM(Quantity)) AS 'Revenue'
FROM previous_query
GROUP BY TrackId
ORDER BY 3 DESC
LIMIT 5;



-- another way to query the most profitable albums Result is the same
WITH previous_query AS (SELECT tracks.TrackId, tracks.AlbumId, albums.Title
FROM tracks
JOIN albums
ON tracks.AlbumId = albums.AlbumId)

SELECT AlbumId, Title, (COUNT(invoice_items.TrackId) * invoice_items.UnitPrice) AS 'Album Revenue'
FROM invoice_items
JOIN previous_query
ON invoice_items.TrackId = previous_query.TrackId
GROUP BY AlbumId
ORDER BY 3 DESC;




-- A query that will return the top 50 most profitable Albums
WITH previous_query AS (SELECT albums.AlbumId, albums.Title, tracks.TrackId, Name, GenreId
FROM albums
JOIN tracks
WHERE albums.AlbumId = tracks.AlbumId)

SELECT previous_query.AlbumId, previous_query.Title, SUM(Quantity), UnitPrice, (SUM(Quantity) * UnitPrice) AS 'Album Revenue' 
FROM invoice_items
JOIN previous_query
ON invoice_items.TrackId = previous_query.TrackId
GROUP BY 1
ORDER BY 5 DESC
LIMIT 50;

-- a query to return a ranking with starting from the most profitable music genre to the least profitable

WITH previous_query AS (SELECT genres.GenreId, genres.Name, tracks.TrackId
FROM tracks
JOIN genres
ON tracks.GenreId = genres.GenreId)

SELECT  previous_query.GenreId, previous_query.Name, (COUNT(invoice_items.TrackId) * invoice_items.UnitPrice) AS 'Genre Revenue'
FROM invoice_items
JOIN previous_query
ON invoice_items.TrackId = previous_query.TrackId
GROUP BY  previous_query.GenreId
ORDER BY 3 DESC;

--Query to retrieve total revenue of sales

SELECT ROUND(SUM(UnitPrice),2) AS 'Total Revenue'
FROM invoice_items;

-- or

SELECT  SUM(Total)
FROM invoices;

-- TOTAL SALES: 2328.6

--Which countries have the highest sales revenue? What percent of total revenue does each country make up?
--solution

SELECT BillingCountry, SUM(Total), ROUND(((SUM(total)/2328.6)* 100), 2) AS 'Percentage of revenue'
FROM invoices
GROUP BY 1
ORDER BY 2 DESC;

--How many customers did each employee support, what is the average revenue for each sale, and what is their total sale?
-- query that returns how many customers each employee support
SELECT  employees.FirstName, COUNT(customers.CustomerId)
FROM customers
JOIN employees
ON customers.SupportRepId = employees.EmployeeId
GROUP BY customers.SupportRepId
ORDER BY 2 DESC;

--Query that returns total sale revenue by employee

SELECT employees.FirstName, customers.SupportRepId, ROUND(SUM(invoices.Total),2)
FROM invoices
JOIN customers ON invoices.CustomerId = customers.CustomerId
JOIN employees on customers.SupportRepId = employees.EmployeeId
GROUP BY 2
ORDER BY 3 DESC;


--query that returns average value for each sale by employee
SELECT employees.FirstName, AVG(invoices.Total)
FROM invoices
JOIN customers ON invoices.CustomerId = customers.CustomerId
JOIN employees ON customers.SupportRepId = employees.EmployeeId
GROUP BY 1;


/*Intermediate Challenge

Do longer or shorter length albums tend to generate more revenue?
Hint: We can use the WITH clause to create a temporary table that determines the number of tracks in each album, then group by the length of the album to compare the average revenue generated for each.
*/

-- SOLUTION THIS ONE WAS A TOUGH ONE.

WITH p AS (SELECT tracks.AlbumId, COUNT(*) AS TrackCount,
CASE 
	WHEN COUNT(*) > 20 THEN 'Longest Albums'
	WHEN COUNT(*) > 15 THEN 'Long Albums'
	WHEN COUNT(*) > 10 THEN 'Normal Albums'
	WHEN COUNT(*) > 5 THEN 'Short Albums'
	WHEN COUNT(*) > 1 THEN 'EPS'
	ELSE 'Singles'
END AS AlbumLengthCategory
	
FROM tracks
GROUP BY 1
ORDER BY 2 DESC),

a AS (SELECT AlbumLengthCategory, COUNT(AlbumId) AS AlbumsPerCategory
FROM p
GROUP BY 1),


b AS (SELECT p.AlbumId, a.AlbumLengthCategory, a.AlbumsPerCategory
FROM a
JOIN p ON a.AlbumLengthCategory = p.AlbumLengthCategory),


c AS (SELECT  albums.AlbumId, SUM(invoice_items.UnitPrice) AS AlbumRevenue
FROM invoice_items
JOIN tracks ON tracks.TrackId = invoice_items.TrackId
JOIN albums ON tracks.AlbumId = albums.AlbumId
GROUP BY 1)




SELECT b.AlbumLengthCategory, SUM(c.AlbumRevenue) AS 'Total Revenue by album length' , 	ROUND(AVG(c.AlbumRevenue),2) AS 'Average Revenue by Album length'
FROM b
JOIN c
ON b.AlbumId = c.AlbumId
GROUP BY 1
ORDER BY 3 DESC;



/*Is the number of times a track appear in any playlist a good indicator of sales?
Hint: We can use the WITH clause to create a temporary table that determines the number of times each track appears in a playlist, then group by the number of times to compare the average revenue generated for each.*/


--A lot of the work from this challange was already done with previous queries, it was just a matter of assembling the final query to return the average revenue for each Playlist Appearance value

WITH previous_query AS (SELECT *
FROM playlist_track
JOIN tracks
ON playlist_track.TrackId = tracks.TrackId),

a AS (SELECT TrackId, Name, COUNT(PlaylistId) AS PlaylistAppearances
FROM previous_query
GROUP BY TrackId
ORDER BY 3 DESC),


b AS (SELECT *
FROM invoice_items
JOIN tracks
ON invoice_items.TrackId = tracks.TrackId),

c AS (SELECT TrackId, Name, (UnitPrice * SUM(Quantity)) AS Revenue
FROM b
GROUP BY TrackId
ORDER BY 3 DESC)

SELECT a.PlaylistAppearances , AVG(c.Revenue)
FROM c
JOIN a ON c.TrackId = a.TrackId
GROUP BY 1
ORDER BY 1 DESC
;


/*Advanced Challenge

How much revenue is generated each year, and what is its percent change 84 from the previous year?
Hint: The InvoiceDate field is formatted as ‘yyyy-mm-dd hh:mm:ss’. Try taking a look at using the strftime() function to help extract just the year. Then, we can use a subquery in the SELECT statement to query the total revenue from the previous year. Remember that strftime() returns the date as a string, so we would need to CAST it to an integer type for this part. Finally, since we cannot refer to a column alias in the SELECT statement, it may be useful to use the WITH clause to query the previous year total in a temporary table, and then calculate the percent change in the final SELECT statement.*/

