/* =========================================
   999 - RollBack All Changes
   Combined safe rollback for all identified ALTER scripts
========================================= */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =========================================
       tblHR_WorkScheduleRD
    ========================================= */
    -- Rename DTCreated back to DTime if renamed
    IF EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE Name = 'DTCreated'
          AND Object_ID = Object_ID('dbo.tblHR_WorkScheduleRD')
    )
    AND NOT EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE Name = 'DTime'
          AND Object_ID = Object_ID('dbo.tblHR_WorkScheduleRD')
    )
    BEGIN
        EXEC sp_rename 'dbo.tblHR_WorkScheduleRD.DTCreated', 'DTime', 'COLUMN';
    END

    -- Drop added WorkScheduleRD columns
    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'isActive' AND Object_ID = Object_ID('dbo.tblHR_WorkScheduleRD')
    )
        ALTER TABLE dbo.tblHR_WorkScheduleRD DROP COLUMN isActive;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTModified' AND Object_ID = Object_ID('dbo.tblHR_WorkScheduleRD')
    )
        ALTER TABLE dbo.tblHR_WorkScheduleRD DROP COLUMN DTModified;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'LastUpdateBy' AND Object_ID = Object_ID('dbo.tblHR_WorkScheduleRD')
    )
        ALTER TABLE dbo.tblHR_WorkScheduleRD DROP COLUMN LastUpdateBy;

    -- NOTE: CreatedBy length increase is not automatically reverted here because the original max length is unknown.

    /* =========================================
       tblHR_WorkSchedule
    ========================================= */
    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'isActive' AND Object_ID = Object_ID('dbo.tblHR_WorkSchedule')
    )
        ALTER TABLE dbo.tblHR_WorkSchedule DROP COLUMN isActive;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'CreatedBy' AND Object_ID = Object_ID('dbo.tblHR_WorkSchedule')
    )
        ALTER TABLE dbo.tblHR_WorkSchedule DROP COLUMN CreatedBy;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTCreated' AND Object_ID = Object_ID('dbo.tblHR_WorkSchedule')
    )
        ALTER TABLE dbo.tblHR_WorkSchedule DROP COLUMN DTCreated;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'LastUpdateBy' AND Object_ID = Object_ID('dbo.tblHR_WorkSchedule')
    )
        ALTER TABLE dbo.tblHR_WorkSchedule DROP COLUMN LastUpdateBy;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTModified' AND Object_ID = Object_ID('dbo.tblHR_WorkSchedule')
    )
        ALTER TABLE dbo.tblHR_WorkSchedule DROP COLUMN DTModified;

    /* =========================================
       tblHR_PersonnelLeaveBalance
    ========================================= */
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

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'LeaveBalanceID' AND Object_ID = Object_ID('tblHR_PersonnelLeaveBalance')
    )
        ALTER TABLE tblHR_PersonnelLeaveBalance DROP COLUMN LeaveBalanceID;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTCreated' AND Object_ID = Object_ID('tblHR_PersonnelLeaveBalance')
    )
        ALTER TABLE tblHR_PersonnelLeaveBalance DROP COLUMN DTCreated;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'CreatedBy' AND Object_ID = Object_ID('tblHR_PersonnelLeaveBalance')
    )
        ALTER TABLE tblHR_PersonnelLeaveBalance DROP COLUMN CreatedBy;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTModified' AND Object_ID = Object_ID('tblHR_PersonnelLeaveBalance')
    )
        ALTER TABLE tblHR_PersonnelLeaveBalance DROP COLUMN DTModified;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'LastUpdateBy' AND Object_ID = Object_ID('tblHR_PersonnelLeaveBalance')
    )
        ALTER TABLE tblHR_PersonnelLeaveBalance DROP COLUMN LastUpdateBy;

    /* =========================================
       tblHR_PersonnelLeaves
    ========================================= */
    IF EXISTS (
        SELECT 1
        FROM sys.key_constraints
        WHERE [type] = 'PK'
          AND [name] = 'PK_tblHR_PersonnelLeaves_TransID'
    )
    BEGIN
        ALTER TABLE tblHR_PersonnelLeaves
        DROP CONSTRAINT PK_tblHR_PersonnelLeaves_TransID;
    END

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'AGHID' AND Object_ID = Object_ID('tblHR_PersonnelLeaves')
    )
        ALTER TABLE tblHR_PersonnelLeaves DROP COLUMN AGHID;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'ReasonCode' AND Object_ID = Object_ID('tblHR_PersonnelLeaves')
    )
        ALTER TABLE tblHR_PersonnelLeaves DROP COLUMN ReasonCode;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTNotice' AND Object_ID = Object_ID('tblHR_PersonnelLeaves')
    )
        ALTER TABLE tblHR_PersonnelLeaves DROP COLUMN DTNotice;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'NoticeFileName' AND Object_ID = Object_ID('tblHR_PersonnelLeaves')
    )
        ALTER TABLE tblHR_PersonnelLeaves DROP COLUMN NoticeFileName;

    /* =========================================
       tblHR_PersonnelMaster
    ========================================= */
    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup'
    )
    BEGIN
        ALTER TABLE tblHR_PersonnelMaster
        DROP CONSTRAINT FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup;
    END

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = N'GroupID' AND Object_ID = Object_ID(N'tblHR_PersonnelMaster')
    )
        ALTER TABLE tblHR_PersonnelMaster DROP COLUMN GroupID;

    /* =========================================
       tblHR_AbsentType
    ========================================= */
    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_tblHR_AbsentType_ChargeToLeaveType'
    )
    BEGIN
        ALTER TABLE tblHR_AbsentType
        DROP CONSTRAINT FK_tblHR_AbsentType_ChargeToLeaveType;
    END

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'LeaveColor' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN LeaveColor;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'ChargeToLeaveType' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN ChargeToLeaveType;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name IN ('Dayspecific', 'DateSpecific') AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN Dayspecific, DateSpecific;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'Active' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN Active;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'CreatedBy' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN CreatedBy;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTCreted' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN DTCreted;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'LastUpdateBy' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN LastUpdateBy;

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'DTModified' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType DROP COLUMN DTModified;

    -- Revert column type/name changes for tblHR_AbsentType
    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'ChargeToLeaved' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
    BEGIN
        ALTER TABLE tblHR_AbsentType
        ALTER COLUMN ChargeToLeaved TINYINT NULL;
        EXEC sp_rename 'tblHR_AbsentType.ChargeToLeaved', 'ChargeToLeave', 'COLUMN';
    END
    ELSE IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'ChargeToLeave' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
    BEGIN
        ALTER TABLE tblHR_AbsentType
        ALTER COLUMN ChargeToLeave TINYINT NULL;
    END

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'FilingNotice' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
    AND NOT EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'Timeline' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
    BEGIN
        EXEC sp_rename 'tblHR_AbsentType.FilingNotice', 'Timeline', 'COLUMN';
    END

    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'FillingNotice' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
    AND NOT EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'Timeline' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
    BEGIN
        EXEC sp_rename 'tblHR_AbsentType.FillingNotice', 'Timeline', 'COLUMN';
    END

    IF NOT EXISTS (
        SELECT 1 FROM sys.columns
        WHERE Name = 'Timeline' AND Object_ID = Object_ID('tblHR_AbsentType')
    )
    BEGIN
        ALTER TABLE tblHR_AbsentType
        ADD Timeline TINYINT NOT NULL DEFAULT (0);
    END

    /* =========================================
       tblModule / Menu / Related objects rollback
    ========================================= */
    IF OBJECT_ID('tempdb..#tblModuleBackup') IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM #tblModuleBackup)
        BEGIN
            DELETE FROM tblModule WHERE ModuleCode = 'HR';
        END
        ELSE
        BEGIN
            UPDATE T
            SET 
                T.[Description] = B.[Description],
                T.Active = B.Active,
                T.UpdatedBy = ORIGINAL_LOGIN(),
                T.DTUpdated = GETDATE()
            FROM tblModule T
            INNER JOIN #tblModuleBackup B
                ON T.ModuleCode = B.ModuleCode;
        END
    END

    IF EXISTS (SELECT 1 FROM tblMenu WHERE LinkURL = '../HumanResource/HRCalendar.aspx')
    BEGIN
        DELETE MOA
        FROM tblMenuObjectAccess MOA
        INNER JOIN tblMenuUserAccess MUA ON MOA.AccessId = MUA.AccessId
        INNER JOIN tblMenu M ON MUA.ItemId = M.ItemId
        WHERE M.LinkURL = '../HumanResource/HRCalendar.aspx';

        DELETE MAD
        FROM tblModuleAccessDetails MAD
        INNER JOIN tblObjects O ON MAD.ObjectID = O.ObjectID
        INNER JOIN tblMenu M ON O.ItemId = M.ItemId
        WHERE M.LinkURL = '../HumanResource/HRCalendar.aspx';

        DELETE O
        FROM tblObjects O
        INNER JOIN tblMenu M ON O.ItemId = M.ItemId
        WHERE M.LinkURL = '../HumanResource/HRCalendar.aspx';

        DELETE FROM tblMenuUserAccess
        WHERE ItemId IN (
            SELECT ItemId FROM tblMenu
            WHERE LinkURL = '../HumanResource/HRCalendar.aspx'
        );

        DELETE FROM tblActivityLogsLinks
        WHERE ItemID IN (
            SELECT ItemId FROM tblMenu
            WHERE LinkURL = '../HumanResource/HRCalendar.aspx'
        );

        DELETE FROM tblMenu
        WHERE LinkURL = '../HumanResource/HRCalendar.aspx';
    END

    IF OBJECT_ID('tblHRSectionDetails', 'U') IS NOT NULL DROP TABLE tblHRSectionDetails;
    IF OBJECT_ID('tblHRSectionHeader', 'U') IS NOT NULL DROP TABLE tblHRSectionHeader;
    IF OBJECT_ID('tblHRDepartment', 'U') IS NOT NULL DROP TABLE tblHRDepartment;
    IF OBJECT_ID('tblHRDivision', 'U') IS NOT NULL DROP TABLE tblHRDivision;

    COMMIT TRANSACTION;
    PRINT '999 Rollback completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '999 Rollback failed. Transaction has been reverted.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
