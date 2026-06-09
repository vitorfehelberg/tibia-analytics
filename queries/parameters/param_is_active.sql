SELECT DISTINCT
       CASE 
         WHEN is_active = TRUE  THEN 'Yes'
         WHEN is_active = FALSE THEN 'No'
       END AS is_active
  FROM tibia_analytics.gold.worlds
 ORDER BY is_active DESC