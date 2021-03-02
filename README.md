# Trabalho de Bancos de Dados 2 - IFC

Trabalho desenvolvido para a matéria de Banco de Dados 2 do curso Tecnólogo em Análise e Desenvolvimento de Sistemas do IFC, campus Blumenau - SC.

## Modelo Lógico
![Modelo Lógico](https://github.com/tnicacio/furry-guacamole/blob/main/modelo-logico.png?raw=true)

## Como testar
No seu banco de dados pl-pgsql preferido, execute o script contido no arquivo schema-all-in-one-file.sql. </br>
Alternativamente, o banco de dados pode ser populado executando-se tables/tables.sql para criar as tabelas e suas relações, e em seguida os objetos da pasta pl-pgsql-objects na seguinte ordem: </br>
1 - Views (v_) </br>
2 - Functions (fnc_) </br>
3 - Procedures (prc_) </br>
4 - Trigger Functions (trg_) </br>
5 - Triggers (trg_) </br>

## Observações sobre as regras de negócios pedidas no exercício
Para ver o exercício, abra o arquivo exercise.pdf.

### Questão 1:
Fiz a lógica pra registrar log ao confirmar ou cancelar uma venda, ou ao inserir itens da venda. Pois se fosse para também registrar na tabela log_movimentos qnd se alterasse um produto, não se teria o usuario q fez a alteração. </br>
### Questão 4:
Coloquei pra se inserir o número de parcelas quando fosse inserido o registro da venda. Por exemplo, caso a venda possua pagmento parcelado, precisa-se inserir o número de parcelas logo no registro da venda, e esse comportamento é consistido através da utilização da trigger function trf_venda_validation. </br>
De forma que as parcelas são geradas quando se dá o update do status para confirmar ou cancelar a venda.

## Tecnologias Utilizadas
- PostgreSQL 13
- pgAdmin
- Notepad++
