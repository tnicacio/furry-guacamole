create table usuario(
id serial primary key,
nome varchar(50),
email varchar(50),
senha varchar(50)
);

create table log_movimentos(
id serial primary key,
data timestamp,
descricao varchar(500),
valor_anterior decimal(6,2),
valor_atual decimal(6,2),
qtde_anterior decimal(6,2),
qtde_atual decimal(6,2),
user_id integer not null
);

create table venda(
id serial primary key,
data date,
pagto_prazo boolean,
numero_parcelas integer,
status char,
id_user integer not null
);

create table produto(
id serial primary key,
descricao varchar(50),
preco decimal(6,2),
qtde_estoque decimal(6,2),
estoque_minimo decimal(6,2),
qtde_reservada decimal(6,2)
);

create table itens(
id_produto integer not null,
id_venda integer not null,
quantidade decimal(6,2),
preco_unitario decimal(6,2),
primary key(id_produto, id_venda)
);

create table parcelamento(
id serial primary key,
id_venda integer not null,
valor decimal(6,2),
data_vencimento date
);


alter table venda
add constraint fk_venda_usuario
foreign key (id_user) references usuario;

alter table if exists itens 
add constraint fk_itens_produto
foreign key (id_produto) references produto;

alter table if exists itens
add constraint fk_itens_venda
foreign key (id_venda) references venda;

alter table if exists parcelamento
add constraint fk_parcelamento_venda
foreign key (id_venda) references venda;

alter table log_movimentos
add constraint fk_logmovimentos_usuario
foreign key (user_id) references usuario;
