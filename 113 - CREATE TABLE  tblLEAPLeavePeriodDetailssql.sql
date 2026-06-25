SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblLEAPLeavePeriodDetails
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPLeavePeriodDetails';
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
    CREATE TABLE dbo.tblLEAPLeavePeriodDetails
    (

        LPDID        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        LPHID        INT NULL,
        IDNumber     VARCHAR(10) NULL,
        Quota        FLOAT NULL,
        LeaveBalance FLOAT NULL,
        ForApproval  FLOAT NULL,
        Approved     FLOAT NULL,
        Posted       FLOAT NULL,
        Settled      FLOAT NULL,
        LeaveUsed    FLOAT NULL,
        Locked       SMALLINT NULL,
        LockedBy     VARCHAR(20) NULL,
        LockedOn     DATETIME NULL,
        SettledBy    VARCHAR(55) NULL,
        DTSetteled   DATETIME NULL
      CONSTRAINT FK_tblLEAPLeavePeriodDetails_tblLEAPLeavePeriodHeader
        FOREIGN KEY (LPHID)
        REFERENCES dbo.tblLEAPLeavePeriodHeader (LPHID)
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
N'Details of leave period balances, approvals, postings, and usage per employee.';

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
('LPDID', N'Primary key of leave period details.'),
('LPHID', N'Foreign key reference to leave period header.'),
('IDNumber', N'Employee ID number.'),
('Quota', N'Total leave quota assigned.'),
('LeaveBalance', N'Remaining leave balance.'),
('ForApproval', N'Leave amount pending approval.'),
('Approved', N'Approved leave amount.'),
('Posted', N'Leave amount already posted.'),
('Settled', N'Settled leave amount.'),
('LeaveUsed', N'Total leave used by employee.'),
('Locked', N'Indicates if record is locked.'),
('LockedBy', N'User who locked the record.'),
('LockedOn', N'Date and time record was locked.'),
('SettledBy', N'User who settled the record.'),
('DTSetteled', N'Date and time record was settled.');

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