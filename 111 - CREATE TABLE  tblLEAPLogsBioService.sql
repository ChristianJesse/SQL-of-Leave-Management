

CREATE TABLE dbo.tblLEAPLogsBioService
(
    ID          BIGINT IDENTITY(1,1) NOT NULL,
    ServerID    INT NULL,
    [Error]     BIT NOT NULL CONSTRAINT DF_tblLEAPLogsBioService_Error DEFAULT (0),
    [Type]      VARCHAR(255) NULL,
    [Message]   VARCHAR(MAX) NULL,
    CreatedBy   VARCHAR(50) NULL,
    DTCreated   DATETIME NOT NULL CONSTRAINT DF_tblLEAPLogsBioService_DTCreated DEFAULT (GETDATE()),

    CONSTRAINT PK_tblLEAPLogsBioService 
        PRIMARY KEY CLUSTERED (ID),

    CONSTRAINT FK_tblLEAPLogsBioService_tblLEAPBiometricServers
        FOREIGN KEY (ServerID)
        REFERENCES dbo.tblLEAPBiometricServers (ServerID)
);


