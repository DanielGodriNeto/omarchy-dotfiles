.pragma library

// What each bar widget does, shown when the pointer rests on it. Keyed by the
// widget's id in the bar layout. Widgets that already show a tooltip of their
// own (active window, tray, microphone, system update, media, painting, apps)
// are left out so they never get two.
var TEXTS = {
  "omarchy.menu": "Menu do Omarchy\nApps, estilo, configurações e sistema",
  "omarchy.workspaces": "Áreas de trabalho\nClique para ir até uma",
  "workspace-windows": "Janelas desta área de trabalho\nA mais clara é a que está em foco",
  "media-spectrum": "Visualizador do áudio que está tocando",
  "omarchy.clock": "Data e hora\nClique para ver o calendário",
  "omarchy.indicators": "Avisos de estado\nGravação de tela, Não perturbar, luz noturna e outros",
  "omarchy.elsewhen": "Horário em outras cidades",
  "omarchy.weather": "Clima\nClique para ver os detalhes",
  "mancato.control-center": "Central de controle\nWi-Fi, Bluetooth, volume, brilho e Não perturbar",
  "omarchy.tailscale": "Tailscale (VPN)\nStatus e máquinas conectadas",
  "omarchy.keyboard-layout": "Idioma do teclado\nClique para alternar",
  "system-pill": "Uso do sistema\nProcessador, temperatura e memória",
  "omarchy.agents": "Agentes de IA\nUso, limites e saldo de cada um",
  "omarchy.bluetooth": "Bluetooth\nDispositivos e conexão",
  "omarchy.network": "Rede\nLista de Wi-Fi e estado da conexão",
  "omarchy.audio": "Som\nVolume, saída de áudio e volume por app",
  "omarchy.monitor": "Tela\nBrilho e opções do monitor",
  "omarchy.power": "Bateria e energia\nNível, modo de energia e estatísticas"
}

function text(id) {
  return TEXTS[String(id || "")] || ""
}
