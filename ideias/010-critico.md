# Subagente crítico (escritor, crítico, melhoria)

- **Estado:** Em andamento (fluxo testado nos commits do grafo; a seção no CLAUDE.md espera autorização do usuário)
- **Origem:** pedido do usuário relatado pela sessão coordenadora, 13/11/2026
- **Resumo:** um subagente separado critica o diff só com os requisitos originais; o escritor corrige; o verificador reexecuta as checagens. Máx. 1 rodada (2 se houver achado alto), só com 3+ arquivos ou arquivos de risco.

## Notas
(registrar quantos achados o crítico encontrou, para medir se vale o custo)
