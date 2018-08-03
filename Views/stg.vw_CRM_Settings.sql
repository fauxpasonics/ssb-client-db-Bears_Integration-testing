SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [stg].[vw_CRM_Settings]
AS
SELECT 
ClientName
,LastRunStart
,LastRunEnd
,HasContact
,HasAccount
,ContactStdUpdateCount
,ContactStdUpdateAvg
,ContactStdUpsertCount
,ContactStdUpsertAvg
,ContactCustomCount
,ContactCustomAvg
,AccountStdUpdateCount
,AccountStdUpdateAvg
,AccountStdUpsertCount
,AccountStdUpsertAvg
,AccountCustomCount
,AccountCustomAvg
,ContactStdResultsCount
,ContactStdResultsErrorCount
,ContactCustomResultsCount
,ContactCustomResultsErrorCount
,AccountStdResultsCount
,AccountStdResultsErrorCount
,AccountCustomResultsCount
,AccountCustomResultsErrorCount
FROM stg.CRM_Settings
WHERE MonitoringEnabled = 1
GO
