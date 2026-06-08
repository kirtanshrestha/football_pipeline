# Football Analytics Pipeline

An end-to-end data engineering pipeline that ingests European football match data, transforms it through a medallion architecture using dbt, and stores analytics-ready datasets in Google BigQuery.

Built as part of **#60DaysOfLearning2026** — Leapfrog Learning Path.

---

## Architecture

```
Kaggle Dataset (SQLite)
        │
        ▼
Python ingestion script
        │
        ▼
┌─────────────────┐
│     BigQuery    │
│                 │
│  raw            │  ← raw tables loaded directly from SQLite
│  ├── match      │
│  ├── team       │
│  ├── player     │
│  ├── league     │
│  └── country    │
│                 │
│  dev            │  ← dbt transformed layers
│  ├── bronze_*   │  Raw copy, untouched
│  ├── silver_*   │  Cleaned, joined, typed
│  └── gold_*     │  Analytics-ready metrics
└─────────────────┘
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Source | Kaggle — European Soccer Database |
| Ingestion | Python + pandas |
| Cloud Warehouse | Google BigQuery |
| Transformation | dbt (data build tool) |
| Language | Python 3, SQL |
| Libraries | pandas, google-cloud-bigquery, dbt-bigquery |

---

## Project Structure

```
football_pipeline/
├── models/
│   ├── bronze/
│   │   ├── bronze_matches.sql       # Raw match data
│   │   ├── bronze_teams.sql         # Raw team data
│   │   ├── bronze_players.sql       # Raw player data
│   │   └── sources.yml              # Raw source declarations
│   │
│   ├── silver/
│   │   ├── silver_matches.sql       # Cleaned + joined matches
│   │   └── schema.yml               # Data quality tests
│   │
│   └── gold/
│       ├── gold_team_performance.sql       # Wins/losses/draws per team per season
│       ├── gold_home_away_performance.sql  # Home performance metrics
│       ├── gold_top_scoring_teams.sql      # Goals scored per team per season
│       └── schema.yml                      # Tests + documentation
│
├── load_to_bigquery.py    # Loads raw SQLite data into BigQuery
├── dbt_project.yml        # dbt project configuration
└── README.md
```

---

## Layers Explained

**Bronze** — exact copy of raw source tables. No transformations. Exists so original data is always preserved and recoverable.

**Silver** — cleaned and enriched:
- Casted date strings to proper DATE type
- Removed null matches
- Joined team names onto match records so `home_team_api_id: 9825` becomes `home_team: Arsenal`
- Deduplicated records from source data quality issues

**Gold** — analytics-ready metrics:
- `gold_team_performance` — wins, losses, draws, goals scored/conceded per team per season
- `gold_home_away_performance` — home win rate, avg goals at home per team per season
- `gold_top_scoring_teams` — total goals scored per team per season across all competitions

---

## Data Quality

dbt tests run on every model:
- `not_null` checks on key columns across Silver and Gold
- `unique` check on match IDs — discovered source data has duplicate IDs, documented and handled via deduplication in Silver
- All tests run via `dbt test`

---

## Running the Pipeline

**1. Install dependencies**
```bash
pip install dbt-bigquery google-cloud-bigquery pandas
```

**2. Set up GCP credentials**

Create a service account in Google Cloud with BigQuery Admin role, download the JSON key, save as `gcp_key.json`.

**3. Load raw data to BigQuery**
```bash
python load_to_bigquery.py
```

**4. Run dbt transformations**
```bash
cd football_pipeline
dbt run
```

**5. Run data quality tests**
```bash
dbt test
```

**6. View documentation**
```bash
dbt docs generate
dbt docs serve
```

---

## Key Learnings

- **Medallion architecture in SQL** — same Bronze→Silver→Gold concept as Python pipelines but implemented purely in dbt models
- **dbt dependency management** — `{{ ref() }}` automatically determines run order, no manual orchestration needed
- **Materialized tables vs views** — views re-run queries every time, tables store results. Critical for performance at scale
- **Real data quality issues** — source dataset had duplicate match IDs, required investigation and engineering decision on how to handle
- **dbt docs** — documentation and lineage diagrams generated automatically from model definitions, no extra work

---

## Dataset

European Soccer Database by Hugo Mathien — 11 European leagues, 25,000+ matches, 10,000+ players across multiple seasons.

Available on Kaggle: https://www.kaggle.com/datasets/hugomathien/soccer