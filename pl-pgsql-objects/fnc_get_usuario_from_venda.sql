create or replace function fnc_get_usuario_from_venda(venda_id_p integer)
returns integer
language plpgsql
as $fnc_get_usuario_from_venda$

declare
usuario_id_w integer;

begin
	select	v.id_user
	into	usuario_id_w
	from	venda v
	where	v.id = venda_id_p;
	
	return usuario_id_w;
end;
$fnc_get_usuario_from_venda$;
