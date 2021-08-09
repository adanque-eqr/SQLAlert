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
| uP_pyAlert_getNextID | Sequence Management | 
| uP_prepEmail | Starts Email Log and obtains intended email recipients based on group | 
| uP_updtEmailLog | Updates Email Log status after alert execution |

### Functions:
| Object Name | Purpose |
| ----- | ------ | 
| fn_RetEmailNHow | Obtains list of intended email addresses by group |

### Workflow:

- 1. Python application calls, "uP_prepEmail" to get email recipients using group name along with if the recipient wants to receive success / fail&warn / or just failures

- 2. After python app sends email, it calls, "uP_updtEmailLog" to update the email log

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

### Review 
select * 
	from pyEmailLog a
		join pyEmailStatus b
			on a.sid = b.sid

### Example pyApplication email log update
exec SQLAlert..uP_updtEmailLog
	 @EMAIL_MID = 1
	,@STATUS_ID = 3
	,@ret_msg = ' TEST WHERE THE ERROR CODE WILL BE STORED'

### Review Queries
```
select distinct a.mid MessageID, a.daterec, a.datesent, a.sender, a.recipients, a.subj, a.msg, b.statusname, a.ret_msg, c.groupname
		-- Add if would like to see associated applications
		-- , f.appname
	from pyEmailLog a
		join pyEmailStatus b
			on a.sid = b.sid
		join pyEmailGroups c
			on a.gid = c.gid
		join pyEmailImportance d
			on a.gid = d.gid
		-- Allows for email groups to be associated with applications
		cross apply SQLAlert.dbo.fn_RetDelimValTbl('~', d.aids) e
			join SQLAlert..pyEmailApplications f on e.retVals = f.aid --and c.rowid = e.rowid
		-- Add where clause as needed
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
