:: ---------------------------------------------------------------------------
:: MTR6 repository updater - overwrites local files with the GitHub content.
::
:: Original one-time creation of the repo in an EMPTY folder:
::     git clone https://github.com/LubinKerhuel/MTR6.git .
::
:: This script does the equivalent without needing an empty folder, and can be
:: re-run any time to re-sync (local modifications are discarded).
:: ---------------------------------------------------------------------------
@echo off
cd /d "%~dp0"
git init -q .
git remote add origin https://github.com/LubinKerhuel/MTR6.git 2>nul
git fetch --depth 1 origin || goto :err
git reset --hard FETCH_HEAD || goto :err
echo === Up to date ===
pause
exit /b 0
:err
echo *** FAILED ***
pause