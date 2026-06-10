WITH base AS (
  SELECT period_start,
         period_end,
         period_status,
         character_id,
         world_id,
         account_status,
         sex,
         vocation,
         is_active_90d,
         LAG(is_active_90d) OVER (PARTITION BY character_id, granularity ORDER BY period_start) AS prev_is_active_90d,
         lifecycle_event,
         in_guild,
         owns_house,
         is_married,
         loyalty_title
    FROM tibia_analytics.gold.characters_behavior_periodic
   WHERE granularity = 'Quarter'
),
filtered AS (
  SELECT base.period_start,
         base.period_end,
         base.character_id,
         base.is_active_90d,
         base.prev_is_active_90d,
         base.lifecycle_event
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
),
period_agg AS (
  SELECT period_start,
         period_end,
         COUNT(DISTINCT character_id) AS observed_total,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'new'              THEN character_id END) AS ev_new,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'returning'        THEN character_id END) AS ev_returning,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'dormant'          THEN character_id END) AS ev_dormant,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'churned'          THEN character_id END) AS ev_churned,
         COUNT(DISTINCT CASE WHEN is_active_90d                        THEN character_id END) AS active_90d,
         COUNT(DISTINCT CASE WHEN is_active_90d AND prev_is_active_90d THEN character_id END) AS retained_90d,
         COUNT(DISTINCT CASE WHEN prev_is_active_90d                   THEN character_id END) AS prev_active_90d
    FROM filtered
   GROUP BY period_start,
            period_end
)
SELECT period_start,
       period_end,
       observed_total,
       ROUND(active_90d / observed_total, 6)                                     AS activity_rate_90d,
       retained_90d,
       ROUND(retained_90d / NULLIF(prev_active_90d, 0), 6)                       AS retention_rate_90d,
       ROUND(1 - (retained_90d / NULLIF(prev_active_90d, 0)), 6)                 AS churn_rate_90d,
       (ev_new + ev_returning)                                                   AS inflow,
       -ev_churned                                                               AS outflow,
       (ev_new + ev_returning - ev_churned)                                      AS net_player_growth,
       ROUND((ev_new + ev_returning) / observed_total, 6)                        AS inflow_rate,
       ROUND(-ev_churned / observed_total, 6)                                    AS outflow_rate,
       ROUND((ev_new + ev_returning - ev_churned) / observed_total, 6)           AS growth_rate,
       ROUND((ev_new + ev_returning) / NULLIF(ev_churned, 0), 6)                 AS replacement_rate
  FROM period_agg
 ORDER BY period_start DESC