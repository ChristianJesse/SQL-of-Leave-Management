






SELECT * FROM 

SELECT * FROM tblHRInOutRecords

SELECT * FROM tblHR_AbsentType 
SELECT * FROM tblHR_AbsentTypeLogs

SELECT B.UserName,B.Position,B.DepartmentCode,A.* FROM tblHR_PersonnelLeaveBalance A
LEFT JOIN tblHR_PersonnelMaster B ON A.IDNumber = B.IDNumber

sp_help tblHR_AbsentType






SELECT A.IDNumber,A.UserName,A.Position,A.DepartmentCode,C.DepartmentName,A.UnitCode,C.UnitName,B.LeaveCode,B.DTLeave,B.LeaveHourFrom,B.LeaveHourTo,B.LeaveReason,B.LeaveCode +' - ' + A.UserName AS UseLeaved
FROM tblHR_PersonnelMaster A 
INNER JOIN tblHR_PersonnelLeaves B ON A.IDNumber = B.IDNumber
LEFT JOIN tblHR_DepartmentUnit C ON A.DepartmentCode = C.DepartmentCode AND A.UnitCode = C.UnitCode
WHERE B.DTApplied >='2025' AND A.DepartmentCode ='ZFAD' AND CostCenter = '10130' AND A.UnitCode ='F004'
ORDER BY IDNumber

select * from tblHR_PersonnelLeaves where DTApplied >='2025'

SELECT SchedCode,* FROM tblHR_PersonnelMaster WHERE DepartmentCode ='ZFAD' AND CostCenter = '10130'  AND UnitCode ='F004' AND DTSeparated IS NULL



select * from tblHR_WorkSchedule

SELECT * FROM  tblHR_PersonnelMaster


SELECT * FROM tblHR_DepartmentUnit

SELECT * FROM tblHRDownloadForm

SELECT * FROM tblHR_PersonnelLeaveBalance

select * from tblMenu where LinkText ='My Team'

---update tblMenu set LinkText ='HR Dashboard' where LinkText ='Attendance Monitoring Dashboard'

SP_HELP tblHR_PersonnelMaster


----------------------------------------------------------------------------------------------------









select EmployeeGroup,* from tblHR_PersonnelMaster
WHERE  DTSeparated IS NULL

select * from tblhr_employeeGroups

SELECT  B.UserName,B.IDNumber,B.Position,B.DepartmentCode,B.UnitCode,B.CostCenter FROM tblHR_PersonnelMaster B 
WHERE  B.DTSeparated IS NULL

SELECT B.UserName,B.IDNumber,B.Position,B.DepartmentCode,B.UnitCode,B.CostCenter,A.* FROM tblHR_PersonnelLeaveBalance A
LEFT JOIN tblHR_PersonnelMaster B ON A.IDNumber = B.IDNumber
WHERE  B.DTSeparated IS NULL
AND A.DTFrom ='2025-01-01 00:00:00.000' AND A. DTTo = '2025-06-30 00:00:00.000'
--AND LeaveCode NOT IN ('SL','VL')
ORDER BY B.CostCenter


SELECT DISTINCT UnitCode + ' - ' + UnitName AS Department
FROM tblHR_DepartmentUnit;

SELECT  UserName,IDNumber,LastName+', '+FirstName As EmployeeName,Position,DepartmentCode,UnitCode,CostCenter FROM tblHR_PersonnelMaster
				WHERE  DTSeparated IS NULL 
				AND DepartmentCode = 'ZADM' and UnitCode like '%f006%'























