


DROP TYPE typeLeaveForApproval
GO
CREATE TYPE typeLeaveForApproval AS TABLE
( 
LeaveType VARCHAR(55)
,DTLeave DATETIME
,LeaveHrsFrom VARCHAR(55)
,LeaveHrsTo VARCHAR(55)
,WorkHrs TINYINT
,ReasonCode VARCHAR(55)
,DTNotice DATETIME
,FileNotice VARCHAR(55)
,ReasonDesc VARCHAR(max)
);
GO







