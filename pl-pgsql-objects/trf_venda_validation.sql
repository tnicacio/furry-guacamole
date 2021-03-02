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
