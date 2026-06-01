





CREATE TABLE tblEarnedLeaveQuota (
    IDNumber   VARCHAR(10) NOT NULL,
    LeaveCode  VARCHAR(10) NOT NULL,
	YearValid  INT NULL,
	LeaveTotalBalance TINYINT NULL,

    January    TINYINT NULL,
    February   TINYINT NULL,
    March      TINYINT NULL,
    April      TINYINT NULL,
    May        TINYINT NULL,
    June       TINYINT NULL,
    July       TINYINT NULL,
    August     TINYINT NULL,
    September  TINYINT NULL,
    October    TINYINT NULL,
    November   TINYINT NULL,
    December   TINYINT NULL,

    CreatedBy  VARCHAR(55) NULL,
    DTCreated  DATETIME NULL,

    CONSTRAINT FK_tblEarnedLeaveQuota_Personnel
        FOREIGN KEY (IDNumber)
        REFERENCES tblHR_PersonnelMaster(IDNumber),

    CONSTRAINT FK_tblEarnedLeaveQuota_LeaveType
        FOREIGN KEY (LeaveCode)
        REFERENCES tblHR_AbsentType(LeaveCode)
);