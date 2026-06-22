CREATE TYPE dbo.typeLEAPLeaveGroupDetails AS TABLE
(
    LGDID INT NULL,
    LGHID INT NULL,
    LeaveCode VARCHAR(20) NULL,

    January DECIMAL(18,2) NULL,
    Febuary DECIMAL(18,2) NULL,
    March DECIMAL(18,2) NULL,
    April DECIMAL(18,2) NULL,
    May DECIMAL(18,2) NULL,
    June DECIMAL(18,2) NULL,
    July DECIMAL(18,2) NULL,
    August DECIMAL(18,2) NULL,
    September DECIMAL(18,2) NULL,
    October DECIMAL(18,2) NULL,
    November DECIMAL(18,2) NULL,
    December DECIMAL(18,2) NULL,
    LeaveInHours SMALLINT NULL,
    LeaveInDays DECIMAL(5,2) NULL
);