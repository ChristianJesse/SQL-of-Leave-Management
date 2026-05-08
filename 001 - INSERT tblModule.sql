-- Before
SELECT 'Before' AS Status, *
FROM tblModule
WHERE ModuleCode = 'HR' AND [Description] = 'Human Resource';

IF NOT EXISTS (SELECT 1 FROM tblModule WHERE ModuleCode = 'HR' AND [Description] = 'Human Resource')
BEGIN
    PRINT 'Inserting new record into tblModule...';
    INSERT INTO tblModule (ModuleCode,[Description],Active,CreatedBy,DTCreated)
    VALUES ('HR','Human Resource',1,ORIGINAL_LOGIN(),GETDATE());
END
ELSE
BEGIN
    PRINT 'Updating existing record in tblModule...';
    UPDATE tblModule
    SET 
        [Description] = 'Human Resource',
        Active = 1,
        UpdatedBy = ORIGINAL_LOGIN(),
        DTUpdated = GETDATE()
    WHERE ModuleCode = 'HR';
END

-- After
SELECT 'After' AS Status, *
FROM tblModule
WHERE ModuleCode = 'HR' AND [Description] = 'Human Resource';
