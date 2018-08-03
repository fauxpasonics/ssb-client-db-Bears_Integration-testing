CREATE ROLE [db_executor]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executor', N'svcLogi'
GO
GRANT EXECUTE TO [db_executor]
