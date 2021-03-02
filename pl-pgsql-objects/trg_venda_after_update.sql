create trigger trg_venda_after_update
after update on venda
for each row
execute procedure trf_venda_after_update();
