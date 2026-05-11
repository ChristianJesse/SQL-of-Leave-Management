



DROP TYPE IF EXISTS typeHRMLQSelectedEmployee
GO
CREATE TYPE typeHRMLQSelectedEmployee AS TABLE
( 
UserName		VARCHAR(55),
IDNumber		VARCHAR(55),
EmployeeName	VARCHAR(155),
Position		VARCHAR(55),
DepartmentCode	VARCHAR(55),
UnitCode		VARCHAR(55),
CostCenter		VARCHAR(55),
LeaveType		VARCHAR(55),
Quota			VARCHAR(55),
Periods			VARCHAR(55),
Status			VARCHAR(55)
);
GO



