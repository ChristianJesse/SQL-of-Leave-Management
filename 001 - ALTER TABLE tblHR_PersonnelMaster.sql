SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create Column LGHID in tblHR_PersonnelMaster
-- =========================================
IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE Name = N'LGHID'
      AND Object_ID = Object_ID(N'tblHR_PersonnelMaster')
)
BEGIN
    ALTER TABLE tblHR_PersonnelMaster
    ADD LGHID INT NULL;

    PRINT 'Column LGHID added to tblHR_PersonnelMaster';
END
ELSE
BEGIN
    PRINT 'Column LGHID already exists in tblHR_PersonnelMaster';
END
GO

-- =========================================
-- Check/Create Foreign Key
-- FK_tblHR_PersonnelMaster_tblLEAPLeaveEntGroupHeader
-- =========================================
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_tblHR_PersonnelMaster_tblLEAPLeaveEntGroupHeader'
)
BEGIN
    ALTER TABLE tblHR_PersonnelMaster
    ADD CONSTRAINT FK_tblHR_PersonnelMaster_tblLEAPLeaveEntGroupHeader
        FOREIGN KEY (LGHID)
        REFERENCES tblLEAPLeaveEntGroupHeader (LGHID);

    PRINT 'Foreign Key FK_tblHR_PersonnelMaster_tblLEAPLeaveEntGroupHeader created';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tblHR_PersonnelMaster_tblLEAPLeaveEntGroupHeader already exists';
END
GO