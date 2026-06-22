
INSERT INTO tblReferenceMaster (
	RCategory, RCode, RValue, RSwitch, MID, 
	RDesc, DTCreated, CreatedBy, ModifiedDate, ModifiedBy
) VALUES 
	( 'LeAPPeriod', 'H1', 'H1', '0', '26',
	'First Half', GETDATE(), SUSER_NAME(), NULL, NULL ),

	('LeAPPeriod', 'H2', 'H2', '0', '26',
	'Second Half', GETDATE(), SUSER_NAME(), NULL, NULL ),

	( 'LeAPPeriod', 'HY', 'HY', '0', '26',
	'Whole Year', GETDATE(), SUSER_NAME(), NULL, NULL )
