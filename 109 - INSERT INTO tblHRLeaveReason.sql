INSERT INTO tblHRLeaveReason
( 
ReasonCode,ReasonDescription,NoticePeriod,Remarks,isActive,LeaveCode,DTCreated,CreatedBy
)
VALUES
(
'RFM','Forced Majeure',0,'This will be applicable for the announced forced leave of the management',1, 'VL' ,GETDATE(),ORIGINAL_LOGIN()
);

