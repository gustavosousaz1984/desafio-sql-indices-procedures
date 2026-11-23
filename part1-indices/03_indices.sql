-- ============================================================
--  PARTE 1 — Cenário: COMPANY
--  Desafio DIO · SQL Database Specialist
--  Arquivo 3/3 — Criação de índices
-- ============================================================
--
--  REGRA DE OURO DO DESAFIO:
--  "Crie apenas aqueles que são importantes."
--
--  Um índice acelera LEITURA (SELECT) mas CUSTA em escrita
--  (INSERT/UPDATE/DELETE precisam manter o índice atualizado).
--  Por isso só indexamos colunas de verdadeiro acesso.
--
--  TIPOS DE ÍNDICE:
--  · BTREE (padrão) — ideal para igualdade (=), BETWEEN, ORDER BY
--                    e junções. Estrutura balanceada.
--  · HASH           — apenas igualdade (=), mas sem ORDER BY e
--                    sem faixa. Útico para consultas exatas.
--
--  A escolha abaixo justifica cada tipo com base na query.
-- ============================================================

USE company;


-- ------------------------------------------------------------
-- ÍNDICE 1 — funcionario.numero_departamento
-- Motiva: PERGUNTA 1 e PERGUNTA 3 (JOIN + GROUP BY)
-- Tipo: BTREE (padrão)
-- Motivo: é a CHAVE ESTRANGEIRA usada no JOIN com departamento.
--         Sem este índice, o MySQL faria varredura completa
--         (full table scan) na tabela funcionario a cada consulta,
--         comparando linha a linha. Com BTREE, o JOIN vira uma
--         busca logarítmica direta pelas linhas daquele
--         departamento.
--         BTREE porque o agrupamento (GROUP BY) e a junção se
--         beneficiam da ordenação natural da árvore.
-- ------------------------------------------------------------
ALTER TABLE funcionario
  ADD INDEX idx_funcionario_departamento (numero_departamento);


-- ------------------------------------------------------------
-- ÍNDICE 2 — localizacao_departamento.localizacao
-- Motiva: PERGUNTA 2 (filtros e ordenação por cidade)
-- Tipo: BTREE (padrão)
-- Motivo: a query filtra e ordena por CIDADE (localizacao).
--         Este índice permite ao SGBD localizar todas as linhas
--         de uma cidade específica sem percorrer a tabela inteira
--         e já as entrega em ordem, dispensando etapa extra de
--         ordenação (filesort).
--         BTREE porque usamos igualdade E ORDER BY.
-- ------------------------------------------------------------
CREATE INDEX idx_localizacao
  ON localizacao_departamento (localizacao)
  USING BTREE;


-- ------------------------------------------------------------
-- ÍNDICE 3 — departamento.nome
-- Motiva: PERGUNTA 1, 2 e 3 (exibição e busca por nome)
-- Tipo: BTREE (padrão)
-- Motivo: o nome do departamento aparece em todas as consultas
--         e é buscado por igualdade. Embora o tamanho da tabela
--         seja pequeno, indexar a coluna de exibição evita
--         ordenação temporária quando se pede "ORDER BY nome".
--         (A UNIQUE KEY uk_departamento_nome já cobre buscas
--         exatas por nome; este índice reforça leituras de
--         exibição.)
-- ------------------------------------------------------------
CREATE INDEX idx_departamento_nome
  ON departamento (nome)
  USING BTREE;


-- ------------------------------------------------------------
-- ÍNDICE 4 (EXEMPLO DE DECISÃO) — POR QUE NÃO INDEXAR SALÁRIO?
-- Nenhuma das consultas do desafio filtra ou ordena por salario.
-- Criar um índice aqui só DESACELERARIA os INSERT/UPDATE, sem
-- ganho algum de leitura. Exemplo de índice que NÃO devemos criar:
--
--   -- NÃO CRIAR:
--   -- CREATE INDEX idx_salario ON funcionario(salario);
-- ------------------------------------------------------------
-- (deliberadamente omitido)


-- ============================================================
--  CONSULTA DE VALIDAÇÃO — mostra os índices criados
-- ============================================================
SELECT
    TABLE_NAME                          AS tabela,
    INDEX_NAME                          AS indice,
    SEQ_IN_INDEX                        AS ordem,
    COLUMN_NAME                         AS coluna,
    NON_UNIQUE                          AS nao_unico
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'company'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
