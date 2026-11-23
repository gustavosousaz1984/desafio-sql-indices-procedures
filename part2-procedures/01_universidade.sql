-- ============================================================
--  PARTE 2 — Procedure de manipulação de dados
--  Cenário: UNIVERSIDADE
--  Desafio DIO · SQL Database Specialist
--  Arquivo 1/2 — Procedure de alunos
-- ============================================================
--
--  OBJETIVO:
--  Procedure com instruções de INSERÇÃO, REMOÇÃO e ATUALIZAÇÃO,
--  todas dentro de estruturas condicionais (IF / CASE).
--
--  · Variáveis de RECEBIMENTO  → recebem os dados do chamador
--  · Variável de CONTROLE      → decide a ação a executar
--
--     p_opcao = 1 → SELECT   (consulta)
--     p_opcao = 2 → INSERT   (inserção)
--     p_opcao = 3 → UPDATE   (atualização)
--     p_opcao = 4 → DELETE   (remoção)
--
--  ATENÇÃO: sempre selecionar o BANCO antes de criar a procedure.
-- ============================================================

-- ① Seleciona o banco de dados ANTES de criar a procedure
CREATE DATABASE IF NOT EXISTS universidade
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE universidade;   -- <<< banco selecionado

-- ------------------------------------------------------------
-- Tabela de exemplo: ALUNO
-- ------------------------------------------------------------
DROP TABLE IF EXISTS aluno;
CREATE TABLE aluno (
  id_aluno   INT          NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(100) NOT NULL,
  matricula  VARCHAR(20)  NOT NULL,
  curso      VARCHAR(80),
  nota       DECIMAL(4,2),
  ativo      BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id_aluno),
  UNIQUE KEY uq_aluno_matricula (matricula)
) ENGINE=InnoDB;

INSERT INTO aluno (nome, matricula, curso, nota, ativo) VALUES
  ('Ana Souza',    '2026001', 'Análise de Dados',  8.50, TRUE),
  ('Bruno Lima',   '2026002', 'Engenharia',         7.20, TRUE),
  ('Carla Mendes', '2026003', 'Direito',            9.10, TRUE);


-- ============================================================
--  CRIAÇÃO DA PROCEDURE
-- ============================================================
DELIMITER $$

CREATE PROCEDURE sp_gestao_aluno (
  -- Variáveis de RECEBIMENTO
  IN p_id_aluno  INT,
  IN p_nome      VARCHAR(100),
  IN p_matricula VARCHAR(20),
  IN p_curso     VARCHAR(80),
  IN p_nota      DECIMAL(4,2),

  -- Variável de CONTROLE (define a ação)
  IN p_opcao     INT
)
BEGIN
  -- --------------------------------------------------------
  -- Estrutura condicional: CASE sobre a variável de controle
  -- --------------------------------------------------------
  CASE p_opcao

    -- ① SELECT — consulta por id (ou todos se id = 0)
    WHEN 1 THEN
      IF COALESCE(p_id_aluno, 0) = 0 THEN
        SELECT * FROM aluno ORDER BY id_aluno;
      ELSE
        SELECT * FROM aluno WHERE id_aluno = p_id_aluno;
      END IF;

    -- ② INSERT — inserção de novo aluno
    WHEN 2 THEN
      INSERT INTO aluno (nome, matricula, curso, nota, ativo)
      VALUES (p_nome, p_matricula, p_curso, p_nota, TRUE);
      SELECT LAST_INSERT_ID() AS novo_id_aluno;

    -- ③ UPDATE — atualização dos dados do aluno
    WHEN 3 THEN
      UPDATE aluno
         SET nome     = COALESCE(p_nome, nome),
             matricula= COALESCE(p_matricula, matricula),
             curso    = COALESCE(p_curso, curso),
             nota     = COALESCE(p_nota, nota)
       WHERE id_aluno = p_id_aluno;
      SELECT ROW_COUNT() AS linhas_atualizadas;

    -- ④ DELETE — remoção do aluno
    WHEN 4 THEN
      DELETE FROM aluno WHERE id_aluno = p_id_aluno;
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

-- ① SELECT: listar todos (id = 0 → todos)
CALL sp_gestao_aluno(0, NULL, NULL, NULL, NULL, 1);

-- ② INSERT: inserir novo aluno
CALL sp_gestao_aluno(NULL, 'Diego Ferreira', '2026004',
                     'Marketing', 6.90, 2);

-- ③ UPDATE: alterar a nota do aluno id = 4
CALL sp_gestao_aluno(4, NULL, NULL, NULL, 9.99, 3);

-- ④ DELETE: remover o aluno id = 4
CALL sp_gestao_aluno(4, NULL, NULL, NULL, NULL, 4);

-- ⑤ SELECT final: confere o estado da tabela
CALL sp_gestao_aluno(0, NULL, NULL, NULL, NULL, 1);
