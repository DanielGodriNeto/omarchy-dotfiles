#!/usr/bin/env bash
# Teste de regressão do grafo: cada pergunta deve devolver TODAS as substrings esperadas (separadas por |).
cd "$(git rev-parse --show-toplevel)"
pass=0; total=0
t(){ total=$((total+1)); out=$(graphify query "$1" --budget 700 2>&1); ok=1
  IFS='|' read -ra want <<<"$2"; for w in "${want[@]}"; do grep -qF -- "$w" <<<"$out" || ok=0; done
  if [ $ok = 1 ]; then pass=$((pass+1)); echo "PASS  $1"; else echo "FAIL  $1  (esperado: $2)"; fi; }
t "qual comando liga o Não perturbar no painel de controle" "Panel.qml|silencing"
t "qual atalho abre o overview de workspaces" "bindings.lua"
t "qual serviço systemd faz a troca automática da pintura" "painting-theme.service"
t "como a dock lê os apps fixados" "Dock.qml"
t "como o peek desktop é protegido durante a troca de tema" "peek_state"
t "quais arquivos mudam ao trocar a pintura" ".local/bin/painting-theme"
echo "Placar: $pass/$total"; [ $pass = $total ]
