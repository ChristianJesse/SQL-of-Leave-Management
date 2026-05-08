CREATE OR ALTER TRIGGER trtblHR_AbsentTypeLogs
ON tblHR_AbsentType
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @User VARCHAR(55) = SYSTEM_USER;
    DECLARE @Now DATETIME = GETDATE();

    /* INSERT */
    INSERT INTO tblHR_AbsentTypeLogs (
        Activity, LeaveCode, LeaveDesc, AbsentType,
        ChargeToLeaved, EndDate, FillingNotice, WithQuota,
        LeavedColor, ChargeToLeaveType,
        Active, CreatedBy, DTCreted, LastUpdateBy, DTModified
    )
    SELECT 
        'INSERT',
        i.LeaveCode,
        i.LeaveDesc,
        i.AbsentType,
        i.ChargeToLeaved,
        i.EndDate,
        i.FillingNotice,
        i.WithQuota,
        i.LeavedColor,
        i.ChargeToLeaveType,
        1,                  -- default Active
        @User,
        @Now,
        NULL,
        NULL
    FROM inserted i
    LEFT JOIN deleted d ON i.LeaveCode = d.LeaveCode
    WHERE d.LeaveCode IS NULL;

    /* UPDATE */
    INSERT INTO tblHR_AbsentTypeLogs (
        Activity, LeaveCode, LeaveDesc, AbsentType,
        ChargeToLeaved, EndDate, FillingNotice, WithQuota,
        LeavedColor, ChargeToLeaveType,
        Active, CreatedBy, DTCreted, LastUpdateBy, DTModified
    )
    SELECT 
        'UPDATE',
        i.LeaveCode,
        i.LeaveDesc,
        i.AbsentType,
        i.ChargeToLeaved,
        i.EndDate,
        i.FillingNotice,
        i.WithQuota,
        i.LeavedColor,
        i.ChargeToLeaveType,
        1,
        NULL,
        NULL,
        @User,
        @Now
    FROM inserted i
    INNER JOIN deleted d ON i.LeaveCode = d.LeaveCode;

    /* DELETE */
    INSERT INTO tblHR_AbsentTypeLogs (
        Activity, LeaveCode, LeaveDesc, AbsentType,
        ChargeToLeaved, EndDate, FillingNotice, WithQuota,
        LeavedColor, ChargeToLeaveType,
        Active, CreatedBy, DTCreted, LastUpdateBy, DTModified
    )
    SELECT 
        'DELETE',
        d.LeaveCode,
        d.LeaveDesc,
        d.AbsentType,
        d.ChargeToLeaved,
        d.EndDate,
        d.FillingNotice,
        d.WithQuota,
        d.LeavedColor,
        d.ChargeToLeaveType,
        0,          -- mark inactive on delete
        NULL,
        NULL,
        @User,
        @Now
    FROM deleted d
    LEFT JOIN inserted i ON i.LeaveCode = d.LeaveCode
    WHERE i.LeaveCode IS NULL;

END;
GO

















