SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- ALTER tblHR_WorkScheduleRD
-- =========================================

/* 1. Modify existing column length */
IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = 'CreatedBy' 
    AND Object_ID = OBJECT_ID('dbo.tblHR_WorkScheduleRD')
    AND max_length < 55
)
BEGIN
    ALTER TABLE dbo.tblHR_WorkScheduleRD
    ALTER COLUMN CreatedBy VARCHAR(55) NULL;
END
GO

/* 2. Rename DTime -> DTCreated */
IF COL_LENGTH('dbo.tblHR_WorkScheduleRD', 'DTime') IS NOT NULL
   AND COL_LENGTH('dbo.tblHR_WorkScheduleRD', 'DTCreated') IS NULL
BEGIN
    EXEC sp_rename 
        'dbo.tblHR_WorkScheduleRD.DTime', 
        'DTCreated', 
        'COLUMN';
END
GO

/* 3. Add isActive */
IF COL_LENGTH('dbo.tblHR_WorkScheduleRD', 'isActive') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkScheduleRD
    ADD isActive BIT NOT NULL 
        CONSTRAINT DF_tblHR_WorkScheduleRD_isActive DEFAULT (1);
END
GO

/* 4. Add DTModified */
IF COL_LENGTH('dbo.tblHR_WorkScheduleRD', 'DTModified') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkScheduleRD
    ADD DTModified DATETIME NULL;
END
GO

/* 5. Add LastUpdateBy */
IF COL_LENGTH('dbo.tblHR_WorkScheduleRD', 'LastUpdateBy') IS NULL
BEGIN
    ALTER TABLE dbo.tblHR_WorkScheduleRD
    ADD LastUpdateBy VARCHAR(55) NULL;
END
GO