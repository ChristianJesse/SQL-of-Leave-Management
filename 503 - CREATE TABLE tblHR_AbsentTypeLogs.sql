SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_help tblHR_AbsentTypeLogs
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

-- If the log table does not exist, build it with the matching sanitized columns
IF OBJECT_ID(@TableName, 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblHR_AbsentTypeLogs
    (	
        [LogID]             BIGINT IDENTITY(1,1) PRIMARY KEY,
        [Activity]          VARCHAR(55) NULL,
        [LeaveCode]         VARCHAR(10) NOT NULL,
        [LeaveDesc]         VARCHAR(50) NULL,
        [AbsentType]        VARCHAR(4) NULL,
        [ChargeToLeave]     BIT NULL,
        [EndDate]           DATE NULL,
        [Filing]            TINYINT NULL,
        [FilingUnit]        INT NULL,
        [Notice]            TINYINT NULL,
        [NoticeUnit]        INT NULL,
        [WithQuota]         BIT NOT NULL,
        [LeaveColor]        VARCHAR(55) NULL,
        [ChargeToLeaveType] VARCHAR(10) NULL,
        [DateSpecific]      BIT NOT NULL,
        [PeriodSpecific]    BIT NOT NULL,
        [EarnedLeave]       BIT NOT NULL,
        [DateRegularized]   INT NULL,
        [DateSeparated]     INT NULL,
        [Active]            BIT NULL,
        [CreatedBy]         VARCHAR(55) NULL,
        [DTCreted]          DATETIME DEFAULT GETDATE(),
        [LastUpdateBy]      VARCHAR(55) NULL,
        [DTModified]        DATETIME DEFAULT GETDATE()
    ) ON [PRIMARY];
END
ELSE
BEGIN
    -- ALTER LOG TABLE ALTERATIONS (Runs cleanly if the log table already exists)
    -- 1. Rename column if it is still named 'FillingNotice'
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'FillingNotice') IS NOT NULL AND COL_LENGTH('tblHR_AbsentTypeLogs', 'Filing') IS NULL
    BEGIN
        EXEC sp_rename 'tblHR_AbsentTypeLogs.FillingNotice', 'Filing', 'COLUMN';
    END
    
    -- 2. Rename column if it is still named 'ChargeToLeaved'
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'ChargeToLeaved') IS NOT NULL AND COL_LENGTH('tblHR_AbsentTypeLogs', 'ChargeToLeave') IS NULL
    BEGIN
        EXEC sp_rename 'tblHR_AbsentTypeLogs.ChargeToLeaved', 'ChargeToLeave', 'COLUMN';
    END

    -- 3. Rename column if it is still named 'LeavedColor'
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'LeavedColor') IS NOT NULL AND COL_LENGTH('tblHR_AbsentTypeLogs', 'LeaveColor') IS NULL
    BEGIN
        EXEC sp_rename 'tblHR_AbsentTypeLogs.LeavedColor', 'LeaveColor', 'COLUMN';
    END

    -- 4. Add new tracking columns safely
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'FilingUnit') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD FilingUnit VARCHAR(1) NULL;
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'Notice') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD Notice TINYINT NULL;
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'NoticeUnit') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD NoticeUnit VARCHAR(1) NULL;
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'DateSpecific') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD DateSpecific BIT NULL;
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'PeriodSpecific') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD PeriodSpecific BIT NULL;
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'EarnedLeave') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD EarnedLeave BIT NULL;
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'DateRegularized') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD DateRegularized VARCHAR(1) NULL;
    IF COL_LENGTH('tblHR_AbsentTypeLogs', 'DateSeparated') IS NULL ALTER TABLE tblHR_AbsentTypeLogs ADD DateSeparated VARCHAR(1) NULL;
    
    -- Sync existing NULL rows in logs to prevent check failures
    EXEC('UPDATE tblHR_AbsentTypeLogs SET DateSpecific = 0 WHERE DateSpecific IS NULL;
          UPDATE tblHR_AbsentTypeLogs SET PeriodSpecific = 0 WHERE PeriodSpecific IS NULL;
          UPDATE tblHR_AbsentTypeLogs SET EarnedLeave = 0 WHERE EarnedLeave IS NULL;
          UPDATE tblHR_AbsentTypeLogs SET DateRegularized = 0 WHERE DateRegularized IS NULL;
          UPDATE tblHR_AbsentTypeLogs SET DateSeparated = 0 WHERE DateSeparated IS NULL;');

    -- Make them NOT NULL to perfectly mirror the main data schema tables
    ALTER TABLE tblHR_AbsentTypeLogs ALTER COLUMN DateSpecific BIT NOT NULL;
    ALTER TABLE tblHR_AbsentTypeLogs ALTER COLUMN PeriodSpecific BIT NOT NULL;
    ALTER TABLE tblHR_AbsentTypeLogs ALTER COLUMN EarnedLeave BIT NOT NULL;
    ALTER TABLE tblHR_AbsentTypeLogs ALTER COLUMN DateRegularized INT NOT NULL;
    ALTER TABLE tblHR_AbsentTypeLogs ALTER COLUMN DateSeparated INT NOT NULL;
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
('ChargeToLeave', N'Indicates if charged to leave.'),
('EndDate', N'End date of leave applicability.'),
('Filing', N'The value duration restriction used for leave application submittal window.'),
('FilingUnit', N'The calendar or working unit tracking window (D = Day, H = Hours).'),
('Notice', N'The minimum advance warning length before a leave event can be submitted.'),
('NoticeUnit', N'The temporal scale for minimum leaf warning length tracking.'),
('WithQuota', N'Indicates if leave has quota.'),
('LeaveColor', N'Display color of leave.'),
('ChargeToLeaveType', N'Reference leave type for charging.'),
('DateSpecific', N'Identifies date range checking validation requirements.'),
('PeriodSpecific', N'Identifies period milestone checking verification specifications.'),
('EarnedLeave', N'A validation tracker evaluating progressive accumulation parameters.'),
('DateRegularized', N'Pro-rata computation configuration value setting flag applied when employee becomes regularized.'),
('DateSeparated', N'Pro-rata computation setting applied when human capital separations materialize.'),
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
    -- Safely target only existing validated column positions
    IF EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE object_id = OBJECT_ID(N'dbo.' + @TableName) AND name = @ColumnName
    )
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