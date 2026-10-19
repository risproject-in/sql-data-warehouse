/*
=============================================================
CREATE DATABASE AND MEDALLION SCHEMAS - POSTGRESQL
=============================================================

Database:
    sales_datawarehouse

Schemas:
    bronze
    silver
    gold

WARNING:
    Script ini menghapus database sales_datawarehouse jika sudah ada.
    Seluruh data di dalam database akan hilang permanen.
=============================================================
*/

DROP DATABASE IF EXISTS datawarehouse WITH (FORCE);
CREATE DATABASE sales_datawarehouse;


/*
=============================================================
DATABASE: datawarehouse
ARCHITECTURE: MEDALLION
=============================================================

Bronze:
    Menyimpan data mentah dari sumber.

Silver:
    Menyimpan data yang sudah dibersihkan dan divalidasi.

Gold:
    Menyimpan data siap analisis dengan Star Schema.
=============================================================
*/

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;


/*
=============================================================
Verivikasi Skema
=============================================================
*/
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('bronze', 'silver', 'gold')
ORDER BY schema_name;
