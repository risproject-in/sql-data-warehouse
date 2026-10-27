# Bronze Layer — Query dan Dokumentasi PostgreSQL

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
