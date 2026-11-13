# Squircle, sombra e curvas de janela

- **Estado:** Feito (aplicado em 13/11/2026; falta o usuário olhar de verdade e ajustar)
- **Origem:** escolha do usuário a partir da pesquisa (ideia 019, docs/PESQUISA-DISTROS.md)
- **Resumo:** `rounding_power` 2.5 (cantos contínuos), sombra estilo COSMIC (range 20, offset 0 5, alpha 0.45 ativa e 0.34 inativa), curva `expoOut` (easeOutExpo do elementary) só na abertura de janela com popin 70%, fechamento com popin 85%.

## Notas
- Arquivo: `.config/hypr/looknfeel.lua`. Validado: `hyprctl configerrors` vazio, `hyprctl getoption` confirma os valores, `luac -p` ok.
- Ajuste fino: `rounding_power` entre 2.5 e 3 (4 é squircle bem marcado); se a sombra pesar na iGPU, baixar `range`.
- Reverter: restaurar o backup `looknfeel.lua.bak5.*` em `~/.config/hypr/` (o Hyprland recarrega ao salvar).
- Limite: o `rounding_power` vale para janelas; as ilhas e painéis do Quickshell seguem com `Rectangle` de raio simples (squircle em QML exige shader ou ShapePath).
