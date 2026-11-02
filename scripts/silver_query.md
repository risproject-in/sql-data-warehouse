# Silver Layer - Query dan Dokumentasi PostgreSQL

Dokumen ini menjelaskan struktur, aturan pembersihan, transformasi, dan validasi
untuk memindahkan data dari Bronze Layer ke Silver Layer.

## Tujuan Silver Layer

Silver Layer menghasilkan data yang lebih konsisten dan siap dipakai untuk proses
analitik. Pada tahap ini data Bronze dibersihkan, distandarkan, dikonversi ke tipe
data yang sesuai, dan diperiksa kualitasnya.

```text
Bronze (data mentah)
        ↓
Cleaning, standardisasi, dan validasi
        ↓
Silver (data bersih)
        ↓
Gold (Star Schema)
```

## Prasyarat

Sebelum menjalankan proses Silver, pastikan:

1. Enam tabel Bronze sudah dibuat dan terisi data.
2. Jumlah data, nilai kosong, dan data duplikat pada Bronze sudah diperiksa.
3. Schema `silver` sudah dibuat melalui `initbronze.md`.
4. Aturan bisnis untuk customer key dan product key sudah ditinjau.

## Pemetaan Bronze ke Silver

| Sumber Bronze | Target Silver | Proses utama |
|---|---|---|
| `bronze.crm_cust_info` | `silver.crm_cust_info` | Trim teks, standardisasi gender, nilai kosong menjadi `NULL` |
| `bronze.crm_prd_info` | `silver.crm_prd_info` | Trim teks, validasi biaya, derivasi `cat_id` sementara |
| `bronze.crm_sales_details` | `silver.crm_sales_details` | Trim key dan konversi tanggal `YYYYMMDD` menjadi `DATE` |
| `bronze.erp_loc_a101` | `silver.erp_loc_a101` | Trim customer ID dan standardisasi nama negara |
| `bronze.erp_cust_az12` | `silver.erp_cust_az12` | Trim customer ID dan standardisasi gender |
| `bronze.erp_px_cat_g1v2` | `silver.erp_px_cat_g1v2` | Trim kategori, subkategori, dan maintenance |

## DDL Silver Layer

> Bagian ini menjalankan full reload pada struktur Silver karena tabel lama akan
> dihapus. Jalankan hanya jika struktur sebelumnya memang boleh diganti.

```sql
CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.crm_cust_info;
DROP TABLE IF EXISTS silver.crm_prd_info;
DROP TABLE IF EXISTS silver.crm_sales_details;
DROP TABLE IF EXISTS silver.erp_loc_a101;
DROP TABLE IF EXISTS silver.erp_cust_az12;
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.crm_cust_info (
    cst_id              INTEGER,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver.crm_prd_info (
    prd_id          INTEGER,
    cat_id          VARCHAR(50),
    prd_key         VARCHAR(50),
    prd_nm          VARCHAR(50),
    prd_cost        INTEGER,
    prd_line        VARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     VARCHAR(50),
    sls_prd_key     VARCHAR(50),
    sls_cust_id     INTEGER,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INTEGER,
    sls_quantity    INTEGER,
    sls_price       INTEGER,
    dwh_create_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver.erp_loc_a101 (
    cid             VARCHAR(50),
    cntry           VARCHAR(50),
    dwh_create_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver.erp_cust_az12 (
    cid             VARCHAR(50),
    bdate           DATE,
    gen             VARCHAR(50),
    dwh_create_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              VARCHAR(50),
    cat             VARCHAR(50),
    subcat          VARCHAR(50),
    maintenance     VARCHAR(50),
    dwh_create_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

## Aturan Transformasi

| Data | Aturan Silver |
|---|---|
| Kolom teks | Hapus spasi di awal dan akhir dengan `TRIM()` |
| Nilai teks kosong | Ubah menjadi `NULL` dengan `NULLIF(TRIM(kolom), '')` |
| Gender | Standarkan `M`, `MALE`, dan `L` menjadi `Male`; `F`, `FEMALE`, dan `P` menjadi `Female` |
| Tanggal transaksi | Konversi angka `YYYYMMDD` menjadi tipe `DATE` |
| Biaya produk negatif | Ubah menjadi `NULL` untuk ditinjau kembali |
| Negara customer | Standarkan beberapa singkatan negara ke nama lengkap |

`cat_id` diambil sementara dari bagian pertama `prd_key` yang dipisahkan tanda
hubung. Aturan ini perlu disesuaikan apabila format `prd_key` pada sumber data
memiliki pola yang berbeda.

## Procedure `silver.load_silver`

Procedure ini melakukan full reload tabel Silver, mencatat proses melalui `RAISE
NOTICE`, dan menambahkan ringkasan proses ke `bronze.etl_log` apabila tabel log
tersebut sudah dibuat.

```sql
CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    v_batch_id    UUID := gen_random_uuid();
    v_start_time  TIMESTAMPTZ := clock_timestamp();
    v_end_time    TIMESTAMPTZ;
    v_row_count   BIGINT;
    v_total_rows  BIGINT := 0;
    v_error_state TEXT;
    v_error_msg   TEXT;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Memulai proses load Silver Layer';
    RAISE NOTICE 'Batch ID: %', v_batch_id;
    RAISE NOTICE '========================================';

    TRUNCATE TABLE
        silver.crm_cust_info,
        silver.crm_prd_info,
        silver.crm_sales_details,
        silver.erp_loc_a101,
        silver.erp_cust_az12,
        silver.erp_px_cat_g1v2;

    RAISE NOTICE 'Memuat silver.crm_cust_info...';

    INSERT INTO silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname,
        cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id,
        NULLIF(TRIM(cst_key), ''),
        NULLIF(TRIM(cst_firstname), ''),
        NULLIF(TRIM(cst_lastname), ''),
        NULLIF(TRIM(cst_marital_status), ''),
        CASE
            WHEN UPPER(TRIM(cst_gndr)) IN ('M', 'MALE', 'L') THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) IN ('F', 'FEMALE', 'P') THEN 'Female'
            ELSE NULLIF(TRIM(cst_gndr), '')
        END,
        cst_create_date
    FROM bronze.crm_cust_info;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    RAISE NOTICE 'crm_cust_info selesai: % baris', v_row_count;

    RAISE NOTICE 'Memuat silver.crm_prd_info...';

    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost,
        prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        prd_id,
        NULLIF(SPLIT_PART(TRIM(prd_key), '-', 1), ''),
        NULLIF(TRIM(prd_key), ''),
        NULLIF(TRIM(prd_nm), ''),
        CASE WHEN prd_cost < 0 THEN NULL ELSE prd_cost END,
        NULLIF(TRIM(prd_line), ''),
        prd_start_dt::DATE,
        prd_end_dt::DATE
    FROM bronze.crm_prd_info;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    RAISE NOTICE 'crm_prd_info selesai: % baris', v_row_count;

    RAISE NOTICE 'Memuat silver.crm_sales_details...';

    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt,
        sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT
        NULLIF(TRIM(sls_ord_num), ''),
        NULLIF(TRIM(sls_prd_key), ''),
        sls_cust_id,
        CASE WHEN sls_order_dt BETWEEN 19000101 AND 21001231
            THEN TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD') END,
        CASE WHEN sls_ship_dt BETWEEN 19000101 AND 21001231
            THEN TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD') END,
        CASE WHEN sls_due_dt BETWEEN 19000101 AND 21001231
            THEN TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD') END,
        sls_sales,
        sls_quantity,
        sls_price
    FROM bronze.crm_sales_details;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    RAISE NOTICE 'crm_sales_details selesai: % baris', v_row_count;

    RAISE NOTICE 'Memuat silver.erp_loc_a101...';

    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        NULLIF(TRIM(cid), ''),
        CASE
            WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
            WHEN UPPER(TRIM(cntry)) IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
            WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
            ELSE NULLIF(TRIM(cntry), '')
        END
    FROM bronze.erp_loc_a101;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    RAISE NOTICE 'erp_loc_a101 selesai: % baris', v_row_count;

    RAISE NOTICE 'Memuat silver.erp_cust_az12...';

    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        NULLIF(TRIM(cid), ''),
        bdate,
        CASE
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE', 'L') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE', 'P') THEN 'Female'
            ELSE NULLIF(TRIM(gen), '')
        END
    FROM bronze.erp_cust_az12;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    RAISE NOTICE 'erp_cust_az12 selesai: % baris', v_row_count;

    RAISE NOTICE 'Memuat silver.erp_px_cat_g1v2...';

    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT
        NULLIF(TRIM(id), ''),
        NULLIF(TRIM(cat), ''),
        NULLIF(TRIM(subcat), ''),
        NULLIF(TRIM(maintenance), '')
    FROM bronze.erp_px_cat_g1v2;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    RAISE NOTICE 'erp_px_cat_g1v2 selesai: % baris', v_row_count;

    v_end_time := clock_timestamp();

    INSERT INTO bronze.etl_log (
        batch_id, layer_name, stage_name, table_name, status,
        start_time, end_time, duration_seconds, rows_loaded,
        rows_failed, executed_by
    )
    VALUES (
        v_batch_id, 'SILVER', 'WHOLE_BATCH', NULL, 'SUCCESS',
        v_start_time, v_end_time,
        EXTRACT(EPOCH FROM (v_end_time - v_start_time)),
        v_total_rows, 0, SESSION_USER
    );

    RAISE NOTICE 'Load Silver Layer selesai';
    RAISE NOTICE 'Total baris diproses: %', v_total_rows;
    RAISE NOTICE 'Durasi: % detik',
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC, 3);

EXCEPTION
    WHEN OTHERS THEN
        v_end_time := clock_timestamp();

        GET STACKED DIAGNOSTICS
            v_error_state = RETURNED_SQLSTATE,
            v_error_msg = MESSAGE_TEXT;

        INSERT INTO bronze.etl_log (
            batch_id, layer_name, stage_name, table_name, status,
            start_time, end_time, duration_seconds, rows_loaded,
            rows_failed, executed_by, error_state, error_message
        )
        VALUES (
            v_batch_id, 'SILVER', 'WHOLE_BATCH', NULL, 'FAILED',
            v_start_time, v_end_time,
            EXTRACT(EPOCH FROM (v_end_time - v_start_time)),
            v_total_rows, 1, SESSION_USER, v_error_state, v_error_msg
        );

        RAISE WARNING 'Load Silver Layer gagal: %', v_error_msg;
        RAISE;
END;
$$;
```

## Menjalankan Procedure

```sql
CALL silver.load_silver();
```

## Validasi Silver Layer

### Jumlah baris tiap tabel

```sql
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS total_rows
FROM silver.crm_cust_info
UNION ALL
SELECT 'crm_prd_info', COUNT(*) FROM silver.crm_prd_info
UNION ALL
SELECT 'crm_sales_details', COUNT(*) FROM silver.crm_sales_details
UNION ALL
SELECT 'erp_cust_az12', COUNT(*) FROM silver.erp_cust_az12
UNION ALL
SELECT 'erp_loc_a101', COUNT(*) FROM silver.erp_loc_a101
UNION ALL
SELECT 'erp_px_cat_g1v2', COUNT(*) FROM silver.erp_px_cat_g1v2;
```

### Data customer yang belum memiliki key

```sql
SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL
   OR cst_key IS NULL;
```

### Transaksi dengan customer yang tidak ditemukan

```sql
SELECT s.*
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c
    ON c.cst_id = s.sls_cust_id
WHERE c.cst_id IS NULL;
```

### Transaksi dengan produk yang tidak ditemukan

```sql
SELECT s.*
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p
    ON p.prd_key = s.sls_prd_key
WHERE p.prd_key IS NULL;
```

### Tanggal transaksi yang tidak valid

```sql
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL;
```

## Alur ke Gold Layer

Setelah data Silver tervalidasi, data digunakan untuk membangun Star Schema:

```text
silver.crm_cust_info + silver.erp_cust_az12 + silver.erp_loc_a101
        ↓
gold.dim_customer

silver.crm_prd_info + silver.erp_px_cat_g1v2
        ↓
gold.dim_product

silver.crm_sales_details
        ↓
gold.fact_sales
```

