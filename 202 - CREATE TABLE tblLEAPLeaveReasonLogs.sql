SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblLEAPLeaveReasonLogs
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPLeaveReasonLogs';
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
    CREATE TABLE dbo.tblLEAPLeaveReasonLogs
    (	
        [ReasonID]            INT IDENTITY(1,1) PRIMARY KEY,
        [Activity]            VARCHAR(55) NULL,
        [LeaveCode]           VARCHAR(10) NULL,
        [ReasonCode]          VARCHAR(10) NOT NULL,
        [ReasonDescription]   VARCHAR(MAX) NULL,
        [NoticePeriod]        TINYINT NOT NULL,
        [Remarks]             VARCHAR(MAX) NULL,
        [isActive]            BIT NOT NULL,

        [DTCreated]           DATETIME NULL,
        [CreatedBy]           VARCHAR(55) NULL,
        [DTModified]          DATETIME NULL,
        [LastUpdateBy]        VARCHAR(55) NULL
    ) ON [PRIMARY];
END

SELECT @name = name, @create_date = create_date, @modify_date = modify_date
FROM sys.tables
WHERE name = @TableName;

PRINT 'Table Info:'
PRINT 'Table Name: ' + @name;
PRINT 'Date Created: ' + FORMAT(@create_date, 'MM/dd/yyyy HH:mm:ss');
PRINT 'Date Modified: ' + FORMAT(@modify_date, 'MM/dd/yyyy HH:mm:ss');

-- =========================================
-- Table Description
-- =========================================
DECLARE @tableDescription NVARCHAR(4000) = 
N'Stores audit logs for leave reasons including activity type, previous values, and audit tracking fields.';

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
('ReasonID', N'Primary key identifier for the log record.'),
('Activity', N'Type of activity performed (INSERT, UPDATE, DELETE).'),
('LeaveCode', N'Associated leave type code.'),
('ReasonCode', N'Code representing the leave reason.'),
('ReasonDescription', N'Description of the leave reason.'),
('NoticePeriod', N'Notice period at the time of the activity.'),
('Remarks', N'Remarks at the time of the activity.'),
('isActive', N'Status at the time of the activity (1 = Active, 0 = Inactive).'),
('DTCreated', N'Date and time when the record was created.'),
('CreatedBy', N'User who created the record.'),
('DTModified', N'Date and time when the record was last modified.'),
('LastUpdateBy', N'User who last updated the record.');

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