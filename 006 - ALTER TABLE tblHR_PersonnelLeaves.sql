

/* Add AGHID column if not existing */
IF COL_LENGTH('tblHR_PersonnelLeaves', 'AGHID') IS NULL
BEGIN
    ALTER TABLE tblHR_PersonnelLeaves
    ADD AGHID INT NULL;
END

/* Add ReasonCode column if not existing */
IF COL_LENGTH('tblHR_PersonnelLeaves', 'ReasonCode') IS NULL
BEGIN
    ALTER TABLE tblHR_PersonnelLeaves
    ADD ReasonCode VARCHAR(10) NULL;
END


/* Make TransID as Primary Key */
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE [type] = 'PK'
      AND [parent_object_id] = OBJECT_ID('tblHR_PersonnelLeaves')
)
BEGIN
    ALTER TABLE tblHR_PersonnelLeaves
    ADD CONSTRAINT PK_tblHR_PersonnelLeaves_TransID
    PRIMARY KEY (TransID);
END

/* Add DTNotice column if not existing */
IF COL_LENGTH('tblHR_PersonnelLeaves', 'DTNotice') IS NULL
BEGIN
    ALTER TABLE tblHR_PersonnelLeaves
    ADD DTNotice DATETIME NULL;
END

/* Add NoticeFileName column if not existing */
IF COL_LENGTH('tblHR_PersonnelLeaves', 'NoticeFileName') IS NULL
BEGIN
    ALTER TABLE tblHR_PersonnelLeaves
    ADD NoticeFileName VARCHAR(55) NULL;
END
