




SELECT * FROM tblReferenceMaster WHERE DTHoliday > '2025'





select * from tblMenu where LinkURL like '%hrdash%'

select * from tblMenu where ItemId > 10619 



--delete tblMenuUserAccess where ItemId in (select ItemId from tblMenu where ItemId > 10619)
--delete tblMenu where ItemId > 10619


select * from tblHR_AbsentType

SP_HELP tblHR_AbsentType


declare @typeLeaveForApproval  typeLeaveForApproval 
INSERT INTO @typeLeaveForApproval (LeaveType,DTLeave,LeaveHrsFrom,LeaveHrsTo,WorkHrs,ReasonCode,DTNotice,FileNotice,ReasonDesc)
VALUES 
('VL'
,'05/21/2026'
,'08:00'
,'18:30'
,'10'
,'UBL'
,'05/20/2026'
,'00002536-BL-05-21-2026.pdf'
,'test');

--SELECT * FROM @typeLeaveForApproval
EXEC spLEAP  @pOption = 32
,@pTypeLeaveForApproval=@typeLeaveForApproval
,@pActivity='SAVE'
,@pUserName = 'COORETO'
,@pModuleID = '11000'
,@pIDNumber = '00002536'

sp_help tblHR_PersonnelLeaves

select * from tblMenu 
select top 100 * from tblActivityLogHeader
order by DTCreated desc

select  top 100 * from tblHR_PersonnelLeaves order by  TransID  desc
select  top 100 * from tblHR_PersonnelLeaveBalance where IDNumber ='00002536'
 
select * from tblAAMApprover where TableName in ('tblHR_PersonnelLeaves','tblLEAPOfficialBusiness') order by DTCreated desc
select * from tblAAMApproverGroupHeader where AGHID in (select AGHID from tblAAMApproverPending where CreatedBy ='COORETO')
select * from tblAAMApproverGroupMembers where AID in (select AID from tblAAMApprover where TableName in ('tblHR_PersonnelLeaves','tblLEAPOfficialBusiness') )
select * from tblAAMApproverPending where CreatedBy ='COORETO'
SELECT * FROM tblAAMApproverAttachments
SELECT * FROM tblHR_PersonnelLeaves WHERE AGHID IS NOT NULL
select * from tblLEAPOfficialBusiness
 
DELETE tblAAMApprover where TableName in ('tblHR_PersonnelLeaves','tblLEAPOfficialBusiness')
DELETE tblAAMApproverGroupHeader where AGHID in (select AGHID from tblAAMApproverPending where CreatedBy ='COORETO')
DELETE tblAAMApproverGroupMembers where AID in (select AID from tblAAMApprover where TableName in ('tblHR_PersonnelLeaves','tblLEAPOfficialBusiness') )
DELETE tblAAMApproverPending where CreatedBy ='COORETO'
delete tblHR_PersonnelLeaves where TransID > 70245
update tblHR_PersonnelLeaveBalance set LeaveBalance = 80,ForPosting=0,AppliedLeave=0 where IDNumber ='00002536'
update tblEarnedLeaveQuota set LeaveTotalBalance = 80,ForPosting=0,AppliedLeave=0 where IDNumber ='00002536'
UPDATE tblHR_PersonnelLeaves SET BalanceAfter = 0 WHERE AGHID IS NOT NULL
delete  tblAAMApproverAttachments
delete tblLEAPOfficialBusiness



select * from tblHR_PersonnelLeaves where TransID > 70245





select * from tblMenu where LinkURL like '%AAM%'


select * from   tblMenuUserAccess where ItemId in (select ItemId from tblMenu where LinkURL like '%AAM%')

SELECT * FROM tblHR_PersonnelLeaves where IDNumber ='00002536'





select * from tblHR_AbsentType where WithQuota = 1
select * from tblHR_AbsentType where WithQuota = 0

SELECT A.LeaveCode FROM tblHR_PersonnelLeaveBalance A
JOIN tblHR_AbsentType B ON B.LeaveCode = A.LeaveCode
AND WithQuota = 1
WHERE IDNumber = '00002536'
AND A.LeaveCode = 'BL'
AND YEAR(DTFrom) = YEAR('2026')
AND ( B.EndDate IS NULL OR GETDATE() < B.EndDate )



select * from tblHR_WorkSchedule where SchedCode = 'SCH2'


SELECT B.SchedCode,A.IDNumber,B.WholeDay,B.FirstHalf,B.SecondHalf
FROM tblHR_PersonnelMaster A  
JOIN tblHR_WorkSchedule B ON A.SchedCode = B.SchedCode
WHERE A. UserName = 'cooreto'




EXEC spHR_ZKT @pOption = 9 , @pUserName = 'COORETO',@pDTApplied ='2026'

SELECT A.AGHID,A.TransID,A.IDNumber,A.LeaveCode,B.LeaveDesc
,ISNULL(CONVERT(VARCHAR,A.DTLeave,101),'') AS DTLeave
,A.LeaveHourFrom,A.LeaveHourTo
,ISNULL(CONVERT(VARCHAR,A.DTApplied,101),'') AS DTApplied
,A.LeaveReason,'','','','',A.Posted
,ISNULL(CONVERT(VARCHAR,A.DTPosted,101),'') AS DTPosted
,A.NumHours
FROM tblHR_PersonnelLeaves A 
LEFT JOIN tblHR_AbsentType B ON A.LeaveCode = B.LeaveCode
WHERE IDNumber = '00002536' AND year(A.DTApplied) > '2025'





select  * from tblHR_PersonnelMaster

select * from tblHR_WorkScheduleRD

select * from tblHR_AbsentType

select * from tblCCD_Holiday

select  * from update tblHR_PersonnelMaster set groupID = 1 where UnitCode ='f004' and EmployeeGroup > 'f' and DTSeparated is null
select * from tblHR_MonthlyEntPerGroup
select * from tblHR_LeaveEntGroup


sp_help tblHR_LeaveEntGroup



select * from tblHR_PersonnelMaster WHERE DepartmentCode ='ZFAD' AND DTSeparated IS NULL



declare @pTypeHRMLQLeaveTypes  typeHRMLQLeaveTypes 
INSERT INTO @pTypeHRMLQLeaveTypes (LeaveType,DTFrom,DTTo,Quota)
VALUES 
('BL' ,'01/01/2026' ,'01/31/2026' ,'11');

--SELECT * FROM @typeLeaveForApproval
EXEC spLEAP @pOption = 7
,@pTypeHRMLQLeaveTypes=@pTypeHRMLQLeaveTypes
,@pDepartmentCode='ZFAD'
,@pUnitCode=''


select * from tblLEAPLeaveTypeQuota 
select * from tblEarnedLeaveQuota
select * from tblHR_PersonnelLeaveBalance where  CreatedBy is not null
select * from tblHR_LeaveEntGroup

SELECT * FROM tblHR_MonthlyEntPerGroup WHERE LeaveCode = 'VL'
select * from tblhr_periodschedule

select DTRegular,* from tblHR_PersonnelMaster  where username='cooreto'

--insert into  tblHR_PersonnelLeaveBalance (IDNumber,LeaveCode,DTFrom,DTTo,Quota,LeaveBalance,AppliedLeave,ForPosting,LeaveUsed,Locked,LockedBy,LockedOn)
--select * from NDESS_DEV01.dbo.tblHR_PersonnelLeaveBalance





declare @pTypeLEAPOfficialBusiness  typeLEAPOfficialBusiness 
INSERT INTO @pTypeLEAPOfficialBusiness (
TransID,
IDNumber,
Purpose,
Attachment,
Reason,
Destination,
OBFrom,
OBTo,
NumHours
)
VALUES 
(
'0',
'00002536',
'Test OB',
'00002536_20260601_20260601064200.jpg',
'test OB',
'test OB',
'2026-06-01 06:42',
'2026-06-01 18:42',
'12.00');

--SELECT * FROM @typeLeaveForApproval
EXEC spLEAP @pOption = 34
,@pTypeLEAPOfficialBusiness=@pTypeLEAPOfficialBusiness
,@pActivity='SAVE'
,@pUserName = 'COORETO'
,@pModuleID = '11000'
,@pIDNumber = '00002536'










SELECT * FROM tblLEAPLogsBioService ORDER BY ID DESC

SELECT * FROM tblConfiguration WHERE Category ='LEAP' and Code ='BioLookBack'
SELECT * FROM tblLEAPBiometricServers
SELECT * FROM tblLEAPInOutRecords ORDER BY TimeInOut DESC

SELECT * FROM update tblLEAPBiometricServers set IPAddress ='192.168.3.49' where Office ='wto'

SELECT * FROM tblLEAPBiometricServers

SELECT * FROM tblLEAPInOutRecords where idnumber ='00002536'ORDER BY TimeInOut DESC

EXEC spLEAP @pOption = 39,@pCode='BioInterval'

