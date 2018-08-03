SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO














CREATE VIEW [dbo].[vwCRMLoad_Contact_Custom_Update]
AS

SELECT  z.[crm_id] contactid
, SSID_Winner new_ssbcrmsystemssidwinner													--, c.new_ssbcrmsystemssidwinner       
, NULLIF(TM_Ids,'') [new_ssbcrmsystemarchticsids]											----, c.[new_ssbcrmsystemarchticsids]							       
, DimCustIDs new_ssbcrmsystemdimcustomerids													----, c.new_ssbcrmsystemdimcustomerids							       
, NULLIF(b.AccountId,'') [str_number]														--, c.[str_number]							        --updateme for STR clients
, NULLIF(z.EmailPrimary,'') AS emailaddress1												--, c.emailaddress1							       
, b.new_ssbcrmsystem_RecordType																--, c.new_ssbcrmsystem_RecordType							       
, b.new_ssbcrmsystemssidwinnersourcesystem													--, c.new_ssbcrmsystemssidwinnersourcesystem							       
, NULLIF(b.TMSuite_Ids,'') AS str_clientsuiteid												--, c.str_clientsuiteid							       
, NULLIF(b.company,'') AS company															--, c.company							       
, NULLIF(b.mobilephone,'') AS mobilephone													--, c.mobilephone							       
, NULLIF(b.telephone2,'') AS telephone2														--, c.telephone2							       
, b.str_clientheadline																		--, c.str_clientheadline							       
, b.ownerid																					--, c.ownerid															       
, b.owneridtype																				--, c.owneridtype														       
, b.str_category																			--, c.str_category													       
, b.str_clientarchticstag																	--, c.str_clientarchticstag											       
, b.str_clientpremiumsalesperson															--, c.str_clientpremiumsalesperson									       
, b.str_clientpremiumserviceperson															--, c.str_clientpremiumserviceperson									       
, b.str_BearsDirectEmailList																--, c.str_BearsDirectEmailList										       
, b.str_BearsPremiumEmailList AS str_bearspremiumseatingemaillist							--, c.str_bearspremiumseatingemaillist										       
, b.str_vamosbearsemaillist																	--, c.str_vamosbearsemaillist											       
, b.str_ExclusiveBearsEventsEmailList														--, c.str_ExclusiveBearsEventsEmailList								       
, b.str_bearsinthecommunityemaillist														--, c.str_bearsinthecommunityemaillist								       
, b.str_bearsproshopemaillist																--, c.str_bearsproshopemaillist										       
, b.str_bearssurveysemaillist																--, c.str_bearssurveysemaillist										       
, b.str_singlegameticketslist																--, c.str_singlegameticketslist										       
, b.str_seasonticketslist																	--, c.str_seasonticketslist											       
, b.str_seasonprioritylist																	--, c.str_seasonprioritylist											       
, b.str_groupticketslist																	--, c.str_groupticketslist											       
, b.str_premiumseatingoptions																--, c.str_premiumseatingoptions										       
, b.new_sthtenure AS new_sthtenure_text														--, c.new_sthtenure
, b.str_clientsecondaryaccts																--,c.str_clientsecondaryaccts
, b.parentcustomerid																		--, c.parentcustomerid
, b.new_ssb_gamesmissed_nonsuites															--, c.new_ssb_gamesmissed_nonsuites
, b.new_ssb_gamesmissed_suites																--, c.new_ssb_gamesmissed_suites
, b.parentcustomeridtype																	--
, b.str_accountattribute1																	--, c.str_accountattribute1
, b.str_accountattribute10																	--, c.str_accountattribute10
, b.str_accountattribute11																	--, c.str_accountattribute11
, b.str_accountattribute12																	--, c.str_accountattribute12
, b.str_accountattribute13																	--, c.str_accountattribute13
, b.str_accountattribute14																	--, c.str_accountattribute14
, b.str_accountattribute15																	--, c.str_accountattribute15
, b.str_accountattribute16																	--, c.str_accountattribute16
, b.str_accountattribute17																	--, c.str_accountattribute17
, b.str_accountattribute18																	--, c.str_accountattribute18
, b.str_accountattribute19																	--, c.str_accountattribute19
, b.str_accountattribute2																	--, c.str_accountattribute2
, b.str_accountattribute20																	--, c.str_accountattribute20
, b.str_accountattribute3																	--, c.str_accountattribute3
, b.str_accountattribute4																	--, c.str_accountattribute4
, b.str_accountattribute5																	--, c.str_accountattribute5
, b.str_accountattribute6																	--, c.str_accountattribute6
, b.str_accountattribute7																	--, c.str_accountattribute7
, b.str_accountattribute8																	--, c.str_accountattribute8
, b.str_accountattribute9																	--, c.str_accountattribute9
, b.new_Append_ABINumber																	--, c.new_Append_ABINumber
, b.new_Append_Company																		--, c.new_Append_Company
, b.new_Append_PrimarySICCode																--, c.new_Append_PrimarySICCode
, b.new_Append_PrimarySICCodeDescription													--, c.new_Append_PrimarySICCodeDescription
, b.new_Append_SecondarySICCode																--, c.new_Append_SecondarySICCode
, b.new_Append_SecondarySICCodeDescription													--, c.new_Append_SecondarySICCodeDescription
, b.new_Append_LocationEmploymentSize														--, c.new_Append_LocationEmploymentSize
, b.new_Append_LocationSalesVolume															--, c.new_Append_LocationSalesVolume
, b.new_Append_IndividualFirmDescription													--, c.new_Append_IndividualFirmDescription
, b.new_Append_BusinessLocationType															--, c.new_Append_BusinessLocationType
, b.new_Append_BusinessCreditScore															--, c.new_Append_BusinessCreditScore
, b.new_Append_BusinessCreditScoreDescription												--, c.new_Append_BusinessCreditScoreDescription
, b.new_append_infogroupmatchpass															--, c.new_append_infogroupmatchpass
, b.new_secondarycontact																	--, c.new_secondarycontact
, b.[new_ticketsalesperson]																	--, c.[new_ticketsalesperson]

      ,CASE WHEN comp.sourcesystem = 'TM' THEN NULLIF(LTRIM(RTRIM(ISNULL(ods.street_addr_1,'') + ' ' + ISNULL(ods.street_addr_2,''))),'')		ELSE c.address2_line1					END AS			address2_line1			 --,c.address2_line1 
      ,CASE WHEN comp.sourcesystem = 'TM' THEN NULLIF(ISNULL(ods.city,''),'')																    ELSE c.address2_city					END AS			address2_city			 --,c.address2_city 
      ,CASE WHEN comp.sourcesystem = 'TM' THEN NULLIF(ISNULL(ods.state,''),'')																    ELSE c.address2_stateorprovince		END AS			address2_stateorprovince	 --,c.address2_stateorprovince 
      ,CASE WHEN comp.sourcesystem = 'TM' THEN NULLIF(ISNULL(ods.zip,''),'')																    ELSE c.address2_postalcode				END AS			address2_postalcode		 --,c.address2_postalcode 
      ,CASE WHEN comp.sourcesystem = 'TM' THEN NULLIF(ISNULL(ods.country,''),'')															    ELSE c.address2_country				END AS			address2_country			 --,c.address2_country 

, b.[new_eloquaticketrequesttimestamp]
, b.[new_eloquaticketrequesttype]

, b.[str_prioritylistcategory]
, b.str_othercategory

--,case when ISNULL(b.SSID_Winner,'') != ISNULL(c.new_ssbcrmsystemssidwinner,'')													   then 1 else 0 end as new_ssbcrmsystemssidwinner
--,case when ISNULL(b.AccountId,'') != ISNULL(c.str_number,'')																	   then 1 else 0 end as str_number
--,case when ISNULL(z.EmailPrimary,'') != ISNULL(c.emailaddress1,'')																   then 1 else 0 end as emailaddress1
--,case when ISNULL(b.new_ssbcrmsystem_RecordType,'') != ISNULL(c.new_ssbcrmsystem_RecordTypename,'')								   then 1 else 0 end as new_ssbcrmsystem_RecordTypename
--,case when ISNULL(b.new_ssbcrmsystemssidwinnersourcesystem,'') != ISNULL(c.new_ssbcrmsystemssidwinnersourcesystem,'')			   then 1 else 0 end as new_ssbcrmsystemssidwinnersourcesystem
--,case when ISNULL(b.TMSuite_Ids,'') != ISNULL(c.str_clientsuiteid,'')															   then 1 else 0 end as str_clientsuiteid
--,case when ISNULL(b.company,'') != ISNULL(c.company,'')																			   then 1 else 0 end as company
--,case when ISNULL(b.mobilephone,'') != ISNULL(c.mobilephone,'')																	   then 1 else 0 end as mobilephone
--,case when ISNULL(b.telephone2,'') != ISNULL(c.telephone2,'')																	   then 1 else 0 end as telephone2
--,case when b.ownerid != c.ownerid																								   then 1 else 0 end as ownerid
--,case when ISNULL(b.owneridtype,'') != ISNULL(c.owneridtype,'')																	   then 1 else 0 end as owneridtype
--,case when ISNULL(b.str_category,'') != ISNULL(c.str_category,'')																   then 1 else 0 end as str_category
--,case when ISNULL(b.str_clientarchticstag,'') != ISNULL(c.str_clientarchticstag,'')												   then 1 else 0 end as str_clientarchticstag
--,case when b.str_clientpremiumsalesperson != c.str_clientpremiumsalesperson														   then 1 else 0 end as str_clientpremiumsalesperson
--,case when b.str_clientpremiumserviceperson != c.str_clientpremiumserviceperson													   then 1 else 0 end as str_clientpremiumserviceperson
--,case when ISNULL(b.str_BearsDirectEmailList,'') != ISNULL(c.str_BearsDirectEmailList,'')										   then 1 else 0 end as str_BearsDirectEmailList
--,case when ISNULL(b.str_BearsPremiumEmailList,'') != ISNULL(c.str_bearspremiumseatingemaillist,'')								   then 1 else 0 end as str_bearspremiumseatingemaillist
--,case when ISNULL(b.str_vamosbearsemaillist,'') != ISNULL(c.str_vamosbearsemaillist,'')											   then 1 else 0 end as str_vamosbearsemaillist
--,case when ISNULL(b.str_ExclusiveBearsEventsEmailList,'') != ISNULL(c.str_ExclusiveBearsEventsEmailList,'')						   then 1 else 0 end as str_ExclusiveBearsEventsEmailList
--,case when ISNULL(b.str_bearsinthecommunityemaillist,'') != ISNULL(c.str_bearsinthecommunityemaillist,'')						   then 1 else 0 end as str_bearsinthecommunityemaillist
--,case when ISNULL(b.str_bearsproshopemaillist,'') != ISNULL(c.str_bearsproshopemaillist,'')										   then 1 else 0 end as str_bearsproshopemaillist
--,case when ISNULL(b.str_bearssurveysemaillist,'') != ISNULL(c.str_bearssurveysemaillist,'')										   then 1 else 0 end as str_bearssurveysemaillist
--,case when ISNULL(b.str_singlegameticketslist,'') != ISNULL(c.str_singlegameticketslist,'')										   then 1 else 0 end as str_singlegameticketslist
--,case when ISNULL(b.str_seasonticketslist,'') != ISNULL(c.str_seasonticketslist,'')												   then 1 else 0 end as str_seasonticketslist
--,case when ISNULL(b.str_seasonprioritylist,'') != ISNULL(c.str_seasonprioritylist,'')											   then 1 else 0 end as str_seasonprioritylist
--,case when ISNULL(b.str_groupticketslist,'') != ISNULL(c.str_groupticketslist,'')												   then 1 else 0 end as str_groupticketslist
--,case when ISNULL(b.str_premiumseatingoptions,'') != ISNULL(c.str_premiumseatingoptions,'')										   then 1 else 0 end as str_premiumseatingoptions
--,case when ISNULL(b.new_sthtenure,'') != ISNULL(c.new_sthtenure_text,'')														   then 1 else 0 end as new_sthtenure_text
--,case when ISNULL(b.str_clientsecondaryaccts,'') != ISNULL(c.str_clientsecondaryaccts,'')										   then 1 else 0 end as str_clientsecondaryaccts
--,case when b.parentcustomerid != c.parentcustomerid																				   then 1 else 0 end as parentcustomerid
--,case when (b.parentcustomerid IS NOT NULL AND c.parentcustomerid IS NULL)														   then 1 else 0 end as parentcustomerid
--,case when ISNULL(b.new_ssb_gamesmissed_nonsuites,'') != ISNULL(c.new_ssb_gamesmissed_nonsuites,'')								   then 1 else 0 end as new_ssb_gamesmissed_nonsuites
--,case when ISNULL(b.new_ssb_gamesmissed_suites,'') != ISNULL(c.new_ssb_gamesmissed_suites,'')									   then 1 else 0 end as new_ssb_gamesmissed_suites
--,case when  ISNULL(b.str_accountattribute1,'') != ISNULL(c.str_accountattribute1, '')											   then 1 else 0 end as str_accountattribute1
--,case when  ISNULL(b.str_accountattribute10,'') != ISNULL(c.str_accountattribute10, '')											   then 1 else 0 end as str_accountattribute10
--,case when  ISNULL(b.str_accountattribute11,'') != ISNULL(c.str_accountattribute11, '')											   then 1 else 0 end as str_accountattribute11
--,case when  ISNULL(b.str_accountattribute12,'') != ISNULL(c.str_accountattribute12, '')											   then 1 else 0 end as str_accountattribute12
--,case when  ISNULL(b.str_accountattribute13,'') != ISNULL(c.str_accountattribute13, '')											   then 1 else 0 end as str_accountattribute13
--,case when  ISNULL(b.str_accountattribute14,'') != ISNULL(c.str_accountattribute14, '')											   then 1 else 0 end as str_accountattribute14
--,case when  ISNULL(b.str_accountattribute15,'') != ISNULL(c.str_accountattribute15, '')											   then 1 else 0 end as str_accountattribute15
--,case when  ISNULL(b.str_accountattribute16,'') != ISNULL(c.str_accountattribute16, '')											   then 1 else 0 end as str_accountattribute16
--,case when  ISNULL(b.str_accountattribute17,'') != ISNULL(c.str_accountattribute17, '')											   then 1 else 0 end as str_accountattribute17
--,case when  ISNULL(b.str_accountattribute18,'') != ISNULL(c.str_accountattribute18, '')											   then 1 else 0 end as str_accountattribute18
--,case when  ISNULL(b.str_accountattribute19,'') != ISNULL(c.str_accountattribute19, '')											   then 1 else 0 end as str_accountattribute19
--,case when  ISNULL(b.str_accountattribute2,'') != ISNULL(c.str_accountattribute2, '')											   then 1 else 0 end as str_accountattribute2
--,case when  ISNULL(b.str_accountattribute20,'') != ISNULL(c.str_accountattribute20, '')											   then 1 else 0 end as str_accountattribute20
--,case when  ISNULL(b.str_accountattribute3,'') != ISNULL(c.str_accountattribute3, '')											   then 1 else 0 end as str_accountattribute3
--,case when  ISNULL(b.str_accountattribute4,'') != ISNULL(c.str_accountattribute4, '')											   then 1 else 0 end as str_accountattribute4
--,case when  ISNULL(b.str_accountattribute5,'') != ISNULL(c.str_accountattribute5, '')											   then 1 else 0 end as str_accountattribute5
--,case when  ISNULL(b.str_accountattribute6,'') != ISNULL(c.str_accountattribute6, '')											   then 1 else 0 end as str_accountattribute6
--,case when  ISNULL(b.str_accountattribute7,'') != ISNULL(c.str_accountattribute7, '')											   then 1 else 0 end as str_accountattribute7
--,case when  ISNULL(b.str_accountattribute8,'') != ISNULL(c.str_accountattribute8, '')											   then 1 else 0 end as str_accountattribute8
--,case when  ISNULL(b.str_accountattribute9,'') != ISNULL(c.str_accountattribute9, '')											   then 1 else 0 end as str_accountattribute9
--,case when  ISNULL(b.new_Append_ABINumber,'') != ISNULL(c.new_Append_ABINumber, '')												   then 1 else 0 end as new_Append_ABINumber
--,case when  ISNULL(b.new_Append_Company,'') != ISNULL(c.new_Append_Company, '')													   then 1 else 0 end as new_Append_Company
--,case when  ISNULL(b.new_Append_PrimarySICCode,'') != ISNULL(c.new_Append_PrimarySICCode, '')									   then 1 else 0 end as new_Append_PrimarySICCode
--,case when  ISNULL(b.new_Append_PrimarySICCodeDescription,'') != ISNULL(c.new_Append_PrimarySICCodeDescription, '')				   then 1 else 0 end as new_Append_PrimarySICCodeDescription
--,case when  ISNULL(b.new_Append_SecondarySICCode,'') != ISNULL(c.new_Append_SecondarySICCode, '')								   then 1 else 0 end as new_Append_SecondarySICCode
--,case when  ISNULL(b.new_Append_SecondarySICCodeDescription,'') != ISNULL(c.new_Append_SecondarySICCodeDescription, '')			   then 1 else 0 end as new_Append_SecondarySICCodeDescription
--,case when  ISNULL(b.new_Append_LocationEmploymentSize,'') != ISNULL(c.new_Append_LocationEmploymentSize, '')					   then 1 else 0 end as new_Append_LocationEmploymentSize
--,case when  ISNULL(b.new_Append_LocationSalesVolume,'') != ISNULL(c.new_Append_LocationSalesVolume, '')							   then 1 else 0 end as new_Append_LocationSalesVolume
--,case when  ISNULL(b.new_Append_IndividualFirmDescription,'') != ISNULL(c.new_Append_IndividualFirmDescription, '')				   then 1 else 0 end as new_Append_IndividualFirmDescription
--,case when  ISNULL(b.new_Append_BusinessLocationType,'') != ISNULL(c.new_Append_BusinessLocationType, '')						   then 1 else 0 end as new_Append_BusinessLocationType
--,case when  ISNULL(b.new_Append_BusinessCreditScore,'') != ISNULL(c.new_Append_BusinessCreditScore, '')							   then 1 else 0 end as new_Append_BusinessCreditScore
--,case when  ISNULL(b.new_Append_BusinessCreditScoreDescription,'') != ISNULL(c.new_Append_BusinessCreditScoreDescription, '')	   then 1 else 0 end as new_Append_BusinessCreditScoreDescription
--,case when  ISNULL(b.new_append_infogroupmatchpass,'') != ISNULL(c.new_append_infogroupmatchpass, '')							   then 1 else 0 end as new_append_infogroupmatchpass
--,case when  ISNULL(b.new_secondarycontact,'') != ISNULL(c.new_secondarycontact, '')												then 1 else 0 end as new_secondarycontact
--,case when  ISNULL(b.[new_ticketsalesperson],'') != ISNULL(c.[new_ticketsalesperson], '')												then 1 else 0 end as [new_ticketsalesperson]
--, case when ISNULL(b.str_othercategory,'') != ISNULL(c.str_othercategory, '')														  then 1 else 0 end as str_othercategory
--, case when ISNULL(b.str_prioritylistcategory,'') != ISNULL(b.str_prioritylistcategory, '')										  then 1 else 0 end as str_prioritylistcategory

-- SELECT *
-- SELECT COUNT(*) 
FROM dbo.[Contact_Custom] b 
INNER JOIN dbo.Contact z ON b.SSB_CRMSYSTEM_CONTACT_ID = z.[SSB_CRMSYSTEM_CONTACT_ID]
LEFT JOIN  prodcopy.vw_contact c ON z.[crm_id] = c.contactID
--INNER JOIN dbo.CRMLoad_Contact_ProcessLoad_Criteria pl ON b.SSB_CRMSYSTEM_CONTACT_ID = pl.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN dbo.vwCompositeRecord_ModAcctID comp ON z.SSB_CRMSYSTEM_CONTACT_ID = comp.SSB_CRMSYSTEM_CONTACT_ID
LEFT JOIN bears.ods.TM_Cust ods ON CAST(ods.acct_id AS NVARCHAR(100)) + ':' + CAST(ods.cust_name_id AS NVARCHAR(100)) = comp.SSID AND comp.SourceSystem = 'tm'
WHERE z.[SSB_CRMSYSTEM_CONTACT_ID] <> z.[crm_id]

AND ( 1=2
OR ISNULL(b.SSID_Winner,'') != ISNULL(c.new_ssbcrmsystemssidwinner,'')
OR ISNULL(b.AccountId,'') != ISNULL(c.str_number,'')
OR ISNULL(z.EmailPrimary,'') != ISNULL(c.emailaddress1,'')
OR ISNULL(b.new_ssbcrmsystem_RecordType,'') != ISNULL(c.new_ssbcrmsystem_RecordTypename,'')
OR ISNULL(b.new_ssbcrmsystemssidwinnersourcesystem,'') != ISNULL(c.new_ssbcrmsystemssidwinnersourcesystem,'')
OR ISNULL(b.TMSuite_Ids,'') != ISNULL(c.str_clientsuiteid,'')
OR ISNULL(b.company,'') != ISNULL(c.company,'')
OR ISNULL(b.mobilephone,'') != ISNULL(c.mobilephone,'')
OR ISNULL(b.telephone2,'') != ISNULL(c.telephone2,'')
OR b.ownerid != c.ownerid
OR ISNULL(b.owneridtype,'') != ISNULL(c.owneridtype,'')
OR ISNULL(b.str_category,'') != ISNULL(c.str_category,'')
OR ISNULL(b.str_clientarchticstag,'') != ISNULL(c.str_clientarchticstag,'')
OR b.str_clientpremiumsalesperson != c.str_clientpremiumsalesperson
OR b.str_clientpremiumserviceperson != c.str_clientpremiumserviceperson
OR ISNULL(b.str_BearsDirectEmailList,'') != ISNULL(c.str_BearsDirectEmailList,'')
OR ISNULL(b.str_BearsPremiumEmailList,'') != ISNULL(c.str_bearspremiumseatingemaillist,'')
OR ISNULL(b.str_vamosbearsemaillist,'') != ISNULL(c.str_vamosbearsemaillist,'')
OR ISNULL(b.str_ExclusiveBearsEventsEmailList,'') != ISNULL(c.str_ExclusiveBearsEventsEmailList,'')
OR ISNULL(b.str_bearsinthecommunityemaillist,'') != ISNULL(c.str_bearsinthecommunityemaillist,'')
OR ISNULL(b.str_bearsproshopemaillist,'') != ISNULL(c.str_bearsproshopemaillist,'')
OR ISNULL(b.str_bearssurveysemaillist,'') != ISNULL(c.str_bearssurveysemaillist,'')
OR ISNULL(b.str_singlegameticketslist,'') != ISNULL(c.str_singlegameticketslist,'')
OR ISNULL(b.str_seasonticketslist,'') != ISNULL(c.str_seasonticketslist,'')
OR ISNULL(b.str_seasonprioritylist,'') != ISNULL(c.str_seasonprioritylist,'')
OR ISNULL(b.str_groupticketslist,'') != ISNULL(c.str_groupticketslist,'')
OR ISNULL(b.str_premiumseatingoptions,'') != ISNULL(c.str_premiumseatingoptions,'')
--OR ISNULL(b.new_sthtenure,'') != ISNULL(c.new_sthtenure_text,'')
OR ISNULL(b.str_clientsecondaryaccts,'') != ISNULL(c.str_clientsecondaryaccts,'')
OR b.parentcustomerid != c.parentcustomerid
OR (b.parentcustomerid IS NOT NULL AND c.parentcustomerid IS NULL)
OR ISNULL(b.new_ssb_gamesmissed_nonsuites,'') != ISNULL(c.new_ssb_gamesmissed_nonsuites,'')
OR ISNULL(b.new_ssb_gamesmissed_suites,'') != ISNULL(c.new_ssb_gamesmissed_suites,'')
 OR ISNULL(b.str_accountattribute1,'') != ISNULL(c.str_accountattribute1, '')
 OR ISNULL(b.str_accountattribute10,'') != ISNULL(c.str_accountattribute10, '')
 OR ISNULL(b.str_accountattribute11,'') != ISNULL(c.str_accountattribute11, '')
 OR ISNULL(b.str_accountattribute12,'') != ISNULL(c.str_accountattribute12, '')
 OR ISNULL(b.str_accountattribute13,'') != ISNULL(c.str_accountattribute13, '')
 OR ISNULL(b.str_accountattribute14,'') != ISNULL(c.str_accountattribute14, '')
 OR ISNULL(b.str_accountattribute15,'') != ISNULL(c.str_accountattribute15, '')
 OR ISNULL(b.str_accountattribute16,'') != ISNULL(c.str_accountattribute16, '')
 OR ISNULL(b.str_accountattribute17,'') != ISNULL(c.str_accountattribute17, '')
 OR ISNULL(b.str_accountattribute18,'') != ISNULL(c.str_accountattribute18, '')
 OR ISNULL(b.str_accountattribute19,'') != ISNULL(c.str_accountattribute19, '')
 OR ISNULL(b.str_accountattribute2,'') != ISNULL(c.str_accountattribute2, '')
 OR ISNULL(b.str_accountattribute20,'') != ISNULL(c.str_accountattribute20, '')
 OR ISNULL(b.str_accountattribute3,'') != ISNULL(c.str_accountattribute3, '')
 OR ISNULL(b.str_accountattribute4,'') != ISNULL(c.str_accountattribute4, '')
 OR ISNULL(b.str_accountattribute5,'') != ISNULL(c.str_accountattribute5, '')
 OR ISNULL(b.str_accountattribute6,'') != ISNULL(c.str_accountattribute6, '')
 OR ISNULL(b.str_accountattribute7,'') != ISNULL(c.str_accountattribute7, '')
 OR ISNULL(b.str_accountattribute8,'') != ISNULL(c.str_accountattribute8, '')
 OR ISNULL(b.str_accountattribute9,'') != ISNULL(c.str_accountattribute9, '')
 OR ISNULL(b.new_Append_ABINumber,'') != ISNULL(c.new_Append_ABINumber, '')						
 OR ISNULL(b.new_Append_Company,'') != ISNULL(c.new_Append_Company, '')							
 OR ISNULL(b.new_Append_PrimarySICCode,'') != ISNULL(c.new_Append_PrimarySICCode, '')					
 OR ISNULL(b.new_Append_PrimarySICCodeDescription,'') != ISNULL(c.new_Append_PrimarySICCodeDescription, '')		
 OR ISNULL(b.new_Append_SecondarySICCode,'') != ISNULL(c.new_Append_SecondarySICCode, '')					
 OR ISNULL(b.new_Append_SecondarySICCodeDescription,'') != ISNULL(c.new_Append_SecondarySICCodeDescription, '')		
 OR ISNULL(b.new_Append_LocationEmploymentSize,'') != ISNULL(c.new_Append_LocationEmploymentSize, '')			
 OR ISNULL(b.new_Append_LocationSalesVolume,'') != ISNULL(c.new_Append_LocationSalesVolume, '')				
 OR ISNULL(b.new_Append_IndividualFirmDescription,'') != ISNULL(c.new_Append_IndividualFirmDescription, '')		
 OR ISNULL(b.new_Append_BusinessLocationType,'') != ISNULL(c.new_Append_BusinessLocationType, '')				
 OR ISNULL(b.new_Append_BusinessCreditScore,'') != ISNULL(c.new_Append_BusinessCreditScore, '')				
 OR ISNULL(b.new_Append_BusinessCreditScoreDescription,'') != ISNULL(c.new_Append_BusinessCreditScoreDescription, '')	
 OR ISNULL(b.new_append_infogroupmatchpass,'') != ISNULL(c.new_append_infogroupmatchpass, '')	
 OR ISNULL(b.new_secondarycontact,'') != ISNULL(c.new_secondarycontact, '')				
 OR ISNULL(b.str_othercategory,'') != ISNULL(c.str_othercategory, '')
 OR ISNULL(b.str_prioritylistcategory,'') != ISNULL(b.str_prioritylistcategory, '')
 OR 
	(comp.SourceSystem = 'tm' AND (1=2
		OR       ISNULL(LTRIM(RTRIM(ISNULL(ods.street_addr_1,'') + ' ' + ISNULL(ods.street_addr_2,''))),'')		!=		ISNULL(address2_line1,'')			
		OR		 ISNULL(ISNULL(ods.city,''),'')																    !=		ISNULL(address2_city,'')			
		OR		 ISNULL(ISNULL(ods.state,''),'')																!=		ISNULL(address2_stateorprovince,'') 
		OR		 ISNULL(ISNULL(ods.zip,''),'')																    !=		ISNULL(address2_postalcode,'')		
		OR		 ISNULL(ISNULL(ods.country,''),'')															    !=		ISNULL(address2_country,'')		   
																													
		))

		OR  ISNULL(b.[new_eloquaticketrequesttimestamp],'') != ISNULL(c.[new_eloquaticketrequesttimestamp],'')
		OR  ISNULL(b.[new_eloquaticketrequesttype],'') != ISNULL(c.[new_eloquaticketrequesttype],'')
		OR ISNULL(CAST(b.[new_ticketsalesperson] AS NVARCHAR(100)),'') != ISNULL(CAST(c.[new_ticketsalesperson] AS NVARCHAR(100)), '')

)
















GO
