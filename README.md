![Status](https://img.shields.io/badge/Status-In_Development-yellow)

# tibia-analytics
Data engineering project focused on measuring the health of Tibia communities through longitudinal analysis of player activity, retention, and world population dynamics.

---

# Deployment

## Prerequisites
Before deploying this project, ensure you have:

- A Databricks workspace with Unity Catalog enabled.
- A configured SQL Warehouse.
- The [Databricks CLI](https://docs.databricks.com/en/dev-tools/cli/index.html) (v0.205+) installed and authenticated.
- A Git folder (Databricks Repos) connected to this repository.

## Importing the jobs
This repository includes three Databricks job definitions under `jobs/`:

| File                                    | Description                                         |
|-----------------------------------------|-----------------------------------------------------|
| `tibia_analytics_schema_bootstrap.json` | Creates catalogs, schemas, and all tables           |
| `tibia_analytics_data_ingestion.json`   | Runs the full ingestion and transformation pipeline |
| `tibia_analytics.json`                  | Orchestrator — runs the two jobs above in sequence  |

Jobs must be created in sequence because the orchestrator references the job IDs generated during creation.

### Via Databricks CLI
Create the dependency jobs first and capture the returned `job_id` values:
```bash
databricks jobs create --json @jobs/tibia_analytics_schema_bootstrap.json
databricks jobs create --json @jobs/tibia_analytics_data_ingestion.json
```
Update the orchestrator configuration with the generated IDs, then create it:
```bash
databricks jobs create --json @jobs/tibia_analytics.json
```

### Via Databricks UI
Jobs can also be created manually in the Databricks workspace:
- Go to **Jobs & Pipelines**.
- Select **Create** → **Job**. 
- Configure tasks based on the JSON definitions in this repository.

## Required Configuration
Before running the orchestrator, replace the following placeholders in `jobs/tibia_analytics.json`:

| Placeholder                              | Where to find it                                                           |
|------------------------------------------|----------------------------------------------------------------------------|
| `<REPLACE_WITH_SCHEMA_BOOTSTRAP_JOB_ID>` | Job ID returned after creating the schema bootstrap job                    |
| `<REPLACE_WITH_DATA_INGESTION_JOB_ID>`   | Job ID returned after creating the data ingestion job                      |
| `<REPLACE_WITH_QUERY_ID>`                | SQL query ID (visible in the SQL Editor URL under `queries/...`) |
| `<REPLACE_WITH_WAREHOUSE_ID>`            | SQL Warehouse ID (found in the warehouse connection details)               |

## Data Pipeline Architecture
<pre>
<b>tibia_analytics</b>................orchestrator, runs daily
├── <b>tibia_analytics_schema_bootstrap</b>
│   ├── Catalog, Schema and Volume creation
│   ├── Utility tables.....calendar
│   ├── Bronze tables
│   ├── Silver tables
│   └── Gold tables
└── <b>tibia_analytics_data_ingestion</b>
    ├── API ingestion......worlds → highscores → characters
    ├── Bronze layer.......COPY INTO raw tables
    ├── Silver layer.......identity resolution, history, enrichment
    └── Gold layer.........behavior, cohort retention, world aggregates
</pre>

The pipeline follows a strict dependency flow across all layers.
World data is ingested first, since it defines the available servers used for highscore queries. Highscores ingestion depends on this metadata, enabling character discovery. Characters combine both previously known entities and newly discovered players, continuously expanding the dataset.  
After data is persisted in the Bronze layer, Silver and Gold transformations execute independently across all domains (worlds, highscores, and characters), using already available upstream data.

## Schedule

The orchestrator runs daily at **10:30 (Europe/Berlin)**, 30 minutes after the Tibia server save.  
This scheduling avoids execution during maintenance windows and ensures upstream API data is fully available before ingestion starts.

## Notes
The bootstrap job is idempotent and safe to re-run, as it relies on `CREATE IF NOT EXISTS`.  
This project currently uses [Databricks CLI](https://docs.databricks.com/aws/en/dev-tools/cli) for simplicity. For production environments, Databricks recommends [Asset Bundles](https://docs.databricks.com/aws/en/dev-tools/bundles) or [Terraform](https://docs.databricks.com/aws/en/dev-tools/terraform) for CI/CD.