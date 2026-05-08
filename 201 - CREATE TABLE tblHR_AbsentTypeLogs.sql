SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblHR_AbsentTypeLogs
-- =========================================
DECLARE @TableName SYSNAME = 'tblHR_AbsentTypeLogs';
DECLARE @name NVARCHAR(128), @create_date DATETIME, @modify_date DATETIME;

SELECT @name = name, @create_date = create_date, @modify_date = modify_date
FROM sys.tables
WHERE name = @TableName;

PRINT 'BEFORE'
SELECT 
    c.name AS [Column Name],
    ep.value AS [Description]
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
LEFT JOIN sys.extended_properties ep 
    ON ep.major_id = t.object_id 
    AND ep.minor_id = c.column_id 
    AND ep.name = 'MS_Description'
WHERE t.name = @TableName
ORDER BY c.column_id;

IF OBJECT_ID(@TableName, 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblHR_AbsentTypeLogs
    (	
        [LogID]                BIGINT IDENTITY(1,1) PRIMARY KEY,
        [Activity]             VARCHAR(55) NULL,
        [LeaveCode]            VARCHAR(10) NOT NULL,
        [LeaveDesc]            VARCHAR(50) NULL,
        [AbsentType]           VARCHAR(4) NULL,
        [ChargeToLeaved]       BIT NULL,
        [EndDate]              DATE NULL,
        [FillingNotice]        TINYINT NOT NULL,
        [WithQuota]            BIT NOT NULL,
        [LeavedColor]          VARCHAR(55) NULL,
        [ChargeToLeaveType]    VARCHAR(10) NULL,
		[Active]			   BIT NULL,
        [CreatedBy]             VARCHAR(55) NULL,
        [DTCreted]             DATETIME DEFAULT GETDATE(),
        [LastUpdateBy]          VARCHAR(55) NULL,
		[DTModified]            DATETIME DEFAULT GETDATE()
		
    ) ON [PRIMARY];
END

SELECT @name = name, @create_date = create_date, @modify_date = modify_date
FROM sys.tables
WHERE name = @TableName;

PRINT 'Table Info:'
PRINT 'Table Name: ' + ISNULL(@name,'');
PRINT 'Date Created: ' + FORMAT(@create_date, 'MM/dd/yyyy HH:mm:ss');
PRINT 'Date Modified: ' + FORMAT(@modify_date, 'MM/dd/yyyy HH:mm:ss');

-- =========================================
-- Table Description
-- =========================================
DECLARE @tableDescription NVARCHAR(4000) = 
N'Logs all insert, update, and delete activities for tblHR_AbsentType including user and timestamp.';

IF EXISTS (
    SELECT 1
    FROM sys.extended_properties
    WHERE name = N'MS_Description'
      AND class = 1
      AND major_id = OBJECT_ID(N'dbo.' + @TableName)
      AND minor_id = 0
)
BEGIN
    EXEC sp_updateextendedproperty
        @name = N'MS_Description',
        @value = @tableDescription,
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = @TableName;
END
ELSE
BEGIN
    EXEC sp_addextendedproperty
        @name = N'MS_Description',
        @value = @tableDescription,
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = @TableName;
END

-- =========================================
-- Column Descriptions
-- =========================================
DECLARE @columns TABLE (ColumnName NVARCHAR(128), Description NVARCHAR(4000));

INSERT INTO @columns VALUES
('LogID', N'Primary key for log records.'),
('Activity', N'Type of activity (INSERT, UPDATE, DELETE).'),
('LeaveCode', N'Leave code affected.'),
('LeaveDesc', N'Description of the leave.'),
('AbsentType', N'Absent type classification.'),
('ChargeToLeaved', N'Indicates if charged to leave.'),
('EndDate', N'End date of leave applicability.'),
('FillingNotice', N'Notice requirement for filing leave.'),
('WithQuota', N'Indicates if leave has quota.'),
('LeavedColor', N'Display color of leave.'),
('ChargeToLeaveType', N'Reference leave type for charging.'),
('Active', N'Active status.'),
('CreatedBy', N'User who create.'),
('DTCreted', N'Date and time created.'),
('LastUpdateBy', N'User who made the change.'),
('DTModified', N'Date and time when change occurred.');

            
             
           

DECLARE @ColumnName NVARCHAR(128), @Description NVARCHAR(4000);

DECLARE ColumnCursor CURSOR FOR 
SELECT ColumnName, Description FROM @columns;

OPEN ColumnCursor;
FETCH NEXT FROM ColumnCursor INTO @ColumnName, @Description;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM sys.extended_properties
        WHERE name = N'MS_Description'
          AND class = 1
          AND major_id = OBJECT_ID(N'dbo.' + @TableName)
          AND minor_id = COLUMNPROPERTY(OBJECT_ID(N'dbo.' + @TableName), @ColumnName, 'ColumnId')
    )
    BEGIN
        EXEC sp_updateextendedproperty
            @name = N'MS_Description',
            @value = @Description,
            @level0type = N'SCHEMA', @level0name = 'dbo',
            @level1type = N'TABLE',  @level1name = @TableName,
            @level2type = N'COLUMN', @level2name = @ColumnName;
    END
    ELSE
    BEGIN
        EXEC sp_addextendedproperty
            @name = N'MS_Description',
            @value = @Description,
            @level0type = N'SCHEMA', @level0name = 'dbo',
            @level1type = N'TABLE',  @level1name = @TableName,
            @level2type = N'COLUMN', @level2name = @ColumnName;
    END

    FETCH NEXT FROM ColumnCursor INTO @ColumnName, @Description;
END

CLOSE ColumnCursor;
DEALLOCATE ColumnCursor;

-- =========================================
-- Verify Descriptions
-- =========================================
SELECT
    c.name AS [Column Name],
    ep.value AS [Description]
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
LEFT JOIN sys.extended_properties ep 
    ON ep.major_id = t.object_id 
    AND ep.minor_id = c.column_id 
    AND ep.name = 'MS_Description'
WHERE t.name = @TableName
ORDER BY c.column_id;
GO