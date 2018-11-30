USE SERVICIO

declare @cant int

set @cant = (select count (*) from OrdenServicio where Id_OrigenOrdenServicio = 0 )
select (@cant)

select top  (@cant) oss.Id_OrigenOrdenServicio, ori.Nom_OrigenOrdenServicio, oss.Num_OrdenServicio, eos.NomEstadoOrdenServicio, oss.Cod_EstadoOrdenServicio, tos.NomTipoOrdenServicio, oss.Movimiento, oss.FechaOrdenServicio, oss.FechaServicio, oss.Cod_SucursalBrinks 
from SERVICIO..OrdenServicio (NOLOCK) as oss 
inner join SERVICIO..tb_OrigenOrdenServicio (NOLOCK) as ori on ori.Id_OrigenOrdenServicio = oss.Id_OrigenOrdenServicio
inner join SERVICIO..TipoOrdenServicio (NOLOCK) as tos on tos.Cod_TipoOrdenServicio = oss.Cod_TipoOrdenServicio
inner join SERVICIO..EstadoOrdenServicio (NOLOCK) as eos on eos.Cod_EstadoOrdenServicio = oss.Cod_EstadoOrdenServicio
where oss.Num_Solicitud = 0 and oss.Id_OrigenOrdenServicio <> 0 
order by oss.FechaOrdenServicio desc

--select count (*) from OrdenServicio 
