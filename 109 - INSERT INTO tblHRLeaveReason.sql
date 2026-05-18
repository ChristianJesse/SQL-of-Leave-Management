INSERT INTO tblLEAPLeaveReason
( 
ReasonCode,ReasonDescription,NoticePeriod,Remarks,isActive,LeaveCode,DTCreated,CreatedBy
)
VALUES
('UBL','Urgent Birtday',0,'This will be applicable for the announced Birtday of the management',1, 'VL' ,GETDATE(),ORIGINAL_LOGIN()),
('RFM','Forced Majeure',0,'This will be applicable for the announced forced leave of the management',1, 'VL' ,GETDATE(),ORIGINAL_LOGIN());

