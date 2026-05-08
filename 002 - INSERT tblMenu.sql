
			DELETE FROM tblMenu WHERE LinkText = 'HR Maintenance'

BEGIN TRY
    BEGIN TRANSACTION;
	
    -- Step 1: Create #MenuTemp
    CREATE TABLE #MenuTemp (
        RowId INT IDENTITY(1, 1),
        ParentId INT,              -- Only set in the first row (real ParentId like 'ITD')
        TempParentRowId INT NULL,  -- Used for internal reference
        LinkText NVARCHAR(255),
        LinkURL NVARCHAR(255),
        Sort INT,
        ModuleName NVARCHAR(50),
        Official BIT,
        DeviceAlloc BIT,
		MID BIGINT
    );

    -- Create mapping between RowId and real ItemId after insertion
    CREATE TABLE #RowIdToItemId (
        RowId INT,
        ItemId INT
    );

	-- Create a table to view all the inserted data later
	CREATE TABLE #InsertedItems (
		RowId INT,
		ItemId INT
	);


    -- Step 2: Insert your structure (sample data)
    DECLARE @pGrandParentID INT,
			@pGrandParentIID INT,
			@lMID BIGINT;
    SELECT @pGrandParentID = ItemId FROM tblMenu WHERE LinkText = 'Human Resource';
	SELECT @lMID = MID FROM tblModule WHERE ModuleCode = 'HR';
    INSERT INTO #MenuTemp (ParentId, TempParentRowId, LinkText, LinkURL, Sort, ModuleName, Official, DeviceAlloc, MID)
    VALUES
        (@pGrandParentID, 1, 'My Team'				, '../HumanResource/HRCalendar.aspx'	, 4, 'SCM', 1, 0, @lMID),
        (@pGrandParentID, 1, 'HR Maintenance'		, ''									, 5, 'SCM', 1, 0, @lMID)


    SELECT @pGrandParentIID = ItemId FROM tblMenu WHERE LinkText = 'HR Maintenance';

	INSERT INTO #MenuTemp (ParentId, TempParentRowId, LinkText, LinkURL, Sort, ModuleName, Official, DeviceAlloc, MID)
    VALUES
        (@pGrandParentIID, 2, 'Leave Maintenance'		, '../HumanResource/HRLeaveMaintenance.aspx'	, 1, 'SCM', 1, 0, @lMID),
        (@pGrandParentIID, 2, 'Leave Reason Maintenance'		, '../HumanResource/HRDashReasonMaintenance.aspx'	, 2, 'SCM', 1, 0, @lMID),
        (@pGrandParentIID, 2, 'Schedule Maintenance'	, '../HumanResource/HRScheduleMaintenance.aspx'	, 3, 'SCM', 1, 0, @lMID),
        (@pGrandParentIID, 2, 'Holiday Tagging'			, '../HumanResource/HRHolidayTaggingMaintenance.aspx'	, 4, 'SCM', 1, 0, @lMID),
        (@pGrandParentIID, 2, 'Maintain Leave Quota'	, '../HumanResource/HRMaintainLeaveQuota.aspx'	, 5, 'SCM', 1, 0, @lMID),
        (@pGrandParentIID, 2, 'Post Approved Leave'		, '../HumanResource/HRDashPostApprovedLeaves.aspx'	, 6, 'SCM', 1, 0, @lMID)
		

    -- Step 3: Loop through each row
   DECLARE @RowId INT, @RowParentId INT, @TempParentRowId INT;
    DECLARE @LinkText NVARCHAR(255), @LinkURL NVARCHAR(255), @Sort INT, @ModuleName NVARCHAR(50);
    DECLARE @Official BIT, @DeviceAlloc BIT, @MID BIGINT,@NewItemId INT, @ItemId INT, @AccessId INT, @ObjectId INT, @ResolvedParentId INT;

    DECLARE MenuCursor CURSOR FOR
    SELECT RowId, ParentId, TempParentRowId, LinkText, LinkURL, Sort, ModuleName, Official, DeviceAlloc, MID
    FROM #MenuTemp
    ORDER BY RowId;

    OPEN MenuCursor;
    FETCH NEXT FROM MenuCursor INTO @RowId, @RowParentId, @TempParentRowId, @LinkText, @LinkURL, @Sort, @ModuleName, @Official, @DeviceAlloc, @MID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Cleanup if already exists
        IF EXISTS (SELECT 1 FROM tblmenu WHERE LinkText = @LinkText AND LinkURL = @LinkURL)
        BEGIN
            SELECT @ItemId = ItemId FROM tblmenu WHERE LinkText = @LinkText AND LinkURL = @LinkURL;

            -- Delete related data

            DELETE FROM tblMenuObjectAccess
            WHERE AccessId IN (Select AccessId FROM tblMenuUserAccess WHERE ItemId = @ItemId)
            IF OBJECT_ID('dbo.tblModuleAccessDetails', 'U') IS NOT NULL
                AND OBJECT_ID('dbo.tblObjects', 'U') IS NOT NULL
            BEGIN
                DELETE FROM tblModuleAccessDetails
                WHERE ObjectID IN (
                    SELECT ObjectID FROM tblObjects WHERE ItemId = @ItemId
                )
                DELETE FROM tblObjects WHERE ItemId = @ItemId;
            END



            DELETE FROM tblMenuUserAccess WHERE ItemId = @ItemId;
            DELETE FROM tblActivityLogsLinks WHERE ItemID = @ItemId;
            DELETE FROM tblmenu WHERE ItemId = @ItemId;
        END


        SELECT @ResolvedParentId = COALESCE(@RowParentId,
            (SELECT ItemId FROM #RowIdToItemId WHERE RowId = @TempParentRowId));


        INSERT INTO tblmenu (ParentId, LinkText, LinkURL, Sort, ModuleName, Official, DeviceAlloc, MID)
        VALUES (@ResolvedParentId, @LinkText, @LinkURL, @Sort, @ModuleName, @Official, @DeviceAlloc,@MID);

        SET @NewItemId = SCOPE_IDENTITY();


        INSERT INTO #RowIdToItemId (RowId, ItemId) 
		VALUES (@RowId, @NewItemId);

		INSERT INTO #InsertedItems (RowId, ItemId)
		VALUES (@RowId, @NewItemId);


        FETCH NEXT FROM MenuCursor INTO @RowId, @RowParentId, @TempParentRowId, @LinkText, @LinkURL, @Sort, @ModuleName, @Official, @DeviceAlloc,@MID;
    END

    CLOSE MenuCursor;
    DEALLOCATE MenuCursor;

    -- Cleanup
    DROP TABLE #MenuTemp;
    DROP TABLE #RowIdToItemId;

	SELECT m.ItemId, m.ParentId, m.LinkText, m.LinkURL, m.Sort, m.ModuleName, m.Official, m.DeviceAlloc, m.MID
	FROM tblmenu m
	JOIN #InsertedItems i ON m.ItemId = i.ItemId
	ORDER BY i.RowId;


    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    DROP TABLE IF EXISTS #MenuTemp, #RowIdToItemId ,#InsertedItems;

    IF CURSOR_STATUS('global', 'MenuCursor') >= 0 BEGIN
        CLOSE MenuCursor;
        DEALLOCATE MenuCursor;
    END
	IF CURSOR_STATUS('global', 'UserAccessCursor') >= 0 BEGIN
        CLOSE UserAccessCursor;
        DEALLOCATE UserAccessCursor;
    END
	IF CURSOR_STATUS('global', 'ButtonAccessCursor') >= 0 BEGIN
		CLOSE ButtonAccessCursor;
		DEALLOCATE ButtonAccessCursor;
    END

    PRINT 'Error occurred. Transaction rolled back.';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
END CATCH;






