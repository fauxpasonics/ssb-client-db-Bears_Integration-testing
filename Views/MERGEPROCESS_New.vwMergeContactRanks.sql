SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
 
 
 
CREATE VIEW [MERGEPROCESS_New].[vwMergeContactRanks]
 
AS
 
SELECT a.SSBID
    , c.contactid ID
    --Add in custom ranking here
    ,ROW_NUMBER() OVER(PARTITION BY SSBID ORDER BY c.modifiedon DESC, c.str_lastactivitydate desc, c.createdon desc) xRank
FROM MERGEPROCESS_New.DetectedMerges a
JOIN mergeprocess_new.tmp_dimcust b 
    ON a.SSBID = b.SSB_CRMSYSTEM_CONTACT_ID AND b.SourceSystem = 'crm_contact' --updateme for source system --TCF 09112017
    AND a.[ObjectType] = 'Contact'
JOIN mergeprocess_new.tmp_pccontact c
    ON b.SSID = CAST(c.contactid AS NVARCHAR(100))
    --AND c.statuscodename = 'Active'
WHERE MergeComplete = 0;
 
 
 
 
 

GO
