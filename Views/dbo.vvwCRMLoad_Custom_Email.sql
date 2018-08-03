SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vvwCRMLoad_Custom_Email]

AS


--Elqoua Contact Us
SELECT 
CAST(f.contactUsReason + ' - ' + f.comments AS NVARCHAR(MAX)) AS Description
, c.crm_id AS regardingobjectid
, 'contact' AS regardingobjecttypecode
, f.createdat  AS ActualStart
, f.createdat  AS ActualEnd
, f.createdat  AS ScheduledStart
, f.createdat  AS ScheduledEnd
, 'phonecall' AS activitytypecode
, 'systemuser' AS owneridtype
, '84CB51D1-1C8C-E711-8123-E0071B72B771' AS ownerid
, 1 AS statecode
, 4 AS statuscode
, CAST('Contact Us Form Submission - ' + f.contactUsReason AS NVARCHAR(300)) AS 'Subject'
, 'ECU - ' + CAST(ID AS NVARCHAR(100)) AS new_TM_NoteID
, 0 AS directioncode
, '[{"PartyId":"84CB51D1-1C8C-E711-8123-E0071B72B771","Name":"# The Chicago Bears Ticket Office","Type":"systemuser"}]' AS 'From'
--select top 100 *
FROM bears.ods.Eloqua_ContactUsForm f
INNER JOIN dbo.vwDimCustomer_ModAcctId ma 
ON CAST(f.ContactId AS NVARCHAR(100))  + '-' + CAST(id AS NVARCHAR(100))  = ma.SSID AND ma.SourceSystem = 'Eloqua_ContactUs'
INNER JOIN dbo.Contact c
ON ma.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
--LEFT JOIN bears_reporting.prodcopy.PhoneCall p
--ON p.new_tm_noteid =  'ECU - ' + CAST(ID AS NVARCHAR(100))
LEFT JOIN bears_reporting.prodcopy.email e
ON e.new_tm_noteid =  'ECU - ' + CAST(ID AS NVARCHAR(100))
WHERE c.crm_id != c.SSB_CRMSYSTEM_CONTACT_ID
--AND p.activityid IS NULL
AND e.activityid IS NULL
AND f.ID != '241112'
--ORDER BY f.createdat




GO
