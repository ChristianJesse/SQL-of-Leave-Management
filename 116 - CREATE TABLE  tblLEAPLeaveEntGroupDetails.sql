SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblLEAPLeaveEntGroupDetails
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPLeaveEntGroupDetails';
DECLARE @name NVARCHAR(128), @create_date DATETIME, @modify_date DATETIME;

SELECT @name = name,
       @create_date = create_date,
       @modify_date = modify_date
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
    CREATE TABLE dbo.tblLEAPLeaveEntGroupDetails
    (
        LGDID        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        LGHID        INT NULL,
        LeaveCode    VARCHAR(10) NULL,
        LeaveInHours SMALLINT NULL,
        LeaveInDays  DECIMAL(18,2) NULL,

        LeaveHours01 TINYINT NULL,
        LeaveHours02 TINYINT NULL,
        LeaveHours03 TINYINT NULL,
        LeaveHours04 TINYINT NULL,
        LeaveHours05 TINYINT NULL,
        LeaveHours06 TINYINT NULL,
        LeaveHours07 TINYINT NULL,
        LeaveHours08 TINYINT NULL,
        LeaveHours09 TINYINT NULL,
        LeaveHours10 TINYINT NULL,
        LeaveHours11 TINYINT NULL,
        LeaveHours12 TINYINT NULL,

        DateCreated  DATETIME NULL,
        CreatedBy     VARCHAR(55) NULL
    ) ON [PRIMARY];
END

SELECT @name = name,
       @create_date = create_date,
       @modify_date = modify_date
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
N'Details of leave entitlement grouping including hours allocation per month and leave configuration.';

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
('LGDID', N'Primary key of leave entitlement group details.'),
('LGHID', N'Foreign key reference to leave entitlement group header.'),
('LeaveCode', N'Leave type code reference.'),
('LeaveInHours', N'Total leave entitlement in hours.'),
('LeaveInDays', N'Total leave entitlement in days.'),
('LeaveHours01', N'Leave hours allocation for month 01.'),
('LeaveHours02', N'Leave hours allocation for month 02.'),
('LeaveHours03', N'Leave hours allocation for month 03.'),
('LeaveHours04', N'Leave hours allocation for month 04.'),
('LeaveHours05', N'Leave hours allocation for month 05.'),
('LeaveHours06', N'Leave hours allocation for month 06.'),
('LeaveHours07', N'Leave hours allocation for month 07.'),
('LeaveHours08', N'Leave hours allocation for month 08.'),
('LeaveHours09', N'Leave hours allocation for month 09.'),
('LeaveHours10', N'Leave hours allocation for month 10.'),
('LeaveHours11', N'Leave hours allocation for month 11.'),
('LeaveHours12', N'Leave hours allocation for month 12.'),
('DateCreated', N'Date the record was created.'),
('CreatedBy', N'User who created the record.');

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