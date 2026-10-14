# Modern Data Warehouse Project

## 1. Data Architecture

This project implements a modern data warehouse using the **Medallion Architecture**, consisting of three data layers:

### 1.1 Bronze Layer
Stores raw data exactly as received from source systems. Data is ingested from ERP and CRM CSV files into SQL Server without applying data transformations.

### 1.2 Silver Layer
Processes raw data through data cleansing, standardization, normalization, and data quality validation to ensure consistency and reliability for analytical purposes.

### 1.3 Gold Layer
Contains business-ready data modeled using a **star schema**, optimized for analytical queries, reporting, and business intelligence.

---

## 2. Project Scope

The project covers the following components:

1. **Data Architecture**  
   Designing a modern data warehouse using the Bronze, Silver, and Gold layers of the Medallion Architecture.

2. **ETL Pipelines**  
   Extracting, transforming, and loading data from source systems into the data warehouse.

3. **Data Modeling**  
   Developing fact and dimension tables optimized for analytical queries.

4. **Analytics and Reporting**  
   Creating SQL-based reports and dashboards to generate actionable business insights.

---

## 3. Project Objective

Develop a modern data warehouse using **Microsoft SQL Server** to consolidate sales data from ERP and CRM source systems. The warehouse will provide an integrated, reliable, and user-friendly data model to support analytical reporting and informed business decision-making.

---

## 4. Project Specifications

### 4.1 Data Sources
Import datasets from two source systems, ERP and CRM, provided as CSV files.

### 4.2 Data Quality
Identify, cleanse, and resolve data quality issues before the data is used for analytical purposes.

### 4.3 Data Integration
Integrate data from ERP and CRM into a unified data model designed to support analytical queries and reporting requirements.

### 4.4 Data Scope
Focus exclusively on the latest available dataset. Historical data tracking and historization are outside the project scope.

### 4.5 Documentation
Provide comprehensive documentation of the data architecture, data model, transformation processes, and Gold layer metadata to support business stakeholders and analytics teams.

---

## 5. Analytics and Reporting

The data warehouse will support the following analytical domains:

### 5.1 Customer Behavior
Analyze customer characteristics, purchasing patterns, and sales behavior to identify relevant business insights.

### 5.2 Product Performance
Evaluate product performance using sales metrics to identify high-performing products and product categories.

### 5.3 Sales Trends
Analyze sales patterns and trends to support business performance evaluation and decision-making.

---

## 6. Repository Structure

The repository is organized into datasets, documentation, SQL scripts, and testing resources.

```text
sql-data-warehouse/
│
├── datasets/
│   ├── source_crm/                     # CRM source datasets
│   │   ├── customers
│   │   ├── products
│   │   └── sales_details
│   │
│   └── source_erp/                     # ERP source datasets
│       ├── customer_demographics
│       ├── locations
│       └── product_categories
│
├── docs/
│   ├── requirements.md                 # Project requirements
│   ├── Project_Requirements.pdf        # Requirements document
│   ├── data_architecture.png           # Medallion architecture diagram
│   ├── data_flow.png                   # Data flow diagram
│   ├── data_integration.png            # Source data integration diagram
│   ├── data_model.png                  # Star schema data model
│   ├── ETL.png                         # ETL techniques and methods
│   ├── data_catalog.md                 # Gold layer data catalog
│   ├── naming_conventions.md           # Naming conventions
│   ├── data_layers.pdf                 # Overview of the three data layers
│   └── Project_Notes_Sketches.pdf      # Project notes and sketches
│
├── scripts/
│   ├── init_database.sql               # Database and schema initialization
│   │
│   ├── bronze/                         # Raw data ingestion scripts
│   │
│   ├── silver/                         # Data cleansing and transformation scripts
│   │
│   └── gold/                           # Analytical model creation scripts
│
├── tests/                              # Silver and Gold layer quality tests
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # Repository license
└── .gitignore                          # Git exclusion rules
```


## 7. Technology Stack

- **Database Management System:** Microsoft SQL Server
- **Data Sources:** ERP and CRM datasets in CSV format
- **Data Processing:** SQL-based ETL pipelines
- **Data Architecture:** Medallion Architecture
- **Data Modeling:** Star schema
- **Analytics:** SQL-based reporting and dashboards
- **Version Control:** Git
