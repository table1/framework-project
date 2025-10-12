# ################################################################
#  _____                                                    _
# |  ___|_ __  __ _  _ __ ___    ___ __      __ ___   _ __ | | __
# | |_  | '__|/ _` || '_ ` _ \  / _ \\ \ /\ / // _ \ | '__|| |/ /
# |  _| | |  | (_| || | | | | ||  __/ \ V  V /| (_) || |   |   <
# |_|   |_|   \__,_||_| |_| |_| \___|  \_/\_/  \___/ |_|   |_|\_\
#
# ################################################################

# Only show welcome message if not running from install.sh
if (Sys.getenv("FW_NON_INTERACTIVE") != "true") {
  cat("\n")
  cat("Welcome to Framework!\n")
  cat("Let's set up your project.\n\n")
}

# ================================================================
# STEP 1: Install Framework Package
# ================================================================

fw_non_interactive_check <- Sys.getenv("FW_NON_INTERACTIVE") == "true"
fw_dev_mode <- Sys.getenv("FW_DEV_MODE") == "true"
fw_dev_path <- Sys.getenv("FW_DEV_PATH", "")

if (fw_dev_mode && nchar(fw_dev_path) > 0) {
  # Dev mode: Install from local path
  if (!fw_non_interactive_check) cat("Dev mode: Installing framework from local path...\n")

  if (!dir.exists(fw_dev_path)) {
    stop(sprintf("Dev path does not exist: %s", fw_dev_path))
  }

  # Install devtools if needed
  if (!requireNamespace("devtools", quietly = TRUE)) {
    if (!fw_non_interactive_check) cat("  Installing devtools...\n")
    install.packages("devtools", quiet = TRUE)
  }

  if (!fw_non_interactive_check) cat(sprintf("  Installing framework from %s...\n", fw_dev_path))
  devtools::install(fw_dev_path, quiet = TRUE, upgrade = "never")
  if (!fw_non_interactive_check) cat("  \u2713 Framework installed from local dev path!\n\n")

} else if (!requireNamespace("framework", quietly = TRUE)) {
  # Normal mode: Install from GitHub
  if (!fw_non_interactive_check) cat("Installing framework package...\n")

  # Install devtools if needed
  if (!requireNamespace("devtools", quietly = TRUE)) {
    if (!fw_non_interactive_check) cat("  Installing devtools...\n")
    install.packages("devtools", quiet = TRUE)
  }

  if (!fw_non_interactive_check) cat("  Installing framework from GitHub...\n")
  devtools::install_github("table1/framework", quiet = TRUE)
  if (!fw_non_interactive_check) cat("  \u2713 Framework installed!\n\n")
} else {
  if (!fw_non_interactive_check) cat("\u2713 Framework package already installed\n\n")
}

# ================================================================
# STEP 2: Interactive Configuration
# ================================================================

# Check if running from install.sh (non-interactive bash script)
fw_non_interactive <- Sys.getenv("FW_NON_INTERACTIVE") == "true"

if (fw_non_interactive) {
  # Read from environment variables set by install.sh
  project_name <- Sys.getenv("FW_PROJECT_NAME", "MyProject")
  type <- Sys.getenv("FW_PROJECT_TYPE", "project")
  use_git <- Sys.getenv("FW_USE_GIT", "TRUE") == "TRUE"
  use_renv <- Sys.getenv("FW_USE_RENV", "FALSE") == "TRUE"
  attach_defaults <- TRUE  # Always use default template with explicit auto_attach settings

  # Author information from ~/.frameworkrc
  author_name <- Sys.getenv("FW_AUTHOR_NAME", "Your Name")
  author_email <- Sys.getenv("FW_AUTHOR_EMAIL", "")
  author_affiliation <- Sys.getenv("FW_AUTHOR_AFFILIATION", "")
  default_format <- Sys.getenv("FW_DEFAULT_FORMAT", "quarto")

  # Suppress welcome messages when called from install.sh
  # (install.sh provides its own beautiful output)
} else if (interactive()) {
  # Author information (stored in ~/.frameworkrc or ~/_frameworkrc on Windows)
  frameworkrc <- file.path(Sys.getenv("HOME"), if (.Platform$OS.type == "windows") "_frameworkrc" else ".frameworkrc")

  if (file.exists(frameworkrc)) {
    # Load existing author info
    rc_lines <- readLines(frameworkrc, warn = FALSE)
    author_name <- sub("^FW_AUTHOR_NAME=\"(.*)\"$", "\\1", grep("^FW_AUTHOR_NAME=", rc_lines, value = TRUE))
    author_email <- sub("^FW_AUTHOR_EMAIL=\"(.*)\"$", "\\1", grep("^FW_AUTHOR_EMAIL=", rc_lines, value = TRUE))
    author_affiliation <- sub("^FW_AUTHOR_AFFILIATION=\"(.*)\"$", "\\1", grep("^FW_AUTHOR_AFFILIATION=", rc_lines, value = TRUE))
    default_format_line <- grep("^FW_DEFAULT_FORMAT=", rc_lines, value = TRUE)
    default_format <- if (length(default_format_line) > 0) {
      sub("^FW_DEFAULT_FORMAT=\"(.*)\"$", "\\1", default_format_line)
    } else {
      "quarto"  # Default if not in config
    }

    cat(sprintf("Using author: %s\n", author_name))
    cat("\n")
  } else {
    # First-time setup
    cat("First-time setup: Author information\n")
    cat("\n")

    author_name <- readline("Your name: ")
    if (nchar(trimws(author_name)) == 0) author_name <- "Your Name"

    author_email <- readline("Your email (optional): ")

    author_affiliation <- readline("Your affiliation (optional): ")

    cat("\n")
    cat("Default notebook format:\n")
    cat("  1. Quarto (.qmd) - recommended\n")
    cat("  2. RMarkdown (.Rmd)\n")
    cat("\n")
    format_choice <- readline("Choose format (1-2) [1]: ")
    default_format <- if (trimws(format_choice) == "2") "rmarkdown" else "quarto"

    # Save to config file
    writeLines(
      c(
        "# Framework configuration",
        "# Edit this file to update your default author information",
        sprintf("FW_AUTHOR_NAME=\"%s\"", author_name),
        sprintf("FW_AUTHOR_EMAIL=\"%s\"", author_email),
        sprintf("FW_AUTHOR_AFFILIATION=\"%s\"", author_affiliation),
        sprintf("FW_DEFAULT_FORMAT=\"%s\"", default_format)
      ),
      frameworkrc
    )

    cat(sprintf("\n\u2713 Saved to %s\n", frameworkrc))
    cat("\n")
  }

  # Project name
  project_name <- readline("Project name: ")
  if (nchar(trimws(project_name)) == 0) {
    project_name <- "MyProject"
    cat("  Using default: MyProject\n")
  }

  cat("\n")

  # Project type
  cat("Project types:\n")
  cat("  1. project (default) - Full-featured data analysis\n")
  cat("     Creates: notebooks/, scripts/, data/, results/, functions/, docs/\n\n")
  cat("  2. course - Teaching materials\n")
  cat("     Creates: presentations/, notebooks/, data/, functions/, docs/\n\n")
  cat("  3. presentation - Single talk\n")
  cat("     Creates: data/, functions/, results/\n\n")

  type_choice <- readline("Choose type (1-3) [1]: ")
  type <- switch(trimws(type_choice),
                 "2" = "course",
                 "3" = "presentation",
                 "project")
  cat(sprintf("  Using type: %s\n", type))

  cat("\n")

  # git integration
  cat("Git version control:\n")
  cat("  Initialize a git repository for this project?\n")
  cat("  You can always run 'git init' manually later\n\n")

  use_git_input <- tolower(trimws(readline("Initialize git repository? (y/n) [y]: ")))
  use_git <- use_git_input != "n" && use_git_input != "no"
  cat(sprintf("  git: %s\n", if (use_git) "enabled" else "disabled"))

  cat("\n")

  # renv integration
  cat("Reproducibility with renv:\n")
  cat("  renv locks package versions for reproducibility\n")
  cat("  You can enable/disable this later with renv_enable()/renv_disable()\n\n")

  use_renv_input <- tolower(trimws(readline("Enable renv? (y/n) [n]: ")))
  use_renv <- use_renv_input == "y" || use_renv_input == "yes"
  cat(sprintf("  renv: %s\n", if (use_renv) "enabled" else "disabled"))

  cat("\n")

  # Default packages configuration
  cat("Default packages:\n")
  cat("  When you run scaffold(), should we automatically load dplyr, tidyr, and ggplot2?\n")
  cat("  (Like running library(dplyr), library(tidyr), library(ggplot2) for you)\n\n")

  use_defaults <- tolower(trimws(readline("Auto-load common packages? (y/n) [y]: ")))
  attach_defaults <- use_defaults != "n" && use_defaults != "no"

  if (attach_defaults) {
    cat("  \u2713 Will auto-load: dplyr, tidyr, ggplot2\n")
    cat("  \u2713 Will install (but not load): readr, stringr, scales\n")
  } else {
    cat("  No packages will be auto-loaded\n")
    cat("  You can configure this later in settings/packages.yml\n")
  }

} else {
  # Non-interactive defaults for CI/CD or scripted runs
  cat("Running in non-interactive mode, using defaults:\n")
  project_name <- "MyProject"
  type <- "project"
  use_git <- TRUE
  use_renv <- FALSE
  attach_defaults <- TRUE
  cat(sprintf("  Project name: %s\n", project_name))
  cat(sprintf("  Type: %s\n", type))
  cat(sprintf("  git: %s\n", if (use_git) "enabled" else "disabled"))
  cat(sprintf("  renv: %s\n", if (use_renv) "enabled" else "disabled"))
  cat("  Default packages: yes\n")
}

if (!fw_non_interactive) {
  cat("\n")
  cat(strrep("=", 60))
  cat("\n")
  cat("Initializing project...\n")
  cat(strrep("=", 60))
  cat("\n\n")
}

# ================================================================
# STEP 3: Run Initialization
# ================================================================

framework::init(
  project_name = project_name,
  type = type,
  use_git = use_git,
  use_renv = use_renv,
  attach_defaults = attach_defaults,
  author_name = author_name,
  author_email = author_email,
  author_affiliation = author_affiliation,
  default_notebook_format = default_format
)

# ================================================================
# STEP 4: Next Steps
# ================================================================

if (!fw_non_interactive) {
  cat("\n")
  cat(strrep("=", 60))
  cat("\n")
  cat("Next Steps:\n")
  cat(strrep("=", 60))
  cat("\n\n")
  cat("1. Start a new R session in this directory\n")
  cat("2. Run:\n")
  cat("     library(framework)\n")
  cat("     scaffold()\n")
  cat("3. Start analyzing!\n\n")
  cat("Tip: The init.R file has been archived to .init.R.done\n")
  cat("     for your records. You can safely delete it.\n\n")
}
