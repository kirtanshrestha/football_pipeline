{{ config(materialized='table') }}

SELECT
    season,
    home_team AS team,
    COUNT(*) AS home_matches,
    SUM(CASE WHEN home_team_goal > away_team_goal THEN 1 ELSE 0 END) AS home_wins,
    SUM(CASE WHEN home_team_goal < away_team_goal THEN 1 ELSE 0 END) AS home_losses,
    SUM(CASE WHEN home_team_goal = away_team_goal THEN 1 ELSE 0 END) AS home_draws,
    ROUND(AVG(home_team_goal), 2) AS avg_goals_at_home
FROM {{ ref('silver_matches') }}
WHERE home_team IS NOT NULL
GROUP BY season, home_team