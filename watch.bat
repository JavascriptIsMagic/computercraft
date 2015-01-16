@echo off
cd "%~dp0src"
%~dp0bin/moonc -t ../dist .
%~dp0bin/moonc -w -t ../dist .