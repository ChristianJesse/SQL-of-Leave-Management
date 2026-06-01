DROP TYPE typeHRMLQLeaveTypes
GO
CREATE TYPE typeHRMLQLeaveTypes AS TABLE
( 
LeaveType Varchar(10),
DTFrom Date,
DTTo Date,
Quota TinyInt
);
GO
