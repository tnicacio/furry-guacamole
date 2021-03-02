create trigger trg_venda_before_insert_update
before insert or update on venda
for each row
execute procedure trf_venda_validation();
