# Game Analytics Dashboard – CS50 SQL Final Project

A SQLite database for storing and analysing Tic‑Tac‑Toe gameplay data. This project was created as the final project for Harvard's CS50 SQL course.

## 📁 Project Files

| File | Description |
|------|-------------|
| `schema.sql` | Database structure (tables, indexes, sample data) |
| `queries.sql` | 10 analytical queries for game insights |
| `DESIGN.md` | Full project documentation (scope, design, limitations) |
| `game_analytics.db` | Sample SQLite database (optional – can be created from `schema.sql`) |

## 🎯 Features

- **Normalised schema** with three tables: `games`, `moves`, and `ai_decisions`
- **Foreign keys** for referential integrity (`ON DELETE CASCADE`)
- **Indexes** for query performance (`game_id`, `action`, `move_id`)
- **10 analytical queries** covering:
  - Win rates
  - Most common winning moves
  - AI learning curves
  - Move sequences
  - Session‑based performance
  - And more

## 📊 Sample Data

The database includes sample data from **3 Tic‑Tac‑Toe games** – enough to demonstrate the structure and query functionality.

## 🚀 How to Use

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/cs50-sql-game-analytics.git
   cd cs50-sql-game-analytics

2. **Create the database**:
   ```bash
   sqlite3 game_analytics.db
   .read schema.sql

3. **Run the queries**:
   ```bash
   .read queries.sql

This project was completed as part of CS50's Introduction to Databases with SQL (HarvardX).
