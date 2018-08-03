SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[temp_address3]

AS

SELECT back.contactid
, back.address1_line1			as   address3_line1
, back.address1_line2			as   address3_line2
, back.address1_city				as   address3_city
, back.address1_stateorprovince	as   address3_stateorprovince
, back.address1_postalcode		as   address3_postalcode
, back.address1_country			as   address3_country
, back.address1_county			as   address3_county


FROM Bears_Reporting.prodcopy.contact_backup_07042017 back
INNER JOIN Bears_Reporting.prodcopy.contact pcc 
ON back.contactid = pcc.contactid
WHERE back.address1_line1 IS NOT NULL AND pcc.statecode = 0
GO
