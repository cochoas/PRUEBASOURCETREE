SET TRAN ISOLATION LEVEL READ UNCOMMITTED; 

/*declare  @Cod_SucursalBrinks Float
SET @Cod_SucursalBrinks = 4.152
Select [ValorParametro]
         From [Corporativo].[dbo].[Parametros]
       Where [NomParametro] = 'MONITOREOTOTAL'
          And [ValorParametro] = Cast(Round(@Cod_SucursalBrinks,0) As Varchar);*/


Select *
    From [Corporativo].[dbo].[Parametros] where ValorParametro = '1'
       --Where [NomParametro] = 'MONITOREOTOTAL' order by 1 desc
  
