

/* Add AGHID column if not existing */
IF COL_LENGTH('tblHR_PersonnelLeaves', 'AGHID') IS NULL
BEGIN
    ALTER TABLE tblHR_PersonnelLeaves
    ADD AGHID BIGINT NULL;
END


/* Add AGHID column if not existing */
IF COL_LENGTH('tblHR_PersonnelLeaves', 'ReasonCode') IS NULL
BEGIN
    ALTER TABLE tblHR_PersonnelLeaves
    ADD ReasonCode VARCHAR(10) NULL;
END



