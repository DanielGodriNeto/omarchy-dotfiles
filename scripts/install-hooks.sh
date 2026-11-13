#!/usr/bin/env bash
# Instala os hooks versionados (pre-commit: MAPA.md; post-commit: grafo em segundo plano).
# O grafo é opcional: exige `uv tool install graphifyy==0.9.108`.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
install -m 755 scripts/pre-commit.hook .git/hooks/pre-commit
install -m 755 scripts/post-commit.hook .git/hooks/post-commit
echo "hooks instalados. Para o grafo: uv tool install graphifyy==0.9.108; depois scripts/graph-refresh.sh"
