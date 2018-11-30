USE [CUSDOCUMENTOS]
GO
SET TRAN ISOLATION LEVEL READ UNCOMMITTED; 

declare   @FechaInicio            DATETIME
declare   @FechaTermino            DATETIME
declare   @Id_ClientePrincipal    VARCHAR(25)
declare   @Id_ClienteDependiente    VARCHAR(25)
declare   @Num_CuentaCustodia    FLOAT
declare   @Cod_TipoValor            VARCHAR(5)
declare   @Cod_SucursalBrinks    FLOAT
declare   @Cod_TipoGestion        VARCHAR(5)
declare   @Cod_TipoCuenta        INT
declare   @EnStock                INT = 0

 SET   @FechaInicio			  = '01-12-2016'   
 SET   @FechaTermino          = '31-12-2016'
 SET   @Id_ClientePrincipal   = '(152)970060006'
 SET   @Id_ClienteDependiente = '(152)966717505'
 SET   @Num_CuentaCustodia    = 10639799
 SET   @Cod_TipoValor         = '15203'
 SET   @Cod_SucursalBrinks    = 2.125
 SET   @Cod_TipoGestion       = '04105'
 SET   @Cod_TipoCuenta        = 15
 SET   @EnStock               = 0

declare @cod_pais int

SELECT  @cod_pais = convert(int,ValorParametro)
FROM CORPORATIVO..PARAMETROS
WHERE NomParametro = 'PAIS'

IF @FechaInicio    = @FechaTermino
  SET @EnStock = 1


select @Cod_TipoCuenta

IF @Cod_TipoGestion = '04105'                                -- EN CARTERA
BEGIN
    IF    (@Cod_TipoCuenta <= 15) or (@Cod_TipoCuenta > 21)    -- TIPOS DE CUENTAS PARA AGRUPACION
    BEGIN
	select ('PRIMER IF')
        SELECT
             cd.NomCliente                                AS NomClienteDependiente
            ,cc.Cod_TipoCuenta
            ,tc.NomTipoCuenta
            ,u.Cod_Remesa
            ,u.Cod_Unidad
            ,u.PreparadoPor
            ,SUBSTRING('000',1,3-LEN(CONVERT(VARCHAR(3),d.Cod_BancoDocumento)) )+CONVERT(VARCHAR(3),d.Cod_BancoDocumento)        AS Banco
            ,CONVERT(BIGINT,d.Num_CuentaDocumento)        AS Cuenta
            ,CONVERT(BIGINT,d.Num_SerieDocumento)        AS Serie
            ,CONVERT(VARCHAR(10),d.FechaDocumento,105)    AS FechaDoc
            ,CONVERT(VARCHAR(10),d.FechaDeposito,105)    AS FechaDep
            ,CONVERT(BIGINT,d.MontoDocumento)            AS MontoDoc
            ,CONVERT(VARCHAR(10),d.FechaIngreso,105)    AS FechaIng
            ,CONVERT(INT,d.Cod_PlazaDocumento)            AS Plaza
            ,ISNULL(d.Id_Girador,'')                    AS RutGirador
--            ,pd.NomPuntoServicio                        AS NomPuntoDependiente
            ,pd.NOMBREPUNTOSERVICIO                        AS NomPuntoDependiente
			,cc.Num_CuentaCustodia

        FROM
             CUENTACUSTODIA cc
                INNER JOIN TIPOCUENTA tc ON    cc.Cod_TipoCuenta = tc.Cod_TipoCuenta
--                INNER JOIN CORPORATIVO..PUNTOSERVICIO pd ON cc.Cod_PuntoDependiente        = pd.Cod_PuntoServicio
                INNER JOIN DOCUMENTO d WITH (NOLOCK) ON
                        cc.Id_ClientePrincipal        = d.Id_ClientePrincipal
                    AND    cc.Id_ClienteDependiente    = d.Id_ClienteDependiente
                    AND    cc.Cod_PuntoDependiente        = d.Cod_PuntoDependiente
                    AND    cc.Num_CuentaCustodia        = d.Num_CuentaCustodia
                    AND    cc.Cod_TipoValor            = d.Cod_TipoValor
--               INNER JOIN CORPORATIVO..CLIENTE cd ON cc.Id_ClienteDependiente    = cd.Id_Cliente
               LEFT JOIN PROCESAMIENTO..UNIDAD    u WITH (NOLOCK) ON
                        d.Cod_Remesa    = u.Cod_Remesa
                    AND    d.Num_Unidad    = u.Num_Unidad
          inner join CIF.dbo.FX_CLIENTE_FULL_BRINKS ( @cod_pais,1)   as cd   on cd.ID_CLIENTEBRINKS  = d.Id_ClienteDependiente
          inner join CIF..CIF_PUNTOSERVICIO                          as pd   on pd.COD_PUNTOSERVICIO = d.Cod_PuntoDependiente

        WHERE
			cc.Id_ClientePrincipal        = @Id_ClientePrincipal
			AND    cc.Id_ClienteDependiente    = @Id_ClienteDependiente
			AND    cc.Num_CuentaCustodia        = @Num_CuentaCustodia
			AND    cc.Cod_TipoValor            = @Cod_TipoValor
			AND    cc.Cod_TipoCuenta            = @Cod_TipoCuenta
			--AND    convert(float, (pd.Cod_SucursalBrinks  + 0.152))        = @Cod_SucursalBrinks
			--AND    (d.FechaIngreso            <= @FechaTermino
				--AND    d.FechaDeposito                >  @FechaTermino )
				OR    (d.FechaDeposito            = '30-12-1899'
				AND    d.FechaDevolucion            >  @FechaTermino 
				AND		d.FechaIngreso			<= @FechaTermino    ) 
			--AND (@EnStock = 0 or d.EnStock = 1)
			--AND    d.Verificado                = 1
			ORDER BY
             FechaDep
            ,Banco
            ,Cuenta
            ,Serie
    END


    IF    (@Cod_TipoCuenta >= 16) and (@Cod_TipoCuenta <= 21)        -- TIPOS DE CUENTA EN GARANTÍA
    BEGIN
		select ('SEGUNDO IF')
        SELECT
             u.Cod_Remesa
            ,u.Cod_Unidad
            ,u.PreparadoPor
            ,SUBSTRING('000',1,3-LEN(CONVERT(VARCHAR(3),d.Cod_BancoDocumento)) )+CONVERT(VARCHAR(3),d.Cod_BancoDocumento)        AS Banco
            ,CONVERT(BIGINT,d.Num_CuentaDocumento)        AS Cuenta
            ,CONVERT(BIGINT,d.Num_SerieDocumento)        AS Serie
            ,CONVERT(VARCHAR(10),d.FechaDocumento,105)    AS FechaDoc
            ,CONVERT(VARCHAR(10),d.FechaDeposito,105)    AS FechaDep
            ,CONVERT(BIGINT,d.MontoDocumento)            AS MontoDoc
            ,CONVERT(VARCHAR(10),d.FechaIngreso,105)    AS FechaIng
            ,d.Cod_PlazaDocumento                        AS Plaza
            ,ISNULL(d.Id_Girador,'')                    AS RutGirador
--            ,pd.NomPuntoServicio                        AS NomPuntoDependiente
            ,pd.NOMBREPUNTOSERVICIO                        AS NomPuntoDependiente

            ,cd.NomCliente                                AS NomClienteDependiente
            ,cc.Cod_TipoCuenta
            ,tc.NomTipoCuenta
			,cc.Num_CuentaCustodia
        FROM
            CUENTACUSTODIA    cc
--                INNER JOIN CORPORATIVO..PUNTOSERVICIO pd ON cc.Cod_PuntoDependiente    = pd.Cod_PuntoServicio
                INNER JOIN TIPOCUENTA tc ON cc.Cod_TipoCuenta            = tc.Cod_TipoCuenta
--                INNER JOIN CORPORATIVO..CLIENTE    cd ON cc.Id_ClienteDependiente    = cd.Id_Cliente
                INNER JOIN DOCUMENTO d WITH (NOLOCK)ON
                        cc.Id_ClientePrincipal        = d.Id_ClientePrincipal
                    AND    cc.Id_ClienteDependiente    = d.Id_ClienteDependiente
                    AND    cc.Cod_PuntoDependiente        = d.Cod_PuntoDependiente
                    AND    cc.Num_CuentaCustodia        = d.Num_CuentaCustodia
                    AND    cc.Cod_TipoValor            = d.Cod_TipoValor
                LEFT JOIN PROCESAMIENTO..UNIDAD u WITH (NOLOCK) ON
                        d.Cod_Remesa    = u.Cod_Remesa
                    AND    d.Num_Unidad    = u.Num_Unidad
         inner join CIF.dbo.FX_CLIENTE_FULL_BRINKS ( @cod_pais,1)   as cd   on cd.ID_CLIENTEBRINKS  = d.Id_ClienteDependiente
          inner join CIF..CIF_PUNTOSERVICIO                          as pd   on pd.COD_PUNTOSERVICIO = d.Cod_PuntoDependiente

        Where
            cc.Id_ClientePrincipal        = @Id_ClientePrincipal
        AND    cc.Id_ClienteDependiente    = @Id_ClienteDependiente
        --AND    cc.Num_CuentaCustodia        = @Num_CuentaCustodia
        AND    cc.Cod_TipoValor            = @Cod_TipoValor
       -- AND    cc.Cod_TipoCuenta            = @Cod_TipoCuenta
        --AND    convert(float, (pd.Cod_SucursalBrinks  + 0.152))        = @Cod_SucursalBrinks
        AND    d.FechaIngreso                <= @FechaTermino
		and d.FechaIngreso >= @FechaInicio
        AND (@EnStock = 0 or d.EnStock = 1)
        AND    d.Verificado                = 1
        AND    CONVERT(VARCHAR(10),d.FechaDevolucion,105) = '30-12-1899'
        ORDER BY
             FechaDep
            ,Banco
            ,Cuenta
            ,Serie
    END
END
----------26----------------

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON


