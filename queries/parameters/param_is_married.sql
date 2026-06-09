SELECT DISTINCT
       CASE 
         WHEN is_married = TRUE  THEN 'Yes'
         WHEN is_married = FALSE THEN 'No'
       END AS is_married
  FROM tibia_analytics.gold.characters_behavior_periodic
 ORDER BY is_married DESC