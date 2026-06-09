SELECT chars.snapshot_date,
       chars.character_id,
       worlds.world_name,
       chars.account_status,
       chars.sex,
       chars.vocation,
       chars.level,
       chars.level_delta_1d,
       chars.level_delta_7d,
       chars.level_delta_30d,
       chars.level_delta_90d,
       chars.first_seen_date,
       chars.last_login_date,
       chars.days_since_last_login,
       chars.is_active_1d,
       chars.is_active_7d,
       chars.is_active_30d,
       chars.is_active_90d,
       chars.lifecycle_stage,
       chars.lifecycle_event,
       chars.in_guild,
       chars.owns_house,
       chars.is_married,
       chars.loyalty_title,
       chars.achievement_points,
       chars.processed_at
  FROM tibia_analytics.gold.characters_behavior_daily AS chars
 INNER JOIN tibia_analytics.gold.worlds AS worlds
    ON worlds.world_id = chars.world_id
 WHERE chars.snapshot_date BETWEEN :date_range.min AND :date_range.max
   AND (:p_world_name IS NULL
         OR ARRAY_SIZE(:p_world_name) = 0 
         OR ARRAY_CONTAINS(:p_world_name, worlds.world_name))
   AND (:p_character_id = 'All' 
         OR chars.character_id = :p_character_id)
 ORDER BY chars.snapshot_date DESC,
          worlds.world_name,
          chars.level DESC