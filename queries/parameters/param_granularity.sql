SELECT DISTINCT
       granularity
  FROM tibia_analytics.gold.characters_behavior_periodic
 ORDER BY CASE
            WHEN granularity = 'Day'     THEN 0
            WHEN granularity = 'Week'    THEN 1
            WHEN granularity = 'Month'   THEN 2
            WHEN granularity = 'Quarter' THEN 3
          END,
          granularity