@echo off
echo open 130.94.18.230 > a.txt
echo crmdump >> a.txt
echo WAKA^<!^>? >> a.txt
echo binary >> a.txt
echo hash >> a.txt
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a)
if "%time:~0,1%"==" " set mytime=%mytime:~1,1%
set customer=%mydate%_%mytime%_Customer.csv
set flight=%mydate%_%mytime%_Flight.csv
set hotel=%mydate%_%mytime%_Hotel.csv
echo get %customer% >> a.txt
echo get %flight% >> a.txt
echo get %hotel% >> a.txt
echo bye >> a.txt
ftp -i -d -s:a.txt
echo Completed
del a.txt
MOVE %customer% C:\dist\data
java -jar C:\dist\WakanowIntegration.jar
MOVE C:\dist\data\%customer% C:\dist\processed
MOVE %flight% C:\dist\data
java -jar C:\dist\WakanowIntegration.jar
MOVE C:\dist\data\%flight% C:\dist\processed
MOVE %hotel% C:\dist\data
java -jar C:\dist\WakanowIntegration.jar
MOVE C:\dist\data\%hotel% C:\dist\processed
