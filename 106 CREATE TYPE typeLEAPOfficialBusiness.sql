



DROP TYPE IF EXISTS typeLEAPOfficialBusiness;
GO

CREATE TYPE typeLEAPOfficialBusiness AS TABLE
(
    TransID        BIGINT,
    IDNumber       VARCHAR(10) NOT NULL,
    Purpose        VARCHAR(255) NULL,
	Attachment	   VARCHAR(255) NULL,
    Reason         VARCHAR(MAX) NULL,
    Destination    VARCHAR(MAX) NULL,
    OBFrom         DATETIME NULL,
    OBTo           DATETIME NULL,
    NumHours       FLOAT NULL
);
GO





