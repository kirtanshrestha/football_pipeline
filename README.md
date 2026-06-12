# Football Analytics Pipeline

An end-to-end data engineering project covering two football data pipelines — a historical analytics pipeline built on Kaggle data, and a live pipeline pulling real match data from the SofaScore API through Kafka into BigQuery with a Looker Studio dashboard.

Built as part of **#60DaysOfLearning2026** — Leapfrog Learning Path.

---

## Two Pipelines

### Pipeline 1 — Historical Analytics (Kaggle)
```
Kaggle SQLite Dataset
        │
        ▼
Python ingestion
        │
        ▼
BigQuery (raw dataset)
        │
        ▼
dbt Bronze → Silver → Gold
        │
        ▼
Analytics ready tables
```

### Pipeline 2 — Live Match Data (SofaScore API)
```
SofaScore API (6 top clubs)
        │
        ▼
Python ingestion
        │
        ▼
Kafka (football-matches topic)
        │
        ▼
Consumer → BigQuery (dev.live_matches)
        │
        ▼
dbt Bronze → Silver → Gold
        │
        ▼
Looker Studio Dashboard
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Sources | Kaggle European Soccer Database, SofaScore API |
| Streaming | Apache Kafka + Zookeeper (Docker) |
| Cloud Warehouse | Google BigQuery |
| Transformation | dbt (data build tool) |
| Dashboard | Looker Studio |
| Language | Python 3, SQL |
| Libraries | pandas, kafka-python, google-cloud-bigquery, dbt-bigquery, python-dotenv |

---

## Project Structure

```
football_pipeline/
├── models/
│   ├── bronze/                          # Kaggle pipeline bronze layer
│   │   ├── bronze_matches.sql
│   │   ├── bronze_teams.sql
│   │   ├── bronze_players.sql
│   │   └── sources.yml
│   │
│   ├── silver/                          # Kaggle pipeline silver layer
│   │   ├── silver_matches.sql
│   │   └── schema.yml
│   │
│   ├── gold/                            # Kaggle pipeline gold layer
│   │   ├── gold_team_performance.sql
│   │   ├── gold_home_away_performance.sql
│   │   ├── gold_top_scoring_teams.sql
│   │   └── schema.yml
│   │
│   └── live/                            # Live pipeline layers
│       ├── bronze/
│       │   ├── bronze_live_matches.sql
│       │   └── sources.yml
│       ├── silver/
│       │   ├── silver_live_matches.sql
│       │   └── schema.yml
│       └── gold/
│           ├── gold_team_form.sql
│           ├── gold_home_away_analysis.sql
│           └── schema.yml
│
├── load_to_bigquery.py     # Loads Kaggle SQLite data into BigQuery
├── dbt_project.yml
└── README.md
```

---

## Pipeline 1 — Kaggle Historical Data

### Layers

**Bronze** — exact copy of raw SQLite tables. No transformations.

**Silver** — cleaned and enriched:
- Cast date strings to proper DATE type
- Removed null matches
- Joined team names onto match records
- Deduplicated records from source data quality issues

**Gold** — analytics-ready metrics:
- `gold_team_performance` — wins, losses, draws, goals per team per season
- `gold_home_away_performance` — home win rate and avg goals at home
- `gold_top_scoring_teams` — total goals per team per season

### Running

```bash
pip install dbt-bigquery google-cloud-bigquery pandas
python load_to_bigquery.py
cd football_pipeline
dbt run
dbt test
```

---

## Pipeline 2 — Live SofaScore Data

### Teams Tracked
Arsenal, Chelsea, Liverpool, Man City, Barcelona, Real Madrid, PSG

### Layers

**Bronze** — raw copy of `live_matches` table in BigQuery.

**Silver** — cleaned and enriched:
- Converted Unix timestamps to proper DATE and DATETIME
- Converted `winner_code` (1/2/0) to readable `home`/`away`/`draw`
- Standardized match status (`AP`, `AET`, `Ended` → `is_finished`)
- Added `goal_difference` column

**Gold** — analytics-ready metrics:
- `gold_team_form` — wins, losses, draws, goals, win percentage per team per tournament
- `gold_home_away_analysis` — home vs away win percentage comparison per team

### Running

```bash
# Start Kafka
cd kafka-football
docker compose up -d

# Ingest from API
cd live-football
python ingest.py

# Start consumer to load into BigQuery
python consumer.py

# Run dbt transformations
cd football_pipeline
dbt run --select live
dbt test --select live
```

### Dashboard

Connected to Looker Studio — showing team form, home vs away win percentages across top European clubs.

---

## Data Quality

dbt tests across both pipelines:
- `not_null` on all key columns
- `unique` on match IDs
- Source data duplicate ID issue discovered and handled via deduplication in Silver

---

## Key Learnings

- **Medallion architecture in SQL** — Bronze→Silver→Gold implemented purely in dbt
- **Kafka for streaming** — real API data flowing through a message broker before landing in BigQuery
- **dbt dependency management** — `{{ ref() }}` automatically determines run order
- **Materialized tables vs views** — critical performance decision at scale
- **Real data quality issues** — duplicate IDs, bad date formats, inconsistent status codes
- **Looker Studio** — free dashboarding tool that connects directly to BigQuery with no extra setup

---

## Part of

**#60DaysOfLearning2026** — Leapfrog Learning Path