SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [wrk].[sp_PrePushMonitoring]

as

-- PRE CRM PUSH / POST PREP MONITORING


declare @ClientName NVARCHAR(100) SET @ClientName = 'Bears'



/*==========================
--Previous Run Did Not Complete Successfully
	-- Errors End Job with Failure
==========================*/
DECLARE @PreviousProcessIncomplete BIT SET @PreviousProcessIncomplete = 
(SELECT CASE WHEN LastRunStart > LastRunEnd THEN 1 ELSE 0 END AS FailMe
FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)

IF @PreviousProcessIncomplete = 1 BEGIN RAISERROR('Previous Run Was Incomplete',16,1) GOTO EndProc END

DECLARE @ReportingDatabase NVARCHAR(100) SET @ReportingDatabase = (SELECT ReportingDatabase FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @IntegrationDatabase NVARCHAR(100) SET @IntegrationDatabase = (SELECT IntegrationDatabase FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @RecipientsList NVARCHAR(300) = (SELECT NotificationRecipients from stg.CRM_Settings where Active = 1 AND ClientName = @ClientName)


UPDATE stg.CRM_Settings set LastRunStart = GETDATE() FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName

/*==========================
--Must Have ONLY 1 CRM_Settings record deployed (no more, no less)
	--Errors End Job with Failure
==========================*/
IF (SELECT COUNT(*) FROM stg.CRM_Settings WHERE active = 1 AND ClientName = @ClientName) != 1 BEGIN raiserror('CRM Settings Missing',16,1) GOTO EndProc END 

/*==========================
--Monitoring Not Enabled 
	-- Errors End Job Gracefully
==========================*/
IF (SELECT MonitoringEnabled FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 0 BEGIN raiserror('Monitoring Not Enabled',16,1) GOTO EndProc END 




/***************************
--Start Contact
***************************/


/*==========================
--Has Contact
	--Errors Skip to End of Section
==========================*/
IF (SELECT HasContact FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 0 BEGIN GOTO EndContact END ELSE BEGIN SELECT 0 END 

/*==========================
--Upsert Counts/Averages
==========================*/


DECLARE @ContactStdUpsertView1 NVARCHAR(100) SET @ContactStdUpsertView1 = (SELECT ContactStdUpsertView1 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 
DECLARE @ContactStdUpsertView2 NVARCHAR(100) SET @ContactStdUpsertView2 = (SELECT ContactStdUpsertView2 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 

DECLARE @ContactStdUpsertViewSQL NVARCHAR(max) SET @ContactStdUpsertViewSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactStdUpsertCount = ' + (SELECT CASE 
WHEN  (SELECT HasMultipleLoadViews_Contact FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 1 
		AND (SELECT ISNULL(ContactStdUpsertView1,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
		AND (SELECT ISNULL(ContactStdUpsertView2,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
	THEN '(SELECT (SElECT count(*) from ' + @IntegrationDatabase + '.' + @ContactStdUpsertView1 + ' with (NOLOCK)) + (SELECT Count(*) from ' + @IntegrationDatabase + '.' + @ContactStdUpsertView2 + ' with (NOLOCK)))'
ELSE '(SElECT count(*) from '+ @IntegrationDatabase + '.' +  @ContactStdUpsertView1 + ' with (NOLOCK))'
END )) + ' WHERE Active = 1 and ClientName = ''' + @ClientName + ''''

--SELECT @ContactStdUpsertViewSQL
EXEC sp_executesql @ContactStdUpsertViewSQL

UPDATE stg.CRM_Settings SET ContactStdUpsertRunCount = ContactStdUpsertRunCount + 1
, ContactStdUpsertAvg = (((ContactStdUpsertAvg * ContactStdUpsertRunCount) + ContactStdUpsertCount) / (ContactStdUpsertRunCount + 1))
FROM stg.CRM_Settings
WHERE Active = 1 AND ClientName = @ClientName

EndContactUpsertCountAverage:

/*==========================
StdUpdate Counts/Averages
==========================*/


DECLARE @ContactStdUpdateView1 NVARCHAR(100) SET @ContactStdUpdateView1 = (SELECT ContactStdUpdateView1 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 
DECLARE @ContactStdUpdateView2 NVARCHAR(100) SET @ContactStdUpdateView2 = (SELECT ContactStdUpdateView2 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 

DECLARE @ContactStdUpdateViewSQL NVARCHAR(max) SET @ContactStdUpdateViewSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactStdUpdateCount = ' + (SELECT CASE 
WHEN  (SELECT HasMultipleLoadViews_Contact FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 1
		AND (SELECT ISNULL(ContactStdUpdateView1,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
		AND (SELECT ISNULL(ContactStdUpdateView2,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
	THEN '(SELECT (SElECT count(*) from ' + @IntegrationDatabase + '.' +  @ContactStdUpdateView1 + ' with (NOLOCK)) + (SELECT Count(*) from ' + @IntegrationDatabase + '.' + @ContactStdUpdateView2 + ' with (NOLOCK)))'
ELSE '(SElECT count(*) from ' + @IntegrationDatabase + '.' + @ContactStdUpdateView1 + ' with (NOLOCK))'
END )) + ' WHERE Active = 1 and ClientName = ''' + @ClientName + ''''

--SELECT @ContactStdUpsertViewSQL
EXEC sp_executesql @ContactStdUpdateViewSQL

UPDATE stg.CRM_Settings SET ContactStdUpdateRunCount = ContactStdUpdateRunCount + 1
, ContactStdUpdateAvg = (((ContactStdUpdateAvg * ContactStdUpdateRunCount) + ContactStdUpdateCount) / (ContactStdUpdateRunCount + 1))
FROM stg.CRM_Settings
WHERE Active = 1 AND ClientName = @ClientName

EndContactStdUpdateCountAverage:

/*==========================
--Custom Counts/Averages
==========================*/


DECLARE @ContactCustomView1 NVARCHAR(100) SET @ContactCustomView1 = (SELECT ContactCustomView1 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 
DECLARE @ContactCustomView2 NVARCHAR(100) SET @ContactCustomView2 = (SELECT ContactCustomView2 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 

DECLARE @ContactCustomViewSQL NVARCHAR(max) SET @ContactCustomViewSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactCustomCount = ' + (SELECT CASE 
WHEN  (SELECT HasMultipleLoadViews_Contact FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 1
		AND (SELECT ISNULL(ContactCustomView1,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
		AND (SELECT ISNULL(ContactCustomView2,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
	THEN '(SELECT (SElECT count(*) from ' + @IntegrationDatabase + '.' +  @ContactCustomView1 + ' with (NOLOCK)) + (SELECT Count(*) from ' + @IntegrationDatabase + '.' + @ContactCustomView2 + ' with (NOLOCK)))'
ELSE '(SElECT count(*) from ' + @IntegrationDatabase + '.' + @ContactCustomView1 + ' with (NOLOCK))'
END )) + ' WHERE Active = 1 and ClientName = ''' + @ClientName + ''''

--SELECT @ContactStdUpsertViewSQL
EXEC sp_executesql @ContactCustomViewSQL

UPDATE stg.CRM_Settings SET ContactCustomRunCount = ContactCustomRunCount + 1
, ContactCustomAvg = (((ContactCustomAvg * ContactCustomRunCount) + ContactCustomCount) / (ContactCustomRunCount + 1))
FROM stg.CRM_Settings
WHERE Active = 1 AND ClientName = @ClientName

EndContactCustomCountAverage:



/*==========================
--Count of CRM_IDs > 0 Means we're syncing two GUIDs to the same CRM/SF Record.
	--Errors emails Recipients List
==========================*/

DECLARE @ContactCRMIDErrorSQL NVARCHAR(max) SET @ContactCRMIDErrorSQL = 

' IF (select count(*) from (select crm_id, count(*) as count from ' + @IntegrationDatabase +  '.dbo.contact group by crm_id having count(*) > 1)z) = 0	BEGIN 
 DECLARE @subject_title NVARCHAR(100) = (SELECT DB_NAME() + '' - dbo.Contact Contains crm_id Dupes'')

 exec [msdb].dbo.sp_send_dbmail
      @profile_name = ''Mandrill''
      ,@recipients = ''' + @RecipientsList +'''
      ,@subject = @subject_title
      ,@body = ''This client has multiple dbo.contact records with the same CRM_ID''
      ,@body_format = ''HTML''
END'

SELECT @ContactCRMIDErrorSQL
EXEC sp_executesql  @ContactCRMIDErrorSQL

ENDContactCRMID:

EndContact:


/***************************
--Start Account
***************************/



/*==========================
--Has Account
	--Errors Skip to End of Section
==========================*/
IF (SELECT HasAccount FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 0 BEGIN GOTO EndAccount END ELSE BEGIN SELECT 0 END 

/*==========================
--Upsert Counts/Averages
==========================*/


DECLARE @AccountStdUpsertView1 NVARCHAR(100) SET @AccountStdUpsertView1 = (SELECT AccountStdUpsertView1 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 
DECLARE @AccountStdUpsertView2 NVARCHAR(100) SET @AccountStdUpsertView2 = (SELECT AccountStdUpsertView2 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 

DECLARE @AccountStdUpsertViewSQL NVARCHAR(max) SET @AccountStdUpsertViewSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET AccountStdUpsertCount = ' + (SELECT CASE 
WHEN  (SELECT HasMultipleLoadViews_Account FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 1 
		AND (SELECT ISNULL(AccountStdUpsertView1,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
		AND (SELECT ISNULL(AccountStdUpsertView2,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
	THEN '(SELECT (SElECT count(*) from '  + @IntegrationDatabase + '.'+  @AccountStdUpsertView1 + ' with (NOLOCK)) + (SELECT Count(*) from '  + @IntegrationDatabase + '.'+ @AccountStdUpsertView2 + ' with (NOLOCK)))'
ELSE '(SElECT count(*) from '  + @IntegrationDatabase + '.'+  @AccountStdUpsertView1 + ' with (NOLOCK))'
END )) + ' WHERE Active = 1 and ClientName = ''' + @ClientName + ''''

--SELECT @AccountStdUpsertViewSQL
EXEC sp_executesql @AccountStdUpsertViewSQL

UPDATE stg.CRM_Settings SET AccountStdUpsertRunCount = AccountStdUpsertRunCount + 1
, AccountStdUpsertAvg = (((AccountStdUpsertAvg * AccountStdUpsertRunCount) + AccountStdUpsertCount) / (AccountStdUpsertRunCount + 1))
FROM stg.CRM_Settings
WHERE Active = 1 AND ClientName = @ClientName

EndAccountUpsertCountAverage:

/*==========================
StdUpdate Counts/Averages
==========================*/


DECLARE @AccountStdUpdateView1 NVARCHAR(100) SET @AccountStdUpdateView1 = (SELECT AccountStdUpdateView1 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 
DECLARE @AccountStdUpdateView2 NVARCHAR(100) SET @AccountStdUpdateView2 = (SELECT AccountStdUpdateView2 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 

DECLARE @AccountStdUpdateViewSQL NVARCHAR(max) SET @AccountStdUpdateViewSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET AccountStdUpdateCount = ' + (SELECT CASE 
WHEN  (SELECT HasMultipleLoadViews_Account FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 1
		AND (SELECT ISNULL(AccountStdUpdateView1,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
		AND (SELECT ISNULL(AccountStdUpdateView2,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
	THEN '(SELECT (SElECT count(*) from '  + @IntegrationDatabase + '.'+  @AccountStdUpdateView1 + ' with (NOLOCK)) + (SELECT Count(*) from '  + @IntegrationDatabase + '.'+ @AccountStdUpdateView2 + ' with (NOLOCK)))'
ELSE '(SElECT count(*) from '  + @IntegrationDatabase + '.'+  @AccountStdUpdateView1 + ' with (NOLOCK))'
END )) + ' WHERE Active = 1 and ClientName = ''' + @ClientName + ''''

--SELECT @AccountStdUpsertViewSQL
EXEC sp_executesql @AccountStdUpdateViewSQL

UPDATE stg.CRM_Settings SET AccountStdUpdateRunCount = AccountStdUpdateRunCount + 1
, AccountStdUpdateAvg = (((AccountStdUpdateAvg * AccountStdUpdateRunCount) + AccountStdUpdateCount) / (AccountStdUpdateRunCount + 1))
FROM stg.CRM_Settings
WHERE Active = 1 AND ClientName = @ClientName

EndAccountStdUpdateCountAverage:

/*==========================
--Custom Counts/Averages
==========================*/


DECLARE @AccountCustomView1 NVARCHAR(100) SET @AccountCustomView1 = (SELECT AccountCustomView1 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 
DECLARE @AccountCustomView2 NVARCHAR(100) SET @AccountCustomView2 = (SELECT AccountCustomView2 FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) 

DECLARE @AccountCustomViewSQL NVARCHAR(max) SET @AccountCustomViewSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET AccountCustomCount = ' + (SELECT CASE 
WHEN  (SELECT HasMultipleLoadViews_Account FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 1
		AND (SELECT ISNULL(AccountCustomView1,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
		AND (SELECT ISNULL(AccountCustomView2,'') FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) != ''
	THEN '(SELECT (SElECT count(*) from '  + @IntegrationDatabase + '.'+  @AccountCustomView1 + ' with (NOLOCK)) + (SELECT Count(*) from '  + @IntegrationDatabase + '.'+ @AccountCustomView2 + ' with (NOLOCK)))'
ELSE '(SElECT count(*) from '  + @IntegrationDatabase + '.'+  @AccountCustomView1 + ' with (NOLOCK))'
END )) + ' WHERE Active = 1 and ClientName = ''' + @ClientName + ''''

--SELECT @AccountStdUpsertViewSQL
EXEC sp_executesql @AccountCustomViewSQL

UPDATE stg.CRM_Settings SET AccountCustomRunCount = AccountCustomRunCount + 1
, AccountCustomAvg = (((AccountCustomAvg * AccountCustomRunCount) + AccountCustomCount) / (AccountCustomRunCount + 1))
FROM stg.CRM_Settings
WHERE Active = 1 AND ClientName = @ClientName

EndAccountCustomCountAverage:




/*==========================
--Count of CRM_IDs > 0 Means we're syncing two GUIDs to the same CRM/SF Record.
	--Errors emails Recipients List
==========================*/
DECLARE @AccountCRMIDErrorSQL NVARCHAR(max) SET @AccountCRMIDErrorSQL = 

' IF (select count(*) from (select crm_id, count(*) as count from ' + @IntegrationDatabase +  '.dbo.Account group by crm_id having count(*) > 1)z) = 0	BEGIN 
 DECLARE @subject_title NVARCHAR(100) = (SELECT DB_NAME() + '' - dbo.Account Contains crm_id Dupes'')
 exec [msdb].dbo.sp_send_dbmail
      @profile_name = ''Mandrill''
      ,@recipients = ''' + @RecipientsList + '''
      ,@subject = @subject_title
      ,@body = ''This client has multiple dbo.Account records with the same CRM_ID''
      ,@body_format = ''HTML''
END'

--SELECT @AccountCRMIDErrorSQL
EXEC sp_executesql  @AccountCRMIDErrorSQL

ENDAccountCRMID:


EndAccount:


	EndProc:
GO
