SELECT DISTINCT
       CASE 
         WHEN owns_house = TRUE  THEN 'Yes'
         WHEN owns_house = FALSE THEN 'No'
       END AS owns_house
  FROM tibia_analytics.gold.characters_behavior_periodic
 ORDER BY owns_house DESC