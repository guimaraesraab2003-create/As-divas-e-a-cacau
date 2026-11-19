# Parte 4: Roteiro de validação com o cliente (fevereiro/2025)

## 1. Pontos a validar

- **Produtos vendidos sem registo em `produtos_filial`:** Existem vendas em fevereiro/2025 para códigos de produto (`P22` a `P27` em fevereiro, e `P21` a `P28` no geral) que não constam na tabela `produtos_filial` (que vai de `P1` a `P20`). Validar se faltam cadastros ou se houve erro de digitação/importação.
- **Ordens de compra zeradas (`ordem_compra = 0`):** Há registos em `pedido_compra` com `ordem_compra = 0` e `qtde_entregue = 0`. Confirmar com o cliente se são pedidos ainda não emitidos/sem ordem gerada ou registos inválidos.
- **Datas de entrega anteriores à data do pedido (`data_entrega < data_pedido`):** Existem pedidos em que a data de entrega está anterior à data de emissão do pedido. Validar se houve troca de datas, entrega antecipada registada de forma incorreta ou erro de sistema.
- **Divergência entre quantidade entregue no pedido e quantidade recebida na entrada:** As quantidades em `pedido_compra.qtde_entregue` não coincidem com `entradas_mercadoria.qtde_recebida` para as mesmas ordens de compra. Confirmar qual é a fonte oficial de conferência de estoque/faturação.
- **Preço de venda inferior ao preço de compra:** Alguns produtos em `produtos_filial` (`P1`, `P8`, `P15` e `P18`) apresentam `preco_venda < preco_compra`. Validar se se trata de promoção/liquidação autorizada ou erro de precificação.


## 2. Técnicas para garantir exatidão e precisão

- **Conferência cruzada entre tabelas (integridade referencial e lógica):** Cruzar `venda` com `produtos_filial`, e `pedido_compra` com `entradas_mercadoria` por `ordem_compra` e `produto_id`, para detetar órfãos, divergências de quantidade e quebras de fluxo.
- **Regras de validação temporal e de domínio:** Verificar se datas de entrega são posteriores ou iguais às datas de pedido, se quantidades/valores são consistentes e se não há colunas extras/deslocadas na origem (`base_teste.xlsx`).
- **Controlo de totais e agregações por período:** Comparar somatórios (`COUNT(*)`, `SUM(qtde_vendida)` e `SUM(qtde_vendida * valor_unitario)`) antes e depois da carga, isolando o recorte de fevereiro/2025.
- **Restrições e automações na base de dados:** Aplicar chaves primárias, chaves estrangeiras e triggers (como a geração automática de `idfornecedor` quando aplicável) para evitar registos incompletos ou inconsistentes. 

## 3. Consultas preparadas para a reunião

1. **Vendas de fevereiro/2025 e verificação de cadastro de produto:** Lista as vendas do período (`2025-02-01` a `2025-02-28`), calcula o valor total por item (`qtde_vendida * valor_unitario`) e sinaliza se o `produto_id` existe em `produtos_filial` (`OK` ou `PRODUTO NÃO CADASTRADO`).
2. **Inconsistência temporal em pedidos de compra:** Retorna os pedidos onde `data_entrega < data_pedido` e calcula a diferença em dias entre ambas as datas para facilitar a investigação.
3. **Confronto entre pedido de compra e entrada de mercadoria:** Junta `pedido_compra` e `entradas_mercadoria` por `ordem_compra`, exibindo `qtde_pedida`, `qtde_entregue` e `qtde_recebida`, além da diferença entre o que foi recebido na nota/entrada e o que consta como entregue no pedido.
4. **Produtos com preço de venda abaixo do preço de compra:** Lista os itens em `produtos_filial` onde `preco_venda < preco_compra`, mostrando os valores e a margem percentual negativa.

## Erros encontrados nos dados

| Tabela | Problema | Quantidade | Consulta que mostra |
| --- | --- | --- | --- |
| `venda` | Produtos vendidos sem correspondência em `produtos_filial` (`P21`–`P28`; 9 em fev/2025) | 13 registos (9 em fev/2025) | Consulta 1 em `sql/04_validacao.sql` |
| `pedido_compra` | Pedidos com `ordem_compra = 0` e `qtde_entregue = 0` | 11 registos | Consulta 3 em `sql/04_validacao.sql` (ou filtro `ordem_compra = 0`) |
| `pedido_compra` | Data de entrega anterior à data do pedido (`data_entrega < data_pedido`) | 20 registos | Consulta 2 em `sql/04_validacao.sql` |
| `pedido_compra` / `entradas_mercadoria` | Divergência entre `qtde_entregue` e `qtde_recebida` na mesma ordem de compra | 18 ordens (`OC 1` a `18`) | Consulta 3 em `sql/04_validacao.sql` |
| `produtos_filial` | `preco_venda` menor que `preco_compra` (`P1`, `P8`, `P15`, `P18`) | 4 registos | Consulta 4 em `sql/04_validacao.sql` |


