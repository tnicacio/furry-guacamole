create trigger trg_itens_before_insert
before insert on itens
for each row
execute procedure trf_itens_validation();
