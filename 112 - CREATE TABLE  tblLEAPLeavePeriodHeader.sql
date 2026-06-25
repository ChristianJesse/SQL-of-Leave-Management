SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblLEAPLeavePeriodHeader
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPLeavePeriodHeader';
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
INNER JOIN sys.tables t
    ON c.object_id = t.object_id
LEFT JOIN sys.extended_properties ep
    ON ep.major_id = t.object_id
   AND ep.minor_id = c.column_id
   AND ep.name = 'MS_Description'
WHERE t.name = @TableName
ORDER BY c.column_id;

IF OBJECT_ID(@TableName, 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblLEAPLeavePeriodHeader
    (
        LPHID           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PID             INT NULL,
        LeaveCode       VARCHAR(10) NOT NULL,
        PeriodSpecific  BIT NULL,
        PQuota			Float NULL,
        [Year]          VARCHAR(4) NULL,
        DTFrom          DATE NULL,
        DTTo            DATE NULL,
        LPStatus        INT NULL,
        CreatedBy       VARCHAR(55) NULL,
        DTCreated       DATETIME NULL,
        LastUpdateBy    VARCHAR(55) NULL,
        DTModified      DATETIME NULL,
        ClosedBy        VARCHAR(55) NULL,
        DTClosed        DATETIME NULL
    ) ON [PRIMARY];
END

SELECT @name = name,
       @create_date = create_date,
       @modify_date = modify_date
FROM sys.tables
WHERE name = @TableName;

PRINT 'Table Info:';
PRINT 'Table Name: ' + @name;
PRINT 'Date Created: ' + FORMAT(@create_date, 'MM/dd/yyyy HH:mm:ss');
PRINT 'Date Modified: ' + FORMAT(@modify_date, 'MM/dd/yyyy HH:mm:ss');

-- =========================================
-- Table Description
-- =========================================
DECLARE @tableDescription NVARCHAR(4000) =
N'Stores leave entitlement period headers and period configuration per leave type.';

IF EXISTS
(
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
        @level1type = N'TABLE', @level1name = @TableName;
END
ELSE
BEGIN
    EXEC sp_addextendedproperty
        @name = N'MS_Description',
        @value = @tableDescription,
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = @TableName;
END

-- =========================================
-- Column Descriptions
-- =========================================
DECLARE @columns TABLE
(
    ColumnName NVARCHAR(128),
    Description NVARCHAR(4000)
);

INSERT INTO @columns VALUES
('LPHID', N'Primary key of leave period header.'),
('PID', N'Reference period identifier.'),
('LeaveCode', N'Reference leave code.'),
('PeriodSpecific', N' 1 = Earned. 0 = Period Specific'),
('PQuota', N'Period Specific leave type quota'),
('Year', N'Applicable year of the leave period.'),
('DTFrom', N'Start date of the leave period.'),
('DTTo', N'End date of the leave period.'),
('LPStatus', N'Status of the leave period.'),
('CreatedBy', N'User who created the record.'),
('DTCreated', N'Date and time the record was created.'),
('LastUpdateBy', N'User who last modified the record.'),
('DTModified', N'Date and time the record was last modified.'),
('ClosedBy', N'User who closed the leave period.'),
('DTClosed', N'Date and time the leave period was closed.');

DECLARE @ColumnName NVARCHAR(128),
        @Description NVARCHAR(4000);

DECLARE ColumnCursor CURSOR FOR
SELECT ColumnName, Description
FROM @columns;

OPEN ColumnCursor;

FETCH NEXT FROM ColumnCursor
INTO @ColumnName, @Description;

WHILE @@FETCH_STATUS = 0
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM sys.extended_properties
        WHERE name = N'MS_Description'
        AND class = 1
        AND major_id = OBJECT_ID(N'dbo.' + @TableName)
        AND minor_id = COLUMNPROPERTY(
                            OBJECT_ID(N'dbo.' + @TableName),
                            @ColumnName,
                            'ColumnId')
    )
    BEGIN
        EXEC sp_updateextendedproperty
            @name = N'MS_Description',
            @value = @Description,
            @level0type = N'SCHEMA', @level0name = 'dbo',
            @level1type = N'TABLE', @level1name = @TableName,
            @level2type = N'COLUMN', @level2name = @ColumnName;
    END
    ELSE
    BEGIN
        EXEC sp_addextendedproperty
            @name = N'MS_Description',
            @value = @Description,
            @level0type = N'SCHEMA', @level0name = 'dbo',
            @level1type = N'TABLE', @level1name = @TableName,
            @level2type = N'COLUMN', @level2name = @ColumnName;
    END

    FETCH NEXT FROM ColumnCursor
    INTO @ColumnName, @Description;
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
INNER JOIN sys.tables t
    ON c.object_id = t.object_id
LEFT JOIN sys.extended_properties ep
    ON ep.major_id = t.object_id
   AND ep.minor_id = c.column_id
   AND ep.name = 'MS_Description'
WHERE t.name = @TableName
ORDER BY c.column_id;
GO