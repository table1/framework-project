# ################################################################
#  _____                                                    _
# |  ___|_ __  __ _  _ __ ___    ___ __      __ ___   _ __ | | __
# | |_  | '__|/ _` || '_ ` _ \  / _ \\ \ /\ / // _ \ | '__|| |/ /
# |  _| | |  | (_| || | | | | ||  __/ \ V  V /| (_) || |   |   <
# |_|   |_|   \__,_||_| |_| |_| \___|  \_/\_/  \___/ |_|   |_|\_\
#
# ################################################################

# Get started with Framework in three easy steps:

# 1. Install the devtools package (if not already installed)
install.packages("devtools")

# 2. Install the framework package
devtools::install_github("table1/framework")

# 3. Edit and run this to initialize your project:
framework::init(
  project_name = "My Project",
  type = "analysis"  # Choose your project type (see below)
)

# ================================================================
# PROJECT TYPES - Pick the one that fits your workflow:
# ================================================================
#
# type = "analysis" (default)
#   Full-featured for data analysis with notebooks/, scripts/,
#   data/ (public/private splits), results/, functions/, docs/
#
# type = "course"
#   For teaching with presentations/, notebooks/, data/,
#   functions/, docs/
#
# type = "presentation"
#   Minimal for single talks with data/, functions/, results/
#
# Not sure? Start with "analysis" - it's the most flexible.
# ================================================================
