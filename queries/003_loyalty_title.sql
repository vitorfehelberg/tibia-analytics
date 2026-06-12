WITH base AS (
  SELECT period_start,
         period_status,
         character_id,
         world_id,
         account_status,
         sex,
         vocation,
         in_guild,
         owns_house,
         is_married,
         loyalty_title
    FROM tibia_analytics.gold.characters_behavior_periodic
   WHERE granularity = 'Week'
),
filtered AS (
  SELECT base.period_start,
         base.character_id,
         base.loyalty_title
    FROM base AS base
   INNER JOIN tibia_analytics.gold.worlds AS worlds
      ON worlds.world_id = base.world_id
   WHERE base.period_start BETWEEN :date_range.min AND :date_range.max
     AND base.period_status != 'partial_start'
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
           OR :p_account_status = base.account_status)
     AND (:p_sex = 'All'
           OR :p_sex = base.sex)
     AND (:p_vocation IS NULL
           OR ARRAY_SIZE(:p_vocation) = 0 
           OR ARRAY_CONTAINS(:p_vocation, base.vocation)
           OR (base.vocation IS NULL AND ARRAY_CONTAINS(:p_vocation, 'No Vocation')))
     AND (:p_in_guild = 'All'
           OR (:p_in_guild   = 'Yes' AND base.in_guild   = TRUE)
           OR (:p_in_guild   = 'No'  AND base.in_guild   = FALSE))
     AND (:p_owns_house = 'All'
           OR (:p_owns_house = 'Yes' AND base.owns_house = TRUE)
           OR (:p_owns_house = 'No'  AND base.owns_house = FALSE))
     AND (:p_is_married = 'All'
           OR (:p_is_married = 'Yes' AND base.is_married = TRUE)
           OR (:p_is_married = 'No'  AND base.is_married = FALSE))
     AND (:p_loyalty_title IS NULL
           OR ARRAY_SIZE(:p_loyalty_title) = 0 
           OR ARRAY_CONTAINS(:p_loyalty_title, base.loyalty_title)
           OR (base.loyalty_title IS NULL AND ARRAY_CONTAINS(:p_loyalty_title, 'No Title')))
)
SELECT period_start,
       loyalty_title,
       COUNT(DISTINCT character_id) AS players
  FROM filtered
 GROUP BY period_start, 
          loyalty_title
 ORDER BY period_start DESC;