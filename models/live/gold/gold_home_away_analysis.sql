{{ config(materialized='table') }}

WITH home AS (
    SELECT
        home_team AS team,
        COUNT(*) AS home_matches,
        SUM(CASE WHEN winner = 'home' THEN 1 ELSE 0 END) AS home_wins,
        SUM(CASE WHEN winner = 'draw' THEN 1 ELSE 0 END) AS home_draws,
        SUM(CASE WHEN winner = 'away' THEN 1 ELSE 0 END) AS home_losses,
        ROUND(AVG(home_score), 2) AS avg_goals_home
    FROM {{ ref('silver_live_matches') }}
    WHERE is_finished = TRUE
    GROUP BY home_team
),

away AS (
    SELECT
        away_team AS team,
        COUNT(*) AS away_matches,
        SUM(CASE WHEN winner = 'away' THEN 1 ELSE 0 END) AS away_wins,
        SUM(CASE WHEN winner = 'draw' THEN 1 ELSE 0 END) AS away_draws,
        SUM(CASE WHEN winner = 'home' THEN 1 ELSE 0 END) AS away_losses,
        ROUND(AVG(away_score), 2) AS avg_goals_away
    FROM {{ ref('silver_live_matches') }}
    WHERE is_finished = TRUE
    GROUP BY away_team
)

SELECT
    h.team,
    h.home_matches,
    h.home_wins,
    h.home_draws,
    h.home_losses,
    h.avg_goals_home,
    a.away_matches,
    a.away_wins,
    a.away_draws,
    a.away_losses,
    a.avg_goals_away,
    ROUND(h.home_wins * 100.0 / h.home_matches, 1) AS home_win_pct,
    ROUND(a.away_wins * 100.0 / a.away_matches, 1) AS away_win_pct
FROM home h
JOIN away a ON h.team = a.team
ORDER BY home_win_pct DESC