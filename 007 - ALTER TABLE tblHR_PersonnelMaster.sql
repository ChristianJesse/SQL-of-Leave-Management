SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create Column GroupID in tblHR_PersonnelMaster
-- =========================================
IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE Name = N'GroupID'
      AND Object_ID = Object_ID(N'tblHR_PersonnelMaster')
)
BEGIN
    ALTER TABLE tblHR_PersonnelMaster
    ADD GroupID smallint NULL;

    PRINT 'Column GroupID added to tblHR_PersonnelMaster';
END
ELSE
BEGIN
    PRINT 'Column GroupID already exists in tblHR_PersonnelMaster';
END
GO

-- =========================================
-- Check/Create Foreign Key FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup
-- =========================================
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup'
)
BEGIN
    ALTER TABLE tblHR_PersonnelMaster
    ADD CONSTRAINT FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup
        FOREIGN KEY (GroupID)
        REFERENCES tblHR_LeaveEntGroup (GroupID);

    PRINT 'Foreign Key FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup created';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tblHR_PersonnelMaster_tblHR_LeaveEntGroup already exists';
END
GO