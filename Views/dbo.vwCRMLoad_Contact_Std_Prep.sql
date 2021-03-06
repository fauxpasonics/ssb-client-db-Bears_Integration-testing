SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Prep]
AS 
SELECT --updateme - hashes
	  a.[SSB_CRMSYSTEM_ACCT_ID] new_ssbcrmsystemacctid
	  , a.[SSB_CRMSYSTEM_CONTACT_ID] new_ssbcrmsystemcontactid
	  , ISNULL(NULLIF(a.[Prefix],''), comp.SalutationName) AS Prefix
      , a.[FirstName]
	  , CASE WHEN ISNULL(a.lastname,'') + ISNULL(a.FirstName,'') = '' THEN comp.companyname ELSE a.[LastName] END AS LastName
	  , NULLIF(LEFT(a.[Suffix],10),'') AS Suffix
	  ,NULLIF(a.[AddressPrimaryStreet],' ')		AS	address1_line1			
	  ,NULLIF(a.[AddressPrimaryCity],'')			AS	address1_city			
	  ,NULLIF(a.[AddressPrimaryState],'')		AS		address1_stateorprovince
	  ,NULLIF(a.[AddressPrimaryZip],'')			AS	address1_postalcode		
	  ,NULLIF(a.[AddressPrimaryCountry],'')		AS	address1_country		
      ,NULLIF(a.[Phone],'') telephone1
	  ,NULLIF(a.EmailPrimary,'') emailaddress1
	  ,NULLIF(a.MiddleName,'') middlename
      ,a.[crm_id] contactid
	  ,c.[LoadType]	  
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.FirstName))),'')) AS Hash_FirstName						--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER( CASE WHEN ISNULL(a.lastname,'') + ISNULL(a.FirstName,'') = '' THEN comp.companyname ELSE a.[LastName] END))),'')) AS Hash_LastName						--	DCH 2017-02-19 
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.Suffix))),'')) AS Hash_Suffix 							--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.AddressPrimaryStreet))),'')) AS Hash_Address1_Line1 		--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(a.Phone,')',''),'(',''),'-',''),' ','')))),'')) AS Hash_Telephone1					--	DCH 2017-02-19
  FROM [dbo].Contact a 
INNER JOIN dbo.[CRMLoad_Contact_ProcessLoad_Criteria] c ON [c].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
INNER JOIN dbo.vwCompositeRecord_ModAcctID comp ON a.SSB_CRMSYSTEM_CONTACT_ID = comp.SSB_CRMSYSTEM_CONTACT_ID
LEFT JOIN bears.ods.TM_Cust ods ON CAST(ods.acct_id AS NVARCHAR(100)) + ':' + CAST(ods.cust_name_id AS NVARCHAR(100)) = comp.SSID AND comp.SourceSystem = 'tm'







GO
