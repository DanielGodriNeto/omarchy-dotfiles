#!/usr/bin/env bash
# Gera docs/MAPA.md: uma linha por arquivo versionado com a primeira descrição/comentário.
cd "$(git rev-parse --show-toplevel)"
{ echo "# Mapa de arquivos (gerado por scripts/map.sh, não edite à mão)"; echo
git ls-files | grep -v -e '^docs/MAPA.md$' -e '^ideias/' -e fastfetch-art/ -e 'docs/graph/' | while read -r f; do
  d=$(grep -m1 -E '^\s*(#|//|--|\*|/\*|;|<!--|"description")' "$f" 2>/dev/null | grep -v '^#!' | head -1)
  [ -z "$d" ] && d=$(grep -m1 -vE '^\s*($|#!|\{|\[|---)' "$f" 2>/dev/null)
  d=$(sed -E 's/^\s*(#+|\/\/+|--+|\*+|\/\*+|;+|<!--)\s*//; s/^"description":\s*//; s/\s+$//' <<<"$d" | cut -c1-140)
  case "$f" in *.png|*.jpg) d="(imagem)";; esac
  echo "- \`$f\`: ${d:-(sem descrição)}"
done; } > docs/MAPA.md
