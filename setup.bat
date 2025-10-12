@echo off
REM Framework setup script for Windows
REM Usage: setup.bat [project_name] [type] [use_renv] [attach_defaults]
REM Example: setup.bat "My Project" project n y

REM Check for author config file (~/_frameworkrc on Windows)
set "FRAMEWORKRC=%USERPROFILE%\_frameworkrc"

if exist "%FRAMEWORKRC%" (
    echo Loading author information from %FRAMEWORKRC%
    for /f "usebackq tokens=1,* delims==" %%a in ("%FRAMEWORKRC%") do (
        if "%%a"=="FW_AUTHOR_NAME" set "AUTHOR_NAME=%%b"
        if "%%a"=="FW_AUTHOR_EMAIL" set "AUTHOR_EMAIL=%%b"
        if "%%a"=="FW_AUTHOR_AFFILIATION" set "AUTHOR_AFFILIATION=%%b"
        if "%%a"=="FW_DEFAULT_FORMAT" set "DEFAULT_FORMAT=%%b"
    )
    REM Remove quotes from values
    set AUTHOR_NAME=%AUTHOR_NAME:"=%
    set AUTHOR_EMAIL=%AUTHOR_EMAIL:"=%
    set AUTHOR_AFFILIATION=%AUTHOR_AFFILIATION:"=%
    set DEFAULT_FORMAT=%DEFAULT_FORMAT:"=%
    REM Default if not set
    if "%DEFAULT_FORMAT%"=="" set "DEFAULT_FORMAT=quarto"
) else (
    echo First-time setup: Author information
    echo.
    set /p "AUTHOR_NAME=Your name: "
    set /p "AUTHOR_EMAIL=Your email (optional): "
    set /p "AUTHOR_AFFILIATION=Your affiliation (optional): "

    echo.
    echo Default notebook format:
    echo   1. Quarto (.qmd) - recommended
    echo   2. RMarkdown (.Rmd)
    echo.
    set /p "FORMAT_CHOICE=Choose format (1-2) [1]: "

    if "%FORMAT_CHOICE%"=="2" (
        set "DEFAULT_FORMAT=rmarkdown"
    ) else (
        set "DEFAULT_FORMAT=quarto"
    )

    REM Save to config file
    (
        echo # Framework configuration
        echo # Edit this file to update your default author information
        echo FW_AUTHOR_NAME="%AUTHOR_NAME%"
        echo FW_AUTHOR_EMAIL="%AUTHOR_EMAIL%"
        echo FW_AUTHOR_AFFILIATION="%AUTHOR_AFFILIATION%"
        echo FW_DEFAULT_FORMAT="%DEFAULT_FORMAT%"
    ) > "%FRAMEWORKRC%"

    echo.
    echo Saved to %FRAMEWORKRC%
    echo.
)

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
echo   Author: %AUTHOR_NAME%
echo   Project name: %PROJECT_NAME%
echo   Type: %TYPE%
if /i "%USE_RENV%"=="y" (echo   renv: enabled) else (echo   renv: disabled)
if /i "%ATTACH_DEFAULTS%"=="y" (echo   Auto-load packages: yes) else (echo   Auto-load packages: no)
echo.
echo Initializing...
echo.

REM Run R setup with author information
R --quiet --no-save --slave -e "if (!requireNamespace('framework', quietly = TRUE)) { cat('Installing Framework package...\n'); if (!requireNamespace('devtools', quietly = TRUE)) { install.packages('devtools', repos = 'https://cloud.r-project.org') }; devtools::install_github('table1/framework') }; framework::init(project_name = '%PROJECT_NAME%', type = '%TYPE%', use_renv = %USE_RENV_R%, attach_defaults = %ATTACH_DEFAULTS_R%, author_name = '%AUTHOR_NAME%', author_email = '%AUTHOR_EMAIL%', author_affiliation = '%AUTHOR_AFFILIATION%', default_notebook_format = '%DEFAULT_FORMAT%')" 2>&1 | findstr /V /R "^> ^+ ^$"

echo.
echo Setup complete!
echo.
echo Next steps:
echo   1. Start R in this directory
echo   2. Run: library(framework); scaffold()
echo   3. Start analyzing!
