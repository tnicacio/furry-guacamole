create or replace function fnc_get_nr_parcelas_from_venda(venda_id_p integer)
returns integer
language plpgsql
as $fnc_get_nr_parcelas_from_venda$

declare
num_parcelas_w		venda.numero_parcelas%type;

begin

	select	coalesce(numero_parcelas, 0)
	into	num_parcelas_w
	from	venda
	where	id = venda_id_p;
	
	return num_parcelas_w;

end;
$fnc_get_nr_parcelas_from_venda$;
