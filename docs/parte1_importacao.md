# Parte 1: Documentação do processo de importação

## Ferramenta utilizada

## Estrutura da planilha

| Aba | Coluna | Tipo | Observação |
| --- | --- | --- | --- |
|  |  |  |  |

## Erros encontrados no DDL e como foram corrigidos

| Tabela | Erro | Correção |
| fornecedor | coluna inexistente na primary key | Removida a coluna idproduto da chave primária |
| fornecedor | erro de digitação no nome da coluna idforncedor | renomear a coluna para idfornecedor |
| produtos_filial | erro de digitação das colunas decricao e idfonecedor | Renomeadas as colunas descricao e idfornecedor |
| produtos_filial | tipo de dado incompatível em idfornecedor (int4) | alterado o tipo da coluna |
| fornecedor | coluna inexistente na primary key | Removida a coluna idproduto da chave primária |

## Erros encontrados no script de importação e como foram corrigidos

| Erro | Efeito | Correção |
| --- | --- | --- |
|  |  |  |

## Tratamentos aplicados aos dados

(conversão de tipos, validações, normalizações)

## Conferência final

| Tabela | Linhas na planilha | Linhas no banco |
| --- | --- | --- |
| fornecedor |  |  |
| produtos_filial |  |  |
| pedido_compra |  |  |
| entradas_mercadoria |  |  |
| venda |  |  |
