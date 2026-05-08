SET ANSI_NULLS ON
	GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************************************************************
SP Name:     spHR_ZKT
Description: 
Author:      COORETO
Called from: HR CALENDAR

_________________________________________________________________________________________________________________________________
History
Change Number	Date            Author			Description
00				05-Feb-2026		COORETO			Initial Creation


---- NOTE: in option 14,16 the date must change once done 
-- FIx the bug in update of  Holiday Tagging List
  _________________________________________________________________________________________________
** For developers: Please update history for us to keep track of the changes made on this SP

***********************************************************************************************/



CREATE OR ALTER PROCEDURE spHR_ZKT
	@pOption					TINYINT
	,@pUserName					VARCHAR(50) = NULL
	,@pRCategory				VARCHAR(50) = NULL
	,@pTypeHRInOurRecords		typeHRInOurRecords READONLY
	,@pTypeHRPostApproveLeaved  typeHRPostApproveLeaved READONLY
	,@pTypeHRMLQLeaveTypes		typeHRMLQLeaveTypes READONLY
	,@pDepartmentCode			VARCHAR(50) = NULL
	,@pUnitCode					VARCHAR(10) = NULL
	,@pDTApplied				VARCHAR(10) = NULL
	,@pTransID					BIGINT = NULL
	,@pIDNumber					VARCHAR(10) = NULL
	,@pNumHours					BIGINT = NULL

	,@pLeaveCode				VARCHAR(10) = NULL
	,@pLeaveDesc				VARCHAR(max) = NULL
	,@pAbsentType				VARCHAR(10) = NULL
	,@pChargeToLeaved			TINYINT = NULL
	,@pEndDate					date = NULL
	,@pFillingNotice			TINYINT = NULL
	,@pWithQuota				TINYINT = NULL
	,@pLeavedColor				VARCHAR(20) = NULL
	,@pDayspecific				TINYINT = NULL
	,@pChargeToLeavedType		VARCHAR(10) = NULL
	,@pActive					tinyint = NULL

	,@pActivity					VARCHAR(50) = NULL
	,@pModuleID					VARCHAR(50) = NULL

	,@pReasonCode				VARCHAR(50) = NULL
	,@pNoticePeriod				TINYINT = NULL
	,@pRemarks					VARCHAR(max) = NULL

	,@pSchedCode				VARCHAR(10) = NULL
	,@pSchedDesc				VARCHAR(60) = NULL
	,@pFirstHalf				VARCHAR(11) = NULL
	,@pSecondHalf				VARCHAR(11) = NULL
	,@pWholeDay					VARCHAR(11) = NULL

	,@pRestDay					VARCHAR(11) = NULL

	,@pIsCheck					TINYINT = NULL
	,@pDTHoliday				DATETIME = NULL
	,@pLegalHoliday				TINYINT = NULL
	,@pArea						VARCHAR(11) = NULL
	,@pHolidayDescription		VARCHAR(max) = NULL

	,@pDTLeave					DATETIME = NULL
	,@pEmpGroup					VARCHAR(10) = NULL
	,@pPostRemarks				VARCHAR(MAX) = NULL

AS
BEGIN

	DECLARE @lTimeStamp			DATETIME
			,@lMID				INT
			,@lDepartmentCode	VARCHAR(55)
			,@lUnitCode			VARCHAR(55)
			,@lCostCenter		VARCHAR(55)
			,@lIDNumber			VARCHAR(55)
			,@lStartOfYear		DATE
			,@lEndOfYear		DATE

	SET NOCOUNT ON;
		SELECT @lMID = MID from tblModule WHERE ModuleCode = 'HR'


	IF @pOption = 1 -- Get Summited Leaved Data for calendar data
		BEGIN
			SELECT A.IDNumber,A.UserName,A.Position,A.DepartmentCode,A.UnitCode,A.CostCenter,B.LeaveCode,B.DTLeave,B.LeaveReason,B.LeaveCode +' - ' + A.UserName AS USELEAVED
				FROM tblHR_PersonnelMaster A 
				INNER JOIN tblHR_PersonnelLeaves B ON A.IDNumber = B.IDNumber
				WHERE B.DTApplied >='2025' AND A.DepartmentCode ='ZFAD' AND CostCenter = '10130'
				

		END
	IF @pOption = 2 -- GET TEAM DATA
		BEGIN
			SELECT @lDepartmentCode = DepartmentCode, @lUnitCode = UnitCode, @lCostCenter = CostCenter  FROM tblHR_PersonnelMaster WHERE UserName = @pUserName

			SELECT EmployeeGroup AS RANKING,* FROM tblHR_PersonnelMaster 
			WHERE DTSeparated IS NULL 
				AND DepartmentCode = @lDepartmentCode
				AND UnitCode = @lUnitCode 
				AND CostCenter = @lCostCenter 
				--AND UserName <> @pUserName
				ORDER BY RANKING,IDNumber
		END
	IF @pOption = 3 -- SAVE IN OUT DATA
		BEGIN
			INSERT INTO tblHRInOutRecords (ServerID,IDNumber,InOutStatus,TimeInOut)
			SELECT ServerID,IDNumber,InOutStatus,TimeInOut FROM @pTypeHRInOurRecords
			
		END
	IF @pOption = 4 -- GET ALL LEAVE TYPE
		BEGIN			
			SELECT  LeaveCode,LeaveDesc,AbsentType,ChargeToLeaved,EndDate,FillingNotice,WithQuota,LeavedColor,Dayspecific,ChargeToLeaveType,LastUpdateBy,DTModified,Active
				FROM tblHR_AbsentType 
			--WHERE LeaveCode IN (SELECT  DISTINCT ChargeToLeavedType FROM tblHR_AbsentType )
			--WHERE ChargeToLeaved = 1	
		END
	IF @pOption = 5 -- GET ALL Department
		BEGIN
			SELECT DISTINCT DepartmentCode,DepartmentCode + ' - ' + DepartmentName AS Department FROM tblHR_DepartmentUnit
		END
	IF @pOption = 6 -- GET ALL Section
		BEGIN
			SELECT DISTINCT DepartmentCode,UnitCode,UnitCode + ' - ' + UnitName AS Section 
				FROM tblHR_DepartmentUnit
			WHERE DepartmentCode = @pDepartmentCode
		END
	--IF @pOption = 7 -- GET ALL EMPLOYEE WITH AND WITHOUT LEAVE QUOTA  
	--	BEGIN

	--	-- WITH QUOTA 
	--	SELECT  A.UserName,A.IDNumber,A.LastName+', '+A.FirstName As EmployeeName,A.Position,A.DepartmentCode,A.UnitCode,A.CostCenter,b.*
	--		FROM tblHR_PersonnelMaster A
	--		JOIN tblHR_PersonnelLeaveBalance B ON A.IDNumber = B.IDNumber
	--		JOIN @pTypeHRMLQLeaveTypes C ON B.LeaveCode = C.LeaveType
	--		--JOIN @typeHRMLQLeaveTypes C ON B.LeaveCode = C.LeaveType
	--			WHERE  A.DTSeparated IS NULL  
	--			AND B.DTFrom = C.DTFrom AND B.DTTo = C.DTTO
	--			AND DepartmentCode = @pDepartmentCode AND UnitCode LIKE '%'+ @pUnitCode +'%'

	--	-- WITHOUT QUOTA
	--	SELECT A.UserName, A.IDNumber, A.LastName + ', ' + A.FirstName AS EmployeeName, A.Position,  A.DepartmentCode, A.UnitCode, A.CostCenter
	--		FROM tblHR_PersonnelMaster A 
	--		CROSS JOIN @pTypeHRMLQLeaveTypes C
	--		WHERE A.DTSeparated IS NULL 
	--		AND NOT EXISTS ( SELECT 1 FROM tblHR_PersonnelLeaveBalance B WHERE B.IDNumber = A.IDNumber
	--				  AND B.LeaveCode = C.LeaveType
	--				  AND B.DTFrom = C.DTFrom
	--				  AND B.DTTo = C.DTTo )
	--		AND DepartmentCode = @pDepartmentCode AND UnitCode LIKE '%'+ @pUnitCode +'%'
	--	END
	IF @pOption = 7 -- GET ALL EMPLOYEE WITH AND WITHOUT LEAVE QUOTA  
		BEGIN

			SET @lStartOfYear = (SELECT MIN(DTFrom) FROM @pTypeHRMLQLeaveTypes);
			SET @lEndOfYear   = (SELECT MAX(DTTo)   FROM @pTypeHRMLQLeaveTypes);


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
			CROSS JOIN @pTypeHRMLQLeaveTypes C
			LEFT JOIN tblHR_PersonnelLeaveBalance B
				ON A.IDNumber = B.IDNumber AND B.LeaveCode = C.LeaveType AND B.DTFrom <= @lEndOfYear AND B.DTTo   >= @lStartOfYear
			WHERE A.DTSeparated IS NULL
			  AND A.DepartmentCode = @pDepartmentCode
			  AND A.UnitCode LIKE '%' + @pUnitCode + '%'

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
				STRING_AGG(ISNULL(CAST(Quota AS VARCHAR(10)), '0'), ', ') AS Quota,
				STRING_AGG(MissingPeriods, ' | ') AS Periods,  --MissingPeriods
				'WITHOUT QUOTA' AS Status
		
			FROM #tmpTblQuota
			GROUP BY UserName, IDNumber, EmployeeName,
				Position, DepartmentCode, UnitCode, CostCenter
			HAVING SUM(IsCovered) < COUNT(*)

			--select * from #tmpTblQuota
			DROP TABLE IF EXISTS #tmpTblQuota

		END
	IF @pOption = 8 -- GET User Info  ----------  EXEC spHR_ZKT @pOption = 23, @pEmpGroup ='PALA', @pDTLeave='2022-01-10 17:49:32.150'   
		BEGIN
			SELECT UserName,IDNumber,LastName+', '+FirstName As EmployeeName,Position,DTBirth,DepartmentCode,UnitCode,CostCenter
			FROM tblHR_PersonnelMaster
			WHERE UserName = @pUserName
		END
	IF @pOption = 9 -- GET Applied Leaves Per User
		BEGIN
			IF @pDTApplied IS NULL OR @pDTApplied = ''
				BEGIN
					SET @pDTApplied =  CONVERT(VARCHAR(10), DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1), 101)
				END
			ELSE
				BEGIN
					SET @pDTApplied =  CONVERT(VARCHAR(10), DATEFROMPARTS(YEAR(@pDTApplied) - 1, 1, 1), 101)
				END
			
			IF OBJECT_ID('tempdb..#TempHRAppliedLeaved') IS NOT NULL
				DROP TABLE #TempHRAppliedLeaved;
		-- Start OLD Allied Leave
				SET @lIDNumber = (SELECT top 1 IDNumber FROM tblHR_PersonnelMaster WHERE UserName = @pUserName AND DTSeparated is null)
				DECLARE @tbl AS TABLE (
					Username VARCHAR(30),
					Applvl BIGINT DEFAULT 0
				)

				INSERT INTO @tbl
				select Approver_Name, Approval_Level  from tblApprovalMatrix  where Module = 'HR' and
				MatxID IN (select matxid from tblSCM_ApproverChild where matxid IN 
				(select matxid from tblApprovalMatrix  where Module = 'HR') and Username = @pUsername )


				select DISTINCT A.TransID, A.IDNumber , A.LeaveCode , LeaveDesc, CONVERT(VARCHAR,DTLeave,101) AS DTLeave  ,
				LeaveHourFrom , LeaveHourTo , CONVERT(VARCHAR,DTApplied,101) AS DTApplied,  LeaveReason,
				CASE WHEN A.Posted = 1 and A.IsCancelled = 0 THEN 'Posted' 
				WHEN A.IsCancelled = 1 and A.Posted = 0 THEN 'Cancelled'
				WHEN A.IsCancelled = 0 and A.Posted = 0 AND STAT = 'FA' THEN 'For Approval'
				WHEN STAT = 'RJCT' THEN 'Rejected'
				WHEN STAT = 'FA' THEN 'For Approval'
				ELSE 'For Posting' END AS LeaveStatus, 
				CAST(B.APPLVL AS VARCHAR) + ' - ' + D.Username AS Approver,
				REMARKS, 
				CASE WHEN STAT = 'FA' THEN 'FOR APPROVAL' 
				WHEN STAT = 'CNL' THEN 'CANCELLED'
				WHEN STAT = 'RJCT' THEN 'REJECTED'
				WHEN STAT = 'APPRVD' THEN 'APPROVED' END AS 'Status'
				, Posted, ISNULL(CONVERT(VARCHAR,DTPosted,101),'') AS DTPosted
				, A.NumHours 
				INTO #TempHRAppliedLeaved
				FROM tblHR_PersonnelLeaves A
				INNER JOIN tblHR_PersonnelLeaveApproval B ON  A.IDNumber = B.IDNumber AND A.TransID = B.TransID 
				INNER JOIN tblHR_AbsentType C ON C.LeaveCode = A.LeaveCode 
				LEFT JOIN @tbl D ON D.Applvl = B.APPLVL 
				WHERE A.IDNumber = @lIDNumber 
				--ORDER BY TransID, DTLeave 
		-- End


			--INSERT INTO #TempHRAppliedLeaved

			--SELECT	A.TransID,
			--		A.IDNumber,
			--		A.LeaveCode,
			--		C.LeaveDesc, 
			--		CONVERT(VARCHAR,A.DTLeave,101) AS DTLeave,
			--		A.LeaveHourFrom,
			--		A.LeaveHourTo,
			--		CONVERT(VARCHAR,A.DTApplied,101) AS DTApplied,
			--		A.LeaveReason,
			--		'' AS LeaveStatus,
			--		'' AS Approver,
			--		'' AS REMARKS,
			--		'' AS Status,
			--		'' AS Posted,
			--		'' AS DTPosted,
			--		A.NumHours
			--	FROM tblHR_PersonnelLeaves A
			--	LEFT JOIN tblHR_PersonnelMaster B ON A.IDNumber = B.IDNumber
			--	LEFT JOIN tblHR_AbsentType C ON A.LeaveCode = C.LeaveCode
			--WHERE B.UserName = @pUserName 
			--	AND year(A.DTApplied) = @pDTApplied

			SELECT DISTINCT * FROM #TempHRAppliedLeaved 
			WHERE  DTApplied > @pDTApplied


		END
	IF @pOption = 10 -- GET Leave Balance
		BEGIN
			IF @pIDNumber IS NULL OR @pIDNumber = ''
				BEGIN
					SET @pIDNumber = (SELECT top 1 IDNumber FROM tblHR_PersonnelMaster WHERE UserName = @pUserName AND DTSeparated is null)
				END


			IF @pDTApplied IS NULL or @pDTApplied = ''
				BEGIN
					SET @pDTApplied = year(GETDATE()) - 1
				END

			  SELECT a.LeaveCode, b.LeaveDesc, CONVERT(VARCHAR,a.DTFrom,101) AS DTFrom, CONVERT(VARCHAR,a.DTTo,101) AS DTTo, 
			  a.Quota, a.LeaveBalance, CONVERT(VARCHAR,a.AppliedLeave,101) AS AppliedLeave, a.ForPosting, a.LeaveUsed, 
					 a.Locked, a.LockedBy, a.LockedOn
			  FROM tblHR_PersonnelLeaveBalance a LEFT JOIN tblHR_AbsentType b ON a.LeaveCode = b.LeaveCode 
			  WHERE a.IDNumber = @pIDNumber and year(DTFROM) = @pDTApplied
		END
	IF @pOption = 11 -- CANCEL LEAVE
		BEGIN
			SELECT  * FROM tblHR_PersonnelLeaveBalance 
			WHERE IDNumber = @pIDNumber 

			IF EXISTS(SELECT * FROM tblHR_PersonnelLeaves WHERE IDNumber = @pIDNumber AND TransID = @pTransID AND AGHID IS NOT NULL)
				BEGIN															
					UPDATE A SET 
						A.ForPosting  = A.ForPosting - @pNumHours ,
						A.LeaveBalance = A.LeaveBalance + @pNumHours
					FROM tblHR_PersonnelLeaveBalance A	
					WHERE IDNumber = @pIDNumber  AND A.LeaveCode = @pLeaveCode
										
					END
			ELSE
				BEGIN							
					UPDATE A SET 
						A.AppliedLeave = A.AppliedLeave - @pNumHours ,
						A.LeaveBalance = A.LeaveBalance + @pNumHours
					FROM tblHR_PersonnelLeaveBalance A
					WHERE IDNumber = @pIDNumber AND A.LeaveCode = @pLeaveCode
														
				END
		END
	IF @pOption = 12 -- GET ALL LEAVE TYPE
		BEGIN
			SELECT  ReasonID,ReasonCode,ReasonDescription,NoticePeriod,Remarks,isActive,LeaveCode
			FROM tblHRLeaveReason WHERE LeaveCode = @pLeaveCode
		END
	IF @pOption = 13 -- GET ALL APPLIED LEAVE
		BEGIN
			IF @pDTApplied IS NULL or @pDTApplied = ''
				BEGIN
					SET @pDTApplied = year(GETDATE()) - 1
				END

			SELECT A.DTFrom, B.UserName,B.IDNumber,LastName+', '+FirstName As EmployeeName,B.Position,B.DTBirth,B.DepartmentCode,B.UnitCode,B.CostCenter,A.LeaveCode,A.DTFrom,A.DTTo,A.Quota,A.LeaveBalance,A.AppliedLeave,A.ForPosting,A.LeaveUsed
			FROM tblHR_PersonnelLeaveBalance A
			LEFT JOIN tblHR_PersonnelMaster B ON A.IDNumber = B.IDNumber
			WHERE  B.DTSeparated IS NULL
				AND A.DTFrom >= @pDTApplied
				AND B.USERNAME = @pUserName


		END
	IF @pOption = 14 -- UPSERT for Leave Maintenance tblHR_AbsentType
		BEGIN
			BEGIN TRY

				-- =========================================
				-- VALIDATION (ONLY WHEN DEACTIVATING)
				-- =========================================
				set @lStartOfYear  = '2025'-- DATEFROMPARTS(YEAR(GETDATE()), 1, 1);

				IF @pActive = 0
				AND ( EXISTS ( SELECT 1  FROM tblHR_PersonnelLeaves  WHERE LeaveCode = @pLeaveCode AND DTApplied >= @lStartOfYear
						) OR EXISTS ( SELECT 1  FROM tblHR_PersonnelLeaveBalance  WHERE LeaveCode = @pLeaveCode AND DTFrom >= @lStartOfYear )
					)
				BEGIN
					RAISERROR ( 'LeaveCode is already in use and cannot be deactivated because it has existing transactions.', 16, 1 );
					RETURN;
				END


				-- =========================================
				-- MERGE STATEMENT
				-- =========================================
				MERGE tblHR_AbsentType AS TARGET
				USING ( 
					SELECT @pLeaveCode AS LeaveCode
				) AS SOURCE
				ON TARGET.LeaveCode = SOURCE.LeaveCode

				WHEN MATCHED THEN
					UPDATE SET  LeaveDesc = @pLeaveDesc,  AbsentType = @pAbsentType,  ChargeToLeaved = @pChargeToLeaved, EndDate = @pEndDate, 
						FillingNotice = @pFillingNotice, WithQuota = @pWithQuota, LeavedColor = @pLeavedColor, Dayspecific = @pDayspecific, 
						ChargeToLeaveType = @pChargeToLeavedType, Active = @pActive, LastUpdateBy = @pUserName, DTModified = GETDATE()

				WHEN NOT MATCHED THEN
					INSERT (
						LeaveCode, LeaveDesc, AbsentType, ChargeToLeaved, EndDate, FillingNotice, WithQuota, 
						LeavedColor, Dayspecific, ChargeToLeaveType, CreatedBy, DTCreted, Active
					)
					VALUES (
						@pLeaveCode, @pLeaveDesc, @pAbsentType, @pChargeToLeaved, @pEndDate, @pFillingNotice, 
						@pWithQuota, @pLeavedColor, @pDayspecific, @pChargeToLeavedType, @pUserName, GETDATE(), @pActive
					);

			END TRY

			-- =========================================
			-- ERROR HANDLING
			-- =========================================
			BEGIN CATCH

				IF ERROR_MESSAGE() LIKE '%FK_tblHR_AbsentType_ChargeToLeaveType%'
					BEGIN
						RAISERROR ( 'Invalid ChargeToLeaveType: the referenced LeaveCode does not exist.', 16, 1 );
					END
				ELSE
					BEGIN
						THROW;
					END

			END CATCH
		END
	IF @pOption = 15 -- GET ALL tblHRLeaveReason
		BEGIN
			SELECT ReasonID,ReasonCode,ReasonDescription,NoticePeriod,Remarks,isActive,LeaveCode,DTCreated,CreatedBy,DTModified,LastUpdateBy 
			FROM tblHRLeaveReason

		END
	IF @pOption = 16 -- UPSERT FOR LEAVE REASON MAINTENANCE tblHRLeaveReason
		BEGIN
			BEGIN TRY
				-- =========================================
				-- VALIDATION (ONLY WHEN DEACTIVATING)
				-- =========================================
				IF @pActive = 0
				AND EXISTS ( SELECT 1 FROM tblHR_PersonnelLeaves
								WHERE ReasonCode = @pReasonCode
									AND DTApplied >=  '2025' -- DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
				)
				BEGIN
					RAISERROR ( 'ReasonCode is already in use and cannot be deactivated due to existing leave transactions.', 16, 1 );
					RETURN;
				END
				-- =========================================
				-- MERGE (UPSERT tblHRLeaveReason)
				-- =========================================
				MERGE dbo.tblHRLeaveReason AS TARGET
				USING ( SELECT @pReasonCode AS ReasonCode, @pLeaveCode AS LeaveCode, @pLeaveDesc AS ReasonDescription, @pNoticePeriod AS NoticePeriod, @pRemarks AS Remarks, @pActive AS isActive
				) AS SOURCE
				ON TARGET.ReasonCode = SOURCE.ReasonCode

				WHEN MATCHED THEN
					UPDATE SET LeaveCode = SOURCE.LeaveCode, ReasonDescription = SOURCE.ReasonDescription, NoticePeriod = SOURCE.NoticePeriod, Remarks = SOURCE.Remarks, isActive = SOURCE.isActive,
						DTModified = GETDATE(), LastUpdateBy = @pUserName

				WHEN NOT MATCHED THEN
					INSERT ( LeaveCode		 , ReasonCode		, ReasonDescription		  , NoticePeriod	   , Remarks	   , isActive		, DTCreated, CreatedBy )
					VALUES ( SOURCE.LeaveCode, SOURCE.ReasonCode, SOURCE.ReasonDescription, SOURCE.NoticePeriod, SOURCE.Remarks, SOURCE.isActive, GETDATE(), @pUserName );

			END TRY

			-- =========================================
			-- ERROR HANDLING
			-- =========================================
			BEGIN CATCH

				IF ERROR_MESSAGE() LIKE '%FK_tblHRLeaveReason%'
					BEGIN
						RAISERROR ( 'Invalid LeaveCode: referenced value does not exist in tblHR_AbsentType.',  16, 1 );
					END
				ELSE
					BEGIN
						THROW;
					END
			END CATCH
		END 
	IF @pOption = 17 -- GET ALL tblHR_WorkSchedule
		BEGIN
			SELECT top 5 SchedCode,SchedDesc,FirstHalf,SecondHalf,WholeDay,isActive,CreatedBy,DTCreated,DTModified,LastUpdateBy
			FROM tblHR_WorkSchedule 

		END
	IF @pOption = 18 -- GET ALL tblHR_WorkScheduleRD
		BEGIN
			SELECT top 5 SchedCode,RestDay,CreatedBy,DTCreated,isActive,DTModified,LastUpdateBy 
			FROM tblHR_WorkScheduleRD 

		END
	IF @pOption = 19 -- UPSERT tblHR_WorkSchedule
		BEGIN
			BEGIN TRY

				IF @pActive = 0
				AND EXISTS ( SELECT 1  FROM tblHR_PersonnelMaster 
								WHERE SchedCode = @pSchedCode
								  AND DTSeparated IS NOT NULL )
				BEGIN
					RAISERROR ( 'Schedule is already used in personnel master and cannot be deactivated.', 16, 1 );
					RETURN;
				END

				MERGE tblHR_WorkSchedule AS TARGET
				USING ( SELECT @pSchedCode AS SchedCode ) AS SOURCE
				ON TARGET.SchedCode = SOURCE.SchedCode

				WHEN MATCHED THEN
					UPDATE SET  SchedDesc = @pSchedDesc, FirstHalf = @pFirstHalf, SecondHalf = @pSecondHalf, WholeDay = @pWholeDay, isActive = @pActive, LastUpdateBy = @pUserName, DTModified = GETDATE()

				WHEN NOT MATCHED THEN
					INSERT ( SchedCode, SchedDesc, FirstHalf, SecondHalf, WholeDay, isActive, CreatedBy, DTCreated )
					VALUES ( @pSchedCode, @pSchedDesc, @pFirstHalf, @pSecondHalf, @pWholeDay, @pActive, @pUserName, GETDATE() );

			END TRY
			BEGIN CATCH
				THROW;
			END CATCH
		END
	IF @pOption = 20 -- UPSERT tblHR_WorkScheduleRD
		BEGIN
			BEGIN TRY
				IF @pActive = 0
				AND EXISTS ( SELECT 1  FROM tblHR_PersonnelMaster 
								WHERE SchedCode = @pSchedCode
								  AND DTSeparated IS NOT NULL
				)
				BEGIN
					RAISERROR ( 'Schedule is already used in personnel master and cannot be deactivated.', 16, 1 );
					RETURN;
				END

				MERGE tblHR_WorkScheduleRD AS TARGET
				USING ( SELECT @pSchedCode AS SchedCode ) AS SOURCE
				ON TARGET.SchedCode = SOURCE.SchedCode

				WHEN MATCHED THEN
					UPDATE SET  RestDay = @pRestDay, isActive = @pActive, LastUpdateBy = @pUserName, DTModified = GETDATE()

				WHEN NOT MATCHED THEN
					INSERT ( SchedCode	, RestDay	, isActive	, CreatedBy	, DTCreated )
					VALUES ( @pSchedCode, @pRestDay, @pActive	, @pUserName, GETDATE() );

			END TRY
			BEGIN CATCH
				THROW;
			END CATCH
		END
	IF @pOption = 21 -- GET ALL tblCCD_Holiday
		BEGIN
			SELECT DTHoliday,Description,EncodedBy,DTime,LegalHoliday,Area,IsCheck
			FROM tblCCD_Holiday 
			WHERE DTHoliday >  DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
			ORDER BY DTime DESC
		END 
	IF @pOption = 22 -- UPSERT tblCCD_Holiday need to fix  with bugs 
		BEGIN
			BEGIN TRY

				MERGE tblCCD_Holiday AS TARGET
				USING ( SELECT @pDTHoliday AS DTHoliday ) AS SOURCE
				ON TARGET.DTHoliday = SOURCE.DTHoliday

				WHEN MATCHED THEN
					UPDATE SET DTHoliday = @pDTHoliday, Description = @pHolidayDescription,LegalHoliday = @pLegalHoliday,Area = @pArea, IsCheck = @pIsCheck, DTime = GETDATE(), EncodedBy = @pUserName

				WHEN NOT MATCHED THEN
					INSERT ( DTHoliday, Description, LegalHoliday, Area,IsCheck, EncodedBy, DTime)
					VALUES ( @pDTHoliday, @pHolidayDescription, @pLegalHoliday, @pArea, @pIsCheck, @pUserName, GETDATE());

			END TRY
			BEGIN CATCH
				THROW;
			END CATCH
		END
	IF @pOption = 23 -- GET ALL APPROVED LEAVE tblHR_PersonnelLeaves
		BEGIN
			-- Default Parameters
			IF @pDTLeave IS NULL 
				SET @pDTLeave = GETDATE();

			-- Employee Group Mapping
			IF @pEmpGroup = 'PALA' 
				SET @pEmpGroup = '0,ZD,ZS,ZT,ZW,ZP';   -- All
			ELSE IF @pEmpGroup = 'PALW' 
				SET @pEmpGroup = 'ZD,ZW,ZP';           -- Weekly
			ELSE IF @pEmpGroup = 'PALM' 
				SET @pEmpGroup = 'ZS,ZT';              -- Monthly

			-- MAIN QUERY
			SELECT  
				hr.IDNumber,
				hr.FirstName + ' ' + hr.LastName AS EmployeeName,
				hr.UserName,
				hr.PayrollType,
				hr.EmployeeSubGroup,

				lv.TransID,
				lv.LeaveCode,
				lv.NumHours,
				lv.LeaveHourFrom,
				lv.LeaveHourTo,
				lv.DTApplied,
				lv.DTLeave,
				lv.LeaveReason,
				lv.WithNotice,
				lv.LeaveNotice,
				lv.ChargedToLeave,

				lv.Posted,
				lv.IsCancelled,
				lv.ApprovalLevel,
				lv.ApprovedLevel,
				lv.Approved1_Stat,
				lv.Approved2_Stat,
				lv.Approved3_Stat,

				b.LeaveDesc,
				b.AbsentType,

				CASE 
					WHEN hr.PayrollType = 'C' THEN 'Supervisor-Up'
					ELSE 'Rank-And-File'
				END AS EmployeeType,

				CASE lv.ApprovalLevel
					WHEN 1 THEN lv.Approved1_DTime
					WHEN 2 THEN lv.Approved2_DTime
					WHEN 3 THEN lv.Approved3_DTime
				END AS DTApproved

			INTO #tempTblApprovedLeaves
			FROM tblHR_PersonnelLeaves lv
			INNER JOIN tblHR_PersonnelMaster hr 
				ON lv.IDNumber = hr.IDNumber
			LEFT JOIN tblHR_AbsentType b 
				ON lv.LeaveCode = b.LeaveCode
			WHERE 
				lv.ApprovalLevel = lv.ApprovedLevel
				AND lv.Posted = 0
				AND lv.IsCancelled = 0
				AND (
					CASE lv.ApprovalLevel
						WHEN 1 THEN lv.Approved1_Stat
						WHEN 2 THEN lv.Approved2_Stat
						WHEN 3 THEN lv.Approved3_Stat
					END
				) <> -1
				AND lv.DTLeave <= @pDTLeave
				AND hr.EmployeeSubGroup IN (
					SELECT DATA FROM dbo.fnsplit(@pEmpGroup, ',')
				);

			-- CHARGED TO LEAVE
			SELECT TOP 5 * 
			FROM #tempTblApprovedLeaves
			WHERE ChargedToLeave = 1
			ORDER BY DTApplied DESC;

			-- NOT CHARGED TO LEAVE
			SELECT TOP 5 *
			FROM #tempTblApprovedLeaves
			WHERE ChargedToLeave = 0
			ORDER BY DTApplied DESC;

			DROP TABLE #tempTblApprovedLeaves;
		END
	IF @pOption = 24 -- GET ALL REFERENCE tblReferenceMaster
		BEGIN
			SELECT * FROM tblReferenceMaster WHERE RCategory =  @pRCategory 
		END
	IF @pOption = 25 -- UPDATE tblHR_PersonnelLeaves Tag AS POSTED 
		BEGIN 
			UPDATE VL
			SET VL.Posted = 1, VL.PostedBy = @pUserName, VL.DTPosted = GETDATE(),VL.PostRemarks = @pPostRemarks
			FROM tblHR_PersonnelLeaves VL
			INNER JOIN @pTypeHRPostApproveLeaved TVL 
				ON VL.IDNumber = TVL.IDNumber  AND VL.TransID = TVL.TransID
			WHERE  VL.Posted = 0

		END

END
GO
