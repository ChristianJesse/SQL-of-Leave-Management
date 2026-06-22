CREATE OR ALTER TRIGGER trtbLogsPeriod
ON tblPeriod
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @User VARCHAR(55) = SYSTEM_USER;
    DECLARE @Now DATETIME = GETDATE();

	-- 1. INSERT BLOCK 
    INSERT INTO tblLogsPeriod (
        Activity, PID, Period, MonthStart, MonthEnd, DTCreated, CreatedBy, DTModified, LastUpdateBy
    )
    SELECT
        'INSERT', i.PID, i.Period, i.MonthStart, i.MonthEnd, @Now, @User, NULL, NULL
    FROM inserted i
    LEFT JOIN deleted d ON i.Period = d.Period
    WHERE d.Period IS NULL;

    -- 2. UPDATE BLOCK 
    INSERT INTO tblLogsPeriod (
		Activity, PID, Period, MonthStart, MonthEnd, DTCreated, CreatedBy, DTModified, LastUpdateBy
    )
    SELECT
        'UPDATE', i.PID, i.Period, i.MonthStart, i.MonthEnd, NULL, NULL, @Now, @User
    FROM inserted i
    INNER JOIN deleted d ON i.Period = d.Period;

    -- 3. DELETE BLOCK 
	INSERT INTO tblLogsPeriod (
		Activity, PID, Period, MonthStart, MonthEnd,
		DTCreated, CreatedBy, DTModified, LastUpdateBy 
	)
	SELECT
		'DELETE',
		d.PID,
		d.Period,
		d.MonthStart,
		d.MonthEnd,
		NULL,
		NULL,
		@Now,
		@User
	FROM deleted d
	LEFT JOIN inserted i ON i.Period = d.Period
	WHERE i.Period IS NULL;

END;
GO

PRINT 'Trigger trtblLogPeriod created successfully.';