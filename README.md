# Framework Project Template

**The easiest way to start a Framework-based data analysis project.**

This repository provides a pre-configured project template for the [Framework R package](https://github.com/table1/framework). Clone it and run `framework::init()` to get started immediately.

## Quick Start

```bash
# Clone this template
git clone https://github.com/table1/framework-project my-project-name
cd my-project-name

# Open in RStudio or VS Code
```

Then in R:

```r
# Install framework package (if not already installed)
devtools::install_github("table1/framework")

# Review init.R to configure your project settings
# Then initialize:
framework::init()
```

That's it! Your project structure is ready.

## What Gets Created

Running `framework::init()` creates:

- **Project structure** - Organized directories for data, scripts, functions, results
- **Configuration files** - `config.yml` and optional `settings/` files
- **Git setup** - `.gitignore` configured to protect private data
- **Tooling** - `.lintr`, `.styler.R`, `.editorconfig` for code quality
- **Database** - `framework.db` for metadata tracking
- **Environment** - `.env` template for secrets

## First Steps After Init

### 1. Start a new session

```r
library(framework)
scaffold()  # Loads packages, functions, config
```

### 2. Add your data

Create a data specification in `config.yml` or `settings/data.yml`:

```yaml
data:
  source:
    private:
      survey:
        path: data/source/private/survey.csv
        type: csv
        locked: true
```

Then load it:

```r
df <- data_load("source.private.survey")
```

### 3. Start analyzing

```r
# Your analysis code
results <- analyze(df)

# Save results
result_save("analysis_v1", results, type = "model")
```

## Project Structure Options

Framework supports two project structures:

**Default** - Full structure with organized work directories:
```
project/
├── data/
│   ├── source/private/
│   ├── cached/
│   └── final/private/
├── work/
│   ├── analysis/
│   ├── processing/
│   └── notebooks/
├── functions/
├── results/private/
├── settings/
└── config.yml
```

**Minimal** - Lightweight for simple projects:
```
project/
├── data/
├── functions/
├── results/
└── config.yml
```

Choose your structure when running `framework::init()`.

## Configuration

Edit `config.yml` to customize:

```yaml
default:
  # List packages to auto-load
  packages:
    - dplyr
    - ggplot2

  # Data catalog
  data: settings/data.yml

  # Database connections
  connections: settings/connections.yml

  # Security settings (encryption keys)
  security: settings/security.yml
```

## Secrets Management

Store secrets in `.env` (gitignored):

```env
DB_HOST=localhost
DB_PASSWORD=secret123
DATA_ENCRYPTION_KEY=mykey
```

Reference in `config.yml`:

```yaml
connections:
  db:
    host: !expr Sys.getenv("DB_HOST")
    password: !expr Sys.getenv("DB_PASSWORD")
```

## Next Steps

- See [Framework documentation](https://github.com/table1/framework) for full features
- Add your custom functions to `functions/`
- Configure packages in `config.yml` or `settings/packages.yml`
- Set up database connections in `settings/connections.yml`
- Start analyzing!

## About Framework

Framework is a lightweight R package for structured, reproducible data analysis. It provides:

- Convention-based project structure
- Declarative data management with integrity tracking
- Smart caching for expensive operations
- Database query helpers (PostgreSQL, SQLite)
- Results tracking with encryption support
- Support for multiple formats: CSV, Stata, SPSS, SAS, RDS

Learn more at [github.com/table1/framework](https://github.com/table1/framework)
