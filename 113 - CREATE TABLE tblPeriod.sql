IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'tblPeriod'
)
BEGIN
    CREATE TABLE dbo.tblPeriod (
        [PID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
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

    PRINT 'Table tblPeriod successfully created.';
END
ELSE
BEGIN
    PRINT 'Table tblPeriod already exists. Creation skipped.';
END