IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'tblHR_PeriodSchedule'
)
BEGIN
    CREATE TABLE dbo.tblHR_PeriodSchedule (
        [PID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Period] VARCHAR(3) NOT NULL,
        [MonthStart] VARCHAR(2) NOT NULL,
        [MonthEnd] VARCHAR(2) NOT NULL,
		[DTCreated] DATETIME NULL,
		[CreatedBy] VARCHAR(55) NULL,
		[DTModified] DATETIME NULL,
		[LastUpdateBy] VARCHAR(55) NULL
    );

    PRINT 'Table tblHR_PeriodSchedule successfully created.';
END
ELSE
BEGIN
    PRINT 'Table tblHR_PeriodSchedule already exists. Creation skipped.';
END