SELECT chars.granularity,
       chars.period_start,
       chars.period_end,
       chars.period_days,
       chars.observed_days,
       chars.is_partial_period,
       chars.period_status,
       chars.character_id,
       worlds.world_name,
       chars.account_status,
       chars.sex,
       chars.vocation,
       chars.level_start,
       chars.level,
       chars.level_delta_period,
       chars.level_delta_short,
       chars.level_delta_medium,
       chars.level_delta_long,
       chars.level_delta_xlong,
       chars.first_seen_date,
       chars.last_login_date,
       chars.days_since_last_login,
       chars.is_active_in_period,
       chars.is_active_1d,
       chars.is_active_7d,
       chars.is_active_30d,
       chars.is_active_90d,
       chars.lifecycle_stage,
       chars.lifecycle_event,
       chars.new_events,
       chars.returning_events,
       chars.dormant_events,
       chars.churned_events,
       chars.in_guild,
       chars.owns_house,
       chars.is_married,
       chars.loyalty_title,
       chars.achievement_points,
       chars.processed_at
  FROM tibia_analytics.gold.characters_behavior_periodic AS chars
 INNER JOIN tibia_analytics.gold.worlds AS worlds
    ON worlds.world_id = chars.world_id
 WHERE chars.granularity = :p_granularity
   AND chars.period_start BETWEEN :date_range.min AND :date_range.max
   AND (ARRAY_CONTAINS(:p_world_name, 'All')
         OR ARRAY_CONTAINS(:p_world_name, worlds.world_name))
   AND (:p_character_id = 'All' 
         OR chars.character_id = :p_character_id)
 ORDER BY chars.period_start DESC,
          worlds.world_name,
          chars.level DESC