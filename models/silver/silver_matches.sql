{{ config(materialized='table') }}

WITH matches AS (
    SELECT
        id,
        season,
        stage,
        CAST(DATETIME(TIMESTAMP(date)) AS DATE) AS match_date,
        home_team_api_id,
        away_team_api_id,
        home_team_goal,
        away_team_goal
    FROM {{ ref('bronze_matches') }}
    WHERE date IS NOT NULL
        AND home_team_goal IS NOT NULL
        AND away_team_goal IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) = 1
),

teams AS (
    SELECT team_api_id, team_long_name
    FROM {{ ref('bronze_teams') }}
)

SELECT
    m.id,
    m.season,
    m.stage,
    m.match_date,
    m.home_team_goal,
    m.away_team_goal,
    ht.team_long_name AS home_team,
    away_t.team_long_name AS away_team
FROM matches m
LEFT JOIN teams ht ON m.home_team_api_id = ht.team_api_id
LEFT JOIN teams away_t ON m.away_team_api_id = away_t.team_api_id