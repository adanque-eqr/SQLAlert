-- Author: Alan Danque
-- Date:   20210723
-- Purpose:Transfer sql alert group, recipients and alert group membership configs
-- Note: Defaults the critical users group to 4.

declare @rowcnt int, @currow int, @cmd varchar(8000)
if object_id('tempdb..#command') is not null drop table #command 
create table #command (rowid int identity(1, 1), cmd varchar(8000))

-- transfer users
set quoted_identifier off
insert into #command (cmd)
	select  distinct "exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='"+rtrim(c.groupname)+"'"
	from EQRDBA..ALERT_NOTIF_PERSONS a 
		join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
		join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
		where a.active = 1

insert into #command (cmd)
	select  distinct "exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='"+rtrim(a.EMAILADDR)+"', @EMAILADDR ='"+rtrim(a.EMAILADDR)+"'"
	from EQRDBA..ALERT_NOTIF_PERSONS a 
		join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
		join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
		where a.active = 1

insert into #command (cmd)
	select distinct 
		"exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='"+rtrim(a.EMAILADDR)+"', @GROUPNAME ='"+rtrim(c.groupname)+"', @TYPEID = "+rtrim(cast(b.typeid as varchar(10)))+", @CRITICALITY_LEVEL = 4"
	from EQRDBA..ALERT_NOTIF_PERSONS a 
		join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
		join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
		where a.active = 1

select @currow = 1, @rowcnt = count(*) from #command 
while @currow <= @rowcnt
begin
	select @cmd = cmd from #command where rowid = @currow 
	select @cmd 
	exec(@cmd)
	select @currow = @currow + 1
end
