# Framework Project Template

**The easiest way to start a Framework-based data analysis project.**

This repository provides a pre-configured project template for the [Framework R package](https://github.com/table1/framework). Clone it, edit `init.R` with your settings, and run it to scaffold your project.

## Quick Start

```bash
# Clone this template
git clone https://github.com/table1/framework-project my-project-name
cd my-project-name

# Open in RStudio or your preferred IDE
```

Then in R:

```r
# Install framework package (if not already installed)
devtools::install_github("table1/framework")

# Edit init.R to set your project name and type
# Then run it:
source("init.R")
```

**Most common setup** (data analysis project):
```r
framework::init(
  project_name = "MyAnalysis",
  type = "analysis"  # Creates notebooks/, scripts/, data/, results/
)
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

## Project Type Options

Framework supports three project types. Choose the one that matches your workflow:

### 1. Analysis (default)
Full-featured for data analysis projects:
```r
framework::init(project_name = "MyProject", type = "analysis")
```
Creates: `notebooks/`, `scripts/`, `data/` (with public/private splits), `results/`, `functions/`, `docs/`, `settings/`

### 2. Course
For teaching with multiple presentations:
```r
framework::init(project_name = "MyProject", type = "course")
```
Creates: `presentations/`, `notebooks/`, `data/`, `functions/`, `docs/`, `settings/`

### 3. Presentation
Minimal structure for single talks:
```r
framework::init(project_name = "MyProject", type = "presentation")
```
Creates: `data/`, `functions/`, `results/`

**Not sure?** Start with `type = "analysis"` - it's the most flexible.

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
