# Finc Guedes

Aplicativo de **controle financeiro pessoal** para Android e iOS, feito em Flutter,
com armazenamento local em **SQLite** (via `sqflite`, **SQL nativo, sem ORM**).

Uso exclusivamente pessoal — não distribuído nas lojas.

## Funcionalidades

- **Dashboard** com saldo atual, receitas/despesas do período, lançamentos em
  atraso, próximos vencimentos e distribuição de despesas por categoria.
- **Movimentos** (receitas e despesas): cadastro, edição, exclusão, efetivar /
  reabrir, busca por texto e filtros por período, tipo e status.
- **Categorias**: CRUD completo, com cor e ícone, separadas por tipo.
- **Contas recorrentes**: cadastro de regras (dia de vencimento, início/fim,
  geração antecipada) e **geração automática** dos movimentos mês a mês.

## Arquitetura

Organização **Feature-First**, com separação clara de responsabilidades:

```
lib/
├── main.dart                  # bootstrap: gera recorrências devidas e sobe o app
├── app.dart                   # MaterialApp, tema, localização pt-BR e providers
├── core/                      # base transversal
│   ├── database/              # AppDatabase, schema (idêntico ao .txt), seed
│   ├── errors/                # AppException
│   ├── state/                 # ControllerBase (ChangeNotifier)
│   ├── theme/                 # AppColors, AppTheme (ancorados na inforvix_ux)
│   ├── ui/                    # catálogo de ícones/cores de categoria
│   ├── utils/                 # moeda, datas, conversões de banco
│   └── widgets/               # componentes reutilizáveis (+ forms/)
├── models/                    # Categoria, Movimento, Recorrencia, enums, DTOs
├── data/
│   ├── sql/                   # SQL centralizado (SELECT/INSERT/UPDATE/DELETE)
│   └── repositories/          # Repository Pattern (acesso ao banco)
├── services/                  # RecorrenciaService (motor de geração)
└── features/                  # dashboard, movimentos, categorias, recorrencias, shell
    └── <feature>/
        ├── controllers/       # Notifiers (estado da tela)
        ├── screens/           # telas
        └── widgets/           # widgets da feature
```

**Camadas:** Screens · Widgets · Controllers/Notifiers · Services · Repository ·
Database · Models.

**Estado:** `provider` + `ChangeNotifier` (controllers por feature).

## Persistência (SQLite + sqflite, sem ORM)

- O schema é criado **exatamente** conforme `ESTRUTURA_BANCO.txt`
  (ver `core/database/database_schema.dart`) — nenhuma tabela nova, nenhuma
  coluna alterada.
- Todo o SQL é **explícito e centralizado** em classes `*Sql`
  (`data/sql/`), sempre **parametrizado com `?`** (proteção contra SQL Injection).
- Os repositórios (`data/repositories/`) executam o SQL via
  `rawQuery/rawInsert/rawUpdate/rawDelete` e convertem linhas em models.
- Valores monetários são armazenados como **inteiros em centavos**; datas como
  texto (`yyyy-MM-dd` / `yyyy-MM-dd HH:mm:ss`).
- Chaves estrangeiras habilitadas (`PRAGMA foreign_keys = ON`).

### Convenções de domínio

| Coluna    | Valores |
|-----------|---------|
| `TIPO`    | `E` = receita · `S` = despesa |
| `STATUS`  | `0` = pendente · `1` = efetivado · `2` = cancelado |
| `ORIGEM`  | `0` = manual · `1` = recorrência |

### Geração de recorrências

`RecorrenciaService.gerarPendentes()` roda no start e após salvar uma
recorrência. Para cada recorrência ativa, gera um movimento por competência
(mês) do início pendente até o mês atual (ou o próximo, se *gerar antecipado*),
ajustando o dia de vencimento em meses curtos. É **idempotente** (usa
`ULTIMA_COMPETENCIA_GERADA` + verificação por competência) e **transacional**.

## Interface (inforvix_ux)

A UI usa a biblioteca **`inforvix_ux`** para padronização visual:

- O tema (`AppColors`/`AppTheme`) é ancorado na `PaletaCores` e na fonte
  **Open Sans** da biblioteca.
- Componentes usados diretamente: `ButtonInforvix`, `Combobox`.
- Quando um componente não existe na biblioteca (campos de valor/data,
  seletores de tipo/categoria, cards de resumo, etc.), ele foi **recriado no
  projeto mantendo o mesmo padrão visual**, conforme permitido.

> Os arquivos da fonte Open Sans em `assets/fonts/` são cópias locais das que
> acompanham a `inforvix_ux`, para que a família fique disponível globalmente.

## Como executar

```bash
flutter pub get
flutter run
```

Testes (regras de domínio):

```bash
flutter test
```

## Requisitos

- Flutter 3.41+ / Dart 3.11+
