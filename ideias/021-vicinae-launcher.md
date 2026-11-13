# Vicinae (launcher estilo Spotlight)

- **Estado:** Feito (instalado e configurado em 13/11/2026; falta o usuário usar e ajustar)
- **Origem:** escolha do usuário a partir da pesquisa (ideia 019)
- **Resumo:** Vicinae 0.30.0 (AUR `vicinae-bin`, GPL-3) no atalho `SUPER+R`, daemon como serviço de usuário, tema gerado a partir do tema/pintura atual, cantos 12 px, modo compacto.

## Notas
- Instalação: `yay -S vicinae-bin`, depois `sudo setcap -r /usr/libexec/vicinae/vicinae-input-server`. O pacote dá `cap_dac_override` a esse binário (snippets e colar automático); a permissão foi removida de propósito. **Cada atualização do pacote a devolve**: rodar o `setcap -r` de novo. `input_server` está desligado em `settings.json`, então colar vira copiar.
- Telemetria desligada (`telemetry.system_info = false`).
- Serviço: `systemctl --user enable --now vicinae.service`. Atalho em `.config/hypr/bindings.lua` (`vicinae toggle`). `SUPER+SPACE` segue sendo o menu do Omarchy e `SUPER+ALT+SPACE` a grade de apps.
- Tema: `.config/omarchy/themed/vicinae.toml.tpl` (renderizado pelo Omarchy a cada troca de tema) e hook `.config/omarchy/hooks/theme-set.d/30-sync-vicinae-theme` (copia para `~/.local/share/vicinae/themes/omarchy.toml` e aplica). Testado só com render manual das cores atuais; **ainda não visto numa troca de tema real** (não rodar `painting-theme next` direto do app: ver CLAUDE.md).
- A busca de arquivos indexa a home inteira e o histórico de clipboard fica em `~/.local/share/vicinae/clipboard.db`.
- A pesquisa dizia que o Omarchy trazia o Walker: errado no 4.0 (não instalado).
