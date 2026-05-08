@echo off
cls

del "[Success]*.txt" 2>nul
del "[Error]*.txt" 2>nul
:start
echo -------------------------
echo *** Script Execution ***
echo -------------------------
set /p sqlsrvr=Server:
set /p sqldb=Database:

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "000 - ROLLBACK.sql" -o "000 - ROLLBACK.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "000 - ROLLBACK.txt"
) ELSE (
    call :renameFile "[Success]" "000 - ROLLBACK.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "001 - INSERT tblModule.sql" -o "001 - INSERT tblModule.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "001 - INSERT tblModule.txt"
) ELSE (
    call :renameFile "[Success]" "001 - INSERT tblModule.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "002 - INSERT tblMenu.sql" -o "002 - INSERT tblMenu.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "002 - INSERT tblMenu.txt"
) ELSE (
    call :renameFile "[Success]" "002 - INSERT tblMenu.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "003 - ALTER TABLE tblHR_AbsentType.sql" -o "003 - ALTER TABLE tblHR_AbsentType.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "003 - ALTER TABLE tblHR_AbsentType.txt"
) ELSE (
    call :renameFile "[Success]" "003 - ALTER TABLE tblHR_AbsentType.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "101 - CREATE TABLE tblHRDivision.sql" -o "101 - CREATE TABLE tblHRDivision.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "101 - CREATE TABLE tblHRDivision.txt"
) ELSE (
    call :renameFile "[Success]" "101 - CREATE TABLE tblHRDivision.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "102 - CREATE TABLE tblHRDepartment.sql" -o "102 - CREATE TABLE tblHRDepartment.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "102 - CREATE TABLE tblHRDepartment.txt"
) ELSE (
    call :renameFile "[Success]" "102 - CREATE TABLE tblHRDepartment.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "103 - CREATE TABLE tblHRSectionHeader.sql" -o "103 - CREATE TABLE tblHRSectionHeader.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "103 - CREATE TABLE tblHRSectionHeader.txt"
) ELSE (
    call :renameFile "[Success]" "103 - CREATE TABLE tblHRSectionHeader.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "104 - CREATE TABLE tblHRSectionDetails.sql" -o "104 - CREATE TABLE tblHRSectionDetails.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "104 - CREATE TABLE tblHRSectionDetails.txt"
) ELSE (
    call :renameFile "[Success]" "104 - CREATE TABLE tblHRSectionDetails.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "105 - CREATE TABLE tblHRInOutRecords.sql" -o "105 - CREATE TABLE tblHRInOutRecords.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "105 - CREATE TABLE tblHRInOutRecords.txt"
) ELSE (
    call :renameFile "[Success]" "105 - CREATE TABLE tblHRInOutRecords.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "106 - CREATE TYPE TypeHRInOutRecords.sql" -o "106 - CREATE TYPE TypeHRInOutRecords.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "106 - CREATE TYPE TypeHRInOutRecords.txt"
) ELSE (
    call :renameFile "[Success]" "106 - CREATE TYPE TypeHRInOutRecords.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "SQLQuery1.sql" -o "SQLQuery1.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "SQLQuery1.txt"
) ELSE (
    call :renameFile "[Success]" "SQLQuery1.txt"
)

sqlcmd -b -S %sqlsrvr% -d %sqldb% -i "spHR_ZKT.sql" -o "spHR_ZKT.txt"
IF ERRORLEVEL 1 (
    call :renameFile "[Error]" "spHR_ZKT.txt"
) ELSE (
    call :renameFile "[Success]" "spHR_ZKT.txt"
)

goto :eof
:renameFile
set "newName=%~1 %~nx2"
ren "%~2" "%newName%"
goto :eof
