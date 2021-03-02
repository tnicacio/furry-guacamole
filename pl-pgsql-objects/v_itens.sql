create or replace view v_itens as

select  p.id								produto_id,
		v.id								venda_id,
		p.descricao							produto_descricao,
		coalesce(p.preco, 0) 				produto_preco_atual,
		coalesce(p.qtde_estoque, 0) 		qt_estoque,
		coalesce(p.estoque_minimo, 0) 		qt_estoque_minimo,
		coalesce(p.qtde_reservada, 0) 		qt_reservada,
		coalesce(i.quantidade, 0)			itens_qt_produto,
		coalesce(i.preco_unitario,0)		itens_preco_unit,
		v.data								venda_data,
		coalesce(v.pagto_prazo, false)		venda_pagto_prazo,
		coalesce(v.numero_parcelas, 0)		venda_numero_parcelas,
		v.status							venda_status,
		v.id_user	 						usuario_venda
from	produto p,
		venda v,
		itens i
where	i.id_produto = p.id
and		i.id_venda = v.id;
