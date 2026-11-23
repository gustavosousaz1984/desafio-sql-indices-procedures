# 🗄️ Desafio SQL — Índices e Procedures

Projeto do curso **SQL Database Specialist (DIO)** cobrindo duas competências essenciais de SGBD:

- **Parte 1 — Índices:** criação de índices estratégicos para acelerar consultas no cenário *company*.
- **Parte 2 — Procedures:** procedures com estruturas condicionais para manipulação de dados (INSERT / SELECT / UPDATE / DELETE) nos cenários *universidade* e *e-commerce*.

> **Autor:** Gustavo Sousa · [LinkedIn](https://www.linkedin.com/in/gustavosousaz/) · [GitHub](https://github.com/gustavosousaz1984)

---

## 📁 Estrutura do projeto

```
desafio-sql-indices-procedures/
├── README.md                      ← este arquivo
├── part1-indices/
│   ├── 01_empresa_schema.sql      ← criação da base company + dados de teste
│   ├── 02_queries.sql             ← queries que motivam os índices
│   └── 03_indices.sql             ← criação dos índices + justificativas
└── part2-procedures/
    ├── 01_universidade.sql        ← procedure de gestão de alunos
    └── 02_ecommerce.sql           ← procedure de gestão de produtos
```

---

## ▶️ Como executar

Os scripts estão em **MySQL 8.x**. Execute na ordem, dentro do MySQL Workbench, DBeaver ou linha de comando:

**Parte 1 — Índices**
```bash
mysql -u root -p < part1-indices/01_empresa_schema.sql
mysql -u root -p < part1-indices/02_queries.sql
mysql -u root -p < part1-indices/03_indices.sql
```

**Parte 2 — Procedures**
```bash
mysql -u root -p < part2-procedures/01_universidade.sql
mysql -u root -p < part2-procedures/02_ecommerce.sql
```

> 📌 Cada arquivo de procedure **seleciona o banco (`USE`)** antes de criar a procedure — requisito do desafio.

---

## 🧠 Parte 1 — Cenário *company*

### As consultas do desafio

| # | Pergunta | Query |
|---|---|---|
| 1 | Qual o departamento com maior número de pessoas? | `02_queries.sql` |
| 2 | Quais são os departamentos por cidade? | `02_queries.sql` |
| 3 | Relação de empregados por departamento | `02_queries.sql` |

### Por que criar índices?

A função do índice é **reduzir o tempo de busca** no SGBD. Sem índice, o MySQL faz uma **varredura completa da tabela** (*full table scan*), comparando linha a linha. Com índice, ele navega por uma estrutura balanceada (árvore) e chega direto ao resultado.

**Porém:** índice não é grátis. Toda escrita (`INSERT`/`UPDATE`/`DELETE`) precisa atualizar todos os índices da tabela. Por isso, o desafio manda:

> *"Crie apenas aqueles que são importantes."*

### Índices criados — e o motivo de cada um

| # | Índice | Tabela | Coluna | Tipo | Motivo |
|---|---|---|---|---|---|
| 1 | `idx_funcionario_departamento` | `funcionario` | `numero_departamento` | **BTREE** | É a **chave estrangeira** do JOIN com `departamento`, usada nas consultas 1 e 3. Sem ele → *full scan* na tabela `funcionario` a cada consulta. |
| 2 | `idx_localizacao` | `localizacao_departamento` | `localizacao` | **BTREE** | A consulta 2 filtra e **ordena por cidade**. O BTREE entrega os dados já ordenados, dispensando etapa extra de ordenação (*filesort*). |
| 3 | `idx_departamento_nome` | `departamento` | `nome` | **BTREE** | Nome aparece em **todas** as consultas para exibição; indexar evita ordenação temporária em `ORDER BY nome`. |

### Índice que **NÃO** foi criado (decisão consciente)

```sql
-- NÃO CRIAR: CREATE INDEX idx_salario ON funcionario(salario);
```

Nenhuma consulta do desafio filtra ou ordena por `salario`. Criar esse índice só **atrasaria** os `INSERT`/`UPDATE` sem trazer qualquer ganho de leitura. Saber **o que não indexar** é tão importante quanto saber o que indexar.

### BTREE vs HASH — por que BTREE?

| Tipo | Serve para | Não serve para |
|---|---|---|
| **BTREE** ✅ | Igualdade (`=`), faixa (`BETWEEN`, `<`, `>`), `ORDER BY`, `JOIN` | — |
| **HASH** | Apenas igualdade (`=`) | Ordenação, faixa, junção |

Todas as consultas aqui usam **JOIN, GROUP BY e ORDER BY** — operações que se beneficiam da ordenação natural do BTREE. Por isso **todas foram criadas como BTREE** (que é, aliás, o padrão do MySQL/InnoDB).

### Estrutura da tabela `company`

```
departamento (PK: numero)
   │ 1:N
   ├──< localizacao_departamento (PK: numero_departamento + localizacao)
   │         └── consultas por CIDADE
   │
   └──< funcionario (FK: numero_departamento)
             └── consultas de CONTAGEM por departamento
```

---

## ⚙️ Parte 2 — Procedures

### Conceito

Uma **procedure** é um bloco de código armazenado no banco que executa uma sequência de instruções. Aqui ela recebe:

- **Variáveis de recebimento** → os dados (`nome`, `matricula`, `preço`…)
- **Variável de controle** (`p_opcao`) → **decide qual ação executar**

### Variável de controle

| `p_opcao` | Ação | Estrutura |
|---|---|---|
| `1` | **SELECT** (consulta) | `IF` dentro do `CASE` |
| `2` | **INSERT** (inserção) | `CASE` |
| `3` | **UPDATE** (atualização) | `CASE` + `COALESCE` |
| `4` | **DELETE** (remoção) | `CASE` |
| outra | Aviso de opção inválida | `ELSE` |

> As instruções estão dentro de estruturas condicionais (**`CASE`** e **`IF`**), como exigido no desafio.

### Cenários implementados

| Arquivo | Banco | Tabela | Procedure |
|---|---|---|---|
| `01_universidade.sql` | `universidade` | `aluno` | `sp_gestao_aluno` |
| `02_ecommerce.sql` | `ecommerce` | `produto` | `sp_gestao_produto` |

Cada arquivo **seleciona o banco com `USE` antes de criar a procedure** e inclui **chamadas (`CALL`)** testando todas as 4 ações.

### Exemplo de chamada

```sql
-- Listar todos os produtos (SELECT)
CALL sp_gestao_produto(0, NULL, NULL, NULL, NULL, 1);

-- Inserir um produto (INSERT)
CALL sp_gestao_produto(NULL, 'Autoclave', 'Equipamentos', 2400.00, 8, 2);

-- Atualizar estoque (UPDATE)
CALL sp_gestao_produto(1, NULL, NULL, NULL, 150, 3);

-- Remover produto (DELETE)
CALL sp_gestao_produto(3, NULL, NULL, NULL, NULL, 4);
```

---

## 🛠️ Tecnologias

- **MySQL 8.x** (SGBD)
- **MySQL Workbench / DBeaver** (cliente)
- **SQL** — DDL, DML, procedures, índices
- **Git / GitHub** (versionamento)

---

## 📚 O que este projeto demonstra

| Competência | Aplicação |
|---|---|
| **Análise de performance** | Identificar quais colunas são realmente acessadas e só indexar essas |
| **Conhecimento de índice** | Entender BTREE vs HASH e o custo do índice na escrita |
| **Programação em SQL** | Procedures com parâmetros, variável de controle e estruturas condicionais |
| **Boas práticas** | Selecionar o banco (`USE`) antes de criar objetos; comentar decisões |
