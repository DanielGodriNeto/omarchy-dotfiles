# Brave: nova aba com o papel de parede da área de trabalho

- **Estado:** Feito e confirmado pelo usuário no Brave (13/11/2026)
- **Origem:** pedido do usuário (13/11/2026): só a imagem de fundo da nova aba invisível, ou igual ao fundo da área de trabalho, automaticamente.
- **Resumo:** a nova aba do Brave vira uma página local (`~/.local/share/brave-newtab/index.html`, original em `.config/brave-newtab/index.html`) que mostra o papel de parede atual em tela cheia com uma caixa de pesquisa do Google. O hook `45-sync-brave-newtab` copia o papel de parede atual para `bg.jpg` a cada troca de tema/pintura.

## Instalação (uma vez, já feita)
- Página e hook em `~/.local/share/brave-newtab` e `~/.config/omarchy/hooks/theme-set.d/`.
- Política do Brave (fora do repo, precisa de root): `/etc/brave/policies/managed/newtab.json` = `{"NewTabPageLocation": "file:///home/<usuário>/.local/share/brave-newtab/index.html"}`. O mesmo diretório guarda o `color.json` do Omarchy; o Omarchy só apaga arquivos que **não** são de root, então este fica.
- Refazer em outra máquina: copiar `.config/brave-newtab/index.html` para `~/.local/share/brave-newtab/` e criar o `newtab.json` com `sudo tee`.

## Notas e riscos
- Não confirmado que o Brave Origin respeita `NewTabPageLocation` (a política pode ser lida ao vivo ou só no próximo início). Teste: abrir uma nova aba no Brave. Se continuar a página antiga do Brave: reiniciar o Brave e testar de novo.
- Plano B: em `brave://settings/newTab`, desligar "Mostrar imagem de fundo" (página lisa).
- Perde os atalhos de sites e as estatísticas da nova aba nativa. Dá para acrescentar atalhos na página local.
- Desfazer: `sudo rm /etc/brave/policies/managed/newtab.json`.
