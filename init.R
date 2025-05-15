# ################################################################
#  _____                                                    _
# |  ___|_ __  __ _  _ __ ___    ___ __      __ ___   _ __ | | __
# | |_  | '__|/ _` || '_ ` _ \  / _ \\ \ /\ / // _ \ | '__|| |/ /
# |  _| | |  | (_| || | | | | ||  __/ \ V  V /| (_) || |   |   <
# |_|   |_|   \__,_||_| |_| |_| \___|  \_/\_/  \___/ |_|   |_|\_\
#
# ################################################################

# Get started with the framework in three easy steps:

# 1. Install the devtools package, if not installed.
install.packages("devtools")

# 2. Install the framework package, if not installed.
devtools::install_github("table1/framework")

# 3. Edit the below line and run it  to initialize the project
framework::init(
  project_name      = "Project Name",
  project_structure = "default",
  lintr             = "default",
  styler            = "default"
)
