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
