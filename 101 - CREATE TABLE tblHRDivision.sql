SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblHRDivision
-- =========================================
DECLARE @TableName SYSNAME = 'tblHRDivision';
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

IF OBJECT_ID(@TableName, 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblHRDivision
    (
        [DivisionID] INT IDENTITY(1,1) PRIMARY KEY,
        [IDNumber] VARCHAR(10) NOT NULL,
        [DivisionHead] VARCHAR(55) NOT NULL,
        [DivisionPosition] VARCHAR(55) NOT NULL,
        [Active] BIT NOT NULL DEFAULT 1,
        [CreatedBy] VARCHAR(50) NOT NULL DEFAULT ORIGINAL_LOGIN(),
        [DTCreated] DATETIME NOT NULL DEFAULT GETDATE(),
        [UpdatedBy] VARCHAR(50) NOT NULL DEFAULT ORIGINAL_LOGIN(),
        [DTUpdated] DATETIME NOT NULL DEFAULT GETDATE()
    ) ON [PRIMARY];
END

-- =========================================
-- Table Description
-- =========================================
DECLARE @tableDescription NVARCHAR(4000) = 
N'Stores company division information including division head and position.';

IF NOT EXISTS (
    SELECT 1 FROM sys.extended_properties
    WHERE major_id = OBJECT_ID('dbo.' + @TableName)
    AND minor_id = 0
    AND name = 'MS_Description'
)
BEGIN
    EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description',
    @value=@tableDescription,
    @level0type=N'SCHEMA',@level0name=N'dbo',
    @level1type=N'TABLE',@level1name=@TableName;
END

-- =========================================
-- Column Descriptions
-- =========================================
DECLARE @columns TABLE (ColumnName NVARCHAR(128), Description NVARCHAR(4000));

INSERT INTO @columns VALUES
('DivisionID',N'Primary key identifier for the division.'),
('IDNumber',N'Employee ID number of the division head.'),
('DivisionHead',N'Full name of the division head.'),
('DivisionPosition',N'Official job position of the division head.'),
('Active',N'Indicates if the division record is active (1 = Active, 0 = Inactive).'),
('CreatedBy',N'User who created the division record.'),
('DTCreated',N'Date and time when the division record was created.'),
('UpdatedBy',N'User who last updated the division record.'),
('DTUpdated',N'Date and time when the division record was last updated.');

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