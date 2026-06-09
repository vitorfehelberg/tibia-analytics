SELECT DISTINCT
       CASE 
         WHEN premium_only = TRUE  THEN 'Yes'
         WHEN premium_only = FALSE THEN 'No'
       END AS premium_only
  FROM tibia_analytics.gold.worlds
 ORDER BY premium_only DESC