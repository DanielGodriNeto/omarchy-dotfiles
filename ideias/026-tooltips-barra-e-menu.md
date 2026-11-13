# Tooltips na barra, atalhos no menu SUPER+SPACE e bolinha da dock

- **Estado:** Feito (aplicado em 13/11/2026; falta o usuário ver em uso)
- **Origem:** pedido do usuário depois de testar a dock (13/11/2026)

## 1. Bolinha de app ativo acompanha o ícone
- `DockWindow.qml`: a bolinha sob o app aberto ganhou o mesmo deslocamento do ícone (`displayedShift` + `magShift`), então anda junto com o zoom e com arrastos. Conferido com o zoom forçado em código: a bolinha ficou centralizada sob o ícone ampliado.

## 2. Tooltips na barra de cima
- `.config/omarchy/plugins/mancato.bar/BarTooltips.js`: texto de cada widget (em português), por id do layout. `Bar.qml` (`ModuleSlot`) mostra o tooltip existente da barra ao repousar o ponteiro, com o mesmo atraso de 400 ms e o "aquecimento" entre ícones vizinhos.
- Ficaram de fora os widgets que já têm tooltip próprio (janela ativa, bandeja, microfone, atualização, mídia, pintura, apps) para não aparecerem dois.
- Verificado: o tooltip do relógio apareceu (forçado em código): "Data e hora / Clique para ver o calendário". Hover real não testado.
- Editar textos: `BarTooltips.js` (id → texto, linha 2 do texto vira a explicação).

## 3. Menu SUPER+SPACE: atalhos como teclas e explicação embaixo
- O plugin do menu foi **clonado** com `omarchy plugin clone omarchy.menu` para `.config/omarchy/plugins/mancato.menu` (o original fica desativado em `shell.json`; backup em `~/.config/omarchy/shell.json.bak.menuclone.*`). Nunca se edita `/usr/share/omarchy`.
- Mudanças em `Menu.qml`: linha de explicação sempre visível (antes só na busca), teclas desenhadas como caps (⌘ ⇧ ⌃ ⌥ e nomes curtos) à direita da linha, cartão mais largo (300 → 440).
- `MenuExtras.js` (escrito à mão): explicações em português por id e a conversão "SUPER SHIFT + F" → ⌘ ⇧ F.
- `Shortcuts.js` é **gerado** por `scripts/menu-shortcuts.py`: casa cada item do menu com o atalho do Hyprland que roda o mesmo comando (27 itens hoje). Rodar de novo depois de atualizar o Omarchy ou mudar atalhos: `python3 -I scripts/menu-shortcuts.py`.
- Itens sem explicação ou sem atalho simplesmente não mostram a linha/teclas. Itens do menu sem explicação escrita (a maioria dos submenus fundos) ficam como antes.
- Risco: o clone não acompanha atualizações do menu original do Omarchy; se algo quebrar depois de um update, `omarchy plugin remove mancato.menu` ou restaurar o `shell.json` do backup volta ao menu original.
