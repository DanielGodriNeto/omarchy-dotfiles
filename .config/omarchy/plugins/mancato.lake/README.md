# mancato.lake

Lago de carpas em ASCII visto só através de terminais foot translúcidos (cada terminal é uma janela para o mesmo lago).

- `Lake.js`: simulação das carpas (indivíduos que às vezes formam pequenos grupos) e dados para a GPU.
- `cells.frag`: rasteriza as carpas em células de caractere na GPU (anatomia, manchas e luz).
- `lake.frag`: desenha água, ondas e os caracteres dentro de cada janela de terminal.
- Modo Performance: o lago aparece em todos os terminais; nos outros modos, só em terminal parado no prompt (`lake-term-state`).
- Configuração: botão de peixe na barra (`bar/modules/koi.qml`; clique esquerdo abre o painel `mancato.lakepanel`, direito liga/desliga). Os ajustes ficam em `~/.config/omarchy/lake.json` e se aplicam na hora (`lake-config` na linha de comando): ligado, onde aparece (automático, só parados, sempre), quantidade de carpas, velocidade, cores (mistura, quentes, frias, da pintura) e ondas ao clicar.
- Clique esquerdo em terminal com lago: onda e as carpas fogem (bind não consumidor em `bindings.lua`).
- Depois de editar um `.frag`, recompile: `/usr/lib/qt6/bin/qsb --glsl "150,300 es" --hlsl 50 --msl 12 -o cells.frag.qsb cells.frag` (o `lake.frag` aceita também `100 es,120`). Edição de QML exige `omarchy restart shell`: o recarregamento a quente não é confiável aqui.
- A anatomia, as manchas e a iluminação das carpas seguem a técnica de pursurer/ascii-koi (MIT); as variantes de cor vêm também de Pawan-webdeveloper/Ascii-Animals-extension (MIT). O código aqui foi reescrito.
