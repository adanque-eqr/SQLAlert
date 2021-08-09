
USE [SQLALERT]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


if object_id('fn_RetDelimValTbl') is not null drop function fn_RetDelimValTbl
go

create function [dbo].[fn_RetDelimValTbl]( @DELIMITERVAL char(1), @INPUTVALUE varchar(8000) ) 
returns @RETROWS TABLE 
	(
	 ROWID int identity(1, 1)
	,retVals VARCHAR(1000) 
	)
as
BEGIN
	--Author: Alan Danque
	--Date:   Sept 22, 2007
	--Purpose:Parse passed values using delimiter
	DECLARE  @ROWCNT INT
		,@CURROW INT
		,@LENINPUTVALUE INT		
		,@LASTVALPOSITION INT
		,@OPTIONVAL VARCHAR(100)
	SELECT @CURROW = 1
	SELECT @LENINPUTVALUE = LEN(@INPUTVALUE) 
	SELECT @LASTVALPOSITION = 0
	SELECT @CURROW = 1
	WHILE @CURROW <= @LENINPUTVALUE
	BEGIN
		IF (SELECT CHARINDEX(@DELIMITERVAL, @INPUTVALUE, @CURROW)) > 1
		BEGIN
			IF (SELECT SUBSTRING(@INPUTVALUE, @CURROW, 1) ) = @DELIMITERVAL
			BEGIN
				SELECT @OPTIONVAL = SUBSTRING(@INPUTVALUE, @LASTVALPOSITION+1, (@CURROW - @LASTVALPOSITION)-1 )
				INSERT @RETROWS (retVals) SELECT @OPTIONVAL
				SELECT @LASTVALPOSITION = @CURROW
			END
		END
		ELSE
			BEGIN
				SELECT @LASTVALPOSITION = @CURROW
			END
		SELECT @CURROW = @CURROW + 1
	END
	RETURN;
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if object_id('fn_VariableValueToTableSession') is not null drop function fn_VariableValueToTableSession
go

CREATE function [dbo].[fn_VariableValueToTableSession] (@EID int)
returns @MESSAGEVAL table (
	 MSG varchar(8000)
	)
AS
BEGIN
--Author:  Alan Danque
--Date:	   1/11/2008
	INSERT INTO @MESSAGEVAL select MESSAGE from SQLALERT..ALERT_SESSION where EID = @EID
return;
END

GO



if object_id('fn_RetEmailNHow') is not null drop function fn_RetEmailNHow
go


create function [dbo].[fn_RetEmailNHow]( @email_group varchar(255), @critical_type int ) 
returns  -- varchar(max)
	@RETROWS TABLE 
	(
	 ROWID int identity(1, 1)
	,retVals VARCHAR(1000) 
	)
as
BEGIN
	--Author: Alan Danque
	--Date:   20210520
	--Purpose:SQLAlert String Modularizer
	declare @emails varchar(max), @sendcriticality varchar(max), @return varchar(max), @gid int 
		select @gid = id from SQLALERT..ALERT_NOTIF_GROUPS where groupname = @email_group --'AL
		insert into @RETROWS (retVals) 
			select 
				d.emailaddr
			from SQLALERT..ALERT_NOTIF_GROUPS a 
				join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b 
					on a.id = b.gid
					join SQLALERT..ALERT_NOTIF_PERSONS d on d.id = b.pid 
					join SQLALERT..ALERT_EMAIL_CRITICALITY f on f.cid =  b.cid 
				where d.active = 1
					and a.groupname = @email_group 
					and f.cid >= @critical_type
	return; 
END
GO

