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
        Activity, LeaveCode, LeaveDesc, AbsentType, ChargeToLeave, EndDate, 
        Filing, FilingUnit, Notice, NoticeUnit, WithQuota, LeaveColor, ChargeToLeaveType,
        DateSpecific, PeriodSpecific, EarnedLeave, DateRegularized, DateSeparated,
        Active, CreatedBy, DTCreted, LastUpdateBy, DTModified
    )
    SELECT 
        'INSERT',
        i.LeaveCode,
        i.LeaveDesc,
        i.AbsentType,
        i.ChargeToLeave,
        i.EndDate,
        i.Filing,
        i.FilingUnit,
        i.Notice,
        i.NoticeUnit,
        i.WithQuota,
        i.LeaveColor,
        i.ChargeToLeaveType,
        i.DateSpecific,
        i.PeriodSpecific,
        i.EarnedLeave,
        i.DateRegularized,
        i.DateSeparated,
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
        Activity, LeaveCode, LeaveDesc, AbsentType, ChargeToLeave, EndDate, 
        Filing, FilingUnit, Notice, NoticeUnit, WithQuota, LeaveColor, ChargeToLeaveType,
        DateSpecific, PeriodSpecific, EarnedLeave, DateRegularized, DateSeparated,
        Active, CreatedBy, DTCreted, LastUpdateBy, DTModified
    )
    SELECT 
        'UPDATE',
        i.LeaveCode,
        i.LeaveDesc,
        i.AbsentType,
        i.ChargeToLeave,
        i.EndDate,
        i.Filing,
        i.FilingUnit,
        i.Notice,
        i.NoticeUnit,
        i.WithQuota,
        i.LeaveColor,
        i.ChargeToLeaveType,
        i.DateSpecific,
        i.PeriodSpecific,
        i.EarnedLeave,
        i.DateRegularized,
        i.DateSeparated,
        1,
        NULL,
        NULL,
        @User,
        @Now
    FROM inserted i
    INNER JOIN deleted d ON i.LeaveCode = d.LeaveCode;

    /* DELETE */
    INSERT INTO tblHR_AbsentTypeLogs (
        Activity, LeaveCode, LeaveDesc, AbsentType, ChargeToLeave, EndDate, 
        Filing, FilingUnit, Notice, NoticeUnit, WithQuota, LeaveColor, ChargeToLeaveType,
        DateSpecific, PeriodSpecific, EarnedLeave, DateRegularized, DateSeparated,
        Active, CreatedBy, DTCreted, LastUpdateBy, DTModified
    )
    SELECT 
        'DELETE',
        d.LeaveCode,
        d.LeaveDesc,
        d.AbsentType,
        d.ChargeToLeave,
        d.EndDate,
        d.Filing,
        d.FilingUnit,
        d.Notice,
        d.NoticeUnit,
        d.WithQuota,
        d.LeaveColor,
        d.ChargeToLeaveType,
        d.DateSpecific,
        d.PeriodSpecific,
        d.EarnedLeave,
        d.DateRegularized,
        d.DateSeparated,
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