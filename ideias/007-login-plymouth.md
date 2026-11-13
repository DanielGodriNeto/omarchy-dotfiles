# Tela de login/Plymouth com a pintura atual

- **Estado:** Em andamento (opção 2 pronta; falta o usuário instalar com sudo)
- **Origem:** pedido do usuário ou HANDOFF antigo (13/11/2026)
- **Resumo:** Levar a pintura atual para a tela de login e o boot.

## Notas
- Estudo (13/11/2026): SDDM tem **autologin** (tela de login nem aparece); Plymouth usa o tema `omarchy` (script) em `/usr/share/plymouth/themes/omarchy`; trocar exige root (`/usr` + `mkinitcpio`/`limine`), o usuário roda num terminal próprio. Opções: 1 fundo liso, 2 pintura escurecida, 3 só logo. Aguardando escolha.
- **Opção 2 escolhida (13/11/2026):** `system/plymouth-pintura/build.sh` gera o tema em `~/.cache/plymouth-pintura` (testado); `install.sh` precisa de sudo, rodar em terminal próprio.
