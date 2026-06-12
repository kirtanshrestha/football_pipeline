{{ config(materialized='table') }}

WITH home_matches AS (
    SELECT
        match_date,
        home_team AS team,
        home_score AS goals_scored,
        away_score AS goals_conceded,
        tournament,
        CASE winner WHEN 'home' THEN 'win' WHEN 'draw' THEN 'draw' ELSE 'loss' END AS result
    FROM {{ ref('silver_live_matches') }}
    WHERE is_finished = TRUE
),

away_matches AS (
    SELECT
        match_date,
        away_team AS team,
        away_score AS goals_scored,
        home_score AS goals_conceded,
        tournament,
        CASE winner WHEN 'away' THEN 'win' WHEN 'draw' THEN 'draw' ELSE 'loss' END AS result
    FROM {{ ref('silver_live_matches') }}
    WHERE is_finished = TRUE
),

all_matches AS (
    SELECT * FROM home_matches
    UNION ALL
    SELECT * FROM away_matches
)

SELECT
    team,
    tournament,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS losses,
    SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS draws,
    SUM(goals_scored) AS goals_scored,
    SUM(goals_conceded) AS goals_conceded,
    ROUND(SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS win_percentage
FROM all_matches
GROUP BY team, tournament
ORDER BY win_percentage DESC