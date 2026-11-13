# Micro-interações da dock (pressionar e bounce de lançamento)

- **Estado:** Feito (aplicado em 13/11/2026; falta o usuário ver e ajustar)
- **Origem:** escolha do usuário a partir da pesquisa (ideia 019, frente A, elementary dock)
- **Resumo:** ao pressionar um ícone ele afunda para 0.92; ao lançar um app que ainda não abriu, o ícone sobe meio ícone em 200 ms e desce em 600 ms com bounce, repetindo com 200 ms de pausa até a janela aparecer (substitui o pulso de opacidade antigo).

## Notas
- Arquivo: `.config/omarchy/plugins/mancato.dock/DockWindow.qml` (componente `AppSlot`). Valores do elementary: `data/Application.css:119-122` (press) e `Launcher.vala:172-196` (bounce).
- Respeita "reduzir movimento" (`Style.reduceMotion`): sem animação, o ícone fica parado.
- O bounce sobe na direção oposta à borda da dock (`bounceSign`), então vale para dock embaixo, em cima ou nos lados; **só testei embaixo**.
- Não feito (ficou para depois): mola ao soltar um app arrastado (scale 1.1 com overshoot), shake de ação negada, magnificação por distância do ponteiro, preview de janela no hover.
- Backup do arquivo anterior em `~/.config/omarchy/plugin-backups/DockWindow.qml.bak.*`. Recarrega sozinho ao salvar (`omarchy restart shell` se travar).
- Verificação feita: shell recarregou sem erro de QML e a camada `omarchy-dock` existe. O efeito em si **não foi visto em movimento** (a dock estava recolhida).
