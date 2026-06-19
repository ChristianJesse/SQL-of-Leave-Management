PRINT 'BEFORE: '
SELECT * FROM tblConfiguration
WHERE Category = 'LEAP' AND Code = 'LeaveGroup'

IF NOT EXISTS (SELECT 1 FROM tblConfiguration WHERE Category = 'LEAP' AND Code = 'LeaveGroup')
	BEGIN
		INSERT INTO tblConfiguration 
		(Category, Code, Description, Value, IsActive, CreationDate, CreatedBy, ModifiedDate, ModifiedBy)
		VALUES
		('LEAP', 'LeaveGroup', 'Use to compute the Leave in Days', 8, 1, GETDATE(), SUSER_NAME(), NULL, NULL)
	END

PRINT 'AFTER: '
SELECT * FROM tblConfiguration
WHERE Category = 'LEAP' AND Code = 'LeaveGroup'