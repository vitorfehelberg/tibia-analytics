SELECT DISTINCT
       CASE 
         WHEN battleye_protected = TRUE  THEN 'Yes'
         WHEN battleye_protected = FALSE THEN 'No'
       END AS battleye_protected
  FROM tibia_analytics.gold.worlds
 ORDER BY battleye_protected DESC