SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_tmp_Address3to4]
as

SELECT contactid,
  address3_city				 as new_address4_city
, address3_country			 as new_address4_country
, address3_county			 as new_address4_county
, address3_fax				 as new_address4_fax
, address3_line1			 as new_address4_line1
, address3_line2			 as new_address4_line2
, address3_line3			 as new_address4_line3
, address3_postalcode		 as new_address4_postalcode
, address3_postofficebox	 as new_address4_postofficebox
, address3_stateorprovince	 as new_address4_stateorprovince
, address3_telephone1		 as new_address4_telephone1
, address3_telephone2		 as new_address4_telephone2
, address3_telephone3		 as new_address4_telephone3
--select count(*)
FROM prodcopy.contact	
WHERE 
isnull(address3_city				,'') != ''
OR isnull(address3_country				,'') != ''
OR isnull(address3_county				,'') != ''
OR isnull(address3_fax					,'') != ''
OR isnull(address3_line1				,'') != ''
OR isnull(address3_line2				,'') != ''
OR isnull(address3_line3				,'') != ''
OR isnull(address3_postalcode			,'') != ''
OR isnull(address3_postofficebox		,'') != ''
OR isnull(address3_stateorprovince		,'') != ''
OR isnull(address3_postalcode			,'') != ''
OR isnull(address3_telephone1			,'') != ''
OR isnull(address3_telephone2			,'') != ''
OR isnull(address3_telephone3			,'') != '' 
GO
