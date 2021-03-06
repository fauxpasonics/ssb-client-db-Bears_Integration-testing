CREATE TABLE [dbo].[CRMLoad_Contact_Std_Update]
(
[new_ssbcrmsystemacctid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[new_ssbcrmsystemcontactid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Prefix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1_line1] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1_line2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1_city] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1_stateorprovince] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1_postalcode] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1_country] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailaddress1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[telephone1] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loadtype] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
