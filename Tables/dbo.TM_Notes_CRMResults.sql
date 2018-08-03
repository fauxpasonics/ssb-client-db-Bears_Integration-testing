CREATE TABLE [dbo].[TM_Notes_CRMResults]
(
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[regardingobjectid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[regardingobjecttypecode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActualStart] [datetime] NULL,
[ActualEnd] [datetime] NULL,
[ScheduledStart] [datetime] NULL,
[ScheduledEnd] [datetime] NULL,
[activitytypecode] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[owneridtype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ownerid] [uniqueidentifier] NULL,
[statecode] [int] NULL,
[statuscode] [int] NULL,
[Subject] [nvarchar] (874) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_TM_NoteID] [bigint] NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL,
[CrmErrorMessage] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
