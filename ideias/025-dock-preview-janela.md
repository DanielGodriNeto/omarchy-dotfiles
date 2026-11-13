# Preview de janela no hover da dock

- **Estado:** Feito (aplicado em 13/11/2026; **hover real não testado**)
- **Origem:** escolha do usuário a partir da pesquisa (ideia 019, frentes A e B: Deepin, elementary 8.1, MacShell)
- **Resumo:** ao deixar o ponteiro ~0,45 s sobre um app em execução, aparece acima da dock um cartão com miniaturas das janelas dele (até 4) e o título de cada uma; clicar numa miniatura traz aquela janela para a frente. Passando para outro app o cartão troca na hora; sair some em 0,22 s.

## Notas
- Arquivo: `.config/omarchy/plugins/mancato.dock/DockWindow.qml` (estado `previewItem/previewSlot/previewTarget`, `previewHoverChanged`, `closePreview`, timers e o `BorderSurface` `preview`). Usa `ScreencopyView` como o `mancato.expose`, com captura estática (`live: false`) e `constraintSize` para manter a proporção.
- Fecha ao abrir o menu, ao clicar no ícone, ao arrastar, ao recolher a dock (auto-hide) e mantém a dock aberta enquanto o ponteiro está no cartão.
- **Verificação:** o shell carrega sem erro; forçando o estado em código, a captura mostrou a miniatura do Claude centralizada acima do ícone, com título e proporção corretos. **Não testado:** o caminho do hover real (o cursor movido por script não gera eventos de movimento), o clique para focar e o comportamento com várias janelas/minimizadas.
- Janelas minimizadas (workspace especial) podem não ter miniatura; pendente de ver.
- Valores ajustáveis: atraso 450 ms (`previewTimer`), tamanho da miniatura (`thumbWidth`/`thumbHeight`), máximo de 4 janelas (`slice(0, 4)`).
