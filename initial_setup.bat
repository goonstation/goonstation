@echo off
cd +secret
if exist __secret.dme (echo Secret File already exists & pause & exit /B) else (echo Attempting to create Secret File)
echo[ > __secret.dme
if exist __secret.dme (echo Secret File successfully created) else (echo There was a problem with creating the Secret File)
pause
