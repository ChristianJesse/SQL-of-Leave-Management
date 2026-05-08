CREATE OR ALTER TRIGGER trTblHRLeaveReasonLogs
ON dbo.tblHRLeaveReason
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @User VARCHAR(55) = SYSTEM_USER;

    /* =========================================
       INSERT
    ========================================= */
    INSERT INTO dbo.tblHRLeaveReasonLogs
    (
        Activity,
        LeaveCode,
        ReasonCode,
        ReasonDescription,
        NoticePeriod,
        Remarks,
        isActive,
        DTCreated,
        CreatedBy,
        DTModified,
        LastUpdateBy
    )
    SELECT
        'INSERT',
        i.LeaveCode,
        i.ReasonCode,
        i.ReasonDescription,
        i.NoticePeriod,
        i.Remarks,
        i.isActive,
        i.DTCreated,
        i.CreatedBy,
        i.DTModified,
        i.LastUpdateBy
    FROM inserted i
    LEFT JOIN deleted d ON i.ReasonID = d.ReasonID
    WHERE d.ReasonID IS NULL;

    /* =========================================
       UPDATE
    ========================================= */
    INSERT INTO dbo.tblHRLeaveReasonLogs
    (
        Activity,
        LeaveCode,
        ReasonCode,
        ReasonDescription,
        NoticePeriod,
        Remarks,
        isActive,
        DTCreated,
        CreatedBy,
        DTModified,
        LastUpdateBy
    )
    SELECT
        'UPDATE',
        i.LeaveCode,
        i.ReasonCode,
        i.ReasonDescription,
        i.NoticePeriod,
        i.Remarks,
        i.isActive,
        i.DTCreated,
        i.CreatedBy,
        i.DTModified,
        i.LastUpdateBy
    FROM inserted i
    INNER JOIN deleted d ON i.ReasonID = d.ReasonID;

    /* =========================================
       DELETE
    ========================================= */
    INSERT INTO dbo.tblHRLeaveReasonLogs
    (
        Activity,
        LeaveCode,
        ReasonCode,
        ReasonDescription,
        NoticePeriod,
        Remarks,
        isActive,
        DTCreated,
        CreatedBy,
        DTModified,
        LastUpdateBy
    )
    SELECT
        'DELETE',
        d.LeaveCode,
        d.ReasonCode,
        d.ReasonDescription,
        d.NoticePeriod,
        d.Remarks,
        d.isActive,
        d.DTCreated,
        d.CreatedBy,
        d.DTModified,
        d.LastUpdateBy
    FROM deleted d
    LEFT JOIN inserted i ON i.ReasonID = d.ReasonID
    WHERE i.ReasonID IS NULL;

END
GO