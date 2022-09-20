
/*1. Write a query to return the food groups with average nutrition value of 
fat (tagname = FAT and/or nutrition description = Total Lipid (fat)) being 
more than 15g.*/
SELECT fdg.fdgrp_cd,fdg.fddrp_desc, nde.nutrdesc, nde.tagname, 
	   ROUND( AVG(nutr_val):: numeric, 2) AS avg_nutr_val
FROM nutr_def AS nde
JOIN nut_data AS nda
ON nde.nutr_no = nda.nutr_no
JOIN food_des AS fd
ON nda.ndb_no = fd.ndb_no
JOIN fd_group AS fdg
ON fdg.fdgrp_cd = fd.fdgrp_cd
WHERE tagname = 'FAT' AND nutrdesc = 'Total lipid (fat)' 
GROUP BY 1, 2, 3, 4
HAVING AVG(nutr_val)>15
ORDER BY avg_nutr_val DESC


/*2. Which food item manufacturer has the highest median nutrition value of 
sugar? Return the manufacturer’s name and the median nutrition value of 
sugar.*/
SELECT fod.manufacname, nde.tagname,
       PERCENTILE_CONT(0.5)
	   WITHIN GROUP(ORDER BY nda.nutr_val)
	   AS Median_nutr_val
FROM nutr_def AS nde
JOIN nut_data AS nda
ON nde.nutr_no = nda.nutr_no
JOIN food_des AS fod
ON nda.ndb_no = fod.ndb_no
WHERE tagname = 'SUGAR'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10


/*3. Which year was the most number of nutrition value of caffeine 
published?*/
SELECT dsr.year, nde.nutrdesc, COUNT(nda.nutr_val) AS no_of_nutr_val
FROM nutr_def AS nde
JOIN nut_data AS nda
ON nde.nutr_no = nda.nutr_no
JOIN datsrcln AS dat
ON nda.ndb_no = dat.ndb_no
JOIN data_src AS dsr
ON dsr.datasrc_id = dat.datasrc_id
WHERE nutrdesc = 'Caffeine'
GROUP BY 1, 2
ORDER BY 3 DESC


/*4. Find the nutrient(s) and food item(s) whose publications have the 
highest number of pages. Return the food description, nutrient description, 
author, title, year of publication, and number of pages.*/
SELECT fde.fdgrp_cd, nde.nutrdesc, dsr.authors, dsr.title, dsr.year, COUNT(dsr.end_page) AS no_of_pages  
FROM data_src AS dsr
JOIN datsrcln AS dat 
ON dsr.datasrc_id = dat.datasrc_id
JOIN nut_data AS nda
ON nda.ndb_no = dat.ndb_no
JOIN nutr_def AS nde
ON nde.nutr_no = nda.nutr_no
JOIN Food_des AS fde
ON fde.ndb_no = nda.ndb_no
GROUP BY 1,2,3,4,5
ORDER BY 6 DESC 


/*5. Which type of data was mostly used in finding nutrition value? 
Return the data type and the number of times it was used.*/
SELECT deriv_cd, COUNT(nutr_val) AS no_data_type_used
FROM nut_data
GROUP BY 1
ORDER BY 2 DESC


/*6. Which nutrient has the highest total number of studies? Return 
the nutrient’s tagname, description and total number of studies.*/
SELECT nde.tagname, nde.nutrdesc, SUM(nda.num_studies) AS total_no_of_studies
FROM nutr_def AS nde
JOIN nut_data AS nda
ON nde.nutr_no = nda.nutr_no
WHERE nda.num_studies IS NOT NULL
GROUP BY 1, 2
ORDER BY 3 DESC


/*7. Find the top 10 food groups with the highest average 
protein factor?*/
SELECT fdg.fdgrp_cd, fdg.fddrp_desc, ROUND(AVG(fds.pro_factor):: numeric, 2) AS avg_pro_factor
FROM fd_group AS fdg
JOIN food_des AS fds
ON fdg.fdgrp_cd = fds.fdgrp_cd
WHERE fds.pro_factor IS NOT NULL
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10


/*8. Find the food item with the highest percentage of refuse. 
Return the food name, group, percentage of refuse and refuse 
description.*/
SELECT fdg.fdgrp_cd, fdg.fddrp_desc, fds.ref_desc, 
	   ROUND(COUNT(fds.refuse)*100.0/COUNT(*)::numeric, 2) AS perc_of_refuse
FROM fd_group AS fdg
JOIN food_des AS fds
ON fdg.fdgrp_cd = fds.fdgrp_cd
GROUP BY 1, 2, 3
ORDER BY 4 DESC


/*9. Which data derivation method has the lowest average 
standard error greater than 0? Return the derivation method and 
its average standard error.*/
SELECT deriv_cd, ROUND(AVG(std_error)::numeric, 2) AS avg_std_error
FROM nut_data
GROUP BY 1
HAVING AVG(std_error) > 0
ORDER BY 2 ASC


/*10. Which food group has the highest number of food items that 
do not have scientific names? Return the group name and number of 
food items without scientific name.*/
SELECT fdg.fddrp_desc, fds.sciname, COUNT(fdg.fdgrp_cd) AS no_of_food_items
FROM fd_group AS fdg
JOIN food_des AS fds
ON fdg.fdgrp_cd = fds.fdgrp_cd
WHERE sciname = ''
GROUP BY 1, 2 
ORDER BY 3 DESC 


/*11. Find the second top 10 food items with the highest gram per 
cup. Consider only food items which have cup as a measure.*/
SELECT fde.fdgrp_cd, wgh.msre_desc, wgh.gm_wgt
FROM food_des AS fde
JOIN weight AS wgh
ON fde.ndb_no = wgh.ndb_no
WHERE wgh.msre_desc = 'cup'
GROUP BY 1, 2, 3
ORDER BY 3 DESC
OFFSET 10 FETCH FIRST 10 ROWS ONLY


/*12. Return a table displaying the highest amount spent on nutrition description in the United State. 
Using the obtained data, determine the highest,lowest and average amount spent?*/ 
(SELECT MAX(total_amount_spent) AS highest_amt, MIN(total_amount_spent) AS lowest_amt,
		   ROUND(AVG(total_amount_spent)::numeric, 2) AS average_amt
FROM 
        (SELECT DISTINCT(nde.nutrdesc), ROUND(SUM(wgh.amount)::numeric, 2) AS total_amount_spent
         FROM nutr_def AS nde
         JOIN nut_data AS nda
         ON nde.nutr_no = nda.nutr_no
         JOIN food_des AS fde
         ON nda.ndb_no = fde.ndb_no
         JOIN weight AS wgh
         ON fde.ndb_no = wgh.ndb_no
         GROUP BY 1 
         ORDER BY 2 DESC) AS sub1)  