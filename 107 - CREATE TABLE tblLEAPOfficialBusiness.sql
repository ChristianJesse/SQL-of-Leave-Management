SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================
-- CREATE TABLE (SAFE BLOCK)
-- =========================================
IF OBJECT_ID('dbo.tblLEAPOfficialBusiness', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblLEAPOfficialBusiness
    (
        [TransID]       BIGINT IDENTITY(1,1) PRIMARY KEY,
        [IDNumber]      VARCHAR(10) NOT NULL,
        [Purpose]       VARCHAR(MAX) NULL,
        [Attachment]    VARCHAR(255) NULL,
        [Destination]   VARCHAR(MAX) NULL,
        [OBFrom]        DATETIME NULL,
        [OBTo]          DATETIME NULL,
        [NumHours]      FLOAT NULL,
        [DTApplied]     DATETIME NULL,
        [AGHID]         INT NULL
    ) ON [PRIMARY];
END
GO

-- =========================================
-- FK
-- =========================================
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'FK_tblLEAPOfficialBusiness_IDNumber'
)
BEGIN
    ALTER TABLE dbo.tblLEAPOfficialBusiness
    ADD CONSTRAINT FK_tblLEAPOfficialBusiness_IDNumber
    FOREIGN KEY (IDNumber)
    REFERENCES dbo.tblHR_PersonnelMaster(IDNumber);
END
GO

-- =========================================
-- DESCRIPTION BLOCK (REDECLARE VARIABLE HERE)
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPOfficialBusiness';

DECLARE @tableDescription NVARCHAR(4000) = 
N'Stores official business applications, destination details, applied hours, schedules, and approval references for employees.';

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
GO

-- =========================================
-- COLUMN DESCRIPTIONS (REDECLARE VARIABLE HERE)
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPOfficialBusiness';

DECLARE @columns TABLE (ColumnName NVARCHAR(128), Description NVARCHAR(4000));

INSERT INTO @columns VALUES
('TransID', N'Primary key identifier for the official business transaction.'),
('IDNumber', N'Employee ID number associated with the official business request.'),
('Purpose', N'Purpose of the official business request.'),
('Attachment', N'Attachment Filename of the official business request.'),
('Destination', N'Destination or location of the official business activity.'),
('OBFrom', N'Start date and time of the official business schedule.'),
('OBTo', N'End date and time of the official business schedule.'),
('NumHours', N'Number of hours requested for official business.'),
('DTApplied', N'Date and time when the official business was applied.'),
('AGHID', N'Associated approval group hierarchy identifier.');

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
            @level0type = N'SCHEMA', @level0name = N'dbo',
            @level1type = N'TABLE',  @level1name = @TableName,
            @level2type = N'COLUMN', @level2name = @ColumnName;
    END

    FETCH NEXT FROM ColumnCursor INTO @ColumnName, @Description;
END

CLOSE ColumnCursor;
DEALLOCATE ColumnCursor;
GO

-- =========================================
-- VERIFY
-- =========================================
DECLARE @TableName SYSNAME = 'tblLEAPOfficialBusiness';

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