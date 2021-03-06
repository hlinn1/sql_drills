USE sakila;

-- Display the first and last names of all actors from the table `actor` --
SELECT first_name, last_name FROM actor;

-- Display the first and last name of each actor in a single column in upper case letters. --
-- Name the column `Actor Name`. --
SELECT CONCAT(first_name, ' ', last_name) AS 'ACTOR NAME' FROM actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only
-- the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id FROM actor 
WHERE first_name = 'joe';

-- Find all actors whose last name contain the letters `GEN`: --
SELECT * FROM actor 
WHERE last_name LIKE '%gen%';

-- Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

-- Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China: --
SELECT * FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');

-- You want to keep a description of each actor. You don't think you will be performing queries 
-- on a description, so create a column in the table `actor` named `description` and use the 
-- data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and 
-- `VARCHAR` are significant).
ALTER TABLE actor
	ADD description BLOB;

-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
	DROP COLUMN description;

-- List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(DISTINCT(last_name))
FROM actor
GROUP BY first_name;

-- List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(DISTINCT(last_name))
FROM actor
GROUP BY first_name
HAVING COUNT(DISTINCT(last_name)) >= 2;

-- The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as 
-- `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:

SELECT first_name, last_name, address.address
FROM address
RIGHT JOIN staff ON address.address_id = staff.address_id;

--  6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT first_name, last_name, SUM(payment.amount)
FROM payment
JOIN staff ON staff.staff_id = payment.staff_id
GROUP BY staff.last_name;

-- SELECT first_name, last_name,
-- 		(SELECT sum(amount) FROM payment
-- 			WHERE payment.staff_id = staff.staff_id)
-- 		+
-- 		(SELECT sum(amount) FROM payment)
-- 			WHERE payment.staff_id = staff.staff_id) as total
-- FROM payment
-- RIGHT JOIN staff ON payment.staff_id = staff.staff_id;

-- SELECT id, player_alias,
--        ( SELECT sum( teamkills ) FROM ws1
--          WHERE ws1.player_id = player.id )
--         +
--        ( SELECT sum( teamkills ) FROM ws2
--          WHERE ws2.player_id = player.id ) as total
-- FROM player
-- JOIN alias ON ......

-- SELECT
--     cities.cityname, SUM(users.age)
-- FROM
--     cities
--        LEFT JOIN
--        users ON cities.id = users.city_id
-- GROUP BY cities.cityname

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, count(actor_id) as 'Actor Count'
FROM film
INNER JOIN film_actor USING (film_id)
GROUP BY film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
-- find out the film number from film table
-- find out how many of those films are in the inventory from the inventory table 
SELECT COUNT(inventory_id) AS 'Number of Hunchback Impossible in Inventory'
FROM inventory
WHERE film_id IN 
(
SELECT film_id 
FROM film
WHERE title = 'Hunchback Impossible'
);

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(payment.amount) AS 'Total Amount Paid'
FROM customer
LEFT JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY last_name
ORDER BY last_name ASC;
--   ```
--   	![Total amount paid](Images/total_payment.png)
--   `

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also 
-- soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE language_id IN
(
SELECT language_id
FROM language
WHERE name = 'English'
)
AND title LIKE 'K%' OR 'Q%';

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
(
SELECT actor_id
FROM film_actor
WHERE film_id IN 
(
SELECT film_id
FROM film
WHERE title = "Alone Trip"
));

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT first_name, last_name, email 
FROM country
INNER JOIN city 
ON city.country_id = country.country_id
INNER JOIN address
ON city.city_id = address.city_id
INNER JOIN customer
ON address.address_id = customer.address_id
WHERE country = 'Canada';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title AS 'Family Movies'
FROM film
WHERE film_id IN
(
SELECT film_id
FROM film_category
WHERE category_id IN
(
SELECT category_id
FROM category
WHERE name = 'Family'
));

-- * 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(film.title) as 'Popularity'
FROM rental
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film
ON inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY Popularity DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(rental_rate) as 'Total Revenue'
FROM rental
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film
ON inventory.film_id = film.film_id
GROUP BY store_id;

-- SELECT store.store_id, SUM(amount) as 'Total Revenue'
-- FROM payment
-- INNER JOIN rental 
-- ON payment.rental_id = rental.rental_id
-- INNER JOIN inventory
-- ON rental.inventory_id = inventory.inventory_id
-- INNER JOIN store
-- ON inventory.store_id = store.store_id
-- GROUP BY store.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country 
FROM address 
INNER JOIN store 
ON address.address_id = store.address_id
INNER JOIN city 
ON address.city_id = city.city_id
INNER JOIN country 
ON city.country_id = country.country_id;

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, 
-- payment, and rental.)
SELECT category.name AS 'Film Genre', SUM(payment.amount) AS 'Gross Revenue'
FROM payment 
INNER JOIN rental
ON payment.rental_id = rental.rental_id
INNER JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film_category
ON inventory.film_id = film_category.film_id
INNER JOIN category
ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem 
-- above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genre AS 
SELECT category.name AS 'Film Genre', SUM(payment.amount) AS 'Gross Revenue'
FROM payment 
INNER JOIN rental
ON payment.rental_id = rental.rental_id
INNER JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film_category
ON inventory.film_id = film_category.film_id
INNER JOIN category
ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genre;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_genre;


