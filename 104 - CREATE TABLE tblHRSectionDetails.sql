SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- Check/Create tblHRSectionDetails
-- =========================================
DECLARE @TableName SYSNAME = 'tblHRSectionDetails';
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
    CREATE TABLE dbo.tblHRSectionDetails
    (
        SectionDID      INT IDENTITY(1,1) PRIMARY KEY,
        IDNumber        VARCHAR(10) NOT NULL,
        Position        VARCHAR(55) NOT NULL,
        SectionHID      INT NOT NULL,
        FixedSeaction   BIT NOT NULL DEFAULT 0,
        Active          BIT NOT NULL DEFAULT 1,
        CreatedBy       VARCHAR(50) NOT NULL DEFAULT ORIGINAL_LOGIN(),
        DTCreated       DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedBy       VARCHAR(50) NOT NULL DEFAULT ORIGINAL_LOGIN(),
        DTUpdated       DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_tblHRSectionDetails_tblHRSectionHeader
        FOREIGN KEY (SectionHID)
        REFERENCES dbo.tblHRSectionHeader(SectionHID)
    ) ON [PRIMARY];
END

-- =========================================
-- Table Description (WITH VALIDATION)
-- =========================================
DECLARE @tableDescription NVARCHAR(4000) = 
N'Stores employee position assignments and membership within a section.';

IF EXISTS (
    SELECT 1
    FROM sys.extended_properties
    WHERE name = 'MS_Description'
    AND major_id = OBJECT_ID('dbo.' + @TableName)
    AND minor_id = 0
)
BEGIN
    EXEC sp_updateextendedproperty
        @name='MS_Description',
        @value=@tableDescription,
        @level0type='SCHEMA',@level0name='dbo',
        @level1type='TABLE',@level1name=@TableName;
END
ELSE
BEGIN
    EXEC sp_addextendedproperty
        @name='MS_Description',
        @value=@tableDescription,
        @level0type='SCHEMA',@level0name='dbo',
        @level1type='TABLE',@level1name=@TableName;
END


-- =========================================
-- Column Descriptions
-- =========================================
DECLARE @columns TABLE (ColumnName NVARCHAR(128), Description NVARCHAR(4000));

INSERT INTO @columns VALUES
('SectionDID',N'Primary key identifier for the section detail record.'),
('IDNumber',N'Employee ID number assigned to the section.'),
('Position',N'Employee job position or role within the section.'),
('SectionHID',N'Foreign key referencing the section header (tblHRSectionHeader.SectionHID).'),
('FixedSeaction',N'Indicates whether the section assignment is fixed or configurable.'),
('Active',N'Indicates if the employee section assignment is active.'),
('CreatedBy',N'User who created the record.'),
('DTCreated',N'Date and time the record was created.'),
('UpdatedBy',N'User who last updated the record.'),
('DTUpdated',N'Date and time the record was last updated.');

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
PRINT 'AFTER'

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