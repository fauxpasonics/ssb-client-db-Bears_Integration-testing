SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************
Created By: Caeleon Work
Created On: 
Updated By: Stephanie Gerber
Update Date: 2018-06-06
Update Notes: Added TM Birthdate and Due Amount 
Reviewed By:
Review Date:
Review Notes:
**************************************************/


CREATE   PROCEDURE [wrk].[sp_Contact_Custom]
AS 

MERGE INTO dbo.Contact_Custom Target
USING dbo.Contact source
ON source.[SSB_CRMSYSTEM_CONTACT_ID] = target.[SSB_CRMSYSTEM_CONTACT_ID]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID]) VALUES (source.[SSB_CRMSYSTEM_ACCT_ID], Source.[SSB_CRMSYSTEM_CONTACT_ID])
WHEN NOT MATCHED BY SOURCE THEN
DELETE ;

EXEC dbo.sp_CRMProcess_ConcatIDs 'Contact'

UPDATE a
SET SSID_Winner = b.[SSID]
, new_ssbcrmsystemssidwinnersourcesystem = b.SourceSystem
, company = LEFT(b.CompanyName,50)
, mobilephone = b.PhoneCell
, telephone2 = b.PhoneHome
FROM [dbo].Contact_Custom a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]



/*
===========================================
Record Type
===========================================
*/
--Start out with what is in CRM
UPDATE a
SET new_ssbcrmsystem_RecordType = pcc.new_ssbcrmsystem_recordtypename
--select count(*)
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'CRM_Contact'
INNER JOIN Bears_Reporting.prodcopy.contact pcc ON pcc.contactid = b.SSID
WHERE pcc.new_ssbcrmsystem_recordtypename IS NOT NULL

--Apply Sponsorship Tag
UPDATE a
SET new_ssbcrmsystem_RecordType = 'Sponsorship/Premium'
--select count(*)
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'CRM_Contact'
INNER JOIN prodcopy.vw_contact pcc ON b.ssid = pcc.contactid
INNER JOIN bears_reporting.prodcopy.TeamMembership pctm ON pctm.systemuserid = pcc.createdby
INNER JOIN bears_reporting.prodcopy.team pct ON pct.teamid = pctm.teamid
WHERE pct.name IN ('Premium', 'Partnership')
--AND pcc.createdon > GETDATE()-10 --remove after first run

--Apply tag for Suites
UPDATE a
SET new_ssbcrmsystem_RecordType = 'Sponsorship/Premium'
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId dc ON dc.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND dc.SourceSystem = 'TM-Suites'
INNER JOIN Bears.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId AND dc.SourceSystem = 'TM-Suites' AND fts.SourceSystem = 'TM-Suites'

--Overwrite with Ticketing if needed, from CRM creator
UPDATE a
SET new_ssbcrmsystem_RecordType = 'Ticketing'
--select count(*)
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'CRM_Contact'
INNER JOIN prodcopy.vw_contact pcc ON b.ssid = pcc.contactid
INNER JOIN bears_reporting.prodcopy.TeamMembership pctm ON pctm.systemuserid = pcc.createdby
INNER JOIN bears_reporting.prodcopy.team pct ON pct.teamid = pctm.teamid
WHERE pct.name IN ('Ticketing')
--AND pcc.createdon > GETDATE()-10 --remove after first run

--Overwrite with Ticketing if needed, from TM
UPDATE a
SET new_ssbcrmsystem_RecordType = 'Ticketing'
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId dc ON dc.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND dc.SourceSystem = 'tm'
INNER JOIN Bears.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId AND dc.SourceSystem = 'TM' AND fts.SourceSystem = 'TM'

UPDATE a
SET new_ssbcrmsystem_RecordType = 'Ticketing'
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId dc ON dc.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND dc.SourceSystem = 'tm'
INNER JOIN bears.etl.TM_ActiveAccountList TMAL ON TMAL.acct_id = dc.AccountId
WHERE sourcetable = 'RawFile__bear2015FULLTKTF'
OR sourcetable = 'RawFile__bear2016FULLTKTF'

--Update Eloqua to Ticketing where recordtype is still null
UPDATE a 
SET a.new_ssbcrmsystem_RecordType = 'Ticketing'
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'Eloqua'
LEFT JOIN dbo.vwDimCustomer_ModAcctId c ON c.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND c.SourceSystem = 'CRM_Contact'
LEFT JOIN prodcopy.vw_contact pcc ON CAST(pcc.contactid AS NVARCHAR(100)) =  CAST(c.SSID AS NVARCHAR(100))
WHERE pcc.new_ssbcrmsystem_recordtypename IS NULL

--Update TM-Suites (Non-Purchaser) to Sponsorship/Premium where recordtype is still null
UPDATE a 
SET a.new_ssbcrmsystem_RecordType = 'Sponsorship/Premium'
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'TM-Suites'
LEFT JOIN dbo.vwDimCustomer_ModAcctId c ON c.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND c.SourceSystem = 'CRM_Contact'
LEFT JOIN prodcopy.vw_contact pcc ON CAST(pcc.contactid AS NVARCHAR(100)) =  CAST(c.SSID AS NVARCHAR(100))
WHERE pcc.new_ssbcrmsystem_recordtypename IS NULL

--Update TM (Non-Purchaser) to Ticketing where recordtype is still null
UPDATE a 
SET a.new_ssbcrmsystem_RecordType = 'Ticketing'
FROM dbo.Contact_Custom a
INNER JOIN dbo.vwDimCustomer_ModAcctId b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'TM'
LEFT JOIN dbo.vwDimCustomer_ModAcctId c ON c.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND c.SourceSystem = 'CRM_Contact'
LEFT JOIN prodcopy.vw_contact pcc ON CAST(pcc.contactid AS NVARCHAR(100)) =  CAST(c.SSID AS NVARCHAR(100))
WHERE pcc.new_ssbcrmsystem_recordtypename IS NULL

--update dbo.contact_custom set new_ssbcrmsystem_RecordType = 'Ticketing' where new_ssbcrmsystem_RecordType is null




/*
===========================================
Alert Field
===========================================
*/
UPDATE contact_custom SET str_clientheadline = NULL

SELECT DISTINCT acct_id, alert_name 
INTO #tempnote
FROM bears.ods.TM_Note



UPDATE c SET str_clientheadline = f.ConcatIDs1
FROM (
SELECT n.SSB_CRMSYSTEM_CONTACT_ID
,ISNULL(LEFT(STUFF((    SELECT  ' | ' + alert_name  AS [text()]
FROM #tempnote TM
WHERE tm.alert_name IS NOT NULL AND tm.acct_id = n.acct_id
ORDER BY alert_name
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs1
--INTO #tempalert
FROM (SELECT acct_id, ssb.SSB_CRMSYSTEM_CONTACT_ID FROM bears.ods.TM_Note n INNER JOIN dimcustomer dc ON n.acct_id = dc.AccountId AND dc.SourceSystem = 'tm' INNER JOIN dbo.DimCustomerssbid ssb ON dc.DimCustomerId = ssb.DimCustomerId WHERE alert_name IS NOT NULL) n
INNER JOIN dbo.Contact_Custom cc ON cc.SSB_CRMSYSTEM_CONTACT_ID = n.SSB_CRMSYSTEM_CONTACT_ID) f 
INNER JOIN dbo.Contact_Custom c ON c.SSB_CRMSYSTEM_CONTACT_ID = f.SSB_CRMSYSTEM_CONTACT_ID

DROP TABLE #tempnote;



/*
===========================================
Tag Field
===========================================
*/

SELECT DISTINCT acct_id, tag 
INTO #tempcust
FROM bears.ods.TM_cust

UPDATE c SET str_clientarchticstag = f.ConcatIDs1
FROM (
SELECT n.SSB_CRMSYSTEM_CONTACT_ID
,ISNULL(LEFT(STUFF((    SELECT  ' | ' + tag  AS [text()]
FROM #tempcust TM
WHERE tm.tag IS NOT NULL AND tm.acct_id = n.acct_id
ORDER BY tag
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs1
--INTO #tempalert
FROM (SELECT acct_id, ssb.SSB_CRMSYSTEM_CONTACT_ID FROM bears.ods.TM_cust n INNER JOIN dimcustomer dc ON n.acct_id = dc.AccountId AND dc.SourceSystem = 'tm' INNER JOIN dbo.DimCustomerssbid ssb ON dc.DimCustomerId = ssb.DimCustomerId WHERE tag IS NOT NULL) n
INNER JOIN dbo.Contact_Custom cc ON cc.SSB_CRMSYSTEM_CONTACT_ID = n.SSB_CRMSYSTEM_CONTACT_ID) f 
INNER JOIN dbo.Contact_Custom c ON c.SSB_CRMSYSTEM_CONTACT_ID = f.SSB_CRMSYSTEM_CONTACT_ID

DROP TABLE #tempcust;


/*
===========================================
Ownership / Salesperson / Service Person
===========================================
*/
-- Update with STR baseline
UPDATE a
SET ownerid = '7AB94FAE-D380-E611-80DF-C4346BAC69F4',  a.owneridtype  = 'systemuser'
FROM dbo.Contact_Custom a


--Update based on TM
UPDATE a
SET OwnerID = CASE WHEN su.systemuserid IS NOT NULL THEN su.systemuserid WHEN b.sourcesystem = 'TM' THEN '84CB51D1-1C8C-E711-8123-E0071B72B771' ELSE '84CB51D1-1C8C-E711-8123-E0071B72B771' end
--SELECT b.accountrep, su.fullname, b.SourceSystem, a.ownerid, su.systemuserid, us.fullname, c.crm_id, c.SSB_CRMSYSTEM_CONTACT_ID
FROM [dbo].Contact_Custom a
INNER JOIN dbo.contact c ON c.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'TM'
left JOIN bears.ods.TM_Cust tmcr ON b.accountid = tmcr.acct_id
left JOIN Bears_Reporting.prodcopy.SystemUser su ON tmcr.acct_rep_name = su.fullname AND su.fullname IS NOT NULL  AND su.isdisabled = 0
LEFT JOIN  Bears_Reporting.prodcopy.SystemUser us ON us.systemuserid = a.ownerid


--Premium Sales Person
--CRM Baseline
UPDATE a
SET str_clientpremiumsalesperson = pcc.str_clientpremiumsalesperson
FROM dbo.Contact_Custom a
INNER JOIN dbo.contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.vw_Contact pcc
ON pcc.contactid = c.crm_id
WHERE pcc.str_clientpremiumsalesperson IS NOT null

--Based on TM
UPDATE a
SET str_clientpremiumsalesperson = su.systemuserid
--SELECT b.accountrep, su.fullname, b.SourceSystem, a.str_clientpremiumsalesperson
FROM [dbo].Contact_Custom a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID] AND b.SourceSystem = 'TM-Suites'
INNER JOIN bears_suites.ods.TM_CustRep tmcr ON b.accountid = tmcr.acct_id
INNER JOIN Bears_Reporting.prodcopy.SystemUser su ON tmcr.rep_full_name = su.fullname AND su.fullname IS NOT NULL AND tmcr.acct_rep_type_name = 'Sales' AND su.isdisabled = 0


-- Premium Service Person
--CRM Baseline
--UPDATE a
--SET str_clientpremiumserviceperson = pcc.str_clientpremiumserviceperson
--FROM dbo.Contact_Custom a
--INNER JOIN dbo.contact c
--ON c.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID
--INNER JOIN Prodcopy.vw_Contact pcc
--ON pcc.contactid = c.crm_id
--WHERE pcc.str_clientpremiumserviceperson IS NOT null


--Based on TM


/*
===========================================
Secondary TM Accounts
===========================================
*/


UPDATE contact_custom 
SET str_clientsecondaryaccts = ConcatIDs1

FROM 
contact_custom cc INNER JOIN 
(
SELECT [GUID]
,LTRIM(ISNULL(LEFT(STUFF((    SELECT  ', ' + name_first + ' ' + name_last  AS [text()]
FROM (
SELECT DISTINCT cc.SSB_CRMSYSTEM_CONTACT_ID AS [GUID], secondaries.FirstName name_first, secondaries.LastName name_last
		FROM contact_custom cc INNER JOIN dbo.vwDimCustomer_ModAcctId mai 
		ON mai.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID AND mai.sourcesystem = 'tm'
		INNER JOIN dbo.vwDimCustomer_ModAcctId secondaries
		ON mai.accountid = secondaries.accountid 
		AND secondaries.sourcesystem = 'tm'
		AND mai.dimcustomerid != secondaries.dimcustomerid 
		AND mai.firstname + mai.lastname != secondaries.firstname + secondaries.lastname 
		WHERE mai.CustomerType IN ('Primary') AND mai.SSB_CRMSYSTEM_PRIMARY_FLAG = 1 AND ISNULL(secondaries.firstname,'') + ISNULL(secondaries.lastname,'') != ''
) TM
WHERE TM.[GUID] = z.[GUID] 
ORDER BY name_first
FOR XML PATH('')), 1, 1, ''),8000),'')) AS ConcatIDs1

FROM (SELECT DISTINCT GUID FROM [stg].tbl_CRMProcess_NonWinners
) z
) query ON query.[GUID] = cc.SSB_CRMSYSTEM_CONTACT_ID




/*
===========================================
STR Category
===========================================
*/

IF OBJECT_ID('tempdb..#categoryTemp') IS NOT NULL
	DROP TABLE #categoryTemp
SELECT ma.SSB_CRMSYSTEM_CONTACT_ID, fts.SSID_acct_id, de.EventCode, dpc.PC1, dpc.PC2, dpc.PC3, dpc.PC4,  CASE WHEN ((ISNULL(dpc.PC2,'') = ''
OR		(ISNULL(dpc.PC2,'') LIKE '[0-9]' AND ISNULL(dpc.PC3,'')='' )
OR		(ISNULL(dpc.PC2,'') IN ('I','O','W') AND ISNULL(dpc.PC3,'')='')
OR		(ISNULL(dpc.PC3,'') IN ('I','O','W') AND ISNULL(dpc.PC4,'')='')))
AND de.EventCode != 'WLDEP' THEN
            'STH'
        ELSE
            NULL
    END AS STH,
    CASE
        WHEN
((ISNULL(dpc.PC2,'') <> '' AND ISNULL(dpc.PC2,'') NOT IN ('I','O','W') AND ISNULL(dpc.pc2,'') NOT LIKE '[0-9]')
OR		(ISNULL(dpc.PC2,'') LIKE '[0-9]' AND ISNULL(dpc.PC3,'')<>'' )AND ISNULL( dpc.PC3, '' ) NOT IN ( 'I', 'O', 'W' ))  
          THEN
            'SGB'
        ELSE
            NULL
    END AS SGB,
    CASE
        WHEN de.EventCode = 'WLDEP' THEN
            'STHPL'
        ELSE
            NULL
    END AS STHPL
INTO #categoryTemp
FROM bears.dbo.FactTicketSales fts (NOLOCK)
JOIN bears.dbo.DimPriceCode dpc ON dpc.DimPriceCodeId = fts.DimPriceCodeId
JOIN bears.dbo.DimEvent de ON de.DimEventId = fts.DimEventId
INNER JOIN dbo.vwDimCustomer_ModAcctId ma ON ma.accountid = fts.SSID_acct_id AND ma.SourceSystem = 'TM' AND ma.SSB_CRMSYSTEM_CONTACT_ID IS NOT null
ORDER BY 1
--Determine the fallout
--SELECT pc1, pc2, pc3, pc4, COUNT(*) FROM #categoryTemp WHERE sth IS NULL AND sgb IS NULL AND STHPL IS NULL GROUP BY pc1, pc2, pc3, PC4 ORDER BY 4 DESC



SELECT ssb_crmsystem_contact_id,
CASE WHEN ISNULL(MAX(STH),'') != '' THEN 'STH'
WHEN  ISNULL(MAX(STHPL),'') != '' THEN 'STHPL'
WHEN ISNULL(MAX(SGB),'')  != ''THEN 'SGB'
ELSE NULL END AS str_category
INTO #finalprep
FROM #categoryTemp
GROUP BY SSB_CRMSYSTEM_CONTACT_ID

UPDATE cc
SET str_category = fp.str_category
--SELECT cc.SSB_CRMSYSTEM_CONTACT_ID, fp.str_category
FROM contact_custom cc left JOIN #finalprep fp ON fp.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID

--DROP TABLE #categoryTemp -- Need for SinceDate, don't drop
DROP TABLE #finalprep

/*
===========================================
TENURE - Must be below STH flag/str_category
===========================================
*/
SELECT cc.SSB_CRMSYSTEM_CONTACT_ID, MIN(YEAR(tm.Since_date)) AS Tenure
into #tenure
FROM dbo.Contact_Custom cc
INNER JOIN dbo.vwDimCustomer_ModAcctId dc ON dc.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID AND dc.SourceSystem = 'tm'
INNER JOIN bears.ods.TM_Cust tm ON CAST(tm.acct_id AS NVARCHAR(100)) + ':' + CAST(tm.cust_name_id AS NVARCHAR(100)) = CAST(dc.SSID AS NVARCHAR(100))
INNER JOIN #categoryTemp ct ON ct.SSID_acct_id = tm.acct_id
WHERE YEAR(tm.Since_date) > 1910 AND tm.Since_date IS NOT NULL AND ct.STH ='STH'
GROUP BY cc.ssb_crmsystem_contact_id



UPDATE CC
SET new_sthtenure = CASE WHEN cc.str_category = 'STH' THEN Tenure ELSE NULL END 
FROM dbo.Contact_Custom cc
left JOIN #tenure t ON t.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
DROP TABLE #tenure

DROP TABLE #categoryTemp 

/*=============================
Games Missed - Non Suites
===============================*/


SELECT a.ssb_crmsystem_contact_id, SUM(a.GamesMissed) AS MissedGames
INTO #MissedGames
FROM (
SELECT ma.SSB_CRMSYSTEM_CONTACT_ID, e.EventDate, e.EventName, CASE WHEN SUM(CAST(fi.IsAttended AS INT)) = 0 THEN 1  WHEN SUM(CAST(fi.IsAttended AS INT)) > 0 THEN 0 ELSE 0 END AS GamesMissed 
FROM contact_custom cc
inner JOIN dbo.vwDimCustomer_ModAcctId ma 
ON ma.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID AND ma.SourceSystem = 'tm'
INNER JOIN bears.dbo.factticketsales fts
ON SUBSTRING(ma.SSID,1,CHARINDEX(':',ma.SSID,1)-1) = fts.SSID_acct_id
INNER JOIN bears.dbo.FactInventory fi 
ON fi.FactTicketSalesId = fts.FactTicketSalesId
INNER JOIN bears.dbo.DimEvent e 
ON e.DimEventId = fi.DimEventId
INNER JOIN bears.dbo.DimSeason s 
ON e.DimSeasonId = s.DimSeasonId AND s.dimarenaid = 7 AND s.seasonname NOT LIKE '%Test%' 
WHERE s.SeasonYear = CASE WHEN MONTH(GETDATE()) IN (4,5,6,7,8,9,10,11,12) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()) - 1 END
AND e.EventDate < GETDATE()
AND cc.str_category = 'STH'
 and e.eventdesc not like '%Preseason' --Gets rid of Preseason games
-- and e.isinventoryeligible = 1  --Gets rid of the Meijer Family Night
GROUP BY ma.SSB_CRMSYSTEM_CONTACT_ID, e.EventDate, e.EventName
--ORDER BY 1,2
) a
GROUP BY a.SSB_CRMSYSTEM_CONTACT_ID

UPDATE cc SET new_ssb_gamesmissed_nonsuites = MissedGames
FROM contact_custom cc
INNER JOIN #MissedGames mg 
ON mg.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID


DROP TABLE #MissedGames




/*=============================
Games Missed - Non Suites
===============================*/


SELECT ma.SSB_CRMSYSTEM_CONTACT_ID,
       e.EventDate,
       e.EventName,
       CASE
           WHEN SUM(CAST(fi.IsAttended AS INT)) = 0 THEN
               1
           WHEN SUM(CAST(fi.IsAttended AS INT)) > 0 THEN
               0
           ELSE
               0
       END AS GamesMissed
INTO #missedsuites
FROM Contact_Custom cc
    INNER JOIN dbo.vwDimCustomer_ModAcctId ma
        ON ma.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
           AND ma.SourceSystem = 'tm-suites'
    INNER JOIN Bears_Suites.dbo.FactTicketSales fts
        ON SUBSTRING(ma.SSID, 1, CHARINDEX(':', ma.SSID, 1) - 1) = fts.SSID_acct_id
    INNER JOIN Bears.dbo.FactInventory fi
        ON fi.FactTicketSalesId = fts.FactTicketSalesId
    INNER JOIN Bears.dbo.DimEvent e
        ON e.DimEventId = fi.DimEventId
    INNER JOIN Bears.dbo.DimSeason s
        ON e.DimSeasonId = s.DimSeasonId
           AND s.DimArenaId = 48
           AND s.SeasonName NOT LIKE '%Test%'
WHERE s.SeasonYear = CASE
                         WHEN MONTH(GETDATE()) IN ( 4, 5, 6, 7, 8, 9, 10, 11, 12 ) THEN
                             YEAR(GETDATE())
                         ELSE
                             YEAR(GETDATE()) - 1
                     END
      AND e.EventDate < GETDATE()
      --AND cc.str_category = 'STH'
      -- and e.eventdesc not like '%Preseason' --Gets rid of Preseason games
      -- and e.isinventoryeligible = 1  --Gets rid of the Meijer Family Night
      AND fts.SourceSystem = 'TM-Suites'
GROUP BY ma.SSB_CRMSYSTEM_CONTACT_ID,
         e.EventDate,
         e.EventName


UPDATE cc SET new_ssb_gamesmissed_suites = GamesMissed
FROM contact_custom cc
INNER JOIN #missedsuites mg 
ON mg.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID


DROP TABLE #missedsuites


/*
===========================================
Eloqua Subscriptions
===========================================
*/

SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(community)AS Community, MAX(direct) AS Direct, MAX(exclusives) AS Exclusives, MAX(premiumseating) AS PremiumSeating, MAX(proshop) AS ProShop, MAX(surveys) AS Surveys, MAX(vamos) AS Vamos
INTO #eloquagroups
FROM bears.ods.Eloqua_EmailGroupMember_Sub_UnSub_PIVOT eg
INNER JOIN dbo.vwDimCustomer_ModAcctId dc ON dc.SourceSystem = 'eloqua' AND  dc.SSID = eg.contactid
GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
ORDER BY 1

UPDATE cc SET 
str_BearsDirectEmailList = eg.Direct
, str_BearsPremiumEmailList = eg.PremiumSeating
, str_vamosbearsemaillist = eg.Vamos
, str_ExclusiveBearsEventsEmailList = eg.Exclusives
, str_bearsinthecommunityemaillist = eg.Community
, str_bearsproshopemaillist = eg.ProShop
, str_bearssurveysemaillist = eg.Surveys
FROM contact_custom cc
INNER JOIN #eloquagroups eg
ON eg.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID

SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(C_Interest_in_Single_Game_Tickets1) AS Singles, MAX(C_Interest_in_Priority_List1) AS PriorityList, MAX(C_Interest_in_Group_Tickets1) AS Groups, MAX(C_Interest_in_Season_Tickets1) AS Season
INTO #eloquainterests
FROM bears.ods.Eloqua_Contact ec
INNER JOIN dbo.vwDimCustomer_ModAcctId dc ON dc.SourceSystem = 'eloqua' AND  dc.SSID = ec.id
GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
ORDER BY 1

UPDATE cc SET 
str_singlegameticketslist = ei.Singles
, str_seasonticketslist = ei.Season
, str_seasonprioritylist = ei.PriorityList
, str_groupticketslist = ei.Groups
FROM contact_custom cc
INNER JOIN #eloquainterests ei
ON ei.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID

DROP TABLE #eloquagroups
DROP TABLE #eloquainterests

/*
===========================================
Account Attributes
===========================================
*/
UPDATE c SET str_accountattribute1 = LEFT(f.ConcatIDs1,100)
, str_accountattribute2 = LEFT(f.ConcatIDs2,100)
, str_accountattribute3 = LEFT(f.ConcatIDs3,100)
, str_accountattribute4 = LEFT(f.ConcatIDs4,100)
, str_accountattribute5 = LEFT(f.ConcatIDs5,100)
, str_accountattribute6 = LEFT(f.ConcatIDs6,100)
, str_accountattribute7 = LEFT(f.ConcatIDs7,100)
, str_accountattribute8 = LEFT(f.ConcatIDs8,100)
, str_accountattribute9 = LEFT(f.ConcatIDs9,100)
, str_accountattribute10 = LEFT(f.ConcatIDs10,100)
, str_accountattribute11 = LEFT(f.ConcatIDs11,100)
, str_accountattribute12 = LEFT(f.ConcatIDs12,100)
, str_accountattribute13 = LEFT(f.ConcatIDs13,100)
, str_accountattribute14 = LEFT(f.ConcatIDs14,100)
, str_accountattribute15 = LEFT(f.ConcatIDs15,100)
, str_accountattribute16 = LEFT(f.ConcatIDs16,100)
, str_accountattribute17 = LEFT(f.ConcatIDs17,100)
, str_accountattribute18 = LEFT(f.ConcatIDs18,100)
, str_accountattribute19 = LEFT(f.ConcatIDs19,100)
, str_accountattribute20 = LEFT(f.ConcatIDs20,100)
--select c.SSB_CRMSYSTEM_CONTACT_ID, f.ConcatIDs1, f.ConcatIDs2, f.ConcatIDs3, f.ConcatIDs4, f.ConcatIDs5, f.ConcatIDs6, f.ConcatIDs7, f.ConcatIDs8, f.ConcatIDs9, f.ConcatIDs10
FROM (
SELECT n.SSB_CRMSYSTEM_CONTACT_ID
,ISNULL(LEFT(STUFF((    SELECT distinct ' | ' + LTRIM(RTRIM(other_info_1))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_1 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs1

,ISNULL(LEFT(STUFF((    SELECT distinct ' | ' + LTRIM(RTRIM(other_info_2))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_2 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs2

,ISNULL(LEFT(STUFF((    SELECT distinct  ' | ' + LTRIM(RTRIM(other_info_3))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_3 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs3

,ISNULL(LEFT(STUFF((    SELECT distinct  ' | ' + LTRIM(RTRIM(other_info_4))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_4 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs4

,ISNULL(LEFT(STUFF((    SELECT distinct  ' | ' + LTRIM(RTRIM(other_info_5))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_5 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs5

,ISNULL(LEFT(STUFF((    SELECT distinct  ' | ' + LTRIM(RTRIM(other_info_6))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_6 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs6

,ISNULL(LEFT(STUFF((    SELECT distinct  ' | ' + LTRIM(RTRIM(other_info_7))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_7 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs7

,ISNULL(LEFT(STUFF((    SELECT distinct  ' | ' + LTRIM(RTRIM(other_info_8))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_8 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs8

,ISNULL(LEFT(STUFF((    SELECT distinct  ' | ' + LTRIM(RTRIM(other_info_9))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_9 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs9

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_10))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_10 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs10

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_11))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_11 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs11

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_12))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_12 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs12

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_13))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_13 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs13

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_14))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_14 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs14

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_15))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_15 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs15

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_16))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_16 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs16

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_17))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_17 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs17

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_18))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_18 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs18

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_19))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_19 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs19

,ISNULL(LEFT(STUFF((    SELECT  distinct ' | ' + LTRIM(RTRIM(other_info_20))  AS [text()]
FROM bears.ods.tm_cust TM
WHERE tm.other_info_20 IS NOT NULL AND tm.acct_id = n.acct_id
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs20
--INTO #tempalert
FROM (SELECT acct_id, ssb.SSB_CRMSYSTEM_CONTACT_ID 
FROM bears.ods.TM_Cust n INNER JOIN dimcustomer dc ON n.acct_id = dc.AccountId AND dc.SourceSystem = 'tm' 
INNER JOIN dbo.DimCustomerssbid ssb ON dc.DimCustomerId = ssb.DimCustomerId) n
INNER JOIN dbo.Contact_Custom cc ON cc.SSB_CRMSYSTEM_CONTACT_ID = n.SSB_CRMSYSTEM_CONTACT_ID) f 
INNER JOIN dbo.Contact_Custom c ON c.SSB_CRMSYSTEM_CONTACT_ID = f.SSB_CRMSYSTEM_CONTACT_ID;



 --Update ParentCustomerID From SSBID table
 WITH Accounts as (
SELECT c.SSB_CRMSYSTEM_CONTACT_ID, ssb.ssid, ROW_NUMBER() OVER (PARTITION BY c.SSB_CRMSYSTEM_CONTACT_ID ORDER BY ssb.SSB_CRMSYSTEM_PRIMARY_FLAG, ssb.SSCreatedDate) accountrank   FROM dbo.Contact c
INNER JOIN dbo.vwDimCustomer_ModAcctId ssb ON ssb.SSB_CRMSYSTEM_ACCT_ID = c.SSB_CRMSYSTEM_ACCT_ID AND ssb.SourceSystem = 'crm_account' --WHERE c.SSB_CRMSYSTEM_CONTACT_ID = '2D351D92-FC46-47C9-83C1-F97029BE1A5A'

) 

UPDATE cc SET cc.parentcustomerid = a.SSID, cc.parentcustomeridtype = 'account'
--SELECT cc.SSB_CRMSYSTEM_CONTACT_ID, a.ssid
FROM dbo.Contact_Custom cc 
INNER JOIN Accounts a ON a.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
--WHERE cc.SSB_CRMSYSTEM_CONTACT_ID = '2D351D92-FC46-47C9-83C1-F97029BE1A5A'
;

--Override SSBID with anything that is already in CRM
UPDATE cc SET parentcustomerid = pc.parentcustomerid, parentcustomeridtype = pc.parentcustomeridtype
FROM dbo.contact_custom cc
INNER JOIN dbo.contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.vw_Contact pc
ON pc.contactid = c.crm_id
WHERE pc.parentcustomeridname IS NOT NULL;


/*================
INFO GROUP APPENDS
==================*/


--Stage Data
SELECT cc.SSB_CRMSYSTEM_CONTACT_ID, ROW_NUMBER() OVER (PARTITION BY cc.SSB_CRMSYSTEM_CONTACT_ID ORDER BY app.ETL__LoadDate DESC, app.Match_Score DESC, app.Sequence_Number DESC) AS xrank
, NULLIF(BE_ABI_Number,'') BE_ABI_Number
, NULLIF(BE_Company_Name,'') BE_Company_Name
, NULLIF(BE_Primary_SIC_Code,'') BE_Primary_SIC_Code
, NULLIF(BE_Primary_SIC_Description,'') BE_Primary_SIC_Description
, NULLIF(BE_Secondary_SIC_Code_1,'') BE_Secondary_SIC_Code_1
, NULLIF(BE_Secondary_SIC_Description_1,'') BE_Secondary_SIC_Description_1
, NULLIF(BE_Location_Employment_Size_Description,'') BE_Location_Employment_Size_Description
, NULLIF(BE_Location_Sales_Volume_Description,'') BE_Location_Sales_Volume_Description
, NULLIF(BE_Individual_Firm_Description,'') BE_Individual_Firm_Description
, NULLIF(BE_Business_Status_Description,'') BE_Business_Status_Description
, NULLIF(BE_Business_Credit_Score,'') BE_Business_Credit_Score
, NULLIF(BE_Business_Credit_Score_Description,'')BE_Business_Credit_Score_Description
,CASE WHEN ISNULL(BE_Primary_SIC_CODE,'') = '' THEN NULL 
WHEN Match_Pass = 'BE1' THEN 'Business Address and Business Phone1 Append' 
WHEN Match_Pass = 'BE2' THEN 'Business Phone2 Append'
WHEN Match_Pass = 'RE1' THEN 'Reverse Business Email Append'
WHEN Match_Pass = 'ER3' THEN 'Reverse Consumer ID Append' ELSE NULL END AS new_append_infogroupmatchpass 
INTO #InfoGroupAll
FROM 
dbo.Contact_Custom cc
INNER JOIN dbo.vwDimCustomer_ModAcctId ma
ON cc.SSB_CRMSYSTEM_CONTACT_ID = ma.SSB_CRMSYSTEM_CONTACT_ID AND ma.SourceSystem = 'Infogroup'
INNER JOIN bears.ods.Infogroup_Appends app ON ma.SSID = app.Sequence_Number
WHERE match_score > 0

----pull most recent non-blank/null value - decided that this actually would bring different SICs together. Just going to pull rank 1 now.
--SELECT i.SSB_CRMSYSTEM_CONTACT_ID 
--,coalesce(one.BE_ABI_Number ,two.BE_ABI_Number ,three.BE_ABI_Number ,four.BE_ABI_Number ,five.BE_ABI_Number ) BE_ABI_Number
--,coalesce(one.BE_Company_Name ,two.BE_Company_Name ,three.BE_Company_Name ,four.BE_Company_Name ,five.BE_Company_Name ) BE_Company_Name
--,coalesce(one.BE_Primary_SIC_Code ,two.BE_Primary_SIC_Code ,three.BE_Primary_SIC_Code ,four.BE_Primary_SIC_Code ,five.BE_Primary_SIC_Code ) BE_Primary_SIC_Code
--,coalesce(one.BE_Primary_SIC_Description ,two.BE_Primary_SIC_Description ,three.BE_Primary_SIC_Description ,four.BE_Primary_SIC_Description ,five.BE_Primary_SIC_Description ) BE_Primary_SIC_Description
--,coalesce(one.BE_Secondary_SIC_Code_1 ,two.BE_Secondary_SIC_Code_1 ,three.BE_Secondary_SIC_Code_1 ,four.BE_Secondary_SIC_Code_1 ,five.BE_Secondary_SIC_Code_1 ) BE_Secondary_SIC_Code_1
--,coalesce(one.BE_Secondary_SIC_Description_1 ,two.BE_Secondary_SIC_Description_1 ,three.BE_Secondary_SIC_Description_1 ,four.BE_Secondary_SIC_Description_1 ,five.BE_Secondary_SIC_Description_1 ) BE_Secondary_SIC_Description_1
--,coalesce(one.BE_Location_Employment_Size_Description ,two.BE_Location_Employment_Size_Description ,three.BE_Location_Employment_Size_Description ,four.BE_Location_Employment_Size_Description ,five.BE_Location_Employment_Size_Description ) BE_Location_Employment_Size_Description
--,coalesce(one.BE_Location_Sales_Volume_Description ,two.BE_Location_Sales_Volume_Description ,three.BE_Location_Sales_Volume_Description ,four.BE_Location_Sales_Volume_Description ,five.BE_Location_Sales_Volume_Description ) BE_Location_Sales_Volume_Description
--,coalesce(one.BE_Individual_Firm_Description ,two.BE_Individual_Firm_Description ,three.BE_Individual_Firm_Description ,four.BE_Individual_Firm_Description ,five.BE_Individual_Firm_Description ) BE_Individual_Firm_Description
--,coalesce(one.BE_Business_Status_Description ,two.BE_Business_Status_Description ,three.BE_Business_Status_Description ,four.BE_Business_Status_Description ,five.BE_Business_Status_Description ) BE_Business_Status_Description
--,coalesce(one.BE_Business_Credit_Score ,two.BE_Business_Credit_Score ,three.BE_Business_Credit_Score ,four.BE_Business_Credit_Score ,five.BE_Business_Credit_Score ) BE_Business_Credit_Score
--,coalesce(one.BE_Business_Credit_Score_Description ,two.BE_Business_Credit_Score_Description ,three.BE_Business_Credit_Score_Description ,four.BE_Business_Credit_Score_Description ,five.BE_Business_Credit_Score_Description ) BE_Business_Credit_Score_Description
--,coalesce(one.new_append_infogroupmatchpass ,two.new_append_infogroupmatchpass ,three.new_append_infogroupmatchpass ,four.new_append_infogroupmatchpass ,five.new_append_infogroupmatchpass) new_append_infogroupmatchpass
--INTO #InfoGroupFinal
--FROM #InfoGroupAll i
--INNER JOIN #InfoGroupAll one ON i.SSB_CRMSYSTEM_CONTACT_ID = one.SSB_CRMSYSTEM_CONTACT_ID AND one.xrank = 1
--left JOIN #InfoGroupAll two ON i.SSB_CRMSYSTEM_CONTACT_ID = two.SSB_CRMSYSTEM_CONTACT_ID AND two.xrank = 2
--left JOIN #InfoGroupAll three ON i.SSB_CRMSYSTEM_CONTACT_ID = three.SSB_CRMSYSTEM_CONTACT_ID AND three.xrank = 3
--left JOIN #InfoGroupAll four ON i.SSB_CRMSYSTEM_CONTACT_ID = four.SSB_CRMSYSTEM_CONTACT_ID AND four.xrank = 4
--left JOIN #InfoGroupAll five ON i.SSB_CRMSYSTEM_CONTACT_ID = five.SSB_CRMSYSTEM_CONTACT_ID AND five.xrank = 5


UPDATE contact_custom 
SET
 new_Append_ABINumber = BE_ABI_Number ,
 new_Append_Company = BE_Company_Name ,
 new_Append_PrimarySICCode = BE_Primary_SIC_Code ,
 [new_append_primarysiccodedescription] = BE_Primary_SIC_Description ,
 new_Append_SecondarySICCode = BE_Secondary_SIC_Code_1 ,
 new_Append_SecondarySICCodeDescription = BE_Secondary_SIC_Description_1 ,
 new_Append_LocationEmploymentSize = BE_Location_Employment_Size_Description ,
 new_Append_LocationSalesVolume = BE_Location_Sales_Volume_Description ,
 new_Append_IndividualFirmDescription = BE_Individual_Firm_Description ,
 new_Append_BusinessLocationType = BE_Business_Status_Description ,
 new_Append_BusinessCreditScore = BE_Business_Credit_Score ,
 new_Append_BusinessCreditScoreDescription = BE_Business_Credit_Score_Description ,
 new_append_infogroupmatchpass = i.new_append_infogroupmatchpass 
FROM contact_custom cc 
INNER JOIN #InfoGroupAll i
--INNER JOIN #InfoGroupFinal i
ON i.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID AND i.xrank = 1

DROP TABLE #InfoGroupAll
--DROP TABLE #InfoGroupFinal


/*=================================
Secondary Contacts
==================================*/
UPDATE contact_custom 
SET new_secondarycontact = ConcatIDs1

FROM 
contact_custom cc INNER JOIN 
(
SELECT [GUID]
,ISNULL(LEFT(STUFF((    SELECT  '| ' + CAST(TM.AccountId AS NVARCHAR(100)) +' - ' + LTRIM(ISNULL(name_first,'')) + ' ' + LTRIM(ISNULL(name_last,'')) + ' ' + ISNULL(NULLIF(LTRIM(RTRIM( LTRIM(ISNULL(TM.AddressPrimaryStreet,'')) + ' ' + LTRIM(ISNULL(TM.AddressPrimaryCity,'')) + ', ' + LTRIM(ISNULL(TM.AddressPrimaryState,'')) + ' ' + LTRIM(ISNULL(TM.AddressPrimaryZip,'')) )),','),'') AS [text()]
FROM ( --TM
SELECT DISTINCT cc.SSB_CRMSYSTEM_CONTACT_ID AS [GUID], secondaries.FirstName name_first, secondaries.LastName name_last, secondaries.AccountId, secondaries.CompanyName, secondaries.MiddleName, 
secondaries.AddressPrimaryStreet, secondaries.AddressPrimaryCity, secondaries.AddressPrimaryState, secondaries.AddressPrimaryZip, secondaries.AddressPrimaryCountry
		FROM contact_custom cc INNER JOIN dbo.vwDimCustomer_ModAcctId mai 
		ON mai.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID AND mai.sourcesystem = 'tm'
		INNER JOIN dbo.vwDimCustomer_ModAcctId secondaries
		ON mai.accountid = secondaries.accountid 
		AND secondaries.sourcesystem = 'tm' AND secondaries.CustomerType = 'secondary'
		AND mai.dimcustomerid != secondaries.dimcustomerid 
		AND mai.firstname + mai.lastname != secondaries.firstname + secondaries.lastname 
		WHERE mai.CustomerType IN ('Primary') AND mai.SSB_CRMSYSTEM_PRIMARY_FLAG = 1 AND ISNULL(secondaries.firstname,'') + ISNULL(secondaries.lastname,'') != ''
) TM
WHERE TM.[GUID] = z.[GUID] 
ORDER BY name_first
FOR XML PATH('')), 1, 1, ''),8000),'') AS ConcatIDs1

FROM (SELECT DISTINCT GUID FROM [stg].tbl_CRMProcess_NonWinners
) z --order by 2
) query ON query.[GUID] = cc.SSB_CRMSYSTEM_CONTACT_ID AND ISNULL(LTRIM(query.ConcatIDs1),'') != ''

/*
=======================================
Ticket Requests
=======================================
*/

IF OBJECT_ID('tempdb..#TicketRequests') IS NOT NULL
	DROP TABLE #TicketRequests
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID GUID,
	   etr.*
INTO #TicketRequests
FROM bears.dbo.vwDimCustomer_ModAcctId dc
    JOIN bears.[etl].[vw_Load_Eloqua_TicketRequestForm] etr
        ON etr.ContactId = dc.SSID
           AND dc.SourceSystem = 'Eloqua';

IF OBJECT_ID('tempdb..#Tr2') IS NOT NULL
	DROP TABLE #Tr2
SELECT tr.GUID,
       CASE WHEN tr.SingleGameTickets = 'on' THEN 'Single Game Tickets' ELSE NULL END AS SingleGameTickets,
       CASE WHEN tr.SeasonTickets = 'on' THEN 'Season Tickets' ELSE NULL END AS SeasonTickets,
       CASE WHEN tr.PriorityTickets = 'on' THEN 'Priority Tickets' ELSE NULL END AS PriorityTickets,
       CASE WHEN tr.GroupTickets = 'on' THEN 'Group Tickets' ELSE NULL END AS GroupTickets,
       CASE WHEN tr.Premium = 'on' THEN 'Premium Tickets' ELSE NULL END AS PremiumTickets,
	   x.maxcreated
INTO #Tr2
FROM #TicketRequests tr
INNER JOIN (SELECT GUID, MAX(CreatedAt) AS maxcreated FROM #TicketRequests GROUP BY GUID) x
	ON x.GUID = tr.GUID AND x.maxcreated=tr.CreatedAt


IF OBJECT_ID('tempdb..#Tr3') IS NOT NULL
	DROP TABLE #Tr3
SELECT GUID SSB_CRMSYSTEM_CONTACT_ID, maxcreated new_eloquaticketrequesttimestamp, CONCAT(CASE WHEN SingleGameTickets IS NOT NULL THEN SingleGameTickets + ' | ' ELSE NULL END,
CASE WHEN SeasonTickets IS NOT NULL THEN SeasonTickets + ' | ' ELSE NULL END, CASE WHEN PriorityTickets IS NOT NULL THEN PriorityTickets + ' | ' ELSE NULL END, CASE WHEN GroupTickets IS NOT NULL THEN GroupTickets + ' | ' ELSE NULL END,
CASE WHEN PremiumTickets IS NOT NULL THEN PremiumTickets + ' | ' ELSE NULL END) AS new_eloquaticketrequesttype
INTO #Tr3
FROM #Tr2

UPDATE cc
SET cc.new_eloquaticketrequesttimestamp = t.new_eloquaticketrequesttimestamp,
	cc.new_eloquaticketrequesttype = t.new_eloquaticketrequesttype
FROM dbo.Contact_Custom cc
JOIN #Tr3 t ON t.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID

DROP TABLE #TicketRequests
DROP TABLE #Tr2
DROP TABLE #Tr3


EXEC dbo.sp_CRMLoad_Contact_ProcessLoad_Criteria

GO
