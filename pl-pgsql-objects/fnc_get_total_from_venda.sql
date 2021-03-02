create or replace function fnc_get_total_from_venda(venda_id_p integer)
returns decimal(6,2)
language plpgsql
as $fnc_get_total_from_venda$

declare
sumTotal decimal(6,2) := 0;

begin

	select 	coalesce(sum(quantidade * preco_unitario) ,0)
	from	itens
	into	sumTotal
	where	id_venda = venda_id_p;
	
	return sumTotal;
end;
$fnc_get_total_from_venda$;
