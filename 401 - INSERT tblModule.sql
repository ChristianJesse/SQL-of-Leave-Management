-- Before
SELECT 'Before' AS Status, *
FROM tblModule
WHERE ModuleCode = 'LeAP' AND [Description] = 'Leave and Attendance Processing';

IF NOT EXISTS (SELECT 1 FROM tblModule WHERE ModuleCode = 'LeAP' AND [Description] = 'Leave and Attendance Processing')
BEGIN
    PRINT 'Inserting new record into tblModule...';
    INSERT INTO tblModule (ModuleCode,[Description],Active,CreatedBy,DTCreated)
    VALUES ('LeAP','Leave and Attendance Processing',1,ORIGINAL_LOGIN(),GETDATE());
END
ELSE
BEGIN
    PRINT 'Updating existing record in tblModule...';
    UPDATE tblModule
    SET 
        [Description] = 'Leave and Attendance Processing',
        Active = 1,
        UpdatedBy = ORIGINAL_LOGIN(),
        DTUpdated = GETDATE()
    WHERE ModuleCode = 'LeAP';
END

-- After
SELECT 'After' AS Status, *
FROM tblModule
WHERE ModuleCode = 'LeAP' AND [Description] = 'Leave and Attendance Processing';
