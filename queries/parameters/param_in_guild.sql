SELECT DISTINCT
       CASE 
         WHEN in_guild = TRUE  THEN 'Yes'
         WHEN in_guild = FALSE THEN 'No'
       END AS in_guild
  FROM tibia_analytics.gold.characters_behavior_periodic
 ORDER BY in_guild DESC