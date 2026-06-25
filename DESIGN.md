# Design Document

By Mohammad Thoriq

Video overview: <https://youtu.be/1dUg9BjHMNo>

## Scope

The purpose of this database is to store and analyse gameplay data from my own games, which is Tic-Tac-Toe. The goal is to answer questions about AI performance, player behavior, and game trends – similar to a real‑world analytics dashboard.

**Included in the scope:**
- Games played (Tic‑Tac‑Toe, Nim, Minesweeper)
- Players (human, AI, or both)
- Moves made during each game
- AI decisions (for reinforcement learning analysis: Q‑values, exploration choices)
- Basic analytics: win rates, duration, popular moves, learning curves

**Outside the scope:**
- User accounts or authentication
- Live multiplayer support
- Real‑time data streaming (the data is logged after games finish)
- Visualisation dashboard (the database is designed to support queries that could power a dashboard, but the dashboard itself is not part of the database)

## Functional Requirements

A user (data analyst or developer) should be able to:
- Log a complete game session, including all moves and AI decisions.
- Query win rates for AI vs human, by game type and starting player.
- Analyse game duration patterns (e.g., average duration by winner).
- Identify the most common winning moves and opening moves.
- Track AI learning curves (win rate over time).
- Correlate AI Q‑values with game outcomes.
- Measure exploration vs exploitation frequency in AI decisions.

**Beyond scope:**
- Users cannot update or delete game records (the database is append‑only – logging is the only write operation).
- Users cannot add new game types without updating the schema.
- No user interface or visualisation is provided – queries must be run directly in SQLite.

## Representation

### Entities

#### `games`
Represents a single game session.

| Column        | Type      | Constraints                 | Justification |
|---------------|-----------|-----------------------------|-----------------------------------------------------------------------------------------|
| `id`          | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique identifier for each game.                                                        |
| `game_type`   | `TEXT`    | `NOT NULL`                  | Distinguishes between games (e.g., 'nim', 'tictactoe').                                 |
| `ai_vs_ai`    | `INTEGER` | `NOT NULL` (0 or 1)         | Boolean flag; 1 if both players were AI, 0 otherwise.                                   |
| `first_player`| `TEXT`    | `NOT NULL`                  | Indicates who moved first ('human', 'ai', or 'random').                                 |
| `winner`      | `TEXT`    | `NULL` allowed              | 'human', 'ai', 'draw', or NULL if unfinished (though my system always completes games). |
| `duration_ms` | `INTEGER` | `NULL` allowed              | Game duration in milliseconds (optional, but useful for analysis).                      |
| `timestamp`   | `DATETIME`| `DEFAULT CURRENT_TIMESTAMP` | When the game was played – automatically recorded.                                      |

#### `moves`
Represents a single move within a game.

| Column | Type | Constraints | Justification |
|----------------|-----------|-----------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `id`           | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique identifier for each move.                                                                                         |
| `game_id`      | `INTEGER` | `NOT NULL`, `FOREIGN KEY`   | Links to the parent game.                                                                                                |
| `move_number`  | `INTEGER` | `NOT NULL`                  | 1‑based turn order (helps reconstruct game flow).                                                                        |
| `player`       | `TEXT`    | `NOT NULL`                  | 'human' or 'ai' – who made this move.                                                                                    |
| `state_before` | `TEXT`    | `NOT NULL`                  | JSON representation of the board/piles before the move – allows full game replay without storing a separate board table. |
| `action`       | `TEXT`    | `NOT NULL`                  | Human‑readable move description (e.g., '(2,3)' for Nim, 'row,col' for Tic‑Tac‑Toe).                                      |
| `is_winning`   | `INTEGER` | `DEFAULT 0`                 | Boolean flag; 1 if this move ended the game in a win.                                                                    |

#### `ai_decisions`
Represents AI decision‑making data for a move (optional, used for reinforcement learning analysis).

| Column        | Type     | Constraints                 | Justification                                                    |
|---------------|----------|-----------------------------|------------------------------------------------------------------|
| `id`          | `INTEGER`| `PRIMARY KEY AUTOINCREMENT` | Unique identifier.                                               |
| `move_id`     | `INTEGER`| `NOT NULL`, `FOREIGN KEY`   | Links to the move in the `moves` table.                          |
| `q_value`     | `REAL`   | `NULL` allowed              | Q‑value of the chosen action before the move.                    |
| `exploration` | `INTEGER`| `NULL` allowed              | 1 if the move was chosen randomly (epsilon‑greedy), 0 otherwise. |
| `best_q`      | `REAL`   | `NULL` allowed              | The highest Q‑value among all available actions at that state.   |

### Relationships

The database has three main entities with the following relationships (represented in the Entity Relationship Diagram below):
+---------+     1       +-------+      1     +--------------+
| games   |------------>| moves |<-----------| ai_decisions |
+---------+   (one)     +-------+    (many)  +--------------+
    |                       |
    | (one)                 | (many)
    +-----------------------+


**Relationships described:**

1. **One game has many moves** (1:N) – a `games.id` can appear many times in `moves.game_id`.
2. **One move can have at most one AI decision** (1:1) – not all moves are AI moves, so `ai_decisions` is optional and linked via `move_id`.
3. **No direct link between games and ai_decisions** – they are connected through the `moves` table (games → moves → ai_decisions).

The foreign keys enforce referential integrity: if a game is deleted, all its moves and associated AI decisions are automatically removed (`ON DELETE CASCADE`).

## Optimizations

To improve query performance, I created the following indexes:

| Index                      | Columns   | Purpose                                                                                                  |
|----------------------------|-----------|----------------------------------------------------------------------------------------------------------|
| `idx_moves_game_id`        | `game_id` | Speeds up joins when querying all moves for a specific game (used in queries that join games and moves). |
| `idx_moves_action`         | `action`  | Accelerates queries that group or filter by move type (e.g., finding common winning moves).              |
| `idx_ai_decisions_move_id` | `move_id` | Speeds up joins between `moves` and `ai_decisions` (used in Q‑value and exploration analysis).           |

These indexes are justified because:
- `game_id` is frequently used in joins (queries 1–10 all join `games` with `moves` or `ai_decisions`).
- `action` is used in grouping queries (queries 4, 6, 9).
- `move_id` is the primary link to AI decision data (queries 7, 8).

No views were created because the queries are varied and cover many different aggregations – each query is specific enough that a view would not reduce complexity.

## Limitations

**Design limitations:**

1. **No player identity table** – the database does not track individual human players. All human players are treated as a single entity ('human'). This limits analysis to aggregate human behaviour rather than per‑player behaviour.

2. **JSON storage** – `state_before` stores board states as JSON, which is convenient but means the database cannot easily query individual board positions (e.g., "find all games where the center cell was played first"). A more normalised design would use separate tables for board positions, but this would increase complexity.

3. **Limited AI decision tracking** – `ai_decisions` only stores the Q‑value for the chosen action and the best Q‑value. It does not store the full action set or the model parameters (e.g., learning rate, discount factor). This makes it difficult to fully replicate the AI's decision process outside the original program.

4. **Append‑only** – the database does not support updating or deleting records (except via `ON DELETE CASCADE`). This is by design (keeping a permanent log), but it means corrections cannot be made without reloading the data.

5. **No support for different AI algorithms** – the schema assumes Q‑learning, so it would need adjustments to store data from other AI approaches (e.g., minimax, neural networks).

**What the database might not represent well:**

- **Complex game states** – storing state as JSON is fine for simple games (Tic‑Tac‑Toe, Nim), but for games with large boards or complex moves, JSON might become unwieldy and slow to query.
- **Multi‑player games** – the current design only supports two players (human vs AI or AI vs AI). It would need modification to handle more than two players or team‑based games.
- **Real‑time analytics** – the database is designed for post‑game analysis, not live dashboards. It does not have triggers or functions to update derived tables automatically.
- **Historical trends** – while the `timestamp` column allows ordering by time, there is no built‑in support for time‑series analysis (e.g., comparing win rates between months). This would need to be handled in the query layer.

Despite these limitations, the database effectively serves its core purpose: providing a structured, queryable log of gameplay data for analysis.
