# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the framework-project template repository.

## About This Repository

This is the **framework-project** template repository - a ready-to-use project template for users of the Framework R package. Users clone this repo to start new data analysis projects with a pre-configured structure.

**Related Repository**: The Framework R package source code is at `~/code/framework`

## README Editing Policy

**CRITICAL: NEVER edit `README.md` directly!**

The README uses a modular parts system located in `readme-parts/`:

- **To edit README content**: Edit the appropriate numbered part file (e.g., `2_quickstart.md`, `5_usage_data.md`)
- **To rebuild README**: Run `Rscript readme-parts/build.R`
- **Parts structure**:
  - `1_header.md` - Title and description
  - `2_quickstart.md` - Installation and project types
  - `3_workflow_intro.md` - Core workflow intro
  - **(NO part 4)** - Notebook usage omitted (specific to framework package docs)
  - `5_usage_data.md` - Data loading, caching, results (steps 2-5, renumbered from framework)
  - `6_rest.md` - Configuration, functions, security, etc.

**Key Difference from framework repo**: This repo intentionally OMITS part 4 (`4_usage_notebooks.md`) because `make_notebook()` documentation is for framework package users, not template users.

See `readme-parts/README.md` for complete documentation.

## Shared Content with Framework

The framework repo (`~/code/framework`) is the source of truth for shared documentation.

If you need to sync content:
1. Always edit in the framework repo first
2. Copy specific parts if needed: `cp ~/code/framework/readme-parts/X_name.md readme-parts/`
3. Rebuild: `Rscript readme-parts/build.R`

## Working with Both Repos

When working across both framework and framework-project:

1. **Framework package changes**: Work in `~/code/framework`
2. **Template/init changes**: Update both repos as needed
3. **Documentation changes**: Edit framework first, then sync to framework-project if applicable

## Git Workflow

Standard git workflow:
```bash
git add .
git commit -m "type: description"
git push
```

This template repo has minimal CI/CD - it's meant to be cloned by end users.
