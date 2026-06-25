DECLARE @lMID INT; 
SELECT @lMID = MID FROM tblModule WHERE ModuleCode = 'LeAP';

DECLARE @lUser VARCHAR(50) = ORIGINAL_LOGIN();
DECLARE @lTimeStamp DATETIME = GETDATE();

IF @lMID IS NOT NULL
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @ReferenceData TABLE (
            RCategory VARCHAR(200),
            RCode VARCHAR(50),
            RValue VARCHAR(200),
            RSwitch VARCHAR(10),
            MID INT,
            RDesc VARCHAR(200)
        );

        -- Reference data
        INSERT INTO @ReferenceData (RCategory, RCode, RValue, RSwitch, MID, RDesc)
        VALUES
			-- Approval Status

			('HR', 'CREATED'		,'CREATED'			, '0', @lMID, 'Created Status'),
			('HR', 'FOR APPROVAL'	,'FOR APPROVAL'		, '0', @lMID, 'For Approval Status'),
			('HR', 'APPROVED'		,'APPROVED'			, '0', @lMID, 'Approved Status'),
			('HR', 'REJECTED'		,'REJECTED'			, '0', @lMID, 'Rejected Status'),
			('HR', 'CANCELLED'		,'CANCELLED'		, '0', @lMID, 'Cancelled Status'),
			('HR', 'POSTED'			,'POSTED'			, '0', @lMID, 'Posted Status'),

			('LeAPLeavePeriodStatus', 'LPSOpen'			,'Open'		, '0', @lMID, 'Leave Period Open Status'),
			('LeAPLeavePeriodStatus', 'LPSClosed'		,'Closed'	, '0', @lMID, 'Leave Period Closed Status'),


			('LeAPPeriod', 'H1', 'H1', '0', @lMID, 'First Half'),
			('LeAPPeriod', 'H2', 'H2', '0', @lMID, 'Second Half'),
			('LeAPPeriod', 'HY', 'HY', '0', @lMID, 'Whole Year'),

			('LeAPLeaveTypeProRataC',	'N', 'None',		'0',	@lMID,	'Pro-Rata Computation None'),
			('LeAPLeaveTypeProRataC',	'P', 'Pro-rated',	'0',	@lMID,	'Pro-Rata Computation Pro-Rated'),
			('LeAPLeaveTypeProRataC',	'E', 'Earned',		'0',	@lMID,	'Pro-Rata Computation Earned'),

			('LeAPLeaveTypeUnit',	'D',	'Days',		'0', @lMID,'Leave Type Unit for Filing and Notice - Days'),
			('LeAPLeaveTypeUnit',	'H',	'Hours',	'0', @lMID,'Leave Type Unit for Filing and Notice - Hours')
			;




        DECLARE @RCategory VARCHAR(200), @RCode VARCHAR(50), @RValue VARCHAR(200),
                @RSwitch VARCHAR(10), @RDesc VARCHAR(200);

        DECLARE cur CURSOR FOR
            SELECT RCategory, RCode, RValue, RSwitch, RDesc
            FROM @ReferenceData;

        OPEN cur;
        FETCH NEXT FROM cur INTO @RCategory, @RCode, @RValue, @RSwitch, @RDesc;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- BEFORE SELECT
            PRINT '--- BEFORE ---';
            SELECT 'BEFORE' AS [BEFORE], * 
            FROM tblReferenceMaster
            WHERE RCategory = @RCategory AND RCode = @RCode AND MID = @lMID;

            IF EXISTS (
                SELECT 1
                FROM tblReferenceMaster
                WHERE RCategory = @RCategory AND RCode = @RCode AND MID = @lMID
            )
            BEGIN
                UPDATE tblReferenceMaster
                SET RValue = @RValue,
                    RSwitch = @RSwitch,
                    RDesc = @RDesc,
                    ModifiedBy = @lUser,
                    ModifiedDate = @lTimeStamp
                WHERE RCategory = @RCategory AND RCode = @RCode AND MID = @lMID;

                PRINT 'Updated: ' + @RCategory + ' - ' + @RCode;
				-- AFTER SELECT
				PRINT '--- AFTER ---';
				SELECT 'AFTER-UPDATE' AS [AFTER], * 
				FROM tblReferenceMaster
				WHERE RCategory = @RCategory AND RCode = @RCode AND MID = @lMID;
            END
            ELSE
            BEGIN
                INSERT INTO tblReferenceMaster
                    (RCategory, RCode, RValue, RSwitch, MID, RDesc, DTCreated, CreatedBy)
                VALUES
                    (@RCategory, @RCode, @RValue, @RSwitch, @lMID, @RDesc, @lTimeStamp, @lUser);

                PRINT 'Inserted: ' + @RCategory + ' - ' + @RCode;

				-- AFTER SELECT
				PRINT '--- AFTER ---';
				SELECT 'AFTER-INSERT' AS [AFTER], * 
				FROM tblReferenceMaster
				WHERE RCategory = @RCategory AND RCode = @RCode AND MID = @lMID;
            END



            FETCH NEXT FROM cur INTO @RCategory, @RCode, @RValue, @RSwitch, @RDesc;
        END

        CLOSE cur;
        DEALLOCATE cur;

        COMMIT TRAN;


    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END
ELSE
BEGIN
    RAISERROR('ModuleCode ''HR'' not found in tblModule.', 16, 1);
END



