CREATE TRIGGER trtblHR_PersonnelMasterAddLeaveQuota
ON tblHR_PersonnelMaster
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pIDNumber NVARCHAR(50);

    DECLARE cur CURSOR FOR
    SELECT i.IDNumber FROM inserted i
    LEFT JOIN deleted d ON i.IDNumber = d.IDNumber
    WHERE i.DTRegular IS NOT NULL
      AND ( d.IDNumber IS NULL           -- New record
            OR ISNULL(i.DTRegular,'1900-01-01') <> ISNULL(d.DTRegular,'1900-01-01') -- DTRegular changed
          );

    OPEN cur;

    FETCH NEXT FROM cur INTO @pIDNumber;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC spLEAP @pOption = 37, @pIDNumber = @pIDNumber

        FETCH NEXT FROM cur INTO @pIDNumber;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
















