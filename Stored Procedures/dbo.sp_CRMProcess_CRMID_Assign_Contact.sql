SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CRMProcess_CRMID_Assign_Contact]
AS
UPDATE a
SET crm_Id = a.SSB_CRMSYSTEM_CONTACT_ID
FROM dbo.contact a
LEFT JOIN prodcopy.vw_contact b
ON a.crm_id = b.contactid
WHERE b.contactid IS NULL 

UPDATE a
SET crm_id = a.ssb_crmsystem_contact_id
--SELECT a.crm_id, a.ssb_crmsystem_contact_id
FROM dbo.contact a
LEFT JOIN dbo.vwDimCustomer_ModAcctId b
ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID AND a.crm_id = b.SSID
WHERE b.SSB_CRMSYSTEM_CONTACT_ID IS NULL AND a.crm_id != a.SSB_CRMSYSTEM_CONTACT_ID


UPDATE a
SET a.crm_id = b.contactid
-- SELECT COUNT(*)
FROM dbo.contact a
INNER JOIN prodcopy.vw_contact b ON a.SSB_CRMSYSTEM_contact_ID = b.new_ssbcrmsystemcontactid
LEFT JOIN (SELECT [crm_id] FROM dbo.contact WHERE crm_id <> [SSB_CRMSYSTEM_CONTACT_ID]) c ON b.contactid = c.crm_id
WHERE ISNULL(a.[crm_id], '') != b.contactid 
AND c.crm_id IS NULL	
---and b.id = '0033800002JUEoUAAX'


UPDATE a
SET [crm_id] =  b.ssid 
-- SELECT COUNT(*) 
FROM dbo.contact a
INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON a.SSB_CRMSYSTEM_contact_ID = b.SSB_CRMSYSTEM_contact_ID
LEFT JOIN (SELECT crm_id FROM dbo.contact WHERE crm_id <> [SSB_CRMSYSTEM_CONTACT_ID]) c ON b.ssid = c.[crm_id]
WHERE b.SourceSystem = 'CRM_Contact' AND a.[crm_id] != b.ssid --updateme
 AND c.[crm_id] IS NULL 

GO
