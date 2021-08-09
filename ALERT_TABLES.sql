USE [SQLALERT]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if object_id('ALERT_SEQUENCE') is not null drop table ALERT_SEQUENCE
go
CREATE TABLE [dbo].[ALERT_SEQUENCE](
	[SEQID] [int] NULL,
	[SEQNAME] [varchar](100) NULL
) ON [PRIMARY]
GO
insert into SQLALERT..ALERT_SEQUENCE (SEQID, SEQNAME) select 0, 'SMTPEMAIL'


if object_id('ALERT_SERVER_TBL') is not null drop table ALERT_SERVER_TBL
go
CREATE TABLE [dbo].[ALERT_SERVER_TBL](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[SERVERNAME] [varchar](20) NULL,
	[PRIORITY] [int] NULL,
	[ACTIVE] [int] NULL
) ON [PRIMARY]
GO
insert into SQLALERT..ALERT_SERVER_TBL (SERVERNAME, [PRIORITY], ACTIVE) select @@SERVERNAME, 1, 1



if object_id('ALERT_REMOTE_SERVER') is not null drop table ALERT_REMOTE_SERVER
go
CREATE TABLE [dbo].[ALERT_REMOTE_SERVER](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[SERVERNAME] [varchar](20) NULL,
	[PRIORITY] [int] NULL,
	[ACTIVE] [int] NULL
) ON [PRIMARY]
GO
insert into SQLALERT..ALERT_REMOTE_SERVER (SERVERNAME, [PRIORITY], ACTIVE) select @@SERVERNAME, 1, 1


if object_id('ALERT_NOTIF_PERSONS') is not null drop table ALERT_NOTIF_PERSONS
go
CREATE TABLE [dbo].[ALERT_NOTIF_PERSONS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[person] [varchar](100) NULL,
	[emailaddr] [varchar](1000) NULL,
	[active] [int] NULL
) ON [PRIMARY]
GO

if object_id('ALERT_NOTIF_GROUPS') is not null drop table ALERT_NOTIF_GROUPS
go
CREATE TABLE [dbo].[ALERT_NOTIF_GROUPS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[groupname] [varchar](100) NULL,
	[active] [int] NULL
) ON [PRIMARY]
GO

if object_id('ALERT_NOTIF_GROUP_MEMBERS') is not null drop table ALERT_NOTIF_GROUP_MEMBERS
go
CREATE TABLE [dbo].[ALERT_NOTIF_GROUP_MEMBERS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[gid] [int] NULL,
	[pid] [int] NULL,
	[typeid] [int] NULL,
	[cid] [int] NULL
) ON [PRIMARY]
GO

if object_id('ALERT_NOTIF_GROUP_MEMBERS_TYPES') is not null drop table ALERT_NOTIF_GROUP_MEMBERS_TYPES
go
CREATE TABLE [dbo].[ALERT_NOTIF_GROUP_MEMBERS_TYPES](
	[id] [int] NULL,
	[type] [varchar](50) NULL
) ON [PRIMARY]
GO

if object_id('ALERT_MESSAGES') is not null drop table ALERT_MESSAGES
go
CREATE TABLE [dbo].[ALERT_MESSAGES](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[msg_date] [datetime] NULL,
	[subj] [varchar](512) NULL,
	[msg] [varchar](8000) NULL,
	[notified] [varchar](7500) NULL
) ON [PRIMARY]
GO

if object_id('ALERT_SESSION') is not null drop table ALERT_SESSION
go
CREATE TABLE [dbo].[ALERT_SESSION](
	[EID] [int] NOT NULL,
	[MESSAGE] [varchar](8000) NULL,
PRIMARY KEY CLUSTERED 
(
	[EID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


if object_id('ALERT_EMAIL_CRITICALITY') is not null drop table ALERT_EMAIL_CRITICALITY
go
CREATE TABLE [dbo].[ALERT_EMAIL_CRITICALITY](
	[cid] [int] NOT NULL,
	[criticality_name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[cid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
insert into SQLALERT..ALERT_EMAIL_CRITICALITY (cid, criticality_name) select 1, 'OnlyFailures'
insert into SQLALERT..ALERT_EMAIL_CRITICALITY (cid, criticality_name) select 2, 'OnlyFailuresWarnings'
insert into SQLALERT..ALERT_EMAIL_CRITICALITY (cid, criticality_name) select 4, 'SendAll'




if object_id('ALERT_EMAIL_METHOD') is not null drop table ALERT_EMAIL_METHOD
go
CREATE TABLE [dbo].[ALERT_EMAIL_METHOD](
	[default_alert] [int] NULL,
	[description] [varchar](20) NULL
) ON [PRIMARY]
GO
insert into SQLALERT..ALERT_EMAIL_METHOD (default_alert, description) select 6, 'CSMail'



if object_id('ALERT_EMAIL_TEXTEVALS') is not null drop table ALERT_EMAIL_TEXTEVALS
go
CREATE TABLE [dbo].[ALERT_EMAIL_TEXTEVALS](
	[txtid] [int] NOT NULL,
	[txt_type_desc] [varchar](20) NULL,
	[txteval] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[txtid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
insert into SQLALERT..ALERT_EMAIL_TEXTEVALS (txtid, txt_type_desc, txteval) select 1, 'errortext', 'fail~error~exception~critical~'
insert into SQLALERT..ALERT_EMAIL_TEXTEVALS (txtid, txt_type_desc, txteval) select 2, 'warntext', 'msg~warn~information~issue~'


if object_id('EMAIL_REQ_TYPE') is not null drop table EMAIL_REQ_TYPE
go
CREATE TABLE [dbo].[EMAIL_REQ_TYPE](
	[TID] [smallint] NOT NULL,
	[TYPENAME] [varchar](20) NULL,
 CONSTRAINT [PK_EMAIL_REQ_TYPE] PRIMARY KEY CLUSTERED 
(
	[TID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

insert into SQLALERT..EMAIL_REQ_TYPE (TID, TYPENAME) select 1, 'TEXT'
insert into SQLALERT..EMAIL_REQ_TYPE (TID, TYPENAME) select 2, 'HTML'
insert into SQLALERT..EMAIL_REQ_TYPE (TID, TYPENAME) select 3, 'text/plain'
insert into SQLALERT..EMAIL_REQ_TYPE (TID, TYPENAME) select 4, 'text/html'


if object_id('ALERT_METHOD_PRIORITY') is not null drop table ALERT_METHOD_PRIORITY
go
CREATE TABLE [dbo].[ALERT_METHOD_PRIORITY](
	[ALERTID] [int] NULL,
	[ALERTNAME] [varchar](100) NULL,
	[ALERTPRIORITY] [int] NULL
) ON [PRIMARY]
GO


insert into SQLALERT..ALERT_METHOD_PRIORITY (ALERTID, ALERTNAME, ALERTPRIORITY) select 1, 'SQL Mail', 4
insert into SQLALERT..ALERT_METHOD_PRIORITY (ALERTID, ALERTNAME, ALERTPRIORITY) select 2, 'jsSMTP Mail', 5
insert into SQLALERT..ALERT_METHOD_PRIORITY (ALERTID, ALERTNAME, ALERTPRIORITY) select 3, 'DB Mail', 3
insert into SQLALERT..ALERT_METHOD_PRIORITY (ALERTID, ALERTNAME, ALERTPRIORITY) select 4, 'xpSMTP Mail', 6
insert into SQLALERT..ALERT_METHOD_PRIORITY (ALERTID, ALERTNAME, ALERTPRIORITY) select 5, 'JAVA Mail', 2
insert into SQLALERT..ALERT_METHOD_PRIORITY (ALERTID, ALERTNAME, ALERTPRIORITY) select 6, 'CSMail', 1

