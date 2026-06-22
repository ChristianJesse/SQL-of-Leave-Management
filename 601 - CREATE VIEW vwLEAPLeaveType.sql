CREATE or ALTER VIEW vwLEAPLeaveType
AS
SELECT DISTINCT
    LeaveCode AS Value,
    LeaveDesc AS Description,
    LeaveCode + ' - ' + LeaveDesc AS LeaveType,
    EndDate
FROM tblHR_AbsentType
WHERE EndDate > GETDATE();
GO