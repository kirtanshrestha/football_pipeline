{{ config(materialized='table') }}

SELECT
    season,
    home_team AS team,
    SUM(home_team_goal) AS total_goals
FROM {{ ref('silver_matches') }}
WHERE home_team IS NOT NULL
GROUP BY season, home_team
UNION ALL
SELECT
    season,
    away_team AS team,
    SUM(away_team_goal) AS total_goals
FROM {{ ref('silver_matches') }}
WHERE away_team IS NOT NULL 
GROUP BY season, away_team