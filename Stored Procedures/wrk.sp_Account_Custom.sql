SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [wrk].[sp_Account_Custom]
AS 

/******************************
Updated By: Caeleon Work
Updated Date: 4/19/18
Update Notes: Added Logic for new_ticketingrevenue field
*******************************/

MERGE INTO dbo.Account_Custom Target
USING dbo.[Account] source
ON source.[SSB_CRMSYSTEM_ACCT_ID] = target.[SSB_CRMSYSTEM_ACCT_ID]
WHEN NOT MATCHED THEN
INSERT ([SSB_CRMSYSTEM_ACCT_ID]) VALUES (Source.[SSB_CRMSYSTEM_ACCT_ID]);

EXEC dbo.sp_CRMProcess_ConcatIDs 'Account'

--UPDATE a
--SET SeasonTicket_Years = recent.SeasonTicket_Years
----SELECT *
--FROM dbo.[Account_Custom] a
--INNER JOIN dbo.CRMProcess_DistinctAccounts recent ON a.SSB_CRMSYSTEM_ACCT_ID = recent.SSB_CRMSYSTEM_ACCT_ID

/*********************************
Ticketing Revenue Rollup For Accounts (new_TicketingRevenue)
***********************************/
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(fts.TotalRevenue) totalrev 
INTO #TotalRev
FROM Bears.dbo.FactTicketSales fts (NOLOCK)
JOIN dbo.vwDimCustomer_ModAcctId dc ON dc.AccountId = fts.SSID_acct_id AND dc.SourceSystem = fts.SourceSystem
AND dc.CustomerType = 'Primary'
WHERE dc.IsBusiness = 1
GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID

UPDATE a
SET a.new_ticketingrevenue = tr.totalrev
FROM dbo.Account_Custom a
INNER JOIN #TotalRev tr ON tr.SSB_CRMSYSTEM_ACCT_ID = a.SSB_CRMSYSTEM_ACCT_ID






UPDATE a
SET SSID_Winner =b.SSID, new_ssbcrmsystemssidwinnersourcesystem = b.SourceSystem
FROM [dbo].[Account_Custom] a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON ISNULL([b].[SSB_CRMSYSTEM_ACCT_ID],b.[SSB_CRMSYSTEM_CONTACT_ID]) = [a].[SSB_CRMSYSTEM_ACCT_ID]
INNER JOIN dbo.[vwDimCustomer_ModAcctId] c ON b.[DimCustomerId] = c.[DimCustomerId] AND c.[SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG] = 1

EXEC dbo.sp_CRMLoad_Account_ProcessLoad_Criteria

GO
