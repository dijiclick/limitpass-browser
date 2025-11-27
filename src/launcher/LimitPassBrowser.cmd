@echo off
setlocal enabledelayedexpansion

REM Dynamically resolved at install time
set "APP_ROOT=%~dp0.."
set "BROWSER_EXE=%APP_ROOT%\chrome.exe"
set "EXTENSION_PATH=%APP_ROOT%\resources\extension"
set "USER_DATA=%APP_ROOT%\user-data"

if not exist "%USER_DATA%" (
    mkdir "%USER_DATA%"
)

if not exist "%BROWSER_EXE%" (
    echo LimitPass Browser binary is missing. Please reinstall.
    exit /b 1
)

set "EXTENSION_PATHS="
if exist "%EXTENSION_PATH%\manifest.json" (
    set "EXTENSION_PATHS=%EXTENSION_PATH%"
) else (
    for /d %%D in ("%EXTENSION_PATH%\*") do (
        if exist "%%D\manifest.json" (
            if defined EXTENSION_PATHS (
                set "EXTENSION_PATHS=!EXTENSION_PATHS!,%%D"
            ) else (
                set "EXTENSION_PATHS=%%D"
            )
        )
    )
)
if not defined EXTENSION_PATHS (
    set "EXTENSION_PATHS=%EXTENSION_PATH%"
)

set "FLAGS_FILE=%APP_ROOT%\config\chromium-flags.txt"
set "EXTRA_FLAGS="
if exist "%FLAGS_FILE%" (
    for /f "usebackq tokens=* delims=" %%A in ("%FLAGS_FILE%") do (
        set "LINE=%%A"
        if not "!LINE!"=="" (
            set "LINE=!LINE:{EXTENSION_PATH}=%EXTENSION_PATH%!"
            set "LINE=!LINE:{EXTENSION_PATHS}=%EXTENSION_PATHS%!"
            set "LINE=!LINE:{USER_DATA_DIR}=%USER_DATA%!"
            set "EXTRA_FLAGS=!EXTRA_FLAGS! !LINE!"
        )
    )
)

start "" "%BROWSER_EXE%" !EXTRA_FLAGS!
endlocal

