
USE [SQLALERT]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

if object_id('SP_ALERT_GETNEXTID') is not null drop proc SP_ALERT_GETNEXTID
go
CREATE PROC [dbo].[SP_ALERT_GETNEXTID] 
	 @SEQNAME VARCHAR(100)
	,@OUTVAL INT OUTPUT
AS
--AUTHOR: ALAN DANQUE
UPDATE SQLALERT..ALERT_SEQUENCE 
	SET @OUTVAL = SEQID = SEQID + 1
	WHERE SEQNAME=@SEQNAME--'SMTPEMAIL'
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

if object_id('SP_TSQLRETINTVAL') is not null drop proc SP_TSQLRETINTVAL
go

CREATE proc [dbo].[SP_TSQLRETINTVAL]
	 @sqlCmd varchar(8000)
	,@resval float output
	,@type int -- 1 for counts, 2 for records affected, 3 PASS SQL FILE.
	,@SERVERNAME varchar(100)=''
	,@NOEXECUTE int = 0
as
/*
Author:	Alan Danque
Date:	Mar 26, 2007
Purpose:Created to return the counts of verification rows and updated rows for execution of dynamic tsql.
*/
set quoted_identifier off
set nocount on
declare @dos_cmd varchar(8000), @EIDVAL int, @dynasqlfile varchar(1000), @GetRowID int
if object_id('tempdb..#tmp_results') is not null drop table #tmp_results
create table #tmp_results (
	 rowid int identity(1, 1)
	,results varchar(8000)
	)
IF @SERVERNAME = ''
begin
	SELECT @SERVERNAME = '(local)'
end
select @sqlCmd
select @resval = 0
if @NOEXECUTE = 0
begin	
	if @type =1 
	begin
		insert into #tmp_results
			exec(@sqlCmd)
		select @resval = cast(results as float) from #tmp_results where rowid = 1
	end
	if @type = 2
	begin

		exec SQLALERT..sp_ALERT_GetNextID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
		insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @sqlCmd)

		select @dynasqlfile = 'c:\scripts\temp\DYNAMIC_SQL_TMP.sql'
		select @dynasqlfile 
		select  @sqlCmd ="master..xp_cmdshell " + "'bcp " + '"' + "select * from SQLALERT.dbo.fn_VariableValueToTableSession(" + rtrim(cast( @EIDVAL as varchar(100)))  + ")" + '"' + " queryout " +  rtrim(@dynasqlfile) + " -c -T ' "
		select  @sqlCmd 
		exec(@sqlCmd)

		select @dos_cmd = "osql -S" +rtrim(@SERVERNAME)+ " -E -n -i c:\scripts\temp\DYNAMIC_SQL_TMP.sql " -- -Q " + '"' + rtrim(@sqlCmd) + '"'
		insert into #tmp_results
			exec master..xp_cmdshell @dos_cmd
		select * from #tmp_results
		IF (select ISNUMERIC(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', '')) from #tmp_results where rowid = 1)=1
		begin
			select @resval = cast(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', '') as float) from #tmp_results where rowid = 1
		end
		else
			begin
				select @resval = -1
			end
	end
	if @type = 3
	begin
		select @dos_cmd = "type " +rtrim(@sqlCmd) 
		EXEC master..xp_cmdshell @dos_cmd
	
		select @dos_cmd = "osql -S" +rtrim(@SERVERNAME)+ " -E -n -i " + rtrim(@sqlCmd)  
		select @dos_cmd
		
		insert into #tmp_results
			exec master..xp_cmdshell @dos_cmd
		select * from #tmp_results
		IF (select ISNUMERIC(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', '')) from #tmp_results where rowid = 1)=1
		begin
			select @resval = cast(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', '') as float) from #tmp_results where rowid = 1
		end
		else
			begin
				select @resval = -1
			end
	end
	if @type =4 -- Query results top with header.
	begin

		exec SQLALERT..sp_ALERT_GetNextID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
		insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @sqlCmd)

		select @dynasqlfile = 'c:\scripts\temp\DYNAMIC_SQL_TMP_'+rtrim(cast(@EIDVAL as varchar(1000)))+'.sql'
		select @dynasqlfile 
		select  @sqlCmd ="master..xp_cmdshell " + "'bcp " + '"' + "select * from SQLALERT.dbo.fn_VariableValueToTableSession(" + rtrim(cast( @EIDVAL as varchar(100)))  + ")" + '"' + " queryout " +  rtrim(@dynasqlfile) + " -c -T ' "
		select  @sqlCmd 
		exec(@sqlCmd)

		select @dos_cmd = "osql -S" +rtrim(@SERVERNAME)+ " -E -n -i " +rtrim(@dynasqlfile) -- -Q " + '"' + rtrim(@sqlCmd) + '"'
		insert into #tmp_results
			exec master..xp_cmdshell @dos_cmd
		select * from #tmp_results
		--IF (select ISNUMERIC(replace(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', ''),'row(s) affected)','')) from #tmp_results where rowid = 3)=1
		IF (select top 1 ISNUMERIC(replace(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', ''),'row(s) affected)','')) from #tmp_results where results like '%affected%' order by rowid asc)=1
		begin
			--select @resval = cast(replace(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', ''),'row(s) affected)','') as float) from #tmp_results where rowid = 3
			select top 1 @resval = cast(replace(replace(replace(replace(rtrim(results), '(',''), 'row affected)', ''),'rows affected)', ''),'row(s) affected)','') as float) from #tmp_results where results like '%affected%' order by rowid asc
		end
		else
			begin
				select @resval = -1
			end
	end
	
	if @type =5 -- Get ReturnThisVal 
	begin


		exec SQLALERT..sp_ALERT_GetNextID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
		insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @sqlCmd)

		select @dynasqlfile = 'c:\scripts\temp\DYNAMIC_SQL_TMP_'+rtrim(cast(@EIDVAL as varchar(1000)))+'.sql'
		select @dynasqlfile 
		select  @sqlCmd ="master..xp_cmdshell " + "'bcp " + '"' + "select * from SQLALERT.dbo.fn_VariableValueToTableSession(" + rtrim(cast( @EIDVAL as varchar(100)))  + ")" + '"' + " queryout " +  rtrim(@dynasqlfile) + " -c -T ' "
		select  @sqlCmd 
		exec(@sqlCmd)

		select @dos_cmd = "osql -S" +rtrim(@SERVERNAME)+ " -E -n -i " +rtrim(@dynasqlfile) -- -Q " + '"' + rtrim(@sqlCmd) + '"'
		insert into #tmp_results
			exec master..xp_cmdshell @dos_cmd
		select @GetRowID = min(rowid) from #tmp_results where results like '%ReturnThisVal%' 
		IF (select ISNUMERIC(replace(replace(replace(rtrim(results), '(',''), ' ReturnThisVal', ''),'rows affected)', '')) from #tmp_results where rowid = @GetRowID)=1
		begin
			select @resval = cast(replace(replace(replace(rtrim(results), '(',''), ' ReturnThisVal', ''),'rows affected)', '') as float) from #tmp_results where rowid = @GetRowID
		end
		else
			begin
				select @resval = -1
			end
	end
end	
GO

if object_id('sp_GetCurrentDefaultEmail') is not null drop proc sp_GetCurrentDefaultEmail
go


CREATE PROC [dbo].[sp_GetCurrentDefaultEmail] @SQLSERVER VARCHAR(50), @ALERT_ID int OUTPUT
as
--AUTHOR: ALAN DANQUE
--DATE:
--PURPOSE:CREATED FOR CROSS SERVER SUPPORT.
--VERSION: 20190911~ATD:Added CSMail verification 
SET QUOTED_IDENTIFIER OFF
SET NOCOUNT ON
DECLARE  @SQL_CMD VARCHAR(8000)
	,@ROWCNT INT
	,@CURROW INT
	,@ALERTIDVAL INT
	,@RETVAL INT
	,@VERIFYEMAIL INT
	,@DOS_CMD VARCHAR(2000)
	,@ALERTNAME VARCHAR(50)

IF OBJECT_ID('TEMPDB..#EMAILORDER') IS NOT NULL DROP TABLE #EMAILORDER
CREATE TABLE #EMAILORDER (ALERTID int, ALERTNAME VARCHAR(512), ALERTPRIORITY int) 

IF OBJECT_ID('TEMPDB..#TMP_RESULTS') IS NOT NULL DROP TABLE #TMP_RESULTS
CREATE TABLE #TMP_RESULTS (
	 ROWID int IDENTITY(1, 1)
	,RESULTS VARCHAR(1000)
	)

SELECT @SQL_CMD = "SELECT RTRIM(CAST(ALERTID AS VARCHAR(5)))+'~'+RTRIM(ALERTNAME)+'~'+ RTRIM(CAST(ALERTPRIORITY AS VARCHAR(5))) FROM SQLALERT..ALERT_METHOD_PRIORITY"
SELECT @DOS_CMD = "osql -S" +RTRIM(@SQLSERVER)+ " -E -Q " + '"' + RTRIM(@SQL_CMD ) + '"'
INSERT INTO #TMP_RESULTS
	EXEC master..xp_cmdshell @DOS_CMD

INSERT INTO #EMAILORDER
SELECT    CAST(RTRIM(LTRIM(REPLACE(SUBSTRING(RESULTS, 1, CHARINDEX('~', RESULTS, 1)),'~',''))) AS int)
	, RTRIM(LTRIM(REPLACE(SUBSTRING(RESULTS, CHARINDEX('~', RESULTS, 1)+1, CHARINDEX('~', RESULTS, CHARINDEX('~', RESULTS, 1)+1) - CHARINDEX('~', RESULTS, 1)-1),'~','')))
	, CAST(SUBSTRING(RESULTS, CHARINDEX('~', RESULTS, CHARINDEX('~', RESULTS, 1)+1)+1, 2) AS int)
	FROM #TMP_RESULTS WHERE RESULTS LIKE '%~%'
	
SELECT @ROWCNT = COUNT(*) FROM #EMAILORDER
SELECT @ROWCNT ASEMAILTYPES

SELECT @CURROW = 1, @RETVAL = 0
WHILE @CURROW <= @ROWCNT OR @RETVAL = 0
BEGIN
	SELECT @ALERTIDVAL = ALERTID FROM #EMAILORDER WHERE ALERTPRIORITY = @CURROW
		IF @ALERTIDVAL = 1
		BEGIN
			SELECT '1'
			EXEC SQLALERT..SP_TSQLRETINTVAL @sqlCmd ="DECLARE @RETVAL int EXEC @RETVAL = master..xp_sendmail @RECIPIENTS='sqlserver@EQRWORLD.COM', @SUBJECT='TEST EMAIL' SELECT RTRIM(CAST(@RETVAL AS VARCHAR(255))) + ' RETURNTHISVAL' ", 
				@TYPE=5, 
				@RESVAL = @VERIFYEMAIL OUTPUT, 
				@SERVERNAME = @SQLSERVER
			IF @VERIFYEMAIL = 0 GOTO RETURNVAL
		END

		IF @ALERTIDVAL = 2
		BEGIN
			SELECT '2'
			EXEC SQLALERT..SP_TSQLRETINTVAL @sqlCmd ="DECLARE @RETVAL int EXEC @RETVAL = SQLALERT.dbo.SP_SQLSMTPMAIL @TO='SQLSERVER@EQRWORLD.COM', @SUBJECT = 'EMAIL TEST' SELECT RTRIM(CAST(@RETVAL AS VARCHAR(255))) + ' RETURNTHISVAL' ", 
				@TYPE=5, 
				@RESVAL = @VERIFYEMAIL OUTPUT, 
				@SERVERNAME = @SQLSERVER
			IF @VERIFYEMAIL = 0 GOTO RETURNVAL
		END

		IF @ALERTIDVAL = 3
		BEGIN
			SELECT '3'
			EXEC SQLALERT..SP_TSQLRETINTVAL @sqlCmd ="DECLARE @RETVAL int EXEC @RETVAL = MSDB..SP_SEND_DBMAIL @PROFILE_NAME = 'DATABASEMAIL', @RECIPIENTS = 'SQLSERVER@EQRWORLD.COM', @SUBJECT = 'EMAIL TEST' SELECT RTRIM(CAST(@RETVAL AS VARCHAR(255))) + ' RETURNTHISVAL' ", 
				@TYPE=5, 
				@RESVAL = @VERIFYEMAIL OUTPUT, 
				@SERVERNAME = @SQLSERVER
			IF @VERIFYEMAIL = 0 GOTO RETURNVAL
		END

		IF @ALERTIDVAL = 4
		BEGIN
			SELECT '4'
			EXEC SQLALERT..SP_TSQLRETINTVAL @sqlCmd ="DECLARE @RETVAL int EXEC @RETVAL = master.dbo.xp_smtp_sendmail @SERVER = 'EQRSMTP01', @PORT = 25, @PING = 1 SELECT RTRIM(CAST(@RETVAL AS VARCHAR(255))) + ' RETURNTHISVAL' ", 
				@TYPE=5, 
				@RESVAL = @VERIFYEMAIL OUTPUT, 
				@SERVERNAME = @SQLSERVER
			IF @VERIFYEMAIL = 0 GOTO RETURNVAL
		END

		IF @ALERTIDVAL = 5
		BEGIN
			SELECT '5'

				declare @javamailtest  varchar(8000)
				if object_id('tempdb..#VERIFYJAVAMAIL') is not null drop table #VERIFYJAVAMAIL
				create table #VERIFYJAVAMAIL (rowid int identity(1,1), resval varchar(8000))

				select @javamailtest  = 'java SendFileEmailArg3 "sqltestserver@eqr.com;" "" "" "SQLTestServer@eqrworld.com" "TEST SUBJECT" "100" "" "3" "SQLTestServer@eqrworld.com" '+rtrim(@@servername)
				select @javamailtest  
				insert into #VERIFYJAVAMAIL(resval)	
					exec master..xp_cmdshell @javamailtest 

				if exists(select * from #VERIFYJAVAMAIL where resval like '%Sent message successfully....%')
				begin
					select @VERIFYEMAIL =0
				end
				else
					begin
						select 'fail'
					end

			--EXEC SQLALERT..SP_TSQLRETINTVAL @sqlCmd ="DECLARE @RETVAL int EXEC @RETVAL = master.dbo.xp_smtp_sendmail @SERVER = 'EQRSMTP01', @PORT = 25, @PING = 1 SELECT RTRIM(CAST(@RETVAL AS VARCHAR(255))) + ' RETURNTHISVAL' ", 
			--	@TYPE=5, 
			--	@RESVAL = @VERIFYEMAIL OUTPUT, 
			--	@SERVERNAME = @SQLSERVER
			IF @VERIFYEMAIL = 0 GOTO RETURNVAL
		END

		IF @ALERTIDVAL = 6
		BEGIN
			SELECT '6'

				declare @csmailtest varchar(8000)
				if object_id('tempdb..#VERIFYCSMAIL') is not null drop table #VERIFYCSMAIL
				create table #VERIFYCSMAIL (rowid int identity(1,1), resval varchar(8000))

				select @csmailtest = 'c:\scripts\csmail\sqlalert.exe "sqltestserver@eqr.com;" "" "" "SQLTestServer@eqrworld.com" "TEST SUBJECT" "100" "" "3" "SQLTestServer@eqrworld.com" '+rtrim(@@servername)+' "SQLAlert"' 
				select @csmailtest 
				insert into #VERIFYCSMAIL(resval)	
					exec master..xp_cmdshell @csmailtest 

				if exists(select * from #VERIFYCSMAIL where resval like '%Sent message successfully....%')
				begin
					select @VERIFYEMAIL =0
				end
				else
					begin
						select 'fail'
					end

			--EXEC SQLALERT..SP_TSQLRETINTVAL @sqlCmd ="DECLARE @RETVAL int EXEC @RETVAL = master.dbo.xp_smtp_sendmail @SERVER = 'EQRSMTP01', @PORT = 25, @PING = 1 SELECT RTRIM(CAST(@RETVAL AS VARCHAR(255))) + ' RETURNTHISVAL' ", 
			--	@TYPE=5, 
			--	@RESVAL = @VERIFYEMAIL OUTPUT, 
			--	@SERVERNAME = @SQLSERVER
			IF @VERIFYEMAIL = 0 GOTO RETURNVAL
		END


	SELECT @CURROW LOOPINGATD
	SELECT @CURROW = @CURROW + 1
END
RETURNVAL:
SELECT @ALERTNAME = ALERTNAME FROM #EMAILORDER WHERE ALERTID = @ALERTIDVAL  
SELECT @DOS_CMD = 'osql -S ' +RTRIM(@SQLSERVER)+ ' -E -Q "' + "UPDATE SQLALERT..ALERT_EMAIL_METHOD SET DEFAULT_ALERT = '" + RTRIM(@ALERTIDVAL) + "', DESCRIPTION= '" + RTRIM(@ALERTNAME) + "'" + '"'
SELECT @DOS_CMD 
EXEC master..xp_cmdshell @DOS_CMD
SELECT @ALERT_ID = @ALERTIDVAL

GO




if object_id('sp_SQLAlert') is not null drop proc sp_SQLAlert
go

CREATE PROC [dbo].[sp_SQLAlert] 
	 @SUBJECT varchar(1000) = ''
	,@MESSAGE varchar(8000) = ''
	,@GROUPNAME varchar(100)=''
	,@EMAIL_ADDRESS varchar(100)=''
	,@SQLMAILSERVER varchar(20)=''
	,@ATTACH_FILEPATH varchar(8000)=''
	,@QUERY varchar(8000)=''
	,@ALERT_METHOD int = 6	-- 0 server preconfigured default, 1 xp_sendmail, 2 smtp mail, 3 xpSMTPMAIL, 4 DatabaseMail, 5 Javamail, 6 CSMail
	,@NORESENDDURATION int = 0
	,@NORESEND int = 0
	,@DISPLAYUSAGE int = 0  -- 0 default dont show usage, 1 displays usage for type selected
		-- NEW Parms xpSMTP
	,@SMTPServer varchar(30) = 'EQRSMTP01'
	,@ALIASFROMNAME varchar(256) = ''
	,@DISPLAYFROMNAME varchar(256) = ''
	,@REPLYTO varchar(1000) = 'SQLServer@eqrworld.com'
	,@PRIORITY varchar(20) = 'NORMAL' -- 'HIGH' / same as @importance however Low, Normal, High
	,@TIMEOUT int = 10000
	,@HTMLMESSAGEFILE varchar(8000) = ''
	,@MAILTYPE varchar(256) = 'text/plain' -- 'text/html' -- , @body_format = 'TEXT' -- 'HTML'
		-- NEW DatabaseMail
	,@SENSITIVITY varchar(50) = 'Normal' -- Normal, PERSONal, Private, Confidential
	,@ATTACH_QUERY_RESULT_AS_FILE int = 0 -- defaults to 0 when set to 1 it attaches query results as file
	,@QUERY_ATTACHMENT_FILENAME varchar(512) = 'Query_Results.txt'
	,@APPEND_QUERY_ERROR int = 1
as
-- Author: 	Alan Danque	
-- Date:	May 11, 2006
-- Purpose:	Build alert and log for historical purposes
/*
Notes: 	

Versions:
	V20170718ATD: Modified to default @REPLYTO and @ALIASFROMNAME on send per Google 10k email limitation on single account.
	V20190911ATD: Modified to CSEMail
	V20210520ATD: Modified to Add Critical Text Rules
*/
set quoted_identifier off
declare  @SQL_CMD varchar(8000)
	,@rowcnt int
	,@currow int
	,@NOTIFIER int
	,@NOTIFIED varchar(7500)
	,@EMAILADDRESS varchar(100)
	,@ERROR_MSG varchar(1000)
	,@SQLSERVER varchar(20)
	,@SQLSERVER_T varchar(20)
	,@STARTEMAIL int
	,@TO_FIELD varchar(1000)
	,@CC_FIELD varchar(1000)
	,@BCC_FIELD varchar(1000)
	,@SEND_TYPE varchar(20)
	,@MSG_TO_SEND varchar(8000)
	,@FRSQLServer varchar(100)
	,@infile varchar(1000)
	,@headerinfile varchar(1000)
	,@dos_cmd varchar(8000)
	,@ADDComma int
	,@EIDVAL int
	,@FILESQLSERVER varchar(30)
	,@CONTENTYPEID varchar(2)
	,@REMOTESQLSVR varchar(50)
	,@CRITICALITY_LEVEL int = 4
	,@skipemails varchar(2000) = ''
	,@RECIPIENTCNT int

--V20170718ATD	
if (@@servername like 'DEV%' or @@servername like 'STA%')
begin
	select @REPLYTO = 'SQLTestServer@eqrworld.com'
end

select @FILESQLSERVER = case when patindex('%\%', SERVERNAME) > 0 
	then substring(SERVERNAME, 1, patindex('%\%', SERVERNAME)-1) else SERVERNAME end 
	from SQLALERT..ALERT_SERVER_TBL 
select @REMOTESQLSVR = SERVERNAME from SQLALERT..ALERT_REMOTE_SERVER where PRIORITY =1 and ACTIVE =1 
	
if  @SUBJECT = '' and @MESSAGE = '' and @GROUPNAME = '' 
begin
	select @DISPLAYUSAGE = 1
end


if @DISPLAYUSAGE = 1
begin 
	set nocount on
	select @SQL_CMD = "exec SQLALERT..SP_SQLALERT " + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " @SQLMAILSERVER = '' -- Specifies SQLServer to send mail from, only specify preconfigured servers. By default it will use the local SQLServer"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ ",@GROUPNAME = 'ALAN_TEST' --  can only use @GROUPNAME or @EMAIL_ADDRESS not both"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ ",@SUBJECT= 'TEST SUBJECT' "+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ ",@MESSAGE= 'TEST MESSAGE' "+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@ATTACH_FILEPATH = '\\mrisql01\c$\scripts\CheckFreeSpace.log;\\mrisql01\c$\scripts\DriveInfo.log' -- not available on jsSMTP Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@PRIORITY = 'NORMAL'  -- 'HIGH' / same as @importance however Low, Normal, High"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@ALERT_METHOD  = 0	-- 0 server preconfigured default, 1 xp_sendmail, 2 smtp mail, 3 DatabaseMail, 4 xpSMTPMAIL, 5 Javamail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@NORESENDDURATION  = 0 -- seconds "+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@NORESEND  = 0"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@DISPLAYUSAGE = 0"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@QUERY = 'select * from master..syslogins (nolock)' -- only available for SQLMail & DB Mail. Note: Limitation on rows."+ char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@ALIASFROMNAME = 'ALIASNAME@eqrworld.com' 	-- only available for xpSMTP Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@DISPLAYFROMNAME = 'DISPLAY NAME'		-- only available for xpSMTP Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@REPLYTO = 'adanque@eqrworld.com'		-- only available for xpSMTP Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@HTMLMESSAGEFILE = 'file.html'  		-- only available for xpSMTP Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@MAILTYPE = 'text/plain' -- 'text/html' -- , @body_format = 'TEXT' -- 'HTML' -- only available for xpSMTP Mail & DB Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@ATTACH_QUERY_RESULT_AS_FILE = 1		-- only available for DB Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@QUERY_ATTACHMENT_FILENAME = 'QueryResults.txt'-- only available for DB Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "-- ,@APPEND_QUERY_ERROR = 1			-- only available for DB Mail"+ char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " Use the below query to list all SP_SQLALERT groups and members" +char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " --------------------------------------------------------------" +char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "select a.PERSON, a.EMAILADDR, c.groupname, b.* from SQLALERT..ALERT_NOTIF_PERSONS a "+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid "+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "join SQLALERT..ALERT_NOTIF_GROUPS c on c.id = b.GID "+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ "order by c.groupname desc"+ char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " --------------------------------------------------------------" +char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " -- 	To add PERSONs to alert" +char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='Alan Danque', @EMAILADDR ='adanque@eqrworld.com'" +char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " -- 	To add group to alert " +char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='DBA'" +char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " -- 	To add group member" +char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqrworld.com', @GROUPNAME ='DBA', @TYPEID 1 --Types are 1 = to, 2 = cc, 3 = bcc" +char(13)
	select @SQL_CMD = @SQL_CMD + char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " -- 	Notes: 	To disable PERSONs to alert" +char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " -- update ALERT_NOTIF_PERSONS set ACTIVE = 0 where id = 3 --  where id is the users id from ALERT_NOTIF_PERSONS" +char(13)
	select @SQL_CMD = @SQL_CMD +char(9)+ " -- update ALERT_NOTIF_PERSONS set ACTIVE = 1 where id = 3" +char(13)
	select @SQL_CMD as 'Usage'
	set nocount off
end
else
begin
-- Start SQL Alert SPROC
	declare @DELETEMAIL table ( ROWID int identity(1, 1), EID int)
	if len(@MESSAGE) > 7000
	begin
		select @MESSAGE = left(@MESSAGE, 7000)
		select @MESSAGE = '*****Current Alert Message Truncated. Email alert contained more data than SQLMail can handle.****' +char(13)+char(13) + @MESSAGE + char(13) +char(13)+ '*****Current Alert Message Truncated. Email alert contained more data than SP_SQLALERT can handle.****'
	end
	
	select @ADDComma = 0
	if @NORESEND <> 0
	begin
		if exists(select * from SQLALERT.dbo.ALERT_MESSAGES where SUBJ = @SUBJECT)
		begin
			if(select count(*) from SQLALERT.dbo.ALERT_MESSAGES where SUBJ = @SUBJECT) >= 1
				begin
					goto ENDPROCESSING
				end
			else
				begin
					goto STARTEMAIL
				end
		end
	end
	
	if @NORESENDDURATION <> 0 
	begin
		if exists(select * from SQLALERT.dbo.ALERT_MESSAGES where SUBJ = @SUBJECT)
		begin
			if( select datediff(s, max(MSG_DATE), getdate()) from SQLALERT.dbo.ALERT_MESSAGES where SUBJ = @SUBJECT) > @NORESENDDURATION
				begin
					goto STARTEMAIL
				end
			else
				begin
					goto ENDPROCESSING
				end
		end
	end
	
	STARTEMAIL:	
	
	select @STARTEMAIL = 0
	select @ERROR_MSG = ''
	select @NOTIFIED = ''
	select @TO_FIELD = ''
	select @CC_FIELD = ''
	select @BCC_FIELD = ''
	
	if @QUERY = ''
		begin
			select @MSG_TO_SEND = @MESSAGE
		end
	else
		begin
			select @MSG_TO_SEND = 'Query Ran: ' + @QUERY + ' Message: ' + @MESSAGE + ' Results: '
		end
	select @SQLSERVER = @SQLMAILSERVER
	
	if @SQLSERVER=''
	begin
		select @SQLSERVER = SERVERNAME from SQLALERT..ALERT_SERVER_TBL where PRIORITY=1
	end
	
	--V20170718ATD
	if @ALIASFROMNAME = ''
		begin
			if (@@servername like 'DEV%' or @@servername like 'STA%')
			begin
				select @ALIASFROMNAME  = 'SQLTestServer@eqrworld.com'
			end
			else 
				begin
					select @ALIASFROMNAME = 'SQLServer@eqrworld.com'
				end
		end
		
	if @DISPLAYFROMNAME = ''
		begin
			select @DISPLAYFROMNAME = rtrim(@SQLSERVER) + '_SQLServer'
		end
	
	if @ALERT_METHOD = 0
	begin
		-- Check which default email is set. This will determine which email sys is currently available.
			print 'ALERT_METHOD'
			select @SQLSERVER_T= rtrim(replace(replace(@SQLSERVER,'[',''),']',''))	
			exec SQLALERT..SP_GETCURRENTDEFAULTEMAIL @SQLSERVER=@SQLSERVER_T, @ALERT_ID = @ALERT_METHOD OUTPUT
			select @ALERT_METHOD
	end
	select @FRSQLServer = 'SQLServer@eqrworld.com'
	
	-- Check @CRITICALITY_LEVEL
	select top 1 @CRITICALITY_LEVEL = a.txtid
		from ALERT_EMAIL_TEXTEVALS a
			cross apply SQLALERT.dbo.fn_RetDelimValTbl('~', a.txteval) c
		where charindex(c.retVals, @SUBJECT) > 0
			or charindex(c.retVals, @MESSAGE) > 0
		order by a.txtid asc

	select @CRITICALITY_LEVEL '@CRITICALITY_LEVEL'

	-- Check if Group Name or PERSON not passed
	if @GROUPNAME ='' and @EMAIL_ADDRESS =''
	begin 
		SELECT 'YOU MUST PASS @GROUPNAME or @EMAILADDRESS A VALUE!'
	end
	else
	begin
		-- Check if Group Name and PERSON is being passed
		if @GROUPNAME <>'' and @EMAIL_ADDRESS <>''
		begin 
			SELECT 'YOU MUST PASS @GROUPNAME or @EMAILADDRESS A VALUE, YOU CAN NOT USE BOTH!'
		end
		else
		begin
			-- Verify GroupName passed
			if @GROUPNAME <> ''
			begin
			if (SELECT count(*) from ALERT_NOTIF_GROUPS where GROUPNAME = @GROUPNAME and ACTIVE=1)=0	
				begin
					SELECT 'INVALID OR DISABLED GROUP: '+ @GROUPNAME 
				end
				else
				begin
					select @STARTEMAIL =1
				end
			end	
			-- Verify PERSON passed
			if @EMAIL_ADDRESS <> ''
			begin
			if (SELECT count(*) from ALERT_NOTIF_PERSONS where EMAILADDR = @EMAIL_ADDRESS and ACTIVE=1)=0
				begin
					SELECT 'INVALID OR DISABLED EMAIL ADDRESS: '+ @EMAIL_ADDRESS 
				end
				else
				begin
					select @STARTEMAIL =1
				end
			end
			-- If all is ok start email build
			if @STARTEMAIL = 1
			begin
				if object_id('tempdb..#ALERT_PERSONS_PREP') is not null drop table #ALERT_PERSONS_PREP
				select 1 as ID, res.PERSON, res.EMAILADDR, res.TYPEID into #ALERT_PERSONS_PREP 
				from 
				(
				select
					a.PERSON, a.EMAILADDR, b.TYPEID 
					from ALERT_NOTIF_PERSONS a 
						join ALERT_NOTIF_GROUP_MEMBERS b on a.ID = b.PID and a.ACTIVE = 1 
						join ALERT_NOTIF_GROUPS c on c.ID = b.GID and c.ACTIVE = 1 and c.GROUPNAME = @GROUPNAME 
				union
				select
					a.PERSON, a.EMAILADDR, '1' as TYPEID
					from ALERT_NOTIF_PERSONS a where a.ACTIVE = 1 and a.EMAILADDR = @EMAIL_ADDRESS
						 and a.ACTIVE = 1 
				)res 		
				group by res.PERSON, res.EMAILADDR, res.TYPEID
	
				update a set a.ID = b.ID
					from #ALERT_PERSONS_PREP a join SQLALERT..ALERT_NOTIF_PERSONS b on 
						a.PERSON = b.PERSON and a.EMAILADDR = b.EMAILADDR where b.ACTIVE=1

				select @skipemails = 'SkippedPerCriticalityRules:'+
					stuff((
					select ','+a.EMAILADDR from #ALERT_PERSONS_PREP a
						left join dbo.[fn_RetEmailNHow](@GROUPNAME , @CRITICALITY_LEVEL) b 
							on a.EMAILADDR = b.retVals
						where b.retVals is null
					FOR XML PATH('')
					), 1, 1, '')-- 

				-- Reduce emails per criticality rules
				delete a from #ALERT_PERSONS_PREP a
					left join dbo.[fn_RetEmailNHow](@GROUPNAME , @CRITICALITY_LEVEL) b 
						on a.EMAILADDR = b.retVals
					where b.retVals is null


			select * from #ALERT_PERSONS_PREP

			if object_id('tempdb..#ALERT_PERSONS') is not null drop table #ALERT_PERSONS
			select IDENTITY(int, 1, 1) AS rowid, ID, PERSON, EMAILADDR, TYPEID
				into #ALERT_PERSONS
				from #ALERT_PERSONS_PREP

			select @RECIPIENTCNT = count(*) from #ALERT_PERSONS
	
			CREATE_EMAIL_RECIPIENTLIST:
				select @currow = 1
				select @rowcnt=count(*) from #ALERT_PERSONS 
				while @currow <= @rowcnt
				begin
					select 	@NOTIFIER=ID
						,@EMAILADDRESS=EMAILADDR
						,@TO_FIELD = @TO_FIELD + case TYPEID when '1' then EMAILADDR + ';' else '' end
						,@CC_FIELD = @CC_FIELD + case TYPEID when '2' then EMAILADDR + ';' else '' end
						,@BCC_FIELD = @BCC_FIELD + case TYPEID when '3' then EMAILADDR + ';' else '' end
						,@SEND_TYPE = case TYPEID when '1' then 'to: ' when '2' then 'cc: ' when '3' then 'bcc: ' end
						from #ALERT_PERSONS where rowid=@currow
					select @NOTIFIED = @NOTIFIED +  @SEND_TYPE + @EMAILADDRESS + '; ' --"~" +rtrim(cast(@NOTIFIER as varchar(10)))
					select @currow = @currow + 1
				end
				select @NOTIFIED 'BEFORE @NOTIFIED'
				select @NOTIFIED = @NOTIFIED +' '+ isnull(@skipemails, '')
				select @NOTIFIED 'AFTER @NOTIFIED'

				print 'out'
				select @ALERT_METHOD 

				if @ALERT_METHOD = 2
				begin
	
					exec SQLALERT..SP_ALERT_GETNEXTID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
					insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @MESSAGE)
					insert into @DELETEMAIL (EID) values (@EIDVAL)
	
					select @headerinfile = '\\' +rtrim(@SQLSERVER)+ '\c$\scripts\email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_HEADER_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @headerinfile 
					select @infile = '\\' +rtrim(@SQLSERVER)+ '\c$\scripts\email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @infile 
			
					select  @SQL_CMD ="master..xp_cmdshell " + "'bcp " + '"' + "select * from SQLALERT.dbo.fn_VariableValueToTableSession(" + rtrim(cast( @EIDVAL as varchar(100)))  + ")" + '"' + " queryout " +  rtrim(@infile) + " -c -T ' "
					select  @SQL_CMD 
					exec(@SQL_CMD)
	
					select @SQL_CMD = " exec SQLALERT.dbo.sp_SQLSmtpMail @To='" +rtrim(@EMAILADDRESS)+ "',@Fr = '" +rtrim(@FRSQLServer)+ "',@SUBJECT = '" +rtrim(@SUBJECT)+ "',@MESSAGE = '"
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' > ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @dos_cmd = 'type ' + rtrim(@infile) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = " exec SQLALERT.dbo.sp_SQLSmtpMail @To='" +rtrim(@EMAILADDRESS)+ "',@Fr = '" +rtrim(@FRSQLServer)+ "',@SUBJECT = '" +rtrim(@SUBJECT)+ "',@MESSAGE = '"
					select @dos_cmd = 'ECHO ' + "', @EmailAlertType = 'SMTP_ALERT'"  + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
					select @SQL_CMD 
	
					select @headerinfile
	
					select @SQL_CMD = 'osql -S '+ rtrim(@SQLSERVER)+ ' -E -i '+@headerinfile
					select @SQL_CMD
					exec master..xp_cmdshell @SQL_CMD
					if @@ERROR <> 0
						begin
							select @ERROR_MSG = 'Could not send email alert using smtp mail to '+@NOTIFIED+ ' SUBJ:' + rtrim(@SUBJECT)
							select @ERROR_MSG 
							raiserror (@ERROR_MSG, 17, 1)
						end
					else 
						begin
							insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
						end
				end	
				
				if @ALERT_METHOD = 1
				begin
					print 'in'
					select @SQL_CMD = rtrim(@SQLSERVER)+ ".master.dbo.xp_sendmail @recipients ='" + @TO_FIELD +"'"
					select @SQL_CMD 
					if @CC_FIELD <> ''
					begin
						 select @SQL_CMD = @SQL_CMD+" , @copy_recipients ='" +@CC_FIELD+ "'"
					end
					if @BCC_FIELD <> ''
					begin
						 select @SQL_CMD = @SQL_CMD+" , @blind_copy_recipients ='" +@BCC_FIELD+ "'"
					end
					if @SUBJECT <> ''
					begin
						 select @SQL_CMD = @SQL_CMD+" , @SUBJECT='" +rtrim(@SUBJECT)+ "'"
					end
					if @MSG_TO_SEND <> ''
					begin
						 select @SQL_CMD = @SQL_CMD+" , @MESSAGE='" + rtrim(@MSG_TO_SEND) + "'"
					end
					if @ATTACH_FILEPATH <> ''
					begin
						 select @SQL_CMD = @SQL_CMD+ " , @attachments='" +rtrim(@ATTACH_FILEPATH) +  "'"
					end
					if @QUERY <> ''
					begin
						 select @SQL_CMD = @SQL_CMD+ " , @query='" +rtrim(@QUERY) +  "'"
					end
					print 'test'
					select @SQL_CMD
					exec(@SQL_CMD)
						if @@ERROR <> 0
							begin
								select @ERROR_MSG = 'Could not send email alert using xp_sendmail to '+@NOTIFIED+ ' SUBJ:' + rtrim(@SUBJECT)
								select @ERROR_MSG 
								select @ALERT_METHOD = 2
								raiserror (@ERROR_MSG, 17, 1)
								GOTO CREATE_EMAIL_RECIPIENTLIST
							end
						else 
							begin
								insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), rtrim(@NOTIFIED) )
							end
				end			

				if @ALERT_METHOD = 6 -- CS MAIL
				begin
					--insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
					--select @MSGID = SCOPE_IDENTITY()

-- NEED ERROR HANDLING FOR text/plain ~ text/html

					exec SQLALERT..SP_ALERT_GETNEXTID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
					begin tran
						insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @MESSAGE)
					commit tran
					insert into @DELETEMAIL (EID) values (@EIDVAL)
					
					select @headerinfile = '\\' +rtrim(@FILESQLSERVER)+ '\c$\scripts\Email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_HEADER_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @headerinfile 
					
					select @SQL_CMD = "declare @EMAIL_STATUS int, @doscmd varchar(8000) "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' > ' + rtrim(@headerinfile) 
					select @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
	
					select @CONTENTYPEID = rtrim(cast(TID as varchar)) from SQLALERT..EMAIL_REQ_TYPE where TYPENAME =@MAILTYPE
									
					select @headerinfile 'ATDFILE'
					--select @SQL_CMD = "select @doscmd = " + '"'+ "c:\scripts\csmail\sqlalert.exe "+'"+'+"'"+'"'+"'+"+' "'+rtrim(@TO_FIELD)+'"'+"+'"+'" "'+"'+"+'"'+rtrim(@CC_FIELD)+'"+'+"'"+'" "'+"'"+'+ "'+rtrim(@BCC_FIELD)+'"+'+"'"+'" "'+"'+ "+'"'+rtrim(@REPLYTO)+'"+'+ "'"+'" "'+"'+ "+'"'+rtrim(@SUBJECT)+'"'+"+'"+'" "'+"'+"+' "'+ rtrim(cast(@EIDVAL as varchar))+'"+'+"'"+ '" "'+"'"+'+ "'+ rtrim(@ATTACH_FILEPATH)+'"'+"+'"+'" "'+"'+"+' "'+ rtrim(@CONTENTYPEID)+'"+'+"'"+'" "'+"'+ '"+ rtrim(@ALIASFROMNAME)+'" '+"'"+'+"'+RTRIM(@@SERVERNAME)+'"' 
					select @SQL_CMD = "select @doscmd = " + '"'+ "c:\scripts\csmail\sqlalert.exe "+'"+'+"'"+'"'+"'+"+' "'+rtrim(@TO_FIELD)+'"'+"+'"+'" "'+"'+"+'"'+rtrim(@CC_FIELD)+'"+'+"'"+'" "'+"'"+'+ "'+rtrim(@BCC_FIELD)+'"+'+"'"+'" "'+"'+ "+'"'+rtrim(@REPLYTO)+'"+'+ "'"+'" "'+"'+ "+'"'+rtrim(@SUBJECT)+'"'+"+'"+'" "'+"'+"+' "'+ rtrim(cast(@EIDVAL as varchar))+'"+'+"'"+ '" "'+"'"+'+ "'+ rtrim(@ATTACH_FILEPATH)+'"'+"+'"+'" "'+"'+"+' "'+ rtrim(@CONTENTYPEID)+'"+'+"'"+'" "'+"'+ '"+ rtrim(@ALIASFROMNAME)+'" "'+"'"+'+"'+RTRIM(@@SERVERNAME)+'"+'+"'"+'" "'+ +"'+ "+'"SQLAlert"'+"+'"+'"'+"'"
				

					select @SQL_CMD 'THIS COMMAND'
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "exec @EMAIL_STATUS = master.dbo.xp_cmdshell @doscmd "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
		
					--select @REMOTESQLSVR = "DEVSQL06"
					select @SQL_CMD = 'sqlcmd -S '+ rtrim(@REMOTESQLSVR)+ ' -E -i '+@headerinfile
					select @SQL_CMD
					--BYPASS SEND ATTEMPT if all recipients have been bypassed due to criticality framework.
					if @RECIPIENTCNT > 0
					begin
						exec master..xp_cmdshell @SQL_CMD
						if @@ERROR <> 0
							begin
								select @ERROR_MSG = 'Could not send email alert using CS mail to '+@NOTIFIED+ ' subj:' + rtrim(@SUBJECT)
								select @ERROR_MSG 
								raiserror (@ERROR_MSG, 17, 1)
							end
						else 
							begin
								insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
							end
					end
					else
						begin
							insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
						end

				end

				if @ALERT_METHOD = 5 -- JAVA MAIL
				begin
					--insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
					--select @MSGID = SCOPE_IDENTITY()

-- NEED ERROR HANDLING FOR text/plain ~ text/html

					exec SQLALERT..SP_ALERT_GETNEXTID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
					begin tran
						insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @MESSAGE)
					commit tran
					insert into @DELETEMAIL (EID) values (@EIDVAL)
					
					select @headerinfile = '\\' +rtrim(@FILESQLSERVER)+ '\c$\scripts\Email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_HEADER_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @headerinfile 
					
					select @SQL_CMD = "declare @EMAIL_STATUS int, @doscmd varchar(8000) "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' > ' + rtrim(@headerinfile) 
					select @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
	
					select @CONTENTYPEID = rtrim(cast(TID as varchar)) from SQLALERT..EMAIL_REQ_TYPE where TYPENAME =@MAILTYPE
									
					select @headerinfile 'ATDFILE'
					select @SQL_CMD = "select @doscmd = " + '"'+ "java SendFileEmailArg3 "+'"+'+"'"+'"'+"'+"+' "'+rtrim(@TO_FIELD)+'"'+"+'"+'" "'+"'+"+'"'+rtrim(@CC_FIELD)+'"+'+"'"+'" "'+"'"+'+ "'+rtrim(@BCC_FIELD)+'"+'+"'"+'" "'+"'+ "+'"'+rtrim(@REPLYTO)+'"+'+ "'"+'" "'+"'+ "+'"'+rtrim(@SUBJECT)+'"'+"+'"+'" "'+"'+"+' "'+ rtrim(cast(@EIDVAL as varchar))+'"+'+"'"+ '" "'+"'"+'+ "'+ rtrim(@ATTACH_FILEPATH)+'"'+"+'"+'" "'+"'+"+' "'+ rtrim(@CONTENTYPEID)+'"+'+"'"+'" "'+"'+ '"+ rtrim(@ALIASFROMNAME)+'" '+"'"+'+"'+RTRIM(@@SERVERNAME)+'"'

					select @SQL_CMD 'THIS COMMAND'
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "exec @EMAIL_STATUS = master.dbo.xp_cmdshell @doscmd "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
		
					--select @REMOTESQLSVR = "DEVSQL06"
					select @SQL_CMD = 'sqlcmd -S '+ rtrim(@REMOTESQLSVR)+ ' -E -i '+@headerinfile
					select @SQL_CMD
					exec master..xp_cmdshell @SQL_CMD
					if @@ERROR <> 0
						begin
							select @ERROR_MSG = 'Could not send email alert using JAVA mail to '+@NOTIFIED+ ' subj:' + rtrim(@SUBJECT)
							select @ERROR_MSG 
							raiserror (@ERROR_MSG, 17, 1)
						end
					else 
						begin
							insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
						end
				
				end
				
				if @ALERT_METHOD = 4	-- xpSMTP Mail
				begin
					-- NEW SMTP EMAIL.
					exec SQLALERT..SP_ALERT_GETNEXTID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
					insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @MESSAGE)
					insert into @DELETEMAIL (EID) values (@EIDVAL)

					select @headerinfile = '\\' +rtrim(@SQLSERVER)+ '\c$\scripts\email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_HEADER_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @headerinfile 
					select @infile = '\\' +rtrim(@SQLSERVER)+ '\c$\scripts\email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @infile 
					select  @SQL_CMD ="master..xp_cmdshell " + "'bcp " + '"' + "select * from SQLALERT.dbo.fn_VariableValueToTableSession(" + rtrim(cast( @EIDVAL as varchar(100)))  + ")" + '"' + " queryout " +  rtrim(@infile) + " -c -T ' "
					select  @SQL_CMD 
					exec(@SQL_CMD)
	
					select @SQL_CMD = "declare @EMAIL_STATUS int "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' > ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "exec @EMAIL_STATUS = master.dbo.xp_smtp_sendmail "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
		
					select @SQL_CMD = "@FROM = '" +rtrim(@ALIASFROMNAME)+ "', @FROM_NAME = '" +rtrim(@DISPLAYFROMNAME)+ "', @replyto = '" +rtrim(@REPLYTO)+ "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd
					exec master..xp_cmdshell @dos_cmd
	
					select @SQL_CMD = "@TO = '" + rtrim(@TO_FIELD) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
			
					select @SQL_CMD = "@CC = '" + rtrim(@CC_FIELD) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@BCC = '" + rtrim(@BCC_FIELD) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 				
					
					select @SQL_CMD = "@priority = '" + rtrim(@PRIORITY) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
					
					select @SQL_CMD = "@SUBJECT = '" + rtrim(@SUBJECT) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@TYPE = '" + rtrim(@MAILTYPE) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@MESSAGE = '"
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
				
					select @dos_cmd = 'type ' + rtrim(@infile) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
		
					select @SQL_CMD = "@MESSAGEfile= '" +rtrim(@HTMLMESSAGEFILE)+ "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@attachments= '" +rtrim(@ATTACH_FILEPATH)+ "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
				
					select @SQL_CMD = "@codepage = 0, @timeout = "+ rtrim(cast(@TIMEOUT as varchar(20))) +", @server= '"+ rtrim(@SMTPServer) + "' "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "select EMAIL_STATUS = @EMAIL_STATUS "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
					select @SQL_CMD 
	
					select @headerinfile
	
					select @SQL_CMD = 'osql -S '+ rtrim(@SQLSERVER)+ ' -E -i '+@headerinfile
					select @SQL_CMD
					exec master..xp_cmdshell @SQL_CMD
					if @@ERROR <> 0
						begin
							select @ERROR_MSG = 'Could not send email alert using xpSMTP mail to '+@NOTIFIED+ ' SUBJ:' + rtrim(@SUBJECT)
							select @ERROR_MSG 
							raiserror (@ERROR_MSG, 17, 1)
						end
					else 
						begin
							insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
						end
				end
	
				if @ALERT_METHOD = 3 -- Database Mail
				begin
					-- NEW SMTP EMAIL.
					exec SQLALERT..SP_ALERT_GETNEXTID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
					insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @MESSAGE)
					insert into @DELETEMAIL (EID) values (@EIDVAL)

					select @headerinfile = '\\' +rtrim(@SQLSERVER)+ '\c$\scripts\email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_HEADER_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @headerinfile 
					select @infile = '\\' +rtrim(@SQLSERVER)+ '\c$\scripts\email\Email_'+ rtrim(cast(@EIDVAL as varchar(20))) + '_' + rtrim(@GROUPNAME) +'_'+ replace(replace(convert(varchar(19),getdate(),121), ' ', '_'),':','-')+ '.sql'
					select @infile 
					select  @SQL_CMD ="master..xp_cmdshell " + "'bcp " + '"' + "select * from SQLALERT.dbo.fn_VariableValueToTableSession(" + rtrim(cast( @EIDVAL as varchar(100)))  + ")" + '"' + " queryout " +  rtrim(@infile) + " -c -T ' "
					select  @SQL_CMD 
					exec(@SQL_CMD)
	
					select @SQL_CMD = "exec msdb..sp_send_dbmail "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@profile_name = 'DatabaseMail', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
				
					select @SQL_CMD = "@recipients = '" + rtrim(@TO_FIELD) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
			
					select @SQL_CMD = "@copy_recipients = '" + rtrim(@CC_FIELD) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@blind_copy_recipients = '" + rtrim(@BCC_FIELD) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 				
					
					select @SQL_CMD = "@importance = '" + rtrim(@PRIORITY) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
					
					select @SQL_CMD = "@SUBJECT = '" + rtrim(@SUBJECT) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@body_format = '" + rtrim(case when @MAILTYPE= 'text/plain' then 'TEXT' else 'HTML' end ) + "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@body = '"
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
				
					select @dos_cmd = 'type ' + rtrim(@infile) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					if @QUERY <> ''
					begin
						select @SQL_CMD = "@query='"
						select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
						select  @dos_cmd 
						exec master..xp_cmdshell @dos_cmd 
			
						exec SQLALERT..SP_ALERT_GETNEXTID @SEQNAME = 'SMTPEMAIL', @OUTVAL=@EIDVAL output
						insert into SQLALERT..ALERT_SESSION (EID, MESSAGE) values (@EIDVAL, @QUERY)
						insert into @DELETEMAIL (EID) values (@EIDVAL)

						select  @SQL_CMD ="master..xp_cmdshell " + "'bcp " + '"' + "select * from SQLALERT.dbo.fn_VariableValueToTableSession(" + rtrim(cast( @EIDVAL as varchar(100)))  + ")" + '"' + " queryout " +  rtrim(@infile) + " -c -T ' "
						select  @SQL_CMD 
						exec(@SQL_CMD)
	
						select @dos_cmd = 'type ' + rtrim(@infile) + ' >> ' + rtrim(@headerinfile) 
						select  @dos_cmd 
						exec master..xp_cmdshell @dos_cmd 
						
						select @SQL_CMD = "', "
						select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
						select  @dos_cmd 
						exec master..xp_cmdshell @dos_cmd 
					end
			
					select @SQL_CMD = "@file_attachments = '" +rtrim(@ATTACH_FILEPATH)+ "', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
				
					select @SQL_CMD = "@SENSITIVITY = '"+ rtrim(@SENSITIVITY) +"', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
	
					select @SQL_CMD = "@ATTACH_QUERY_RESULT_AS_FILE = '"+ rtrim(@ATTACH_QUERY_RESULT_AS_FILE) +"', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
					
					select @SQL_CMD = "@QUERY_ATTACHMENT_FILENAME = '"+ rtrim(@QUERY_ATTACHMENT_FILENAME) +"', "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
					
					select @SQL_CMD = "@APPEND_QUERY_ERROR = '"+ rtrim(@APPEND_QUERY_ERROR) +"' "
					select @dos_cmd = 'ECHO ' + rtrim(@SQL_CMD) + ' >> ' + rtrim(@headerinfile) 
					select  @dos_cmd 
					exec master..xp_cmdshell @dos_cmd 
					
					select @headerinfile
	
					select @SQL_CMD = 'osql -S '+ rtrim(@SQLSERVER)+ ' -E -i '+@headerinfile
					select @SQL_CMD
					exec master..xp_cmdshell @SQL_CMD
					if @@ERROR <> 0
						begin
							select @ERROR_MSG = 'Could not send email alert using xpSMTP mail to '+@NOTIFIED+ ' SUBJ:' + rtrim(@SUBJECT)
							select @ERROR_MSG 
							raiserror (@ERROR_MSG, 17, 1)
						end
					else 
						begin
							insert into SQLALERT..ALERT_MESSAGES (MSG_DATE, SUBJ, MSG, NOTIFIED) values (getdate(), rtrim(@SUBJECT), rtrim(@MESSAGE), @NOTIFIED )
						end
				end
	
				
				if object_id('tempdb..#ALERT_PERSONS') is not null
				begin
					drop table #ALERT_PERSONS
				end
				
			end
		end
	end
	ENDPROCESSING:
-- END SQL Alert SPROC
	-- REMOVE TEMP SQLALERT..ALERT_SESSION records and temp file
	select @currow = 1, @rowcnt = count(*) from @DELETEMAIL
	select * from @DELETEMAIL
	select @rowcnt 
	if @rowcnt > 0
	begin
		while @currow <= @rowcnt
		begin
			select @EIDVAL = EID from @DELETEMAIL where ROWID = @currow
			waitfor delay '00:00:01'
			select @dos_cmd = 'del /Q \\' +rtrim(replace(replace(substring(@SQLSERVER, 1, case when charindex('\', @SQLSERVER, 1) = 0 then len(@SQLSERVER) else charindex('\', @SQLSERVER, 1) -1  end),'[',''),']',''))+ '\c$\scripts\Email\Email_'+rtrim(cast(@EIDVAL as varchar(255)))+'_*.sql'
			select @dos_cmd 
			-- ATD TEMPORARY
			--exec master..xp_cmdshell @dos_cmd
			select @currow = @currow + 1
		end
		-- ATD TEMPORARY
		-- delete a from SQLALERT..ALERT_SESSION a join @DELETEMAIL b on a.EID = b.EID
	end
END

GO





if object_id('sp_AddAlertPerson') is not null drop proc sp_AddAlertPerson
go


create proc [dbo].[sp_AddAlertPerson] @FULLNAME varchar(100), @EMAILADDR varchar(1000)
as
-- Author: 	Alan Danque	
-- Date:	May 12, 2006
-- Purpose:	Used to add group
if (select count(*) from SQLALERT..ALERT_NOTIF_PERSONS where Person = @FULLNAME and EmailAddr = @EMAILADDR)=0
	begin
		insert into SQLALERT..ALERT_NOTIF_PERSONS (Person, EmailAddr, Active) values (@FULLNAME ,@EMAILADDR, 1)
	end
else
	begin
		print 'ERROR PERSON ALREADY EXISTS'
	end
GO


if object_id('sp_AddAlertGroup') is not null drop proc sp_AddAlertGroup
go

create proc [dbo].[sp_AddAlertGroup] @GROUPNAME varchar(100)
as
-- Author: 	Alan Danque	
-- Date:	May 12, 2006
-- Purpose:	Used to add group
if (select count(*) from SQLALERT..ALERT_NOTIF_GROUPS where groupname = @GROUPNAME)=0
	begin
		insert into SQLALERT..ALERT_NOTIF_GROUPS (groupname, active) values (@GROUPNAME, 1)
	end
else
	begin
		print 'ERROR GROUP ALREADY EXISTS'
	end
GO


if object_id('sp_AddAlertGroupMember') is not null drop proc sp_AddAlertGroupMember
go

CREATE proc [dbo].[sp_AddAlertGroupMember] @EmailAddress varchar(100), @GROUPNAME varchar(100), @TYPEID int=1, @CRITICALITY_LEVEL int = 4 -- 4 all, 2 warn, 1 fail/error
as
-- Author: 	Alan Danque	
-- Date:	May 12, 2006
-- Purpose:	Used to add group members
-- Notes:	Types are 1 = to, 2 = cc, 3 = bcc
declare  @GROUPID int
	,@PERSONID int
if exists(select * from SQLALERT..ALERT_NOTIF_PERSONS where emailaddr = @EmailAddress) and exists(select * from SQLALERT..ALERT_NOTIF_GROUPS where groupname = @GROUPNAME)
begin
	if (select count(*) from SQLALERT..ALERT_NOTIF_GROUP_MEMBERS a join SQLALERT..ALERT_NOTIF_GROUPS b on a.gid = b.id join SQLALERT..ALERT_NOTIF_PERSONS c on a.pid = c.id where c.emailaddr = @EmailAddress and b.groupname = @GROUPNAME)=0
		begin
			select @GROUPID = id from SQLALERT..ALERT_NOTIF_GROUPS where groupname = @GROUPNAME
			select @PERSONID = id from SQLALERT..ALERT_NOTIF_PERSONS where emailaddr = @EmailAddress 
			insert into SQLALERT..ALERT_NOTIF_GROUP_MEMBERS (GID, PID, TYPEID, CID) values (@GROUPID, @PERSONID, @TYPEID, @CRITICALITY_LEVEL)
		end
	else
		begin
			print 'ERROR PERSON ALREADY MEMBER'	
		end
end
else
	begin
		print 'ERROR PERSON/GROUPNAME DOES NOT EXIST'	
	end
GO



if object_id('sp_CreateJobNotificationAlert') is not null drop proc sp_CreateJobNotificationAlert
go




create PROC [dbo].[sp_CreateJobNotificationAlert] 
	 @JOBNAME VARCHAR(255) 
	,@EMAILGROUP VARCHAR(100) = 'DBA'
	,@DBASUPPORT_EMAILGROUP VARCHAR(100) = ''	
	,@NON_IT_EMAILGROUP VARCHAR(100) = ''
	,@SUBJECTPREFIX VARCHAR(100) = ''
AS
--AUTHOR: ALAN DANQUE
--DATE:	  SEPT 18, 2006
--PURPOSE:CREATE ALERT ON JOB EXECUTION.
/* Modifications:
	ATD:08.25.2008:Added NON_IT_EMAILGROUP & SUBJECTPREFIX processing.
	ATD:12.16.2011:Modified the results display to display in desc order to show the latest exec first.
	ATD:06.04.2014:Added and defaulted SQLSupport Email Group notification
	ATD:02.13.2017:Corrected sort for the job history 
*/
SET QUOTED_IDENTIFIER OFF
DECLARE  @MAXDATE VARCHAR(8)
	,@MAXTIME VARCHAR(8)
	,@JOBID VARCHAR(100)
	,@RUNSTATS INT
	,@MESSAGE VARCHAR(700)
	,@MESSAGE_DATA VARCHAR(4000)
	,@SUBJECT_DATA VARCHAR(500)
	,@DURATION VARCHAR(20)
	,@ROWCNT INT
	,@CURROW INT
	,@JOBSTEPDETAIL VARCHAR(4000)
	,@COMPSTATUS INT
SELECT TOP 1 
	@MAXDATE = SJH.run_date, 
	@MAXTIME = SJH.run_time, 
	@JOBID = SJH.job_id, 
	@RUNSTATS = SJH.run_status, 
	@MESSAGE = SJH.message, 
	@DURATION = SJH.run_duration
	FROM msdb.dbo.sysjobhistory SJH 
		JOIN msdb.dbo.sysjobs_view SJ ON SJ.job_id = SJH.job_id 
			AND SJ.name = @JOBNAME 
			AND SJH.step_id = 0
	ORDER BY SJH.run_date DESC,
		 SJH.run_time DESC

	-- CREATE JOB STEP EXECUTION DETAILS.
	IF OBJECT_ID('tempdb..#EMAILDETAIL') IS NOT NULL
	BEGIN
		DROP TABLE #EMAILDETAIL
	END
	SELECT top 1 
		IDENTITY (int, 1, 1) ROWID,
		CONVERT(CHAR(32), replace(SJH.step_name,'(Job outcome)', 'Last Job Run') )+ ' | START:' +
		STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,SJH.run_time),6),5,0,':'),3,0,':') + '   | DUR:' +
		STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,SJH.run_duration),6),5,0,':'),3,0,':') + ' | ' +
		 CASE WHEN SJH.run_status = '1' THEN 'Succeeded' ELSE 'Failed' END + CHAR(13) AS MESSAGEDETAIL
	INTO #EMAILDETAIL
		FROM msdb.dbo.sysjobhistory SJH 
			JOIN msdb.dbo.sysjobs_view SJ ON SJ.job_id = SJH.job_id
				AND SJ.name = @JOBNAME
		WHERE SJH.step_name = '(Job outcome)'--SJH.run_date = REPLACE(CONVERT(CHAR(10),GETDATE(),111), '/', '')
	--ORDER BY STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,SJH.run_time),6),5,0,':'),3,0,':') DESC
	ORDER BY SJH.run_date desc, SJH.run_time desc 

	INSERT INTO #EMAILDETAIL
	SELECT 
		--IDENTITY (int, 1, 1) ROWID,
		CONVERT(CHAR(40), SJH.step_name )+ ' | ' +
		STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,SJH.run_time),6),5,0,':'),3,0,':') + '   | ' +
		STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,SJH.run_duration),6),5,0,':'),3,0,':') + ' | ' +
		 CASE WHEN SJH.run_status = '1' THEN 'Succeeded' ELSE 'Failed' END + CHAR(13) AS MESSAGEDETAIL
			FROM msdb.dbo.sysjobhistory SJH 
			JOIN msdb.dbo.sysjobs_view SJ ON SJ.job_id = SJH.job_id
				AND SJ.name = @JOBNAME
		WHERE SJH.run_date = REPLACE(CONVERT(CHAR(10),GETDATE(),111), '/', '')
	--ORDER BY STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,SJH.run_time),6),5,0,':'),3,0,':') DESC
	ORDER BY SJH.run_date desc, SJH.run_time desc 

			--, SJH.step_id ASC
		--ORDER BY STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,SJH.run_time),6),5,0,':'),3,0,':') ASC, SJH.step_id ASC

	select * from  #EMAILDETAIL order by ROWID asc

	SELECT @COMPSTATUS = COUNT(*) FROM #EMAILDETAIL WHERE UPPER(MESSAGEDETAIL) LIKE '%FAILED%'
	SELECT @ROWCNT = COUNT(*) FROM #EMAILDETAIL
	SELECT @CURROW = 1
	SELECT @JOBSTEPDETAIL = CHAR(13) + 'JOB STEP EXECUTION DETAIL: ....... . . '
	SELECT @JOBSTEPDETAIL = @JOBSTEPDETAIL + CHAR(13) + 'Step Name                                | Start Time | Duration | Status  ' + CHAR(13)
	WHILE @CURROW <= @ROWCNT 
	BEGIN
		SELECT @JOBSTEPDETAIL = @JOBSTEPDETAIL + MESSAGEDETAIL FROM #EMAILDETAIL WHERE ROWID = @CURROW
		SELECT @CURROW = @CURROW + 1
	END

	-- COMBINE MESSAGE FOR DELIVERY	
	SELECT @MESSAGE_DATA = "JOB RUN: " +RTRIM(@JOBNAME)+ " WAS RUN ON " + CAST(CONVERT(VARCHAR, @MAXDATE) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,@MAXTIME),6),5,0,':'),3,0,':') AS VARCHAR(255)) + CHAR(13) + 
			"DURATION: " +  STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR,@DURATION),6),5,0,':'),3,0,':') + CHAR(13) +
			"STATUS:  " + CASE WHEN @RUNSTATS = 1 THEN 'Completed' ELSE 'Failed' END +  CHAR(13) +
			"MESSAGES: " + @MESSAGE + CHAR(13) + @JOBSTEPDETAIL

	SELECT @MESSAGE_DATA = REPLACE(@MESSAGE_DATA, "'", "")
-- SEND NOTIFICATION
SELECT @SUBJECT_DATA = CASE WHEN @SUBJECTPREFIX <> '' THEN RTRIM(@SUBJECTPREFIX) ELSE '' END + "SQLSERVER JOB NOTIFICATION: " + RTRIM(@JOBNAME) + " " + CASE WHEN @COMPSTATUS = 0 THEN 'Succeeded' ELSE 'Completed W/Errors' END +" ON \\" + @@SERVERNAME
EXEC SQLAlert..SP_SQLALERT
	 @SUBJECT = @SUBJECT_DATA
	,@MESSAGE = @MESSAGE_DATA
	,@GROUPNAME = @EMAILGROUP
	,@MAILTYPE = 'text/plain'

IF @DBASUPPORT_EMAILGROUP <> ''
BEGIN
	EXEC SQLAlert..SP_SQLALERT
		 @SUBJECT = @SUBJECT_DATA
		,@MESSAGE = @MESSAGE_DATA
		,@GROUPNAME = @DBASUPPORT_EMAILGROUP
		,@MAILTYPE = 'text/plain'
END

IF @NON_IT_EMAILGROUP <> ''
BEGIN
	SELECT @SUBJECT_DATA = CASE WHEN @SUBJECTPREFIX <> '' THEN RTRIM(@SUBJECTPREFIX)  ELSE '' END + "SQLSERVER JOB NOTIFICATION: " + RTRIM(@JOBNAME) + " " + CASE WHEN @COMPSTATUS = 0 THEN 'Succeeded' ELSE 'Completed W/Errors' END +" ON \\" + @@SERVERNAME
	SELECT @MESSAGE_DATA = "This is an automated email notification, please do not reply." + char(13) + char(13) + "SQLSERVER JOB NOTIFICATION: " + RTRIM(@JOBNAME) + " " + CASE WHEN @COMPSTATUS = 0 THEN 'Succeeded' ELSE 'Completed W/Errors and will be verified by the IT Operations Group. More info to follow.' END 
	SELECT @SUBJECT_DATA ATD1
	SELECT @MESSAGE_DATA ATD2
	EXEC SQLAlert..SP_SQLALERT
		 @SUBJECT = @SUBJECT_DATA
		,@MESSAGE = @MESSAGE_DATA
		,@GROUPNAME = @NON_IT_EMAILGROUP
		,@MAILTYPE = 'text/plain'
		 
END
GO


