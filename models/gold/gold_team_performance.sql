{{ config(materialized='table') }}

WITH home AS (
    SELECT
        season,
        home_team AS team,
        home_team_goal AS goals_scored,
        away_team_goal AS goals_conceded,
        CASE
            WHEN home_team_goal > away_team_goal THEN 'win'
            WHEN home_team_goal < away_team_goal THEN 'loss'
            ELSE 'draw'
        END AS result
    FROM {{ ref('silver_matches') }}
),

away AS (
    SELECT
        season,
        away_team AS team,
        away_team_goal AS goals_scored,
        home_team_goal AS goals_conceded,
        CASE
            WHEN away_team_goal > home_team_goal THEN 'win'
            WHEN away_team_goal < home_team_goal THEN 'loss'
            ELSE 'draw'
        END AS result
    FROM {{ ref('silver_matches') }}
),

combined AS (
    SELECT * FROM home
    UNION ALL
    SELECT * FROM away
)

SELECT
    season,
    team,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS losses,
    SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS draws,
    SUM(goals_scored) AS goals_scored,
    SUM(goals_conceded) AS goals_conceded
FROM combined
WHERE team IS NOT NULL
GROUP BY season, team
ORDER BY season, wins DESC