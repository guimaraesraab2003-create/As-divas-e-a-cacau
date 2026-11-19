-- 03_transformacoes
-- Nome: Sabrina Giovanna 
(Transformações de Dados da Parte 3 (Inclui Trigger)
-- Equipe: As divas e a cacau

SELECT 
    CONCAT(pc.produto_id, COALESCE(' - ' || pc.descricao_produto, '')) AS "Produto",
    SUM(pc.qtde_pedida) AS "Qtde Requisitada",
    TO_CHAR(MIN(pc.data_pedido), 'DD/MM/YYYY') AS "Data Solicitação"
FROM public.pedido_compra pc
GROUP BY pc.produto_id, pc.descricao_produto
HAVING SUM(pc.qtde_pedida) > 10
ORDER BY pc.produto_id;


-- 4. Trigger que gera automaticamente um novo idfornecedor na tabela de produtos
-- Relacionado à tabela de fornecedor (PostgreSQL)

-- Passo 4.1: Criar a função da Trigger
CREATE OR REPLACE FUNCTION public.fn_gerar_idfornecedor_produto()
RETURNS TRIGGER AS $$
DECLARE
    v_max_id INT;
    v_novo_id_str VARCHAR(25);
BEGIN
    -- Se o idfornecedor for nulo ou vazio ao inserir/atualizar um produto:
    IF NEW.idfornecedor IS NULL OR TRIM(NEW.idfornecedor) = '' THEN
        
        -- Busca o maior número entre os fornecedores cadastrados (ex.: extrai número de 'F12')
        SELECT COALESCE(MAX(CAST(REGEXP_REPLACE(idfornecedor, '\D', '', 'g') AS INT)), 0) + 1
        INTO v_max_id
        FROM public.fornecedor;

        v_novo_id_str := 'F' || v_max_id;

        -- Garante que o fornecedor exista na tabela fornecedor
        INSERT INTO public.fornecedor (idfornecedor, razao_social)
        VALUES (v_novo_id_str, 'Fornecedor Automático ' || v_novo_id_str)
        ON CONFLICT (idfornecedor) DO NOTHING;

        -- Atribui o novo ID gerado ao produto
        NEW.idfornecedor := v_novo_id_str;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Passo 4.2: Criar a Trigger associada à tabela produtos_filial
DROP TRIGGER IF EXISTS trg_gerar_idfornecedor ON public.produtos_filial;

CREATE TRIGGER trg_gerar_idfornecedor
BEFORE INSERT OR UPDATE ON public.produtos_filial
FOR EACH ROW
EXECUTE FUNCTION public.fn_gerar_idfornecedor_produto();
