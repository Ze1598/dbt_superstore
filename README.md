# Superstore Analytics: dbt Data Pipeline

A production-grade data engineering pipeline built with **dbt**, demonstrating dimensional modeling, automated testing, and interactive analytics visualization.

[![dbt](https://img.shields.io/badge/dbt-1.7+-orange.svg)](https://www.getdbt.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org/)
[![Python](https://img.shields.io/badge/Python-3.10+-green.svg)](https://www.python.org/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.x-red.svg)](https://streamlit.io/)

---

## Project Overview

This project transforms raw e-commerce data from Tableau's public Superstore dataset into a star-schema data warehouse, complete with comprehensive data quality testing and interactive dashboards.

**Key Features:**
- **Dimensional Modeling**: Implements Kimball methodology with 5 dimensions and 1 fact table
- **Schema Validation**: All steps of the process go through schema validation, including uniqueness, nullability, and set values checks
- **Automated Tests**: Generic tests, singular tests, and custom business logic validation
- **Incremental Loading**: Incremental loading via dbt built-in functionality
- **Interactive Dashboard**: Created with Streamlit and Plotly
- **IaC-First**: Reproducible builds with Docker, `just`, and `uv`

---

## Data Architecture

### Pipeline Flow
Raw Data (Excel) 

→ Landing Zone (CSV)

→ Raw Layer (PostgreSQL)

→ Staging Layer (PostgreSQL)

→ Dimensional Model (PostgreSQL)

→ Analytics Dashboard (Streamlit)

### Data Model

**Staging Layer**:
- `stg__orders` - Order-level attributes (ship mode, segment)
- `stg__orders_transactions` - Transaction metrics (sales, profit, quantity, business keys)
- `stg__returns` - Return flags
- `stg__customer` - Customer data
- `stg__product` - Product catalog
- `stg__geography` - Location hierarchy

**Dimensional Model** (Star Schema):
- **Fact Table**: `fct__orders` - Order transactions
- **Dimensions**:
  - `dim__customer`
  - `dim__product`
  - `dim__geography`
  - `dim__order`
  - `dim__date`

**Reporting Layer**:
- `fct_streamlit`

---

## Testing Strategy

This project includes predominantly schema validation tests, with additional business logic tests, to ensure data quality at every layer:

### Test Coverage

| Layer | Generic Tests | Business Tests | Total |
|-------|---------------|----------------|-------|
| Staging | 65+ | - | 65+ |
| Dimensions | 35+ | - | 35+ |
| Facts | 15+ | 2 | 17+ |

### Test Types

**Generic Tests** (via dbt & dbt_utils):
- `unique` - Primary key validation
- `not_null` - Required field enforcement
- `relationships` - Foreign key integrity
- `accepted_values` - Category/enum validation
- `unique_combination_of_columns` - Composite key validation
- `accepted_range` - Numeric boundary checks
- `expression_is_true` - Custom business logic

**Singular Tests** (Custom SQL):
1. [assert_positive_profit_for_non_discounted.sql](dbt_superstore/tests/assert_positive_profit_for_non_discounted.sql) - Validates profitability rules
2. [assert_return_rate_below_threshold.sql](dbt_superstore/tests/assert_return_rate_below_threshold.sql) - Monitors return rate KPIs (< 30%)

Example Test Configuration:
```yaml
# marts/facts/schema.yml
models:
  - name: fct__orders
    columns:
      - name: product_key
        tests:
          - not_null
          - relationships:
              to: ref('dim__product')
              field: product_key
    tests:
      # Business rule: Ship date >= Order date
      - dbt_utils.expression_is_true:
          expression: "date_ship_key >= date_order_key"
```

---

## Quick Start

### Prerequisites


### Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd dbt_superstore
   ```

2. **Configure dbt profile**
   ```bash
   cp profiles.yml.example profiles.yml
   # Edit profiles.yml with your database credentials
   ```

3. **Install dependencies**
   ```bash
   just install
   ```

4. **Start PostgreSQL**
   ```bash
   just up
   ```

5. **Download and prepare data**
   ```bash
   # Download Sample - Superstore.xls from Tableau
   # https://www.tableau.com/sites/default/files/2021-05/Sample%20-%20Superstore.xls

   # Convert Excel to CSV
   uv run python scripts/xls_to_csv.py "data/Sample - Superstore.xls"
   ```

6. **Run dbt pipeline**
   ```bash
   cd dbt_superstore

   # Load seed data
   dbt seed

   # Build models and run tests
   dbt build

   # Or run separately:
   dbt run    # Build all models
   dbt test   # Run all tests
   ```

7. **Launch dashboard**
   ```bash
   just run
   # Opens Streamlit app at http://localhost:8501
   ```

---

## Dashboard Features

The Streamlit dashboard provides interactive analytics:

- **KPI Cards**: Total sales, profit, orders, and return rate
- **Sales Trends**: Monthly and annual revenue evolution 
- **Top N Analysis**: Breakdowns by multiple measures
- **Filter Pane**: Sidebad with filters to change years displayed and dynamically adjust Top N values and measures

**Tech Stack**: Streamlit + Plotly (Express) + SQLAlchemy

---

## Project Structure

```
├── data/                          # Raw data files
│   ├── Sample - Superstore.xls    # Source dataset
│   ├── orders.csv                 # Extracted orders
│   └── returns.csv                # Extracted returns
├── dbt_superstore/                # dbt project
│   ├── models/
│   │   ├── staging/               # Staging layer (6 models)
│   │   │   ├── stg__orders.sql
│   │   │   ├── stg__returns.sql
│   │   │   ├── stg__customer.sql
│   │   │   ├── stg__product.sql
│   │   │   ├── stg__geography.sql
│   │   │   ├── stg__orders_transactions.sql
│   │   │   ├── sources.yml
│   │   │   └── schema.yml         # Staging ests
│   │   └── marts/
│   │       ├── dimensions/        # 5 dimension tables
│   │       │   ├── dim__customer.sql
│   │       │   ├── dim__product.sql
│   │       │   ├── dim__geography.sql
│   │       │   ├── dim__order.sql
│   │       │   ├── dim__date.sql
│   │       │   └── schema.yml     # Dimension tests
│   │       ├── facts/
│   │       │   ├── fct__orders.sql
│   │       │   └── schema.yml     # Fact tests
│   │       └── reporting/
│   │           └── fct_streamlit.sql
│   ├── tests/                     # Business tests
│   │   ├── assert_positive_profit_for_non_discounted.sql
│   │   └── assert_return_rate_below_threshold.sql
│   ├── seeds/                     # CSV data for seeding
│   ├── dbt_project.yml            # dbt configuration
│   └── packages.yml               # dbt_utils dependency
├── scripts/
│   └── xls_to_csv.py              # Data extraction script
├── app.py                         # Streamlit dashboard
├── docker-compose.yml             # PostgreSQL container
├── justfile                       # Task automation
├── pyproject.toml                 # Python dependencies
├── uv.lock                        # Dependency lock file
└── profiles.yml.example           # dbt profile template
```

---

## Key Implementation Details

### 1. Kimball Keys
Dimensions include business keys identified with sufix _bkey, and surrogate keys identified with the sufix _key.

### 2. Incremental Loading
Fact tables and the date dimension use incremental materialization for efficient updates:

```yaml
# dbt_project.yml
marts:
  facts:
    +materialized: incremental
    unique_key: order_key
  dimensions:
    dim__date:
      +materialized: incremental
      +unique_key: date_key
```

The rationale behind an incremental load for the date dimension is to avoid changing the physical data on a static dimension beyond the first load.

### 3. Hash-Based Change Detection
Dimension tables include row hashes for SCD tracking - SCD logic currently not implemented:

```sql
-- dim__customer.sql
{{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS rowhash_keys,
{{ dbt_utils.generate_surrogate_key(['customer_name']) }} AS rowhash_nonkeys
```

### 4. Data Quality Gates
Tests are configured with severity levels to control pipeline behavior:

```yaml
- relationships:
    to: ref('dim__product')
    field: product_key
    config:
      severity: error  # Stops pipeline on failure
```

---

## Available Commands

All common tasks are automated via `justfile`:

```bash
just install       # Install dependencies
just up            # Start PostgreSQL
just down          # Stop PostgreSQL
just dbt run       # Run dbt transformations
just dbt test      # Run all tests
just dbt-test model_name  # Test specific model
just run           # Start Streamlit app
just test          # Run Python tests
```

---

## Prerequisites


| Tool | Version | Purpose |
|------|---------|---------|
| Docker Desktop | ≥ 4.x | Run Postgres container |
| Python | 3.10+ | Data prep + visualization |
| dbt-core | 1.7+ | ELT & modeling |
| dbt-postgres | 1.9+ | PostgreSQL connector |
| git | any | Version control |
| just | ≥ 1.14 | Task automation |
| uv | ≥ 0.1 | Python package manager |

---

## Clean Up

Stop and remove all containers and volumes:

```bash
just down
```

This removes:
- PostgreSQL container
- Docker volumes with database data
- Streamlit processes

---

## Resources

- **dbt Documentation**: https://docs.getdbt.com/
- **dbt_utils Package**: https://github.com/dbt-labs/dbt-utils
- **Data Source**: [Tableau Superstore Sample Data](https://www.tableau.com/sites/default/files/2021-05/Sample%20-%20Superstore.xls)

---

## Licensing & Attribution

The *Sample – Superstore* dataset is redistributed under the terms published by Tableau Software for educational use.  Other listed datasets retain their original licenses—always check the source before sharing production results.

This project is open source and available for portfolio and educational purposes.