IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.tblLeAPLeaveReasonAssignment') AND type in (N'U'))
    BEGIN
        CREATE TABLE dbo.tblLeAPLeaveReasonAssignment (
            [RMID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            [ReasonCode] VARCHAR(10) NOT NULL,
            [LeaveCode] VARCHAR(10) NOT NULL,
            [DTCreated] DATETIME NULL,
            [CreatedBy] VARCHAR(55) NULL,
            [DTModified] DATETIME NULL,
            [LastUpdateBy] VARCHAR(55) NULL
        );
        PRINT 'Table ''tblLeAPLeaveReasonAssignment'' created successfully.';
    END
ELSE 
    BEGIN
        PRINT 'Table ''tblLeAPLeaveReasonAssignment'' already exists. Skipping...';
    END