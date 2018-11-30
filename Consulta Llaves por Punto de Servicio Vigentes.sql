/***
 *      _      _                        _____  _            _____                 _      _        __      ___                  _            
 *     | |    | |                      |  __ \| |          / ____|               (_)    (_)       \ \    / (_)                | |           
 *     | |    | | __ ___   _____  ___  | |__) | |_ ___    | (___   ___ _ ____   ___  ___ _  ___    \ \  / / _  __ _  ___ _ __ | |_ ___  ___ 
 *     | |    | |/ _` \ \ / / _ \/ __| |  ___/| __/ _ \    \___ \ / _ \ '__\ \ / / |/ __| |/ _ \    \ \/ / | |/ _` |/ _ \ '_ \| __/ _ \/ __|
 *     | |____| | (_| |\ V /  __/\__ \ | |    | || (_) |   ____) |  __/ |   \ V /| | (__| | (_) |    \  /  | | (_| |  __/ | | | ||  __/\__ \
 *     |______|_|\__,_| \_/ \___||___/ |_|     \__\___(_) |_____/ \___|_|    \_/ |_|\___|_|\___/      \/   |_|\__, |\___|_| |_|\__\___||___/
 *                                                                                                             __/ |                        
 *                                                                                                            |___/                         
 */
-- select GETDATE(), CAST(GETDATE() as date)
SET TRAN ISOLATION LEVEL READ UNCOMMITTED; 
declare @FechaHasta datetime = CAST(GETDATE() as date);
select NombreSucursalbrinks, p.Cod_puntoServicio,
       M.Num_llavero, 
	   NombreFantasia, NombrePuntoservicio, 
	   convert(varchar, LL.INS_DT , 112)+replace(convert(varchar(8), LL.INS_DT , 108),':','') AS CODIGO/*,
	   convert(varchar, m.Ins_dt, 105) as FechaCreacion,
	   convert(varchar, m.Ins_Dt, 108) as HoraCreacion -- */
from corporativo..movllavero m inner join cif..cif_puntoservicio  p  on (m.cod_puntoservicio = p.cod_puntoservicio)
                                                  inner join cif..cif_sucursalbrinks sb on (p.cod_sucursalbrinks = sb.cod_sucursalbrinks)
												  inner join cif..cif_cliente c on (p.id_cliente = c.id_cliente)
												  INNER JOIN corporativo..llavero LL ON M.NUM_LLAVERO = LL.NUM_LLAVERO 
where activo = 1
and p.Vigente=1
and (@FechaHasta is null or ll.FechaCreacion <= @FechaHasta)
order by p.cod_sucursalbrinks, num_llavero;


