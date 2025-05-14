-- Create the table  
CREATE OR REPLACE TABLE RAW.BC_PARKS_FINAL (
  facility_id NUMBER,
  facility_name STRING,
  facility_name_clean STRING,
  is_open BOOLEAN,
  is_active BOOLEAN,
  created_at TIMESTAMP_NTZ,
  description STRING,
  facility_code STRING
);

-- create procedure to insert the data and cleaned it up
CREATE OR REPLACE PROCEDURE LOAD_BC_PARKS_FINAL()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
  TRUNCATE TABLE RAW.BC_PARKS_FINAL;

  INSERT INTO RAW.BC_PARKS_FINAL (
    facility_id,
    facility_name,
    facility_name_clean,
    is_open,
    is_active,
    created_at,
    description,
    facility_code
  )
  SELECT
    value:id::NUMBER AS facility_id,
    value:attributes:name::STRING AS facility_name,
    CASE 
      WHEN POSITION(':' IN value:attributes:name::STRING) > 0
        THEN SPLIT_PART(value:attributes:name::STRING, ':', 1)
      ELSE value:attributes:name::STRING
    END AS facility_name_clean,
    value:attributes:isFacilityOpen::BOOLEAN AS is_open,
    value:attributes:isActive::BOOLEAN AS is_active,
    value:attributes:createdAt::TIMESTAMP_NTZ AS created_at,
    REPLACE(REPLACE(REPLACE(value:attributes:description::STRING, '<p>', ''), '</p>', ''), '&nbsp;', '') AS description,
    SPLIT_PART(value:attributes:name::STRING, ':', 0)::STRING AS facility_code
  FROM PUBLIC.BC_PARKS_RAW,
  LATERAL FLATTEN(input => data:data);

  RETURN 'BC Parks Table Updated';
END;
$$;

-- Task to schedule it monthly at 6 AM PST
CREATE OR REPLACE TASK refresh_bc_parks_raw
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 6 1 * * America/Los_Angeles'
AS
  CALL LOAD_BC_PARKS_FINAL();

ALTER TASK refresh_bc_parks_raw RESUME;
