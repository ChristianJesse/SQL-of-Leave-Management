
INSERT INTO tblReferenceMaster (
	RCategory, RCode, RValue, RSwitch, MID, 
	RDesc, DTCreated, CreatedBy, ModifiedDate, ModifiedBy
) VALUES 
	( 'LeAPPeriod', 'H1', 'H1', '0', '27',
	'First Half', GETDATE(), SUSER_NAME(), NULL, NULL ),

	('LeAPPeriod', 'H2', 'H2', '0', '27',
	'Second Half', GETDATE(), SUSER_NAME(), NULL, NULL ),

	( 'LeAPPeriod', 'HY', 'HY', '0', '27',
	'Whole Year', GETDATE(), SUSER_NAME(), NULL, NULL )


	INSERT INTO tblReferenceMaster 
(RCategory, RCode, RValue, RSwitch, MID, RDesc, DTCreated, CreatedBy, ModifiedDate, ModifiedBy)
VALUES
('LeAPLeaveTypeProRataC', 'N', 'None', 0, 27,'Pro-Rata Computation None', GETDATE(), SUSER_NAME(), NULL, NULL),
('LeAPLeaveTypeProRataC', 'P', 'Pro-rated', 0, 27,'Pro-Rata Computation Pro-Rated', GETDATE(), SUSER_NAME(), NULL, NULL),
('LeAPLeaveTypeProRataC', 'E', 'Earned', 0, 27,'Pro-Rata Computation Earned', GETDATE(), SUSER_NAME(), NULL, NULL)


	INSERT INTO tblReferenceMaster 
(RCategory, RCode, RValue, RSwitch, MID, RDesc, DTCreated, CreatedBy, ModifiedDate, ModifiedBy)
VALUES
('LeAPLeaveTypeUnit', 'D', 'Days', 0, 27,'Leave Type Unit for Filing and Notice - Days', GETDATE(), SUSER_NAME(), NULL, NULL),
('LeAPLeaveTypeUnit', 'H', 'Hours', 0, 27,'Leave Type Unit for Filing and Notice - Hours', GETDATE(), SUSER_NAME(), NULL, NULL)


SELECT * FROM tblReferenceMaster