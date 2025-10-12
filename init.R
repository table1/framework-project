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

if (!requireNamespace("framework", quietly = TRUE)) {
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
  use_renv <- Sys.getenv("FW_USE_RENV", "FALSE") == "TRUE"
  attach_defaults <- TRUE  # Always use default template with explicit auto_attach settings

  # Suppress welcome messages when called from install.sh
  # (install.sh provides its own beautiful output)
} else if (interactive()) {
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
  use_renv <- FALSE
  attach_defaults <- TRUE
  cat(sprintf("  Project name: %s\n", project_name))
  cat(sprintf("  Type: %s\n", type))
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
  use_renv = use_renv,
  attach_defaults = attach_defaults
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
