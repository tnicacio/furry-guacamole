insert into usuario (nome, email, senha) values
('Tiago','tiago@gmail.com','123456'),
('Nala Mala', 'nala@mala.com','0987654321'),
('Sofia','sofia@fia.com','12344321');

insert into produto (descricao, preco, qtde_estoque, estoque_minimo, qtde_reservada) values
('Pizza', 11.59, 400, 40, 0),
('Nuggets', 16.97, 500, 45, 0),
('Pão de Batata', 4.50, 350, 30, 0);

/*
	trf_venda_validation -> trg_venda_before_insert_update;
*/
insert into venda (data, pagto_prazo, numero_parcelas, id_user) values 
('22/02/2021', false, null, 1),
('23/02/2021',false, null, 2),
('24/02/2021', true, 3, 1);

/*
	prc_log_movimentos -> trf_itens_validation -> trg_itens_before_insert;
*/
insert into itens (id_produto, id_venda, quantidade) values
(2, 1, 4),
(1, 2, 3),
(3, 2, 2),
(2, 3, 2),
(1, 3, 4);

/*
	trf_venda_validation -> trg_venda_before_insert_update;
	prc_log_movimentos -> trf_venda_after_update -> trg_venda_after_update;
*/
update venda
set status = 'O'
where id = 3;

update venda
set status = 'X'
where id = 2;

