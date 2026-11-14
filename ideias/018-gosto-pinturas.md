# Gosto de pinturas (feedback e descoberta)

- **Estado:** Em andamento
- **Origem:** pedido do usuário (13/11/2026)
- **Resumo:** Gostei/Não gostei com motivos, aprendizado por autor, gênero, categoria, cor e qualidade, exploração de 30%, acervo ampliado (Van Gogh, Velho Oeste, deserto, montanhas...).

## Notas
Feito: motor, painel, descoberta, acervo de ~1267. Falta: usar de verdade e ajustar; categoria de "bandidos" não existe na Commons.

## Feedback simplificado (13/11/2026)
- O usuário achou demorado descrever motivos: o Gostei/Não gostei agora é só um clique, sem escolher motivo.
- **Botões 👍 👎 no canto da pintura** (`mancato.desktop`, ao lado da legenda, só na área de trabalho vazia). Depois da avaliação os botões somem e ficam só um símbolo (👍 em destaque, 👎 apagado). **Não gostei** troca para outra pintura na hora (como no painel); **Gostei** fica na atual.
- **Mudar de ideia:** menu das pinturas → **Minha avaliação desta pintura** → Gostei, Não gostei ou Remover avaliação (`painting-theme rating` mostra a nota; `painting-theme unrate` remove).
- Painel da pintura (clique na barra): **Não gostei** também é direto, sem lista de motivos.
- Sem motivo, a avaliação vale para tudo que descreve a pintura (categoria, artista, gênero, etiquetas de estilo, traço, tema, região, época, paleta e luz), menos a qualidade do arquivo.
- Verificado: botões e símbolo na tela, ciclo gostei → remover por comando, submenu no menu. Os cliques nos botões não foram testados (o ponteiro por script não chega à camada do desktop).
- **Troca instantânea (13/11/2026):** a próxima pintura já fica baixada e cortada em `~/.cache/painting-theme/next.jpg` (+ `next.json`) e `next` usa isso. O que atrapalhava: toda avaliação apagava esse cache, então o Gostei/Não gostei deixava a próxima troca lenta. Agora o cache **continua valendo** depois de avaliar; só é descartado (e refeito em segundo plano) se a pré-carregada for da mesma categoria da que acabou de receber Não gostei. Depois de cada troca uma nova já é preparada.
