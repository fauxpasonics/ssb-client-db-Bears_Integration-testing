SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwCRMLoad_Custom_TM_Notes]
AS

--TM Notes
SELECT DISTINCT
note.text AS Description
, c.crm_id AS regardingobjectid
, 'contact' AS regardingobjecttypecode
, note.upd_Datetime AS ActualStart
, note.upd_Datetime AS ActualEnd
, note.upd_Datetime AS ScheduledStart
, note.upd_Datetime AS ScheduledEnd
, 'phonecall' AS activitytypecode
, 'systemuser' AS owneridtype
, CASE WHEN u.systemuserid IS NOT NULL THEN u.systemuserid ELSE '84CB51D1-1C8C-E711-8123-E0071B72B771' END AS ownerid
, 1 AS statecode
, 2 AS statuscode
, CASE WHEN note.note_type = 'M' THEN 'Memo' WHEN note.note_type = 'T' THEN 'Task' END + ' ' + ISNULL(note.category,'') + ' ' + ISNULL(note.subject,'') + ' #' + CAST(note.acct_id AS NVARCHAR(100)) + ' ' + note.add_user AS 'Subject'
, CAST(note.note_id AS NVARCHAR(100)) AS new_TM_NoteID
--, CAST(note.note_id AS NVARCHAR(100)) AS new_TM_NoteID

--SELECT COUNT(*)
FROM bears.ods.TM_Note note
INNER JOIN bears.dbo.vwDimCustomer_ModAcctId dc
	ON note.acct_id = dc.AccountId AND dc.SourceSystem = 'tm' AND dc.CustomerType = 'primary'
INNER JOIN Bears_Integration.dbo.contact c
	ON dc.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
LEFT JOIN bears_reporting.prodcopy.SystemUser u
	ON note.upd_user = u.new_TM_UserID
LEFT JOIN bears_reporting.prodcopy.phonecall pc
	ON CAST(note.note_id AS NVARCHAR(100)) = pc.new_tm_noteid --had to add this field to client's Dynamics under Phone Call
LEFT JOIN bears_reporting.prodcopy.phonecall pcpc 
	ON pcpc.subject = CASE WHEN note.note_type = 'M' THEN 'Memo' WHEN note.note_type = 'T' THEN 'Task' END + ' ' + ISNULL(note.category,'Memo') + ' ' + ISNULL(note.subject,'') + ' #' + CAST(note.acct_id AS NVARCHAR(100)) + ' ' + note.add_user AND pcpc.description = note.text
WHERE (note.upd_Datetime  < '2010-07-01 00:00:00.000'
OR
note.upd_Datetime > '2017-07-11 00:00:00.000')
--AND note.task_stage_status = 'Completed' --Removed so that we could load Memos, which don't have a completed flag.
AND ((note_type = 'T' AND note.task_stage_status = 'Completed') OR note.note_type = 'M')
AND c.crm_id != c.SSB_CRMSYSTEM_CONTACT_ID
AND (pc.activityid IS NULL OR (pc.activityid IS NOT NULL AND  ISNULL(pc.description,'') != ISNULL(note.text,'')))   --Exlude where there is already an SSB creation (on tmnoteid) or where we created one, but the task was later updated. This means we will create a dupe but it is an acceptable dupe
AND pcpc.activityid IS NULL  --Catches STR Creations  --Not needed in net new builds


--UNION

--THIS WAS MOVED TO dbo.vwCRMLoad_Custom_Email

----Elqoua Contact Us
--SELECT 
--f.contactUsReason + ' - ' + f.comments AS Description
--, c.crm_id AS regardingobjectid
--, 'contact' AS regardingobjecttypecode
--, f.createdat
--, f.createdat
--, f.createdat
--, f.createdat
--, 'phonecall' AS activitytypecode
--, 'systemuser' AS owneridtype
--, '84CB51D1-1C8C-E711-8123-E0071B72B771' AS ownerid
--, 1 AS statecode
--, 2 AS statuscode
--, 'Contact Us Form Submission - ' + f.contactUsReason AS 'Subject'
--, 'ECU - ' + CAST(ID AS NVARCHAR(100)) AS new_TM_NoteID
----select top 100 *
--FROM bears.ods.Eloqua_ContactUsForm f
--INNER JOIN dbo.vwDimCustomer_ModAcctId ma 
--ON CAST(f.ContactId AS NVARCHAR(100))  + '-' + CAST(id AS NVARCHAR(100))  = ma.SSID AND ma.SourceSystem = 'Eloqua_ContactUs'
--INNER JOIN dbo.Contact c
--ON ma.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
--LEFT JOIN bears_reporting.prodcopy.PhoneCall p
--ON p.new_tm_noteid =  'ECU - ' + CAST(ID AS NVARCHAR(100))
----LEFT JOIN bears_reporting.prodcopy.email e
----ON e.new_tm_noteid =  'ECU - ' + CAST(ID AS NVARCHAR(100))
--WHERE c.crm_id != c.SSB_CRMSYSTEM_CONTACT_ID
--AND p.activityid IS NULL
----AND e.activityid IS null



GO
