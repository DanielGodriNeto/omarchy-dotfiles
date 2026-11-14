# Acervo ampliado (orientais, históricas, variedade) e mapa de gosto

- **Estado:** Feito (acervo ampliado e gosto semeado em 13/11/2026; refinar com Gostei/Não gostei no uso)
- **Origem:** pedido do usuário (13/11/2026)

## O que entrou
- Acervo de 1285 para **1940** pinturas (1494 elegíveis: JPEG horizontal ≥ 1500 px), em 94 categorias/artistas. Imagens locais em `~/.local/share/fastfetch-art` (não vão ao git); a lista, os metadados e a luminosidade estão em `.local/share/fastfetch-art/{index.jsonl,meta.json,lum.json}`.
- Orientais: Hokusai, Hiroshige, Monte Fuji, paisagens do Japão, escola Kanō, shan shui, templos, orientalismo, Nicholas Roerich. Dragões: arte de dragões, São Jorge e o dragão. Históricas: pintura histórica, Matejko, Delacroix, Repin, John Martin. Variedade: marinhas e Aivazovsky, inverno, Friedrich, Church, Hopper, Hodler, Monet e outros.
- Comandos usados: `painting-theme-discover [--depth 1] [--max N] "Categoria"…` (2,5 s entre chamadas ao Commons), `painting-theme-fetch`, `painting-theme meta`, `lum`, `features`. Categorias que não existem no Commons são puladas; categorias de artistas com muitas subcategorias precisam de `--depth 1`.
- Pouca coisa de pintura chinesa clássica: os rolos são verticais e o filtro pede horizontal ≥ 1,3.
- Qualidade irregular nas categorias amplas (ex.: um templo egípcio em "Paintings of temples", arte digital em "Dragons in art"): usar "Só essa imagem" no painel da pintura para excluir.

## Mapa de gosto
- O sorteio já aprende por categoria (`cat`), artista e gênero a partir de Gostei/Não gostei (`painting-theme taste`), com 30% de exploração.
- Para acelerar: 4 folhas de amostra (58 temas, uma pintura por tema, numeradas) enviadas ao usuário; as respostas viram avaliações semente em `~/.config/painting-theme/taste.json` (só dimensões categoria, artista e gênero, sem cor). Mapeamento número → pintura em scratchpad da sessão (`sheets/mapping.json`).

## Gosto semeado (13/11/2026)
- O usuário respondeu às 58 amostras: gostou da grande maioria (muito: 9, 25, 28-30, 39, 44-46, 50, 51, 55-57); não gostou de 23, 27, 37 e, mais ou menos, de 47; 54 foi "muito escura"; 31 e 58 neutros.
- 74 avaliações semente gravadas em `~/.config/painting-theme/taste.json` (marcadas `seed`): gostar = 1 avaliação por tema, "muito" = 2 (46 = 3), não gostar = 2, "não muito" = 1, só dimensões tema e artista (e `lum` para a escura). Backup `taste.json.bak.*` ao lado. Resultado: favorece Aivazovsky, Friedrich, Bierstadt e pores do sol do século 19; evita Hodler, Remington, "pores do sol" genéricos e Kuhnert.
- **Correção (13/11):** o não gostar da amostra 23 era do estilo daquela imagem (artístico, pouco realista, borda), não do tema pores do sol. Removidas as 2 avaliações negativas da categoria `Paintings of sunsets` e excluída só aquela imagem (`1218.jpg` em `exclude.txt`).
