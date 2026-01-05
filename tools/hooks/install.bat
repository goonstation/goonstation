@echo off
setlocal

if defined TG_INCLUDE_TGUI_HOOKS (
	goto :skipTguiPrompt
)
set /p tguiChoice=Do you want to install TGUI hooks (requires Node.js)? (Y/N):
if /i "%tguiChoice%"=="Y" (
	set "TG_INCLUDE_TGUI_HOOKS=1"
) else (
	set "TG_INCLUDE_TGUI_HOOKS=0"
)
:skipTguiPrompt

if defined TG_INCLUDE_BASE_HOOKS (
	goto :skipBasePrompt
)
set /p baseChoice=Do you want to install map merge and icon merge hooks? (Y/N):
if /i "%baseChoice%"=="Y" (
	set "TG_INCLUDE_BASE_HOOKS=1"
) else (
	set "TG_INCLUDE_BASE_HOOKS=0"
)
:skipBasePrompt

call "%~dp0\..\bootstrap\python" -m hooks.install %*

pause
