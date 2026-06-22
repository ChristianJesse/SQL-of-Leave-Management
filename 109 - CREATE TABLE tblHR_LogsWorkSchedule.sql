IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'tblHR_LogsWorkSchedule'
)
BEGIN
    CREATE TABLE tblHR_LogsWorkSchedule (
        LogID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Activity VARCHAR(55) NULL,

        SchedCode VARCHAR(10) NOT NULL,
        SchedDesc VARCHAR(60) NULL,
        FirstHalf VARCHAR(12) NULL,
        SecondHalf VARCHAR(12) NULL,
        WholeDay VARCHAR(12) NULL,
        isActive BIT NOT NULL,

        CreatedBy VARCHAR(55) NULL,
        DTCreated DATETIME NULL,
        DTModified DATETIME NULL,
        LastUpdateBy VARCHAR(55) NULL
    );

    PRINT 'tblHR_LogsWorkSchedule table created successfully.';
END
ELSE
	BEGIN
		PRINT 'tblHR_LogsWorkSchedule table already exists.';
	END
GO