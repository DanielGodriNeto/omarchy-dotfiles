.pragma library
/*
 * Koi lake simulation (CPU side). The world is the whole screen in pixels. This file only moves the koi
 * (individuals that now and then form small groups) and hands their spines to the GPU: cells.frag
 * rasterises them into ASCII cells and lake.frag draws the water and the terminals' windows.
 * The koi colour schemes also use the variants of Pawan-webdeveloper/Ascii-Animals-extension (MIT). The koi anatomy in cells.frag (body profile, fins, markings, lighting by cell) follows the technique
 * of pursurer/ascii-koi (MIT), ported to the GPU for this project.
 */
var CW = 5, CH = 9, W = 1920, H = 1080, cols = 384, rows = 120
var N = 12
var fish = [], rips = [], t = 0
var cfg = { count: 16, speed: 1, palette: "mix" }
var PALS = { mix: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], warm: [0, 1, 2, 3, 5, 6, 11], cool: [7, 8, 9, 10, 4], paint: [0] }
var VAR = [0, 1, 0, 1, 2, 1, 0, 3, 1, 0, 2, 1, 3, 0, 1, 0]

function clamp(v, a, b) { return v < a ? a : v > b ? b : v }
function colourFor(k) { var p = PALS[cfg.palette] || PALS.mix; return p[(k * 5 + 2) % p.length] }
function rnd(a, b) { return a + Math.random() * (b - a) }

function mk(k) {
  var a = rnd(0, 6.283), L = rnd(120, 230), x = rnd(100, W - 100), y = rnd(100, H - 100), gap = L / (N - 1)
  var nodes = []
  for (var j = 0; j < N; j++) nodes.push([x - Math.cos(a) * j * gap, y - Math.sin(a) * j * gap])
  return {
    k: k, seed: k * 7 + 3, L: L, gap: gap, nodes: nodes, vx: Math.cos(a) * 4, vy: Math.sin(a) * 4,
    tg: rnd(3, 5.5), soc: rnd(.3, 1), loner: false, mood: rnd(40, 200), phase: rnd(0, 6), beat: .6, turn: 0, a: a,
    variety: VAR[k % VAR.length], colour: colourFor(k), depth: rnd(.62, 1)
  }
}

function init(w, h, count) {
  W = w; H = h; cols = Math.ceil(w / CW); rows = Math.ceil(h / CH); fish = []
  cfg.count = count || cfg.count
  for (var i = 0; i < cfg.count; i++) fish.push(mk(i))
}
/* c: { count, speed, palette }. Resizes the shoal and recolours it without restarting the lake. */
function configure(c) {
  cfg.speed = c.speed > 0 ? c.speed : 1
  cfg.palette = PALS[c.palette] ? c.palette : "mix"
  cfg.count = clamp(Math.round(c.count || 16), 1, 32)
  while (fish.length < cfg.count) fish.push(mk(fish.length))
  fish.length = cfg.count
  for (var i = 0; i < fish.length; i++) fish[i].colour = colourFor(i)
}
function size() { return { cols: cols, rows: rows, cw: CW, ch: CH } }
function time() { return t }
function ripples() {
  var out = []
  for (var i = Math.max(0, rips.length - 4); i < rips.length; i++) out.push([rips[i].x, rips[i].y, t - rips[i].t])
  return out
}
function addRipple(x, y) {
  rips.push({ x: x, y: y, t: t })
  for (var i = 0; i < fish.length; i++) {
    var f = fish[i], dx = f.nodes[0][0] - x, dy = f.nodes[0][1] - y, d = Math.hypot(dx, dy) || 1
    if (d < 520) { var p = (520 - d) / 520 * 12; f.vx += dx / d * p; f.vy += dy / d * p }
  }
}

function step() {
  t += .07
  for (var i = rips.length - 1; i >= 0; i--) if (t - rips[i].t > 3.6) rips.splice(i, 1)
  for (var a = 0; a < fish.length; a++) {
    var f = fish[a], h = f.nodes[0]
    if (--f.mood <= 0) { f.loner = Math.random() < .45; f.mood = rnd(80, 220); f.tg = rnd(2.8, 5.6) }
    var n = 0, ax = 0, ay = 0, cx = 0, cy = 0, sx = 0, sy = 0
    for (var b = 0; b < fish.length; b++) {
      if (b === a) continue
      var o = fish[b], dx = o.nodes[0][0] - h[0], dy = o.nodes[0][1] - h[1], d = Math.hypot(dx, dy) || 1
      if (d < 280) { n++; ax += o.vx; ay += o.vy; cx += o.nodes[0][0]; cy += o.nodes[0][1] }
      if (d < 110) { sx -= dx / d * (110 - d); sy -= dy / d * (110 - d) }
    }
    // Individuals first: a fish only seeks company while its group is small, and now and then ignores everyone.
    if (n > 0 && !f.loner && n <= 3) {
      f.vx += (ax / n - f.vx) * .03 * f.soc + (cx / n - h[0]) * .0009 * f.soc
      f.vy += (ay / n - f.vy) * .03 * f.soc + (cy / n - h[1]) * .0009 * f.soc
    }
    f.vx += sx * .004; f.vy += sy * .004
    f.vx += rnd(-.22, .22); f.vy += rnd(-.22, .22)
    if (h[0] < 90) f.vx += .5; if (h[0] > W - 90) f.vx -= .5
    if (h[1] < 80) f.vy += .5; if (h[1] > H - 80) f.vy -= .5
    var sp = Math.hypot(f.vx, f.vy) || 1, ns = sp + (f.tg * cfg.speed - sp) * .05
    f.vx *= ns / sp; f.vy *= ns / sp
    var na = Math.atan2(f.vy, f.vx), da = Math.atan2(Math.sin(na - f.a), Math.cos(na - f.a))
    f.turn = f.turn * .8 + da * .2; f.a = na
    f.beat = clamp(ns / 5, .3, 1)
    f.phase += .07 * (3 + f.beat * 5)
    h[0] += f.vx; h[1] += f.vy
    for (var j = 1; j < N; j++) {
      var p = f.nodes[j - 1], q = f.nodes[j], qx = q[0] - p[0], qy = q[1] - p[1], qd = Math.hypot(qx, qy) || 1
      q[0] = p[0] + qx / qd * f.gap; q[1] = p[1] + qy / qd * f.gap
    }
  }
}


var texels = []
function enc(col, row, v) {
  var q = clamp(Math.round((v + 512) * 16), 0, 65535)
  texels.push(col, row, q >> 8, q & 255)
}

/* The fish as a flat list [col, row, r, g, ...] of texels of a 40 x 32 image, one row per koi: columns 0..N-1
 * the spine x, N..2N-1 the spine y (with the swimming wave applied), then flare L, flare R, depth (x100),
 * colour, seed, variety. The shader decodes (r * 256 + g) / 16 - 512. */
function fishTexels() {
  texels = []
  for (var a = 0; a < fish.length; a++) {
    var f = fish[a], swim = .25 + .9 * f.beat
    for (var n = 0; n < N; n++) {
      var s = n / (N - 1), p = Math.max(0, n - 1), q = Math.min(N - 1, n + 1)
      var tx = f.nodes[p][0] - f.nodes[q][0], ty = f.nodes[p][1] - f.nodes[q][1], tl = Math.hypot(tx, ty) || 1
      tx /= tl; ty /= tl
      var off = f.L * .045 * (.05 + .95 * Math.pow(s, 2.2)) * swim * Math.sin(f.phase - s * 4.6)
      enc(n, a, f.nodes[n][0] - ty * off)
      enc(N + n, a, f.nodes[n][1] + tx * off)
    }
    var bank = clamp(f.turn * 3, -.3, .3), scull = .15 * (1 - f.beat) * Math.sin(f.phase * .5)
    enc(2 * N, a, (1 + scull - bank) * 100)
    enc(2 * N + 1, a, (1 - scull + bank) * 100)
    enc(2 * N + 2, a, f.depth * 100)
    enc(2 * N + 3, a, f.colour)
    enc(2 * N + 4, a, f.seed)
    enc(2 * N + 5, a, f.variety)
    enc(2 * N + 6, a, f.nodes[N >> 1][0])
    enc(2 * N + 7, a, f.nodes[N >> 1][1])
    enc(2 * N + 8, a, f.L * .8)
  }
  return texels
}
function count() { return fish.length }
