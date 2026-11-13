# Cantos no painel de controle (Retos, Suaves, Padrão, Redondos)

- **Estado:** Feito (aplicado em 13/11/2026; testado ponta a ponta com 0, 18 e 12)
- **Origem:** escolha do usuário a partir da pesquisa (ideia 019, frente A, seletor de raio do Deepin)
- **Resumo:** uma linha "Cantos" no painel de controle com quatro predefinições (0, 6, 12 e 18 px). Escolher uma grava o valor, recarrega o Hyprland e a barra, a dock, os menus e o próprio painel redesenham com o novo raio. Setas esquerda/direita mudam a predefinição quando o cursor do teclado está na linha (índice 7).

## Notas
- Valor guardado em `~/.config/omarchy/corner-radius` (um número de 0 a 24); sem arquivo vale 12. Lido por `.config/hypr/looknfeel.lua` (função `corner_radius()`); escrito por `.local/bin/corner-radius` (`corner-radius` mostra, `corner-radius N` grava e roda `hyprctl reload config-only`).
- A recarga emite `configreloaded`, o evento que o shell escuta para espelhar `decoration:rounding` (`Style.cornerRadius`). Por isso não se usa `hyprctl eval`: ele muda o Hyprland mas o shell não percebe.
- `control-center-state` agora inclui `radius`. `Panel.qml` tem `radiusPresets`, `setRadius`, `stepRadius`.
- `rounding_power` (squircle, ideia 020) não muda: vale para qualquer raio.
- Verificado com captura: em 18 o painel e os blocos ficam mais redondos e "Redondos" fica marcado; em 0 tudo reto e "Retos" marcado; de volta a 12 sem erros de configuração.
- Backups: `~/.config/hypr/looknfeel.lua.bak6.*` e `~/.config/omarchy/plugin-backups/Panel.qml.bak.radius.*`.
- Ficou de fora: slider de opacidade global (Deepin), pois o Omarchy já trata transparência por janela.
