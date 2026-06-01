SET ANSI_NULLS ON
	GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************************************************************
SP Name:     spLEAP
Description: 
Author:      COORETO
Called from: HR CALENDAR

_________________________________________________________________________________________________________________________________
History
Change Number	Date            Author			Description
00				05-May-2026		COORETO			Initial Creation


---- NOTE: in option 14,16,18 the date must change once done 
-- FIx the bug in update of  Holiday Tagging List
  _________________________________________________________________________________________________
** For developers: Please update history for us to keep track of the changes made on this SP

***********************************************************************************************/

CREATE OR ALTER PROCEDURE spLEAP
	@pOption					TINYINT
	,@pUserName					VARCHAR(50) = NULL
	,@pRCategory				VARCHAR(50) = NULL
	,@pTypeLEAPInOutRecords				TypeLEAPInOutRecords READONLY
	,@pTypeHRPostApproveLeaved			typeHRPostApproveLeaved READONLY
	,@pTypeHRMLQLeaveTypes				typeHRMLQLeaveTypes READONLY
	,@ptypeHRMLQSelectedEmployee		typeHRMLQSelectedEmployee READONLY
	,@pTypeLeaveForApproval				typeLeaveForApproval READONLY
	,@pTypeLEAPOfficialBusiness			typeLEAPOfficialBusiness READONLY
	,@pDepartmentCode			VARCHAR(50) = NULL
	,@pUnitCode					VARCHAR(10) = NULL
	,@pDTApplied				VARCHAR(10) = NULL
	,@pTransID					BIGINT = NULL
	,@pIDNumber					VARCHAR(10) = NULL
	,@pNumHours					BIGINT = NULL

	,@pLeaveCode				VARCHAR(10) = NULL
	,@pLeaveDesc				VARCHAR(max) = NULL
	,@pAbsentType				VARCHAR(10) = NULL
	,@pChargeToLeave			TINYINT = NULL
	,@pEndDate					date = NULL
	,@pFilingNotice			TINYINT = NULL
	,@pWithQuota				TINYINT = NULL
	,@pLeaveColor				VARCHAR(20) = NULL
	,@pDateSpecific				TINYINT = NULL
	,@pChargeToLeaveType		VARCHAR(10) = NULL
	,@pActive					tinyint = NULL
	,@pPeriodSpecific			TINYINT = NULL --Jake

	,@pActivity					VARCHAR(50) = NULL
	,@pModuleID					VARCHAR(50) = NULL

	,@pReasonCode				VARCHAR(50) = NULL
	,@pNoticePeriod				TINYINT = NULL
	,@pRemarks					VARCHAR(max) = NULL

	,@pSchedCode				VARCHAR(10) = NULL
	,@pSchedDesc				VARCHAR(max) = NULL
	,@pFirstHalf				VARCHAR(11) = NULL
	,@pSecondHalf				VARCHAR(11) = NULL
	,@pWholeDay					VARCHAR(11) = NULL

	,@pRestDay					VARCHAR(11) = NULL
	,@pRDID						INT = NULL

	,@pPID						INT = NULL
	,@pPeriod					VARCHAR(3) = NULL
	,@pMonthStart				INT = NULL
	,@pMonthEnd					INT = NULL

	,@pIsCheck					TINYINT = NULL
	,@pDTHoliday				DATETIME = NULL
	,@pHID						INT = NULL -- Jake
	,@pLegalHoliday				TINYINT = NULL
	,@pArea						VARCHAR(11) = NULL
	,@pHolidayDescription		VARCHAR(max) = NULL

	,@pDTLeave					DATETIME = NULL
	,@pEmpGroup					VARCHAR(10) = NULL
	,@pPostRemarks				VARCHAR(MAX) = NULL

	,@pDTFrom					datetime = NULL
	,@pDTTo						datetime = NULL
	,@pQuota					FLOAT	= NULL
	,@pLeaveBalanceID			INT = NULL
	,@pYearValid				INT = NULL
	,@pLeaveBalance				INT = NULL
	,@pPathCode					VARCHAR(60) = NULL


AS
BEGIN

	DECLARE @lTimeStamp			DATETIME
			,@lMID				INT
			,@lRanking			VARCHAR(55)
			,@lDepartmentCode	VARCHAR(55)
			,@lUnitCode			VARCHAR(55)
			,@lCostCenter		VARCHAR(55)
			,@lIDNumber			VARCHAR(55)
			,@lStartOfYear		DATE
			,@lEndOfYear		DATE
			,@lLeaveCode		VARCHAR(10)
			,@lDTFrom			DATETIME
			,@lDTTo				DATETIME
			,@lQuota			FLOAT
			,@lPeriods			VARCHAR(55)
			,@lDTFromStr		VARCHAR(10)
			,@lDTToStr			VARCHAR(10)
			,@lLeaveUsed		TINYINT
			,@lUserName			VARCHAR(100)
			,@lErrorMessage		VARCHAR(MAX)
			,@lErrorLine		INT

			,@ltableHTMLTotal NVARCHAR(MAX) = ''
			,@lLeaveType VARCHAR(55)
			,@lWorkHrs TINYINT
			,@lReason VARCHAR(max)
			,@lDTNotice DATETIME
			,@lDTLeave DATETIME
			,@lLeaveHrsFrom VARCHAR(8)
			,@lLeaveHrsTo VARCHAR(8)
			,@lReasonCode VARCHAR(55)
			,@lFileNotice VARCHAR(55)
			,@lReasonDesc VARCHAR(MAX)
			,@lAddmsg VARCHAR(MAX)
			,@lmsg VARCHAR(MAX)
			,@lAHID VARCHAR(55)
			,@lStatusID VARCHAR(55)
			,@lID VARCHAR(55)
			,@lCID VARCHAR(55)
			,@ltblAAM TypeDARCSApproverData
			,@lTypeAAMAD TypeAAMApproverData
			,@lTypeAAMAttchmnts	TypeAAMAttachments  
			,@ltableHTML VARCHAR(MAX)
			,@lStatus VARCHAR(55)
			,@lAGHID VARCHAR(55)
			,@msg VARCHAR(MAX)
			,@lTransID BIGINT
			,@lAbsentType Varchar(4)
			,@lChargeToLeave BIT
			,@lLeaveBalance int
			,@lReasonDefinition varchar(255)
			,@lOBDate	DATETIME
			,@lOBReason varchar(max)
			,@lNumHours FLOAT
			,@lOBDestination varchar(255)
			,@lOBFrom DATETIME
			,@lOBTo DATETIME
			,@lPurpose varchar(255)
			,@lDestination varchar(255)
			,@lAttachment varchar(255)


CREATE TABLE #tmpApprovers (
			AHID INT,
			AGHID BIGINT,
			AGDID BIGINT,
			AID BIGINT,
			ADID INT,
			ApproverName VARCHAR(50),
			ApprovalLevel INT,
			PRIMARYID VARCHAR(500),
			StatusID INT,
			PrevStatsID INT,
			TableName VARCHAR(200),
			TableDescription VARCHAR(1000),
			Remarks VARCHAR(200),
			ALHID BIGINT,
			A_UpdatedBy VARCHAR(50),
			A_DTUpdated DATETIME,
			Active BIT
			);

	SET NOCOUNT ON;
		SELECT @lMID = MID from tblModule WHERE ModuleCode = 'LeAP'
		SET @lTimeStamp = GETDATE();


	IF @pOption = 1 -- Get Summited Leaved Data for calendar data
		BEGIN
			SELECT @lRanking = EmployeeGroup, @lDepartmentCode = DepartmentCode, @lUnitCode = UnitCode, @lCostCenter = CostCenter  FROM tblHR_PersonnelMaster WHERE UserName = @pUserName

			SELECT A.IDNumber,A.UserName,A.Position,A.DepartmentCode,A.UnitCode,A.CostCenter,B.LeaveCode,B.DTLeave,B.LeaveReason,B.LeaveCode +' - ' + A.UserName AS USELEAVED
				FROM tblHR_PersonnelMaster A 
				INNER JOIN tblHR_PersonnelLeaves B ON A.IDNumber = B.IDNumber
				WHERE  A.DepartmentCode =@lDepartmentCode AND CostCenter = @lCostCenter
				

		END
	IF @pOption = 2 -- GET TEAM DATA
		BEGIN
			DECLARE @WeekStart DATE = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE));
			DECLARE @WeekEnd   DATE = DATEADD(DAY, 7, @WeekStart);

			SELECT 
				@lRanking = EmployeeGroup,
				@lDepartmentCode = DepartmentCode,
				@lUnitCode = UnitCode,
				@lCostCenter = CostCenter
			FROM tblHR_PersonnelMaster 
			WHERE UserName = @pUserName;

			SELECT 
				A.EmployeeGroup AS Ranking,
				A.IDNumber,
				A.UserName,
				A.LastName,
				A.FirstName,
				A.Position,
				A.SchedCode,

				ISNULL(B.VLTotalThisWeek, 0) AS VLTotalThisWeek,
				ISNULL(B.SLTotalThisWeek, 0) AS SLTotalThisWeek,
				ISNULL(C.OBTotalThisWeek, 0) AS OBTotalThisWeek,

				ISNULL(D.InTotalThisWeek, 0) AS InTotalThisWeek,
				ISNULL(D.LateTotalThisWeek, 0) AS LateTotalThisWeek

			FROM tblHR_PersonnelMaster A

			/* LEAVES */
			LEFT JOIN (
				SELECT 
					IDNumber,
					SUM(CASE WHEN LeaveCode = 'VL' THEN NumHours ELSE 0 END) AS VLTotalThisWeek,
					SUM(CASE WHEN LeaveCode = 'SL' THEN NumHours ELSE 0 END) AS SLTotalThisWeek
				FROM tblHR_PersonnelLeaves
				WHERE DTLeave >= @WeekStart
				  AND DTLeave <  @WeekEnd
				GROUP BY IDNumber
			) B ON A.IDNumber = B.IDNumber

			/* OFFICIAL BUSINESS */
			LEFT JOIN (
				SELECT 
					IDNumber,
					SUM(NumHours) AS OBTotalThisWeek
				FROM tblLEAPOfficialBusiness
				WHERE OBFrom >= @WeekStart
				  AND OBTo <  @WeekEnd
				GROUP BY IDNumber
			) C ON A.IDNumber = C.IDNumber

			/* IN / OUT + WORK HOURS */
			LEFT JOIN (
				SELECT
					X.IDNumber,

					CAST(SUM(X.WorkMinutes) / 60.0 AS DECIMAL(18,2)) AS InTotalThisWeek,

					CAST(
						SUM(CASE WHEN X.LateMinutes > 0 THEN X.LateMinutes ELSE 0 END) / 60.0
					AS DECIMAL(18,2)) AS LateTotalThisWeek

				FROM (
					SELECT
						D.IDNumber,
						D.WorkDate,
						D.FirstIn,
						D.LastOut,

						/* WORK MINUTES (SAFE + SCHEDULE BASED) */
						CASE 
							WHEN D.FirstIn IS NOT NULL AND ISNULL(D.LastOut, GETDATE()) IS NOT NULL
							THEN 
								DATEDIFF(
									MINUTE,
									CASE 
										WHEN D.FirstIn < DATEADD(MINUTE,
												DATEDIFF(MINUTE, 0, TRY_CAST(WS.FirstHalf AS TIME)),
												CAST(D.WorkDate AS DATETIME))
										THEN DATEADD(MINUTE,
												DATEDIFF(MINUTE, 0, TRY_CAST(WS.FirstHalf AS TIME)),
												CAST(D.WorkDate AS DATETIME))
										ELSE D.FirstIn
									END,
									CASE 
										WHEN ISNULL(D.LastOut, GETDATE()) > DATEADD(MINUTE,
												DATEDIFF(MINUTE, 0, TRY_CAST(WS.SecondHalf AS TIME)),
												CAST(D.WorkDate AS DATETIME))
										THEN DATEADD(MINUTE,
												DATEDIFF(MINUTE, 0, TRY_CAST(WS.SecondHalf AS TIME)),
												CAST(D.WorkDate AS DATETIME))
										ELSE ISNULL(D.LastOut, GETDATE())
									END
								)
							ELSE 0
						END AS WorkMinutes,

						/* LATE MINUTES (SAFE CONVERSION) */
						CASE 
							WHEN D.FirstIn >
								 DATEADD(
									MINUTE,
									DATEDIFF(MINUTE, 0, TRY_CAST(WS.FirstHalf AS TIME)),
									CAST(D.WorkDate AS DATETIME)
								 )
							THEN DATEDIFF(
									MINUTE,
									DATEADD(
										MINUTE,
										DATEDIFF(MINUTE, 0, TRY_CAST(WS.FirstHalf AS TIME)),
										CAST(D.WorkDate AS DATETIME)
									),
									D.FirstIn
								 )
							ELSE 0
						END AS LateMinutes

					FROM (
						SELECT
							R.IDNumber,
							CAST(R.TimeInOut AS DATE) AS WorkDate,

							MIN(CASE WHEN R.InOutStatus = 'IN' THEN R.TimeInOut END) AS FirstIn,
							MAX(CASE WHEN R.InOutStatus = 'OUT' THEN R.TimeInOut END) AS LastOut

						FROM tblLEAPInOutRecords R
						WHERE R.TimeInOut >= @WeekStart
						  AND R.TimeInOut <  @WeekEnd
						GROUP BY
							R.IDNumber,
							CAST(R.TimeInOut AS DATE)
					) D

					INNER JOIN tblHR_PersonnelMaster PM
						ON PM.IDNumber LIKE '%' + D.IDNumber + '%'

					INNER JOIN tblHR_WorkSchedule WS
						ON WS.SchedCode = PM.SchedCode

					WHERE D.FirstIn IS NOT NULL

				) X

				GROUP BY X.IDNumber

			) D ON A.IDNumber LIKE '%' + D.IDNumber + '%'

			WHERE 
				A.DTSeparated IS NULL 
				AND A.DepartmentCode = @lDepartmentCode
				AND A.UnitCode = @lUnitCode 
				AND A.CostCenter = @lCostCenter 
				AND A.EmployeeGroup >= @lRanking

			ORDER BY Ranking;
		END
	IF @pOption = 3 -- SAVE IN OUT DATA
		BEGIN

			INSERT INTO tblLEAPInOutRecords (ServerID,IDNumber,InOutStatus,TimeInOut)
			SELECT ServerID,IDNumber,InOutStatus,TimeInOut FROM @pTypeLEAPInOutRecords
			
		END
	IF @pOption = 4 -- GET ALL LEAVE TYPE
		BEGIN			
			
			SELECT A.LeaveCode, A.LeaveDesc, A.AbsentType, A.ChargeToLeave, A.EndDate, A.FilingNotice, A.WithQuota, A.LeaveColor, A.DateSpecific
				   ,A.PeriodSpecific

					,CASE 
						WHEN A.PeriodSpecific = 1 THEN
							(SELECT TOP 1 RIGHT('0' + CAST(P.MonthStart AS VARCHAR(2)), 2)
								FROM tblHR_PeriodSchedule P
								WHERE MONTH(GETDATE()) BETWEEN P.MonthStart AND P.MonthEnd
							)
						ELSE NULL
					END AS PeriodFrom

					,CASE 
						WHEN A.PeriodSpecific = 1 THEN
							(SELECT TOP 1 RIGHT('0' + CAST(P.MonthEnd AS VARCHAR(2)), 2)
								FROM tblHR_PeriodSchedule P
								WHERE MONTH(GETDATE()) BETWEEN P.MonthStart AND P.MonthEnd
							)
						ELSE NULL
					END AS PeriodTo

				   ,A.ChargeToLeaveType
				   ,A.LastUpdateBy
				   ,A.DTModified
			FROM tblHR_AbsentType A
			WHERE (A.EndDate IS NULL OR CAST(GETDATE() AS DATE) <= A.EndDate)


			
		END
	IF @pOption = 5 -- GET ALL Department
		BEGIN
			SELECT DISTINCT DepartmentCode,DepartmentCode + ' - ' + DepartmentName AS Department FROM tblHR_DepartmentUnit
		END
	IF @pOption = 6 -- GET ALL Section
		BEGIN
			IF @pDepartmentCode = NULL OR @pDepartmentCode = ''
				BEGIN 
					SELECT DISTINCT DepartmentCode,UnitCode,UnitCode + ' - ' + UnitName AS Section 
						FROM tblHR_DepartmentUnit
					--WHERE DepartmentCode = @pDepartmentCode
				END
			ELSE 
				BEGIN 
					SELECT DISTINCT DepartmentCode,UnitCode,UnitCode + ' - ' + UnitName AS Section 
					FROM tblHR_DepartmentUnit
					WHERE DepartmentCode = @pDepartmentCode
				END
			
		END
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
				END AS IsCovered




			INTO #tmpTblQuota
			FROM tblHR_PersonnelMaster A
			CROSS JOIN @pTypeHRMLQLeaveTypes C
			LEFT JOIN tblHR_PersonnelLeaveBalance B
				ON A.IDNumber = B.IDNumber AND B.LeaveCode = C.LeaveType AND B.DTFrom <= @lEndOfYear AND B.DTTo   >= @lStartOfYear
			WHERE A.DTSeparated IS NULL
			AND (A.DepartmentCode = @pDepartmentCode AND A.UnitCode LIKE '%' + @pUnitCode + '%')

			-- Department filter
			AND ( ISNULL(@pDepartmentCode, '') = '' OR A.DepartmentCode = @pDepartmentCode )
			-- Unit filter
			AND ( ISNULL(@pUnitCode, '') = '' OR A.UnitCode LIKE '%' + @pUnitCode + '%' )
			-- BL LeaveType Birthdate validation
			AND (C.LeaveType <> 'BL' OR MONTH(A.DTBirth) BETWEEN MONTH(@lStartOfYear) AND MONTH(@lEndOfYear) )


		----------------------------------------------WITH QUOTA
			SELECT UserName, IDNumber, EmployeeName, Position, DepartmentCode, UnitCode, CostCenter,Quota

			FROM #tmpTblQuota
			GROUP BY UserName, IDNumber, EmployeeName,
				Position, DepartmentCode, UnitCode, CostCenter,Quota,IsCovered
			HAVING  SUM(IsCovered) = COUNT(*)   

		----------------------------------------------WITHOUT QUOTA

			SELECT UserName, IDNumber, EmployeeName, Position, DepartmentCode, UnitCode, CostCenter,Quota

			FROM #tmpTblQuota
			GROUP BY UserName, IDNumber, EmployeeName,
				Position, DepartmentCode, UnitCode, CostCenter,Quota
			HAVING SUM(IsCovered) < COUNT(*)

			select * from #tmpTblQuota
			DROP TABLE IF EXISTS #tmpTblQuota

		END
	IF @pOption = 8 -- GET User Info  
		BEGIN
			SELECT UserName,IDNumber,LastName+', '+FirstName As EmployeeName,Position,DTBirth,DepartmentCode,UnitCode,CostCenter
			FROM tblHR_PersonnelMaster
			WHERE UserName = @pUserName
		END
	IF @pOption = 9 -- GET Applied Leaves Per User for Leave Monitoring
		BEGIN
			IF @pDTApplied IS NULL OR @pDTApplied = ''
				BEGIN
					--SET @pDTApplied = CONVERT(VARCHAR(10), DATEFROMPARTS(YEAR(GETDATE()) , 1, 1), 101)
					SET @pDTApplied = YEAR(GETDATE());
				END
			ELSE
				BEGIN
					--SET @pDTApplied = CONVERT(VARCHAR(10), DATEFROMPARTS(YEAR(@pDTApplied), 1, 1), 101)
					SET @pDTApplied = YEAR(@pDTApplied);

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
				Remarks, 
				CASE WHEN STAT = 'FA' THEN 'FOR APPROVAL' 
				WHEN STAT = 'CNL' THEN 'CANCELLED'
				WHEN STAT = 'RJCT' THEN 'REJECTED'
				WHEN STAT = 'APPRVD' THEN 'APPROVED' END AS 'Status'
				, Posted, ISNULL(CONVERT(VARCHAR,DTPosted,101),'') AS DTPosted
				, A.NumHours 
				,NULL AS AGHID
				INTO #TempHRAppliedLeaved
				FROM tblHR_PersonnelLeaves A
				INNER JOIN tblHR_PersonnelLeaveApproval B ON  A.IDNumber = B.IDNumber AND A.TransID = B.TransID 
				INNER JOIN tblHR_AbsentType C ON C.LeaveCode = A.LeaveCode 
				LEFT JOIN @tbl D ON D.Applvl = B.APPLVL 
				WHERE A.IDNumber = @lIDNumber 


			INSERT INTO #TempHRAppliedLeaved
			SELECT A.TransID,A.IDNumber,A.LeaveCode,B.LeaveDesc
			,ISNULL(CONVERT(VARCHAR,A.DTLeave,101),'') AS DTLeave
			,A.LeaveHourFrom,A.LeaveHourTo
			,ISNULL(CONVERT(VARCHAR,A.DTApplied,101),'') AS DTApplied
			,A.LeaveReason
			,''
			,''
			,''
			,'',A.Posted
			,ISNULL(CONVERT(VARCHAR,A.DTPosted,101),'') AS DTPosted
			,A.NumHours
			,AGHID
			FROM tblHR_PersonnelLeaves A 
			LEFT JOIN tblHR_AbsentType B ON A.LeaveCode = B.LeaveCode
			WHERE A.IDNumber = @lIDNumber AND year(A.DTApplied) > '2025'
			AND year(A.DTApplied) = @pDTApplied

			DECLARE @TypeAAMAGHID TypeAAMAGHID 
			INSERT INTO @TypeAAMAGHID (AGHID)
			SELECT AGHID  FROM tblHR_PersonnelLeaves  WHERE IDNumber = @lIDNumber AND AGHID IS NOT NULL

			-- LATEST AAM APPROVER
			INSERT INTO #tmpApprovers  (AHID,AGHID,AGDID,AID,ADID,ApproverName,ApprovalLevel,PRIMARYID, StatusID, PrevStatsID, Active, TableName,TableDescription, Remarks, ALHID, A_UpdatedBy, A_DTUpdated)
			EXEC spAAMProcess  @pOption = 17, @pTypeAGHID = @TypeAAMAGHID
			--SELECT * FROM  #tmpApprovers

			SELECT  A.TransID,A.IDNumber,A.DTLeave,A.LeaveCode,A.LeaveDesc,A.LeaveHourFrom,A.LeaveHourTo,A.DTApplied,A.LeaveReason

			,CASE WHEN A.AGHID IS NULL THEN A.LeaveStatus
				ELSE (SELECT TOP 1 R.RValue FROM #tmpApprovers T JOIN tblReferenceMaster R ON T.StatusID = R.RID WHERE T.AGHID = A.AGHID ORDER BY T.A_DTUpdated DESC )
			END AS LeaveStatus

			,CASE WHEN A.AGHID IS NULL THEN A.Approver
				ELSE (SELECT STRING_AGG( 'L' + CAST( T.ApprovalLevel AS VARCHAR(10))  + ' - ' + T.ApproverName,  ', ' ) FROM #tmpApprovers T WHERE AGHID = A.AGHID )
			END AS Approver

			,CASE WHEN A.AGHID IS NULL THEN A.REMARKS
				ELSE ( SELECT STRING_AGG( 'L' + CAST(T.ApprovalLevel AS VARCHAR(10))  + ' - ' + T.Remarks,  ', ' ) FROM #tmpApprovers T WHERE AGHID = A.AGHID )
			END AS Remarks

			,A.Status
			,A.Posted,A.DTPosted,A.NumHours,A.AGHID
			FROM #TempHRAppliedLeaved A 
				WHERE YEAR(A.DTApplied) =  @pDTApplied

			
		END
		
/*  

EXEC spLEAP @pOption = 2  ,@pUserName = 'cooreto' ,@pDTApplied ='2025'


EXEC spLEAP @pOption = 9 , @pUserName = 'cooreto',@pDTApplied ='2025'   

EXEC spLEAP @pOption = 10 , @pUserName = 'cooreto',@pDTApplied ='2026',@pLeaveCode ='VL'

*/
	IF @pOption = 10 -- GET Leave Balance per LeaveCode 
		BEGIN
			IF @pIDNumber IS NULL OR @pIDNumber = ''
				BEGIN
					SET @pIDNumber = (SELECT top 1 IDNumber FROM tblHR_PersonnelMaster WHERE UserName = @pUserName AND DTSeparated is null)
				END

			IF @pDTApplied IS NULL or @pDTApplied = ''
				BEGIN
					SET @pDTApplied = year(GETDATE())
				END
			
			IF EXISTS (SELECT A.LeaveCode
						FROM tblHR_PersonnelLeaveBalance A
						JOIN tblHR_AbsentType B ON B.LeaveCode = A.LeaveCode
				   WHERE IDNumber = @pIDNumber
					 AND A.LeaveCode = @pLeaveCode AND ( B.EndDate IS NULL OR GETDATE() < B.EndDate ))
				BEGIN
					SELECT a.LeaveCode, b.LeaveDesc, CONVERT(VARCHAR,a.DTFrom,101) AS DTFrom, CONVERT(VARCHAR,a.DTTo,101) AS DTTo, 
					  a.Quota, a.LeaveBalance, CONVERT(VARCHAR,a.AppliedLeave,101) AS AppliedLeave, a.ForPosting, a.LeaveUsed, 
							 a.Locked, a.LockedBy, a.LockedOn,b.Datespecific,A.LeaveBalanceID,b.ChargeToLeave
					  FROM tblHR_PersonnelLeaveBalance a LEFT JOIN tblHR_AbsentType b ON a.LeaveCode = b.LeaveCode 
					  WHERE a.IDNumber = @pIDNumber AND year(DTFROM) = @pDTApplied AND A.LeaveCode = @pLeaveCode
				END
			ELSE 
				BEGIN
					--RAISERROR('No leave authorized to the employee.',11,1)
					SELECT * FROM tblHR_AbsentType WHERE  ChargeToLeave = 0
					AND LeaveCode = @pLeaveCode

				END 
		END
	IF @pOption = 11 -- CANCEL LEAVE 
		BEGIN
			SELECT  * FROM tblHR_PersonnelLeaveBalance 
			WHERE IDNumber = @pIDNumber 
			--RAISERROR ('Goods', 16, 1);

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
			FROM tblLEAPLeaveReason WHERE LeaveCode = @pLeaveCode
		END
	IF @pOption = 13 -- GET ALL APPLIED LEAVE
		BEGIN
			IF @pDTApplied IS NULL or @pDTApplied = ''
				BEGIN
					SET @pDTApplied = year(GETDATE()) 
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

				-- Start Jake
				--IF @pActive = 0 
				--AND ( EXISTS ( SELECT 1  FROM tblHR_PersonnelLeaves  WHERE LeaveCode = @pLeaveCode AND DTApplied >= @lStartOfYear
				--		) OR EXISTS ( SELECT 1  FROM tblHR_PersonnelLeaveBalance  WHERE LeaveCode = @pLeaveCode AND DTFrom >= @lStartOfYear )
				--	)
				--BEGIN
				--	RAISERROR ( 'LeaveCode is already in use and cannot be deactivated because it has existing transactions.', 16, 1 );
				--	RETURN;
				--END
				-- End Jake


				-- =========================================
				-- MERGE STATEMENT
				-- =========================================
				MERGE tblHR_AbsentType AS TARGET
				USING ( 
					SELECT @pLeaveCode AS LeaveCode
				) AS SOURCE
				ON TARGET.LeaveCode = SOURCE.LeaveCode

				WHEN MATCHED THEN
					UPDATE SET  LeaveDesc = @pLeaveDesc,  AbsentType = @pAbsentType,  ChargeToLeave = @pChargeToLeave, EndDate = @pEndDate, 
						FilingNotice = @pFilingNotice, WithQuota = @pWithQuota, LeaveColor = @pLeaveColor, Datespecific = @pDateSpecific, 
						ChargeToLeaveType = @pChargeToLeaveType, PeriodSpecific = @pPeriodSpecific, LastUpdateBy = @pUserName, DTModified = GETDATE()

				WHEN NOT MATCHED THEN
					INSERT (
						LeaveCode, LeaveDesc, AbsentType, ChargeToLeave, EndDate, FilingNotice, WithQuota, 
						LeaveColor, Datespecific, ChargeToLeaveType, CreatedBy, DTCreted, PeriodSpecific
					)
					VALUES (
						@pLeaveCode, @pLeaveDesc, @pAbsentType, @pChargeToLeave, @pEndDate, @pFilingNotice, 
						@pWithQuota, @pLeaveColor, @pDateSpecific, @pChargeToLeaveType, @pUserName, GETDATE(), @pPeriodSpecific
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
	IF @pOption = 15 -- GET ALL tblLEAPLeaveReason
		BEGIN
			SELECT ReasonID,ReasonCode,ReasonDescription,NoticePeriod,Remarks,isActive,LeaveCode,DTCreated,CreatedBy,DTModified,LastUpdateBy 
			FROM tblLEAPLeaveReason

		END
	IF @pOption = 16 -- UPSERT FOR LEAVE REASON MAINTENANCE tblLEAPLeaveReason
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
				-- MERGE (UPSERT tblLEAPLeaveReason)
				-- =========================================
				MERGE dbo.tblLEAPLeaveReason AS TARGET
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

				IF ERROR_MESSAGE() LIKE '%FK_tblLEAPLeaveReason%'
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
			SELECT SchedCode,SchedDesc,FirstHalf,SecondHalf,WholeDay,isActive,CreatedBy,DTCreated,DTModified,LastUpdateBy
			FROM tblHR_WorkSchedule 

		END
	IF @pOption = 18 -- GET ALL tblHR_WorkScheduleRD
		BEGIN
			SELECT RDID,SchedCode,RestDay,CreatedBy,DTCreated,isActive,DTModified,LastUpdateBy --Jake ADD RDID
			FROM tblHR_WorkScheduleRD 
			WHERE SchedCode = @pSchedCode -- JAKE

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
				USING ( SELECT @pRDID AS RDID, @pSchedCode AS SchedCode, @pRestDay AS RestDay) AS SOURCE -- JAKE
				ON TARGET.RDID = SOURCE.RDID --Jake
				--TARGET.SchedCode = SOURCE.SchedCode
				--AND TARGET.RestDay = SOURCE.RestDay --JAKE

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
			SELECT HID,DTHoliday,Description,EncodedBy,DTime,LegalHoliday,Area,IsCheck  --Jake add HID
			FROM tblCCD_Holiday   
			WHERE DTHoliday >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)  
			ORDER BY DTHoliday   
		END   
	IF @pOption = 22 -- UPSERT tblCCD_Holiday need to fix  with bugs   
		BEGIN  
			BEGIN TRY  
		-- Jake Start
			MERGE tblCCD_Holiday AS target  
			USING ( SELECT @pHID AS HID) AS SOURCE  
			ON (target.HID = source.HID)  
  
			WHEN MATCHED THEN
				UPDATE SET 
					DTHoliday = @pDTHoliday, -- Now you can safely update the date itself
					Description = @pHolidayDescription,
					LegalHoliday = @pLegalHoliday,
					Area = @pArea,
					IsCheck = @pIsCheck,
					EncodedBy = @pUserName,
					DTime = GETDATE()

			WHEN NOT MATCHED THEN
				INSERT (DTHoliday, Description, EncodedBy, DTime, LegalHoliday, Area, IsCheck)
				VALUES (@pDTHoliday, @pHolidayDescription, @pUserName, GETDATE(), @pLegalHoliday, @pArea, @pIsCheck);  
			-- Jake End
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

			-- MAIN QUERY (Returns everything in a single consolidated result set)
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
				lv.ChargedToLeave, -- This column will determine Charge vs Not Charge

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
			--INTO #tempTblApprovedLeaves
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
				)
			ORDER BY lv.ChargedToLeave DESC, lv.DTApplied DESC; -- Keeps structure ordered natively

			--DROP TABLE #tempTblApprovedLeaves;
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
	IF @pOption = 26 -- Bulk Insert new leave quota MLQ 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION

				DECLARE lCur_LeaveBalance CURSOR FOR

					SELECT E.IDNumber, E.UserName, L.LeaveType, L.DTFrom, L.DTTo, L.Quota,
						   CONVERT(VARCHAR(10), L.DTFrom, 120) + ' to ' + CONVERT(VARCHAR(10), L.DTTo, 120) AS Periods
					FROM @pTypeHRMLQSelectedEmployee E
					CROSS JOIN @pTypeHRMLQLeaveTypes L

				OPEN lCur_LeaveBalance

				FETCH NEXT FROM lCur_LeaveBalance INTO
					@lIDNumber, @lUserName, @lLeaveCode, @lDTFrom, @lDTTo, @lQuota,@lPeriods

				WHILE @@FETCH_STATUS = 0
				BEGIN

					IF EXISTS (	SELECT 1
								FROM tblHR_PersonnelLeaveBalance
								WHERE IDNumber = @lIDNumber
								AND LeaveCode = @lLeaveCode
								AND DTFrom = @lDTFrom
								AND DTTo = @lDTTo )
					BEGIN
					SET @lDTFromStr = CONVERT(VARCHAR(10), @lDTFrom, 120)
					SET @lDTToStr   = CONVERT(VARCHAR(10), @lDTTo, 120)

						RAISERROR('Leave quota already exists. UserName : %s | LeaveCode : %s | DTFrom : %s | DTTo : %s',
								   16,
								   1,
								   @lUserName,
								   @lLeaveCode,
								   @lDTFromStr,
								   @lDTToStr)

					END
					    EXEC spLEAP @pOption = 37, @pIDNumber = @lIDNumber, @pLeaveCode = @lLeaveCode, @pDTFrom = @lDTFrom,@pDTTo = @lDTTo, @pUserName = @pUserName,@pLeaveBalance = @lQuota

					INSERT INTO tblHR_PersonnelLeaveBalance (IDNumber  , LeaveCode  , DTFrom  , DTTo  , Quota             , LeaveBalance      , AppliedLeave, ForPosting, LeaveUsed , Locked, LockedBy, LockedOn,DTCreated,CreatedBy )
													VALUES	(@lIDNumber, @lLeaveCode, @lDTFrom, @lDTTo, ISNULL(@lQuota, 0), ISNULL(@lQuota, 0), 0			, 0			, 0			, 0		, NULL	  , NULL	,GETDATE(),@pUserName )

					FETCH NEXT FROM lCur_LeaveBalance INTO
						@lIDNumber, @lUserName, @lLeaveCode, @lDTFrom, @lDTTo, @lQuota,@lPeriods

				END

				CLOSE lCur_LeaveBalance
				DEALLOCATE lCur_LeaveBalance

				COMMIT TRANSACTION

			END TRY

			BEGIN CATCH

				IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION

				IF CURSOR_STATUS('local', 'lCur_LeaveBalance') >= -1
				BEGIN
					CLOSE lCur_LeaveBalance
					DEALLOCATE lCur_LeaveBalance
				END

				SELECT
					@lErrorMessage = ERROR_MESSAGE(),
					@lErrorLine = ERROR_LINE()

				RAISERROR( 'Error inserting leave balance. Line: %d | Message: %s', 16, 1, @lErrorLine, @lErrorMessage )

			END CATCH

		END
	IF @pOption = 27 -- UPDATE MLQ Leave Balance 
		BEGIN	
			UPDATE tblHR_PersonnelLeaveBalance SET DTFrom = @PDTFrom , DTTo = @pDTTo , Quota = @pQuota,LeaveBalance = (@pQuota - AppliedLeave + ForPosting), LastUpdateBy = @pUserName, DTModified = GETDATE()
			WHERE IDNumber = @pIDNumber AND LeaveCode = @pLeaveCode AND LeaveBalanceID = @pLeaveBalanceID
		END
	IF @pOption = 28 -- DELETE MLQ Leave Balanve
		BEGIN
			SET @lUserName =(SELECT LastName+', '+FirstName As EmployeeName FROM tblHR_PersonnelMaster WHERE IDNumber = @pIDNumber )
			SET @lLeaveUsed = (SELECT DISTINCT COUNT(A.LeaveBalanceid) FROM tblHR_PersonnelLeaveBalance A  
					JOIN tblHR_PersonnelLeaves B ON A.IDNumber = B.IDNumber AND A.LeaveCode = B.LeaveCode
					WHERE A.IDNumber = @pIDNumber
					AND A.LeaveCode = @pLeaveCode 
					AND B.DTApplied BETWEEN @PDTFrom  AND @pDTTo)


			IF @lLeaveUsed >= 1
				BEGIN
						RAISERROR('Leave quota is already used by UserName : %s cannot be deleted.',
								   16,
								   1,
								   @lUserName)
				END
			ELSE
				BEGIN
					DELETE tblHR_PersonnelLeaveBalance WHERE IDNumber = @pIDNumber AND LeaveCode = @pLeaveCode AND LeaveBalanceID = @pLeaveBalanceID
				END
		END
	IF @pOption = 29 -- Bulk delete leave quota MLQ
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION

				DECLARE @lErrorUsers VARCHAR(MAX)

				DECLARE lCur_LeaveBalance CURSOR FOR

					SELECT E.IDNumber, E.UserName, L.LeaveType, L.DTFrom, L.DTTo
					FROM @pTypeHRMLQSelectedEmployee E
					CROSS JOIN @pTypeHRMLQLeaveTypes L

				OPEN lCur_LeaveBalance

				FETCH NEXT FROM lCur_LeaveBalance INTO
					@lIDNumber, @lUserName, @lLeaveCode, @lDTFrom, @lDTTo

				WHILE @@FETCH_STATUS = 0
				BEGIN

					SET @lLeaveUsed = (
										SELECT COUNT(A.LeaveBalanceID)
										FROM tblHR_PersonnelLeaveBalance A
										JOIN tblHR_PersonnelLeaves B
											ON A.IDNumber = B.IDNumber
											AND A.LeaveCode = B.LeaveCode
										WHERE A.IDNumber = @lIDNumber
										AND A.LeaveCode = @lLeaveCode
										AND B.DTApplied BETWEEN @lDTFrom AND @lDTTo
										)

					IF @lLeaveUsed >= 1
					BEGIN

						SET @lErrorUsers = ISNULL(@lErrorUsers + CHAR(10), '') +
										   'UserName : ' + @lUserName +
										   ' | LeaveCode : ' + @lLeaveCode

					END
					ELSE
					BEGIN

						DELETE tblHR_PersonnelLeaveBalance
						WHERE IDNumber = @lIDNumber
						AND LeaveCode = @lLeaveCode
						AND DTFrom = @lDTFrom
						AND DTTo = @lDTTo

						DELETE tblEarnedLeaveQuota WHERE IDNumber = @lIDNumber
						AND LeaveCode = @lLeaveCode AND YearValid = YEAR(@lDTFrom)

					END

					FETCH NEXT FROM lCur_LeaveBalance INTO
						@lIDNumber, @lUserName, @lLeaveCode, @lDTFrom, @lDTTo

				END

				CLOSE lCur_LeaveBalance
				DEALLOCATE lCur_LeaveBalance

				IF ISNULL(@lErrorUsers, '') <> ''
				BEGIN
				SET @lErrorMessage = 'Leave quota cannot be deleted because it is already used.'
					+ CHAR(10)
					+ @lErrorUsers

				RAISERROR(@lErrorMessage, 16, 1)

				END

				COMMIT TRANSACTION

			END TRY

			BEGIN CATCH

				IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION

				IF CURSOR_STATUS('local', 'lCur_LeaveBalance') >= -1
				BEGIN
					CLOSE lCur_LeaveBalance
					DEALLOCATE lCur_LeaveBalance
				END

				SELECT
					@lErrorMessage = ERROR_MESSAGE(),
					@lErrorLine = ERROR_LINE()

				RAISERROR(
					'Error deleting leave balance. Line: %d | Message: %s',
					16,
					1,
					@lErrorLine,
					@lErrorMessage
				)

			END CATCH

		END
	IF @pOption = 30 -- GET WorkSchedule AND RD per employee
		BEGIN
			--SELECT * --SchedCode,RestDay,CreatedBy,DTCreated,isActive,DTModified,LastUpdateBy 
			--FROM tblHR_WorkSchedule	

			SELECT B.SchedCode,A.IDNumber,B.WholeDay,B.FirstHalf,B.SecondHalf
			FROM tblHR_PersonnelMaster A  
			JOIN tblHR_WorkSchedule B ON A.SchedCode = B.SchedCode
			WHERE A. UserName = @pUserName


			SELECT STRING_AGG(B.RestDay, ',') AS RestDays, COUNT(B.RestDay) as NoOffRestDays
			FROM tblHR_PersonnelMaster A
			JOIN tblHR_WorkScheduleRD B 
				ON A.SchedCode = B.SchedCode
			WHERE A.UserName = @pUserName
					   
		END
	IF @pOption = 31 -- GET FILEPATH
		BEGIN
			SELECT Value FROM tblConfiguration_ActivePath WHERE Category = 'LEAP' AND CODE = @pPathCode
			--SELECT * FROM tblConfiguration_ArchivePath WHERE Category = 'LEAP' AND CODE ='LEAPUPLOAD'

		END
	IF @pOption = 32 -- LEAVE SAVE FOR APPROVAL
		BEGIN
			IF EXISTS ( SELECT 1 FROM tblHR_AbsentType A WHERE A.PeriodSpecific = 1 AND A.LeaveCode IN (SELECT LeaveType FROM @pTypeLeaveForApproval) )
				BEGIN
					DECLARE @LeaveSummary TABLE
					(
						IDNumber VARCHAR(10),
						LeaveCode VARCHAR(10),
						YearValid INT,
						LeaveTotalBalance DECIMAL(18,2),
						CurrentAccumulatedBalance DECIMAL(18,2),
						totalleaveused DECIMAL(18,2)
					);

					INSERT INTO @LeaveSummary
					SELECT 
						Q.IDNumber,
						Q.LeaveCode,
						Q.YearValid,
						Q.LeaveTotalBalance,

						( ISNULL(Q.January,0) +
							CASE WHEN MONTH(GETDATE()) >= 2 THEN ISNULL(Q.February,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 3 THEN ISNULL(Q.March,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 4 THEN ISNULL(Q.April,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 5 THEN ISNULL(Q.May,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 6 THEN ISNULL(Q.June,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 7 THEN ISNULL(Q.July,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 8 THEN ISNULL(Q.August,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 9 THEN ISNULL(Q.September,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 10 THEN ISNULL(Q.October,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 11 THEN ISNULL(Q.November,0) ELSE 0 END +
							CASE WHEN MONTH(GETDATE()) >= 12 THEN ISNULL(Q.December,0) ELSE 0 END
						),

						ISNULL(L.totalleaveused,0)

					FROM tblEarnedLeaveQuota Q
					LEFT JOIN (
						SELECT  
							LeaveType,
							SUM(CAST(WorkHrs AS DECIMAL(18,2))) AS totalleaveused
						FROM @pTypeLeaveForApproval
						GROUP BY LeaveType
					) L ON L.LeaveType = Q.LeaveCode;


					-- VALIDATION
					IF EXISTS (
						SELECT 1
						FROM @LeaveSummary
						WHERE totalleaveused > CurrentAccumulatedBalance
					)
					BEGIN
						DECLARE @used DECIMAL(18,2),
								@avail DECIMAL(18,2),
								@leavecode VARCHAR(10);

						SELECT TOP 1
							@used = totalleaveused,
							@avail = CurrentAccumulatedBalance,
							@leavecode = LeaveCode
						FROM @LeaveSummary
						WHERE totalleaveused > CurrentAccumulatedBalance;


					SET @msg = 'Insufficient leave balance for LeaveCode ' + @leavecode +
							   '. Used: ' + CAST(@used AS VARCHAR(20)) +
							   ' |Earned Available: ' + CAST(@avail AS VARCHAR(20));

					RAISERROR(@msg, 16, 1);
						RETURN;
					END;

					-- SUCCESS OUTPUT
					SELECT *
					FROM @LeaveSummary;
				END
			ELSE
				BEGIN


	----------------------------------------- if goods ---------------------------
				CREATE TABLE #AAMProcessResultsLeave
				(AHID INT,AID BIGINT ,ADID INT,AGHID BIGINT,AGDID BIGINT,PRIMARYID INT);

				BEGIN TRY
					BEGIN TRANSACTION;
				
					IF CURSOR_STATUS('local', 'LeaveCursor') >= -1
						BEGIN
							CLOSE LeaveCursor;
							DEALLOCATE LeaveCursor;
						END

					DECLARE LeaveCursor CURSOR LOCAL FAST_FORWARD FOR
						SELECT LeaveType,DTLeave,LeaveHrsFrom,LeaveHrsTo,WorkHrs,ReasonCode,DTNotice,FileNotice,ReasonDesc
						FROM @pTypeLeaveForApproval;


					OPEN LeaveCursor;

					FETCH NEXT FROM LeaveCursor INTO
						 @lLeaveType
						,@lDTLeave
						,@lLeaveHrsFrom
						,@lLeaveHrsTo
						,@lWorkHrs
						,@lReasonCode
						,@lDTNotice
						,@lFileNotice
						,@lReasonDesc;

					WHILE @@FETCH_STATUS = 0
						BEGIN

							SET @lAddmsg =
									'LeaveType : ' + ISNULL(@lLeaveType,'')
								+ ' | Date Leave : ' + ISNULL(CONVERT(VARCHAR,@lDTLeave,101),'')

							BEGIN TRY
								BEGIN TRAN;

								EXEC spActivityLogs
									 @pButtonName    = @pActivity,
									 @pErrorMessage  = @lmsg,
									 @pModuleID      = @pModuleID,
									 @pUser          = @pUserName,
									 @pTimeStamp     = @lTimeStamp,
									 @pAdditionalMsg = @lAddmsg,
									 @pTransactional = 1;

								SET @lAHID = @@IDENTITY;


								SELECT @lStatusID = RID ,@lStatus = RValue
								FROM tblReferenceMaster
								WHERE MID = @lMID AND RCode = 'FOR APPROVAL' AND RCategory = 'HR'

								/*
									SAVE STAGING HEADER
								*/
	/*	


	SELECT * FROM tblHR_PersonnelLeaveBalance WHERE IDNumber ='00002536' AND LeaveCode = 'BL'  AND GETDATE() BETWEEN DTFrom AND DTTo
	select  top 10 * from tblHR_PersonnelLeaves  where IDNumber ='00002536' order by  TransID  desc
	select  top 100 * from tblHR_PersonnelLeaveBalance where IDNumber ='00002536'

	sp_help tblHR_PersonnelLeaves
	*/

			SELECT @lLeaveBalance=LeaveBalance  FROM tblHR_PersonnelLeaveBalance WHERE IDNumber = @pIDNumber AND LeaveCode = @lLeaveType AND @lTimeStamp BETWEEN DTFrom AND DTTo
			SELECT @lChargeToLeave = ChargeToLeave,@lAbsentType = AbsentType  FROM tblHR_AbsentType WHERE LeaveCode = @lLeaveType 
			SELECT @lReasonDefinition = ReasonDescription FROM tblLEAPLeaveReason WHERE ReasonCode = @lReasonCode

			INSERT INTO tblHR_PersonnelLeaves
			(IDNumber	,LeaveCode	,DTApplied	,BalanceBefore,BalanceAfter ,LeaveHourFrom ,LeaveHourTo ,DTLeave	,NumHours	
			,ReasonCode	 ,WithNotice,DTNotice	,NoticeFileName	,LeaveReason ,ChargedToLeave,AbsentType)
			VALUES
			(@pIDNumber	,@lLeaveType,@lTimeStamp,@lLeaveBalance,(@lLeaveBalance - @lWorkHrs),@lLeaveHrsFrom,@lLeaveHrsTo,@lDTLeave	,@lWorkHrs	
			,@lReasonCode,'1'		,@lDTNotice	,@lFileNotice	,@lReasonDesc,@lChargeToLeave,@lAbsentType);

								SET @lID = SCOPE_IDENTITY();

								/*
									GET AAM CATEGORY
								*/

								SELECT @lCID = CID
								FROM tblAAMCategory
								WHERE Code = 'LEAVE'


				SELECT @pUnitCode = UnitCode FROM tblHR_PersonnelMaster where UserName = @pUserName

								DELETE @lTypeAAMAD

			INSERT INTO @lTypeAAMAD
			( ModuleName ,CID	,ID		,TableID ,SubCategory ,SubCategoryValue	,ALHID ,CurrentStat ,PrevStat ,TableName				,CreatedBy ,Reason		,RequestColumn ,ExpirationDate )
			VALUES
			( 'LeAP'	 ,@lCID	,@lID	,@lID	 ,'Department',@pUnitCode				,@lAHID,@lStatusID  ,0		  ,'tblHR_PersonnelLeaves'	,@pUserName ,@lReasonDesc ,'StatusID'	  ,NULL );

			-- For Attachments insert
			INSERT INTO @lTypeAAMAttchmnts (TableID	,Category	,Code	,PrimaryFile, FileName		, FilePath)
									SELECT  @lID	,Category	,Code	,1			,@lFileNotice	,'Leave Application files/'+ @lLeaveType+'/'
								FROM tblConfiguration_ActivePath 
									WHERE Category = 'LEAP' AND Code ='LeaveApp'
								/*
									PROCESS AAM
								*/

								INSERT INTO #AAMProcessResultsLeave ( AHID ,AID ,ADID ,AGHID ,AGDID ,PRIMARYID )
								EXEC spAAMProcess
									 @pOption = 9,
									 @pTypeAD = @lTypeAAMAD,
									 @pTypeAttachments = @lTypeAAMAttchmnts

								SELECT @lAGHID = AGHID
								FROM #AAMProcessResultsLeave;

								IF @lAGHID IS NULL
									BEGIN
										RAISERROR ('No AAM defined.',11,1);
									END
								ELSE
									BEGIN

										UPDATE tblHR_PersonnelLeaves
										SET AGHID = @lAGHID
										WHERE TransID = @lID

										/*
											UPDATE BALANCE (FOR ACCUMULATE APPLIED LEAVE)
										*/

										UPDATE tblHR_PersonnelLeaveBalance 
										SET AppliedLeave = ISNULL(AppliedLeave,0) + ISNULL(@lWorkHrs,0),
											LeaveBalance = LeaveBalance - ISNULL(@lWorkHrs,0)
										WHERE IDNumber = @pIDNumber 
										AND LeaveCode = @lLeaveType 
										AND @lTimeStamp BETWEEN DTFrom AND DTTo

										/*
											EMAIL BODY
										*/

										SELECT 
										@lLeaveType =  LeaveCode
										,@lDTLeave = DTLeave
										,@lWorkHrs = NumHours
										,@lReasonCode = ReasonCode
										,@lDTNotice = DTNotice
										,@lFileNotice = NoticeFileName
										,@lReasonDesc = LeaveReason
										FROM tblHR_PersonnelLeaves 
										WHERE AGHID = @lAGHID

										SET @ltableHTML =
											'<table cellpadding="4" cellspacing="0" width="100%"
															style="border-collapse:collapse;font-family:Arial;font-size:12px;">'

														+ '<tr style="background-color:#E6E6E6;">'
														+ '<td colspan="2"
															style="border:1px solid #000;
															font-weight:bold;
															color:#02075D;">'
														+ 'Leave Application Details'
														+ '</td>'
														+ '</tr>'

														+ '<tr>'
														+ '<td style="border:1px solid #000;"><b>Leave Type</b></td>'
														+ '<td style="border:1px solid #000;">' + ISNULL(@lLeaveType,'') + '</td>'
														+ '</tr>'

														+ '<tr>'
														+ '<td style="border:1px solid #000;"><b>Date Leave</b></td>'
														+ '<td style="border:1px solid #000;">' + ISNULL(FORMAT(@lDTLeave,'MM/dd/yyyy'),'') + '</td>'
														+ '</tr>'

														+ '<tr>'
														+ '<td style="border:1px solid #000;"><b>Work Hours</b></td>'
														+ '<td style="border:1px solid #000;">' + CAST(@lWorkHrs AS VARCHAR) + '</td>'
														+ '</tr>'

														+ '<tr>'
														+ '<td style="border:1px solid #000;"><b>Reason</b></td>'
														+ '<td style="border:1px solid #000;">' + ISNULL(@lReasonCode+' - '+@lReasonDefinition,'') + '</td>'
														+ '</tr>'

														+ '<tr>'
														+ '<td style="border:1px solid #000;"><b>Notice Date</b></td>'
														+ '<td style="border:1px solid #000;">' + ISNULL(FORMAT(@lDTNotice,'MM/dd/yyyy hh:mm:ss tt'),'') + '</td>'
														+ '</tr>'

														+ '<tr>'
														+ '<td style="border:1px solid #000;"><b>Attachment</b></td>'
														+ '<td style="border:1px solid #000;">' + ISNULL(@lFileNotice,'') + '</td>'
														+ '</tr>'

														+ '<tr>'
														+ '<td style="border:1px solid #000;"><b>Reason Description</b></td>'
														+ '<td style="border:1px solid #000;">' + ISNULL(@lReasonDesc,'') + '</td>'
														+ '</tr>'

														+ '</table>';

										SET @ltableHTMLTotal += @ltableHTML;
										SET @ltableHTMLTotal += '<hr style="border:1px dashed #999; margin:20px 0;" />';

									END
								COMMIT TRAN;
							END TRY

							BEGIN CATCH

								IF @@TRANCOUNT > 0
									ROLLBACK TRANSACTION;

								SET @lmsg = ERROR_MESSAGE();

								EXEC spActivityLogs
									 @pButtonName    = @pActivity,
									 @pErrorMessage  = @lmsg,
									 @pModuleID      = @pModuleID,
									 @pUser          = @pUserName,
									 @pTimeStamp     = @lTimeStamp,
									 @pAdditionalMsg = @lAddmsg,
									 @pTransactional = 1;

								RAISERROR (@lmsg,16,1);

							END CATCH;

							FETCH NEXT FROM LeaveCursor INTO
								 @lLeaveType
								,@lDTLeave
								,@lLeaveHrsFrom
								,@lLeaveHrsTo
								,@lWorkHrs
								,@lReasonCode
								,@lDTNotice
								,@lFileNotice
								,@lReasonDesc;

						END

					CLOSE LeaveCursor
					DEALLOCATE LeaveCursor

				/*
					SEND EMAIL
				*/

				EXEC spAAMProcess
					 @pOption     = 40,
					 @pEmailBody  = @ltableHTMLTotal,
					 @pAGHID      = @lAGHID,
					 @pUser       = @pUserName,
					 @pStatus     = @lStatus,
					 @pTimeStamp  = @lTimeStamp;

					COMMIT TRANSACTION;
				END TRY
				BEGIN CATCH

					IF @@TRANCOUNT > 0
						ROLLBACK TRANSACTION;

					SET @msg = ERROR_MESSAGE();
					EXEC spActivityLogs
									 @pButtonName    = @pActivity,
									 @pErrorMessage  = @msg,
									 @pModuleID      = @pModuleID,
									 @pUser          = @pUserName,
									 @pTimeStamp     = @lTimeStamp,
									 @pAdditionalMsg = @lAddmsg,
									 @pTransactional = 1;

					RAISERROR (@msg,16,1);


				END CATCH

			END

		END
	IF @pOption = 33 -- GET ALL Leave Balance per user
		BEGIN
			IF @pIDNumber IS NULL OR @pIDNumber = ''
				BEGIN
					SET @pIDNumber = (SELECT top 1 IDNumber FROM tblHR_PersonnelMaster WHERE UserName = @pUserName AND DTSeparated is null)
				END

			IF @pDTApplied IS NULL or @pDTApplied = ''
				BEGIN
					SET @pDTApplied = year(GETDATE())
				END

			  SELECT a.LeaveCode, b.LeaveDesc, CONVERT(VARCHAR,a.DTFrom,101) AS DTFrom, CONVERT(VARCHAR,a.DTTo,101) AS DTTo, 
			  a.Quota, a.LeaveBalance, CONVERT(VARCHAR,a.AppliedLeave,101) AS AppliedLeave, a.ForPosting, a.LeaveUsed, 
					 a.Locked, a.LockedBy, a.LockedOn,b.Datespecific,A.LeaveBalanceID
			  FROM tblHR_PersonnelLeaveBalance a LEFT JOIN tblHR_AbsentType b ON a.LeaveCode = b.LeaveCode 
			  WHERE a.IDNumber = @pIDNumber AND year(DTFROM) = @pDTApplied 
		END
	IF @pOption = 34 -- OFFICIAL BUSINESS SAVE FOR APPROVAL
		BEGIN
			SELECT @lRanking = EmployeeGroup, @lDepartmentCode = DepartmentCode, @lUnitCode = UnitCode, @lCostCenter = CostCenter  FROM tblHR_PersonnelMaster WHERE UserName = @pUserName
			
			CREATE TABLE #AAMProcessResultsOB
			(
				AHID INT,
				AID BIGINT,
				ADID INT,
				AGHID BIGINT,
				AGDID BIGINT,
				PRIMARYID INT
			);

			BEGIN TRY
				BEGIN TRANSACTION;

				IF CURSOR_STATUS('local', 'OBCursor') >= -1
				BEGIN
					CLOSE OBCursor;
					DEALLOCATE OBCursor;
				END

				DECLARE OBCursor CURSOR LOCAL FAST_FORWARD FOR
					SELECT  TransID, IDNumber, Purpose, Attachment, Reason, Destination, OBFrom, OBTo, NumHours
					FROM @pTypeLEAPOfficialBusiness;

				OPEN OBCursor;

				FETCH NEXT FROM OBCursor INTO
					@lTransID, @lIDNumber, @lPurpose, @lAttachment, @lReason, @lDestination, @lOBFrom, @lOBTo, @lNumHours;

				WHILE @@FETCH_STATUS = 0
				BEGIN

					SET @lAddmsg =
						'Purpose : ' + ISNULL(@lPurpose,'')
						+ ' | From : ' + ISNULL(CONVERT(VARCHAR,@lOBFrom,101),'');

					BEGIN TRY
						BEGIN TRAN;

						EXEC spActivityLogs
							@pButtonName    = @pActivity,
							@pErrorMessage  = @lmsg,
							@pModuleID      = @pModuleID,
							@pUser          = @pUserName,
							@pTimeStamp     = @lTimeStamp,
							@pAdditionalMsg = @lAddmsg,
							@pTransactional = 1;

						SET @lAHID = @@IDENTITY;

						SELECT *
						FROM tblReferenceMaster
						WHERE MID = @lMID 
						AND RCode = 'FOR APPROVAL' 
						AND RCategory = 'HR';

						/*
							INSERT OFFICIAL BUSINESS
						*/
						INSERT INTO tblLEAPOfficialBusiness
	                      ( IDNumber   ,Purpose   ,Attachment  ,Reason   ,DTApplied   ,NumHours   ,Destination   ,OBFrom   ,OBTo )
						VALUES
	                      ( @lIDNumber ,@lPurpose ,@lAttachment,@lReason ,@lTimeStamp ,@lNumHours ,@lDestination ,@lOBFrom ,@lOBTo );

						SET @lID = SCOPE_IDENTITY();

						/*
							GET AAM CATEGORY
						*/
						SELECT @lCID = CID
						FROM tblAAMCategory
						WHERE Code = 'OfficialBusiness'

						DELETE @lTypeAAMAD;

							INSERT INTO @lTypeAAMAD
							( ModuleName ,CID	,ID		,TableID ,SubCategory ,SubCategoryValue	,ALHID ,CurrentStat ,PrevStat ,TableName				,CreatedBy  ,Reason		,RequestColumn ,ExpirationDate )
							VALUES
							( 'LEAP'	 ,@lCID	,@lID	,@lID	 ,'Department',@lUnitCode		,@lAHID,@lStatusID  ,0		  ,'tblLEAPOfficialBusiness',@pUserName ,@lReason	,'StatusID'	  ,NULL );


							select * from @lTypeAAMAD
						DELETE @lTypeAAMAttchmnts;

						INSERT INTO @lTypeAAMAttchmnts
							(TableID,Category,Code,PrimaryFile	,FileName		,FilePath)
						SELECT @lID	,Category,Code,1			,@lAttachment	,'Official Business files/'
						FROM tblConfiguration_ActivePath
							WHERE Category = 'LEAP'
						AND Code = 'OfficialBusinessApp';


						/*
							PROCESS AAM
						*/

						INSERT INTO #AAMProcessResultsOB
						(
							AHID, AID, ADID, AGHID, AGDID, PRIMARYID
						)
						EXEC spAAMProcess
							@pOption = 9,
							@pTypeAD = @lTypeAAMAD,
							@pTypeAttachments = @lTypeAAMAttchmnts;

						SELECT @lAGHID = AGHID
						FROM #AAMProcessResultsOB;

						IF @lAGHID IS NULL
						BEGIN
							RAISERROR ('No AAM defined.',11,1);
						END
						ELSE
						BEGIN

							UPDATE tblLEAPOfficialBusiness
							SET AGHID = @lAGHID
							WHERE TransID = @lID;

							/*
								EMAIL BODY
							*/
							SELECT 
								@lPurpose = Purpose,
								@lAttachment = Attachment,
								@lReason = Reason,
								@lDestination = Destination,
								@lOBFrom = OBFrom,
								@lOBTo = OBTo,
								@lNumHours = NumHours
							FROM tblLEAPOfficialBusiness
							WHERE AGHID = @lAGHID;

							SET @ltableHTML =
								'<table cellpadding="4" cellspacing="0" width="100%"
									style="border-collapse:collapse;font-family:Arial;font-size:12px;">'

								+ '<tr style="background-color:#E6E6E6;">'
								+ '<td colspan="2" style="border:1px solid #000;font-weight:bold;color:#02075D;">'
								+ 'Official Business Details'
								+ '</td></tr>'

								+ '<tr><td style="border:1px solid #000;"><b>Purpose</b></td>'
								+ '<td style="border:1px solid #000;">' + ISNULL(@lPurpose,'') + '</td></tr>'

								+ '<tr><td style="border:1px solid #000;"><b>Reason</b></td>'
								+ '<td style="border:1px solid #000;">' + ISNULL(@lReason,'') + '</td></tr>'

								+ '<tr><td style="border:1px solid #000;"><b>Destination</b></td>'
								+ '<td style="border:1px solid #000;">' + ISNULL(@lDestination,'') + '</td></tr>'

								+ '<tr><td style="border:1px solid #000;"><b>OB From</b></td>'
								+ '<td style="border:1px solid #000;">' + ISNULL(FORMAT(@lOBFrom,'MM/dd/yyyy hh:mm tt'),'') + '</td></tr>'

								+ '<tr><td style="border:1px solid #000;"><b>OB To</b></td>'
								+ '<td style="border:1px solid #000;">' + ISNULL(FORMAT(@lOBTo,'MM/dd/yyyy hh:mm tt'),'') + '</td></tr>'

								+ '<tr><td style="border:1px solid #000;"><b>Hours</b></td>'
								+ '<td style="border:1px solid #000;">' + CAST(@lNumHours AS VARCHAR) + '</td></tr>'

								+ '</table>';

							SET @ltableHTMLTotal += @ltableHTML;
							SET @ltableHTMLTotal += '<hr style="border:1px dashed #999;" />';

						END

						COMMIT TRAN;
					END TRY
					BEGIN CATCH
						IF @@TRANCOUNT > 0
							ROLLBACK TRAN;

						SET @lmsg = ERROR_MESSAGE();

						EXEC spActivityLogs
							@pButtonName = @pActivity,
							@pErrorMessage = @lmsg,
							@pModuleID = @pModuleID,
							@pUser = @pUserName,
							@pTimeStamp = @lTimeStamp,
							@pAdditionalMsg = @lAddmsg,
							@pTransactional = 1;

						RAISERROR(@lmsg,16,1);
					END CATCH;

					FETCH NEXT FROM OBCursor INTO
						@lTransID,
						@lIDNumber,
						@lPurpose,
						@lAttachment,
						@lReason,
						@lDestination,
						@lOBFrom,
						@lOBTo,
						@lNumHours;
				END

				CLOSE OBCursor;
				DEALLOCATE OBCursor;

				EXEC spAAMProcess
					@pOption = 40,
					@pEmailBody = @ltableHTMLTotal,
					@pAGHID = @lAGHID,
					@pUser = @pUserName,
					@pStatus = @lStatus,
					@pTimeStamp = @lTimeStamp;

				COMMIT TRANSACTION;

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION;

				SET @msg = ERROR_MESSAGE();

				EXEC spActivityLogs
					@pButtonName = @pActivity,
					@pErrorMessage = @msg,
					@pModuleID = @pModuleID,
					@pUser = @pUserName,
					@pTimeStamp = @lTimeStamp,
					@pAdditionalMsg = @lAddmsg,
					@pTransactional = 1;

				RAISERROR(@msg,16,1);
			END CATCH;
		END

	IF @pOption = 35 -- GET ALL tblHR_PeriodSchedule JAKE
		BEGIN
			SELECT PID, [Period], MonthStart, MonthEnd, DTCreated, CreatedBy, DTModified, LastUpdateBy
			FROM tblHR_PeriodSchedule 

		END
	IF @pOption = 36 -- UPSERT for tblHR_PeriodSchedule --Jake
		BEGIN
			BEGIN TRY

				MERGE tblHR_PeriodSchedule AS TARGET
				USING ( SELECT @pPID AS PID, @pPeriod AS Period, @pMonthStart AS MonthStart, @pMonthEnd AS MonthEnd) AS SOURCE
				ON TARGET.PID = SOURCE.PID 

				WHEN MATCHED THEN
					UPDATE SET  [Period] = @pPeriod, MonthStart = @pMonthStart, MonthEnd = @pMonthEnd, LastUpdateBy = @pUserName, DTModified = GETDATE()

				WHEN NOT MATCHED THEN
					INSERT ( [Period]	, MonthStart, MonthEnd, CreatedBy, DTCreated)
					VALUES ( @pPeriod, @pMonthStart, @pMonthEnd	, @pUserName, GETDATE());

			END TRY
			BEGIN CATCH
				THROW;
			END CATCH
		END

	IF @pOption = 37 -- Call in option 26 for earned leave computation
		BEGIN
			BEGIN TRY

				DECLARE @lCurrentDate DATE,
						@lEndDate DATE,
						@lMonth INT,
						@lGroupID INT,
						@lLeaveHours DECIMAL(18,2),
						@lRemainingBalance DECIMAL(18,2),
						@lInsertValue DECIMAL(18,2),
						@lSQL NVARCHAR(MAX);

				SET @lCurrentDate = @pDTFrom;
				SET @lEndDate = @pDTTo;

				SET @lRemainingBalance = ISNULL(@pLeaveBalance,0);

				SELECT @lGroupID = GroupID
				FROM tblHR_PersonnelMaster
				WHERE IDNumber = @pIDNumber;

				WHILE @lCurrentDate <= @lEndDate
				BEGIN

					SET @lMonth = MONTH(@lCurrentDate);

					-- Get monthly entitlement
					SET @lSQL = '
						SELECT @lLeaveHours = LeaveHours' + RIGHT('0' + CAST(@lMonth AS VARCHAR), 2) + '
						FROM tblHR_MonthlyEntPerGroup
						WHERE GroupID = @lGroupID
						  AND LeaveCode = @pLeaveCode
					';

					EXEC sp_executesql
						@lSQL,
						N'@lLeaveHours DECIMAL(18,2) OUTPUT,
						  @lGroupID INT,
						  @pLeaveCode VARCHAR(10)',
						@lLeaveHours OUTPUT,
						@lGroupID,
						@pLeaveCode;

					SET @lLeaveHours = ISNULL(@lLeaveHours,0);

					-- ⭐ NEW LOGIC (ALLOW PARTIAL + CARRY OVER)
					IF @lRemainingBalance >= @lLeaveHours
					BEGIN
						SET @lInsertValue = @lLeaveHours;
						SET @lRemainingBalance = @lRemainingBalance - @lLeaveHours;
					END
					ELSE IF @lRemainingBalance > 0
					BEGIN
						SET @lInsertValue = @lRemainingBalance;
						SET @lRemainingBalance = 0;
					END
					ELSE
					BEGIN
						SET @lInsertValue = 0;
					END

					-- Insert / Update
					IF EXISTS (
						SELECT 1
						FROM tblEarnedLeaveQuota
						WHERE IDNumber = @pIDNumber
						  AND LeaveCode = @pLeaveCode
						  AND YearValid = YEAR(@pDTTo)
					)
					BEGIN

						UPDATE tblEarnedLeaveQuota
						SET
							January   = January   + CASE WHEN @lMonth = 1  THEN @lInsertValue ELSE 0 END,
							February  = February  + CASE WHEN @lMonth = 2  THEN @lInsertValue ELSE 0 END,
							March     = March     + CASE WHEN @lMonth = 3  THEN @lInsertValue ELSE 0 END,
							April     = April     + CASE WHEN @lMonth = 4  THEN @lInsertValue ELSE 0 END,
							May       = May       + CASE WHEN @lMonth = 5  THEN @lInsertValue ELSE 0 END,
							June      = June      + CASE WHEN @lMonth = 6  THEN @lInsertValue ELSE 0 END,
							July      = July      + CASE WHEN @lMonth = 7  THEN @lInsertValue ELSE 0 END,
							August    = August    + CASE WHEN @lMonth = 8  THEN @lInsertValue ELSE 0 END,
							September = September + CASE WHEN @lMonth = 9  THEN @lInsertValue ELSE 0 END,
							October   = October   + CASE WHEN @lMonth = 10 THEN @lInsertValue ELSE 0 END,
							November  = November  + CASE WHEN @lMonth = 11 THEN @lInsertValue ELSE 0 END,
							December  = December  + CASE WHEN @lMonth = 12 THEN @lInsertValue ELSE 0 END,

							LeaveTotalBalance = ISNULL(LeaveTotalBalance,0) + @lInsertValue

						WHERE IDNumber = @pIDNumber
						  AND LeaveCode = @pLeaveCode
						  AND YearValid = YEAR(@pDTTo);

					END
					ELSE
					BEGIN

						INSERT INTO tblEarnedLeaveQuota
						(
							IDNumber,
							LeaveCode,
							YearValid,

							January,
							February,
							March,
							April,
							May,
							June,
							July,
							August,
							September,
							October,
							November,
							December,

							LeaveTotalBalance,
							CreatedBy,
							DTCreated
						)
						VALUES
						(
							@pIDNumber,
							@pLeaveCode,
							YEAR(@pDTTo),

							CASE WHEN @lMonth = 1  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 2  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 3  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 4  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 5  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 6  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 7  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 8  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 9  THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 10 THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 11 THEN @lInsertValue ELSE 0 END,
							CASE WHEN @lMonth = 12 THEN @lInsertValue ELSE 0 END,

							@lInsertValue,
							@pUserName,
							GETDATE()
						);

					END

					SET @lCurrentDate = DATEADD(MONTH, 1, @lCurrentDate);

				END

			END TRY
			BEGIN CATCH
				RAISERROR('Error inserting Earned Leave Quota (Option 38).', 16, 1);
			END CATCH
		END

	IF @pOption = 38 -- Get All Biometric Server
		BEGIN
			SELECT ServerID,IPAddress,[Port],Office,[Description] FROM tblLEAPBiometricServers
		END










	END
GO
