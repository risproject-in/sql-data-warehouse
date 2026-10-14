# Modern Data Warehouse Project
# モダンデータウェアハウスプロジェクト

## 1. Data Architecture データアーキテクチャ

This project implements a modern data warehouse using the **Medallion Architecture**, consisting of three data layers.
本プロジェクトでは、3つのデータレイヤーで構成される**メダリオンアーキテクチャ（Medallion Architecture）**を採用し、モダンデータウェアハウスを構築します。

### 1.1 Bronze Layer ブロンズレイヤー

Stores raw data exactly as received from source systems. Data is ingested from ERP and CRM CSV files into SQL Server without applying data transformations.

ソースシステムから取得した生データを、加工せずにそのまま保存します。ERPおよびCRMのCSVファイルからデータをSQL Serverに取り込み、変換処理を行わずに格納します。

### 1.2 Silver Layer
### 1.2 シルバーレイヤー

Processes raw data through data cleansing, standardization, normalization, and data quality validation to ensure consistency and reliability for analytical purposes.

データクレンジング、標準化、正規化、およびデータ品質検証を実施します。分析に利用できる一貫性と信頼性を備えたデータを整備します。

### 1.3 Gold Layer
### 1.3 ゴールドレイヤー

Contains business-ready data modeled using a **star schema**, optimized for analytical queries, reporting, and business intelligence.

**スタースキーマ（Star Schema）**に基づいてモデル化された、業務分析に利用可能なデータを格納します。分析クエリ、レポート作成、およびビジネスインテリジェンスに適した構造を採用します。

---

## 2. Project Scope
## 2. プロジェクトの範囲

The project covers the following components.

本プロジェクトでは、以下の項目を対象とします。

1. **Data Architecture — データアーキテクチャ**

   Designing a modern data warehouse using the Bronze, Silver, and Gold layers of the Medallion Architecture.

   メダリオンアーキテクチャのブロンズ、シルバー、ゴールドの各レイヤーを用いて、モダンデータウェアハウスを設計します。

2. **ETL Pipelines — ETLパイプライン**

   Extracting, transforming, and loading data from source systems into the data warehouse.

   ソースシステムからデータを抽出し、変換処理を実施したうえで、データウェアハウスにロードします。

3. **Data Modeling — データモデリング**

   Developing fact and dimension tables optimized for analytical queries.

   分析クエリに適したファクトテーブルおよびディメンションテーブルを設計・構築します。

4. **Analytics and Reporting — 分析とレポート作成**

   Creating SQL-based reports and dashboards to generate actionable business insights.

   SQLを用いたレポートおよびダッシュボードを作成し、ビジネス上の意思決定に役立つ分析結果を提供します。

---

## 3. Project Objective
## 3. プロジェクトの目的

Develop a modern data warehouse using **Microsoft SQL Server** to consolidate sales data from ERP and CRM source systems. The warehouse will provide an integrated, reliable, and user-friendly data model to support analytical reporting and informed business decision-making.

**Microsoft SQL Server**を使用して、ERPおよびCRMの各ソースシステムに分散した販売データを統合するモダンデータウェアハウスを構築します。統合された信頼性の高い、利用しやすいデータモデルを提供し、分析レポートの作成およびデータに基づく意思決定を支援します。

---

## 4. Project Specifications
## 4. プロジェクト仕様

### 4.1 Data Sources
### 4.1 データソース

Import datasets from two source systems, ERP and CRM, provided as CSV files.

ERPおよびCRMの2つのソースシステムから提供されるCSV形式のデータセットをインポートします。

### 4.2 Data Quality
### 4.2 データ品質

Identify, cleanse, and resolve data quality issues before the data is used for analytical purposes.

分析に利用する前に、データ品質上の問題を特定し、データクレンジングおよび修正を実施します。

### 4.3 Data Integration
### 4.3 データ統合

Integrate data from ERP and CRM into a unified data model designed to support analytical queries and reporting requirements.

ERPおよびCRMのデータを統合し、分析クエリおよびレポート作成の要件を満たす統一データモデルを構築します。

### 4.4 Data Scope
### 4.4 データの対象範囲

Focus exclusively on the latest available dataset. Historical data tracking and historization are outside the project scope.

最新のデータセットのみを対象とします。過去データの追跡および履歴管理は本プロジェクトの対象外とします。

### 4.5 Documentation
### 4.5 ドキュメント

Provide comprehensive documentation of the data architecture, data model, transformation processes, and Gold layer metadata to support business stakeholders and analytics teams.

ビジネス関係者および分析チームを支援するため、データアーキテクチャ、データモデル、変換処理、およびゴールドレイヤーのメタデータに関する包括的なドキュメントを作成します。

---

## 5. Analytics and Reporting
## 5. 分析とレポート作成

The data warehouse will support the following analytical domains.

本データウェアハウスでは、以下の分析領域を対象とします。

### 5.1 Customer Behavior
### 5.1 顧客行動分析

Analyze customer characteristics, purchasing patterns, and sales behavior to identify relevant business insights.

顧客の属性、購買パターン、および購買行動を分析し、ビジネスに役立つ知見を抽出します。

### 5.2 Product Performance
### 5.2 商品パフォーマンス分析

Evaluate product performance using sales metrics to identify high-performing products and product categories.

販売指標を用いて商品ごとの実績を評価し、売上実績の高い商品および商品カテゴリーを特定します。

### 5.3 Sales Trends
### 5.3 売上トレンド分析

Analyze sales patterns and trends to support business performance evaluation and decision-making.

売上のパターンおよびトレンドを分析し、業績評価と意思決定を支援します。

---

## 6. Repository Structure
## 6. リポジトリ構成

The repository is organized into datasets, documentation, SQL scripts, and testing resources.

リポジトリは、データセット、ドキュメント、SQLスクリプト、およびテ
