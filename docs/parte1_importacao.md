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
