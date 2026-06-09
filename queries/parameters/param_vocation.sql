SELECT DISTINCT
       CASE
         WHEN vocation LIKE '%Druid%'    THEN 'Druid'
         WHEN vocation LIKE '%Knight%'   THEN 'Knight'
         WHEN vocation LIKE '%Monk%'     THEN 'Monk'
         WHEN vocation LIKE '%Paladin%'  THEN 'Paladin'
         WHEN vocation LIKE '%Sorcerer%' THEN 'Sorcerer'
         WHEN vocation IS NULL           THEN 'No Vocation'
         ELSE vocation
       END AS vocation
  FROM characters_behavior_periodic
 ORDER BY CASE
            WHEN vocation = 'No Vocation' THEN 0
            ELSE 1
          END,
          vocation