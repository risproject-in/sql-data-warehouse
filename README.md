DATA ARCHITECTURE :
1. Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics.


PROJECT INVOLVES :
1. Data Architecture: Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.
2. ETL Pipelines: Extracting, transforming, and loading data from source systems into the warehouse.
3. Data Modeling: Developing fact and dimension tables optimized for analytical queries.
4. Analytics & Reporting: Creating SQL-based reports and dashboards for actionable insights.


OBJECTIVE :
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.


SPECIFICATION :
1. Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
2. Data Quality: Cleanse and resolve data quality issues prior to analysis.
3. Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
4. Scope: Focus on the latest dataset only; historization of data is not required.
5. Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.


ANALYTICS & REPORTING :
1. Customer Behavior
2. Product Performance
3. Sales Trends


REPOSITORY STRUCTURE :
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│   ├── source_crm/                     # CRM source: customers, products, sales details
│   ├── source_erp/                     # ERP source: customer birthdates and gender, locations, product categories
│
├── docs/                               # Project documentation and architecture details
│   ├── requirements.md                 # Project requirements (also as Project_Requirements.pdf)
│   ├── data_architecture.png           # The project's architecture (bronze, silver, gold)
│   ├── data_flow.png                   # Data flow diagram
│   ├── data_integration.png            # How the source tables relate to each other
│   ├── data_model.png                  # Data model (star schema)
│   ├── ETL.png                         # The ETL techniques and methods used
│   ├── data_catalog.md                 # Catalog of the gold layer, field descriptions and metadata
│   ├── naming_conventions.md           # Consistent naming guidelines for tables, columns, and files
│   ├── data_layers.pdf                 # The three layers side by side
│   ├── Project_Notes_Sketches.pdf      # Baraa's project notes and sketches
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── init_database.sql               # Creates the database and the three schemas
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Quality checks for the silver and gold layers
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
└── .gitignore                          # Files and directories to be ignored by Git
