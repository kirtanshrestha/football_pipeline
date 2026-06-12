{{ config(materialized='table') }}

SELECT
    match_id,
    tournament,
    season,
    home_team,
    away_team,
    home_score,
    away_score,
    status,
    TIMESTAMP_SECONDS(start_timestamp) AS match_datetime,
    DATE(TIMESTAMP_SECONDS(start_timestamp)) AS match_date,
    CASE winner_code
        WHEN 1 THEN 'home'
        WHEN 2 THEN 'away'
        WHEN 0 THEN 'draw'
        ELSE 'unknown'
    END AS winner,
    CASE
        WHEN status IN ('Ended', 'AP', 'AET') THEN TRUE
        ELSE FALSE
    END AS is_finished,
    home_score - away_score AS goal_difference
FROM {{ ref('bronze_live_matches') }}