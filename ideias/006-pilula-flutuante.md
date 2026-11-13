# Barra em pílula flutuante

- **Estado:** Feito (opção C, ilhas)
- **Origem:** pedido do usuário ou HANDOFF antigo (13/11/2026)
- **Resumo:** Pill.qml já dá o formato por widget; falta margem/flutuação da barra.

## Notas
- Estudo (13/11/2026): a janela da barra (`/usr/share/omarchy/shell/plugins/bar/Bar.qml`, `BarPanel`) ocupa a tela toda com `exclusiveZone` fixo e desenha a faixa em `barStrip`. Flutuar = copiar o plugin `bar` para `~/.config/omarchy/plugins` e dar margem/raio ao `barStrip`; sem opção nativa. Risco: o plugin copiado não recebe atualizações do Omarchy. Opções A atual, B pílula contínua, C ilhas. Aguardando escolha.
- **Feito (13/11/2026):** opção C. `omarchy plugin clone omarchy.bar` criou `mancato.bar` (shell.json: `bar.id`); `Bar.qml` ganhou `islandGap` (8 px), componente `Island` e fundo da faixa transparente. Revisor: sem achados médios. Volta ao padrão: remover `"id"` de `bar` no shell.json e `omarchy restart shell`. Ressalva: não recebe updates da barra do Omarchy.
