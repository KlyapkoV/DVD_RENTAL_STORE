-- 1. Информация по каждому покупателю (адрес, город и страна проживания)
SELECT CONCAT(first_name, ' ', last_name) AS "Покупатель"
      , address AS "Адрес"
      , city AS "Город"
      , country AS "Страна"
FROM public.customer AS cust INNER JOIN public.address AS addr ON cust.address_id = addr.address_id
							 INNER JOIN public.city AS cit ON addr.city_id = cit.city_id
							 INNER JOIN public.country AS cou ON cou.country_id = cit.country_id

							 
-- 2. Количество покупателей в разрезе магазинов
SELECT store_id AS "ID магазина"
      , COUNT(DISTINCT CONCAT(first_name, ' ', last_name)) AS "Количество покупателей"
FROM public.customer
GROUP BY store_id


-- 3. Информация о магазине, у которого больше 300-от покупателей (город, фамилия и имя продавца, который работает в этом магазине)
SELECT store_count.store_id AS "ID магазина"
      , "Количество покупателей"
      , cit.city AS "Город магазина"
      , CONCAT(staf.first_name, ' ', staf.last_name) AS "Сотрудник магазина"
FROM(
     SELECT store_id
           , COUNT(DISTINCT CONCAT(first_name,' ', last_name)) AS "Количество покупателей"
     FROM public.customer AS store_count
     GROUP BY store_id
     HAVING COUNT(DISTINCT CONCAT(first_name,' ' ,last_name)) > 300
    ) AS store_count INNER JOIN public.store AS store ON store_count.store_id = store.store_id
					 INNER JOIN public.address AS addr ON store.address_id = addr.address_id
					 INNER JOIN public.city AS cit ON addr.city_id = cit.city_id
					 INNER JOIN public.staff AS staf ON store.manager_staff_id = staf.staff_id 

															     				 
-- 4. Топ-5 покупателей, которые взяли в аренду наибольшее количество фильмов
SELECT CONCAT(first_name,' ' ,last_name) AS "Покупатель"
      , COUNT(rent.customer_id) AS "Количество фильмов"
FROM public.customer AS cust INNER JOIN public.rental AS rent ON cust.customer_id = rent.customer_id
GROUP BY CONCAT(first_name,' ' ,last_name)
ORDER BY COUNT(rent.customer_id) DESC
LIMIT 5


-- 5. Подсчёт для каждого покупателя аналитических показателей:
--   1. количество фильмов, которые он взял в аренду
--   2. общач стоимость платежей за аренду всех фильмов (значение округлить до целого числа)
--   3. минимальное значение платежа за аренду фильма
--   4. максимальное значение платежа за аренду фильма
SELECT CONCAT(cust.first_name,' ' ,cust.last_name) AS "Покупатель"
      , kol  AS "Количество фильмов"
      , SUM(pay.tcp) AS "Общая стоимость платежей"
      , MIN(pay.amount) AS "Минимальная стоимость платежа"
      , MAX(pay.amount) AS "Максимальная стоимость платежа"
FROM public.customer AS cust INNER JOIN (
                                         SELECT customer_id
                                               , COUNT(*) AS kol
										 FROM public.rental 
										 GROUP BY customer_id
										) AS rent ON cust.customer_id = rent.customer_id
						     INNER JOIN (
						                 SELECT customer_id
						                       , CAST((SUM (amount)) AS INT) AS tcp
						                       , amount
						     			 FROM public.payment 
						     			 GROUP BY customer_id
						     			         , amount
						     			) AS pay ON cust.customer_id = pay.customer_id
GROUP BY CONCAT(first_name,' ' ,last_name)
 		, kol

 		
-- 6. Всевозможные пары городов (не должно быть пар с одинаковыми названиями городов)
SELECT c1.city, c2.city
FROM public.city AS c1 CROSS JOIN public.city AS c2
WHERE c1.city != c2.city


-- 7. Среднее количество дней, за которые покупатель возвращает фильмы (для каждого покупателя)
SELECT customer_id AS "ID покупателя"
      , ROUND(AVG(return_date :: DATE - rental_date :: DATE), 0) AS "Cреднее количество дней на возврат"
FROM public.rental
GROUP BY customer_id
ORDER BY customer_id ASC


-- 8. Количество аренд каждого фильма, общая стоимость аренды фильма за всё время
SELECT title AS "Наименование фильма"
	  , (CASE WHEN trc IS NULL THEN '0'
	   		  ELSE COUNT(title)
	     END) AS "Количество аренд"
	  ,trc AS "Общая стоимость аренды"
FROM public.film AS film FULL JOIN public.inventory AS inv USING (film_id)
						 FULL JOIN public.rental AS rent USING (inventory_id)
						 FULL JOIN public.payment AS pay USING (rental_id)
					     FULL JOIN (
					                SELECT title
	   									  , SUM(amount) AS trc
					      			FROM public.rental FULL JOIN public.inventory AS i USING (inventory_id)
					      			                   FULL JOIN public.payment AS p USING (rental_id)
					      			                   FULL JOIN public.film AS f USING (film_id)
					      			GROUP BY title
					      		   ) AS rental_cost USING (title)
GROUP BY title
        , trc


-- 9. Фильмы, которые ни разу не брали в аренду
SELECT title AS "Наименование фильма"
	  , (CASE WHEN trc IS NULL THEN '0'
	   		  ELSE CONCAT(title)
	     END) AS "Количество аренд"
FROM public.film AS film FULL JOIN public.inventory AS inv USING (film_id)
						 FULL JOIN public.rental AS rent USING (inventory_id)
						 FULL JOIN public.payment AS pay USING (rental_id)
					     FULL JOIN (
					                SELECT title
	   									  , SUM(amount) AS trc
					      			FROM public.rental FULL JOIN public.inventory AS i USING (inventory_id)
					      			                   FULL JOIN public.payment AS p USING (rental_id)
					      			                   FULL JOIN public.film AS f USING (film_id)
					      			GROUP BY title
					      		   ) AS rental_cost USING (title)
WHERE trc IS NULL
GROUP BY title
        , trc


-- 10. Количество продаж, выполненных каждым продавцом. Добавление вычисляемой колонки "Премия". Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
SELECT staff_id, COUNT(*) AS "Количество продаж"
      , (CASE WHEN COUNT(payment_id) > 7300 THEN 'Да'
	          ELSE 'Нет'
	     END) AS "Премия"
FROM public.payment
GROUP BY staff_id


-- 11. Таблица по платежам, согласно требованиям:
--   1. нумерация всех платежей от 1 до N по дате;
--   2. нумерация платежей для каждого покупателя (сортировка платежей по дате);
--   3. нарастающий итогом суммы всех платежей для каждого покупателя (сортировка сперва по дате платежа, а затем по сумме платежа от наименьшей к большей);
--   4. нумерация платежей для каждого покупателя по стоимости платежа от наибольших к меньшим так (платежи с одинаковым значением имеют одинаковое значение номера)
SELECT customer_id AS "ID покупателя"
      , amount AS "Платёж" 
      , payment_date AS "Дата платежа"
	  , ROW_NUMBER() OVER(ORDER BY payment_date) AS "Номер платежа по дате" -- ROW_NUMBER() - пронумеровал дату платежа; OVER - то, что входит в оконную функцию; далее просто сортировка
	  , ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS "Номер платежа покупателя по дате" -- добавляется PARTITION BY - поле или список полей (которые описывают группу строк) к которым применяется оконная функция (разбиение на подгруппы)
	  , SUM(amount) OVER(PARTITION BY customer_id ORDER BY payment_date, amount) AS "Нарастающий итог суммы всех платежей для каждого покупателя"
	  , DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY amount DESC) AS "Ранги для платежей" -- DENSE_RANK() - ранг по одинковым платежам без пропуска (считает группу родственных строк)
FROM public.payment


-- 12. Величина платежей (каждого текущего и предыдущего) для каждого покупателя (значение по умолчанию 0.0, сортировка по дате)
SELECT customer_id AS "ID покупателя"
      , amount AS "Платёж" 
	  , LAG(amount,1, 0.) OVER(PARTITION BY customer_id ORDER BY payment_date)
FROM public.payment


-- 13. Разница между предыдущим и следующим платежом покупателя
SELECT customer_id AS "ID покупателя"
      , payment_date AS "Дата платежа"
      , amount AS "Предыдущий платеж"
      , LEAD(amount) OVER (PARTITION BY customer_id ORDER BY payment_date) AS "Следующий платеж"
	  , (LEAD(amount) OVER (PARTITION BY customer_id ORDER BY payment_date) - amount) AS "Разница платежей"
FROM public.payment


-- 14. Величина последней аренды покупателей
SELECT DISTINCT customer_id AS "ID покупателя"
 	           , LAST_VALUE(amount) OVER (PARTITION BY customer_id) AS "Величина последней аренды"
FROM public.payment
ORDER BY customer_id


-- 15. Продажи (нарастающим итогом) за август 2005 года по каждому продавцу
SELECT DISTINCT staff_id AS "ID продавца"
 	  , SUM(amount) OVER(PARTITION BY staff_id) AS "Сумма продаж"
FROM public.payment
WHERE CAST(payment_date AS DATE) >= '2005-08-01'
     AND CAST(payment_date AS DATE) < '2005-09-01'


-- 16. Продажи (нарастающим итогом) за август 2005 года по каждой дате продажи (без учёта времени, с сортировкой по дате)
SELECT DISTINCT staff_id AS "ID продавца"
			   , "Дата платежа"
			   , LAST_VALUE("Cумма за день продаж") OVER(PARTITION BY staff_id, "Дата платежа") AS "Нарастающий итог по продажам"
FROM(
	 SELECT staff_id
		   , CAST(payment_date AS DATE) AS "Дата платежа"
 	       , SUM(amount) OVER (PARTITION BY staff_id ORDER BY payment_date, amount) AS "Cумма за день продаж"
	 FROM public.payment
	 WHERE CAST(payment_date AS DATE) >= '2005-08-01'
	       AND CAST(payment_date AS DATE) < '2005-09-01'
	 GROUP BY staff_id
	         , payment_date
	         , amount
	) AS e
ORDER BY staff_id
        , "Дата платежа"
    

-- 17. Таблица по покупателям (в разрезе стран), согласно условиям (сортировка по странам):
--   1. покупатель, арендовавший наибольшее количество фильмов
--   2. покупатель, арендовавший фильмов на самую большую сумму
--   3. покупатель, который последним арендовал фильм
WITH films AS (
               SELECT country
				     , LAST_VALUE(CONCAT(first_name, ' ' ,last_name)) OVER (PARTITION BY country ORDER BY COUNT(customer_id), CONCAT(first_name, ' ' , last_name) DESC) AS "Покупатель, арендовавший наибольшее количество фильмов"
               FROM public.payment AS pay JOIN public.customer AS cust USING (customer_id)
                                          JOIN public.address AS adr USING (address_id)
                                          JOIN public.city AS cit USING (city_id)
                                          JOIN public.country AS ctr USING (country_id)
               GROUP BY country
                       , CONCAT(first_name, ' ' , last_name)
              ),
     large_amount AS (
                      SELECT country
                            , LAST_VALUE(CONCAT(first_name, ' ' , last_name)) OVER (PARTITION BY country ORDER BY COUNT(amount), CONCAT(first_name, ' ' , last_name) DESC) AS "Покупатель, арендовавший фильмов на самую большую сумму"
              		  FROM public.payment AS pay JOIN public.customer AS cust USING (customer_id)
                                                 JOIN public.address AS adr USING (address_id)
                                                 JOIN public.city AS cit USING (city_id)
						                         JOIN public.country AS ctr USING (country_id)
                      GROUP BY country, CONCAT(first_name, ' ' , last_name)
                      ORDER BY country
                     ),
     last_rental AS (
                     SELECT DISTINCT country
                                    ,LAST_VALUE(CONCAT(first_name, ' ' , last_name)) OVER (PARTITION BY country ORDER BY payment_date, CONCAT(first_name, ' ' , last_name) DESC) AS "Покупатель, который последним арендовал фильм"
                     FROM public.payment AS pay JOIN public.customer AS cust USING (customer_id)
                                                JOIN public.address AS adr USING (address_id)
                                                JOIN public.city AS cit USING (city_id)
						                        JOIN public.country AS ctr USING (country_id)
					 ORDER BY country
					)
SELECT DISTINCT country AS "Страна"
			   , CONCAT(first_name, ' ' , last_name) AS "Наибольшее количество фильмов"
			   , CONCAT(first_name, ' ' , last_name) AS "Аренда на самую большую сумму"
               , CONCAT(first_name, ' ' , last_name) AS "Последний арендатор фильмов"
FROM public.payment AS pay JOIN public.customer AS cust USING (customer_id)
                           JOIN public.address AS adr USING (address_id)
                           JOIN public.city AS cit USING (city_id)
						   JOIN public.country AS ctr USING (country_id)
WHERE CONCAT(first_name, ' ' , last_name) IN (
                                              SELECT "Покупатель, арендовавший наибольшее количество фильмов"
							                  FROM films
							                 )
	 AND CONCAT(first_name, ' ' , last_name) IN (
	                                             SELECT "Покупатель, арендовавший фильмов на самую большую сумму"
							                     FROM large_amount
							                    )
	 AND CONCAT(first_name, ' ' , last_name) IN (
	                                             SELECT "Покупатель, который последним арендовал фильм"
							                     FROM last_rental
							                    )					       
ORDER BY country


-- 18. Создание материализованного представления (Количество аренд фильмов с атрибутом "Behind the Scenes" у каждого покупателя)
CREATE MATERIALIZED VIEW movie_rentals AS (
                                           SELECT DISTINCT customer_id "ID покупателя"
                                                          , COUNT(rental_id) OVER (PARTITION BY customer_id) AS "Количество аренд"
                                           FROM public.film AS f JOIN public.inventory AS i USING (film_id)
					                                             JOIN public.rental AS r USING (inventory_id)
                                           WHERE  special_features IN (
                                                                       SELECT special_features
						                                               FROM public.film
                                                                       WHERE  special_features && ARRAY['Behind the Scenes']
                                                                      )
                                           GROUP BY customer_id, rental_id
                                           ORDER BY customer_id
                                          )


-- 19. Обновление материализованного представления
REFRESH MATERIALIZED VIEW movie_rentals


-- 20. Сведения о самой первой продаже каждого продавца
SELECT pay.staff_id "ID продавца"
      , film_id AS "ID фильма"
      , title AS "Название фильма"
      , amount AS "Стоимость"
      , payment_date AS "Дата"
      , first_name AS "Имя покупателя"
      , last_name AS "Фамилия покупателя"
      , email AS "Email покупателя"
FROM (
	  SELECT *
	        , ROW_NUMBER() OVER (PARTITION BY staff_id ORDER BY payment_date)
	  FROM payment
	 ) AS pay JOIN public.customer AS cus USING (customer_id)
	  		  JOIN public.rental AS ren USING (rental_id)
	  		  JOIN public.inventory AS inv USING (inventory_id)
	  		  JOIN public.film AS fi USING (film_id)
WHERE row_number = 1


-- 21. Показатели по каждому магазину:
--   1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
--   2. количество фильмов, взятых в аренду в этот день
--   3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
--   4. сумму продажи в этот день
SELECT tabl_1.store_id AS "ID магазина"
      , rental_date AS "День (аренда больше всего фильмов)"
      , count AS "Количество фильмов"
      , payment_date AS "День (наименьшая сумма аренды)"
      , SUM "Сумма продажи"
FROM(
	 SELECT COUNT(inv.film_id)
	       , ren.rental_date::DATE
	       , inv.store_id
		   , ROW_NUMBER() OVER (PARTITION BY inv.store_id ORDER BY COUNT(inv.film_id) DESC) AS rn_1
	 FROM rental AS ren JOIN inventory AS inv USING (inventory_id)
	 GROUP BY ren.rental_date::DATE
	         , inv.store_id
	) AS tabl_1 JOIN (
	                  SELECT SUM(pay.amount)
	                        , pay.payment_date::DATE
	                        , st.store_id
	                        , ROW_NUMBER() OVER (PARTITION BY st.store_id ORDER BY SUM(pay.amount)) rn_2
	                  FROM payment AS pay JOIN staff st ON pay.staff_id = st.staff_id
	                  GROUP BY pay.payment_date::DATE
	                          , st.store_id
	                 ) tabl_2 ON tabl_1.store_id = tabl_2.store_id
WHERE rn_1 = 1
      AND rn_2 = 1