SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Update] AS

--MATERIALIZING TABLE. LOOK AT TABLE AND SPROC


--updateme - Hashes
SELECT 
  a.new_ssbcrmsystemacctid
, a.new_ssbcrmsystemcontactid
, a.Prefix
, a.FirstName
, a.LastName
, a.Suffix
, a.address1_line1
, NULL AS address1_line2
, a.address1_city
, a.address1_stateorprovince
, a.address1_postalcode
, a.address1_country
, a.emailaddress1
, a.telephone1
, a.contactid
, LoadType
, a.middlename
--, b.FirstName, b.LastName, b.Suffix, b.address1_line1, b.address1_line2, b.address1_city, b.address1_stateorprovince, b.address1_postalcode, b.address1_country, b.emailaddress1
--, b.telephone1

FROM [dbo].[vwCRMLoad_Contact_Std_Prep] a WITH (NOLOCK)
JOIN prodcopy.vw_contact b WITH (NOLOCK) ON a.contactid = b.contactID
WHERE LoadType = 'Update' 
AND (ISNULL(a.address1_line1,'') != ISNULL(b.address1_line1,'')
	OR ISNULL(a.Prefix,'') != ISNULL(b.salutation,'')
	OR ISNULL(a.FirstName,'') != ISNULL(b.FirstName,'')
	OR ISNULL(a.LastName,'') != ISNULL(b.LastName,'')
	OR ISNULL(LEFT(a.Suffix,10),'') != ISNULL(b.Suffix,'')
	OR ISNULL(a.address1_city,'') != ISNULL(b.address1_city,'')
	OR ISNULL(a.address1_stateorprovince,'') != ISNULL(b.address1_stateorprovince,'')
	OR ISNULL(a.address1_postalcode,'') != ISNULL(b.address1_postalcode,'')
	OR ISNULL(a.address1_country,'') != ISNULL(b.address1_country,'')
	OR ISNULL(a.emailaddress1,'') != ISNULL(b.emailaddress1,'')
	OR ISNULL(a.telephone1,'') != ISNULL(b.telephone1,'')
	OR ISNULL(a.middlename,'') != ISNULL(b.middlename,'')
	)






GO
