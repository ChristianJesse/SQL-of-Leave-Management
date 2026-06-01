/* =========================================
   SAFE ROLLBACK SCRIPT
========================================= */
BEGIN TRY
    BEGIN TRANSACTION;

    /* =========================
       tblHR_AbsentType
    ========================= */

    -- Drop added columns safely
    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'LeavedColor' AND Object_ID = Object_ID('tblHR_AbsentType'))
        ALTER TABLE tblHR_AbsentType DROP COLUMN LeavedColor;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Dayspecific' AND Object_ID = Object_ID('tblHR_AbsentType'))
        ALTER TABLE tblHR_AbsentType DROP COLUMN Dayspecific;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'ChargeToLeaveType' AND Object_ID = Object_ID('tblHR_AbsentType'))
        ALTER TABLE tblHR_AbsentType DROP COLUMN ChargeToLeaveType;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'ChangeBy' AND Object_ID = Object_ID('tblHR_AbsentType'))
        ALTER TABLE tblHR_AbsentType DROP COLUMN ChangeBy;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'DTChange' AND Object_ID = Object_ID('tblHR_AbsentType'))
        ALTER TABLE tblHR_AbsentType DROP COLUMN DTChange;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'FillingNotice' AND Object_ID = Object_ID('tblHR_AbsentType'))
        ALTER TABLE tblHR_AbsentType DROP COLUMN FillingNotice;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Active' AND Object_ID = Object_ID('tblHR_AbsentType'))
        ALTER TABLE tblHR_AbsentType DROP COLUMN Active;
    -- Revert datatype (bit → tinyint)
    IF EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE Name = 'ChargeToLeaved' 
        AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType
        ALTER COLUMN ChargeToLeaved TINYINT NULL;

    -- Rename column back to original
    IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'ChargeToLeaved' AND Object_ID = Object_ID('tblHR_AbsentType'))
        EXEC sp_rename 'tblHR_AbsentType.ChargeToLeaved', 'ChargeToLeave', 'COLUMN';

    -- Restore Timeline column (if missing)
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE Name = 'Timeline' 
        AND Object_ID = Object_ID('tblHR_AbsentType')
    )
        ALTER TABLE tblHR_AbsentType
        ADD Timeline TINYINT NOT NULL DEFAULT 0;

    /* =========================
       tblModule
    ========================= */
    IF OBJECT_ID('tempdb..#tblModuleBackup') IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM #tblModuleBackup)
        BEGIN
            PRINT 'Rollback: Deleting inserted HR module...';
            DELETE FROM tblModule WHERE ModuleCode = 'HR';
        END
        ELSE
        BEGIN
            PRINT 'Rollback: Restoring original values...';
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

    /* =========================
       tblMenu / Related objects
    ========================= */
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

    /* =========================
       Drop tables if exist
    ========================= */
    IF OBJECT_ID('tblHRSectionDetails', 'U') IS NOT NULL DROP TABLE tblHRSectionDetails;
    IF OBJECT_ID('tblHRSectionHeader', 'U') IS NOT NULL DROP TABLE tblHRSectionHeader;
    IF OBJECT_ID('tblHRDepartment', 'U') IS NOT NULL DROP TABLE tblHRDepartment;
    IF OBJECT_ID('tblHRDivision', 'U') IS NOT NULL DROP TABLE tblHRDivision;

    COMMIT TRANSACTION;
    PRINT 'Rollback completed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Rollback failed. Transaction has been reverted.';
    PRINT ERROR_MESSAGE();
END CATCH;



GO 


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Drop Foreign Key FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup
-- =========================================
IF EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup'
)
BEGIN
    ALTER TABLE tblHR_PersonnelMaster
    DROP CONSTRAINT FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup;

    PRINT 'Foreign Key FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup dropped';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup does not exist';
END
GO

-- =========================================
-- Drop Column GroupID from tblHR_PersonnelMaster
-- =========================================
IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE Name = N'GroupID'
      AND Object_ID = Object_ID(N'tblHR_PersonnelMaster')
)
BEGIN
    ALTER TABLE tblHR_PersonnelMaster
    DROP COLUMN GroupID;

    PRINT 'Column GroupID dropped from tblHR_PersonnelMaster';
END
ELSE
BEGIN
    PRINT 'Column GroupID does not exist in tblHR_PersonnelMaster';
END
GO