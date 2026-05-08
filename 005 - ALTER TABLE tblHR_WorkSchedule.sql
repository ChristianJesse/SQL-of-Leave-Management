SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- ALTER tblHR_WorkSchedule (Add New Columns)
-- =========================================
IF COL_LENGTH('dbo.tblHR_WorkSchedule', 'isActive') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkSchedule
    ADD isActive BIT NOT NULL CONSTRAINT DF_tblHR_WorkSchedule_isActive DEFAULT (1);
END
GO

IF COL_LENGTH('dbo.tblHR_WorkSchedule', 'CreatedBy') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkSchedule
    ADD CreatedBy VARCHAR(55) NULL;
END
GO

IF COL_LENGTH('dbo.tblHR_WorkSchedule', 'DTCreated') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkSchedule
    ADD DTCreated DATETIME NULL;
END
GO

IF COL_LENGTH('dbo.tblHR_WorkSchedule', 'LastUpdateBy') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkSchedule
    ADD LastUpdateBy VARCHAR(55) NULL;
END
GO

IF COL_LENGTH('dbo.tblHR_WorkSchedule', 'DTModified') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkSchedule
    ADD DTModified DATETIME NULL;
END
GO