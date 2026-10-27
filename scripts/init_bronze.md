# Inisialisasi Bronze Layer - PostgreSQL

Dokumen ini berisi langkah awal untuk membuat database `sales_datawarehouse`,
schema Medallion, dan enam tabel pada Bronze Layer.

## Arsitekturhttps://github.com/risproject-in/sql-data-warehouse/tree/main/scripts

```text
Bronze → Silver → Gold
```

- **Bronze** menyimpan data mentah dari sistem sumber.
- **Silver** menyimpan data yang sudah dibersihkan dan divalidasi.
- **Gold** menyimpan data siap analisis dengan Star Schema.

> Script penghapusan database bersifat destruktif. Jalankan hanya jika database
> memang boleh dibuat ulang dan seluruh data lama sudah tidak diperlukan.

## 1. Membuat Database

Jalankan bagian ini saat terhubung ke database `postgres`, bukan ke
`sales_datawarehouse`.

```sql
DROP DATABASE IF EXISTS sales_datawarehouse WITH (FORCE);
CREATE DATABASE sales_datawarehouse;
```

`WITH (FORCE)` akan memutus koneksi aktif dan menghapus database beserta seluruh
isinya. Jika tidak ingin menghapus database lama, gunakan hanya:

```sql
CREATE DATABASE sales_datawarehouse;
```

## 2. Membuat Schema Medallion

Setelah database dibuat, buka Query Tool baru yang terhubung ke
`sales_datawarehouse`, lalu jalankan:

```sql
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
```

## 3. DDL Bronze Layer PostgreSQL

DDL berikut membuat enam tabel Bronze. Tabel Bronze tidak menggunakan primary key
atau foreign key terlebih dahulu agar data sumber dapat disimpan apa adanya.
Validasi key dilakukan pada Silver Layer.

```sql
DROP TABLE IF EXISTS bronze.crm_cust_info;
DROP TABLE IF EXISTS bronze.crm_prd_info;
DROP TABLE IF EXISTS bronze.crm_sales_details;
DROP TABLE IF EXISTS bronze.erp_loc_a101;
DROP TABLE IF EXISTS bronze.erp_cust_az12;
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INTEGER,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);

CREATE TABLE bronze.crm_prd_info (
    prd_id        INTEGER,
    prd_key       VARCHAR(50),
    prd_nm        VARCHAR(50),
    prd_cost      INTEGER,
    prd_line      VARCHAR(50),
    prd_start_dt  TIMESTAMP,
    prd_end_dt    TIMESTAMP
);

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num   VARCHAR(50),
    sls_prd_key   VARCHAR(50),
    sls_cust_id   INTEGER,
    sls_order_dt  INTEGER,
    sls_ship_dt   INTEGER,
    sls_due_dt    INTEGER,
    sls_sales     INTEGER,
    sls_quantity  INTEGER,
    sls_price     INTEGER
);

CREATE TABLE bronze.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
);

CREATE TABLE bronze.erp_cust_az12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
);
```

### Penyesuaian dari SQL Server

| SQL Server | PostgreSQL |
|---|---|
| `NVARCHAR` | `VARCHAR` |
| `DATETIME` | `TIMESTAMP` |
| `IF OBJECT_ID` | `DROP TABLE IF EXISTS` |
| `GO` | Tidak digunakan |

## 4. Verifikasi Schema dan Tabel

### Verifikasi schema

```sql
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('bronze', 'silver', 'gold')
ORDER BY schema_name;
```

### Verifikasi tabel Bronze

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'bronze'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

Hasil yang diharapkan:

```text
crm_cust_info
crm_prd_info
crm_sales_details
erp_cust_az12
erp_loc_a101
erp_px_cat_g1v2
```

## 5. Verifikasi Jumlah Data

Jalankan query berikut setelah proses bulk import selesai:

```sql
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS total_rows
FROM bronze.crm_cust_info

UNION ALL

SELECT 'crm_prd_info', COUNT(*)
FROM bronze.crm_prd_info

UNION ALL

SELECT 'crm_sales_details', COUNT(*)
FROM bronze.crm_sales_details

UNION ALL

SELECT 'erp_cust_az12', COUNT(*)
FROM bronze.erp_cust_az12

UNION ALL

SELECT 'erp_loc_a101', COUNT(*)
FROM bronze.erp_loc_a101

UNION ALL

SELECT 'erp_px_cat_g1v2', COUNT(*)
FROM bronze.erp_px_cat_g1v2;
```
Jika tabel belum diisi, nilai `total_rows` akan bernilai `0`. Hal tersebut normal
setelah DDL dan sebelum bulk import dijalankan.
