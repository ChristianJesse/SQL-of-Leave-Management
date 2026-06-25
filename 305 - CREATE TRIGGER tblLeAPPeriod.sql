
CREATE OR ALTER TRIGGER trtblLEAPLeavePeriodHeader
ON tblLEAPLeavePeriodHeader
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Msg NVARCHAR(MAX);

    /* BLOCK ONLY IF NEW RANGE IS FULLY COVERED BY EXISTING RANGE */
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN tblLEAPLeavePeriodHeader t
            ON  t.LeaveCode      = i.LeaveCode
            AND t.PeriodSpecific = i.PeriodSpecific
            AND t.LPHID <> i.LPHID
            AND t.DTFrom <= i.DTFrom
            AND t.DTTo   >= i.DTTo
    )
    BEGIN
        SELECT @Msg =
            'Invalid Leave Type Quota: Range is fully covered by existing record(s). ID(s): ' +
            STUFF((
                SELECT ', ' + CAST(t.LPHID AS NVARCHAR)
                FROM inserted i
                JOIN tblLEAPLeavePeriodHeader t
                    ON  t.LeaveCode      = i.LeaveCode
                    AND t.PeriodSpecific = i.PeriodSpecific
                    AND t.LPHID <> i.LPHID
                    AND t.DTFrom <= i.DTFrom
                    AND t.DTTo   >= i.DTTo
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

        THROW 50001, @Msg, 1;
    END
END
GO