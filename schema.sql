-- ============================================================
-- Game Analytics Dashboard – Database Schema
-- CS50 SQL Final Project
-- ============================================================

-- Game sessions: one row per game played
CREATE TABLE "games" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "game_type" TEXT NOT NULL,               -- 'nim', 'minesweeper', 'tictactoe'
    "ai_vs_ai" INTEGER NOT NULL,             -- 1 if both players were AI, 0 otherwise
    "first_player" TEXT NOT NULL,            -- 'human', 'ai', or 'random'
    "winner" TEXT,                           -- 'human', 'ai', 'draw', or NULL
    "duration_ms" INTEGER,                   -- game duration in milliseconds
    "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Individual moves within a game
CREATE TABLE "moves" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "game_id" INTEGER NOT NULL,
    "move_number" INTEGER NOT NULL,          -- 1‑based turn order
    "player" TEXT NOT NULL,                  -- 'human' or 'ai'
    "state_before" TEXT NOT NULL,            -- JSON representation (e.g., board or piles)
    "action" TEXT NOT NULL,                  -- e.g., '(2,3)' or 'row,col'
    "is_winning" INTEGER DEFAULT 0,          -- 1 if this move ended the game
    FOREIGN KEY ("game_id") REFERENCES "games"("id") ON DELETE CASCADE
);

-- AI decisions (for reinforcement learning analysis)
CREATE TABLE "ai_decisions" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "move_id" INTEGER NOT NULL,
    "q_value" REAL,                          -- Q‑value before the move
    "exploration" INTEGER,                   -- 1 if chosen randomly (epsilon), 0 otherwise
    "best_q" REAL,                           -- Best Q‑value among available actions
    FOREIGN KEY ("move_id") REFERENCES "moves"("id") ON DELETE CASCADE
);

-- Optional: sample indexes for query performance
CREATE INDEX "idx_moves_game_id" ON "moves" ("game_id");
CREATE INDEX "idx_moves_action" ON "moves" ("action");
CREATE INDEX "idx_ai_decisions_move_id" ON "ai_decisions" ("move_id");

-- Sample data: 3 games (all Tic‑Tac‑Toe)
INSERT INTO "games" ("game_type", "ai_vs_ai", "first_player", "winner", "duration_ms", "timestamp")
VALUES
    ('tictactoe', 1, 'ai', 'ai', 1500, datetime('now', '-1 hour')),
    ('tictactoe', 1, 'human', 'draw', 2300, datetime('now', '-30 minutes')),
    ('tictactoe', 0, 'ai', 'human', 1800, datetime('now', '-15 minutes'));

-- Sample moves for game 1 (Tic‑Tac‑Toe)
INSERT INTO "moves" ("game_id", "move_number", "player", "state_before", "action", "is_winning")
VALUES
    (1, 1, 'ai', '[[],[],[]]', '(0,0)', 0),
    (1, 2, 'ai', '[[X],[],[]]', '(1,1)', 0),
    (1, 3, 'ai', '[[X],[O],[]]', '(0,1)', 0),
    (1, 4, 'ai', '[[X,O],[O],[]]', '(1,2)', 0),
    (1, 5, 'ai', '[[X,O],[O,X],[]]', '(0,2)', 1);   -- winning move
