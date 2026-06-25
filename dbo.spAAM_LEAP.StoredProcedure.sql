SET ANSI_NULLS ON
	GO
SET QUOTED_IDENTIFIER OFF
GO
/********************************************************************************************************************************
SP Name:     spAAM_HR
Description: 
Author:      COORETO
Called from: HR LEAVE APPLICATION

_________________________________________________________________________________________________________________________________
History
Change Number	Date            Author			Description
00				23-Mar-2026		COORETO			Initial Creation

  _________________________________________________________________________________________________
** For developers: Please update history for us to keep track of the changes made on this SP

***********************************************************************************************/

CREATE OR ALTER PROCEDURE spAAM_LeAP	
	@pOption					TINYINT
	,@pUserName					VARCHAR(50) = NULL
	,@pDisplayData				TypeAAMDisplayParams READONLY
	,@TypeSONum 				TypeSONum READONLY
	,@oAAMAdditionalEmailHtml	NVARCHAR(MAX)       = NULL OUTPUT 
	,@pAGHID				    BIGINT = NULL		
	,@pLeaveBalanceID			INT  = NULL
	,@pWorkHrs					INT = NULL
	,@pIsApprove				BIT = NULL
	,@pTransID					INT = 0

AS
BEGIN

	DECLARE @lTimeStamp			DATETIME
			,@lMID				INT
			,@ltableHTML		VARCHAR(MAX)
			,@ltableHTMLTotal	NVARCHAR(MAX) = ''
			-- LEAVE
			,@lLeaveType VARCHAR(55)
			,@lWorkHrs TINYINT
			,@lReason VARCHAR(MAX)
			,@lDTNotice DATETIME
			,@lFileNotice VARCHAR(55)
			,@lReasonDesc VARCHAR(MAX)
			,@lLeaveCode		VARCHAR(10)
			,@lDTFrom			DATETIME
			,@lDTTo				DATETIME
			-- OB
			,@lOBDate	DATETIME
			,@lNumHours FLOAT
			,@lOBDestination varchar(255)
			,@lOBFrom DATETIME
			,@lOBTo DATETIME
			,@lPurpose varchar(255)
			,@lDestination varchar(255)


	SET NOCOUNT ON;
		SELECT @lMID = MID from tblModule WHERE ModuleCode = 'LeAP'


	IF @pOption = 1 -- GET ALL LEAVE FOR APPROVAL
		BEGIN
			SELECT  A.TransID
				,A.LeaveCode +' - '+ C.LeaveDesc AS [Leave Type]
				,CONVERT(varchar(22), A.DTLeave, 101) AS [Date Leave]
				,A.ReasonCode +' - '+ D.ReasonDescription AS [Reason]
				,A.LeaveReason AS [Reason Details]
				,B.IDNumber
				,B.LastName +', '+ B.FirstName AS [Emplyee Name]
				,A.NumHours AS [Leave Hours]
				--,CONVERT(varchar(22), A.DTNotice, 101) AS [Date Notice]
				,FORMAT(A.DTNotice, 'MM/dd/yyyy hh:mm:ss tt') AS [Date Notice]
				,FORMAT(A.DTApplied, 'MM/dd/yyyy hh:mm:ss tt') AS [Date Submitted]
				,A.AGHID
				,(SELECT LeaveBalanceID 
					FROM tblHR_PersonnelLeaveBalance 
					WHERE LeaveCode = A.LeaveCode AND IDNumber = B.IDNumber AND A.DTApplied BETWEEN DTFrom AND DTTo) AS LeaveBalanceID
			FROM tblHR_PersonnelLeaves A 
				LEFT JOIN tblHR_PersonnelMaster B ON A.IDNumber = B.IDNumber
				LEFT JOIN tblHR_AbsentType C ON A.LeaveCode = C.LeaveCode
				LEFT JOIN tblLEAPLeaveReason D ON A.ReasonCode = D.ReasonCode
			WHERE AGHID IS NOT NULL 
			ORDER BY DTLeave


		END
	ELSE IF @pOption = 2 -- Post-Approval 
		BEGIN
		IF @pIsApprove = 1 
			BEGIN 
				UPDATE  tblHR_PersonnelLeaveBalance  SET AppliedLeave =  (AppliedLeave - @pWorkHrs) , ForPosting = (ForPosting + @pWorkHrs)
					WHERE LeaveBalanceID = @pLeaveBalanceID
			END
		ELSE IF @pIsApprove = 0 
			BEGIN
				UPDATE  tblHR_PersonnelLeaveBalance  SET AppliedLeave =  (AppliedLeave - @pWorkHrs) , LeaveBalance = (LeaveBalance + @pWorkHrs)
						WHERE LeaveBalanceID = @pLeaveBalanceID
					
						CREATE TABLE testAAAMCJ (TestColumn VARCHAR(100));

				--UPDATE tblHR_PersonnelLeaves SET IsCancelled = 1 WHERE TransID = @pTransID
			END
		END
	ELSE IF @pOption = 3 -- LEAVE Email Notification SEND EMEIL 
		BEGIN
			SELECT 
			@lLeaveType =  LeaveCode
			,@lDTFrom = DTLeave
			,@lWorkHrs = NumHours
			,@lReason = ReasonCode
			,@lDTNotice = DTNotice
			,@lFileNotice = NoticeFileName
			,@lReasonDesc = LeaveReason
			FROM tblHR_PersonnelLeaves 
			WHERE AGHID = @pAGHID

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
			+ '<td style="border:1px solid #000;">' + ISNULL(FORMAT(@lDTFrom,'MM/dd/yyyy'),'') + '</td>'
			+ '</tr>'

			+ '<tr>'
			+ '<td style="border:1px solid #000;"><b>Work Hours</b></td>'
			+ '<td style="border:1px solid #000;">' + CAST(@lWorkHrs AS VARCHAR) + '</td>'
			+ '</tr>'

			+ '<tr>'
			+ '<td style="border:1px solid #000;"><b>Reason</b></td>'
			+ '<td style="border:1px solid #000;">' + ISNULL(@lReason,'') + '</td>'
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

			
			SET @oAAMAdditionalEmailHtml = @ltableHTMLTotal;

			select @oAAMAdditionalEmailHtml
		END
	ELSE IF @pOption = 4 -- GET ALL OB FOR APPROVAL
		BEGIN
			SELECT TransID
			,A.IDNumber
			,B.LastName +', '+ B.FirstName AS [Emplyee Name]

			,A.Purpose
			,A.Attachment
			,A.Destination
			,FORMAT(A.OBFrom, 'MM/dd/yyyy hh:mm:ss tt') AS [OB From]
			,FORMAT(A.OBTo, 'MM/dd/yyyy hh:mm:ss tt') AS [OB To]
			,A.NumHours
			,FORMAT(A.DTApplied, 'MM/dd/yyyy hh:mm:ss tt') AS [Date Applied]
			,A.AGHID
			FROM tblLEAPOfficialBusiness A 
			LEFT JOIN tblHR_PersonnelMaster B ON A.IDNumber = B.IDNumber
		END
	ELSE IF @pOption = 5 -- OB Email Notification SEND 
		BEGIN
			SELECT 
				@lPurpose = Purpose,
				@lDestination = Destination,
				@lOBFrom = OBFrom,
				@lOBTo = OBTo,
				@lNumHours = NumHours
			FROM tblLEAPOfficialBusiness
			WHERE AGHID = @pAGHID

				SET @ltableHTML =
								'<table cellpadding="4" cellspacing="0" width="100%"
									style="border-collapse:collapse;font-family:Arial;font-size:12px;">'

								+ '<tr style="background-color:#E6E6E6;">'
								+ '<td colspan="2" style="border:1px solid #000;font-weight:bold;color:#02075D;">'
								+ 'Official Business Details'
								+ '</td></tr>'

								+ '<tr><td style="border:1px solid #000;"><b>Purpose</b></td>'
								+ '<td style="border:1px solid #000;">' + ISNULL(@lPurpose,'') + '</td></tr>'

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

				SET @oAAMAdditionalEmailHtml = @ltableHTMLTotal;
				select @oAAMAdditionalEmailHtml

		END

END
GO
