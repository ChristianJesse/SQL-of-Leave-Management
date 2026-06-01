

BEGIN TRY
    BEGIN TRANSACTION;

    -- =========================================
    -- Temp Tables
    -- =========================================
    CREATE TABLE #MenuTemp (
        RowId INT IDENTITY(1,1),
        ParentId INT NULL,
        TempParentRowId INT NULL,
        LinkText NVARCHAR(255),
        LinkURL NVARCHAR(255),
        Sort INT,
        ModuleName NVARCHAR(50),
        Official BIT,
        DeviceAlloc BIT,
        MID BIGINT
    );

    CREATE TABLE #RowIdToItemId (
        RowId INT,
        ItemId INT
    );

    CREATE TABLE #InsertedItems (
        RowId INT,
        ItemId INT
    );

    -- =========================================
    -- Variables
    -- =========================================
    DECLARE 
        @pGrandParentID1 INT,
        @lMID BIGINT;

    DECLARE 
        @RowId INT,
        @RowParentId INT,
        @TempParentRowId INT,
        @LinkText NVARCHAR(255),
        @LinkURL NVARCHAR(255),
        @Sort INT,
        @ModuleName NVARCHAR(50),
        @Official BIT,
        @DeviceAlloc BIT,
        @MID BIGINT,
        @NewItemId INT,
        @ItemId INT,
        @ResolvedParentId INT;

    -- =========================================
    -- Get Parent / Module IDs
    -- =========================================
    SELECT @pGrandParentID1 = ItemId
    FROM tblMenu
    WHERE LinkText = 'Human Resource';

    SELECT @lMID = MID FROM tblModule WHERE ModuleCode = 'LeAP';

    -- =========================================
    -- Insert Menu Structure
    -- =========================================
    INSERT INTO #MenuTemp
    ( ParentId, TempParentRowId, LinkText, LinkURL, Sort, ModuleName, Official, DeviceAlloc, MID )
    VALUES
        -- Level 1
        (@pGrandParentID1, NULL, 'LeAP', '', 4, 'SCM', 1, 0, @lMID),

        -- Level 2
        (NULL, 1, 'Post Approved Leave', '../LeAP/LeAPPostApprovedLeaves.aspx', 5, 'SCM', 1, 0, @lMID),
        (NULL, 1, 'MyTeam', '../LeAP/LeAPMyTeam.aspx', 1, 'SCM', 1, 0, @lMID),
        (NULL, 1, 'Maintenance', '', 2, 'SCM', 1, 0, @lMID),

        -- Level 3
        (NULL, 4, 'Leaves', '../LeAP/LeAPLeaveMaintenance.aspx', 1, 'SCM', 1, 0, @lMID),
        (NULL, 4, 'Leave Reasons', '../LeAP/LeAPReasonMaintenance.aspx', 2, 'SCM', 1, 0, @lMID),
        (NULL, 4, 'Schedules', '../LeAP/LeAPScheduleMaintenance.aspx', 3, 'SCM', 1, 0, @lMID),
        (NULL, 4, 'Holidays', '../LeAP/LeAPHolidayMaintenance.aspx', 4, 'SCM', 1, 0, @lMID),
        (NULL, 4, 'Leave Quota', '../LeAP/LeAPLeaveQuotaMaintenance.aspx', 5, 'SCM', 1, 0, @lMID);

    -- =========================================
    -- Cursor
    -- =========================================
    DECLARE MenuCursor CURSOR FOR
    SELECT RowId, ParentId, TempParentRowId, LinkText, LinkURL, Sort, ModuleName, Official, DeviceAlloc, MID
    FROM #MenuTemp
    ORDER BY RowId;

    OPEN MenuCursor;

    FETCH NEXT FROM MenuCursor INTO
        @RowId,
        @RowParentId,
        @TempParentRowId,
        @LinkText,
        @LinkURL,
        @Sort,
        @ModuleName,
        @Official,
        @DeviceAlloc,
        @MID;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        -- =========================================
        -- Delete Existing
        -- =========================================
        IF EXISTS (
            SELECT 1
            FROM tblMenu
            WHERE LinkText = @LinkText
              AND LinkURL = @LinkURL
        )
        BEGIN
            SELECT @ItemId = ItemId
            FROM tblMenu
            WHERE LinkText = @LinkText
              AND LinkURL = @LinkURL;

            DELETE FROM tblMenuObjectAccess
            WHERE AccessId IN (
                SELECT AccessId
                FROM tblMenuUserAccess
                WHERE ItemId = @ItemId
            );

            IF OBJECT_ID('dbo.tblModuleAccessDetails', 'U') IS NOT NULL
               AND OBJECT_ID('dbo.tblObjects', 'U') IS NOT NULL
            BEGIN
                DELETE FROM tblModuleAccessDetails
                WHERE ObjectID IN (
                    SELECT ObjectID
                    FROM tblObjects
                    WHERE ItemId = @ItemId
                );

                DELETE FROM tblObjects
                WHERE ItemId = @ItemId;
            END;

            DELETE FROM tblMenuUserAccess
            WHERE ItemId = @ItemId;

            DELETE FROM tblActivityLogsLinks
            WHERE ItemID = @ItemId;

            DELETE FROM tblMenu
            WHERE ItemId = @ItemId;
        END;

        -- =========================================
        -- Resolve Parent
        -- =========================================
        SELECT @ResolvedParentId =
            COALESCE(
                @RowParentId,
                (
                    SELECT ItemId
                    FROM #RowIdToItemId
                    WHERE RowId = @TempParentRowId
                )
            );

        -- =========================================
        -- Insert Menu
        -- =========================================
        INSERT INTO tblMenu
        (
            ParentId,
            LinkText,
            LinkURL,
            Sort,
            ModuleName,
            Official,
            DeviceAlloc,
            MID
        )
        VALUES
        (
            @ResolvedParentId,
            @LinkText,
            @LinkURL,
            @Sort,
            @ModuleName,
            @Official,
            @DeviceAlloc,
            @MID
        );

        SET @NewItemId = SCOPE_IDENTITY();

        INSERT INTO #RowIdToItemId (RowId, ItemId)
        VALUES (@RowId, @NewItemId);

        INSERT INTO #InsertedItems (RowId, ItemId)
        VALUES (@RowId, @NewItemId);

        FETCH NEXT FROM MenuCursor INTO
            @RowId,
            @RowParentId,
            @TempParentRowId,
            @LinkText,
            @LinkURL,
            @Sort,
            @ModuleName,
            @Official,
            @DeviceAlloc,
            @MID;
    END;

    CLOSE MenuCursor;
    DEALLOCATE MenuCursor;

    -- =========================================
    -- Result
    -- =========================================
    SELECT 
        m.ItemId,
        m.ParentId,
        m.LinkText,
        m.LinkURL,
        m.Sort,
        m.ModuleName,
        m.Official,
        m.DeviceAlloc,
        m.MID
    FROM tblMenu m
    INNER JOIN #InsertedItems i
        ON m.ItemId = i.ItemId
    ORDER BY i.RowId;

    -- =========================================
    -- Cleanup
    -- =========================================
    DROP TABLE #MenuTemp;
    DROP TABLE #RowIdToItemId;
    DROP TABLE #InsertedItems;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DROP TABLE IF EXISTS #MenuTemp;
    DROP TABLE IF EXISTS #RowIdToItemId;
    DROP TABLE IF EXISTS #InsertedItems;

    IF CURSOR_STATUS('global', 'MenuCursor') >= -1
    BEGIN
        CLOSE MenuCursor;
        DEALLOCATE MenuCursor;
    END;

    PRINT 'Error occurred. Transaction rolled back.';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(50));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(50));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(50));

END CATCH;