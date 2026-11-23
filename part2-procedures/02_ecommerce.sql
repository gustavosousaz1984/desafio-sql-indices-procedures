-- ============================================================
--  PARTE 2 — Procedure de manipulação de dados
--  Cenário: E-COMMERCE
--  Desafio DIO · SQL Database Specialist
--  Arquivo 2/2 — Procedure de produtos
-- ============================================================
--
--  Mesma estrutura da procedure de universidade, aplicada a um
--  cenário de e-commerce (produtos de uma loja).
--
--     p_opcao = 1 → SELECT   (consulta)
--     p_opcao = 2 → INSERT   (inserção)
--     p_opcao = 3 → UPDATE   (atualização)
--     p_opcao = 4 → DELETE   (remoção)
--
--  ATENÇÃO: sempre selecionar o BANCO antes de criar a procedure.
-- ============================================================

-- ① Seleciona o banco de dados ANTES de criar a procedure
CREATE DATABASE IF NOT EXISTS ecommerce
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE ecommerce;      -- <<< banco selecionado

-- ------------------------------------------------------------
-- Tabela de exemplo: PRODUTO
-- ------------------------------------------------------------
DROP TABLE IF EXISTS produto;
CREATE TABLE produto (
  id_produto INT           NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(120)  NOT NULL,
  categoria  VARCHAR(80),
  preco      DECIMAL(10,2) NOT NULL,
  estoque    INT           NOT NULL DEFAULT 0,
  ativo      BOOLEAN       NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id_produto)
) ENGINE=InnoDB;

INSERT INTO produto (nome, categoria, preco, estoque, ativo) VALUES
  ('Resina composta odontológica', 'Resinas',       180.00, 120, TRUE),
  ('Fotopolimerizador LED',        'Equipamentos',  850.00,  15, TRUE),
  ('Kit de clareamento',           'Clareamento',   320.00,  40, TRUE);


-- ============================================================
--  CRIAÇÃO DA PROCEDURE
-- ============================================================
DELIMITER $$

CREATE PROCEDURE sp_gestao_produto (
  -- Variáveis de RECEBIMENTO
  IN p_id_produto INT,
  IN p_nome       VARCHAR(120),
  IN p_categoria  VARCHAR(80),
  IN p_preco      DECIMAL(10,2),
  IN p_estoque    INT,

  -- Variável de CONTROLE (define a ação)
  IN p_opcao      INT
)
BEGIN
  -- --------------------------------------------------------
  -- Estrutura condicional: CASE sobre a variável de controle
  -- --------------------------------------------------------
  CASE p_opcao

    -- ① SELECT — consulta por id (ou todos se id = 0)
    WHEN 1 THEN
      IF COALESCE(p_id_produto, 0) = 0 THEN
        SELECT * FROM produto ORDER BY id_produto;
      ELSE
        SELECT * FROM produto WHERE id_produto = p_id_produto;
      END IF;

    -- ② INSERT — inserção de novo produto
    WHEN 2 THEN
      INSERT INTO produto (nome, categoria, preco, estoque, ativo)
      VALUES (p_nome, p_categoria, p_preco, p_estoque, TRUE);
      SELECT LAST_INSERT_ID() AS novo_id_produto;

    -- ③ UPDATE — atualização de preço/estoque do produto
    WHEN 3 THEN
      UPDATE produto
         SET nome      = COALESCE(p_nome, nome),
             categoria = COALESCE(p_categoria, categoria),
             preco     = COALESCE(p_preco, preco),
             estoque   = COALESCE(p_estoque, estoque)
       WHERE id_produto = p_id_produto;
      SELECT ROW_COUNT() AS linhas_atualizadas;

    -- ④ DELETE — remoção do produto
    WHEN 4 THEN
      DELETE FROM produto WHERE id_produto = p_id_produto;
      SELECT ROW_COUNT() AS linhas_removidas;

    -- Opção inválida
    ELSE
      SELECT 'Opção inválida. Use: 1=SELECT, 2=INSERT, 3=UPDATE, 4=DELETE'
             AS aviso;

  END CASE;
END$$

DELIMITER ;


-- ============================================================
--  CHAMADAS DA PROCEDURE (testando cada ação)
-- ============================================================

-- ① SELECT: listar todos os produtos (id = 0 → todos)
CALL sp_gestao_produto(0, NULL, NULL, NULL, NULL, 1);

-- ② INSERT: inserir novo produto
CALL sp_gestao_produto(NULL, 'Autoclave de bancada', 'Equipamentos',
                       2400.00, 8, 2);

-- ③ UPDATE: reajustar estoque do produto id = 1
CALL sp_gestao_produto(1, NULL, NULL, NULL, 150, 3);

-- ④ DELETE: remover o produto id = 3
CALL sp_gestao_produto(3, NULL, NULL, NULL, NULL, 4);

-- ⑤ SELECT final: confere o estado da tabela
CALL sp_gestao_produto(0, NULL, NULL, NULL, NULL, 1);
