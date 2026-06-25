SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN TRY
BEGIN TRAN

-- =========================================
-- 1. RENAME COLUMNS
-- =========================================
IF COL_LENGTH('tblHR_AbsentType', 'Timeline') IS NOT NULL AND COL_LENGTH('tblHR_AbsentType', 'Filing') IS NULL
BEGIN
    EXEC sp_rename 'tblHR_AbsentType.Timeline', 'Filing', 'COLUMN';
END

-- =========================================
-- 2. ADD NEW COLUMNS SAFELY (Allowing NULL initially for data safety)
-- =========================================
IF COL_LENGTH('tblHR_AbsentType', 'FilingUnit') IS NULL
    ALTER TABLE tblHR_AbsentType ADD FilingUnit INT NULL;

IF COL_LENGTH('tblHR_AbsentType', 'Notice') IS NULL
    ALTER TABLE tblHR_AbsentType ADD Notice TINYINT NULL;

IF COL_LENGTH('tblHR_AbsentType', 'NoticeUnit') IS NULL
    ALTER TABLE tblHR_AbsentType ADD NoticeUnit INT NULL;

IF COL_LENGTH('tblHR_AbsentType', 'LeaveColor') IS NULL
    ALTER TABLE tblHR_AbsentType ADD LeaveColor VARCHAR(55) NULL;

IF COL_LENGTH('tblHR_AbsentType', 'ChargeToLeaveType') IS NULL
    ALTER TABLE tblHR_AbsentType ADD ChargeToLeaveType VARCHAR(10) NULL;

IF COL_LENGTH('tblHR_AbsentType', 'DateSpecific') IS NULL
    ALTER TABLE tblHR_AbsentType ADD DateSpecific BIT NULL; -- NULL initially

IF COL_LENGTH('tblHR_AbsentType', 'PeriodSpecific') IS NULL 
    ALTER TABLE tblHR_AbsentType ADD PeriodSpecific BIT NULL; -- NULL initially

IF COL_LENGTH('tblHR_AbsentType', 'EarnedLeave') IS NULL 
    ALTER TABLE tblHR_AbsentType ADD EarnedLeave BIT NULL; -- NULL initially

IF COL_LENGTH('tblHR_AbsentType', 'DateRegularized') IS NULL 
    ALTER TABLE tblHR_AbsentType ADD DateRegularized INT NULL; -- NULL initially

IF COL_LENGTH('tblHR_AbsentType', 'DateSeparated') IS NULL 
    ALTER TABLE tblHR_AbsentType ADD DateSeparated INT NULL; -- NULL initially

IF COL_LENGTH('tblHR_AbsentType', 'CreatedBy') IS NULL
    ALTER TABLE tblHR_AbsentType ADD CreatedBy VARCHAR(55) NULL;

IF COL_LENGTH('tblHR_AbsentType', 'DTCreted') IS NULL
    ALTER TABLE tblHR_AbsentType ADD DTCreted DATETIME NULL;

IF COL_LENGTH('tblHR_AbsentType', 'LastUpdateBy') IS NULL
    ALTER TABLE tblHR_AbsentType ADD LastUpdateBy VARCHAR(55) NULL;

IF COL_LENGTH('tblHR_AbsentType', 'DTModified') IS NULL
    ALTER TABLE tblHR_AbsentType ADD DTModified DATETIME NULL;

-- =========================================
-- 3. SANITIZE AND FIX EXISTING NULL RECORDS
-- =========================================
UPDATE tblHR_AbsentType SET Filing = 0 WHERE Filing IS NULL;
UPDATE tblHR_AbsentType SET FilingUnit = 0 WHERE FilingUnit IS NULL;
UPDATE tblHR_AbsentType SET Notice = 0 WHERE Notice IS NULL;
UPDATE tblHR_AbsentType SET NoticeUnit = 0 WHERE NoticeUnit IS NULL;
UPDATE tblHR_AbsentType SET WithQuota = 0 WHERE WithQuota IS NULL;

-- Fix the new flags so they can be securely forced to NOT NULL
UPDATE tblHR_AbsentType SET DateSpecific = 0 WHERE DateSpecific IS NULL;
UPDATE tblHR_AbsentType SET PeriodSpecific = 0 WHERE PeriodSpecific IS NULL;
UPDATE tblHR_AbsentType SET EarnedLeave = 0 WHERE EarnedLeave IS NULL;
UPDATE tblHR_AbsentType SET DateRegularized = 0 WHERE DateRegularized IS NULL; 
UPDATE tblHR_AbsentType SET DateSeparated = 0 WHERE DateSeparated IS NULL;


-- =========================================
-- 4. APPLY ENFORCED 'NOT NULL' DATA TYPE CHANGES
-- =========================================
ALTER TABLE tblHR_AbsentType ALTER COLUMN ChargeToLeave BIT NULL;
ALTER TABLE tblHR_AbsentType ALTER COLUMN Filing TINYINT NOT NULL;
ALTER TABLE tblHR_AbsentType ALTER COLUMN WithQuota BIT NOT NULL;

-- Transition new columns to NOT NULL now that data is safe
ALTER TABLE tblHR_AbsentType ALTER COLUMN DateSpecific BIT NOT NULL;
ALTER TABLE tblHR_AbsentType ALTER COLUMN PeriodSpecific BIT NOT NULL;
ALTER TABLE tblHR_AbsentType ALTER COLUMN EarnedLeave BIT NOT NULL;
ALTER TABLE tblHR_AbsentType ALTER COLUMN DateRegularized INT NOT NULL;
ALTER TABLE tblHR_AbsentType ALTER COLUMN DateSeparated INT NOT NULL;


-- =========================================
-- 5. SEED DEFAULT SYSTEM COLOR SCHEMES
-- =========================================
UPDATE tblHR_AbsentType
SET LeaveColor = CASE LeaveCode
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
WHERE LeaveCode IN ('BL','EL','ELBRVL','ELPL','LWP','MAND','ML','PL','SL','SLWOP','SPL','SSL','UL','VL','VLWOP');


-- =========================================
-- 6. ADD SELF-REFERENCING FOREIGN KEY CONSTRAINT
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

COMMIT TRAN
PRINT 'SUCCESS: tblHR_AbsentType updated successfully.'

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH
GO
