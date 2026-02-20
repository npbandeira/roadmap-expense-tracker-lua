Aqui está uma versão mais simples e direta do README:

```markdown
# Expense Tracker CLI

Um rastreador de despesas simples para linha de comando, desenvolvido em Lua.

## Funcionalidades

- ✅ Adicionar despesa (descrição, valor)
- ✅ Listar todas as despesas
- ✅ Resumo total e por mês
- ✅ Excluir despesa por ID

## Como usar

### Adicionar despesa
```bash
lua expense-tracker.lua add --description "Almoço" --amount 25.90
```

### Listar despesas
```bash
lua expense-tracker.lua list
```

### Ver resumo
```bash
# Total geral
lua expense-tracker.lua summary

# Total do mês 1 (janeiro)
lua expense-tracker.lua summary --month 1
```

### Excluir despesa
```bash
lua expense-tracker.lua delete --id 2
```

## Instalação

1. Tenha Lua instalado: https://www.lua.org/download.html
2. Baixe o arquivo `expense-tracker.lua`
3. Execute no terminal:
```bash
lua expense-tracker.lua add --description "Teste" --amount 10
```

## Estrutura

- `expenses.csv` - arquivo com suas despesas (gerado automaticamente)
- `budget.json` - configurações de orçamento (gerado automaticamente)

## Exemplos rápidos

```bash
# Adicionar despesas
lua expense-tracker.lua add --description "Café" --amount 5.50
lua expense-tracker.lua add --description "Uber" --amount 15.00

# Ver lista
lua expense-tracker.lua list

# Ver resumo de janeiro
lua expense-tracker.lua summary --month 1
```

## Erros comuns

- **"command not found"**: Instale o Lua
- **"Invalid amount"**: Use ponto (.) no lugar de vírgula: 25.90
- **"Month must be between 1-12"**: Use meses de 1 a 12

## Projeto original

Baseado no desafio [Expense Tracker do roadmap.sh](https://roadmap.sh/projects/expense-tracker)