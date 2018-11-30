/* ------------- LOG DE ERRORES -------------- */
declare @Usuario varchar(25)='';
declare @Aplicacion varchar(25)=''; --'%custodia.exe%';
declare @Fecha date=GETDATE()-1;
declare @Base varchar(15)=''; --'TRANSPORTE';
declare @Error varchar(50)=''--'%reembolso%'
declare @Name_Script varchar(50) = ''--'SPCHK_INS_ReintentosOrdenServicio'; --'%SPCUS_INS_CIERREMODULO%';

SELECT TOP 1000 CONVERT(varchar(16), Date_Operation, 120) Fecha, Name_DB, Error_Description, Name_Script_Proccess, User_ID, App_name --, *
  FROM [BD_REGISTRO_ERRORES].[dbo].[TB_LogError]
Where (@Usuario='' or User_ID = @Usuario)
and (@Aplicacion = '' or App_name like @Aplicacion)
and (@Fecha = '' or Date_Operation >= @Fecha)
and (@Base = '' or Name_DB like @Base)
and (@Error = '' or Error_Description like @Error)
and (@Name_Script = '' or Name_script_Proccess like @Name_Script)
order by Date_Operation desc
