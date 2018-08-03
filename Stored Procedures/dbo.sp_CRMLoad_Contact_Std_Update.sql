SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CRMLoad_Contact_Std_Update]

AS

TRUNCATE TABLE [dbo].CRMLoad_Contact_Std_Update


INSERT INTO [dbo].CRMLoad_Contact_Std_Update
SELECT * 
FROM dbo.vwcrmload_contact_std_update
GO
