/*
======================================================================================================================================
   ____ _                          _        ____                     _       
  / ___(_) ___ _ __ _ __ ___    __| | ___  | __ )  _____   _____  __| | __ _ 
 | |   | |/ _ \ '__| '__/ _ \  / _` |/ _ \ |  _ \ / _ \ \ / / _ \/ _` |/ _` |
 | |___| |  __/ |  | | |  __/ | (_| |  __/ | |_) | (_) \ V /  __/ (_| | (_| |
  \____|_|\___|_|  |_|  \___|  \__,_|\___| |____/ \___/ \_/ \___|\__,_|\__,_|
                                                                             
http://patorjk.com/software/taag/#p=display&f=Standard&t=Cierre%20de%20Boveda

====================================== Sucursales Brinks ======================================
1	Santiago		5	Temuco			9	Osorno			13	Calama			18	Arica
2	Viña del Mar	6	Puerto Montt	10	Copiapó			14	Los Ángeles		19	Coyhaique
3	Talca			7	Rancagua		11	Punta Arenas	16	La Serena		20	San Felipe
4	Concepción		8	Iquique			12	Antofagasta		17	Chillan		
===============================================================================================

select * from CIF..CIF_Cliente c where c.NombreFantasia like '%SCOTIA%'         -- 97018000
select * from CIF..CIF_Cliente c where c.NombreFantasia like '%BANCO%CREDITO%'   -- 97006000
select * from CIF..CIF_Cliente c where c.NombreFantasia like '%BANCO%DE%CHILE%'  -- 97004000
select * from CIF..CIF_Cliente c where c.NombreFantasia like '%SANTANDER%SANTI%' -- 97036000
select * from CIF..CIF_Cliente c where c.NombreFantasia like '%BBVA%'            -- 97032000
select * from CIF..CIF_Cliente c where c.NombreFantasia like '%SECURITY%'        -- 97053000
select * from CIF..CIF_Cliente c where c.NombreFantasia like '%HEROES%'          -- 70016330

======================================================================================================================================
*/
BEGIN
	BEGIN TRY
		declare @Cod_SucursalBrinks float = 4;
		declare @Id_ClienteBrinks varchar(15) ='97004000'; -- Chile
		declare @FechaSaldo varchar(10)=CONVERT(VARCHAR, GETDATE(), 112);

		declare @tran_local bit;
		declare @Id_TipoValor int=0; -- 0: Todos, 1: Billetes, 2: Monedas
		declare @Nom_Valor varchar(100) = '';
		declare @Cliente varchar(200)= '';
		declare @Sucursal varchar(200)= '';

		select @Cliente=RazonSocial from CIF..CIF_Cliente as cl where cl.Id_Cliente = @Id_ClienteBrinks;
		select @Sucursal=su.NombreSucursalBrinks from CIF..CIF_SucursalBrinks as su where su.Cod_SucursalBrinks = @Cod_SucursalBrinks;

		IF @tran_local = 1
			BEGIN TRAN;

		--select *  
		update cc set cc.FechaSaldo=@FechaSaldo
		from CUSTODIA..tb_CartolaCtaCustodia cc
		where cc.Cerrado = 0
		and cc.Id_CtaCustodia in 
		(
		select c.Id_CtaCustodia
		from CUSTODIA..tb_CtaCustodia c
		where (@Id_ClienteBrinks = '0' or  Id_Cliente=@Id_ClienteBrinks)
		and c.Cod_SucursalBrinks=@Cod_SucursalBrinks
		and (@Id_TipoValor=0 or c.Id_TipoValor=@Id_TipoValor)
		and c.Activo = 1
		);

		select @Nom_Valor=case @Id_TipoValor when 1 then 'BILLETES' when 2 then 'MONEDAS' else 'BILLETES y MONEDAS' end;

		print '------------------------------------------------------------------------------------------';
		print '';
		print '*** Custodia  C E R R A D A ***';
		print '';
		print '------------------------------------------------------------------------------------------';
		print 'Sucursal  : ' + @Sucursal;
		print 'Cliente   : ' + @Cliente;
		print 'Fecha     : ' + cast(cast(@FechaSaldo as DATE) as VARCHAR);
		print 'Tipo Valor: ' + @Nom_Valor;
		print '------------------------------------------------------------------------------------------';
			
		IF @tran_local = 1
			COMMIT;
	
	END TRY	
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			IF @tran_local = 1
				ROLLBACK TRAN;
				
		Declare @Name_server [varchar](1000), @Name_DB [varchar](1000), @Error_Number int, @Error_Description [varchar](1000), @Name_Script_Proccess [varchar](1000), @User_ID [varchar](1000), 
				@Type_Operation [varchar](1), @App_name [varchar](1000), @SpID [int],	@ErrorSeverity INT, @ErrorState INT;
	SELECT @Name_Server =@@SERVERNAME, @Name_DB = DB_NAME(), @Error_Number = ERROR_NUMBER(), @Error_Description = ERROR_MESSAGE(), @Name_Script_Proccess = OBJECT_NAME(@@PROCID), @User_ID = SUSER_NAME(),  @Type_Operation = 'U', @App_Name = APP_NAME(), @SpID = @@SPID, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
		Exec Registro_Errores @Name_Server, @Name_DB, @Error_Number, @Error_Description, @Name_Script_Proccess, @User_ID, @Type_Operation, @App_name, @SpID;
		RAISERROR (@Error_Description,@ErrorSeverity,@ErrorState);
--		Return @Error_Number;
	END CATCH
END;
