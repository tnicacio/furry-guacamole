create or replace function trf_venda_after_update() 
returns trigger as 
$trf_venda_after_update$

declare
cur_venda_dados cursor (id_p integer)
				for
				select 	i.produto_id,
						i.itens_qt_produto,
						i.qt_estoque,
						i.qt_reservada,
						(i.qt_reservada - i.itens_qt_produto) as new_qt_reservada_w,
						(i.qt_estoque + i.itens_qt_produto) as new_cancel_estoque_quantidade_w,
						i.itens_preco_unit as preco_antigo_w,
						i.produto_preco_atual as preco_novo_w,
						i.usuario_venda
				from	v_itens i
				where	i.venda_id = id_p;
			
begin

	if 	(new.status is null) or
		(coalesce(new.status,'xpto') = coalesce(old.status,'xpto')) then
		return NULL;
	end if;

	if (new.status = 'O') then -- Venda confirmada
		
		for cur in cur_venda_dados(new.id) loop
		
			update 	produto p
			set		qtde_reservada = cur.new_qt_reservada_w
			where	p.id = cur.produto_id;
			
			RAISE NOTICE 'confirming order id = % with product id = %', new.id, cur.produto_id;
			call prc_log_movimentos('Confirming order id = ' || new.id || ' | Shipping reserved quantity(' || cur.itens_qt_produto || 
									') from product id = ' || cur.produto_id || ' | Current produto.qtde_estoque =  ' || cur.qt_estoque ||
									' | Registering old and new Reserved Quantities '
									, cur.preco_antigo_w, cur.preco_novo_w, cur.qt_reservada, cur.new_qt_reservada_w, cur.usuario_venda);
		
		end loop;
		
		if (old.pagto_prazo) and (old.numero_parcelas > 0) then
			call prc_generate_installments(new.id,'30 days');
		end if;
		
		return NEW;
		
	elsif (new.status = 'X') then	-- Venda cancelada
	
		for cur in cur_venda_dados(new.id) loop
		
			update 	produto p
			set		qtde_reservada = cur.new_qt_reservada_w,
					qtde_estoque = cur.new_cancel_estoque_quantidade_w
			where	p.id = cur.produto_id;
			
			RAISE NOTICE 'canceling order id = % with product id = %', new.id, cur.produto_id;
			call prc_log_movimentos('Canceling order id = ' || new.id || ' | Returning reserved quantity(' || cur.itens_qt_produto || 
									') from product id = ' || cur.produto_id || ' | New produto.qtde_reservada =  ' || cur.new_qt_reservada_w ||
									' | Registering old and new Quantities in Stock '
									, cur.preco_antigo_w, cur.preco_novo_w, cur.qt_estoque, cur.new_cancel_estoque_quantidade_w, cur.usuario_venda);
		
		end loop;
		
		return NEW;
	end if;
	
	return NULL; 
end;	
$trf_venda_after_update$ language plpgsql;
