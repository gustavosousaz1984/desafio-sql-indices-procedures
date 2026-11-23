-- ============================================================
--  PARTE 1 — Cenário: COMPANY
--  Desafio DIO · SQL Database Specialist
--  Arquivo 2/3 — Queries de recuperação de informações
-- ============================================================
--  Estas são as consultas que motivam a criação dos índices.
--  Cada índice existe para acelerar UMA destas buscas.
-- ============================================================

USE company;


-- ------------------------------------------------------------
-- PERGUNTA 1 — Qual o departamento com maior número de pessoas?
-- Acessa: departamento (nome) + funcionario (numero_departamento)
-- ------------------------------------------------------------
SELECT
    d.numero,
    d.nome                              AS departamento,
    COUNT(f.ssn)                        AS total_pessoas
FROM departamento d
INNER JOIN funcionario f
        ON f.numero_departamento = d.numero
GROUP BY d.numero, d.nome
ORDER BY total_pessoas DESC
LIMIT 1;


-- ------------------------------------------------------------
-- PERGUNTA 2 — Quais são os departamentos por cidade?
-- Acessa: localizacao_departamento (localizacao) + departamento
-- ------------------------------------------------------------
SELECT
    ld.localizacao                      AS cidade,
    d.numero,
    d.nome                              AS departamento
FROM localizacao_departamento ld
INNER JOIN departamento d
        ON d.numero = ld.numero_departamento
ORDER BY ld.localizacao, d.nome;


-- ------------------------------------------------------------
-- PERGUNTA 3 — Relação de empregados por departamento
-- Acessa: departamento + funcionario (agrupando por departamento)
-- ------------------------------------------------------------
SELECT
    d.numero,
    d.nome                              AS departamento,
    COUNT(f.ssn)                        AS total_empregados
FROM departamento d
INNER JOIN funcionario f
        ON f.numero_departamento = d.numero
GROUP BY d.numero, d.nome
ORDER BY total_empregados DESC, d.numero;


-- ------------------------------------------------------------
-- BÔNUS — Ranking completo de ocupação por departamento
-- (mesma lógica da Pergunta 1, sem LIMIT, para visualizar tudo)
-- ------------------------------------------------------------
SELECT
    d.numero,
    d.nome                              AS departamento,
    COUNT(f.ssn)                        AS total_pessoas,
    ROUND(100.0 * COUNT(f.ssn) /
          (SELECT COUNT(*) FROM funcionario), 1) AS pct_equipe
FROM departamento d
INNER JOIN funcionario f
        ON f.numero_departamento = d.numero
GROUP BY d.numero, d.nome
ORDER BY total_pessoas DESC;
