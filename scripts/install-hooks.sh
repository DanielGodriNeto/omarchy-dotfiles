#!/usr/bin/env bash
# Instala o hook de pós-commit versionado. O grafo é opcional: exige `uv tool install graphifyy`.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
install -m 755 scripts/post-commit.hook .git/hooks/post-commit
echo "hook instalado. Para o grafo: uv tool install graphifyy; depois scripts/graph-refresh.sh"
