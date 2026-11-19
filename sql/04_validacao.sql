-- 04_validacao
-- Nome: As divas e a cacau

-- 1. Conferência de Vendas de Fevereiro de 2025 vs Itens Cadastrados
SELECT 
    v.venda_id,
    v.data_emissao,
    v.produto_id,
    v.qtde_vendida,
    v.valor_unitario,
    (v.qtde_vendida * v.valor_unitario) AS total_item,
    CASE WHEN p.idproduto IS NULL THEN 'PRODUTO NÃO CADASTRADO' ELSE 'OK' END AS status_cadastro
FROM public.venda v
LEFT JOIN public.produtos_filial p ON v.produto_id = p.idproduto
WHERE v.data_emissao BETWEEN '2025-02-01' AND '2025-02-28'
ORDER BY v.data_emissao;

-- 2. Auditoria Inconsistência Temporal nas Entregas de Compras
SELECT 
    pedido_id,
    ordem_compra,
    produto_id,
    data_pedido,
    data_entrega,
    (data_pedido - data_entrega) AS dias_de_inconsistencia
FROM public.pedido_compra
WHERE data_entrega < data_pedido;

-- 3. Confronto de Quantidades de Recebimento (Pedido x NFE)
SELECT 
    pc.ordem_compra,
    pc.produto_id,
    pc.descricao_produto,
    pc.qtde_pedida,
    pc.qtde_entregue AS qtde_registrada_pedido,
    em.nro_nfe,
    em.qtde_recebida AS qtde_registrada_nfe,
    (em.qtde_recebida - pc.qtde_entregue) AS diferenca_fisico_financeiro
FROM public.pedido_compra pc
JOIN public.entradas_mercadoria em ON pc.ordem_compra = em.ordem_compra
ORDER BY pc.ordem_compra;

-- 4. Análise de Produtos Vendidos com Margem Negativa
SELECT 
    idproduto,
    descricao,
    preco_compra,
    preco_venda,
    ROUND(((preco_venda - preco_compra) / preco_compra * 100)::numeric, 2) AS margem_percentual
FROM public.produtos_filial
WHERE preco_venda < preco_compra;

