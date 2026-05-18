MERGE tblConfiguration_ActivePath AS T 
	USING (SELECT 'LEAP' AS Category, 'LEAPUPLOAD' AS Code) AS S ON T.Category = S.Category AND T.Code = S.Code 
	WHEN MATCHED 
		THEN 
		UPDATE SET Description = 'LEAP Upload file path', Value = '//192.168.1.11/Reports/LEAP/', isActive = 1, CreationDate = GETDATE(), CreatedBy = ORIGINAL_LOGIN() 
	WHEN NOT MATCHED THEN INSERT (Category, Code, Description, Value, isActive, CreationDate, CreatedBy) 
VALUES ('LEAP', 'LEAPUPLOAD', 'LEAP Upload file path', '//192.168.1.11/Reports/LEAP/', 1, GETDATE(), ORIGINAL_LOGIN());


MERGE tblConfiguration_ArchivePath AS T 
	USING (SELECT 'LEAP' AS Category, 'LEAPUPLOAD' AS Code) AS S ON T.Category = S.Category AND T.Code = S.Code 
	WHEN MATCHED 
		THEN 
		UPDATE SET Description = 'LEAP Upload file path', Value = '//192.168.1.11/Reports/LEAP/', isActive = 1, CreationDate = GETDATE(), CreatedBy = ORIGINAL_LOGIN() 
	WHEN NOT MATCHED THEN INSERT (Category, Code, Description, Value, isActive, CreationDate, CreatedBy) 
VALUES ('LEAP', 'LEAPUPLOAD', 'LEAP Upload file path', '//192.168.1.11/Reports/LEAP/', 1, GETDATE(), ORIGINAL_LOGIN());





