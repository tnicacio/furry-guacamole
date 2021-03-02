create or replace function trf_itens_validation() 
returns trigger as 
$trf_itens_validation$

declare

preco_w				produto.preco%type;
qt_estoque_w		produto.qtde_estoque%type;
qt_estoque_minimo_w	produto.estoque_minimo%type;
qt_reservada_w		produto.qtde_reservada%type;
new_qt_reservada_w	produto.qtde_reservada%type;
new_qt_estoque_w	produto.qtde_estoque%type;

begin

select	coalesce(p.preco,0),
		coalesce(p.qtde_estoque,0),
		coalesce(p.estoque_minimo,0),
		coalesce(p.qtde_reservada,0)
into	preco_w,
		qt_estoque_w,
		qt_estoque_minimo_w,
		qt_reservada_w
from	produto p
where	p.id = new.id_produto;

raise notice 'new.id_produto: %; qtde_estoque: %; new.quantidade: %; estoque_minimo: %', new.id_produto, qt_estoque_w, new.quantidade, qt_estoque_minimo_w;

if ((qt_estoque_w - new.quantidade) >= qt_estoque_minimo_w) then
	
	new.preco_unitario := preco_w;
	
	new_qt_reservada_w := qt_reservada_w + new.quantidade;
	new_qt_estoque_w := qt_estoque_w - new.quantidade;
	
	update 	produto
	set		qtde_reservada = new_qt_reservada_w,
			qtde_estoque = new_qt_estoque_w
	where 	produto.id = new.id_produto;
	
	
	call prc_log_movimentos('Reserving items | Order id = ' || new.id_venda ||
							' | Reserved Quantity(' || new.quantidade || ') from product id = ' ||  new.id_produto || 
							' | New produto.qtde_estoque =  ' || new_qt_estoque_w ||
							' | Registering old and new Quantities in Stock'
							, preco_w, preco_w, qt_estoque_w, new_qt_estoque_w, fnc_get_usuario_from_venda(new.id_venda));
	
	return NEW;	
	
end if;

raise exception 'Not enough items in stock';
	
end;	
$trf_itens_validation$ language plpgsql;
