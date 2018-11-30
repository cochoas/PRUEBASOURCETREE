
				P1.NOMPERSONAL+' '+P1.APEPERSONAL AS PERSONADIGITA,
				C.NOMBRESUCURSALBRINKS AS CLVDIGITA,
				OS.NOM_ORIGENORDENSERVICIO,
				PAU.NUM_PAUTA,
				PAU.COD_RUTA,
				R.NOMRUTA AS [NOMBRE RUTA],
				PE.NOMPERSONAL+' '+PE.APEPERSONAL AS MENSAJERO,
				PE2.NOMPERSONAL+' '+PE2.APEPERSONAL AS QUIENMODIFICA, 
				CLI.ID_CLIENTE AS CLIENTE, 
				CLI.RAZONSOCIAL AS BANCO,
				CASE --WHEN T.COD_TIPOORDENSERVICIO = 12 AND O.MOVIMIENTO = ''E'' AND PD.NOMBREPUNTOSERVICIO LIKE ''%WAGNER%'' THEN  ''PUNTO DESTINO WAGNER.'' 
					 --WHEN OS.NOM_ORIGENORDENSERVICIO NOT like ''%FRECUENCIA%'' AND T.COD_TIPOORDENSERVICIO = 12 AND O.MOVIMIENTO = ''E'' AND PD.NOMBREPUNTOSERVICIO LIKE ''%TG%'' THEN  ''PUNTO DESTINO BANCO.'' 
					 --WHEN OS.NOM_ORIGENORDENSERVICIO NOT like ''%FRECUENCIA%'' AND T.COD_TIPOORDENSERVICIO = 12 AND O.MOVIMIENTO = ''E'' AND PD.NOMBREPUNTOSERVICIO LIKE ''%(TG)%'' THEN  ''PUNTO DESTINO BANCO.''
					 --WHEN OS.NOM_ORIGENORDENSERVICIO NOT like ''%FRECUENCIA%'' AND T.COD_TIPOORDENSERVICIO = 12 AND O.MOVIMIENTO = ''E'' AND PD.NOMBREPUNTOSERVICIO LIKE ''%%T.G%%''  THEN  ''PUNTO DESTINO BANCO.'' 
					 --WHEN OS.NOM_ORIGENORDENSERVICIO NOT like ''%FRECUENCIA%'' AND T.COD_TIPOORDENSERVICIO = 12 AND O.MOVIMIENTO = ''E'' AND PD.NOMBREPUNTOSERVICIO LIKE ''%TESORERIA REGIONAL%'' THEN ''PUNTO DESTINO BANCO.''
					 --WHEN O.COD_TIPOORDENSERVICIO = 20 AND E.COD_ESTADOORDENSERVICIO = 31 THEN ''CARGA NN ASIGNADA'' /*EXCLUYE PLANIFICACI�N Y CARGA DE ATM, ADEMAS EN ESTADO CANCELADAS.*/
					 --WHEN OS.NOM_ORIGENORDENSERVICIO = ''CUSTODIA'' AND O.COD_PUNTOORIGEN = 0 THEN ''CUSTODIA - FOFI''--/*EN ORIGEN CUSTODIA Y SIN PUNTO ORIGEN*/
 					 WHEN E.COD_ESTADOORDENSERVICIO In (3, 31, 65) THEN 'ESTADO CANCELADAS.' --/*EN ESTADO CANCELADAS Y ANULADAS.*/
					 --WHEN OS.NOM_ORIGENORDENSERVICIO NOT like ''%FRECUENCIA%'' AND T.COD_TIPOORDENSERVICIO = 1 AND PO.NOMBREPUNTOSERVICIO LIKE ''%BRINKS%'' AND PD.NOMBREPUNTOSERVICIO LIKE ''%BRINKS%'' THEN  ''CUSTODIA - FOFI'' 
					 WHEN S.Cod_SucursalBrinks = 2 AND (PD.NOMBREPUNTOSERVICIO LIKE '%LOS ANDES%' or PD.NOMBREPUNTOSERVICIO LIKE '%SAN FELIPE%' or PO.NOMBREPUNTOSERVICIO LIKE '%LOS ANDES%' or PO.NOMBREPUNTOSERVICIO LIKE '%SAN FELIPE%') THEN  'ANOMALIA VI�A' 
				ELSE 'NORMAL' END AS ANOMALIA,
				CASE WHEN PAU.COD_HANDHELD IS NOT NULL AND PAU.COD_HANDHELD <> '' AND PAU.COD_HANDHELD <> 0 THEN 'CON HANDHELD' ELSE '' END AS HANDHELD
				,EP.NomEstadoPauta AS ESTADO_PAUTA
				,Nov.NombreNovedad as Novedad
	FROM SERVICIO.DBO.ORDENSERVICIO AS O
		INNER JOIN SERVICIO.DBO.ESTADOORDENSERVICIO AS E	ON O.COD_ESTADOORDENSERVICIO = E.COD_ESTADOORDENSERVICIO
		INNER JOIN SERVICIO.DBO.TIPOORDENSERVICIO	AS T	ON O.COD_TIPOORDENSERVICIO = T.COD_TIPOORDENSERVICIO
		INNER JOIN SERVICIO.DBO.TIPOPROGRAMACION	AS P	ON O.COD_TIPOPROGRAMACION = P.COD_TIPOPROGRAMACION
		LEFT OUTER JOIN CUSTODIA.DBO.TB_TIPOVALOR	AS TV	ON O.COD_TIPOVALOR = TV.COD_TIPOVALOR
		LEFT JOIN CIF.DBO.CIF_PUNTOSERVICIO			AS PO	ON O.COD_PUNTOORIGEN = PO.COD_PUNTOSERVICIO
		LEFT JOIN CIF.DBO.CIF_PUNTOSERVICIO			AS PD	ON O.COD_PUNTODESTINO = PD.COD_PUNTOSERVICIO 
		INNER JOIN SERVICIO.DBO.TB_ESTADOOM			AS EOM	ON E.ID_ESTADOOM = EOM.ID_ESTADOOM
		LEFT JOIN CIF.DBO.CIF_SUCURSALBRINKS		AS S	ON CONVERT(INT, O.COD_SUCURSALBRINKS) = S.COD_SUCURSALBRINKS --*** se cambia a Left
		LEFT JOIN CORPORATIVO..PERSONAL			AS P1	ON O.INS_ID				= P1.USERID --*** se cambia a Left
		left JOIN CIF..CIF_SUCURSALBRINKS			AS C	ON C.COD_SUCURSALBRINKS+0.152	= P1.COD_SUCURSALBRINKS --*** se cambia a Left
		LEFT JOIN SERVICIO..TB_ORIGENORDENSERVICIO AS OS	ON O.ID_ORIGENORDENSERVICIO = OS.ID_ORIGENORDENSERVICIO
		LEFT JOIN TRANSPORTE..ORDENSERVICIO			AS OST	ON OST.NUM_ORDENSERVICIO = O.NUM_ORDENSERVICIO
		LEFT JOIN TRANSPORTE..PAUTAATENCION			AS PA	ON PA.NUM_ATENCION = OST.NUM_ATENCION AND PA.ACTIVO = 1
		LEFT JOIN TRANSPORTE..PAUTA					AS PAU	ON PAU.NUM_PAUTA	= PA.NUM_PAUTA
		LEFT JOIN TRANSPORTE..RUTA					AS R	ON R.COD_RUTA		= PAU.COD_RUTA
		LEFT JOIN CORPORATIVO..PERSONAL				AS PE	ON PE.ID_PERSONAL	= PAU.ID_MENSAJERO	
		LEFT JOIN CORPORATIVO..PERSONAL				AS PE2	ON PE2.USERID		= O.MOD_ID
	    LEFT JOIN [SERVICIO].[DBO].[TB_ORDENSERVICIOFAMILIA] AS OSF ON OSF.ID_ORDENSERVICIOFAMILIA = T.ID_ORDENSERVICIOFAMILIA
	    INNER JOIN CIF.DBO.CIF_CLIENTE			AS CLI ON CLI.ID_CLIENTEBRINKS = O.ID_CLIENTEPRINCIPAL
		LEFT JOIN [TRANSPORTE].[DBO].[ESTADOPAUTA] AS EP ON PAU.COD_ESTADOPAUTA = EP.COD_ESTADOPAUTA
		LEFT JOIN Servicio.[dbo].[Tb_NovedadOrdenServicio] AS nos ON O.Num_OrdenServicio = nos.Num_OrdenServicio
		LEFT JOIN [SERVICIO].[dbo].[Tb_Novedad] AS nov ON nos.Id_Novedad = Nov.Id_Novedad 
	WHERE o.FechaServicio >= '20170125' and o.FechaServicio < '20170126'
	WHERE  kjdsfjs�djf�ds 
	�sdkf�dskf�odsjf
	order by 12 asc
	