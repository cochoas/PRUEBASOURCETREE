
	,Id_PuntoServicioTipoOrden INT
	,Cod_TipoOrdenServicio INT
	,NomTipoOrdenServicio Varchar(50)
	,ClientePrincipal Varchar(100)
	,FechaInicioServicio DateTime
	,FechaTerminoServicio DateTime
	,Apedido BIT
	,Cod_PuntoOrigen INT
	,NomPuntoOrigen Varchar(50)
	,Cod_PuntoDestino INT
	,NomPuntoDestino Varchar(50)
	,NombreTipoMovimiento Varchar(50)
	,AtiendeFestivo BIT
	,Domingo Bit
	,Lunes Bit
	,Martes Bit
	,Miercoles Bit
	,Jueves Bit
	,Viernes Bit
	,Sabado Bit
	,Vigente Bit
	,Id_Personal varchar(25)
	,FechaRegistro DateTime
)
--Recupera los PS Activos
INSERT INTO #TMP_Puntos (Cod_PuntoServicio)
SELECT 
	Cod_PuntoServicio
FROM dbo.CIF_PuntoServicio
WHERE ((@Cod_SucursalBrinks = 0) OR (Cod_SucursalBrinks = @Cod_SucursalBrinks))
	AND Vigente = 1
	--and cod_puntoservicio = 22244

--Recupera Frecuencias y Pivotea los valores
INSERT INTO #TMP_Frecuencia
(
	Cod_PuntoServicio
	,Id_PuntoServicioTipoOrden
	,Cod_TipoOrdenServicio
	,NomTipoOrdenServicio
	,ClientePrincipal
	,FechaInicioServicio
	,FechaTerminoServicio
	,Apedido
	,Cod_PuntoOrigen
	,NomPuntoOrigen
	,Cod_PuntoDestino
	,NomPuntoDestino
	,NombreTipoMovimiento
	,AtiendeFestivo
	,Domingo
	,Lunes
	,Martes
	,Miercoles
	,Jueves
	,Viernes
	,Sabado
	,Vigente
	,Id_Personal
	,FechaRegistro
)
SELECT 
	Cod_PuntoServicio
	,Id_PuntoServicioTipoOrden
	,Cod_TipoOrdenServicio
	,NomTipoOrdenServicio
	,ClientePrincipal
	,FechaInicioServicio
	,FechaTerminoServicio
	,Apedido
	,Cod_PuntoOrigen
	,NomPuntoOrigen=NOMBREPUNTOSERVICIO1
	,Cod_PuntoDestino
	,NomPuntoDestino=NOMBREPUNTOSERVICIO2
	,NombreTipoMovimiento
	,AtiendeFestivo
	,[Domingo] = ISNULL([Domingo],0)
	,[Lunes] = ISNULL([Lunes],0)
	,[Martes] = ISNULL([Martes],0)
	,[Miercoles] = ISNULL([Miércoles],0)
	,[Jueves] = ISNULL([Jueves],0)
	,[Viernes] = ISNULL([Viernes],0)
	,[Sabado] = ISNULL([Sábado],0)
	,Vigente = ISNULL(Vigente,0)
	,Id_Personal
	,FechaRegistro
FROM
(
	SELECT
		PSTO.Cod_PuntoServicio
		,PSTO.Id_PuntoServicioTipoOrden
		,TOS.Cod_TipoOrdenServicio
		,TOS.NomTipoOrdenServicio
		,ClientePrincipal = CL.RazonSocial
		,PSTO.FechaInicioServicio
		,PSTO.FechaTerminoServicio
		,PSTO.Apedido
		,PSTO.Cod_PuntoOrigen
		,NOMBREPUNTOSERVICIO1=PS1.NOMBREPUNTOSERVICIO
		,PSTO.Cod_PuntoDestino
		,NOMBREPUNTOSERVICIO2=PS2.NOMBREPUNTOSERVICIO
		,PSTO.AtiendeFestivo
		,TM.NombreTipoMovimiento
		,DS.NombreDiaSemana
		,Valor = 1
		,PSTO.Vigente
		,PSTO.Id_Personal
		,PSTO.FechaRegistro
	FROM dbo.tb_PuntoServicioTipoOrden AS PSTO
	LEFT JOIN dbo.tb_FrecuenciaPunto AS F ON PSTO.Id_PuntoServicioTipoOrden = F.Id_PuntoServicioTipoOrden AND ISNULL(F.Vigente,1) = 1 
	INNER JOIN SERVICIO.dbo.TipoOrdenServicio AS TOS ON PSTO.Cod_TipoOrdenServicio = TOS.Cod_TipoOrdenServicio
	LEFT JOIN dbo.Tb_DiaSemana AS DS ON F.Id_DiaSemana = DS.Id_DiaSemana
	INNER JOIN dbo.CIF_Cliente CL ON PSTO.Id_ClientePrincipal = CL.Id_Cliente
	LEFT JOIN dbo.Tb_TipoMovimiento AS TM ON TOS.Movimiento = TM.Abreviado
	INNER JOIN #TMP_Puntos AS T ON PSTO.Cod_PuntoServicio = T.Cod_PuntoServicio
	left JOIN dbo.CIF_PuntoServicio AS PS1 ON PSTO.Cod_PuntoOrigen = PS1.Cod_PuntoServicio
	left JOIN dbo.CIF_PuntoServicio AS PS2 ON PSTO.Cod_PuntoDestino = PS2.Cod_PuntoServicio
	WHERE TOS.Activo = 1
	) AS TABLA
PIVOT
	(
	SUM(valor)
	FOR NombreDiaSemana IN ([Domingo], [Lunes], [Martes], [Miércoles], [Jueves], [Viernes], [Sábado])
	) AS PVT;

--Recupera los valores de los puntos de Servicio activos versus las frecuencias
SELECT 
	SUCURSALBRINKS = S.NombreSucursalBrinks,
	RUTCLIENTE = CL.Id_Cliente +'-'+ dbo.FN_CalculaDigitoRut(CL.Id_Cliente),
	--CL.RAZONSOCIAL,
	CL.NOMBREFANTASIA,
	PS.COD_PUNTOSERVICIO,
	NOMBREPUNTOSERVICIO = (select replace(replace(replace(PS.NOMBREPUNTOSERVICIO, char(9), ' '), char(10), ' '), char(13), ' ') ), -- instrucción elimina los saltos de linea
	NOMBREPUNTOSERVICIOCLIENTE = ISNULL(PS.NOMBREPUNTOSERVICIOCLIENTE,''),
	NumLocal = ISNULL(PS.CodigoInternoCliente,''),
	TIPOPUNTOSERVICIO = TP.NombreTipoPuntoServicio,
	COMUNA = ISNULL(C.NombreComuna, 'Por Definir'),
	TIPOCALLE = TC.NOMBRETIPOCALLE,
	NOMBREDIRECCION = CD.NombreCalle,
	D.NUMERODIRECCION,
	DRU = CASE
			WHEN PS.DentroRadioUrbano = 1 THEN 1
			ELSE 0
		  END,
	FRU = CASE
			WHEN PS.DentroRadioUrbano = 0 THEN 1
			ELSE 0
		  END,
	RESTODIRECCION = ISNULL(D.RestoDireccion,'')
	,Num_Llavero = ISNULL((SELECT TOP 1 MLL.Num_Llavero FROM CORPORATIVO.dbo.MovLlavero AS MLL
				WHERE MLL.Cod_PuntoServicio = PS.Cod_PuntoServicio
				AND MLL.Activo = 1),'')
	,Cod_TipoOrdenServicio
	,NomTipoOrdenServicio = ISNULL(NomTipoOrdenServicio, '')
	,Cod_PuntoOrigen = ISNULL(T.Cod_PuntoOrigen,0)
	,NomPuntoOrigen = ISNULL((select replace(replace(replace(T.NomPuntoOrigen, char(9), ' '), char(10), ' '), char(13), ' ') ),'') -- instrucción elimina los saltos de linea
	,Cod_PuntoDestino = ISNULL(T.Cod_PuntoDestino,0)
	,NomPuntoDestino = ISNULL((select replace(replace(replace(T.NomPuntoDestino, char(9), ' '), char(10), ' '), char(13), ' ') ),'') -- instrucción elimina los saltos de linea
	,ClientePrincipal = ISNULL(ClientePrincipal, '')
	,FechaInicioServicio = ISNULL(CONVERT(VARCHAR,FechaInicioServicio,103), '')
	,FechaTerminoServicio = ISNULL(CONVERT(VARCHAR,FechaTerminoServicio,103), '')
	,Apedido = ISNULL(Apedido,0)
	,NombreTipoMovimiento = ISNULL(NombreTipoMovimiento,'')
	,AtiendeFestivo = ISNULL(AtiendeFestivo,0)
	,Domingo = ISNULL(Domingo,'')
	,Lunes = ISNULL(Lunes, '')
	,Martes = ISNULL(Martes,'')
	,Miercoles = ISNULL(Miercoles,'')
	,Jueves = ISNULL(Jueves,'')
	,Viernes = ISNULL(Viernes,'')
	,Sabado = ISNULL(Sabado,'')
	,DomingoHorario = ISNULL((SELECT TOP 1 CONVERT(VARCHAR,RangoInicio,108) +' a '+ CONVERT(VARCHAR,RangoTermino,108) FROM dbo.Tb_FrecuenciaPunto WHERE Id_PuntoServicioTipoOrden = T.Id_PuntoServicioTipoOrden AND Vigente = 1 AND Id_DiaSemana = 1),'')
	,LunesHorario = ISNULL((SELECT TOP 1 CONVERT(VARCHAR,RangoInicio,108) +' a '+ CONVERT(VARCHAR,RangoTermino,108) FROM dbo.Tb_FrecuenciaPunto WHERE Id_PuntoServicioTipoOrden = T.Id_PuntoServicioTipoOrden AND Vigente = 1 AND Id_DiaSemana = 2),'')
	,MartesHorario = ISNULL((SELECT TOP 1 CONVERT(VARCHAR,RangoInicio,108) +' a '+ CONVERT(VARCHAR,RangoTermino,108) FROM dbo.Tb_FrecuenciaPunto WHERE Id_PuntoServicioTipoOrden = T.Id_PuntoServicioTipoOrden AND Vigente = 1 AND Id_DiaSemana = 3),'')
	,MiercolesHorario = ISNULL((SELECT TOP 1 CONVERT(VARCHAR,RangoInicio,108) +' a '+ CONVERT(VARCHAR,RangoTermino,108) FROM dbo.Tb_FrecuenciaPunto WHERE Id_PuntoServicioTipoOrden = T.Id_PuntoServicioTipoOrden AND Vigente = 1 AND Id_DiaSemana = 4),'')
	,JuevesHorario = ISNULL((SELECT TOP 1 CONVERT(VARCHAR,RangoInicio,108) +' a '+ CONVERT(VARCHAR,RangoTermino,108) FROM dbo.Tb_FrecuenciaPunto WHERE Id_PuntoServicioTipoOrden = T.Id_PuntoServicioTipoOrden AND Vigente = 1 AND Id_DiaSemana = 5),'')
	,ViernesHorario = ISNULL((SELECT TOP 1 CONVERT(VARCHAR,RangoInicio,108) +' a '+ CONVERT(VARCHAR,RangoTermino,108) FROM dbo.Tb_FrecuenciaPunto WHERE Id_PuntoServicioTipoOrden = T.Id_PuntoServicioTipoOrden AND Vigente = 1 AND Id_DiaSemana = 6),'')
	,SabadoHorario = ISNULL((SELECT TOP 1 CONVERT(VARCHAR,RangoInicio,108) +' a '+ CONVERT(VARCHAR,RangoTermino,108) FROM dbo.Tb_FrecuenciaPunto WHERE Id_PuntoServicioTipoOrden = T.Id_PuntoServicioTipoOrden AND Vigente = 1 AND Id_DiaSemana = 7),'')
	,UsuarioModificacion_Punto = Per.NomPersonal +' '+Per.ApePersonal
	,FechaHora_Modificacion_Punto = CONVERT(VARCHAR,PS.FechaRegistro, 103) +' '+CONVERT(VARCHAR,PS.FechaRegistro, 108)
	,UsuarioModificacion_Servicio = ISNULL(Per2.NomPersonal +' '+Per2.ApePersonal,'')
	,FechaHora_Modificacion_Servicio = ISNULL(CONVERT(VARCHAR,T.FechaRegistro, 103) +' '+CONVERT(VARCHAR,T.FechaRegistro, 108),'')
	,Activo_PuntoServicio = PS.Vigente
	,Activo_TipoOrdenServicio = ISNULL(T.Vigente,0)
FROM CIF.dbo.CIF_PuntoServicio AS PS
LEFT JOIN #TMP_Frecuencia AS T ON PS.Cod_PuntoServicio = T.Cod_PuntoServicio 
INnER JOIN CIF.dbo.CIF_Cliente AS CL ON PS.Id_Cliente = Cl.Id_Cliente
INNER JOIN CIF.dbo.CIF_SucursalBrinks AS S ON PS.Cod_SucursalBrinks = S.Cod_SucursalBrinks
INNER JOIN CIF.dbo.CIF_TipoPuntoServicio AS TP ON PS.Cod_TipoPuntoServicio = TP.Cod_TipoPuntoServicio
INNER JOIN CIF.dbo.Tb_Direccion AS D ON PS.Id_Direccion = D.Id_Direccion
INNER JOIN CIF.dbo.Tb_CalleDireccion AS CD ON D.Id_CalleDireccion = CD.Id_CalleDireccion
INNER JOIN cif.DBO.glb_cOMUNA as c ON d.Cod_Comuna = C.Cod_Comuna
LEFT JOIN CIF.dbo.CIF_TipoCalle AS TC ON D.Cod_TipoCalle = TC.Cod_TipoCalle
LEFT JOIN Corporativo.dbo.Personal AS Per ON PS.Id_Personal = Per.Id_Personal
LEFT JOIN Corporativo.dbo.Personal AS Per2 ON T.Id_Personal = Per2.Id_Personal
WHERE 
	--PS.Cod_PuntoServicio = 12694 AND
	((@Cod_SucursalBrinks = 0) OR (PS.Cod_SucursalBrinks = @Cod_SucursalBrinks)) 
	AND ((NomTipoOrdenServicio <> '<NO ASIGNADO>') AND (ISNULL(T.Vigente,0) = 1))
	--and CL.NOMBREFANTASIA like '%EKONO LIMITADA.%'
	--and S.NombreSucursalBrinks like '%santiago%'
	--and NombreTipoMovimiento like '%Retiro - Entrega%'

ORDER BY
	S.NombreSucursalBrinks, CL.RAZONSOCIAL, PS.NombrePuntoServicio;

	
--Elimina tablas temrporales
DROP TABLE #TMP_Puntos;
DROP TABLE #TMP_Frecuencia;