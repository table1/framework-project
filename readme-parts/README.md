# README Parts System

This directory contains the modular parts that build `README.md`.

## Structure

- **Numbered parts**: Files like `1_header.md`, `2_quickstart.md`, etc.
- **build.R**: Script that stitches parts together into `README.md`
- Parts are combined in numerical order with blank lines between sections

## Usage

### Edit README Content

1. Edit the relevant numbered part file (e.g., `2_quickstart.md`)
2. Run: `Rscript readme-parts/build.R`
3. The `README.md` is regenerated from all parts

### Parts Overview

- `1_header.md` - Title and description
- `2_quickstart.md` - Installation and initialization
- `3_workflow_intro.md` - Core workflow intro
- **(NO part 4)** - Notebook usage omitted (see framework repo)
- `5_usage_data.md` - Data loading, caching, results
- `6_rest.md` - Configuration, functions, security, etc.

## Shared Content with framework

**Part 4 (`4_usage_notebooks.md`) comes from the framework repo!**

This repo intentionally **omits** the notebook creation section because that's specific to the framework package documentation.

### To Update Shared Section

**DO NOT edit part 4 here!** Always edit in the framework repo:

1. **Edit**: `/Users/erikwestlund/code/framework/readme-parts/4_usage_notebooks.md`
2. **Build framework**: `cd ~/code/framework && Rscript readme-parts/build.R`
3. **Copy here if you want it**:
   ```bash
   cp ~/code/framework/readme-parts/4_usage_notebooks.md ~/code/framework-project/readme-parts/
   ```
4. **Build this repo**: `Rscript readme-parts/build.R`

But typically framework-project doesn't include part 4 at all - it's for framework package users who need to know about `make_notebook()`.

## Benefits

- ✅ Parallel structure with framework repo
- ✅ Easy to see what's different (no part 4)
- ✅ Simple rebuild with `build.R`
- ✅ Template repo stays focused on getting started
