--1. Total vendido em quantidade e em R$ por produto em Fevereiro de 2025
SELECT 
    v.produto_id,
    COALESCE(p.descricao, 'Produto Sem Cadastro') AS descricao_produto,
    SUM(v.qtde_vendida) AS total_quantidade_vendida,
    ROUND(SUM(v.qtde_vendida * v.valor_unitario)::numeric, 2) AS valor_total_reais
FROM public.venda v
LEFT JOIN public.produtos_filial p 
    ON v.produto_id = p.idproduto
WHERE v.data_emissao >= '2025-02-01' 
  AND v.data_emissao <= '2025-02-28'
GROUP BY 
    v.produto_id, 
    p.descricao
ORDER BY 
    v.produto_id;


-- 2. Produtos requisitados (pedido de compra) e não recebidos (entradas_mercadoria)
-- Abordagem 1: Produtos em pedido_compra cujas ordens de compra não possuem registro em entradas_mercadoria
SELECT DISTINCT
    pc.pedido_id,
    pc.ordem_compra,
    pc.produto_id,
    pc.descricao_produto,
    pc.qtde_pedida,
    pc.data_pedido
FROM public.pedido_compra pc
LEFT JOIN public.entradas_mercadoria em 
    ON pc.ordem_compra = em.ordem_compra 
   AND pc.produto_id = em.produto_id
WHERE em.ordem_compra IS NULL 
   OR pc.ordem_compra = 0;


-- Abordagem 2: Produtos onde a quantidade recebida em entradas_mercadoria é inferior à pedida
SELECT 
    pc.produto_id,
    pc.descricao_produto,
    SUM(pc.qtde_pedida) AS total_qtde_pedida,
    COALESCE(SUM(em.qtde_recebida), 0) AS total_qtde_recebida,
    (SUM(pc.qtde_pedida) - COALESCE(SUM(em.qtde_recebida), 0)) AS saldo_pendente
FROM public.pedido_compra pc
LEFT JOIN public.entradas_mercadoria em 
    ON pc.ordem_compra = em.ordem_compra 
   AND pc.produto_id = em.produto_id
GROUP BY 
    pc.produto_id, 
    pc.descricao_produto
HAVING COALESCE(SUM(em.qtde_recebida), 0) < SUM(pc.qtde_pedida)
ORDER BY 
    pc.produto_id;--
