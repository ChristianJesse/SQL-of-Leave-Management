PRINT 'BEFORE';
EXEC sp_help 'tblCCD_Holiday';

-- Check if HID column already exists
IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE Name = N'HID'
      AND Object_ID = Object_ID(N'tblCCD_Holiday')
)
BEGIN
    ALTER TABLE tblCCD_Holiday
    ADD HID INT IDENTITY(1,1) PRIMARY KEY;

    PRINT 'HID column added successfully.';
END
ELSE
BEGIN
    PRINT 'HID column already exists.';
END

PRINT 'AFTER';
EXEC sp_help 'tblCCD_Holiday';