




SELECT * FROM tblCCD_Holiday WHERE DTHoliday > '2025'





select * from tblMenu where LinkURL like '%hrdash%'

select * from tblMenu where ItemId > 10619 



--delete tblMenuUserAccess where ItemId in (select ItemId from tblMenu where ItemId > 10619)
--delete tblMenu where ItemId > 10619


select * from tblHR_AbsentType



declare @typeLeaveForApproval  typeLeaveForApproval 
INSERT INTO @typeLeaveForApproval (LeaveType,DTFrom,DTTo,WorkHrs,Reason,DTNotice,FileNotice,ReasonDesc)
VALUES 
('BL', '2026-01-01', '2026-12-31','10', 'test','2026-03-10','test','test');
--SELECT * FROM @typeHRMLQLeaveTypes
EXEC spHR_ZKT @pOption = 32 ,@pTypeLeaveForApproval=@typeLeaveForApproval




select top 100 * from tblActivityLogHeader
order by DTCreated desc

select * from tblHR_PersonnelLeaves where TransID


select * from tblModule WHERE ModuleCode = 'AAM'


select * from tblMenu where LinkURL like '%AAM%'


select * from   tblMenuUserAccess where ItemId in (select ItemId from tblMenu where LinkURL like '%AAM%')

SELECT * FROM tblHR_PersonnelLeaves where IDNumber ='00002536'


























