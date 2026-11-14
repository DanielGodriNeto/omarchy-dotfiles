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
- **Modo avaliação rápida (13/11/2026):** menu das pinturas → **Modo avaliação rápida** (✓ quando ligado; também há o chip "Avaliação rápida" no painel da barra). Ligado: Gostei **e** Não gostei trocam para outra pintura na hora, para passar por várias avaliando. Desligado (padrão): só Não gostei troca. Config `rate_mode` em `~/.config/painting-theme/config.json`; comando `painting-theme quick like|dislike` (usado pelos botões do desktop e pelo painel).
- No modo rápido **só aparecem pinturas novas**: nunca avaliadas e nunca mostradas como papel de parede (`~/.local/state/painting-theme/seen.json`, preenchido a cada troca; semeado com o que já tinha nota). Se acabarem as novas, cai para as não avaliadas. A pré-carregada que já foi vista ou avaliada é descartada ao ligar o modo. Verificado: 3 sorteios seguidos vieram novos.
- **Botões em lugar fixo (13/11/2026):** os botões 👍 👎 (ou o símbolo da nota) ficam num espaço fixo de 88 px no canto de baixo à esquerda, e a legenda vem à direita deles. Antes os botões vinham depois da legenda e andavam conforme o tamanho do nome. Verificado nas capturas antes e depois de avaliar: botão e legenda na mesma posição.
- **Botões só no modo rápido (13/11/2026):** a pedido, os botões 👍 👎 do canto (e o símbolo da nota) só existem com o **modo avaliação rápida ligado**; desligado, o canto volta a ter só a legenda, como antes. `Desktop.qml` observa `~/.config/painting-theme/config.json` (`rate_mode`). Avaliar com o modo desligado continua possível pelo painel da barra e pelo menu (Minha avaliação). Verificado nas capturas: ligado mostra os botões, desligado só a legenda.
- **Correção (13/11/2026):** os botões 👍 👎 do canto **sempre aparecem**. O que depende do modo rápido é só a posição: ligado, ficam num espaço fixo à esquerda com a legenda à direita; desligado, vêm depois da legenda, como antes. Implementado com um componente `RatingButtons` instanciado nos dois lugares em `Desktop.qml`. (A versão anterior sumia com os botões fora do modo rápido, o que foi um erro de leitura do pedido.)
