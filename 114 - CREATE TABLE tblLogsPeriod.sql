IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'tblLogsPeriod'
)
BEGIN
    CREATE TABLE tblLogsPeriod (
        LogID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Activity VARCHAR(55) NULL,

		[PID] INT NOT NULL,
        [Period] VARCHAR(3) NOT NULL,
		[Description] VARCHAR(MAX) NOT NULL,
        [MonthStart] DATE NOT NULL,
        [MonthEnd] DATE NOT NULL,
		[Year] VARCHAR(4) NOT NULL,
		[DTCreated] DATETIME NULL,
		[CreatedBy] VARCHAR(55) NULL,
		[DTModified] DATETIME NULL,
		[LastUpdateBy] VARCHAR(55) NULL
    );

    PRINT 'tblLogsPeriod table created successfully.';
END
ELSE
BEGIN
    PRINT 'tblLogsPeriod table already exists.';
END
GO