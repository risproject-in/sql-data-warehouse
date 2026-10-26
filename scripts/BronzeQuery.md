# Bronze Layer — Query PostgreSQL

Dokumentasi ini menjelaskan enam tabel pada **Bronze Layer** dalam data warehouse.

Bronze Layer menyimpan data mentah dari sistem sumber sebelum dilakukan pembersihan,
validasi, dan transformasi ke Silver Layer.

## Sumber Data

```text
CRM
├── crm_cust_info
├── crm_sales_details
└── crm_prd_info

ERP
├── erp_loc_a101
├── erp_cust_az12
└── erp_px_cat_g1v2
```

## File Sumber dan Header CSV

### CRM

| File sumber | Header CSV |
|---|---|
| `cust_info.csv` | `cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date` |
| `prd.info.csv` | `prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt` |
| `sales_details.csv` | `sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price` |

### ERP

| File sumber | Header CSV |
|---|---|
| `CUST_AZ12.csv` | `CID,BDATE,GEN` |
| `LOC_A101.csv` | `CID,CNTRY` |
| `PX_CAT_G1V2.csv` | `ID,CAT,SUBCAT,MAINTENANCE` |

Header CSV digunakan untuk dokumentasi dan pengecekan urutan kolom. Pada perintah
`\copy`, PostgreSQL memasukkan nilai berdasarkan urutan kolom yang ditentukan pada
bagian tujuan. Nama header tidak harus sama persis dengan nama kolom tabel, tetapi
urutannya harus sesuai.

## Arsitektur Data

```text
Bronze
├── Data mentah dari CRM dan ERP
│
Silver
├── Data yang sudah dibersihkan dan divalidasi
│
Gold
└── Data siap analisis dengan Star Schema
```

---

## 1. `bronze.crm_cust_info`

### Fungsi

Menyimpan data dasar customer atau pelanggan dari sistem CRM.

### Logic

Tabel ini menjadi sumber informasi utama pelanggan, meliputi:

- ID customer;
- kode customer;
- nama depan dan nama belakang;
- status pernikahan;
- jenis kelamin;
- tanggal pembuatan data.

Tabel ini belum menjadi dimension final karena masih berupa data mentah dari sistem
sumber.

### Query

```sql
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info (
    cst_id INTEGER,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);
```

### Kolom

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `cst_id` | `INTEGER` | ID customer dari CRM |
| `cst_key` | `VARCHAR(50)` | Kode bisnis customer |
| `cst_firstname` | `VARCHAR(50)` | Nama depan customer |
| `cst_lastname` | `VARCHAR(50)` | Nama belakang customer |
| `cst_marital_status` | `VARCHAR(50)` | Status pernikahan customer |
| `cst_gndr` | `VARCHAR(50)` | Jenis kelamin customer |
| `cst_create_date` | `DATE` | Tanggal pembuatan data customer |

### Peran dalam Data Warehouse

```text
bronze.crm_cust_info
        ↓
silver.customer_clean
        ↓
gold.dim_customer
```

### Bulk Import Data dari CSV

Perintah berikut digunakan untuk memasukkan data customer dari file CSV ke tabel
`bronze.crm_cust_info`. Perintah `\copy` dijalankan melalui terminal `psql` yang sudah
terhubung ke database `sales_datawarehouse`.

Gunakan garis miring `/` pada path Windows agar path dapat dibaca dengan aman oleh
PostgreSQL.

```sql
\copy bronze.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) FROM 'D:/Acceleration/datasets/source_crm/cust_info.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

Keterangan:

- `bronze.crm_cust_info` adalah tabel tujuan.
- Daftar kolom menentukan urutan pemetaan kolom CSV ke tabel PostgreSQL.
- `HEADER TRUE` menunjukkan bahwa baris pertama file berisi nama kolom.
- `FORMAT CSV` menunjukkan format file sumber adalah CSV.
- `DELIMITER ','` menunjukkan pemisah antar kolom adalah koma.
- `QUOTE '"'` menentukan karakter pembungkus nilai teks.
- `ENCODING 'UTF8'` menentukan encoding file sumber.

Setelah import selesai, verifikasi jumlah dan isi data:

```sql
SELECT COUNT(*) AS total_customer
FROM bronze.crm_cust_info;
```

```sql
SELECT *
FROM bronze.crm_cust_info
LIMIT 10;
```

---

## 2. `bronze.crm_sales_details`

### Fungsi

Menyimpan data detail transaksi penjualan dari sistem CRM.

### Logic

Satu baris merepresentasikan satu detail transaksi penjualan. Tabel ini menyimpan:

- nomor pesanan;
- kode produk yang dibeli;
- customer yang melakukan pembelian;
- tanggal pemesanan;
- tanggal pengiriman;
- tanggal jatuh tempo;
- jumlah produk;
- harga produk;
- total nilai penjualan.

Kolom tanggal menggunakan `INTEGER` karena data sumber kemungkinan menggunakan format
`YYYYMMDD`, misalnya `20261020`. Konversi ke tipe `DATE` dilakukan pada Silver Layer.

### Query

```sql
CREATE TABLE IF NOT EXISTS bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INTEGER,
    sls_order_dt INTEGER,
    sls_ship_dt INTEGER,
    sls_due_dt INTEGER,
    sls_sales INTEGER,
    sls_quantity INTEGER,
    sls_price INTEGER
);
```

### Kolom

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `sls_ord_num` | `VARCHAR(50)` | Nomor pesanan |
| `sls_prd_key` | `VARCHAR(50)` | Kode produk |
| `sls_cust_id` | `INTEGER` | ID customer |
| `sls_order_dt` | `INTEGER` | Tanggal pemesanan dari sumber |
| `sls_ship_dt` | `INTEGER` | Tanggal pengiriman dari sumber |
| `sls_due_dt` | `INTEGER` | Tanggal jatuh tempo dari sumber |
| `sls_sales` | `INTEGER` | Nilai total penjualan |
| `sls_quantity` | `INTEGER` | Jumlah produk yang dibeli |
| `sls_price` | `INTEGER` | Harga produk |

### Relasi Utama

```text
sls_cust_id  →  crm_cust_info.cst_id
sls_prd_key  →  crm_prd_info.prd_key
```

### Peran dalam Data Warehouse

```text
bronze.crm_sales_details
        ↓
silver.sales_clean
        ↓
gold.fact_sales
```

---

## 3. `bronze.crm_prd_info`

### Fungsi

Menyimpan informasi master produk dari sistem CRM.

### Logic

Tabel ini menjelaskan produk yang dijual, bukan transaksi penjualannya. Data yang
disimpan meliputi:

- ID produk;
- kode produk;
- nama produk;
- biaya produk;
- lini produk;
- tanggal mulai berlaku;
- tanggal akhir berlaku.

### Query

```sql
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info (
    prd_id INTEGER,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INTEGER,
    prd_line VARCHAR(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt TIMESTAMP
);
```

### Kolom

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `prd_id` | `INTEGER` | ID produk |
| `prd_key` | `VARCHAR(50)` | Kode produk |
| `prd_nm` | `VARCHAR(50)` | Nama produk |
| `prd_cost` | `INTEGER` | Biaya produk |
| `prd_line` | `VARCHAR(50)` | Lini atau kelompok produk |
| `prd_start_dt` | `TIMESTAMP` | Awal masa berlaku produk |
| `prd_end_dt` | `TIMESTAMP` | Akhir masa berlaku produk |

### Relasi Utama

```text
crm_prd_info.prd_key  →  crm_sales_details.sls_prd_key
```

### Peran dalam Data Warehouse

```text
bronze.crm_prd_info
        ↓
silver.product_clean
        ↓
gold.dim_product
```

---

## 4. `bronze.erp_loc_a101`

### Fungsi

Menyimpan informasi lokasi atau negara customer dari sistem ERP.

### Logic

Tabel ini melengkapi data customer dari CRM dengan informasi geografis. CRM mungkin
hanya memiliki ID customer, sedangkan ERP menyediakan negara atau lokasi customer.

Sebelum digabungkan dengan data CRM, format `cid` perlu divalidasi karena kode customer
dari CRM dan ERP dapat menggunakan format yang berbeda.

### Query

```sql
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);
```

### Kolom

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `cid` | `VARCHAR(50)` | ID atau kode customer dari ERP |
| `cntry` | `VARCHAR(50)` | Negara atau lokasi customer |

### Peran dalam Data Warehouse

```text
bronze.erp_loc_a101
        ↓
silver.customer_clean
        ↓
gold.dim_customer
```

---

## 5. `bronze.erp_cust_az12`

### Fungsi

Menyimpan informasi demografis customer dari sistem ERP.

### Logic

Tabel ini digunakan untuk melengkapi informasi customer dari CRM, terutama:

- kode customer;
- tanggal lahir;
- gender.

Data dari tabel ini dapat digabungkan dengan `bronze.crm_cust_info` setelah dilakukan
validasi dan penyamaan format kode customer pada Silver Layer.

### Query

```sql
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);
```

### Kolom

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `cid` | `VARCHAR(50)` | Kode customer dari ERP |
| `bdate` | `DATE` | Tanggal lahir customer |
| `gen` | `VARCHAR(50)` | Gender customer |

### Peran dalam Data Warehouse

```text
bronze.erp_cust_az12
        ↓
silver.customer_clean
        ↓
gold.dim_customer
```

---

## 6. `bronze.erp_px_cat_g1v2`

### Fungsi

Menyimpan informasi kategori dan subkategori produk dari sistem ERP.

### Logic

Tabel ini melengkapi informasi produk dari `bronze.crm_prd_info`. CRM mungkin hanya
menyimpan nama dan kode produk, sedangkan ERP menyediakan:

- kategori produk;
- subkategori produk;
- informasi pemeliharaan produk.

Kode produk perlu divalidasi sebelum digunakan untuk menggabungkan data ERP dan CRM.

### Query

```sql
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
```

### Kolom

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `id` | `VARCHAR(50)` | ID atau kode produk dari ERP |
| `cat` | `VARCHAR(50)` | Kategori produk |
| `subcat` | `VARCHAR(50)` | Subkategori produk |
| `maintenance` | `VARCHAR(50)` | Informasi pemeliharaan produk |

### Relasi Utama

```text
erp_px_cat_g1v2.id  →  crm_prd_info.prd_key
```

### Peran dalam Data Warehouse

```text
bronze.erp_px_cat_g1v2
        ↓
silver.product_clean
        ↓
gold.dim_product
```

---

## Relasi Antar Tabel Bronze

```text
crm_cust_info
      │
      ├── erp_loc_a101
      └── erp_cust_az12
      │
      └── dim_customer
```

```text
crm_prd_info
      │
      └── erp_px_cat_g1v2
      │
      └── dim_product
```

```text
crm_sales_details
      │
      ├── dim_customer
      ├── dim_product
      └── dim_date
      │
      └── fact_sales
```

## Alur Medallion Architecture

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

1. **CRM** menyediakan data customer, produk, dan transaksi penjualan.
2. **ERP** melengkapi data customer dengan lokasi dan demografi.
3. **ERP** juga melengkapi data produk dengan kategori dan subkategori.
4. Semua data sumber pertama kali disimpan apa adanya di Bronze Layer.
5. Data dibersihkan dan divalidasi di Silver Layer.
6. Data yang telah siap dianalisis dibentuk menjadi fact dan dimension pada Gold Layer.
