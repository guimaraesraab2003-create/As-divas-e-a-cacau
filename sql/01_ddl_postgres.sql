-- DDL corrigido para PostgreSQL
-- PostgreSQL

DROP TABLE IF EXISTS public.venda CASCADE;
DROP TABLE IF EXISTS public.entradas_mercadoria CASCADE;
DROP TABLE IF EXISTS public.pedido_compra CASCADE;
DROP TABLE IF EXISTS public.produtos_filial CASCADE;
DROP TABLE IF EXISTS public.fornecedor CASCADE;

-- 1. Tabela Fornecedor
CREATE TABLE public.fornecedor (
    idfornecedor VARCHAR(25) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    CONSTRAINT fornecedor_pkey PRIMARY KEY (idfornecedor)
);

-- 2. Tabela Produtos por Filial
CREATE TABLE public.produtos_filial (
    filial_id INT NOT NULL DEFAULT 1,
    idproduto VARCHAR(25) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    estoque NUMERIC(12, 4) NOT NULL DEFAULT 0,
    preco_unitario NUMERIC(12, 4) NOT NULL DEFAULT 0,
    preco_compra NUMERIC(12, 4) NOT NULL DEFAULT 0,
    preco_venda NUMERIC(12, 4) NOT NULL DEFAULT 0,
    idfornecedor VARCHAR(25) NULL,
    CONSTRAINT produtos_filial_pkey PRIMARY KEY (filial_id, idproduto),
    CONSTRAINT fk_produtos_fornecedor FOREIGN KEY (idfornecedor) REFERENCES public.fornecedor(idfornecedor) ON UPDATE CASCADE ON DELETE SET NULL
);

-- 3. Tabela Pedido de Compra
CREATE TABLE public.pedido_compra (
    pedido_id INT NOT NULL,
    data_pedido DATE NULL,
    item INT NOT NULL DEFAULT 1,
    produto_id VARCHAR(25) NOT NULL,
    descricao_produto VARCHAR(255) NULL,
    ordem_compra INT NOT NULL DEFAULT 0,
    qtde_pedida NUMERIC(12, 4) NULL,
    filial_id INT NULL DEFAULT 1,
    data_entrega DATE NULL,
    qtde_entregue NUMERIC(12, 4) NOT NULL DEFAULT 0,
    qtde_pendente NUMERIC(12, 4) NOT NULL DEFAULT 0,
    preco_compra NUMERIC(12, 4) NULL DEFAULT 0,
    fornecedor_id VARCHAR(25) NULL,
    CONSTRAINT pedido_compra_pkey PRIMARY KEY (pedido_id, produto_id, item)
);

-- 4. Tabela Entradas de Mercadoria
CREATE TABLE public.entradas_mercadoria (
    data_entrada DATE NULL,
    nro_nfe VARCHAR(255) NOT NULL,
    item INT NOT NULL DEFAULT 1,
    produto_id VARCHAR(25) NOT NULL,
    descricao_produto VARCHAR(255) NULL,
    ordem_compra INT NOT NULL DEFAULT 0,
    qtde_recebida NUMERIC(12, 4) NULL,
    filial_id INT NULL DEFAULT 1,
    custo_unitario NUMERIC(12, 4) NOT NULL DEFAULT 0,
    CONSTRAINT entradas_mercadoria_pkey PRIMARY KEY (ordem_compra, item, produto_id, nro_nfe)
);

-- 5. Tabela Venda
CREATE TABLE public.venda (
    venda_id INT NOT NULL,
    data_emissao DATE NOT NULL,
    horariomov VARCHAR(8) NOT NULL DEFAULT '00:00:00',
    produto_id VARCHAR(25) NOT NULL,
    qtde_vendida NUMERIC(12, 4) NULL,
    valor_unitario NUMERIC(12, 4) NOT NULL DEFAULT 0,
    filial_id INT NOT NULL DEFAULT 1,
    item INT NOT NULL DEFAULT 1,
    unidade_medida VARCHAR(3) NULL,
    CONSTRAINT pk_consumo PRIMARY KEY (filial_id, venda_id, data_emissao, produto_id, item, horariomov)
);
