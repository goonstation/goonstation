@echo off
setlocal

if defined HOOKS_INCLUDE_TGUI (
	goto :skipTguiPrompt
)

for /F "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

set /p tguiChoice=Do you want to install TGUI hooks %ESC%[1m(REQUIRES Node.js)%ESC%[0m? (Y/N):
if /i "%tguiChoice%"=="Y" (
	set "HOOKS_INCLUDE_TGUI=1"
) else (
	set "HOOKS_INCLUDE_TGUI=0"
)
:skipTguiPrompt

if defined HOOKS_INCLUDE_BASE (
	goto :skipBasePrompt
)
set /p baseChoice=Do you want to install map merge and icon merge hooks? (Y/N):
if /i "%baseChoice%"=="Y" (
	set "HOOKS_INCLUDE_BASE=1"
) else (
	set "HOOKS_INCLUDE_BASE=0"
)
:skipBasePrompt

call "%~dp0\..\bootstrap\python" -m hooks.install %*

pause
