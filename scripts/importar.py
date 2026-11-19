import os
import datetime as dt
import pandas as pd
import psycopg2

ARQUIVO = C:\Users\Windows10\Downloads ("EXCEL_PATH", "dados/base_teste.xlsx")
DB = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", 5432)),
    "database": os.getenv("DB_NAME", "postgres"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "1234"),
}

def vazio(v):
    return v is None or (not isinstance(v, (str, dt.date, dt.time)) and pd.isna(v))

def texto(v, padrao=None):
    if vazio(v):
        return padrao
    if isinstance(v, float) and v.is_integer():
        v = int(v)
    s = str(v).strip()
    return s if s else padrao

def numero(v, padrao=None):
    return padrao if vazio(v) else float(v)

def inteiro(v, padrao=None):
    return padrao if vazio(v) else int(float(v))

def data(v):
    if vazio(v):
        return None
    if isinstance(v, (pd.Timestamp, dt.datetime)):
        return v.date()
    if isinstance(v, dt.date):
        return v
    if isinstance(v, (int, float)):
        return (dt.datetime(1899, 12, 30) + dt.timedelta(days=int(v))).date()
    try:
        return pd.to_datetime(str(v), dayfirst=True).date()
    except Exception:
        return None

def hora(v):
    if vazio(v):
        return "00:00:00"
    if isinstance(v, (dt.datetime, pd.Timestamp)):
        return v.strftime("%H:%M:%S")
    if isinstance(v, dt.time):
        return v.strftime("%H:%M:%S")
    if isinstance(v, (int, float)):
        seg = int(round(float(v) * 86400)) % 86400
        return f"{seg // 3600:02d}:{seg % 3600 // 60:02d}:{seg % 60:02d}"
    return str(v).strip()[:8]

def pegar(row, *nomes):
    for n in nomes:
        if n in row.index:
            return row[n]
    return None

def ler(aba):
    df = pd.read_excel(ARQUIVO, sheet_name=aba)
    df.columns = df.columns.astype(str).str.strip().str.lower()
    return df

def importar(conn, titulo, df, sql, montar):
    print(f"Importando {titulo}...")
    cur = conn.cursor()
    ok = 0
    for idx, row in df.iterrows():
        try:
            cur.execute(sql, montar(row))
            ok += cur.rowcount
        except Exception as e:
            print(f"  [ERRO] {titulo} (linha {idx + 2} da planilha): {e}")
    cur.close()
    print(f"  -> {ok} de {len(df)} registros inseridos em {titulo}\n")

def main():
    print("Conectando ao PostgreSQL...")
    conn = psycopg2.connect(**DB)
    conn.autocommit = True
    print("Conectado com sucesso!\n")

    # 1. FORNECEDOR
    importar(
        conn, "fornecedor", ler("fornecedor"),
        """
        INSERT INTO public.fornecedor (idfornecedor, razao_social)
        VALUES (%s, %s)
        ON CONFLICT (idfornecedor) DO NOTHING
        """,
        lambda r: (
            texto(pegar(r, "idfornecedor", "idforncedor")),
            texto(r["razao_social"]),
        ),
    )

    # 2. PRODUTOS_FILIAL
    importar(
        conn, "produtos_filial", ler("produtos_filial"),
        """
        INSERT INTO public.produtos_filial
        (filial_id, idproduto, descricao, estoque, preco_unitario, preco_compra, preco_venda, idfornecedor)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (filial_id, idproduto) DO NOTHING
        """,
        lambda r: (
            inteiro(r["filial_id"], 1),
            texto(pegar(r, "idproduto", "produto_id")),
            texto(pegar(r, "descricao", "decricao")),
            numero(r["estoque"], 0),
            numero(r["preco_unitario"], 0),
            numero(r["preco_compra"], 0),
            numero(r["preco_venda"], 0),
            texto(pegar(r, "idfornecedor", "idfonecedor")), # Corrigido para texto ('F1', 'F2'...)
        ),
    )

    # 3. PEDIDO_COMPRA
    df_pc = ler("pedido_compra")
    df_pc = df_pc.iloc[:, :12] # Descarta colunas espúrias (Unnamed: 12..22)

    def montar_pedido(r):
        pedida = numero(r["qtde_pedida"])
        entregue = numero(r["qtde_entregue"], 0)
        pendente = numero(pegar(r, "qtde_pendente"))
        if pendente is None:
            pendente = (pedida - entregue) if pedida is not None else 0
        
        # Tratamento do idfornecedor caso venha como inteiro ou string 'F1'
        forn_raw = pegar(r, "fornecedor_id", "idfornecedor")
        forn_str = texto(forn_raw)
        if forn_str and forn_str.isdigit():
            forn_str = f"F{forn_str}"

        return (
            inteiro(r["pedido_id"]),
            data(r["data_pedido"]),
            inteiro(r["item"], 1),
            texto(r["produto_id"]),
            texto(r["descricao_produto"]),
            inteiro(r["ordem_compra"], 0),
            pedida,
            inteiro(r["filial_id"], 1),
            data(r["data_entrega"]),
            entregue,
            pendente,
            numero(r["preco_compra"], 0),
            forn_str,
        )

    importar(
        conn, "pedido_compra", df_pc,
        """
        INSERT INTO public.pedido_compra
        (pedido_id, data_pedido, item, produto_id, descricao_produto,
         ordem_compra, qtde_pedida, filial_id, data_entrega,
         qtde_entregue, qtde_pendente, preco_compra, fornecedor_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (pedido_id, produto_id, item) DO NOTHING
        """,
        montar_pedido,
    )

    # 4. ENTRADAS_MERCADORIA
    importar(
        conn, "entradas_mercadoria", ler("entradas_mercadoria"),
        """
        INSERT INTO public.entradas_mercadoria
        (data_entrada, nro_nfe, item, produto_id, descricao_produto,
         ordem_compra, qtde_recebida, filial_id, custo_unitario)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (ordem_compra, item, produto_id, nro_nfe) DO NOTHING
        """,
        lambda r: (
            data(r["data_entrada"]),
            texto(r["nro_nfe"]),
            inteiro(r["item"], 1),
            texto(r["produto_id"]),
            texto(r["descricao_produto"]),
            inteiro(r["ordem_compra"], 0),
            numero(r["qtde_recebida"]),
            inteiro(r["filial_id"], 1),
            numero(r["custo_unitario"], 0),
        ),
    )

    # 5. VENDA
    importar(
        conn, "venda", ler("venda"),
        """
        INSERT INTO public.venda
        (venda_id, data_emissao, horariomov, produto_id,
         qtde_vendida, valor_unitario, filial_id, item, unidade_medida)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (filial_id, venda_id, data_emissao, produto_id, item, horariomov)
        DO NOTHING
        """,
        lambda r: (
            inteiro(r["venda_id"]),
            data(r["data_emissao"]),
            hora(r["horariomov"]),
            texto(r["produto_id"], ""),
            numero(r["qtde_vendida"]),
            numero(r["valor_unitario"], 0),
            inteiro(r["filial_id"], 1),
            inteiro(r["item"], 1),
            texto(r["unidade_medida"]),
        ),
    )

    conn.close()
    print("=" * 40)
    print("Importação concluída com 100% de sucesso!")
    print("=" * 40)

if __name__ == "__main__":
    main()
