CREATE OR ALTER TRIGGER trtblHR_LogsWorkScheduleRD
ON tblHR_WorkScheduleRD
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @User VARCHAR(55) = SYSTEM_USER;
    DECLARE @Now DATETIME = GETDATE();

	-- 1. INSERT BLOCK 
    INSERT INTO tblHR_LogsWorkScheduleRD (
        Activity, SchedCode, RestDay, CreatedBy, DTCreated,
        isActive, DTModified, LastUpdateBy
    )
    SELECT
        'INSERT', i.SchedCode, i.RestDay, @User, @Now,
        i.isActive, NULL, NULL
    FROM inserted i
    LEFT JOIN deleted d ON i.SchedCode = d.SchedCode
    WHERE d.SchedCode IS NULL;

    -- 2. UPDATE BLOCK 
    INSERT INTO tblHR_LogsWorkScheduleRD (
		Activity, SchedCode, RestDay, CreatedBy,
        DTCreated,  isActive, DTModified, LastUpdateBy 
    )
    SELECT
        'UPDATE', i.SchedCode, i.RestDay, NULL,
        NULL, i.isActive, @Now, @User  
    FROM inserted i
    INNER JOIN deleted d ON i.SchedCode = d.SchedCode;

    -- 3. DELETE BLOCK 
    INSERT INTO tblHR_LogsWorkScheduleRD (
        Activity,  SchedCode,  RestDay, CreatedBy,
        DTCreated, isActive, DTModified, LastUpdateBy 
    )
    SELECT
        'DELETE', d.SchedCode, d.RestDay, NULL,
        NULL, 0, @Now, @User 
    FROM deleted d
    LEFT JOIN inserted i ON i.SchedCode = d.SchedCode
    WHERE i.SchedCode IS NULL;

END;
GO

PRINT 'Trigger trtblHR_LogsWorkScheduleRD created successfully.';