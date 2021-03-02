create or replace procedure prc_generate_installments(venda_id_p integer,interval_p interval)
language plpgsql
as $$
declare

month_counter		integer;
num_parcelas_w		venda.numero_parcelas%type;
total_w				itens.preco_unitario%type;
monthly_payment_w	itens.preco_unitario%type;

begin

total_w 		:= fnc_get_total_from_venda(venda_id_p);
num_parcelas_w 	:= fnc_get_nr_parcelas_from_venda(venda_id_p);

if (num_parcelas_w = 0) or (total_w = 0) then
	return;
end if;

monthly_payment_w = total_w/num_parcelas_w;

month_counter := 0;
loop

	insert into parcelamento(id_venda, valor, data_vencimento)
	values(venda_id_p, monthly_payment_w, CURRENT_DATE + (month_counter * interval_p));

	month_counter = month_counter + 1;
	exit when month_counter = num_parcelas_w;
end loop;

end;
$$;
