WITH base AS (
  SELECT period_start,
         period_end,
         period_status,
         character_id,
         world_id,
         account_status,
         sex,
         vocation,
         lifecycle_stage,
         lifecycle_event,
         in_guild,
         owns_house,
         is_married,
         loyalty_title
    FROM tibia_analytics.gold.characters_behavior_periodic
   WHERE granularity = 'Week'
),
filtered AS (
  SELECT base.period_start,
         base.period_end,
         base.character_id,
         base.lifecycle_stage,
         base.lifecycle_event
    FROM base AS base
   INNER JOIN tibia_analytics.gold.worlds AS worlds
      ON worlds.world_id = base.world_id
   WHERE base.period_start BETWEEN :date_range.min AND :date_range.max
     AND base.period_status != 'partial_start'
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
           OR :p_account_status = base.account_status)
     AND (:p_sex = 'All'
           OR :p_sex = base.sex)
     AND (ARRAY_CONTAINS(:p_vocation, 'All')
           OR ARRAY_CONTAINS(:p_vocation, base.vocation))
     AND (:p_in_guild = 'All'
           OR (:p_in_guild   = 'Yes' AND base.in_guild    = TRUE)
           OR (:p_in_guild   = 'No'  AND base.in_guild    = FALSE))
     AND (:p_owns_house = 'All'
           OR (:p_owns_house = 'Yes' AND base.owns_house  = TRUE)
           OR (:p_owns_house = 'No'  AND base.owns_house  = FALSE))
     AND (:p_is_married = 'All'
           OR (:p_is_married = 'Yes' AND base.is_married  = TRUE)
           OR (:p_is_married = 'No'  AND base.is_married  = FALSE))
     AND (ARRAY_CONTAINS(:p_loyalty_title, 'All')
           OR ARRAY_CONTAINS(:p_loyalty_title, base.loyalty_title))
),
period_agg AS (
  SELECT period_start,
         period_end,
         COUNT(DISTINCT character_id)                                                         AS observed_total,
         COUNT(DISTINCT CASE WHEN lifecycle_stage = 'new'              THEN character_id END) AS characters_new,
         COUNT(DISTINCT CASE WHEN lifecycle_stage = 'returning'        THEN character_id END) AS characters_returning,
         COUNT(DISTINCT CASE WHEN lifecycle_stage = 'active'           THEN character_id END) AS characters_active,
         COUNT(DISTINCT CASE WHEN lifecycle_stage = 'dormant'          THEN character_id END) AS characters_dormant,
         COUNT(DISTINCT CASE WHEN lifecycle_stage = 'churned'          THEN character_id END) AS characters_churned,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'new'              THEN character_id END) AS ev_new,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'returning'        THEN character_id END) AS ev_returning,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'dormant'          THEN character_id END) AS ev_dormant,
         COUNT(DISTINCT CASE WHEN lifecycle_event = 'churned'          THEN character_id END) AS ev_churned
    FROM filtered
   GROUP BY period_start,
            period_end
)
SELECT period_start,
       period_end,
       observed_total,
       characters_new,
       characters_returning,
       characters_active,
       characters_dormant,
       characters_churned,
       ROUND(characters_new       / observed_total, 6)                           AS new_character_rate,
       ROUND(characters_returning / observed_total, 6)                           AS returning_character_rate,
       ROUND(characters_active    / observed_total, 6)                           AS active_character_rate,
       ROUND(characters_dormant   / observed_total, 6)                           AS dormant_character_rate,
       ROUND(characters_churned   / observed_total, 6)                           AS churned_character_rate,
       ev_new, 
       ev_returning, 
       ev_dormant, 
       ev_churned,
       ROUND(ev_new       / observed_total, 6)                                   AS new_event_rate,
       ROUND(ev_returning / observed_total, 6)                                   AS returning_event_rate,
       ROUND(ev_dormant   / observed_total, 6)                                   AS dormant_event_rate,
       ROUND(ev_churned   / observed_total, 6)                                   AS churned_event_rate,
       (ev_new + ev_returning)                                                   AS inflow,
       -ev_churned                                                               AS outflow,
       (ev_new + ev_returning - ev_churned)                                      AS net_character_growth,
       ROUND((ev_new + ev_returning) / observed_total, 6)                        AS inflow_rate,
       ROUND(-ev_churned / observed_total, 6)                                    AS outflow_rate,
       ROUND((ev_new + ev_returning - ev_churned) / observed_total, 6)           AS growth_rate,
       ROUND((ev_new + ev_returning) / NULLIF(CAST(ev_churned AS DOUBLE), 0), 6) AS replacement_rate,
       ROUND(ev_new / NULLIF(ev_new + ev_returning, 0), 6)                       AS acquisition_ratio,
       ROUND(ev_returning / NULLIF(ev_new + ev_returning, 0), 6)                 AS reactivation_ratio
  FROM period_agg
 ORDER BY period_start DESC;