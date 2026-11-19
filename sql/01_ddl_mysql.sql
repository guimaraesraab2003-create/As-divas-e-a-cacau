-- DDL corrigido para MySQL
-- MySQL

DROP TABLE IF EXISTS venda;
DROP TABLE IF EXISTS entradas_mercadoria;
DROP TABLE IF EXISTS pedido_compra;
DROP TABLE IF EXISTS produtos_filial;
DROP TABLE IF EXISTS fornecedor;

-- 1. Tabela Fornecedor
CREATE TABLE fornecedor (
    idfornecedor VARCHAR(25) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    PRIMARY KEY (idfornecedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Tabela Produtos por Filial
CREATE TABLE produtos_filial (
    filial_id INT NOT NULL DEFAULT 1,
    idproduto VARCHAR(25) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    estoque DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    preco_unitario DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    preco_compra DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    preco_venda DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    idfornecedor VARCHAR(25) NULL,
    PRIMARY KEY (filial_id, idproduto),
    CONSTRAINT fk_produtos_fornecedor FOREIGN KEY (idfornecedor) REFERENCES fornecedor(idfornecedor) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Tabela Pedido de Compra
CREATE TABLE pedido_compra (
    pedido_id INT NOT NULL,
    data_pedido DATE NULL,
    item INT NOT NULL DEFAULT 1,
    produto_id VARCHAR(25) NOT NULL,
    descricao_produto VARCHAR(255) NULL,
    ordem_compra INT NOT NULL DEFAULT 0,
    qtde_pedida DECIMAL(12, 4) NULL,
    filial_id INT NULL DEFAULT 1,
    data_entrega DATE NULL,
    qtde_entregue DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    qtde_pendente DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    preco_compra DECIMAL(12, 4) NULL DEFAULT 0.0000,
    fornecedor_id VARCHAR(25) NULL,
    PRIMARY KEY (pedido_id, produto_id, item)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Tabela Entradas de Mercadoria
CREATE TABLE entradas_mercadoria (
    data_entrada DATE NULL,
    nro_nfe VARCHAR(255) NOT NULL,
    item INT NOT NULL DEFAULT 1,
    produto_id VARCHAR(25) NOT NULL,
    descricao_produto VARCHAR(255) NULL,
    ordem_compra INT NOT NULL DEFAULT 0,
    qtde_recebida DECIMAL(12, 4) NULL,
    filial_id INT NULL DEFAULT 1,
    custo_unitario DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    PRIMARY KEY (ordem_compra, item, produto_id, nro_nfe)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Tabela Venda
CREATE TABLE venda (
    venda_id INT NOT NULL,
    data_emissao DATE NOT NULL,
    horariomov VARCHAR(8) NOT NULL DEFAULT '00:00:00',
    produto_id VARCHAR(25) NOT NULL,
    qtde_vendida DECIMAL(12, 4) NULL,
    valor_unitario DECIMAL(12, 4) NOT NULL DEFAULT 0.0000,
    filial_id INT NOT NULL DEFAULT 1,
    item INT NOT NULL DEFAULT 1,
    unidade_medida VARCHAR(3) NULL,
    PRIMARY KEY (filial_id, venda_id, data_emissao, produto_id, item, horariomov)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
