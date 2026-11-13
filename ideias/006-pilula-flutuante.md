# Barra em pílula flutuante

- **Estado:** Pendente (sem opção nativa; só QML próprio)
- **Origem:** pedido do usuário ou HANDOFF antigo (13/11/2026)
- **Resumo:** Pill.qml já dá o formato por widget; falta margem/flutuação da barra.

## Notas
- Estudo (13/11/2026): a janela da barra (`/usr/share/omarchy/shell/plugins/bar/Bar.qml`, `BarPanel`) ocupa a tela toda com `exclusiveZone` fixo e desenha a faixa em `barStrip`. Flutuar = copiar o plugin `bar` para `~/.config/omarchy/plugins` e dar margem/raio ao `barStrip`; sem opção nativa. Risco: o plugin copiado não recebe atualizações do Omarchy. Opções A atual, B pílula contínua, C ilhas. Aguardando escolha.
