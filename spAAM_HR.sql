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

CREATE OR ALTER PROCEDURE spAAM_HR
	@pOption					TINYINT
	,@pUserName					VARCHAR(50) = NULL

AS
BEGIN

	DECLARE @lTimeStamp			DATETIME
			,@lMID				INT

	SET NOCOUNT ON;
		SELECT @lMID = MID from tblModule WHERE ModuleCode = 'HR'


	IF @pOption = 1
		BEGIN
			SELECT * FROM tblHR_PersonnelLeaves WHERE AGHID IS NOT NULL 
		END
END
GO
