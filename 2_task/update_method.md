## Methods for Updating the Data Mart

### Using Internal Tools of the Selected DBMS

1. **Triggers:**
   Triggers on the `deposits` and `withdrawals` tables that update the daily summary data mart after each insert operation.

2. **Materialized Views + pg_cron:**
   Using the `REFRESH MATERIALIZED VIEW` command with `pg_cron` extension, we can automatically refresh the materialized view to ensure it contains the latest data from the base tables.

### Using External Tools

3. **dbt (preferable approach):**
   dbt allows create models, their dependencies, document, and test data transformations using SQL and YAML files. 

4. **Apache Airflow:**
   Apache Airflow can be used to orchestrate and automate the data update process by creating Directed Acyclic Graphs (DAGs) of tasks.

Strongly depends on the task description and preferences related to the data mart.
For instance, tools like Debezium + Kafka can be used to track source data changes in real-time. Debezium captures row-level changes in your databases and streams these changes to Kafka topics.