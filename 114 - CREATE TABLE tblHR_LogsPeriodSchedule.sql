IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'tblHR_LogsPeriodSchedule'
)
BEGIN
    CREATE TABLE tblHR_LogsPeriodSchedule (
        LogID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Activity VARCHAR(55) NULL,

		[PID] INT NOT NULL,
        [Period] VARCHAR(3) NOT NULL,
        [MonthStart] VARCHAR(2) NOT NULL,
        [MonthEnd] VARCHAR(2) NOT NULL,
		[DTCreated] DATETIME NULL,
		[CreatedBy] VARCHAR(55) NULL,
		[DTModified] DATETIME NULL,
		[LastUpdateBy] VARCHAR(55) NULL
    );

    PRINT 'tblHR_LogsPeriodSchedule table created successfully.';
END
ELSE
BEGIN
    PRINT 'tblHR_LogsPeriodSchedule table already exists.';
END
GO