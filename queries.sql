-- ============================================================
-- Game Analytics Dashboard – Queries
-- CS50 SQL Final Project
-- ============================================================

-- 1. Overall win rates for the AI across all game types
-- Shows how often the AI wins compared to humans
SELECT
    game_type,
    COUNT(*) AS total_games,
    SUM(CASE WHEN winner = 'ai' THEN 1 ELSE 0 END) AS ai_wins,
    SUM(CASE WHEN winner = 'human' THEN 1 ELSE 0 END) AS human_wins,
    SUM(CASE WHEN winner = 'draw' THEN 1 ELSE 0 END) AS draws,
    ROUND(100.0 * SUM(CASE WHEN winner = 'ai' THEN 1 ELSE 0 END) / COUNT(*), 2) AS ai_win_rate
FROM games
GROUP BY game_type
ORDER BY ai_win_rate DESC;


-- 2. Win rate comparison: AI vs human, grouped by who started first
-- Does starting first give an advantage to either player?
SELECT
    game_type,
    first_player,
    COUNT(*) AS total_games,
    SUM(CASE WHEN winner = 'ai' THEN 1 ELSE 0 END) AS ai_wins,
    ROUND(100.0 * SUM(CASE WHEN winner = 'ai' THEN 1 ELSE 0 END) / COUNT(*), 2) AS ai_win_rate
FROM games
WHERE winner IN ('ai', 'human')
GROUP BY game_type, first_player
ORDER BY game_type, first_player;


-- 3. Average game duration by game type and winner
-- Are winning games shorter or longer on average?
SELECT
    game_type,
    winner,
    COUNT(*) AS games,
    ROUND(AVG(duration_ms), 2) AS avg_duration_ms,
    ROUND(MIN(duration_ms), 2) AS fastest_ms,
    ROUND(MAX(duration_ms), 2) AS slowest_ms
FROM games
GROUP BY game_type, winner
ORDER BY game_type, avg_duration_ms;


-- 4. Most common winning move in each game type
-- For Tic‑Tac‑Toe: which cell is most frequently the winning move?
SELECT
    game_type,
    action,
    COUNT(*) AS times_used,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY game_type), 2) AS percentage
FROM moves
JOIN games ON moves.game_id = games.id
WHERE moves.is_winning = 1
GROUP BY game_type, action
ORDER BY game_type, times_used DESC
LIMIT 5;


-- 5. AI learning curve – win rate over time (using a window function)
-- How does AI performance improve as it plays more games?
SELECT
    game_number,
    running_avg_win_rate
FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY id) AS game_number,
        AVG(CASE WHEN winner = 'ai' THEN 1 ELSE 0 END)
            OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg_win_rate
    FROM games
    WHERE game_type = 'tictactoe'
) AS rolling_win_rates
WHERE game_number % 10 = 0   -- every 10 games
ORDER BY game_number;


-- 6. Which first move is most successful in Tic‑Tac‑Toe?
-- Does playing center, corner, or edge correlate with higher win rates?
SELECT
    moves.action AS first_move,
    COUNT(*) AS games,
    SUM(CASE WHEN games.winner = 'ai' THEN 1 ELSE 0 END) AS ai_wins,
    ROUND(100.0 * SUM(CASE WHEN games.winner = 'ai' THEN 1 ELSE 0 END) / COUNT(*), 2) AS ai_win_rate
FROM moves
JOIN games ON moves.game_id = games.id
WHERE moves.move_number = 1
  AND games.game_type = 'tictactoe'
GROUP BY moves.action
ORDER BY ai_win_rate DESC
LIMIT 5;


-- 7. Average Q‑value of AI decisions by game outcome
-- Is there a correlation between Q‑values and winning?
SELECT
    games.winner,
    ROUND(AVG(ai_decisions.q_value), 4) AS avg_q_value,
    COUNT(*) AS total_ai_moves
FROM ai_decisions
JOIN moves ON ai_decisions.move_id = moves.id
JOIN games ON moves.game_id = games.id
GROUP BY games.winner
ORDER BY avg_q_value DESC;


-- 8. Exploration vs exploitation – how often does the AI explore?
-- Does exploration frequency differ between wins and losses?
SELECT
    games.winner,
    ROUND(100.0 * SUM(CASE WHEN ai_decisions.exploration = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS exploration_rate,
    COUNT(*) AS total_ai_moves
FROM ai_decisions
JOIN moves ON ai_decisions.move_id = moves.id
JOIN games ON moves.game_id = games.id
GROUP BY games.winner
ORDER BY exploration_rate DESC;


-- 9. Most common move sequences (using self‑join) – top 3 first moves
-- What are the most popular opening moves in Tic‑Tac‑Toe?
WITH first_moves AS (
    SELECT
        game_id,
        action AS first_action,
        LEAD(action, 1) OVER (PARTITION BY game_id ORDER BY move_number) AS second_action
    FROM moves
    JOIN games ON moves.game_id = games.id
    WHERE games.game_type = 'tictactoe'
)
SELECT
    first_action,
    second_action,
    COUNT(*) AS sequence_count
FROM first_moves
WHERE second_action IS NOT NULL
GROUP BY first_action, second_action
ORDER BY sequence_count DESC
LIMIT 5;


-- 10. CTE: games grouped into sessions (10‑game blocks) and their average win rate
-- Shows improvement over sessions (e.g., every 10 games)
WITH game_sessions AS (
    SELECT
        id,
        winner,
        NTILE(10) OVER (ORDER BY id) AS session_group
    FROM games
    WHERE game_type = 'tictactoe'
)
SELECT
    session_group,
    COUNT(*) AS games_in_session,
    ROUND(100.0 * SUM(CASE WHEN winner = 'ai' THEN 1 ELSE 0 END) / COUNT(*), 2) AS session_win_rate
FROM game_sessions
GROUP BY session_group
ORDER BY session_group;
