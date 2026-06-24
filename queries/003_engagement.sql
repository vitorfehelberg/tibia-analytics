WITH base AS (
  SELECT period_start,
         period_end,
         period_days,
         observed_days,
         is_partial_period,
         period_status,
         character_id,
         world_id,
         account_status,
         sex,
         vocation,
         level,
         level_delta_period,
         level_delta_short,
         level_delta_medium,
         level_delta_long,
         level_delta_xlong,
         is_active_in_period,
         is_active_1d,
         is_active_7d,
         is_active_30d,
         is_active_90d,
         in_guild,
         owns_house,
         is_married,
         loyalty_title,
         achievement_points
    FROM tibia_analytics.gold.characters_behavior_periodic
   WHERE granularity = 'Week'
),
filtered AS (
  SELECT base.period_start,
         base.period_end,
         base.period_days,
         base.observed_days,
         base.is_partial_period,
         base.period_status,
         base.character_id,
         base.level,
         base.level_delta_period,
         base.level_delta_short,
         base.level_delta_medium,
         base.level_delta_long,
         base.level_delta_xlong,
         base.is_active_in_period,
         base.is_active_1d,
         base.is_active_7d,
         base.is_active_30d,
         base.is_active_90d,
         base.achievement_points
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
         period_days,
         observed_days,
         is_partial_period,
         period_status,
         COUNT(DISTINCT character_id)                                                  AS observed_total,
         COUNT(DISTINCT CASE WHEN is_active_in_period     THEN character_id END)       AS active_characters,
         COUNT(DISTINCT CASE WHEN is_active_1d            THEN character_id END)       AS active_1d,
         COUNT(DISTINCT CASE WHEN is_active_7d            THEN character_id END)       AS active_7d,
         COUNT(DISTINCT CASE WHEN is_active_30d           THEN character_id END)       AS active_30d,
         COUNT(DISTINCT CASE WHEN is_active_90d           THEN character_id END)       AS active_90d,
         ROUND(AVG(level), 6)                                                          AS avg_level_all,
         ROUND(AVG(level_delta_period), 6)                                             AS avg_level_progression_all,
         ROUND(AVG(level_delta_short), 6)                                              AS avg_level_progression_short_all,
         ROUND(AVG(level_delta_medium), 6)                                             AS avg_level_progression_medium_all,
         ROUND(AVG(level_delta_long), 6)                                               AS avg_level_progression_long_all,
         ROUND(AVG(level_delta_xlong), 6)                                              AS avg_level_progression_xlong_all,
         ROUND(AVG(achievement_points), 6)                                             AS avg_achievement_points_all,
         ROUND(AVG(CASE WHEN is_active_in_period      THEN level END), 6)              AS avg_level_active,
         ROUND(AVG(CASE WHEN is_active_in_period      THEN level_delta_period END), 6) AS avg_level_progression_active,
         ROUND(AVG(CASE WHEN is_active_in_period      THEN level_delta_short  END), 6) AS avg_level_progression_short_active,
         ROUND(AVG(CASE WHEN is_active_in_period      THEN level_delta_medium END), 6) AS avg_level_progression_medium_active,
         ROUND(AVG(CASE WHEN is_active_in_period      THEN level_delta_long   END), 6) AS avg_level_progression_long_active,
         ROUND(AVG(CASE WHEN is_active_in_period      THEN level_delta_xlong  END), 6) AS avg_level_progression_xlong_active,
         ROUND(AVG(CASE WHEN is_active_in_period      THEN achievement_points END), 6) AS avg_achievement_points_active
    FROM filtered
   GROUP BY period_start,
            period_end,
            period_days,
            observed_days,
            is_partial_period,
            period_status
)
SELECT period_start,
       period_end,
       period_days,
       observed_days,
       is_partial_period,
       period_status,
       observed_total,
       active_characters,
       ROUND(active_characters / observed_total, 6)     AS period_activity_rate,
       ROUND(active_1d      / observed_total, 6)        AS activity_rate_1d,
       ROUND(active_7d      / observed_total, 6)        AS activity_rate_7d,
       ROUND(active_30d     / observed_total, 6)        AS activity_rate_30d,
       ROUND(active_90d     / observed_total, 6)        AS activity_rate_90d,
       ROUND(active_1d      / NULLIF(active_30d, 0), 6) AS stickiness_dau_mau,
       ROUND(active_7d      / NULLIF(active_30d, 0), 6) AS stickiness_wau_mau,
       avg_level_all,
       avg_level_progression_all,
       avg_level_progression_short_all,
       avg_level_progression_medium_all,
       avg_level_progression_long_all,
       avg_level_progression_xlong_all,
       avg_achievement_points_all,
       avg_level_active,
       avg_level_progression_active,
       avg_level_progression_short_active,
       avg_level_progression_medium_active,
       avg_level_progression_long_active,
       avg_level_progression_xlong_active,
       avg_achievement_points_active
  FROM period_agg
 ORDER BY period_start DESC;