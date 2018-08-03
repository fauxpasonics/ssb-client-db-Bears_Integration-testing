SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
 CREATE PROCEDURE [wrk].[sp_PostPushMonitoring]
 AS

--POST CRM PUSH MONITORING

declare @ClientName NVARCHAR(100) SET @ClientName = 'Bears'


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


DECLARE @ReportingDatabase NVARCHAR(100) SET @ReportingDatabase = (SELECT ReportingDatabase FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @IntegrationDatabase NVARCHAR(100) SET @IntegrationDatabase = (SELECT IntegrationDatabase FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @CreatedUserField NVARCHAR(100) SET @CreatedUserField = (SELECT CASE WHEN CRM_Platform = 'Dynamics' THEN 'CreatedBy' WHEN CRM_Platform = 'SFDC' THEN 'CreatedById' ELSE NULL end  FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ModifiedUserField NVARCHAR(100) SET @ModifiedUserField = (SELECT CASE WHEN CRM_Platform = 'Dynamics' THEN 'ModifiedBy' WHEN CRM_Platform = 'SFDC' THEN 'LastModifiedByID' ELSE NULL end  FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @CreatedDateField NVARCHAR(100) SET @CreatedDateField = (SELECT CASE WHEN CRM_Platform = 'Dynamics' THEN 'CreatedOn' WHEN CRM_Platform = 'SFDC' THEN 'CreatedDate' ELSE NULL end  FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ModifiedDateField NVARCHAR(100) SET @ModifiedDateField = (SELECT CASE WHEN CRM_Platform = 'Dynamics' THEN 'CreatedOn' WHEN CRM_Platform = 'SFDC' THEN 'CreatedDate' ELSE NULL end  FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @IntegrationUser NVARCHAR(100) SET @IntegrationUser = (SELECT IntegrationUser FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ProdcopySchema NVARCHAR(100) SET @ProdcopySchema = (SELECT ProdcopySchema FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ProdcopyDaysBack INT SET @ProdcopyDaysBack = (SELECT ProdcopyDaysBack FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ModifiedCreatedTimestamp DATETIME SET @ModifiedCreatedTimestamp = (SELECT GETDATE() - @ProdcopyDaysBack)
DECLARE @LoadDateField NVARCHAR(100) SET @LoadDateField = (SELECT LoadDateField FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ResultsErrorWhereSQL NVARCHAR(200) SET @ResultsErrorWhereSQL = (SELECT CASE WHEN CRM_Platform = 'Dynamics' THEN 'WHERE CRMErrorMessage IS NOT NULL' WHEN CRM_Platform = 'SFDC' THEN 'WHERE ISNULL(ErrorDescription,'''') != ''''' ELSE NULL end  FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)

SELECT 1

/***************************
--Start Contact
***************************/


/*==========================
--Has Contact
	--Errors Skip to End of Section
==========================*/
IF (SELECT HasContact FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName) = 0 BEGIN GOTO EndContact END

DECLARE @ProdcopyContactTable NVARCHAR(100) SET @ProdcopyContactTable = (SELECT ProdcopyContactTable FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ContactStdResultsTable NVARCHAR(100) SET @ContactStdResultsTable = (SELECT ContactStdResultsTable FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)
DECLARE @ContactCustomResultsTable NVARCHAR(100) SET @ContactCustomResultsTable = (SELECT ContactCustomResultsTable FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName)



/*==========================
--Contact Prodcopy Created/Modified
==========================*/
SELECT 2

--Modified by SSB in Last 1 Day ONLY
DECLARE @ContactModifiedbySSBSQL NVARCHAR(max) SET @ContactModifiedbySSBSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactProdcopyModifiedbySSBCount = (SElECT count(*) from ' + @ReportingDatabase + '.' + @ProdcopySchema + '.' + @ProdcopyContactTable + 
' with (NOLOCK) WHERE ' + @ModifiedDateField + ' > GETDATE()-1 and ' + @ModifiedUserField + ' = ''' + @IntegrationUser + ''') WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@ContactModifiedbySSBSQL)
EXEC sp_executesql @ContactModifiedbySSBSQL

--Created by SSB in Last 1 Day ONLY
DECLARE @ContactCreatedbySSBSQL NVARCHAR(max) SET @ContactCreatedbySSBSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactProdcopyCreatedbySSBCount = (SElECT count(*) from ' + @ReportingDatabase + '.' + @ProdcopySchema + '.' + @ProdcopyContactTable + 
' with (NOLOCK) WHERE ' + @ModifiedDateField + ' > GETDATE()-1 and ' + @ModifiedUserField + ' = ''' + @IntegrationUser + ''') WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@ContactCreatedbySSBSQL)
EXEC sp_executesql @ContactCreatedbySSBSQL

--Modified by Anyone in Last X Day(s)
DECLARE @ContactModifiedSQL NVARCHAR(max) SET @ContactModifiedSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactProdcopyModifiedCount = (SElECT count(*) from ' + @ReportingDatabase + '.' + @ProdcopySchema + '.' + @ProdcopyContactTable + 
' with (NOLOCK) WHERE ' + @ModifiedDateField + ' > ''' + CONVERT(VARCHAR(100),@ModifiedCreatedTimestamp, 121)  + ''') WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@ContactModifiedSQL)
EXEC sp_executesql @ContactModifiedSQL

--Created by Anyone in Last X Day(s)
DECLARE @ContactCreatedSQL NVARCHAR(max) SET @ContactCreatedSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactProdcopyCreatedCount = (SElECT count(*) from ' + @ReportingDatabase + '.' + @ProdcopySchema + '.' + @ProdcopyContactTable + 
' with (NOLOCK) WHERE ' + @CreatedDateField + ' > ''' + CONVERT(VARCHAR(100),@ModifiedCreatedTimestamp, 121)  + ''') WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@@ContactCreatedSQL)
EXEC sp_executesql @ContactCreatedSQL


SELECT 3

/*==========================
--Contact Prodcopy Records Ingested
==========================*/

--Number of Records Ingested to Warehouse in Last ONE Day ONLY
DECLARE @ContactLoadDateSQL NVARCHAR(max) SET @ContactLoadDateSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactLoadDateCount = (SElECT count(*) from ' + @ReportingDatabase + '.' + @ProdcopySchema + '.' + @ProdcopyContactTable + 
' with (NOLOCK) WHERE ' + @LoadDateField + ' > GETDATE()-1 ) WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@ContactLoadDateSQL)
EXEC sp_executesql @ContactLoadDateSQL

SELECT 4

/*==========================
--Contact TO CRM Loading Counts/Errors
==========================*/

--Contact Std - Number of Records Attempted to Load
DECLARE @ContactStdResultsCountSQL NVARCHAR(max) SET @ContactStdResultsCountSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactStdResultsCount = (SElECT count(*) from ' + @IntegrationDatabase + '.' + @ContactStdResultsTable + 
' with (NOLOCK) ) WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@ContactStdResultsCountSQL)
EXEC sp_executesql @ContactStdResultsCountSQL

--Contact Std - Number of Records Failed to Load
DECLARE @ContactStdResultsErrorCountSQL NVARCHAR(max) SET @ContactStdResultsErrorCountSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactStdResultsErrorCount = (SElECT count(*) from ' + @IntegrationDatabase + '.' + @ContactStdResultsTable + 
' with (NOLOCK) ' + @ResultsErrorWhereSQL + ') WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@ContactStdResultsCountSQL)
EXEC sp_executesql @ContactStdResultsErrorCountSQL

--Contact Custom - Number of Records Attempted to Load
DECLARE @ContactCustomResultsCountSQL NVARCHAR(max) SET @ContactCustomResultsCountSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactCustomResultsCount = (SElECT count(*) from ' + @IntegrationDatabase + '.' + @ContactCustomResultsTable + 
' with (NOLOCK) ) WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@@ContactCustomResultsCountSQL)
EXEC sp_executesql @ContactCustomResultsCountSQL

--Contact Custom - Number of Records Failed to Load
DECLARE @ContactCustomResultsErrorCountSQL NVARCHAR(max) SET @ContactCustomResultsErrorCountSQL = 
(SELECT 'UPDATE stg.CRM_Settings SET ContactCustomResultsErrorCount = (SElECT count(*) from ' + @IntegrationDatabase + '.' + @ContactCustomResultsTable + 
' with (NOLOCK) ' + @ResultsErrorWhereSQL + ') WHERE Active = 1 and ClientName = ''' + @ClientName + '''')

--SELECT (@@ContactCustomResultsErrorCountSQL)
EXEC sp_executesql @ContactCustomResultsErrorCountSQL










--REPLICATE ABOVE FOR ACCOUNT


--select prodcopy all other pushes where modified by integrationuser
--select prodcopy all other pushes where created by integrationuser

--count of results table where error is present

--determining which prodcopy tables did/didn't pick up new records - Jets control table?.... Add step in between the prodcopy pull and the hard deletion to log time/tablename?

--HEDA

--Hard Deletion

UPDATE stg.CRM_Settings set LastRunEnd = GETDATE() FROM stg.CRM_Settings WHERE Active = 1 AND ClientName = @ClientName

EndContact:







EndAccount:




EndProc:

GO
