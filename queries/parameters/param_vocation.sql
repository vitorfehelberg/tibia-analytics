SELECT DISTINCT
       CASE
         WHEN vocation IS NULL THEN 'No Vocation'
         ELSE vocation
       END AS vocation
  FROM characters_behavior_periodic
 ORDER BY CASE
            WHEN vocation = 'No Vocation' THEN 0
            ELSE 1
          END,
          vocation