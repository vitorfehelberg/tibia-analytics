SELECT DISTINCT
       vocation
  FROM characters_behavior_periodic
 ORDER BY CASE
            WHEN vocation = 'No Vocation' THEN 0
            ELSE 1
          END,
          vocation