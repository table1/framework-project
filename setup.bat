@echo off
REM Framework setup script for Windows
REM Usage: setup.bat [project_name] [type] [use_renv] [attach_defaults]
REM Example: setup.bat "My Project" project n y

REM Default values
set "PROJECT_NAME=%~1"
if "%PROJECT_NAME%"=="" set "PROJECT_NAME=MyProject"

set "TYPE=%~2"
if "%TYPE%"=="" set "TYPE=project"

set "USE_RENV=%~3"
if "%USE_RENV%"=="" set "USE_RENV=n"

set "ATTACH_DEFAULTS=%~4"
if "%ATTACH_DEFAULTS%"=="" set "ATTACH_DEFAULTS=y"

REM Convert y/n to TRUE/FALSE for R
if /i "%USE_RENV%"=="y" (set "USE_RENV_R=TRUE") else (set "USE_RENV_R=FALSE")
if /i "%ATTACH_DEFAULTS%"=="y" (set "ATTACH_DEFAULTS_R=TRUE") else (set "ATTACH_DEFAULTS_R=FALSE")

echo ====================================================
echo   Framework Project Setup
echo ====================================================
echo.
echo Configuration:
echo   Project name: %PROJECT_NAME%
echo   Type: %TYPE%
if /i "%USE_RENV%"=="y" (echo   renv: enabled) else (echo   renv: disabled)
if /i "%ATTACH_DEFAULTS%"=="y" (echo   Auto-load packages: yes) else (echo   Auto-load packages: no)
echo.
echo Initializing...
echo.

REM Run R setup
R --quiet --no-save -e "if (!requireNamespace('framework', quietly = TRUE)) { cat('Installing Framework package...\n'); if (!requireNamespace('devtools', quietly = TRUE)) { install.packages('devtools', repos = 'https://cloud.r-project.org') }; devtools::install_github('table1/framework') }; framework::init(project_name = '%PROJECT_NAME%', type = '%TYPE%', use_renv = %USE_RENV_R%, attach_defaults = %ATTACH_DEFAULTS_R%)"

echo.
echo Setup complete!
echo.
echo Next steps:
echo   1. Start R in this directory
echo   2. Run: library(framework); scaffold()
echo   3. Start analyzing!
