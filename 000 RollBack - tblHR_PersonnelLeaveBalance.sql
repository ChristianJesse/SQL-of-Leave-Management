SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN TRY

    BEGIN TRAN

    /*========================================================
     DROP PRIMARY KEY (IF EXISTS)
    ========================================================*/
    IF EXISTS (
        SELECT 1
        FROM sys.key_constraints
        WHERE [type] = 'PK'
          AND [name] = 'PK_tblHR_PersonnelLeaveBalance'
    )
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        DROP CONSTRAINT PK_tblHR_PersonnelLeaveBalance;
    END

    /*========================================================
     DROP IDENTITY COLUMN
    ========================================================*/
    IF EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID('tblHR_PersonnelLeaveBalance')
          AND name = 'LeaveBalanceID'
    )
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        DROP COLUMN LeaveBalanceID;
    END

    /*========================================================
     DROP ADDED COLUMNS
    ========================================================*/
    IF EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID('tblHR_PersonnelLeaveBalance')
          AND name = 'DTCreated'
    )
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        DROP COLUMN 
            DTCreated,
            CreatedBy,
            DTModified,
            LastUpdateBy;
    END

    COMMIT TRAN

    PRINT 'SUCCESS: Rollback completed successfully.'

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRAN

    PRINT 'ERROR: ' + ERROR_MESSAGE();

END CATCH
GO