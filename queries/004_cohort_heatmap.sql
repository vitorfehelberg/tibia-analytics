SELECT cr.cohort_period,
       cr.periods_elapsed,
       SUM(cr.cohort_size)                                               AS cohort_size,
       SUM(cr.retained_count)                                            AS retained_count,
       ROUND(SUM(cr.retained_count) / NULLIF(SUM(cr.cohort_size), 0), 4) AS retention_rate
  FROM tibia_analytics.gold.cohort_retention AS cr
 INNER JOIN tibia_analytics.gold.worlds      AS worlds
    ON worlds.world_id = cr.world_id
 WHERE cr.granularity          = 'Month'
   AND cr.cohort_period BETWEEN :date_range.min AND :date_range.max
   AND cr.cohort_period_status IN ('complete', 'partial_missing')
   AND cr.observation_period_status IN ('complete', 'partial_missing')
   AND (ARRAY_CONTAINS(:p_world_name, 'All')
         OR ARRAY_CONTAINS(:p_world_name, worlds.world_name))
   AND (ARRAY_CONTAINS(:p_location, 'All')
         OR ARRAY_CONTAINS(:p_location, worlds.location))
   AND (ARRAY_CONTAINS(:p_pvp_type, 'All')
         OR ARRAY_CONTAINS(:p_pvp_type, worlds.pvp_type))
   AND (:p_premium_only = 'All'
         OR (:p_premium_only = 'Yes' AND worlds.premium_only = TRUE)
         OR (:p_premium_only = 'No'  AND worlds.premium_only = FALSE))
   AND (ARRAY_CONTAINS(:p_transfer_type, 'All')
         OR ARRAY_CONTAINS(:p_transfer_type, worlds.transfer_type))
   AND (:p_battleye_protected = 'All'
         OR (:p_battleye_protected = 'Yes' AND worlds.battleye_protected = TRUE)
         OR (:p_battleye_protected = 'No'  AND worlds.battleye_protected = FALSE))
   AND (ARRAY_CONTAINS(:p_world_type, 'All')
         OR ARRAY_CONTAINS(:p_world_type, worlds.world_type))
   AND (:p_is_active = 'All'
         OR (:p_is_active  = 'Yes' AND worlds.is_active = TRUE)
         OR (:p_is_active  = 'No'  AND worlds.is_active = FALSE))
   AND (:p_account_status  = 'All'
         OR :p_account_status = cr.account_status)
   AND (:p_sex = 'All'
         OR :p_sex = cr.sex)
   AND (ARRAY_CONTAINS(:p_vocation, 'All')
         OR ARRAY_CONTAINS(:p_vocation, cr.vocation))
   AND (:p_in_guild = 'All'
         OR (:p_in_guild   = 'Yes' AND cr.in_guild    = TRUE)
         OR (:p_in_guild   = 'No'  AND cr.in_guild    = FALSE))
   AND (:p_owns_house = 'All'
         OR (:p_owns_house = 'Yes' AND cr.owns_house  = TRUE)
         OR (:p_owns_house = 'No'  AND cr.owns_house  = FALSE))
   AND (:p_is_married = 'All'
         OR (:p_is_married = 'Yes' AND cr.is_married  = TRUE)
         OR (:p_is_married = 'No'  AND cr.is_married  = FALSE))
   AND (ARRAY_CONTAINS(:p_loyalty_title, 'All')
         OR ARRAY_CONTAINS(:p_loyalty_title, cr.loyalty_title))
 GROUP BY cr.cohort_period, 
          cr.periods_elapsed
 ORDER BY cr.cohort_period, 
          cr.periods_elapsed