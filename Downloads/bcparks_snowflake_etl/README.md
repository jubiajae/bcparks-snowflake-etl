# BC Parks Facilities Snowflake ETL

This project demonstrates a complete ETL pipeline in Snowflake using public BC Parks API data.

## 🧩 Components

- **Postman**: Tested the public API endpoint.
- **VS Code + Python**: Fetched and saved the JSON file locally.
- **SnowSQL**: Uploaded JSON file into Snowflake.
- **Snowflake**:
  - Created raw staging and cleaned tables
  - Flattened and transformed nested JSON
  - Scheduled monthly refresh using Tasks + Stored Procedures

## ✅ Pipeline Overview

1. Fetch data from: `https://bcparks.api.gov.bc.ca/api/park-facilities?pagination[limit]=-1`
2. Save JSON to local file `facilities.json`
3. Upload to Snowflake using:
    ```sql
    PUT file://path/to/facilities.json @~/bcparks auto_compress=false;
    COPY INTO PUBLIC.BC_PARKS_RAW FROM @~/bcparks FILE_FORMAT = (TYPE = 'JSON');
    ```
4. Use `LOAD_BC_PARKS_FINAL()` stored procedure to transform data:
    - Split `facility_name` into code + label
    - Strip HTML tags and `&nbsp;` from description

## 📅 Task Schedule

Runs monthly at **6 AM PST on the 1st**:
```sql
SCHEDULE = 'USING CRON 0 6 1 * * America/Los_Angeles'
```

## 📂 Files Included

- `etl.sql` – Create table, procedure, task
- `fetch_bcparks.py` – Optional script to automate fetch
- `sample_output.csv` – Example of cleaned output

---

## 🔗 Useful Commands

```sql
-- Run the ETL manually
CALL LOAD_BC_PARKS_FINAL();

-- View results
SELECT * FROM RAW.BC_PARKS_FINAL LIMIT 10;

-- Check task
SHOW TASKS;
```
