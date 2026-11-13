#!/usr/bin/env python3
"""Crítico automático (sem LLM) da camada semântica do grafo: confere cada nó e aresta de
docs/graph/semantic.json contra o código-fonte. Saída: precisão por tipo e lista de suspeitos.

Uso: scripts/graph-verify.py [--strict]   (--strict: sai com 1 se houver suspeito de severidade alta)
Regras (evidência executável, nada de opinião):
  nó      : o arquivo existe e algum termo do rótulo aparece nele
  aresta  : os dois extremos existem; para calls/references/launches/runs, o termo do alvo aparece no arquivo do
            extremo de origem; INFERRED e AMBIGUOUS sempre vão para revisão (o grafo não prova nada)
"""
import json, re, subprocess, sys
from pathlib import Path

ROOT = Path(subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip())
SEM = json.loads((ROOT / "docs/graph/semantic.json").read_text())
AST_IDS = set()
gj = ROOT / "graphify-out/graph.json"
if gj.exists():
    data = json.loads(gj.read_text())
    AST_IDS = {n["id"] for n in data.get("nodes", [])}

STOP = {"plugin", "module", "script", "file", "config", "bar", "the", "and", "for", "with", "root", "main", "from", "uses", "reads"}


def terms(label: str):
    """Termos que identificam o nó: palavras e identificadores do rótulo, sem as genéricas."""
    out = []
    for t in re.findall(r"[A-Za-z_][A-Za-z0-9_.\-]{3,}", label):
        if t.lower() not in STOP:
            out.append(t)
            out += [p for p in re.split(r"[._\-]", t) if len(p) >= 5 and p.lower() not in STOP]
    return out


def text_of(rel):
    p = ROOT / rel
    return p.read_text(errors="ignore").lower() if p.is_file() else None


nodes = {n["id"]: n for n in SEM["nodes"]}
bad_nodes, bad_edges, review = [], [], []

for n in nodes.values():
    src = n.get("source_file")
    if not src:
        continue
    t = text_of(src)
    if t is None:
        bad_nodes.append((n["id"], f"arquivo inexistente: {src}"))
    elif Path(src).name.lower() == n["label"].lower():
        continue  # o nó é o próprio arquivo
    elif not any(x.lower() in t for x in terms(n["label"])):
        bad_nodes.append((n["id"], f"nenhum termo de '{n['label']}' aparece em {src}"))

for e in SEM["edges"]:
    s, t = e["source"], e["target"]
    if s not in nodes and s not in AST_IDS:
        bad_edges.append((e, "origem não existe"))
        continue
    if t not in nodes and t not in AST_IDS:
        bad_edges.append((e, "destino não existe"))
        continue
    if e.get("confidence") in ("INFERRED", "AMBIGUOUS"):
        review.append((e, f"confiança {e['confidence']}"))
        continue
    if e.get("relation") in ("calls", "references", "launches", "runs") and s in nodes and t in nodes:
        body = text_of(nodes[s].get("source_file") or "")
        if body is not None and not any(x.lower() in body for x in terms(nodes[t]["label"])):
            bad_edges.append((e, f"'{nodes[t]['label']}' não aparece em {nodes[s].get('source_file')}"))

n_n, n_e = len(nodes), len(SEM["edges"])
print(f"nós: {n_n - len(bad_nodes)}/{n_n} confirmados | arestas: {n_e - len(bad_edges) - len(review)}/{n_e} confirmadas, "
      f"{len(review)} em revisão (INFERRED/AMBIGUOUS), {len(bad_edges)} suspeitas")
for i, why in bad_nodes:
    print(f"  NÓ SUSPEITO   {i}: {why}")
for e, why in bad_edges:
    print(f"  ARESTA SUSPEITA {e['source']} -{e['relation']}-> {e['target']}: {why}")
for e, why in review:
    print(f"  REVISAR        {e['source']} -{e['relation']}-> {e['target']} ({why})")
if "--strict" in sys.argv and (bad_nodes or bad_edges):
    sys.exit(1)
