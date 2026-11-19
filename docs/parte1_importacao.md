# Parte 1: Documentação do processo de importação

## Ferramenta utilizada

## Estrutura da planilha

| Aba | Coluna | Tipo | Observação |
| | Aba | Coluna | Tipo | Observação |
| --- | --- | --- | --- |
| `fornecedor` | `idfornecedor` | `VARCHAR(25)` | Chave primária. Na planilha vinha como `F1`, `F2`... (corrigido erro de typo `idforncedor` do DDL original). |
| `fornecedor` | `razao_social` | `VARCHAR(255)` | Razão social do fornecedor. |
| `produtos_filial` | `filial_id` | `INT` | Identificador da filial (todos valor 1 na amostra). |
| `produtos_filial` | `idproduto` | `VARCHAR(25)` | Identificador do produto (`P1` a `P20`). |
| `produtos_filial` | `descricao` | `VARCHAR(255)` | Descrição do produto (corrigido typo `decricao` do DDL original). |
| `produtos_filial` | `estoque` | `NUMERIC(12,4)` | Quantidade em stock. |
| `produtos_filial` | `preco_unitario` | `NUMERIC(12,4)` | Preço unitário cadastrado. |
| `produtos_filial` | `preco_compra` | `NUMERIC(12,4)` | Custo/Preço de compra. |
| `produtos_filial` | `preco_venda` | `NUMERIC(12,4)` | Preço de venda ao público. |
| `produtos_filial` | `idfornecedor` | `VARCHAR(25)` | Chave estrangeira para `fornecedor` (no DDL vinha incorretamente como `INT`). |
| `pedido_compra` | `pedido_id` | `INT` | Identificador do pedido de compra. |
| `pedido_compra` | `data_pedido` | `DATE` | Data de emissão do pedido. |
| `pedido_compra` | `item` | `INT` | Número do item no pedido. |
| `pedido_compra` | `produto_id` | `VARCHAR(25)` | Código do produto solicitado. |
| `pedido_compra` | `descricao_produto` | `VARCHAR(255)` | Descrição do produto. |
| `pedido_compra` | `ordem_compra` | `INT` | Identificador da Ordem de Compra (11 registos com valor 0). |
| `pedido_compra` | `qtde_pedida` | `NUMERIC(12,4)` | Quantidade solicitada no pedido. |
| `pedido_compra` | `filial_id` | `INT` | Código da filial. |
| `pedido_compra` | `data_entrega` | `DATE` | Data prevista/realizada de entrega. |
| `pedido_compra` | `qtde_entregue` | `NUMERIC(12,4)` | Quantidade registada como entregue. |
| `pedido_compra` | `preco_compra` | `NUMERIC(12,4)` | Preço unitário negociado de compra. |
| `pedido_compra` | `fornecedor_id` | `VARCHAR(25)` | Identificador do fornecedor (convertido de número para `F1`..`F20`). |
| `pedido_compra` | `Unnamed: 12` a `22` | *Ignorado* | Colunas espúrias/deslocadas à direita no Excel (ignoradas no mapeamento). |
| `entradas_mercadoria` | `data_entrada` | `DATE` | Data da entrada física/emissão da nota. |
| `entradas_mercadoria` | `nro_nfe` | `VARCHAR(255)` | Número da Nota Fiscal de Entrada. |
| `entradas_mercadoria` | `item` | `INT` | Item da nota fiscal. |
| `entradas_mercadoria` | `produto_id` | `VARCHAR(25)` | Código do produto recebido. |
| `entradas_mercadoria` | `descricao_produto` | `VARCHAR(255)` | Descrição do produto. |
| `entradas_mercadoria` | `ordem_compra` | `INT` | Chave de ligação à tabela `pedido_compra`. |
| `entradas_mercadoria` | `qtde_recebida` | `NUMERIC(12,4)` | Quantidade efetivamente recebida e conferida na nota. |
| `entradas_mercadoria` | `filial_id` | `INT` | Código da filial de destino. |
| `entradas_mercadoria` | `custo_unitario` | `NUMERIC(12,4)` | Custo unitário constante na NFE. |
| `venda` | `venda_id` | `INT` | Identificador único da venda. |
| `venda` | `data_emissao` | `DATE` | Data da transação de venda. |
| `venda` | `horariomov` | `VARCHAR(8)` | Horário do movimento. |
| `venda` | `produto_id` | `VARCHAR(25)` | Código do produto vendido (`P1` a `P28`). |
| `venda` | `qtde_vendida` | `NUMERIC(12,4)` | Quantidade vendida. |
| `venda` | `valor_unitario` | `NUMERIC(12,4)` | Valor unitário praticado na venda. |
| `venda` | `filial_id` | `INT` | Código da filial onde ocorreu a venda (1, 2 ou 3). |
| `venda` | `item` | `INT` | Item da venda. |
| `venda` | `unidade_medida` | `VARCHAR(3)` | Unidade de medida (ex.: `UN`). |
--- | --- | --- | --- |
|  |  |  |  |

## Erros encontrados no DDL e como foram corrigidos

| Tabela | Erro | Correção |

| fornecedor | coluna inexistente na primary key | Removida a coluna idproduto da chave primária |
| fornecedor | erro de digitação no nome da coluna idforncedor | renomear a coluna para idfornecedor |
| produtos_filial | erro de digitação das colunas decricao e idfonecedor | Renomeadas as colunas descricao e idfornecedor |
| produtos_filial | tipo de dado incompatível em idfornecedor (int4) | alterado o tipo da coluna |
| entradas_mercadoria | coluna ordem_compra usente na definição da tabela | Adicionada a coluna ordem_compra na estrutura de colunas da tabela entradas_mercadoria |


## Erros encontrados no script de importação e como foram corrigidos

| Erro | Efeito | Correção |

| produtos_filial e entradas_mercadoria | Erro de sintaxe Python (aspas triplas da string SQL abertas antes do parâmetro conn na função importar)	Ajustada a ordem dos argumentos e o fechamento/abertura correta das aspas triplas na c | Ajustada a ordem dos argumentos e o fechamento/abertura correta das aspas triplas na chamada da função importar |
| produtos_filial | Incompatibilidade de tipo ao converter idfornecedor com inteiro(...) (transformando 'F1' em None/erro) | Removida a conversão para inteiro, mantendo idfornecedor como string/texto na leitura e inserção |
| pedido_compra | Leitura de 11 colunas espúrias/fantasmas (Unnamed: 12 a Unnamed: 22) presentes à direita na aba do Excel | Aplicado fatiamento estrito com df.iloc[:, :12] para importar apenas as 12 colunas válidas | 
| Configuração de Conexão | Credenciais e senha do banco expostas em texto claro diretamente no código-fonte | Substituídos os valores fixos por leitura de variáveis de ambiente |  
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
