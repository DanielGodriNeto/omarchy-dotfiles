# Zoom da dock por proximidade do mouse (estilo macOS)

- **Estado:** Feito (aplicado em 13/11/2026; falta o usuário ver com o mouse de verdade e ajustar)
- **Origem:** escolha do usuário a partir da pesquisa (ideia 019, frentes A e B)
- **Resumo:** os ícones perto do ponteiro crescem (até 1.55x no ponteiro, curva gaussiana com raio de 1.6 slots), os vizinhos se afastam para não sobrepor e o fundo da dock alarga junto. Funciona na dock em qualquer borda (eixo vertical incluso, não testado).

## Notas
- Lógica pura e testada: `magnify()` em `.config/omarchy/plugins/mancato.dock/DockModel.js`; teste em `scripts/dock-magnify.test.mjs` (`node scripts/dock-magnify.test.mjs`).
- Ligação em `DockWindow.qml`: `body.pointerAlong` (posição do ponteiro no `HoverHandler`), `body.mag`, constantes `magScale` e `magRadius` no topo. Durante arraste ou reordenação o zoom fica desligado.
- Pressionar afunda para 92% do tamanho atual (inclusive ampliado). O hover antigo de 1.15x só vale sem zoom.
- **Verificação:** o teste unitário passa; com o ponteiro fixado em código, a captura mostrou o zoom, os vizinhos sem sobreposição e o fundo alargando. **Não consegui testar o hover real:** `hl.dsp.cursor.move` teletransporta o cursor e a dock não recebe eventos de movimento, então a cadeia hover → posição do ponteiro só foi validada por leitura de código.
- Aprendizado: plugin QML alterado exige `omarchy restart shell` (hot reload não vale); `Behavior` não funciona em propriedade `readonly` (derrubou a dock por um instante durante o desenvolvimento).
- Ficou para depois: preview de janela no hover (`ScreencopyView`), mola ao soltar app arrastado, shake de ação negada.
