# SQLAlert
SQLAlert Code

## SQLAlert Notifications Framework

Author: Alan Danque

Date:	20210809

Purpose:Allows for logging, reporting and email group subscription with sender/reciever configuration of SendAll, SendOnlyFail&War, or SendOnlyFail Email Alerts
Status: Currently Being Tested in DEV.


## Abstract:

Under construction: The intention for this is to log, track and configure email alerts from SQL applications. With the email subscription model and a configuration area for if a recipient wants to receive all emails ie successful/fail/warn or fail/warn or just fail notifications.


## Relation DB Objects
### Tables:
| Table Name | Purpose |
| ----- | ------ | 
| EMAIL_REQ_TYPE | Email Mime Type | 
| ALERT_METHOD_PRIORITY | Email Send Notification Type Priority | 
| ALERT_SEQUENCE | Object Sequence Management | 
| ALERT_SERVER_TBL | Server Mananagement Table | 
| ALERT_REMOTE_SERVER | Remote Server Management Table | 
| ALERT_NOTIF_PERSONS | Recipients Configuration Table | 
| ALERT_NOTIF_GROUPS | Email Alert Group Management Table | 
| ALERT_NOTIF_GROUP_MEMBERS | Email Group Membership Table | 
| ALERT_NOTIF_GROUP_MEMBERS_TYPES | Email Group Membership Receipt Type | 
| ALERT_MESSAGES | Alert Email History | 
| ALERT_SESSION | Session ID Management | 
| ALERT_EMAIL_CRITICALITY | Email criticality configuration | 
| ALERT_EMAIL_METHOD | Default Email send type | 
| ALERT_EMAIL_TEXTEVALS | Criticality categorical text configuration | 

### Stored Procedures:
| Object Name | Purpose |
| ----- | ------ | 
| SP_ALERT_GETNEXTID | Manages Table IDs | 
| SP_TSQLRETINTVAL | Parses int values within txt| 
| sp_GetCurrentDefaultEmail | Get next email type after verifying default | 
| sp_SQLAlert | Email Notification entry sproc | 
| sp_AddAlertPerson | Adds recipient to framework | 
| sp_AddAlertGroup | Adds groups to framework | 
| sp_AddAlertGroupMember | Adds membership to framework | 
| sp_CreateJobNotificationAlert | Creates email notification | 

### Functions:
| Object Name | Purpose |
| ----- | ------ | 
| fn_RetEmailNHow | Obtains list of intended email addresses by group |
| fn_RetDelimValTbl | Tokenizing text function | 
| fn_VariableValueToTableSession | Session ID Message Management | 


- Server: DEVSQL08 (currently)

### Example pyApplication Email Prep 
declare @OUTVAL varchar(max)
exec SQLAlert..[uP_prepEmail] 
	 @EMAILGROUP = 'ALAN_TEST'
	,@subj = 'test subject'
	,@msg = ' test message '
	,@sender = 'alan danque'
	,@OUTVAL = @OUTVAL OUTPUT
select @OUTVAL 

### Usage Queries
```
Steps to set recipient criticality level per sql email group.
	
While adding sqlalert members.

	 -- 	To add PERSONs to alert
	 exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='Alan Danque', @EMAILADDR ='adanque@eqr.com'
	exec SQLALERT..sp_AddAlertPERSON @FULLNAME ='Alan Danque', @EMAILADDR ='adanque@gmail.com'

	 -- 	To add group to alert 
	 exec SQLALERT..sp_AddAlertGroup @GROUPNAME ='ALAN_TEST'

	 -- 	To add group member
	 exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@eqr.com', @GROUPNAME ='ALAN_TEST', @TYPEID = 1 --Types are 1 = to, 2 = cc, 3 = bcc
	 exec SQLALERT..sp_AddAlertGroupMember @EMAILADDRess ='adanque@gmail.com', @GROUPNAME ='ALAN_TEST', @TYPEID = 1 --Types are 1 = to, 2 = cc, 3 = bcc
			,@CRITICALITY_LEVEL = 1 -- 4 all, 2 warn, 1 fail/error


Update existing SQLAlert members

-- Review SQLAlert email group membership.
select a.PERSON, a.EMAILADDR, c.groupname, b.* 
from SQLALERT..ALERT_NOTIF_PERSONS a 
	join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
	join SQLALERT..ALERT_NOTIF_GROUPS c on c.id = b.GID 
order by c.groupname desc

-- Update membership based on expected type of email -- 4 all emails, 2 warn, 1 fail/error
Update b set b.cid = 1  --(This sets the type of emails to send to only Failures / Errors)
	from SQLALERT..ALERT_NOTIF_PERSONS a 
		join SQLALERT..ALERT_NOTIF_GROUP_MEMBERS b on a.id = b.pid 
		join SQLALERT..ALERT_NOTIF_GROUPS c on c.id = b.GID 
	where a.emailaddr = 'adanque@gmail.com'
		and c.groupname = 'ALAN_TEST'


```

## Servers
- Server: All Dev SQL Servers
Under construction

## Deployment steps.
To Deploy:


1. Download and copy the sqlalert.exe to the target sql server local C:\Scripts\CSMail\ folder.


2. Connect to the target SQL Server and execute the following scripts in the order noted.
  a. Create SQLAlert DB.sql  (note may need to modify the target data and log drive names to align with target SQL Server.)
  b. ALERT_TABLES.sql
  c. ALERT_SPROCS.sql
  d. ALERT_FUNCTIONS.sql
  e. ALERT_TRANSFER_EQRDBA_ALERT_GROUP_MEMBERS.sql

 
## Test steps.
Execute the following command within SSMS.

1. exec sp_SQLAlert
    @GROUPNAME = 'DBA'
    ,@SUBJECT= 'TEST SUBJECT PLS IGNORE' 
    ,@MESSAGE= 'TEST MESSAGE '

2. Validate the email was recorded into the ALERT_MESSAGES table.
pls execute the query: 

select top 100 * from EQRDBA..ALERT_MESSAGES (nolock) order by id desc



Not in scope: 
Changing current SQL Job Notifications to swap the EQRDBA with SQLAlert databases.
Changing database objects to refer to the SQLAlert email procs vs the EQRDBA.


## Project files
| Type | File name | Description |
| ----- | ------ | ------ |
| TSQL | ALERT_FUNCTIONS.sql | | 
| TSQL | ALERT_SPROCS.sql | | 
| TSQL | ALERT_TABLES.sql | | 
| TSQL | ALERT_TESTING.sql | | 
| TSQL | ALERT_TRANSFER_EQRDBA_ALERT_GROUP_MEMBERS.sql | | 
| TSQL | Create SQLAlert DB.sql | | 
| MD | README.md | | 
| C# | SQLAlert.cs | | 
| EXE | sqlalert.exe | | 
