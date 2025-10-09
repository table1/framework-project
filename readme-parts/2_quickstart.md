## Quick Start

### Option 1: Use the Template (Recommended)

```bash
git clone https://github.com/table1/framework-project my-project
cd my-project
```

Edit `init.R` with your settings, then run:
```r
devtools::install_github("table1/framework")
source("init.R")
```

**Most common setup:**
```r
framework::init(
  project_name = "MyProject",
  type = "project",  # Creates notebooks/, scripts/, data/, results/
  use_renv = FALSE   # Set TRUE to enable renv for reproducibility
)
```

### Option 2: Start from Scratch

```r
# Install package
devtools::install_github("table1/framework")

# Initialize in current directory
framework::init(
  project_name = "MyProject",
  type = "project",       # or "course" or "presentation"
  use_renv = FALSE,       # Set TRUE to enable renv
  interactive = FALSE
)
```

### Project Types

- **project** (default): Full-featured with `notebooks/`, `scripts/`, `data/` (public/private splits), `results/`, `functions/`, `docs/`
- **course**: For teaching with `presentations/`, `notebooks/`, `data/`, `functions/`, `docs/`
- **presentation**: Minimal for single talks with `data/`, `functions/`, `results/`

**Not sure?** Use `type = "project"` - it's the most flexible.

## What It Does

Framework reduces boilerplate and enforces best practices for data analysis:

- **Project scaffolding** - Standardized directories, config-driven setup
- **Data management** - Declarative data catalog, integrity tracking, encryption
- **Auto-loading** - Packages and custom functions loaded automatically
- **Optional renv integration** - Reproducible package management (opt-in)
- **Caching** - Smart caching for expensive computations
- **Database helpers** - PostgreSQL, SQLite with credential management
- **Results tracking** - Save/retrieve analysis outputs with blinding support
- **Supported formats** - CSV, TSV, RDS, Stata (.dta), SPSS (.sav), SAS (.xpt, .sas7bdat)

## What Gets Created

When you run `init()`, Framework creates:

- **Project structure** - Organized directories (varies by type)
- **Configuration files** - `config.yml` and optional `settings/` files
- **Git setup** - `.gitignore` configured to protect private data
- **Tooling** - `.lintr`, `.styler.R`, `.editorconfig` for code quality
- **Database** - `framework.db` for metadata tracking
- **Environment** - `.env` template for secrets

### Example: Project Type Structure

```
project/
├── notebooks/              # Exploratory analysis
├── scripts/                # Production pipelines
├── data/
│   ├── source/private/     # Raw data (gitignored)
│   ├── source/public/      # Public raw data
│   ├── cached/            # Computation cache (gitignored)
│   └── final/private/     # Results (gitignored)
├── functions/             # Custom functions
├── results/private/       # Analysis outputs (gitignored)
├── docs/                  # Documentation
├── config.yml            # Project configuration
├── framework.db          # Metadata/tracking database
└── .env                  # Secrets (gitignored)
```
