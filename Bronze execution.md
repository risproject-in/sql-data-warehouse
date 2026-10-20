CRM
├── crm_cust_info
├── crm_sales_details
└── crm_prd_info

ERP
├── erp_loc_a101
├── erp_cust_az12
└── erp_px_cat_g1v2

1. bronze.crm_cust_info
Fungsi
Menyimpan data dasar customer dari sistem CRM.
Logic
Tabel ini menjadi sumber informasi utama pelanggan, seperti:
- ID customer;
- kode customer;
- nama customer;
- status pernikahan;
- jenis kelamin;
- tanggal pembuatan data.
Tabel ini belum menjadi dimension final karena masih berupa data mentah.

===================================================================================================================================================
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info (
    cst_id INTEGER,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);
===================================================================================================================================================

2. bronze.crm_sales_details
Fungsi
Menyimpan data transaksi penjualan dari CRM.
Logic
Satu baris merepresentasikan detail transaksi penjualan.
Tabel ini menyimpan:
- nomor pesanan;
- produk yang dibeli;
- customer yang membeli;
- tanggal pemesanan;
- tanggal pengiriman;
- tanggal jatuh tempo;
- jumlah produk;
- harga;
- total penjualan.
Kolom tanggal menggunakan INTEGER karena data sumber kemungkinan menggunakan format:

===================================================================================================================================================
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
===================================================================================================================================================

3. bronze.crm_prd_info
Fungsi
Menyimpan informasi master produk dari sistem CRM.
Logic
Tabel ini menjelaskan produk yang dijual, bukan transaksi penjualannya.
Data yang disimpan meliputi:
- ID produk;
- kode produk;
- nama produk;
- biaya produk;
- lini produk;
- tanggal mulai berlaku;
- tanggal akhir berlaku.

===================================================================================================================================================
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info (
    prd_id INTEGER,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INTEGER,
    prd_line VARCHAR(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt TIMESTAMP
);
===================================================================================================================================================

4. bronze.erp_loc_a101
Fungsi
Menyimpan informasi lokasi atau negara customer dari sistem ERP.
Logic
Tabel ini melengkapi data customer dari CRM dengan informasi geografis.
CRM mungkin hanya memiliki ID customer, sedangkan ERP menyediakan negara customer.


===================================================================================================================================================
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);
===================================================================================================================================================

5. bronze.erp_cust_az12
Fungsi
Menyimpan informasi demografis customer dari sistem ERP.
Logic
Tabel ini digunakan untuk melengkapi informasi customer dari CRM, terutama:
- tanggal lahir;
- gender;
- kode customer.
Data dari tabel ini dapat digabungkan dengan crm_cust_info

===================================================================================================================================================
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);
===================================================================================================================================================

6. bronze.erp_px_cat_g1v2
Fungsi
Menyimpan informasi kategori dan subkategori produk dari sistem ERP.
Logic
Tabel ini melengkapi informasi produk dari crm_prd_info.
Misalnya, CRM hanya menyimpan nama dan kode produk, sedangkan ERP menyimpan:
- kategori produk;
- subkategori produk;
- informasi maintenance.

===================================================================================================================================================
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
===================================================================================================================================================
