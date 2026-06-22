DROP TYPE typeHRMLQLeaveTypes
GO
CREATE TYPE typeHRMLQLeaveTypes AS TABLE
( 
ID BIGINT NULL,   
PeriodSpecific BIT,
Year INT,
LeaveType Varchar(10),
DTFrom Date,
DTTo Date,
Quota TinyInt
);
GO
