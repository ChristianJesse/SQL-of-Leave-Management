CREATE or ALTER TRIGGER trtblHR_LogsWorkSchedule
ON tblHR_WorkSchedule
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @User VARCHAR(55) = SYSTEM_USER;
    DECLARE @Now DATETIME = GETDATE();

    -- 1. INSERT BLOCK 
    INSERT INTO tblHR_LogsWorkSchedule (
        Activity, SchedCode, SchedDesc, FirstHalf, SecondHalf, WholeDay, 
        isActive, CreatedBy, DTCreated, DTModified, LastUpdateBy
    )
    SELECT
        'INSERT', i.SchedCode, i.SchedDesc, i.FirstHalf, i.SecondHalf, i.WholeDay, 
        i.isActive, @User, @Now, NULL, NULL
    FROM inserted i
    LEFT JOIN deleted d ON i.SchedCode = d.SchedCode
    WHERE d.SchedCode IS NULL;

    -- 2. UPDATE BLOCK 
    INSERT INTO tblHR_LogsWorkSchedule (
        Activity, SchedCode, SchedDesc, FirstHalf, SecondHalf, WholeDay, 
        isActive, CreatedBy, DTCreated, DTModified, LastUpdateBy
    )
    SELECT
        'UPDATE', i.SchedCode, i.SchedDesc, i.FirstHalf, i.SecondHalf, i.WholeDay, 
        i.isActive, NULL, NULL, @Now, @User  -- 
    FROM inserted i
    INNER JOIN deleted d ON i.SchedCode = d.SchedCode;

    -- 3. DELETE BLOCK 
    INSERT INTO tblHR_LogsWorkSchedule (
        Activity, SchedCode, SchedDesc, FirstHalf, SecondHalf, WholeDay, 
        isActive, CreatedBy, DTCreated, DTModified, LastUpdateBy
    )
    SELECT
        'DELETE', d.SchedCode, d.SchedDesc, d.FirstHalf, d.SecondHalf, d.WholeDay, 
        d.isActive, NULL, NULL, @Now, @User  
    FROM deleted d
    LEFT JOIN inserted i ON i.SchedCode = d.SchedCode
    WHERE i.SchedCode IS NULL;
END;
GO

PRINT 'Trigger trtblHR_LogsWorkSchedule created successfully.';