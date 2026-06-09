SELECT cr.periods_elapsed,
       CASE :p_cohort_dimension
         WHEN 'account_status' THEN cr.account_status
         WHEN 'vocation'       THEN cr.vocation
         WHEN 'world_name'     THEN worlds.world_name
         WHEN 'in_guild'       THEN CASE WHEN cr.in_guild   THEN 'Yes' ELSE 'No' END
         WHEN 'owns_house'     THEN CASE WHEN cr.owns_house THEN 'Yes' ELSE 'No' END
         WHEN 'is_married'     THEN CASE WHEN cr.is_married THEN 'Yes' ELSE 'No' END
         ELSE 'All'
       END                                                               AS cohort_dimension,
       SUM(cr.cohort_size)                                               AS cohort_size,
       SUM(cr.retained_count)                                            AS retained_count,
       ROUND(SUM(cr.retained_count) / NULLIF(SUM(cr.cohort_size), 0), 4) AS retention_rate
  FROM tibia_analytics.gold.cohort_retention AS cr
 INNER JOIN tibia_analytics.gold.worlds As worlds
    ON worlds.world_id = cr.world_id
 WHERE cr.granularity          = 'Month'
   AND cr.cohort_period BETWEEN :date_range.min AND :date_range.max
   AND cr.cohort_period_status = 'full'
   AND cr.observation_period_status = 'full'
   AND (:p_world_name IS NULL
         OR ARRAY_SIZE(:p_world_name) = 0 
         OR ARRAY_CONTAINS(:p_world_name, worlds.world_name))
   AND (:p_location IS NULL
         OR ARRAY_SIZE(:p_location) = 0 
         OR ARRAY_CONTAINS(:p_location, worlds.location))
   AND (:p_pvp_type IS NULL
         OR ARRAY_SIZE(:p_pvp_type) = 0 
         OR ARRAY_CONTAINS(:p_pvp_type, worlds.pvp_type))
   AND (:p_premium_only = 'All'
         OR (:p_premium_only   = 'Yes' AND worlds.premium_only   = TRUE)
         OR (:p_premium_only   = 'No'  AND worlds.premium_only   = FALSE))
   AND (:p_transfer_type IS NULL
         OR ARRAY_SIZE(:p_transfer_type) = 0 
         OR ARRAY_CONTAINS(:p_transfer_type, worlds.transfer_type))
   AND (:p_battleye_protected = 'All'
         OR (:p_battleye_protected   = 'Yes' AND worlds.battleye_protected   = TRUE)
         OR (:p_battleye_protected   = 'No'  AND worlds.battleye_protected   = FALSE))
   AND (:p_world_type IS NULL
         OR ARRAY_SIZE(:p_world_type) = 0 
         OR ARRAY_CONTAINS(:p_world_type, worlds.world_type))
   AND (:p_is_active = 'All'
         OR (:p_is_active   = 'Yes' AND worlds.is_active   = TRUE)
         OR (:p_is_active   = 'No'  AND worlds.is_active   = FALSE))
   AND (:p_account_status = 'All'
         OR :p_account_status = cr.account_status)
   AND (:p_sex = 'All'
         OR :p_sex = cr.sex)
   AND (:p_vocation IS NULL
         OR ARRAY_SIZE(:p_vocation) = 0 
         OR ARRAY_CONTAINS(:p_vocation, cr.vocation)
         OR (cr.vocation IS NULL AND ARRAY_CONTAINS(:p_vocation, 'No Vocation')))
   AND (:p_in_guild = 'All'
         OR (:p_in_guild   = 'Yes' AND cr.in_guild   = TRUE)
         OR (:p_in_guild   = 'No'  AND cr.in_guild   = FALSE))
   AND (:p_owns_house = 'All'
         OR (:p_owns_house = 'Yes' AND cr.owns_house = TRUE)
         OR (:p_owns_house = 'No'  AND cr.owns_house = FALSE))
   AND (:p_is_married = 'All'
         OR (:p_is_married = 'Yes' AND cr.is_married = TRUE)
         OR (:p_is_married = 'No'  AND cr.is_married = FALSE))
   AND (:p_loyalty_title IS NULL
         OR ARRAY_SIZE(:p_loyalty_title) = 0 
         OR ARRAY_CONTAINS(:p_loyalty_title, cr.loyalty_title)
         OR (cr.loyalty_title IS NULL AND ARRAY_CONTAINS(:p_loyalty_title, 'No Title')))
 GROUP BY cr.periods_elapsed, 
          cohort_dimension
 ORDER BY cr.periods_elapsed, 
          cohort_dimension