@echo off
setlocal
cd /d C:\Users\maria\Downloads\SGBD\schemaspy\schemaspy

if exist output rmdir /s /q output
mkdir output

java -jar schemaspy-6.2.4.jar -configFile schemaspy.properties -gv "C:\Program Files\Graphviz"
powershell -ExecutionPolicy Bypass -File ".\fix-relationships.ps1"

pause