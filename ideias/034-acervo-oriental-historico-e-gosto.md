# Acervo ampliado (orientais, históricas, variedade) e mapa de gosto

- **Estado:** Em andamento (acervo ampliado e ordenado; falta o usuário marcar os temas das folhas para semear o gosto)
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
