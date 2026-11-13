# Notificações: arrastar para o lado para dispensar

- **Estado:** Feito (aplicado em 13/11/2026; **gesto não testado com mouse real**)
- **Origem:** escolha do usuário a partir da pesquisa (ideia 019, frente A, elementary notifications)
- **Resumo:** o card da notificação segue o ponteiro ao ser arrastado na horizontal, vai ficando transparente e, passando de um terço da largura, sai e é dispensado; senão volta com animação. O clique simples continua abrindo a notificação.

## Notas
- Arquivo: `.config/omarchy/plugins/mancato.notifications/Toast.qml` (propriedades `swipe`, `swipeActive`, `swipeLimit` no card e a `MouseArea` `cardArea` no fim do arquivo). A posição do ponteiro é lida em coordenadas da cena, porque a área anda junto com o card.
- Já existia e não foi mexido: pausa do tempo com hover (o deck expande no hover e `paused` segue `service.expanded`) e o botão de fechar no hover.
- **Verificação:** o shell recarregou, a notificação de teste (`notify-send`) aparece normal e empilha. Não consegui testar o arrasto: o cursor movido por script não gera eventos de movimento. Falta ver com o mouse/trackpad: arrastar, soltar antes e depois do limite, e conferir que o clique ainda abre.
- Se algo estranho aparecer, restaurar `~/.config/omarchy/plugin-backups/Toast.qml.bak.swipe.*` e rodar `omarchy restart shell`.
- O aviso `QQmlVMEMetaObject: attempted to evaluate a function in an invalid context` aparece em todo restart do shell, antes e depois desta mudança (não é daqui).
- Decidido não fazer: tela de bloqueio estilo macOS. O serviço de lock tem 919 linhas de autenticação (PAM, digital); refazê-lo num plugin arrisca trancar o usuário fora da sessão e o ganho visual é pequeno. A tela já tem fundo desfocado e campo no tema; `shell.toml [lock]` ajusta só as cores.
