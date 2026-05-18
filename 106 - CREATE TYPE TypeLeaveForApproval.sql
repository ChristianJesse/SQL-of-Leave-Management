


DROP TYPE typeLeaveForApproval
GO
CREATE TYPE typeLeaveForApproval AS TABLE
( 
LeaveType VARCHAR(55)
,DTFrom DATETIME
,DTTo DATETIME
,WorkHrs TINYINT
,Reason VARCHAR(55)
,DTNotice DATETIME
,FileNotice VARCHAR(55)
,ReasonDesc VARCHAR(max)
);
GO






