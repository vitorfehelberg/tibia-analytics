SELECT DISTINCT
       CASE
         WHEN loyalty_title IS NULL THEN 'No Title'
         ELSE loyalty_title
       END AS loyalty_title
  FROM tibia_analytics.gold.characters_behavior_periodic
 ORDER BY CASE 
            WHEN loyalty_title = 'No Title' THEN 0
            WHEN loyalty_title = 'Scout of Tibia' THEN 1
            WHEN loyalty_title = 'Sentinel of Tibia' THEN 2
            WHEN loyalty_title = 'Steward of Tibia' THEN 3
            WHEN loyalty_title = 'Warden of Tibia' THEN 4
            WHEN loyalty_title = 'Squire of Tibia' THEN 5
            WHEN loyalty_title = 'Warrior of Tibia' THEN 6
            WHEN loyalty_title = 'Keeper of Tibia' THEN 7
            WHEN loyalty_title = 'Guardian of Tibia' THEN 8
            WHEN loyalty_title = 'Sage of Tibia' THEN 9
            WHEN loyalty_title = 'Savant of Tibia' THEN 10
            WHEN loyalty_title = 'Enlightened of Tibia' THEN 11
            ELSE 1
          END, 
          loyalty_title