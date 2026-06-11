SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblLEAPLeaveTypeQuota
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPLeaveTypeQuota';
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

IF OBJECT_ID(@TableName, 'U') IS NOT NULL
BEGIN
    PRINT 'Table Name: ' + @name;
    PRINT 'Date Created: ' + FORMAT(@create_date, 'MM/dd/yyyy HH:mm:ss');
    PRINT 'Date Modified: ' + FORMAT(@modify_date, 'MM/dd/yyyy HH:mm:ss');
    PRINT 'Table is already Existing: ' + @TableName;
END

-- Create table if it does not exist
IF OBJECT_ID(@TableName,'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblLEAPLeaveTypeQuota
    (
        ID BIGINT IDENTITY(1,1) PRIMARY KEY,
        LeaveCode VARCHAR(10) NOT NULL,

        PeriodSpecific BIT NOT NULL 
            CONSTRAINT DF_tblLEAPLeaveTypeQuota_PeriodSpecific DEFAULT 0,

        DTFrom DATETIME NOT NULL,
        DTTo DATETIME NOT NULL,
        Quota FLOAT NULL,

        CreatedBy VARCHAR(55) NULL,
        DTCreated DATETIME NOT NULL DEFAULT GETDATE(),
        DTModified DATETIME NULL,
        LastUpdateBy VARCHAR(55) NULL,

        CONSTRAINT FK_tblLEAPLeaveTypeQuota_tblHR_AbsentType
        FOREIGN KEY (LeaveCode)
        REFERENCES dbo.tblHR_AbsentType(LeaveCode)
    );
END

-- Fetch table info
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
N'Stores leave type quota per period range including effective date range and assigned quota per leave code.';

IF EXISTS (
    SELECT 1
    FROM sys.extended_properties
    WHERE name = N'MS_Description'
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
('ID','Primary key identity of leave quota record.'),
('LeaveCode','Reference to leave type in tblHR_AbsentType.'),
('PeriodSpecific','Indicates whether quota is period-based (0 = No, 1 = Yes).'),
('DTFrom','Start date of quota validity period.'),
('DTTo','End date of quota validity period.'),
('Quota','Allocated quota value for the leave type.'),
('CreatedBy','User who created the record.'),
('DTCreated','Timestamp when the record was created.'),
('DTModified','Timestamp when the record was last modified.'),
('LastUpdateBy','User who last updated the record.');

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
PRINT 'Column Descriptions:';
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