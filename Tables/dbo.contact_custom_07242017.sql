CREATE TABLE [dbo].[contact_custom_07242017]
(
[SSB_CRMSYSTEM_ACCT_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SSB_CRMSYSTEM_CONTACT_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SSID_Winner] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TM_Ids] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DimCustIDs] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ssbcrmsystem_RecordType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ssbcrmsystemssidwinnersourcesystem] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMSuite_Ids] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[telephone2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mobilephone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ownerid] [uniqueidentifier] NULL,
[owneridtype] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[str_category] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[str_clientheadline] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
