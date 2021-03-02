-- CREATE TABLES --

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

-- ALTER TABLES --

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

-- VIEWS --

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

-- FUNCTIONS --

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


-- PROCEDURES --

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


create or replace 
procedure prc_log_movimentos(	descricao_p varchar(500),
								valor_anterior_p decimal(6,2),
								valor_atual_p decimal(6,2),
								qtde_anterior_p decimal(6,2),
								qtde_atual_p decimal(6,2),
								user_id_p integer
								)
language plpgsql
as $$
declare

begin

	if (coalesce(user_id_p,0) > 0) then

		insert into log_movimentos (data,
									descricao,
									valor_anterior,
									valor_atual,
									qtde_anterior,
									qtde_atual,
									user_id)
							values (now(),
									descricao_p,
									valor_anterior_p,
									valor_atual_p,
									qtde_anterior_p,
									qtde_atual_p,
									user_id_p);
	end if;

end;
$$;

-- TRIGGER FUNCTIONS --

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


create or replace function trf_venda_validation() 
returns trigger as 
$trf_venda_validation$
			
begin

	if (new.pagto_prazo) and (coalesce(new.numero_parcelas, 0) = 0) then
		RAISE EXCEPTION 'An installment payment order must have more than 0 installments';
	end if;
	
	if (new.pagto_prazo is null)	or (new.pagto_prazo = false) then
		new.pagto_prazo := false;
		new.numero_parcelas := 0;
	end if;		

	if (TG_OP = 'INSERT') then
		
		if (new.status is not null) then
			RAISE EXCEPTION 'A new order must be registered with an empty status';
		end if;
	
		if (new.data is null) then
			new.data := now();
		end if;
		
		RETURN NEW;
		
	elsif (TG_OP = 'UPDATE') then

		if (old.status is not null)
			and (new.status is not null) then
			RAISE EXCEPTION 'Order status already defined as %', old.status;
		end if;
	
		RETURN NEW;
	end if;
	
	RETURN NULL;
end;	
$trf_venda_validation$ language plpgsql;


-- TRIGGERS -- 

create trigger trg_itens_before_insert
before insert on itens
for each row
execute procedure trf_itens_validation();


create trigger trg_venda_after_update
after update on venda
for each row
execute procedure trf_venda_after_update();


create trigger trg_venda_before_insert_update
before insert or update on venda
for each row
execute procedure trf_venda_validation();

-- End of File --