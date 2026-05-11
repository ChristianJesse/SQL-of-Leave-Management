SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN TRY

    BEGIN TRAN

    /*========================================================
     ADD NEW COLUMNS
    ========================================================*/

    IF COL_LENGTH('tblHR_PersonnelLeaveBalance', 'DTCreated') IS NULL
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        ADD DTCreated DATETIME NULL;

        PRINT 'DTCreated column added.'
    END
    ELSE
    BEGIN
        PRINT 'DTCreated column already exists.'
    END


    IF COL_LENGTH('tblHR_PersonnelLeaveBalance', 'CreatedBy') IS NULL
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        ADD CreatedBy VARCHAR(55) NULL;

        PRINT 'CreatedBy column added.'
    END
    ELSE
    BEGIN
        PRINT 'CreatedBy column already exists.'
    END


    IF COL_LENGTH('tblHR_PersonnelLeaveBalance', 'DTModified') IS NULL
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        ADD DTModified DATETIME NULL;

        PRINT 'DTModified column added.'
    END
    ELSE
    BEGIN
        PRINT 'DTModified column already exists.'
    END


    IF COL_LENGTH('tblHR_PersonnelLeaveBalance', 'LastUpdateBy') IS NULL
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        ADD LastUpdateBy VARCHAR(55) NULL;

        PRINT 'LastUpdateBy column added.'
    END
    ELSE
    BEGIN
        PRINT 'LastUpdateBy column already exists.'
    END


    /*========================================================
     ADD IDENTITY COLUMN
    ========================================================*/

    IF COL_LENGTH('tblHR_PersonnelLeaveBalance', 'LeaveBalanceID') IS NULL
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        ADD LeaveBalanceID INT IDENTITY(1,1);

        PRINT 'LeaveBalanceID column added.'
    END
    ELSE
    BEGIN
        PRINT 'LeaveBalanceID column already exists.'
    END


    /*========================================================
     OPTIONAL: MAKE PRIMARY KEY
    ========================================================*/
    /*
    IF NOT EXISTS (
        SELECT 1
        FROM sys.key_constraints
        WHERE [type] = 'PK'
          AND [name] = 'PK_tblHR_PersonnelLeaveBalance'
    )
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaveBalance
        ADD CONSTRAINT PK_tblHR_PersonnelLeaveBalance
        PRIMARY KEY (LeaveBalanceID);

        PRINT 'Primary key added.'
    END
    ELSE
    BEGIN
        PRINT 'Primary key already exists.'
    END
    */


    COMMIT TRAN

    PRINT 'SUCCESS: tblHR_PersonnelLeaveBalance updated successfully.'

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRAN

    PRINT 'ERROR: ' + ERROR_MESSAGE();

END CATCH
GO