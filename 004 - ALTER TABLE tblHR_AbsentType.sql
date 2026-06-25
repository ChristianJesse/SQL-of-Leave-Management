SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN TRY
BEGIN TRAN

-- =========================================
-- 1. RENAME COLUMNS
-- =========================================

IF COL_LENGTH('tblHR_AbsentType', 'Timeline') IS NOT NULL
AND COL_LENGTH('tblHR_AbsentType', 'FilingNotice') IS NULL
BEGIN
    EXEC sp_rename 'tblHR_AbsentType.Timeline', 'FilingNotice', 'COLUMN';
END


-- =========================================
-- 3. MODIFY COLUMN TYPES
-- =========================================

IF COL_LENGTH('tblHR_AbsentType', 'ChargeToLeave') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType
    ALTER COLUMN ChargeToLeave BIT NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'FilingNotice') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType
    ALTER COLUMN FilingNotice TINYINT NOT NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'WithQuota') IS NOT NULL
BEGIN
    ALTER TABLE tblHR_AbsentType
    ALTER COLUMN WithQuota BIT NOT NULL;
END


-- =========================================
-- 4. ADD NEW COLUMNS
-- =========================================

IF COL_LENGTH('tblHR_AbsentType', 'LeaveColor') IS NULL
BEGIN
    ALTER TABLE tblHR_AbsentType ADD LeaveColor VARCHAR(55) NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'ChargeToLeaveType') IS NULL
BEGIN
    ALTER TABLE tblHR_AbsentType ADD ChargeToLeaveType VARCHAR(10) NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'DateSpecific') IS NULL
BEGIN
    ALTER TABLE tblHR_AbsentType ADD DateSpecific BIT NOT NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'PeriodSpecific') IS NULL --Jake
BEGIN
    ALTER TABLE tblHR_AbsentType ADD PeriodSpecific BIT NOT NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'EarnedLeave') IS NULL --Jake
BEGIN
    ALTER TABLE tblHR_AbsentType ADD EarnedLeave BIT NOT NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'DateRegularized') IS NULL --Jake
BEGIN
    ALTER TABLE tblHR_AbsentType ADD DateRegularized VARCHAR(1) NOT NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'DateSeparated') IS NULL --Jake
BEGIN
    ALTER TABLE tblHR_AbsentType ADD DateSeparated VARCHAR(1) NOT NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'CreatedBy') IS NULL
BEGIN
    ALTER TABLE tblHR_AbsentType ADD CreatedBy VARCHAR(55) NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'DTCreted') IS NULL
BEGIN
    ALTER TABLE tblHR_AbsentType ADD DTCreted DATETIME NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'LastUpdateBy') IS NULL
BEGIN
    ALTER TABLE tblHR_AbsentType ADD LastUpdateBy VARCHAR(55) NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'DTModified') IS NULL
BEGIN
    ALTER TABLE tblHR_AbsentType ADD DTModified DATETIME NULL;
END



-- =========================================
-- 5. ADD FOREIGN KEY
-- =========================================

IF NOT EXISTS (
    SELECT 1 
    FROM sys.foreign_keys 
    WHERE name = 'FK_tblHR_AbsentType_ChargeToLeaveType'
)
BEGIN
    ALTER TABLE tblHR_AbsentType
    ADD CONSTRAINT FK_tblHR_AbsentType_ChargeToLeaveType
    FOREIGN KEY (ChargeToLeaveType)
    REFERENCES tblHR_AbsentType (LeaveCode);
END


-- =========================================
-- DONE
-- =========================================

COMMIT TRAN
PRINT 'SUCCESS: tblHR_AbsentType updated successfully.'

END TRY
BEGIN CATCH
    ROLLBACK TRAN

    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH
GO


-- =========================================
-- 6. UPDATE DEFAULT VALUES
-- =========================================

UPDATE tblHR_AbsentType
SET LeaveColor =
CASE LeaveCode
    WHEN 'SL' THEN '#C62828'
    WHEN 'EL' THEN '#1565C0'
    WHEN 'ELBRVL' THEN '#2E7D32'
    WHEN 'ELPL' THEN '#EF6C00'
    WHEN 'LWP' THEN '#6A1B9A'
    WHEN 'MAND' THEN '#5D4037'
    WHEN 'ML' THEN '#F9A825'
    WHEN 'PL' THEN '#AD1457'
    WHEN 'VL' THEN '#00897B'
    WHEN 'SLWOP' THEN '#006064'
    WHEN 'SPL' THEN '#9E9D24'
    WHEN 'SSL' THEN '#546E7A'
    WHEN 'UL' THEN '#212121'
    WHEN 'BL' THEN '#283593'
    WHEN 'VLWOP' THEN '#455A64'
END
WHERE LeaveCode IN (
'BL','EL','ELBRVL','ELPL','LWP','MAND','ML','PL','SL','SLWOP','SPL','SSL','UL','VL','VLWOP'
);


---- Set Active default
--UPDATE tblHR_AbsentType 
--SET Active = 1 
--WHERE Active IS NULL;


-- =========================================
-- 2. FIX NULL DATA BEFORE CONSTRAINT CHANGE
-- =========================================

IF COL_LENGTH('tblHR_AbsentType', 'FilingNotice') IS NOT NULL
BEGIN
    UPDATE tblHR_AbsentType 
    SET FilingNotice = 0 
    WHERE FilingNotice IS NULL;
END

IF COL_LENGTH('tblHR_AbsentType', 'WithQuota') IS NOT NULL
BEGIN
    UPDATE tblHR_AbsentType 
    SET WithQuota = 0 
    WHERE WithQuota IS NULL;
END
