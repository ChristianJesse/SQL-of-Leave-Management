@echo off
cls
:start
echo -------------------------
echo *** Script Execution ***
echo -------------------------
set /p sqlsrvr=Server:
set /p sqldb=Database:

sqlcmd -S%sqlsrvr% -d%sqldb% -i"000 - ROLLBACK.sql" -o"000 - ROLLBACK.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"000 - RollBack - tblHR_AbsentType.sql" -o"000 - RollBack - tblHR_AbsentType.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"000 - RollBack - tblHR_PersonnelLeaveBalance.sql" -o"000 - RollBack - tblHR_PersonnelLeaveBalance.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"001 - INSERT tblModule.sql" -o"001 - INSERT tblModule.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"002 - INSERT tblConfiguration_ActivePath.sql" -o"002 - INSERT tblConfiguration_ActivePath.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"003 - INSERT tblMenu.sql" -o"003 - INSERT tblMenu.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"004 - ALTER TABLE tblHR_AbsentType.sql" -o"004 - ALTER TABLE tblHR_AbsentType.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"005 - ALTER TABLE tblHR_PersonnelLeaveBalance.sql" -o"005 - ALTER TABLE tblHR_PersonnelLeaveBalance.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"006 - ALTER TABLE tblHR_PersonnelLeaves.sql" -o"006 - ALTER TABLE tblHR_PersonnelLeaves.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"007 - ALTER TABLE tblHR_WorkSchedule.sql" -o"007 - ALTER TABLE tblHR_WorkSchedule.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"008 - ALTER TABLE tblHR_WorkScheduleRD.sql" -o"008 - ALTER TABLE tblHR_WorkScheduleRD.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"009 - ALTER tblCCD_Holiday.sql" -o"009 - ALTER tblCCD_Holiday.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"101 - CREATE TABLE tblLEAPDivision.sql" -o"101 - CREATE TABLE tblLEAPDivision.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"102 - CREATE TABLE tblLEAPDepartment.sql" -o"102 - CREATE TABLE tblLEAPDepartment.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"103 - CREATE TABLE tblLEAPSectionHeader.sql" -o"103 - CREATE TABLE tblLEAPSectionHeader.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"104 - INSERT tblReferenceMaster.sql" -o"104 - INSERT tblReferenceMaster.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"105 - CREATE TABLE tblLEAPSectionDetails.sql" -o"105 - CREATE TABLE tblLEAPSectionDetails.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"106 - CREATE TABLE tblLEAPInOutRecords.sql" -o"106 - CREATE TABLE tblLEAPInOutRecords.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"107 - CREATE TABLE tblLEAPOfficialBusiness.sql" -o"107 - CREATE TABLE tblLEAPOfficialBusiness.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"108 - CREATE TABLE tblHR_AbsentTypeLogs.sql" -o"108 - CREATE TABLE tblHR_AbsentTypeLogs.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"109 - CREATE TABLE tblHR_LogsWorkSchedule.sql" -o"109 - CREATE TABLE tblHR_LogsWorkSchedule.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"110 - CREATE TABLE tblLEAPLeaveReasonLogs.sql" -o"110 - CREATE TABLE tblLEAPLeaveReasonLogs.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"111 - CREATE TABLE tblHR_LogsWorkScheduleRD.sql" -o"111 - CREATE TABLE tblHR_LogsWorkScheduleRD.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"112 - INSERT INTO tblHRLeaveReason.sql" -o"112 - INSERT INTO tblHRLeaveReason.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"201 - CREATE TYPE typeHRMLQLeaveTypes.sql" -o"201 - CREATE TYPE typeHRMLQLeaveTypes.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"202 - CREATE TYPE typeHRMLQSelectedEmployee.sql" -o"202 - CREATE TYPE typeHRMLQSelectedEmployee.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"203 - CREATE TYPE TypeHRPostApproveLeaved.sql" -o"203 - CREATE TYPE TypeHRPostApproveLeaved.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"204 - CREATE TYPE TypeLEAPInOutRecords.sql" -o"204 - CREATE TYPE TypeLEAPInOutRecords.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"205 - CREATE TYPE TypeLeaveForApproval.sql" -o"205 - CREATE TYPE TypeLeaveForApproval.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"206 - CREATE TYPE typeLEAPOfficialBusiness.sql" -o"206 - CREATE TYPE typeLEAPOfficialBusiness.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"207 - CREATE TABLE tblLEAPLeaveReason.sql" -o"207 - CREATE TABLE tblLEAPLeaveReason.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"208 - UPDATE tblHR_AbsentType.sql" -o"208 - UPDATE tblHR_AbsentType.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"301 - CREATE TRIGGER trtblHR_AbsentTypeLogs.sql" -o"301 - CREATE TRIGGER trtblHR_AbsentTypeLogs.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"302 - CREATE TRIGGER trTblHRLeaveReasonLogs.sql" -o"302 - CREATE TRIGGER trTblHRLeaveReasonLogs.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"303 - CREATE TRIGGER trtblHR_LogsWorkSchedule.sql" -o"303 - CREATE TRIGGER trtblHR_LogsWorkSchedule.txt"
sqlcmd -S%sqlsrvr% -d%sqldb% -i"304 - CREATE TRIGGER trtblHR_LogsWorkScheduleRD.sql" -o"304 - CREATE TRIGGER trtblHR_LogsWorkScheduleRD.txt"
