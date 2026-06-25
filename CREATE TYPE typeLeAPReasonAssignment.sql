IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'typeLeAPLeaveReasonAssignment')
    BEGIN
        CREATE TYPE dbo.typeLeAPLeaveReasonAssignment AS TABLE (
            LeaveCode VARCHAR(20) NOT NULL
        );
        PRINT 'Table Type ''typeLeAPLeaveReasonAssignment'' created successfully.';
    END
ELSE
    BEGIN
        PRINT 'Table Type ''typeLeAPLeaveReasonAssignment'' already exists. Skipping...';
    END