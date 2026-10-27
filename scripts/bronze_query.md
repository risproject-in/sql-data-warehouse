# Bronze Layer - Query dan Dokumentasi PostgreSQL

Dokumen ini berisi penjelasan enam tabel Bronze, sumber file CSV, query bulk
import, dan pemeriksaan data setelah proses pemuatan.

## Sumber Data

```text
CRM
├── crm_cust_info       ← cust_info.csv
├── crm_prd_info        ← prd.info.csv
└── crm_sales_details   ← sales_details.csv

ERP
├── erp_cust_az12       ← CUST_AZ12.csv
├── erp_loc_a101        ← LOC_A101.csv
└── erp_px_cat_g1v2     ← PX_CAT_G1V2.csv
```

## Header File CSV

### CRM

| File | Header |
|---|---|
| `cust_info.csv` | `cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date` |
| `prd.info.csv` | `prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt` |
| `sales_details.csv` | `sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price` |

### ERP

| File | Header |
|---|---|
| `CUST_AZ12.csv` | `CID,BDATE,GEN` |
| `LOC_A101.csv` | `CID,CNTRY` |
| `PX_CAT_G1V2.csv` | `ID,CAT,SUBCAT,MAINTENANCE` |

`HEADER TRUE` hanya melewati baris header. Pemetaan data dilakukan berdasarkan
urutan kolom yang ditulis pada perintah `\copy`.

## Fungsi Enam Tabel

### `bronze.crm_cust_info`

Menyimpan data dasar customer dari CRM, seperti identitas, nama, status pernikahan,
jenis kelamin, dan tanggal pembuatan data. Tabel ini menjadi sumber untuk
`gold.dim_customer` setelah proses pembersihan dan penggabungan dengan data ERP.

### `bronze.crm_prd_info`

Menyimpan master produk dari CRM, meliputi kode, nama, biaya, lini produk, dan
periode berlaku produk. Tabel ini menjadi salah satu sumber `gold.dim_product`.

### `bronze.crm_sales_details`

Menyimpan detail transaksi penjualan dari CRM. Satu baris merepresentasikan detail
pesanan, termasuk customer, produk, tanggal transaksi, jumlah, harga, dan nilai
penjualan. Tabel ini menjadi sumber `gold.fact_sales`.

### `bronze.erp_cust_az12`

Menyimpan data demografis customer dari ERP, terutama tanggal lahir dan gender.
Data ini melengkapi `crm_cust_info`.

### `bronze.erp_loc_a101`

Menyimpan lokasi atau negara customer dari ERP. Data ini digunakan untuk melengkapi
atribut customer pada `dim_customer`.

### `bronze.erp_px_cat_g1v2`

Menyimpan kategori, subkategori, dan informasi pemeliharaan produk dari ERP. Data
ini melengkapi `crm_prd_info` sebelum dibentuk menjadi `dim_product`.

## Relasi Logis

```text
crm_cust_info
      ├── erp_cust_az12
      └── erp_loc_a101
              ↓
        gold.dim_customer
```

```text
crm_prd_info
      └── erp_px_cat_g1v2
              ↓
        gold.dim_product
```

```text
crm_sales_details
      ├── dim_customer
      ├── dim_product
      └── dim_date
              ↓
        gold.fact_sales
```

## Bulk Import Data CSV

Jalankan perintah berikut dari terminal `psql` yang sudah terhubung ke database
`sales_datawarehouse`:

```bash
psql -U postgres -d sales_datawarehouse
```

Path berikut menggunakan asumsi:

```text
CRM: D:/Acceleration/datasets/source_crm/
ERP: D:/Acceleration/datasets/source_erp/
```

Jika lokasi folder berbeda, ubah path pada perintah terkait.

### Import CRM

```sql
\copy bronze.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) FROM 'D:/Acceleration/datasets/source_crm/cust_info.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

```sql
\copy bronze.crm_prd_info (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt) FROM 'D:/Acceleration/datasets/source_crm/prd.info.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

```sql
\copy bronze.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price) FROM 'D:/Acceleration/datasets/source_crm/sales_details.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

### Import ERP

```sql
\copy bronze.erp_cust_az12 (cid, bdate, gen) FROM 'D:/Acceleration/datasets/source_erp/CUST_AZ12.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

```sql
\copy bronze.erp_loc_a101 (cid, cntry) FROM 'D:/Acceleration/datasets/source_erp/LOC_A101.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

```sql
\copy bronze.erp_px_cat_g1v2 (id, cat, subcat, maintenance) FROM 'D:/Acceleration/datasets/source_erp/PX_CAT_G1V2.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

## Verifikasi Isi Tabel

### Verifikasi jumlah baris

```sql
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS total_rows
FROM bronze.crm_cust_info
UNION ALL
SELECT 'crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL
SELECT 'crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL
SELECT 'erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL
SELECT 'erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL
SELECT 'erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2;
```

### Verifikasi sampel data

```sql
SELECT * FROM bronze.crm_cust_info LIMIT 5;
SELECT * FROM bronze.crm_prd_info LIMIT 5;
SELECT * FROM bronze.crm_sales_details LIMIT 5;
SELECT * FROM bronze.erp_cust_az12 LIMIT 5;
SELECT * FROM bronze.erp_loc_a101 LIMIT 5;
SELECT * FROM bronze.erp_px_cat_g1v2 LIMIT 5;
```

### Verifikasi data kosong

```sql
SELECT *
FROM bronze.crm_cust_info
WHERE cst_id IS NULL
   OR cst_key IS NULL;
```

```sql
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL
   OR sls_prd_key IS NULL
   OR sls_cust_id IS NULL;
```

## Stored Procedure dan Durasi Load

PostgreSQL menggunakan `CALL nama_procedure()` untuk menjalankan procedure. Nama
procedure mengikuti pola:

```text
load_<layer>
```

Contoh:

```text
bronze.load_bronze()
silver.load_silver()
gold.load_gold()
```

Perintah `\copy` membaca file dari komputer client sehingga dijalankan melalui
terminal `psql`. Perintah tersebut tidak ditempatkan langsung di dalam procedure
PL/pgSQL. Procedure dapat digunakan untuk menjalankan transformasi internal,
validasi, logging, dan pengukuran durasi setelah data tersedia di tabel Bronze.

Contoh procedure untuk mencatat durasi proses validasi Bronze:

```sql
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time   TIMESTAMP;
    v_duration   INTERVAL;
BEGIN
    v_start_time := clock_timestamp();

    RAISE NOTICE 'Memulai proses Bronze Layer pada %', v_start_time;

    PERFORM COUNT(*) FROM bronze.crm_cust_info;
    PERFORM COUNT(*) FROM bronze.crm_prd_info;
    PERFORM COUNT(*) FROM bronze.crm_sales_details;
    PERFORM COUNT(*) FROM bronze.erp_cust_az12;
    PERFORM COUNT(*) FROM bronze.erp_loc_a101;
    PERFORM COUNT(*) FROM bronze.erp_px_cat_g1v2;

    v_end_time := clock_timestamp();
    v_duration := v_end_time - v_start_time;

    RAISE NOTICE 'Bronze Layer selesai pada %', v_end_time;
    RAISE NOTICE 'Durasi proses: %', v_duration;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Load Bronze gagal: %', SQLERRM;
        RAISE;
END;
$$;
```

Jalankan procedure dengan:

```sql
CALL bronze.load_bronze();
```

PostgreSQL tidak memiliki fungsi `DATEDIFF()` seperti SQL Server. Durasi dapat
dihitung menggunakan pengurangan timestamp:

```sql
SELECT clock_timestamp() - statement_timestamp() AS duration;
```

Atau dalam satuan detik:

```sql
SELECT EXTRACT(
    EPOCH FROM (clock_timestamp() - statement_timestamp())
) AS duration_seconds;

## Data Dictionary Bronze Layer

### `bronze.crm_cust_info`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `cst_id` | `INTEGER` | ID customer dari CRM |
| `cst_key` | `VARCHAR(50)` | Kode bisnis customer |
| `cst_firstname` | `VARCHAR(50)` | Nama depan customer |
| `cst_lastname` | `VARCHAR(50)` | Nama belakang customer |
| `cst_marital_status` | `VARCHAR(50)` | Status pernikahan customer |
| `cst_gndr` | `VARCHAR(50)` | Jenis kelamin customer |
| `cst_create_date` | `DATE` | Tanggal pembuatan data customer |

### `bronze.crm_prd_info`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `prd_id` | `INTEGER` | ID produk |
| `prd_key` | `VARCHAR(50)` | Kode produk |
| `prd_nm` | `VARCHAR(50)` | Nama produk |
| `prd_cost` | `INTEGER` | Biaya produk |
| `prd_line` | `VARCHAR(50)` | Lini atau kelompok produk |
| `prd_start_dt` | `TIMESTAMP` | Awal masa berlaku produk |
| `prd_end_dt` | `TIMESTAMP` | Akhir masa berlaku produk |

### `bronze.crm_sales_details`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `sls_ord_num` | `VARCHAR(50)` | Nomor pesanan |
| `sls_prd_key` | `VARCHAR(50)` | Kode produk |
| `sls_cust_id` | `INTEGER` | ID customer |
| `sls_order_dt` | `INTEGER` | Tanggal pemesanan dari sumber |
| `sls_ship_dt` | `INTEGER` | Tanggal pengiriman dari sumber |
| `sls_due_dt` | `INTEGER` | Tanggal jatuh tempo dari sumber |
| `sls_sales` | `INTEGER` | Nilai total penjualan |
| `sls_quantity` | `INTEGER` | Jumlah produk |
| `sls_price` | `INTEGER` | Harga produk |

### `bronze.erp_cust_az12`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `cid` | `VARCHAR(50)` | Kode customer dari ERP |
| `bdate` | `DATE` | Tanggal lahir customer |
| `gen` | `VARCHAR(50)` | Gender customer |

### `bronze.erp_loc_a101`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `cid` | `VARCHAR(50)` | ID atau kode customer dari ERP |
| `cntry` | `VARCHAR(50)` | Negara atau lokasi customer |

### `bronze.erp_px_cat_g1v2`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `id` | `VARCHAR(50)` | ID atau kode produk dari ERP |
| `cat` | `VARCHAR(50)` | Kategori produk |
| `subcat` | `VARCHAR(50)` | Subkategori produk |
| `maintenance` | `VARCHAR(50)` | Informasi pemeliharaan produk |

## Alur Medallion dan Star Schema

```text
BRONZE
├── crm_cust_info
├── crm_sales_details
├── crm_prd_info
├── erp_loc_a101
├── erp_cust_az12
└── erp_px_cat_g1v2
        ↓
SILVER
├── customer_clean
├── product_clean
└── sales_clean
        ↓
GOLD — STAR SCHEMA
├── dim_customer
├── dim_product
├── dim_date
└── fact_sales
```

## Ringkasan Logic

1. CRM menyediakan data customer, produk, dan transaksi penjualan.
2. ERP melengkapi data customer dengan lokasi dan demografi.
3. ERP melengkapi data produk dengan kategori dan subkategori.
4. Semua data sumber disimpan apa adanya di Bronze Layer.
5. Data dibersihkan dan divalidasi di Silver Layer.
6. Data siap analisis dibentuk menjadi fact dan dimension pada Gold Layer.
```
