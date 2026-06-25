






SELECT * FROM tblConfiguration where Category ='LEAP'

MERGE tblConfiguration AS T 
	USING (SELECT 'LEAP' AS Category, 'BioInterval' AS Code) AS S ON T.Category = S.Category AND T.Code = S.Code 
	WHEN MATCHED 
		THEN 
		UPDATE SET Description = 'LeAP Biometric Service - How often the worker should reconnect and read new attendance logs interval for retreiving the attendance', Value = '500', isActive = 1, CreationDate = GETDATE(), CreatedBy = ORIGINAL_LOGIN() 
	WHEN NOT MATCHED THEN INSERT (Category, Code, Description, Value, isActive, CreationDate, CreatedBy) 
VALUES ('LEAP', 'BioInterval', 'LeAP Biometric Service - How often the worker should reconnect and read new attendance logs interval for retreiving the attendance', '500', 1, GETDATE(), ORIGINAL_LOGIN());


MERGE tblConfiguration AS T 
	USING (SELECT 'LEAP' AS Category, 'BioLookBack' AS Code) AS S ON T.Category = S.Category AND T.Code = S.Code 
	WHEN MATCHED 
		THEN 
		UPDATE SET Description = 'LeAP Biometric Service - LookBackMinutes On the first run we read a small history window so we can catch recent punches to Look Back', Value = '1440', isActive = 1, CreationDate = GETDATE(), CreatedBy = ORIGINAL_LOGIN() 
	WHEN NOT MATCHED THEN INSERT (Category, Code, Description, Value, isActive, CreationDate, CreatedBy) 
VALUES ('LEAP', 'BioLookBack', 'LeAP Biometric Service - LookBackMinutes On the first run we read a small history window so we can catch recent punches to Look Back', '1440', 1, GETDATE(), ORIGINAL_LOGIN());


--MERGE tblConfiguration AS T 
--	USING (SELECT 'LEAP' AS Category, 'RetirementAge' AS Code) AS S ON T.Category = S.Category AND T.Code = S.Code 
--	WHEN MATCHED 
--		THEN 
--		UPDATE SET Description = 'Age retirement of the emplyee', Value = '60', isActive = 1, CreationDate = GETDATE(), CreatedBy = ORIGINAL_LOGIN() 
--	WHEN NOT MATCHED THEN INSERT (Category, Code, Description, Value, isActive, CreationDate, CreatedBy) 
--VALUES ('LEAP', 'RetirementAge', 'Age retirement of the emplyee', '60', 1, GETDATE(), ORIGINAL_LOGIN());

MERGE tblConfiguration AS T 
	USING (SELECT 'LEAP' AS Category, 'LeaveGroup' AS Code) AS S ON T.Category = S.Category AND T.Code = S.Code 
	WHEN MATCHED 
		THEN 
		UPDATE SET Description = 'Use to compute the Leave in Days', Value = '8', isActive = 1, CreationDate = GETDATE(), CreatedBy = ORIGINAL_LOGIN() 
	WHEN NOT MATCHED THEN INSERT (Category, Code, Description, Value, isActive, CreationDate, CreatedBy) 
VALUES ('LEAP', 'LeaveGroup', 'Use to compute the Leave in Days', '8', 1, GETDATE(), ORIGINAL_LOGIN());


SELECT * FROM tblConfiguration where Category ='LEAP'



