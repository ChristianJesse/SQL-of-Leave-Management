







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






