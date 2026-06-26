# Databricks Jobs

This directory contains the Databricks Job definitions used to deploy and orchestrate the Tibia Analytics platform.

## Available Jobs

| Job                                 | Purpose                                                                                                |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `tibia_analytics`                   | Main orchestrator responsible for coordinating the execution of the platform workflows.                |
| `tibia_analytics_schema_bootstrap`  | Creates the catalogs, schemas, utility objects, and tables required by the platform.                   |
| `tibia_analytics_data_ingestion`    | Executes the ingestion, transformation, and analytics pipeline across Bronze, Silver, and Gold layers. |
| `tibia_analytics_refresh_dashboard` | Refreshes the Lakeview dashboard after successful pipeline execution to publish the latest analytics.  |

## Notes

The job definitions stored in this repository have been sanitized for source control:

* Workspace notebook paths were replaced with Git repository-relative paths.
* Environment-specific identifiers (Job IDs, Query IDs, Warehouse IDs) were replaced with placeholders.
* Personal information and email notification settings were removed.

For deployment instructions and environment setup, refer to the main project README.
