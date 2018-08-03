SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vwCRMLoad_Account_Custom_Update]
AS

SELECT  z.[crm_id] accountid
, SSID_Winner new_ssbcrmsystemssidwinner
, b.TM_Ids
, b.new_ssbcrmsystemssidwinnersourcesystem
, DimCustIDs new_ssbcrmsystemdimcustomerids
, b.AccountId [str_number]
, b.new_ticketingrevenue
--, b.TMSuite_Ids AS str_clientsuiteid
-- SELECT *
-- SELECT COUNT(*) 
FROM dbo.[Account_Custom] b 
INNER JOIN dbo.Account z ON b.SSB_CRMSYSTEM_Acct_ID = z.[SSB_CRMSYSTEM_Acct_ID]
LEFT JOIN  prodcopy.vw_Account c ON z.[crm_id] = c.AccountID
----INNER JOIN dbo.CRMLoad_Acct_ProcessLoad_Criteria pl ON b.SSB_CRMSYSTEM_Acct_ID = pl.SSB_CRMSYSTEM_Acct_ID
LEFT JOIN Bears.[dbo].[vw_KeyAccounts] k --updateme
		ON z.crm_ID = k.SSID
WHERE z.[SSB_CRMSYSTEM_Acct_ID] <> z.[crm_id]
AND k.SSID IS NULL
--AND  (HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.SSID_Winner)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemssidwinner AS VARCHAR(MAX)))),'')) 
--	--OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.TM_Ids)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemdimcustomerids AS VARCHAR(MAX)))),'')) 
--	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssbcrmsystemssidwinnersourcesystem)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemssidwinnersourcesystem AS VARCHAR(MAX)))),''))
--	--OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.DimCustIDs)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemdimcustomerids AS VARCHAR(MAX)))),''))
--	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.AccountId)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[str_number] AS VARCHAR(MAX)))),''))
--	--OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.TMSuite_Ids)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_clientsuiteid AS VARCHAR(MAX)))),''))
--	)

	AND ( 
 ISNULL(b.SSID_Winner,'') != ISNULL(c.new_ssbcrmsystemssidwinner,'')
OR ISNULL(b.new_ssbcrmsystemssidwinnersourcesystem,'') != ISNULL(c.new_ssbcrmsystemssidwinnersourcesystem,'')
OR ISNULL(b.AccountId,'') != ISNULL(c.str_number,'')
--OR ISNULL(b.TMSuite_Ids,'') != ISNULL(c.str_clientsuiteid,'')
OR ISNULL(b.new_ticketingrevenue,0) != ISNULL(c.new_ticketingrevenue,0)

)


GO
