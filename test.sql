







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






------------------------------------MLQ TESTING AREA








	declare @typeHRMLQLeaveTypes		typeHRMLQLeaveTypes
			,@typeHRMLQSelectedEmployee	typeHRMLQSelectedEmployee
			,@lStartOfYear		DATE
			,@lEndOfYear		DATE

 		INSERT INTO @typeHRMLQLeaveTypes (LeaveType, DTFrom, DTTo, Quota)
								 VALUES  ('BL', '2026-01-01', '2026-12-31', '11'),
								 ('EL', '2026-01-01', '2026-12-31', '11');
--EXEC spHR_ZKT @pOption = 7
--,@pDepartmentCode ='zadm'
--,@pUnitCode='a001' 
--,@pTypeHRMLQLeaveTypes	=	@typeHRMLQLeaveTypes



			SET @lStartOfYear = (SELECT MIN(DTFrom) FROM @typeHRMLQLeaveTypes);
			SET @lEndOfYear   = (SELECT MAX(DTTo)   FROM @typeHRMLQLeaveTypes);


			SELECT  A.UserName, A.IDNumber, A.LastName + ', ' + A.FirstName AS EmployeeName, A.Position, A.DepartmentCode, A.UnitCode, A.CostCenter,
				C.LeaveType,B.Quota,
				CASE 
					WHEN B.IDNumber IS NULL THEN 0
					WHEN B.DTFrom <= C.DTFrom AND B.DTTo >= C.DTTo THEN 1
					ELSE 0
				END AS IsCovered,

				CASE 
					WHEN B.IDNumber IS NULL 
						THEN C.LeaveType
					ELSE NULL
				END AS MissingLeaveType,

				CASE 
					WHEN B.IDNumber IS NULL 
						THEN CONVERT(VARCHAR, C.DTFrom, 23) + ' to ' + CONVERT(VARCHAR, C.DTTo, 23)

					WHEN B.DTFrom > C.DTFrom 
						THEN CONVERT(VARCHAR, C.DTFrom, 23) + ' to ' + CONVERT(VARCHAR, B.DTFrom, 23)

					WHEN B.DTTo < C.DTTo 
						THEN CONVERT(VARCHAR, B.DTTo, 23) + ' to ' + CONVERT(VARCHAR, C.DTTo, 23)

					ELSE NULL
				END AS MissingPeriods,

				CASE 
					WHEN B.IDNumber IS NOT NULL 
						THEN CONVERT(VARCHAR, C.DTFrom, 23) + ' to ' + CONVERT(VARCHAR, C.DTTo, 23)

					WHEN B.DTFrom < C.DTFrom 
						THEN CONVERT(VARCHAR, C.DTFrom, 23) + ' to ' + CONVERT(VARCHAR, B.DTFrom, 23)

					WHEN B.DTTo > C.DTTo 
						THEN CONVERT(VARCHAR, B.DTTo, 23) + ' to ' + CONVERT(VARCHAR, C.DTTo, 23)

					ELSE NULL
				END AS CoverPeriods


			INTO #tmpTblQuota
			FROM tblHR_PersonnelMaster A
			CROSS JOIN @typeHRMLQLeaveTypes C
			LEFT JOIN tblHR_PersonnelLeaveBalance B
				ON A.IDNumber = B.IDNumber AND B.LeaveCode = C.LeaveType AND B.DTFrom <= @lEndOfYear AND B.DTTo   >= @lStartOfYear
			WHERE A.DTSeparated IS NULL
			  AND A.DepartmentCode = 'zadm'
			  AND A.UnitCode LIKE '%a001%'
select * from #tmpTblQuota

		----------------------------------------------WITH QUOTA
			SELECT UserName, IDNumber, EmployeeName, Position, DepartmentCode, UnitCode, CostCenter,
				STRING_AGG(LeaveType, ', ') AS LeaveType,
				STRING_AGG(ISNULL(CAST(Quota AS VARCHAR(10)), '0'), ', ') AS Quota,
				STRING_AGG(CoverPeriods, ' | ') AS Periods, -- CoverPeriods

				'WITH QUOTA' AS Status
			FROM #tmpTblQuota
			GROUP BY UserName, IDNumber, EmployeeName,
				Position, DepartmentCode, UnitCode, CostCenter,IsCovered
			HAVING  SUM(IsCovered) = COUNT(*)   

		----------------------------------------------WITHOUT QUOTA

			SELECT UserName, IDNumber, EmployeeName, Position, DepartmentCode, UnitCode, CostCenter,
				STRING_AGG(CASE WHEN IsCovered = 0 THEN LeaveType END, ', ') AS LeaveType,
				STRING_AGG( CASE  WHEN MissingPeriods IS NOT NULL  THEN ISNULL(CAST(Quota AS VARCHAR(10)), '0') END,  ', ') AS Quota,

				STRING_AGG(MissingPeriods, ' | ') AS Periods,  --MissingPeriods
				'WITHOUT QUOTA' AS Status
		
			FROM #tmpTblQuota
			GROUP BY UserName, IDNumber, EmployeeName,
				Position, DepartmentCode, UnitCode, CostCenter
			HAVING SUM(IsCovered) < COUNT(*)

			--select * from #tmpTblQuota
			DROP TABLE IF EXISTS #tmpTblQuota




		SELECT * FROM tblHR_PersonnelLeaves	 WHERE 	 IDNumber = '00002354'  AND LeaveCode = 'BL' 

SELECT DISTINCT COUNT(A.LeaveBalanceid) FROM tblHR_PersonnelLeaveBalance A  
JOIN tblHR_PersonnelLeaves B ON A.IDNumber = B.IDNumber AND A.LeaveCode = B.LeaveCode
WHERE A.IDNumber = '00002354' 
AND A.LeaveCode = 'BL' 
--AND A.LeaveBalanceID = '12132' 
AND B.DTApplied BETWEEN '2025-01-01 00:00:00.000' 
AND '2025-12-31 00:00:00.000'











select * from tblHR_PersonnelLeaveBalance where IDNumber ='00002523'


	declare @typeHRMLQLeaveTypes  typeHRMLQLeaveTypes 
		INSERT INTO @typeHRMLQLeaveTypes (LeaveType, DTFrom, DTTo, Quota)
		VALUES 
		--('EL', '2025-04-02', '2025-04-30', '11'),
		--('VL', '2025-01-01', '2025-12-30', '11'),
		('BL', '2025-01-01', '2025-12-31', '11');
		--SELECT * FROM @typeHRMLQLeaveTypes
		 EXEC spHR_ZKT @pOption = 7, @pDepartmentCode ='zadm', @pUnitCode='a001' ,@pTypeHRMLQLeaveTypes=@typeHRMLQLeaveTypes


		-- WITH QUOTA 
			SELECT  distinct A.UserName,A.IDNumber,A.LastName+', '+A.FirstName As EmployeeName,A.Position,A.DepartmentCode,A.UnitCode,A.CostCenter,b.*
			FROM tblHR_PersonnelMaster A
			JOIN tblHR_PersonnelLeaveBalance B ON A.IDNumber = B.IDNumber
			--JOIN @pTypeHRMLQLeaveTypes C ON B.LeaveCode = C.Quota
			JOIN @typeHRMLQLeaveTypes C ON B.LeaveCode = C.LeaveType
				WHERE  A.DTSeparated IS NULL  
				AND B.DTFrom = C.DTFrom AND B.DTTo = C.DTTO

		-- WITHOUT QUOTA 
		SELECT A.UserName, A.IDNumber, A.LastName + ', ' + A.FirstName AS EmployeeName, A.Position,  A.DepartmentCode, A.UnitCode, A.CostCenter
		FROM tblHR_PersonnelMaster A 
		CROSS JOIN @typeHRMLQLeaveTypes C
		WHERE A.DTSeparated IS NULL 
		AND NOT EXISTS ( SELECT 1 FROM tblHR_PersonnelLeaveBalance B WHERE B.IDNumber = A.IDNumber
					  AND B.LeaveCode = C.LeaveType
					  AND B.DTFrom <= C.DTFrom
					  AND B.DTTo   >= C.DTTo )



			

-- EXEC spHR_ZKT @pOption = 7, @pDepartmentCode ='zadm', @pUnitCode='a001' ,@pTypeHRMLQLeaveTypes=@typeHRMLQLeaveTypes
				
 --UPDATE  tblHR_PersonnelLeaveBalance SET DTTo ='2026-01-01 00:00:00.000' WHERE IDNUMBER = 00002034 AND LeaveCode = 'BL' AND DTTo ='2025-12-31 00:00:00.000'

 
 --SELECT * FROM  tblHR_PersonnelLeaveBalance  WHERE IDNUMBER = 00002034 AND LeaveCode = 'BL'



 select Position,* from tblHR_PersonnelMaster where UserName = 'cooreto'




 SELECT * FROM tblHR_PersonnelLeaveBalance WHERE YEAR(DTFrom) = 2026

 SELECT * FROM tblHR_PersonnelLeaves


 
	declare @typeHRMLQLeaveTypes		typeHRMLQLeaveTypes,
			@typeHRMLQSelectedEmployee	typeHRMLQSelectedEmployee

 		INSERT INTO @typeHRMLQLeaveTypes (LeaveType, DTFrom, DTTo, Quota)
								 VALUES  ('BL', '2026-01-01', '2026-12-31', '11');

		INSERT INTO @typeHRMLQSelectedEmployee (UserName	, IDNumber	, EmployeeName	, Position			,DepartmentCode	,UnitCode	,CostCenter	,LeaveType	,Quota	,Periods					,Status)
										VALUES ('CMORBITA'	, '00002217', 'ORBITA, SWGDP', 'LEGAL MANAGER'	,'ZADM'			,'A001'		,'10160'	,'BL'		,'0'	,'2026-01-01 to 2026-12-31'	,'WITHOUT QUOTA');
		SELECT * FROM @typeHRMLQLeaveTypes
		SELECT * FROM @typeHRMLQSelectedEmployee

		 EXEC spHR_ZKT @pOption = 26
		 ,@pDepartmentCode ='zadm'
		 ,@pUnitCode='a001' 
		 ,@pTypeHRMLQLeaveTypes	=	@typeHRMLQLeaveTypes
		 ,@pTypeHRMLQSelectedEmployee = @typeHRMLQSelectedEmployee

SELECT * FROM tblHR_PersonnelLeaveBalance WHERE YEAR(DTFrom) = 2026
-- delete tblHR_PersonnelLeaveBalance WHERE YEAR(DTFrom) = 2026




	declare @typeHRMLQLeaveTypes		typeHRMLQLeaveTypes,
			@typeHRMLQSelectedEmployee	typeHRMLQSelectedEmployee

 		INSERT INTO @typeHRMLQLeaveTypes (LeaveType, DTFrom, DTTo, Quota)
								 VALUES  ('BL', '2026-01-01', '2026-12-31', '11'),
								 ('EL', '2026-01-01', '2026-12-31', '11');
EXEC spHR_ZKT @pOption = 7
,@pDepartmentCode ='zadm'
,@pUnitCode='a001' 
,@pTypeHRMLQLeaveTypes	=	@typeHRMLQLeaveTypes











