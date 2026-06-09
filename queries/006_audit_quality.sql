WITH expected_periods AS (
  SELECT DISTINCT
         CAST(
           CASE
             WHEN :p_granularity = 'Quarter' THEN DATE_TRUNC('quarter', full_date)
             WHEN :p_granularity = 'Month'   THEN DATE_TRUNC('month', full_date)
             WHEN :p_granularity = 'Week'    THEN DATE_TRUNC('week', full_date)
             ELSE full_date
           END
         AS DATE) AS period_start
    FROM tibia_analytics.utils.calendar
   WHERE full_date BETWEEN :date_range.min AND :date_range.max
),
base AS (
  SELECT period_start,
         MAX(period_end)              AS period_end,
         MAX(period_days)             AS period_days,
         MAX(observed_days)           AS observed_days,
         MAX(period_status)           AS period_status,
         MAX(processed_at)            AS processed_at,
         COUNT(DISTINCT character_id) AS total_characters
    FROM tibia_analytics.gold.characters_behavior_periodic
   WHERE granularity = :p_granularity
     AND period_start BETWEEN :date_range.min AND :date_range.max
   GROUP BY period_start
)
SELECT ep.period_start,
       COALESCE(ROUND(b.observed_days * 1.0 / NULLIF(b.period_days, 0), 4), 0) AS coverage_ratio,
       SUM(CASE WHEN       b.period_status IS NULL OR b.period_status = 'partial_missing' THEN 1 ELSE 0 END) OVER (ORDER BY ep.period_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS missing_periods,
       ROUND(SUM(CASE WHEN b.period_status IS NULL OR b.period_status = 'partial_missing' THEN 1 ELSE 0 END) OVER (ORDER BY ep.period_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
         / ROW_NUMBER() OVER (ORDER BY ep.period_start), 6) AS missing_period_rate,
       MAX(b.processed_at) OVER () AS last_processing_time,
       COALESCE(b.total_characters, 0) AS total_characters
  FROM expected_periods AS ep
  LEFT JOIN base AS b
    ON b.period_start   = ep.period_start
  WHERE ep.period_start <= (
          SELECT MAX(period_start)
            FROM base
       )
 ORDER BY ep.period_start DESC