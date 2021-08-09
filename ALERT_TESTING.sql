
-- Transfer users


set quoted_identifier off
select  distinct "exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='"+rtrim(c.groupname)+"'"
from EQRDBA..ALERT_NOTIF_PERSONS a 
	join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.active = 1

set quoted_identifier off
select  distinct "exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='"+rtrim(a.EMAILADDR)+"', @EMAILADDR ='"+rtrim(a.EMAILADDR)+"'"
from EQRDBA..ALERT_NOTIF_PERSONS a 
	join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.active = 1

select distinct 
	"exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='"+rtrim(a.EMAILADDR)+"', @GROUPNAME ='"+rtrim(c.groupname)+"', @TYPEID = "+rtrim(cast(b.typeid as varchar(10)))+", @CRITICALITY_LEVEL = 4"
from EQRDBA..ALERT_NOTIF_PERSONS a 
	join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.active = 1

/*
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='ALAN_TEST'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='CriticalDatesRpt'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='DBA'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='DBA_MRI_SQL_ALERT'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='FRB_NOTIFY'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='KHARI_TEST'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='LRO'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='MAIL_TEST'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='PrefEmpReport'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='PRICING_BING'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='PricingDatamartLoadTest'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='PricingDM'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='PRICINGDM_ADMIN'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='PRICINGDM_LRO81'
exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='SQLSupport'

exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='aadam@eqr.com', @EMAILADDR ='aadam@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='AArchie@eqr.com', @EMAILADDR ='AArchie@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='ABaker@eqr.com', @EMAILADDR ='ABaker@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='adanque@eqr.com', @EMAILADDR ='adanque@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='DDear@eqr.com', @EMAILADDR ='DDear@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='ecortes@eqr.com', @EMAILADDR ='ecortes@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='HStarck@eqr.com', @EMAILADDR ='HStarck@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='jhu@eqr.com', @EMAILADDR ='jhu@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='jvan@eqr.com', @EMAILADDR ='jvan@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='kbuchanan@eqr.com', @EMAILADDR ='kbuchanan@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='NSickler@eqr.com', @EMAILADDR ='NSickler@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='RVoinovich@eqr.com', @EMAILADDR ='RVoinovich@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='SMerchant@eqr.com', @EMAILADDR ='SMerchant@eqr.com'
exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='TBuhay@eqr.com', @EMAILADDR ='TBuhay@eqr.com'

exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='aadam@eqr.com', @GROUPNAME ='PricingDatamartLoadTest', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='AArchie@eqr.com', @GROUPNAME ='MAIL_TEST', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='AArchie@eqr.com', @GROUPNAME ='PrefEmpReport', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='ABaker@eqr.com', @GROUPNAME ='CriticalDatesRpt', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='ABaker@eqr.com', @GROUPNAME ='MAIL_TEST', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='ALAN_TEST', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='CriticalDatesRpt', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='DBA', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='DBA_MRI_SQL_ALERT', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='FRB_NOTIFY', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='LRO', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='MAIL_TEST', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='PrefEmpReport', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='PRICING_BING', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='PricingDatamartLoadTest', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='PricingDM', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='PRICINGDM_ADMIN', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='SQLSupport', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='DDear@eqr.com', @GROUPNAME ='LRO', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='DDear@eqr.com', @GROUPNAME ='MAIL_TEST', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='ecortes@eqr.com', @GROUPNAME ='DBA', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='HStarck@eqr.com', @GROUPNAME ='PricingDatamartLoadTest', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='HStarck@eqr.com', @GROUPNAME ='PricingDM', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jhu@eqr.com', @GROUPNAME ='MAIL_TEST', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='DBA', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='DBA_MRI_SQL_ALERT', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='LRO', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='MAIL_TEST', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='PRICING_BING', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='PricingDatamartLoadTest', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='PricingDM', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='PRICINGDM_LRO81', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='jvan@eqr.com', @GROUPNAME ='SQLSupport', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='kbuchanan@eqr.com', @GROUPNAME ='DBA', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='kbuchanan@eqr.com', @GROUPNAME ='KHARI_TEST', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='kbuchanan@eqr.com', @GROUPNAME ='SQLSupport', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='NSickler@eqr.com', @GROUPNAME ='PrefEmpReport', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='RVoinovich@eqr.com', @GROUPNAME ='CriticalDatesRpt', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='RVoinovich@eqr.com', @GROUPNAME ='MAIL_TEST', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='RVoinovich@eqr.com', @GROUPNAME ='PrefEmpReport', @TYPEID = 2, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='SMerchant@eqr.com', @GROUPNAME ='PrefEmpReport', @TYPEID = 1, @CRITICALITY_LEVEL = 4
exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='TBuhay@eqr.com', @GROUPNAME ='PrefEmpReport', @TYPEID = 1, @CRITICALITY_LEVEL = 4


*/

exec SQLAlert..sp_SQLAlert

select  * from EQRDBA..ALERT_SERVER_TBL

select * from SQLAlert..ALERT_MESSAGES (nolock)

select * from EQRDBA..ALERT_REMOTE_SERVER (NOLOCK)
select * from SQLAlert..ALERT_REMOTE_SERVER (NOLOCK)

exec SQLALERT..SP_SQLALERT 
	 @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer
	,@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both
	,@SUBJECT= 'TEST SUBJECT - SUCCESS DEVSQL29' 
	,@MESSAGE= 'TEST MESSAGE' 


exec SQLALERT..SP_SQLALERT 
	 @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer
	,@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both
	,@SUBJECT= 'TEST SUBJECT - WARN DEVSQL29' 
	,@MESSAGE= 'TEST MESSAGE' 


exec SQLALERT..SP_SQLALERT 
	 @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer
	,@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both
	,@SUBJECT= 'TEST SUBJECT - FAIL NOW 2 DEVSQL29' 
	,@MESSAGE= 'TEST MESSAGE FROM ALAN NOW 2' 

	 
exec SQLALERT..SP_SQLALERT 
	 @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer
	,@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both
	,@SUBJECT= 'TEST SUBJECT - ERROR DEVSQL29' 
	,@MESSAGE= 'TEST MESSAGE' 

exec EQRDBA..SP_SQLALERT 
	 @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer
	,@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both
	,@SUBJECT= 'TEST SUBJECT - ERROR' 
	,@MESSAGE= 'TEST MESSAGE' 


exec EQRDBA..SP_SQLALERT 
	 @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer
	,@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both
	,@SUBJECT= 'TEST SUBJECT - ERROR' 
	,@MESSAGE= 'TEST MESSAGE' 

Usage
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
exec SQLALERT..SP_SQLALERT 
	 @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer
	,@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both
	,@SUBJECT= 'TEST SUBJECT' 
	,@MESSAGE= 'TEST MESSAGE' 
	-- ,@ATTACH_FILEPATH = '\\mrisql01\c$\scripts\CheckFreeSpace.log;\\mrisql01\c$\scripts\DriveInfo.log' -- not available on jsSMTP Mail
	-- ,@PRIORITY = 'NORMAL'  -- 'HIGH' / same as @importance however Low, Normal, High
	-- ,@ALERT_METHOD  = 0	-- 0 server preconfigured default, 1 xp_sendmail, 2 smtp mail, 3 DatabaseMail, 4 xpSMTPMAIL, 5 Javamail
	-- ,@NORESENDDURATION  = 0 -- seconds 
	-- ,@NORESEND  = 0
	-- ,@DISPLAYUSAGE = 0
	
	-- ,@QUERY = 'select * from master..syslogins (nolock)' -- only available for SQLMail & DB Mail. Note: Limitation on rows.

	-- ,@ALIASFROMNAME = 'ALIASNAME@eqrworld.com' 	-- only available for xpSMTP Mail
	-- ,@DISPLAYFROMNAME = 'DISPLAY NAME'		-- only available for xpSMTP Mail
	-- ,@REPLYTO = 'adanque@eqrworld.com'		-- only available for xpSMTP Mail
	-- ,@HTMLMESSAGEFILE = 'file.html'  		-- only available for xpSMTP Mail
	-- ,@MAILTYPE = 'text/plain' -- 'text/html' -- , @body_format = 'TEXT' -- 'HTML' -- only available for xpSMTP Mail & DB Mail

	-- ,@ATTACH_QUERY_RESULT_AS_FILE = 1		-- only available for DB Mail
	-- ,@QUERY_ATTACHMENT_FILENAME = 'QueryResults.txt'-- only available for DB Mail
	-- ,@APPEND_QUERY_ERROR = 1			-- only available for DB Mail


	 Use the below query to list all SP_SQLALERT groups and members
	 --------------------------------------------------------------
	select a.PERSON, a.EMAILADDR, c.groupname, b.* from SQLALERT..ALERT_NOTIF_PERSONS a 
	join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join SQLALERT..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	order by c.groupname desc
	 --------------------------------------------------------------


	 -- 	To add PERSONs to alert
	 exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='Alan Danque', @EMAILADDR ='adanque@eqr.com'
	 
	 -- 	To add group to alert 
	 exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='DBA'

	 -- 	To add group member
	 exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='DBA', @TYPEID = 1 --Types are 1 = to, 2 = cc, 3 = bcc




	 -- 	To add PERSONs to alert
	 exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='Alan Danque', @EMAILADDR ='adanque@eqr.com'
	exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='Alan Danque', @EMAILADDR ='adanque@gmail.com'

	 -- 	To add group to alert 
	 exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='ALAN_TEST'

	 -- 	To add group member
	 exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='ALAN_TEST', @TYPEID = 1 --Types are 1 = to, 2 = cc, 3 = bcc
	 exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@gmail.com', @GROUPNAME ='ALAN_TEST', @TYPEID = 1 --Types are 1 = to, 2 = cc, 3 = bcc
			,@CRITICALITY_LEVEL = 1 -- 4 all, 2 warn, 1 fail/error


	 -- 	Notes: 	To disable PERSONs to alert
	 -- update ALERT_NOTIF_PERSONS set ACTIVE = 0 where id = 3 --  where id is the users id from ALERT_NOTIF_PERSONS
	 -- update ALERT_NOTIF_PERSONS set ACTIVE = 1 where id = 3



Completion time: 2021-07-08T09:32:09.8672356-05:00





select a.PERSON, a.EMAILADDR, c.groupname, b.* 
from EQRDBA..ALERT_NOTIF_PERSONS a 
	join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
order by c.groupname desc


select a.PERSON, a.EMAILADDR, c.groupname, b.* 
from SQLALERT..ALERT_NOTIF_PERSONS a 
	join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join SQLALERT..ALERT_NOTIF_GROUPS c on c.id = b.GID 
order by c.groupname desc

Update b set b.cid = 1
	from SQLALERT..ALERT_NOTIF_PERSONS a 
		join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
		join SQLALERT..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.emailaddr = 'adanque@gmail.com'
		and c.groupname = 'ALAN_TEST'






set quoted_identifier off
select  distinct "exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='"+rtrim(c.groupname)+"'"
from EQRDBA..ALERT_NOTIF_PERSONS a 
	join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.active = 1

set quoted_identifier off
select  distinct "exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='"+rtrim(a.EMAILADDR)+"', @EMAILADDR ='"+rtrim(a.EMAILADDR)+"'"
from EQRDBA..ALERT_NOTIF_PERSONS a 
	join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.active = 1

select distinct 
	"exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='"+rtrim(a.EMAILADDR)+"', @GROUPNAME ='"+rtrim(c.groupname)+"', @TYPEID = "+rtrim(cast(b.typeid as varchar(10)))+", @CRITICALITY_LEVEL = 4"
from EQRDBA..ALERT_NOTIF_PERSONS a 
	join EQRDBA..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join EQRDBA..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.active = 1

select a.PERSON, a.EMAILADDR, c.groupname, b.* 
from SQLALERT..ALERT_NOTIF_PERSONS a 
	join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join SQLALERT..ALERT_NOTIF_GROUPS c on c.id = b.GID 
order by c.groupname desc

