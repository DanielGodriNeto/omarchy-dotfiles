# Brave: nova aba transparente

- **Estado:** Substituído pela [ideia 033](033-brave-nova-aba-papel-de-parede.md) (a regra de opacidade foi removida: o usuário queria só a imagem de fundo da nova aba, não a janela inteira)
- **Origem:** pedido do usuário (13/11/2026)
- **Resumo:** só na página de nova aba (título `New Tab - Brave Origin`, classe `brave-origin`) a janela do Brave fica translúcida (opacidade 0.6), mostrando o papel de parede por trás. Qualquer outra aba volta ao normal sozinha (a regra casa pelo título).

## Notas
- Regra em `.config/hypr/looknfeel.lua`: `o.window({ class = "^brave-origin$", title = "^(New Tab|Nova guia) - Brave Origin$" }, { opacity = "0.6 0.6" })`. Menor número = mais transparente (0.4 mostra bem mais o fundo). Verificado: `hyprctl getprop address:... opacity` = 0.6 na janela da nova aba.
- A foto da nova aba do Brave continua desenhada pela página. Para o fundo aparecer limpo, desligar **Mostrar imagem de fundo** em `brave://settings/newTab`: a página fica de cor lisa e a translucidez deixa ver o papel de parede.
- Não testado: a volta da opacidade ao navegar para outra aba (depende de o Hyprland reavaliar a regra na troca de título).
- Limitação: o compositor deixa a janela inteira translúcida, texto e ícones da nova aba também.
