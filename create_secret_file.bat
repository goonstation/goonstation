@echo off
cd +secret
echo[ > __secret.dme
if exist __secret.dme (echo Secret File successfully created) else (echo There was a problem with creating the secret file)
pause