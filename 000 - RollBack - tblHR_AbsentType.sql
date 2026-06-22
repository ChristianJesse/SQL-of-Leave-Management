SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN TRY
BEGIN TRAN

-- =========================================
-- 1. DROP FOREIGN KEY
-- =========================================
IF EXISTS (
    SELECT 1 
    FROM sys.foreign_keys 
    WHERE name = 'FK_tblHR_AbsentType_ChargeToLeaveType'
)
BEGIN
    ALTER TABLE tblHR_AbsentType
    DROP CONSTRAINT FK_tblHR_AbsentType_ChargeToLeaveType;
END


-- =========================================123131
-- 2. DROP ADDED COLUMNS
-- =========================================

IF COL_LENGTH('tblHR_AbsentType', 'LeavedColor') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN LeavedColor;
END

IF COL_LENGTH('tblHR_AbsentType', 'ChargeToLeaveType') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN ChargeToLeaveType;
END

IF COL_LENGTH('tblHR_AbsentType', 'Dayspecific') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN Dayspecific;
END

IF COL_LENGTH('tblHR_AbsentType', 'CreatedBy') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN CreatedBy;
END

IF COL_LENGTH('tblHR_AbsentType', 'DTCreted') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN DTCreted;
END

IF COL_LENGTH('tblHR_AbsentType', 'Active') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN Active;
END

IF COL_LENGTH('tblHR_AbsentType', 'LastUpdateBy') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN LastUpdateBy;
END

IF COL_LENGTH('tblHR_AbsentType', 'DTModified') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType DROP COLUMN DTModified;
END

-- =========================================
-- 3. REVERT COLUMN TYPES
-- =========================================

-- ChargeToLeaved -> back to TINYINT
IF COL_LENGTH('tblHR_AbsentType', 'ChargeToLeaved') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType
    ALTER COLUMN ChargeToLeaved TINYINT NULL;
END

-- FillingNotice -> back to original (Timeline was NOT NULL tinyint)
IF COL_LENGTH('tblHR_AbsentType', 'FillingNotice') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType
    ALTER COLUMN FillingNotice TINYINT NOT NULL;
END

-- WithQuota stays BIT NOT NULL (already original)
-- If you want FULL revert (nullable before?), uncomment below:
-- ALTER TABLE tblHR_AbsentType ALTER COLUMN WithQuota BIT NULL;


-- =========================================
-- 4. RENAME COLUMNS BACK
-- =========================================

IF COL_LENGTH('tblHR_AbsentType', 'ChargeToLeaved') IS NOT NULL
AND COL_LENGTH('tblHR_AbsentType', 'ChargeToLeave') IS NULL
BEGIN
    EXEC sp_rename 'tblHR_AbsentType.ChargeToLeaved', 'ChargeToLeave', 'COLUMN';
END

IF COL_LENGTH('tblHR_AbsentType', 'FillingNotice') IS NOT NULL
AND COL_LENGTH('tblHR_AbsentType', 'Timeline') IS NULL
BEGIN
    EXEC sp_rename 'tblHR_AbsentType.FillingNotice', 'Timeline', 'COLUMN';
END


-- =========================================
-- 5. OPTIONAL: CLEAN DATA (if needed)
-- =========================================
-- No strict rollback for data updates (color/defaults),
-- but you can nullify if needed:

-- UPDATE tblHR_AbsentType SET LeavedColor = NULL; -- already dropped


-- =========================================
-- DONE
-- =========================================

COMMIT TRAN
PRINT 'ROLLBACK SUCCESS: tblHR_AbsentType reverted to original structure.'

END TRY
BEGIN CATCH
    ROLLBACK TRAN
    PRINT 'ROLLBACK ERROR: ' + ERROR_MESSAGE();
END CATCH
GO



