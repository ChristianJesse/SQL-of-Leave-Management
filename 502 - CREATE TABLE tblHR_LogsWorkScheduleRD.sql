IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'tblHR_LogsWorkScheduleRD'
)
BEGIN
    CREATE TABLE tblHR_LogsWorkScheduleRD (
        LogID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Activity VARCHAR(55) NULL,

        SchedCode VARCHAR(10) NOT NULL,
        RestDay TINYINT NOT NULL,

        CreatedBy VARCHAR(55) NULL,
        DTCreated DATETIME NULL,
        isActive BIT NOT NULL,
        DTModified DATETIME NULL,
        LastUpdateBy VARCHAR(55) NULL
    );

    PRINT 'tblHR_LogsWorkScheduleRD table created successfully.';
END
ELSE
BEGIN
    PRINT 'tblHR_LogsWorkScheduleRD table already exists.';
END
GO