# Framework

A lightweight R package for structured, reproducible data analysis projects focusing on convention over configuration.

**⚠️ Active Development:** APIs may change. Version 1 with stable API coming soon.

## Quick Start

**Preview:** During setup, you'll be asked to choose:
- **Project type** - `project` (full-featured), `course` (teaching), or `presentation` (single talk)
- **Notebook format** - Quarto `.qmd` (recommended) or RMarkdown `.Rmd`
- **Git** - Whether to initialize a `git` repository
- **Package management** - Whether to use renv for package management

Not sure? Choose the defaults. You can always change these later in `config.yml`.

### Option 1: CLI Tool (Recommended)

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/table1/framework/main/inst/bin/install-cli.sh | bash

# Create projects
framework new myproject
framework new slides presentation
framework new                      # Interactive
```

See [Command Line Interface](#command-line-interface) for full details.

### Option 2: One-Time Script (No CLI Installation)

**One-liner (macOS/Linux/Windows with Git Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/table1/framework-project/main/new-project.sh | bash
```

This guides you through creating a new project without installing the CLI.

### Option 3: Manual Setup

Clone the template and customize `init.R` to your preferences:

```bash
git clone https://github.com/table1/framework-project my-project
cd my-project
```

**Open `init.R`** in your favorite editor to set your project name, type, and options, then run it:

```r
framework::init(
  project_name = "MyProject",
  type = "project",                                  # or "course" or "presentation"
  use_renv = FALSE,
  default_notebook_format = "quarto",
  author_name = "Your Name",                         # Allows auto-filling Notebook author (optional)
  author_email = "email@example.com", 
  author_affiliation = "Johns Hopkins University"  
)

# Then run your code from your IDE. Or save your changes and run:
source("init.R")
```

### Project Types

- **project** (default): Full-featured research projects with exploratory notebooks, production scripts, organized data management, and documentation
- **course**: Teaching materials with presentations, student notebooks, and example data
- **presentation**: Single talks or presentations with minimal overhead: just data, helper functions, and output

**Not sure?** Use `type = "project"` - it's the most flexible.

**Example structure:**

```
project/
├── notebooks/              # Exploratory analysis
├── scripts/                # Production pipelines
├── data/
│   ├── source/private/     # Raw data (gitignored)
│   ├── source/public/      # Public raw data
│   ├── cached/             # Computation cache (gitignored)
│   └── final/private/      # Results (gitignored)
├── functions/              # Custom functions
├── results/private/        # Analysis outputs (gitignored)
├── docs/                   # Documentation
├── config.yml              # Project configuration
├── framework.db            # Metadata/tracking database
└── .env                    # Secrets (gitignored)
```

## Why Use Framework?

Framework reduces boilerplate and enforces best practices for data analysis:

- **Project scaffolding** - Standardized directories, config-driven setup
- **Data management** - Declarative data catalog, integrity tracking, encryption (on roadmap)
- **Auto-loading** - Load the packages you use in every file with one command; no more file juggling with your `library()` calls
- **Optional renv integration** - Use `renv` for reproducible package management without having to fight `renv` or babysit it.
- **Caching** - Smart caching for expensive computations
- **Database helpers** - PostgreSQL, SQLite with credential management
- **Supported file formats** - CSV, TSV, RDS, Stata (.dta), SPSS (.sav), SAS (.xpt, .sas7bdat)

## What Gets Created

When you run `init()`, Framework creates:

- **Project structure** - Organized directories (varies by type)
- **Configuration files** - `config.yml` and optional `settings/` files
- **Git setup** - `.gitignore` configured to protect private data
- **Tooling** - `.lintr`, `.styler.R`, `.editorconfig` for code quality
- **Database** - `framework.db` for metadata tracking
- **Environment** - `.env` template for secrets

## Core Workflow

### 1. Initialize Your Session

```r
library(framework)
scaffold()  # Loads packages, functions, config, standardizes working directory
```

### 2. Load Data

**Via config:**
```yaml
# config.yml or settings/data.yml
data:
  source:
    private:
      survey:
        path: data/source/private/survey.dta
        type: stata
        locked: true
```

```r
# Load using dot notation
df <- data_load("source.private.survey")
```

**Direct path:**
```r
df <- data_load("data/my_file.csv")       # CSV
df <- data_load("data/stata_file.dta")    # Stata
df <- data_load("data/spss_file.sav")     # SPSS
```

Statistical formats (Stata/SPSS/SAS) strip metadata by default for safety. Use `keep_attributes = TRUE` to preserve labels.

### 3. Cache Expensive Operations

```r
model <- get_or_cache("model_v1", {
  expensive_model_fit(df)
}, expire_after = 1440)  # Cache for 24 hours
```

### 4. Save Results

```r
# Save data
data_save(processed_df, "final.private.clean", type = "csv")

# Save analysis output
result_save("regression_model", model, type = "model")

# Save notebook (blinded)
result_save("report", file = "report.html", type = "notebook",
            blind = TRUE, public = FALSE)
```

### 5. Query Databases

```yaml
# config.yml
connections:
  db:
    driver: postgresql
    host: !expr Sys.getenv("DB_HOST")
    database: !expr Sys.getenv("DB_NAME")
    user: !expr Sys.getenv("DB_USER")
    password: !expr Sys.getenv("DB_PASS")
```

```r
df <- query_get("SELECT * FROM users WHERE active = true", "db")
```


## Configuration

**Simple:**
```yaml
default:
  packages:
    - dplyr
    - ggplot2
  data:
    example: data/example.csv
```

**Advanced:** Split config into `settings/` files:
```yaml
default:
  data: settings/data.yml
  packages: settings/packages.yml
  connections: settings/connections.yml
  security: settings/security.yml
```

Use `.env` for secrets:
```env
DB_HOST=localhost
DB_PASS=secret
DATA_ENCRYPTION_KEY=key123
```

Reference in config:
```yaml
security:
  data_key: !expr Sys.getenv("DATA_ENCRYPTION_KEY")
```

## Key Functions

| Function | Purpose |
|----------|---------|
| `scaffold()` | Initialize session (load packages, functions, config) |
| `data_load()` | Load data from path or config |
| `data_save()` | Save data with integrity tracking |
| `query_get()` | Execute SQL query, return data |
| `query_execute()` | Execute SQL command |
| `get_or_cache()` | Lazy evaluation with caching |
| `result_save()` | Save analysis output |
| `result_get()` | Retrieve saved result |
| `scratch_capture()` | Quick debug/temp file save |
| `renv_enable()` | Enable renv for reproducibility (opt-in) |
| `renv_disable()` | Disable renv integration |
| `packages_snapshot()` | Save package versions to renv.lock |
| `packages_restore()` | Restore packages from renv.lock |

## Data Integrity & Security

- **Hash tracking** - All data files tracked with SHA-256 hashes
- **Locked data** - Flag files as read-only, errors on modification
- **Encryption** - AES encryption for sensitive data/results
- **Gitignore by default** - Private directories auto-ignored

## Reproducibility with renv

Framework includes **optional** renv integration (OFF by default):

```r
# Enable renv for this project
renv_enable()

# Your packages are now managed by renv
# Use snapshot after installing new packages
packages_snapshot()

# Disable renv if you prefer
renv_disable()
```

**Version pinning in config.yml:**
```yaml
packages:
  - dplyr              # Latest from CRAN
  - ggplot2@3.4.0     # Specific version
  - tidyverse/dplyr@main  # GitHub with ref
```

See [renv integration docs](docs/features/renv_integration.md) for details.

## Roadmap

- Excel file support
- Quarto codebook generation
