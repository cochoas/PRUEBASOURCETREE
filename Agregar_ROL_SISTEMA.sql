/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [Cod_Sistema]
      ,[Cod_RolPerfil]
      ,[Ins_Id]
      ,[Ins_Dt]
      ,[Mod_Id]
      ,[Mod_Dt]
  FROM [CORPORATIVO].[dbo].[PermisoSistema] where cod_sistema = 5

  USE  CORPORATIVO

 begin tran
INSERT INTO [CORPORATIVO].[dbo].[PermisoSistema]
           ([Cod_Sistema]
			,[Cod_RolPerfil]
			,[Ins_Id]
			,[Ins_Dt]
			,[Mod_Id]
			,[Mod_Dt])
     VALUES (5,84,'COCHOA',getdate(),'COCHOA' ,getdate())
Commit Tran