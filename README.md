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

🎥 Video Demo

[Watch on YouTube](https://www.youtube.com/watch?v=1dUg9BjHMNo)

📚 Course

This project was completed as part of CS50's Introduction to Databases with SQL (HarvardX).

👤 Author

Mohammad Thoriq

📄 License

This project is open source and available under the MIT License.

---

## 🛠️ How to Add It

1. **Create a new file** in your GitHub repository called `README.md`.
2. **Copy the above content** into the file.
3. **Replace placeholders**:
   - `yourusername` – your GitHub username
   - `YOUR_VIDEO_ID` – your YouTube video ID (or full link)
4. **Commit and push** to GitHub.

---

## ✅ Optional: Add a License

You can also add a `LICENSE` file (e.g., MIT License) by clicking **"Add file"** → **"Create new file"** → name it `LICENSE` and choose the MIT template.

---

## 📂 Final Repository Structure
cs50-sql-game-analytics/
├── DESIGN.md
├── README.md
├── game_analytics.db (optional)
├── queries.sql
└── schema.sql


