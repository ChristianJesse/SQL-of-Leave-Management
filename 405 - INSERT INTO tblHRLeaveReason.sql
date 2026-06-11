INSERT INTO tblLEAPLeaveReason
( 
ReasonCode,ReasonDescription,NoticePeriod,Remarks,isActive,LeaveCode,DTCreated,CreatedBy
)
VALUES
('UBL','Urgent Birtday',0,'This will be applicable for the announced Birtday of the management',1, 'VL' ,GETDATE(),ORIGINAL_LOGIN()),
('RFM','Forced Majeure',0,'This will be applicable for the announced forced leave of the management',1, 'VL' ,GETDATE(),ORIGINAL_LOGIN());

insert into tblLEAPBiometricServers 
values	('192.168.3.46','4370','WTO' ,'WTO Biometric Server',ORIGINAL_LOGIN(),GETDATE(),NULL,NULL),
		('192.168.1.40','4370','FCIE','FCIE Biometric Server',ORIGINAL_LOGIN(),GETDATE(),NULL,NULL),
		--('192.168.1.204','4370','JYC','JYC Biometric Server',ORIGINAL_LOGIN(),GETDATE(),NULL,NULL),
		('192.168.3.61','4370','Test','Test server',ORIGINAL_LOGIN(),GETDATE(),NULL,NULL)

