#!/usr/bin/env bash
# Reconstrói graphify-out/: AST do código (sem LLM) + camada semântica versionada (docs/graph/semantic.json).
# Se QML, config ou .md mudaram desde a extração semântica, avisa (graphify-out/STALE-SEMANTIC) para rodar o Haiku de novo.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
O=graphify-out; mkdir -p $O; [ -f $O/.graphify_python ] || uv tool run --from graphifyy python -c "import sys;print(sys.executable)" > $O/.graphify_python
PY=$(cat $O/.graphify_python); ST=$O/stage.$$
trap 'rm -rf "$ST"' EXIT
V=$(graphify --version 2>/dev/null | awk '{print $NF}')
[ "$V" = "0.9.108" ] || echo "aviso: graphify $V instalado; testado com 0.9.108" >&2
rm -rf "$ST"; mkdir -p "$ST"
git ls-files | grep -v -e fastfetch-art -e '\.json$' -e '^scripts/' -e '^ideias' -e '^docs/' -e '^CLAUDE.md$' | while read -r f; do
  [ -f "$f" ] || continue; mkdir -p "$ST/$(dirname "$f")"
  case "$f" in *.qml|*.lua|*.service|*.jsonc|*.toml|*.tpl) cp "$f" "$ST/$f.txt";; *) cp "$f" "$ST/$f";; esac
done
SUM=$(cd "$ST" && find . \( -name "*.txt" -o -name "*.md" \) | sort | xargs sha256sum | sha256sum | cut -d' ' -f1)
"$PY" - "$ST" "$O" <<'P'
import json,sys
from pathlib import Path
from graphify.detect import detect
from graphify.extract import extract
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json
S,O=Path(sys.argv[1]),Path(sys.argv[2])
d=detect(S); ast=extract([Path(f) for f in d['files']['code']],cache_root=S)
sp=Path('docs/graph/semantic.json'); sem=json.loads(sp.read_text()) if sp.exists() else {'nodes':[],'edges':[],'hyperedges':[]}
seen={n['id'] for n in ast['nodes']}; nodes=list(ast['nodes'])
nodes+= [n for n in sem['nodes'] if n['id'] not in seen]
ex={'nodes':nodes,'edges':ast['edges']+sem['edges'],'hyperedges':sem.get('hyperedges',[])}
G=build_from_json(ex,root=str(S),directed=False)
c=cluster(G); lab={k:f'Community {k}' for k in c}
to_json(G,c,str(O/'graph.json'),community_labels=lab)
(O/'GRAPH_REPORT.md').write_text(generate(G,c,score_all(G,c),lab,god_nodes(G),surprising_connections(G,c),d,{'input':0,'output':0},str(S),suggested_questions=suggest_questions(G,c,lab)))
print(f'grafo: {G.number_of_nodes()} nós, {G.number_of_edges()} arestas')
P
rm -rf "$ST"
if [ "$SUM" != "$(cat docs/graph/semantic.sha 2>/dev/null)" ]; then
  echo "QML, config ou .md mudaram: rode a extração semântica (Haiku) e depois: echo $SUM > docs/graph/semantic.sha" | tee $O/STALE-SEMANTIC
else rm -f $O/STALE-SEMANTIC; fi
