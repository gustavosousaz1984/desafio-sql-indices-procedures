-- ============================================================
--  PARTE 1 — Cenário: COMPANY (empresa)
--  Desafio DIO · SQL Database Specialist
--  Arquivo 1/3 — Esquema + dados de teste
-- ============================================================
--  Objetivo: criar a base que sustenta as consultas do desafio
--  e, a partir delas, decidir quais índices realmente importam.
-- ============================================================

CREATE DATABASE IF NOT EXISTS company
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE company;

-- ------------------------------------------------------------
-- DEPARTAMENTO
-- ------------------------------------------------------------
CREATE TABLE departamento (
  numero             INT          NOT NULL,
  nome               VARCHAR(40)  NOT NULL,
  gerente_ssn        CHAR(11),
  data_inicio_gerente DATE,
  PRIMARY KEY (numero),
  UNIQUE KEY uk_departamento_nome (nome)
) ENGINE=InnoDB COMMENT='Departamentos da empresa';

-- ------------------------------------------------------------
-- LOCALIZACAO_DEPARTAMENTO (N:1 com departamento)
-- Relação N:N entre departamento e cidades → tabela associativa.
-- ------------------------------------------------------------
CREATE TABLE localizacao_departamento (
  numero_departamento INT         NOT NULL,
  localizacao         VARCHAR(40) NOT NULL,
  PRIMARY KEY (numero_departamento, localizacao),
  CONSTRAINT fk_locdep_departamento
    FOREIGN KEY (numero_departamento) REFERENCES departamento (numero)
) ENGINE=InnoDB COMMENT='Cidades onde cada departamento atua';

-- ------------------------------------------------------------
-- FUNCIONARIO
-- ------------------------------------------------------------
CREATE TABLE funcionario (
  ssn                CHAR(11)     NOT NULL,
  primeiro_nome      VARCHAR(20)  NOT NULL,
  nome_meio          CHAR(1),
  ultimo_nome        VARCHAR(20)  NOT NULL,
  data_nascimento    DATE,
  endereco           VARCHAR(60),
  sexo               CHAR(1),
  salario            DECIMAL(10,2),
  super_ssn          CHAR(11),            -- chefia (auto-referência)
  numero_departamento INT         NOT NULL,
  PRIMARY KEY (ssn),
  CONSTRAINT fk_func_departamento
    FOREIGN KEY (numero_departamento) REFERENCES departamento (numero),
  CONSTRAINT fk_func_superior
    FOREIGN KEY (super_ssn) REFERENCES funcionario (ssn)
) ENGINE=InnoDB COMMENT='Funcionários da empresa';


-- ============================================================
--  DADOS DE TESTE
-- ============================================================

-- Departamentos
INSERT INTO departamento (numero, nome, gerente_ssn, data_inicio_gerente) VALUES
  (1, 'Pesquisa',      '12345678901', '2020-01-15'),
  (2, 'Administração', '98765432109', '2019-06-01'),
  (3, 'Direção',       '45612378945', '2018-03-10');

-- Localizações (cidade por departamento)
INSERT INTO localizacao_departamento (numero_departamento, localizacao) VALUES
  (1, 'São Paulo'),
  (1, 'Rio de Janeiro'),
  (2, 'São Paulo'),
  (2, 'Maceió'),
  (3, 'Maceió');

-- Funcionários (12 no total)
--   Departamento 1 (Pesquisa)      → 6 pessoas
--   Departamento 2 (Administração) → 4 pessoas
--   Departamento 3 (Direção)       → 2 pessoas
INSERT INTO funcionario
  (ssn, primeiro_nome, nome_meio, ultimo_nome, data_nascimento, endereco, sexo, salario, super_ssn, numero_departamento)
VALUES
  -- Chefias (super_ssn NULL)
  ('12345678901', 'Ana',     'L', 'Silva',    '1980-05-10', 'Rua A, 100',   'F', 15000.00, NULL,         1),
  ('98765432109', 'Bruno',   'M', 'Costa',    '1978-11-22', 'Rua B, 200',   'M', 14000.00, NULL,         2),
  ('45612378945', 'Carla',   'P', 'Dias',     '1975-02-28', 'Rua C, 300',   'F', 16000.00, NULL,         3),
  -- Departamento 1 — Pesquisa
  ('11122233344', 'Diego',   'R', 'Souza',    '1990-07-14', 'Rua D, 400',   'M',  8000.00, '12345678901', 1),
  ('22233344455', 'Elena',   'T', 'Martins',  '1992-09-08', 'Rua E, 500',   'F',  7500.00, '12345678901', 1),
  ('33344455566', 'Felipe',  'G', 'Oliveira', '1988-12-01', 'Rua F, 600',   'M',  8200.00, '12345678901', 1),
  ('44455566677', 'Gabriela','H', 'Lima',     '1993-03-19', 'Rua G, 700',   'F',  7000.00, '12345678901', 1),
  ('55566677788', 'Henrique','J', 'Pereira',  '1991-06-25', 'Rua H, 800',   'M',  7800.00, '12345678901', 1),
  -- Departamento 2 — Administração
  ('66677788899', 'Isabela', 'K', 'Rocha',    '1989-08-30', 'Rua I, 900',   'F',  9000.00, '98765432109', 2),
  ('77788899900', 'João',    'N', 'Alves',    '1985-04-17', 'Rua J, 1000',  'M',  9500.00, '98765432109', 2),
  ('88899900011', 'Karina',  'B', 'Fernandes','1994-01-05', 'Rua K, 1100',  'F',  8500.00, '98765432109', 2),
  -- Departamento 3 — Direção
  ('99900011122', 'Lucas',   'C', 'Mendes',   '1983-10-11', 'Rua L, 1200',  'M', 12000.00, '45612378945', 3);
