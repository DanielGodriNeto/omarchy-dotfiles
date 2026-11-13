import { createRequire } from "node:module"
import assert from "node:assert/strict"
const require = createRequire(import.meta.url)
const M = require(new URL("../.config/omarchy/plugins/mancato.dock/DockModel.js", import.meta.url).pathname)
const near = (a, b, e = 1e-9) => assert.ok(Math.abs(a - b) < e, `${a} != ${b}`)

// no pointer: nothing grows or moves
let r = M.magnify(7, 56, -1, 90, 1.55)
assert.deepEqual(r.scales, Array(7).fill(1)); assert.deepEqual(r.shifts, Array(7).fill(0))

// pointer on the middle of slot 3: that slot is the biggest, near max
r = M.magnify(7, 56, 3.5 * 56, 90, 1.55)
near(r.scales[3], 1.55)
assert.ok(r.scales[3] > r.scales[2] && r.scales[2] > r.scales[1] && r.scales[1] > r.scales[0])
near(r.scales[2], r.scales[4])               // symmetric
near(r.shifts[3], 0); near(r.shifts[2], -r.shifts[4]) // centered, mirrored

// pointer at the left end: first slot grows, the row stays centered (shifts sum to about -(total-weighted))
r = M.magnify(7, 56, 0.5 * 56, 90, 1.55)
assert.ok(r.scales[0] > r.scales[1])
// the gap between neighbours' edges never shrinks below zero (no overlap)
for (let i = 0; i < 6; i++) {
  const rightEdge = (i + 0.5) * 56 + r.shifts[i] + r.scales[i] * 56 / 2
  const leftEdge = (i + 1.5) * 56 + r.shifts[i + 1] - r.scales[i + 1] * 56 / 2
  assert.ok(leftEdge - rightEdge > -1e-9, `overlap at ${i}: ${leftEdge - rightEdge}`)
}
// radius 0 or maxScale 1 is a no-op
assert.deepEqual(M.magnify(3, 56, 80, 0, 1.55).scales, [1, 1, 1])
assert.deepEqual(M.magnify(3, 56, 80, 90, 1).shifts, [0, 0, 0])
console.log("magnify: all assertions passed")
const e = M.magnify(7, 56, 3.5 * 56, 90, 1.55)
assert.ok(e.extra > 0); near(e.extra, e.scales.reduce((a, s) => a + (s - 1) * 56, 0))
assert.equal(M.magnify(7, 56, -1, 90, 1.55).extra, 0)
console.log("magnify extra: ok")
