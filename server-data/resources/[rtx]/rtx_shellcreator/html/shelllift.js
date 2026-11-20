(function (root) {
  const LIFT = {};

  function image(w, h) {
    return { width: w, height: h, rgba: new Uint8Array(w * h * 4) };
  }

  function hash(x, y, s) {
    let h = (x * 374761393 + y * 668265263 + (s || 0) * 982451653) | 0;

    h = (h ^ (h >>> 13)) * 1274126177 | 0;
    h = h ^ (h >>> 16);

    return (h >>> 0) / 4294967295;
  }

  function smooth(t) {
    return t * t * (3 - 2 * t);
  }

  function noise(x, y, s) {
    const xi = Math.floor(x);
    const yi = Math.floor(y);
    const xf = smooth(x - xi);
    const yf = smooth(y - yi);
    const a = hash(xi, yi, s);
    const b = hash(xi + 1, yi, s);
    const c = hash(xi, yi + 1, s);
    const d = hash(xi + 1, yi + 1, s);

    return a + (b - a) * xf + (c - a) * yf + (a - b - c + d) * xf * yf;
  }

  function wrapNoise(x, y, period, s) {
    const xi = Math.floor(x);
    const yi = Math.floor(y);
    const xf = smooth(x - xi);
    const yf = smooth(y - yi);
    const m = function (v) { return ((v % period) + period) % period; };
    const a = hash(m(xi), m(yi), s);
    const b = hash(m(xi + 1), m(yi), s);
    const c = hash(m(xi), m(yi + 1), s);
    const d = hash(m(xi + 1), m(yi + 1), s);

    return a + (b - a) * xf + (c - a) * yf + (a - b - c + d) * xf * yf;
  }

  function fill(img, fn) {
    for (let y = 0; y < img.height; y++) {
      for (let x = 0; x < img.width; x++) {
        const c = fn(x, y);
        const o = (y * img.width + x) * 4;

        img.rgba[o] = Math.max(0, Math.min(255, Math.round(c[0])));
        img.rgba[o + 1] = Math.max(0, Math.min(255, Math.round(c[1])));
        img.rgba[o + 2] = Math.max(0, Math.min(255, Math.round(c[2])));
        img.rgba[o + 3] = c.length > 3 ? Math.max(0, Math.min(255, Math.round(c[3]))) : 255;
      }
    }

    return img;
  }

  function blend(img, x, y, c, a) {
    if (x < 0 || y < 0 || x >= img.width || y >= img.height || a <= 0) return;

    const o = (y * img.width + x) * 4;
    const k = Math.min(1, a);

    img.rgba[o] = img.rgba[o] + (c[0] - img.rgba[o]) * k;
    img.rgba[o + 1] = img.rgba[o + 1] + (c[1] - img.rgba[o + 1]) * k;
    img.rgba[o + 2] = img.rgba[o + 2] + (c[2] - img.rgba[o + 2]) * k;
  }

  function shape(img, box, dist, c) {
    const x0 = Math.max(0, Math.floor(box[0]) - 2);
    const y0 = Math.max(0, Math.floor(box[1]) - 2);
    const x1 = Math.min(img.width - 1, Math.ceil(box[2]) + 2);
    const y1 = Math.min(img.height - 1, Math.ceil(box[3]) + 2);

    for (let y = y0; y <= y1; y++) {
      for (let x = x0; x <= x1; x++) {
        const d = dist(x + 0.5, y + 0.5);

        if (d < 1) blend(img, x, y, typeof c === "function" ? c(x, y, d) : c, Math.min(1, 0.5 - d + 0.5) > 0 ? Math.min(1, 1 - d) : 0);
      }
    }
  }

  function segDist(px, py, a, b) {
    const dx = b[0] - a[0];
    const dy = b[1] - a[1];
    const l = dx * dx + dy * dy || 1e-9;
    const t = Math.max(0, Math.min(1, ((px - a[0]) * dx + (py - a[1]) * dy) / l));

    return Math.hypot(px - a[0] - dx * t, py - a[1] - dy * t);
  }

  function strokes(img, lines, width, c) {
    let box = [Infinity, Infinity, -Infinity, -Infinity];

    lines.forEach(function (line) {
      line.forEach(function (p) {
        box = [Math.min(box[0], p[0] - width), Math.min(box[1], p[1] - width), Math.max(box[2], p[0] + width), Math.max(box[3], p[1] + width)];
      });
    });
    shape(img, box, function (x, y) {
      let d = Infinity;

      lines.forEach(function (line) {
        for (let i = 0; i < line.length - 1; i++) d = Math.min(d, segDist(x, y, line[i], line[i + 1]));
      });

      return d - width / 2 + 0.5;
    }, c);
  }

  function circle(img, cx, cy, r, c) {
    shape(img, [cx - r, cy - r, cx + r, cy + r], function (x, y) { return Math.hypot(x - cx, y - cy) - r + 0.5; }, c);
  }

  function ring(img, cx, cy, r, w, c) {
    shape(img, [cx - r, cy - r, cx + r, cy + r], function (x, y) { return Math.abs(Math.hypot(x - cx, y - cy) - (r - w / 2)) - w / 2 + 0.5; }, c);
  }

  function rect(img, x0, y0, x1, y1, r, c) {
    shape(img, [x0, y0, x1, y1], function (x, y) {
      const qx = Math.abs(x - (x0 + x1) / 2) - ((x1 - x0) / 2 - r);
      const qy = Math.abs(y - (y0 + y1) / 2) - ((y1 - y0) / 2 - r);

      return Math.hypot(Math.max(qx, 0), Math.max(qy, 0)) + Math.min(Math.max(qx, qy), 0) - r + 0.5;
    }, c);
  }

  function poly(img, pts, c) {
    const xs = pts.map(function (p) { return p[0]; });
    const ys = pts.map(function (p) { return p[1]; });

    shape(img, [Math.min.apply(null, xs), Math.min.apply(null, ys), Math.max.apply(null, xs), Math.max.apply(null, ys)], function (x, y) {
      let inside = false;
      let d = Infinity;

      for (let i = 0, j = pts.length - 1; i < pts.length; j = i++) {
        const a = pts[i];
        const b = pts[j];

        if ((a[1] > y) !== (b[1] > y) && x < (b[0] - a[0]) * (y - a[1]) / (b[1] - a[1]) + a[0]) inside = !inside;
        d = Math.min(d, segDist(x, y, a, b));
      }

      return (inside ? -d : d) + 0.5;
    }, c);
  }

  const ARC = function (cx, cy, rx, ry, a0, a1, n) {
    const out = [];

    for (let i = 0; i <= n; i++) {
      const a = (a0 + (a1 - a0) * i / n) * Math.PI / 180;

      out.push([cx + Math.cos(a) * rx, cy + Math.sin(a) * ry]);
    }

    return out;
  };

  const GLYPHS = {
    "0": [ARC(0.5, 0.5, 0.32, 0.44, 0, 360, 40)],
    "1": [[[0.3, 0.24], [0.54, 0.06], [0.54, 0.94]], [[0.32, 0.94], [0.76, 0.94]]],
    "2": [ARC(0.5, 0.32, 0.3, 0.26, 200, 360, 14).concat(ARC(0.5, 0.32, 0.3, 0.26, 0, 70, 8)).concat([[0.2, 0.94], [0.82, 0.94]])],
    "3": [ARC(0.5, 0.29, 0.28, 0.23, 205, 450, 18), ARC(0.5, 0.72, 0.31, 0.22, 270, 515, 18)],
    "4": [[[0.66, 0.94], [0.66, 0.06], [0.16, 0.68], [0.86, 0.68]]],
    "5": [[[0.78, 0.06], [0.28, 0.06], [0.24, 0.46]].concat(ARC(0.5, 0.65, 0.3, 0.29, 236, 360 + 150, 22))],
    "6": [ARC(0.5, 0.67, 0.3, 0.27, 0, 360, 30), [[0.22, 0.62], [0.32, 0.3], [0.48, 0.12], [0.66, 0.06]]],
    "7": [[[0.18, 0.06], [0.82, 0.06], [0.42, 0.94]]],
    "8": [ARC(0.5, 0.28, 0.26, 0.22, 0, 360, 30), ARC(0.5, 0.71, 0.31, 0.23, 0, 360, 30)],
    "9": [ARC(0.5, 0.33, 0.3, 0.27, 0, 360, 30), [[0.78, 0.38], [0.68, 0.7], [0.52, 0.88], [0.34, 0.94]]],
    "-": [[[0.26, 0.52], [0.74, 0.52]]]
  };

  function text(img, label, cx, cy, h, width, c) {
    const chars = String(label).split("").filter(function (ch) { return GLYPHS[ch]; });
    const w = h * 0.62;
    const gap = h * 0.08;
    const total = chars.length * w + (chars.length - 1) * gap;
    let x = cx - total / 2;

    chars.forEach(function (ch) {
      const lines = GLYPHS[ch].map(function (line) { return line.map(function (p) { return [x + (p[0] - 0.5) * w + w / 2, cy - h / 2 + p[1] * h]; }); });

      strokes(img, lines, width, c);
      x += w + gap;
    });
  }

  function brushed(size, base, spread, seed, vertical) {
    return fill(image(size, size), function (x, y) {
      const a = vertical ? y : x;
      const b = vertical ? x : y;
      const line = (hash(b, 7, seed) - 0.5) * 0.55 + (wrapNoise(a / 18, b / 0.7, Math.round(size / 18), seed + 1) - 0.5) * 0.6 + (hash(a, b, seed + 3) - 0.5) * 0.3 + (wrapNoise(a / 128, b / 128, Math.max(1, Math.round(size / 128)), seed + 2) - 0.5) * 0.35;
      const v = base + line * spread;

      return [v, v + 0.5, v + 1.5];
    });
  }

  function normalOf(height, strength) {
    const w = height.width;
    const h = height.height;
    const at = function (x, y) { return height.rgba[(((y + h) % h) * w + ((x + w) % w)) * 4] / 255; };

    return fill(image(w, h), function (x, y) {
      const dx = (at(x + 1, y) - at(x - 1, y)) * strength;
      const dy = (at(x, y + 1) - at(x, y - 1)) * strength;
      const l = Math.hypot(dx, dy, 1);

      return [128 + 127 * -dx / l, 128 + 127 * -dy / l, 128 + 127 / l];
    });
  }

  function flat(size, c) {
    return fill(image(size, size), function () { return c; });
  }

  function specOf(img, gain, bias) {
    return fill(image(img.width, img.height), function (x, y) {
      const v = img.rgba[(y * img.width + x) * 4] * gain + bias;

      return [v, v, v];
    });
  }

  function panelImage(size, seed) {
    const img = brushed(size, 198, 11, seed, true);
    const seam = Math.round(size * 0.012);

    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        const e = Math.min(x, y, size - 1 - x, size - 1 - y);

        if (e < seam) blend(img, x, y, [70, 72, 76], 1);
        else if (e < seam + 2) blend(img, x, y, [232, 233, 236], 0.55);
      }
    }

    return img;
  }

  function panelHeight(size) {
    const seam = Math.round(size * 0.012);

    return fill(image(size, size), function (x, y) {
      const e = Math.min(x, y, size - 1 - x, size - 1 - y);
      const v = e < seam ? 40 : 200 + (hash(x, 3, 9) - 0.5) * 6;

      return [v, v, v];
    });
  }

  function granite(size) {
    return fill(image(size, size), function (x, y) {
      const n = wrapNoise(x / 22, y / 22, Math.round(size / 22), 31) * 0.55 + wrapNoise(x / 6, y / 6, Math.round(size / 6), 32) * 0.3 + hash(x, y, 33) * 0.15;
      const fleck = hash(x, y, 34) > 0.985 ? 70 : hash(x, y, 35) > 0.993 ? -12 : 0;
      const v = 30 + n * 34 + fleck;

      return [v + 2, v + 1, v];
    });
  }

  function sill(w, h) {
    return fill(image(w, h), function (x, y) {
      const g = (y % 16) < 3 ? -46 : (y % 16) < 5 ? 26 : 0;
      const v = 150 + g + (hash(x, y, 41) - 0.5) * 18 + (wrapNoise(x / 20, y / 3, Math.round(w / 20), 42) - 0.5) * 18;

      return [v, v + 1, v + 2];
    });
  }

  function mirror(size) {
    return fill(image(size, size), function (x, y) {
      const g = 0.5 + 0.5 * Math.sin((x * 0.7 - y) / size * Math.PI * 1.6);
      const v = 112 + g * 38 + (wrapNoise(x / 90, y / 90, Math.max(1, Math.round(size / 90)), 51) - 0.5) * 12;

      return [v - 6, v + 2, v + 10];
    });
  }

  function lightPanel(size) {
    const img = fill(image(size, size), function (x, y) {
      const ex = Math.min(x, size - 1 - x) / size;
      const ey = Math.min(y, size - 1 - y) / size;
      const edge = Math.min(1, Math.min(ex, ey) * 9);

      return [200 + 52 * edge, 196 + 52 * edge, 186 + 50 * edge];
    });
    const step = size / 8;

    for (let gy = 0; gy < 8; gy++) {
      for (let gx = 0; gx < 8; gx++) circle(img, (gx + 0.5) * step, (gy + 0.5) * step, step * 0.16, [255, 252, 244]);
    }

    return img;
  }

  function display(w, h) {
    const img = fill(image(w, h), function (x, y) {
      const v = 7 + (hash(x, y, 61) - 0.5) * 3;

      return [v, v, v + 2];
    });

    rect(img, 1, 1, w - 1, h - 1, 3, [24, 24, 28]);
    rect(img, 4, 4, w - 4, h - 4, 2, [6, 6, 8]);

    return img;
  }

  const AMBER = [255, 156, 36];

  function digit(label) {
    const img = fill(image(128, 128), function () { return [6, 6, 8]; });

    text(img, label, 64, 64, 92, 13, AMBER);

    return img;
  }

  function arrow(up) {
    const img = fill(image(64, 64), function () { return [6, 6, 8]; });

    poly(img, up ? [[32, 10], [54, 46], [10, 46]] : [[32, 54], [54, 18], [10, 18]], AMBER);

    return img;
  }

  function button(img, cx, cy, r, label, lit) {
    circle(img, cx, cy + 2, r + 3, [70, 72, 76]);
    circle(img, cx, cy, r + 2, [36, 38, 42]);
    circle(img, cx, cy, r, function (x, y) {
      const t = (y - (cy - r)) / (2 * r);
      const v = 222 - t * 60;

      return [v, v + 1, v + 4];
    });
    ring(img, cx, cy, r * 0.82, Math.max(2, r * 0.12), lit ? [120, 196, 255] : [160, 186, 210]);

    if (label === "up") poly(img, [[cx, cy - r * 0.42], [cx + r * 0.38, cy + r * 0.26], [cx - r * 0.38, cy + r * 0.26]], [40, 42, 46]);
    else if (label === "down") poly(img, [[cx, cy + r * 0.42], [cx + r * 0.38, cy - r * 0.26], [cx - r * 0.38, cy - r * 0.26]], [40, 42, 46]);
    else if (label === "open") {
      poly(img, [[cx - r * 0.1, cy - r * 0.3], [cx - r * 0.46, cy], [cx - r * 0.1, cy + r * 0.3]], [40, 42, 46]);
      poly(img, [[cx + r * 0.1, cy - r * 0.3], [cx + r * 0.46, cy], [cx + r * 0.1, cy + r * 0.3]], [40, 42, 46]);
    } else if (label === "close") {
      poly(img, [[cx - r * 0.46, cy - r * 0.3], [cx - r * 0.1, cy], [cx - r * 0.46, cy + r * 0.3]], [40, 42, 46]);
      poly(img, [[cx + r * 0.46, cy - r * 0.3], [cx + r * 0.1, cy], [cx + r * 0.46, cy + r * 0.3]], [40, 42, 46]);
    } else if (label === "bell") {
      circle(img, cx, cy, r * 0.62, [236, 186, 40]);
      strokes(img, [ARC(cx, cy + r * 0.02, r * 0.26, r * 0.3, 180, 360, 12), [[cx - r * 0.26, cy + r * 0.02], [cx - r * 0.3, cy + r * 0.2], [cx + r * 0.3, cy + r * 0.2], [cx + r * 0.26, cy + r * 0.02]]], Math.max(2, r * 0.1), [40, 32, 10]);
      circle(img, cx, cy + r * 0.3, r * 0.07, [40, 32, 10]);
    } else text(img, label, cx, cy, r * 0.95, Math.max(2.2, r * 0.13), [40, 42, 46]);
  }

  function copButtons(n) {
    const W = 256;
    const H = 1024;
    const cols = n > 6 ? 2 : 1;
    const rows = Math.ceil(n / cols);
    const top = 210;
    const bottom = H - 250;
    const r = Math.min(36, (bottom - top) / Math.max(1, rows) * 0.36, cols === 2 ? 40 : 50);
    const gap = rows === 1 ? 0 : Math.min((bottom - top) / (rows - 1), r * 2.9);
    const out = [];

    for (let j = 0; j < n; j++) {
      const i = n - 1 - j;
      const row = Math.floor(i / cols);
      const col = i % cols;

      out.push({ cx: cols === 1 ? W / 2 : W / 2 + (col === 0 ? -56 : 56), cy: top + 20 + row * gap, r: r });
    }

    return out;
  }

  LIFT.copButtons = copButtons;

  function cop(labels) {
    const W = 256;
    const H = 1024;
    const img = brushed(Math.max(W, H), 196, 11, 71, true);
    const out = image(W, H);

    for (let y = 0; y < H; y++) out.rgba.set(img.rgba.subarray(y * img.width * 4, y * img.width * 4 + W * 4), y * W * 4);

    rect(out, 2, 2, W - 2, H - 2, 10, function (x, y) { const o = (y * W + x) * 4; return [out.rgba[o] * 0.86, out.rgba[o + 1] * 0.86, out.rgba[o + 2] * 0.86]; });
    rect(out, 10, 10, W - 10, H - 10, 8, function (x, y) { const o = (y * W + x) * 4; return [out.rgba[o] / 0.86, out.rgba[o + 1] / 0.86, out.rgba[o + 2] / 0.86]; });
    rect(out, 40, 44, W - 40, 150, 6, [8, 8, 10]);

    const spots = copButtons(labels.length);

    labels.forEach(function (label, j) { button(out, spots[j].cx, spots[j].cy, spots[j].r, label, false); });

    button(out, W / 2 - 58, H - 190, 32, "open", false);
    button(out, W / 2 + 58, H - 190, 32, "close", false);
    button(out, W / 2, H - 88, 34, "bell", false);

    return out;
  }

  function litButton(label) {
    const img = fill(image(128, 128), function () { return [40, 42, 46]; });

    circle(img, 64, 64, 58, function (x, y) {
      const t = (y - 6) / 116;
      const v = 240 - t * 46;

      return [v, v + 3, v + 8];
    });
    ring(img, 64, 64, 50, 8, [150, 225, 255]);
    ring(img, 64, 64, 58, 3, [110, 180, 235]);

    if (label === "up") poly(img, [[64, 40], [84, 78], [44, 78]], [30, 60, 90]);
    else if (label === "down") poly(img, [[64, 88], [84, 50], [44, 50]], [30, 60, 90]);
    else text(img, label, 64, 64, 52, 7, [30, 60, 90]);

    return img;
  }

  function callPlate(kind) {
    const W = 128;
    const H = 256;
    const base = brushed(256, 196, 11, 81, true);
    const out = image(W, H);

    for (let y = 0; y < H; y++) out.rgba.set(base.rgba.subarray(y * 256 * 4, y * 256 * 4 + W * 4), y * W * 4);

    rect(out, 2, 2, W - 2, H - 2, 12, function (x, y) { const o = (y * W + x) * 4; return [out.rgba[o] * 0.84, out.rgba[o + 1] * 0.84, out.rgba[o + 2] * 0.84]; });
    rect(out, 9, 9, W - 9, H - 9, 9, function (x, y) { const o = (y * W + x) * 4; return [out.rgba[o] / 0.84, out.rgba[o + 1] / 0.84, out.rgba[o + 2] / 0.84]; });

    if (kind === "both") {
      button(out, W / 2, H * 0.32, 30, "up", false);
      button(out, W / 2, H * 0.68, 30, "down", false);
    } else button(out, W / 2, H / 2, 32, kind, false);

    return out;
  }

  LIFT.textures = function (labels) {
    const steel = brushed(512, 200, 12, 11, false);
    const steelV = brushed(512, 200, 12, 12, true);
    const panel = panelImage(512, 13);
    const out = {
      lift_steel: steel,
      lift_steel_n: normalOf(steel, 0.25),
      lift_steel_s: specOf(steel, 0.55, 40),
      lift_steelv: steelV,
      lift_steelv_n: normalOf(steelV, 0.25),
      lift_dark: brushed(256, 70, 8, 14, true),
      lift_panel: panel,
      lift_panel_n: normalOf(panelHeight(512), 2.2),
      lift_granite: granite(512),
      lift_granite_s: flat(16, [150, 150, 150]),
      lift_sill: sill(256, 64),
      lift_mirror: mirror(256),
      lift_mirror_s: flat(16, [255, 255, 255]),
      lift_light: lightPanel(256),
      lift_disp: display(128, 64),
      lift_black: flat(16, [18, 18, 20]),
      lift_flatn: flat(16, [128, 128, 255]),
      lift_up: arrow(true),
      lift_down: arrow(false),
      lift_call_up: callPlate("up"),
      lift_call_down: callPlate("down"),
      lift_call_both: callPlate("both")
    };

    out.lift_sill_n = normalOf(out.lift_sill, 2);
    out.lift_granite_n = normalOf(out.lift_granite, 0.8);
    (labels || []).forEach(function (label) {
      out["lift_d_" + label.replace("-", "m")] = digit(label);
      out["lift_p_" + label.replace("-", "m")] = litButton(label);
    });
    out.lift_p_up = litButton("up");
    out.lift_p_down = litButton("down");
    out["lift_cop_" + (labels || []).join("_").replace(/-/g, "m")] = cop(labels || ["0"]);

    return out;
  };

  const SPEC = { HardAlphaBlend: [1, 0, 0, 0], useTessellation: [0, 0, 0, 0], wetnessMultiplier: [1, 0, 0, 0], specMapIntMask: [1, 0, 0, 0], specularFresnel: [0.97, 0, 0, 0] };

  function mats(labels) {
    const copKey = "lift_cop_" + labels.join("_").replace(/-/g, "m");
    const spec = function (d, n, s, intensity, falloff, bump) { return { shader: "normal_spec", textures: { DiffuseSampler: d, BumpSampler: n, SpecSampler: s }, params: Object.assign({}, SPEC, { bumpiness: [bump, 0, 0, 0], specularIntensityMult: [intensity, 0, 0, 0], specularFalloffMult: [falloff, 0, 0, 0] }) }; };
    const glow = function (d, k) { return { shader: "emissive", textures: { DiffuseSampler: d }, params: { matMaterialColorScale: [1, 0, 0, 1], HardAlphaBlend: [1, 0, 0, 0], useTessellation: [0, 0, 0, 0], emissiveMultiplier: [k, 0, 0, 0], globalAnimUV1: [0, 1, 0, 0], globalAnimUV0: [1, 0, 0, 0] } }; };

    return {
      steel: spec("lift_steel", "lift_steel_n", "lift_steel_s", 0.8, 110, 0.4),
      steelv: spec("lift_steelv", "lift_steelv_n", "lift_steel_s", 0.8, 110, 0.4),
      dark: spec("lift_dark", "lift_flatn", "lift_steel_s", 0.5, 80, 0),
      panel: spec("lift_panel", "lift_panel_n", "lift_steel_s", 0.8, 120, 1),
      granite: spec("lift_granite", "lift_granite_n", "lift_granite_s", 0.9, 260, 0.8),
      sill: spec("lift_sill", "lift_sill_n", "lift_steel_s", 0.9, 120, 1.2),
      mirror: spec("lift_mirror", "lift_flatn", "lift_mirror_s", 1.6, 600, 0),
      black: spec("lift_black", "lift_flatn", "lift_black", 0.3, 40, 0),
      cop: spec(copKey, "lift_flatn", "lift_steel_s", 0.9, 140, 0),
      call_up: spec("lift_call_up", "lift_flatn", "lift_steel_s", 0.9, 140, 0),
      call_down: spec("lift_call_down", "lift_flatn", "lift_steel_s", 0.9, 140, 0),
      call_both: spec("lift_call_both", "lift_flatn", "lift_steel_s", 0.9, 140, 0),
      light: glow("lift_light", 2.6),
      disp: glow("lift_disp", 1),
      up: glow("lift_up", 2),
      down: glow("lift_down", 2)
    };
  }

  function builder(M) {
    const groups = {};
    const boxes = [];
    const group = function (key) {
      if (!groups[key]) groups[key] = Object.assign({ positions: [], normals: [], uvs: [], indices: [] }, M[key] ? { look: M[key] } : { look: null, key: key });

      return groups[key];
    };
    const quad = function (key, a, b, c, d, uv) {
      const g = group(key);
      const n0 = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
      const n1 = [d[0] - a[0], d[1] - a[1], d[2] - a[2]];
      let n = [n0[1] * n1[2] - n0[2] * n1[1], n0[2] * n1[0] - n0[0] * n1[2], n0[0] * n1[1] - n0[1] * n1[0]];
      const l = Math.hypot(n[0], n[1], n[2]) || 1;
      const base = g.positions.length / 3;

      n = [n[0] / l, n[1] / l, n[2] / l];
      [a, b, c, d].forEach(function (p, i) {
        g.positions.push(p[0], p[1], p[2]);
        g.normals.push(n[0], n[1], n[2]);
        g.uvs.push(uv[i][0], uv[i][1]);
      });
      g.indices.push(base, base + 1, base + 2, base, base + 2, base + 3);
    };
    const api = {
      quad: quad,
      face: function (key, origin, u, v, w, h, uvMode) {
        const a = origin;
        const b = [a[0] + u[0] * w, a[1] + u[1] * w, a[2] + u[2] * w];
        const c = [b[0] + v[0] * h, b[1] + v[1] * h, b[2] + v[2] * h];
        const d = [a[0] + v[0] * h, a[1] + v[1] * h, a[2] + v[2] * h];
        const m = uvMode || { scale: 1 };
        let uv;

        if (m.fit) uv = [[0, 1], [1, 1], [1, 0], [0, 0]];
        else if (m.rect) uv = [[m.rect[0], m.rect[3]], [m.rect[2], m.rect[3]], [m.rect[2], m.rect[1]], [m.rect[0], m.rect[1]]];
        else {
          const s = m.scale || 1;
          const ou = m.u || 0;
          const ov = m.v || 0;

          uv = [[ou, ov + h / s], [ou + w / s, ov + h / s], [ou + w / s, ov], [ou, ov]];
        }

        quad(key, a, b, c, d, uv);
      },
      box: function (key, lo, hi, opts) {
        const o = opts || {};
        const k = function (side) { return (o.keys && o.keys[side]) || key; };
        const uvm = function (side) { return (o.uv && o.uv[side]) || o.uvAll || { scale: o.scale || 1 }; };
        const sx = hi[0] - lo[0];
        const sy = hi[1] - lo[1];
        const sz = hi[2] - lo[2];
        const skip = o.skip || [];

        if (skip.indexOf("-y") < 0) api.face(k("-y"), [lo[0], lo[1], lo[2]], [1, 0, 0], [0, 0, 1], sx, sz, uvm("-y"));
        if (skip.indexOf("+y") < 0) api.face(k("+y"), [hi[0], hi[1], lo[2]], [-1, 0, 0], [0, 0, 1], sx, sz, uvm("+y"));
        if (skip.indexOf("-x") < 0) api.face(k("-x"), [lo[0], hi[1], lo[2]], [0, -1, 0], [0, 0, 1], sy, sz, uvm("-x"));
        if (skip.indexOf("+x") < 0) api.face(k("+x"), [hi[0], lo[1], lo[2]], [0, 1, 0], [0, 0, 1], sy, sz, uvm("+x"));
        if (skip.indexOf("+z") < 0) api.face(k("+z"), [lo[0], lo[1], hi[2]], [1, 0, 0], [0, 1, 0], sx, sy, uvm("+z"));
        if (skip.indexOf("-z") < 0) api.face(k("-z"), [lo[0], hi[1], lo[2]], [1, 0, 0], [0, -1, 0], sx, sy, uvm("-z"));
        if (o.collide) boxes.push({ min: lo.slice(), max: hi.slice() });
      },
      collide: function (lo, hi) { boxes.push({ min: lo.slice(), max: hi.slice() }); },
      disc: function (key, radius) {
        const g = group(key);
        const base = g.positions.length / 3;
        const n = 32;

        g.positions.push(0, 0, 0);
        g.normals.push(0, -1, 0);
        g.uvs.push(0.5, 0.5);

        for (let k = 0; k <= n; k++) {
          const a = 2 * Math.PI * k / n;

          g.positions.push(Math.cos(a) * radius, 0, Math.sin(a) * radius);
          g.normals.push(0, -1, 0);
          g.uvs.push(0.5 + Math.cos(a) * 0.5, 0.5 - Math.sin(a) * 0.5);
        }

        for (let k = 0; k < n; k++) g.indices.push(base, base + 1 + k, base + 2 + k);
      },
      tube: function (key, a, b, r, sides, collide) {
        const d = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
        const len = Math.hypot(d[0], d[1], d[2]) || 1;
        const t = [d[0] / len, d[1] / len, d[2] / len];
        const ref = Math.abs(t[2]) < 0.9 ? [0, 0, 1] : [1, 0, 0];
        let u = [t[1] * ref[2] - t[2] * ref[1], t[2] * ref[0] - t[0] * ref[2], t[0] * ref[1] - t[1] * ref[0]];
        const ul = Math.hypot(u[0], u[1], u[2]);

        u = [u[0] / ul, u[1] / ul, u[2] / ul];

        const v = [t[1] * u[2] - t[2] * u[1], t[2] * u[0] - t[0] * u[2], t[0] * u[1] - t[1] * u[0]];
        const n = sides || 12;
        const g = group(key);
        const ring = function (c, k) {
          const ang = 2 * Math.PI * k / n;
          const dir = [u[0] * Math.cos(ang) + v[0] * Math.sin(ang), u[1] * Math.cos(ang) + v[1] * Math.sin(ang), u[2] * Math.cos(ang) + v[2] * Math.sin(ang)];

          return { p: [c[0] + dir[0] * r, c[1] + dir[1] * r, c[2] + dir[2] * r], n: dir };
        };
        const base = g.positions.length / 3;

        for (let k = 0; k <= n; k++) {
          [a, b].forEach(function (c, end) {
            const q = ring(c, k);

            g.positions.push(q.p[0], q.p[1], q.p[2]);
            g.normals.push(q.n[0], q.n[1], q.n[2]);
            g.uvs.push(k / n * 0.3, end * len);
          });
        }

        for (let k = 0; k < n; k++) {
          const i = base + k * 2;

          g.indices.push(i, i + 2, i + 3, i, i + 3, i + 1);
        }

        [[a, -1], [b, 1]].forEach(function (cap) {
          const c = cap[0];
          const centre = g.positions.length / 3;

          g.positions.push(c[0], c[1], c[2]);
          g.normals.push(t[0] * cap[1], t[1] * cap[1], t[2] * cap[1]);
          g.uvs.push(0.5, 0.5);

          for (let k = 0; k <= n; k++) {
            const q = ring(c, k);

            g.positions.push(q.p[0], q.p[1], q.p[2]);
            g.normals.push(t[0] * cap[1], t[1] * cap[1], t[2] * cap[1]);
            g.uvs.push(0.5, 0.5);
          }

          for (let k = 0; k < n; k++) {
            if (cap[1] > 0) g.indices.push(centre, centre + 1 + k, centre + 2 + k);
            else g.indices.push(centre, centre + 2 + k, centre + 1 + k);
          }
        });

        if (collide) boxes.push({ min: [Math.min(a[0], b[0]) - r, Math.min(a[1], b[1]) - r, Math.min(a[2], b[2]) - r], max: [Math.max(a[0], b[0]) + r, Math.max(a[1], b[1]) + r, Math.max(a[2], b[2]) + r] });
      },
      done: function (lamps) {
        const meshes = Object.keys(groups).filter(function (k) { return groups[k].look && groups[k].indices.length; }).map(function (k) {
          const g = groups[k];

          return { positions: g.positions, normals: g.normals, uvs: g.uvs, indices: g.indices, shader: g.look.shader, textures: g.look.textures, params: g.look.params };
        });

        if (boxes.length) {
          const lo = [Infinity, Infinity, Infinity];
          const hi = [-Infinity, -Infinity, -Infinity];

          meshes.forEach(function (m) {
            for (let i = 0; i < m.positions.length; i += 3) {
              for (let k = 0; k < 3; k++) {
                lo[k] = Math.min(lo[k], m.positions[i + k]);
                hi[k] = Math.max(hi[k], m.positions[i + k]);
              }
            }
          });

          const blo = [Infinity, Infinity, Infinity];
          const bhi = [-Infinity, -Infinity, -Infinity];

          boxes.forEach(function (b) {
            for (let k = 0; k < 3; k++) {
              blo[k] = Math.min(blo[k], b.min[k]);
              bhi[k] = Math.max(bhi[k], b.max[k]);
            }
          });

          if (lo.some(function (v, k) { return v < blo[k] - 0.001; })) boxes.push({ min: lo.slice(), max: [lo[0] + 0.001, lo[1] + 0.001, lo[2] + 0.001] });
          if (hi.some(function (v, k) { return v > bhi[k] + 0.001; })) boxes.push({ min: [hi[0] - 0.001, hi[1] - 0.001, hi[2] - 0.001], max: hi.slice() });
        }

        return { meshes: meshes, boxes: boxes, lamps: lamps || [] };
      }
    };

    return api;
  }

  function cabin(e, M) {
    const L = e.layout;
    const B = builder(M);
    const x0 = -L.cwH;
    const x1 = L.cwH;
    const y0 = L.cy0;
    const y1 = L.cy1;
    const H = L.CH;
    const f = L.floor || 0.02;
    const t = 0.03;
    const dh = L.door / 2;
    const depth = y1 - y0;
    const ix0 = x0 + t;
    const ix1 = x1 - t;
    const iy0 = y0 + t;
    const iy1 = y1 - t;
    const bw = ix1 - ix0;

    B.box("steel", [x0, y0, f - 0.14], [x1, y1, f], { keys: { "+z": "granite" }, uv: { "+z": { scale: 0.9 } }, collide: true });
    B.box("sill", [-dh - 0.05, L.landB + 0.033, f - 0.03], [dh + 0.05, y0 + 0.03, f + 0.002], { uv: { "+z": { scale: 0.25 } }, collide: true });

    B.box("steel", [x0, iy0, 0], [ix0, y1, H], { collide: true });
    B.box("steel", [ix1, iy0, 0], [x1, y1, H], { collide: true });
    B.box("steel", [ix0, iy1, 0], [ix1, y1, H], { collide: true });
    B.box("steel", [x0, y0, 0], [-dh, iy0, H], { collide: true });
    B.box("steel", [dh, y0, 0], [x1, iy0, H], { collide: true });
    B.box("steel", [-dh, y0, L.doorH], [dh, iy0, H], { collide: true });

    const pz0 = f + 0.12;
    const pz1 = H - 0.1;
    const sidePanels = Math.max(1, Math.round((iy1 - iy0) / 0.7));
    const pw = (iy1 - iy0) / sidePanels;

    for (let i = 0; i < sidePanels; i++) {
      B.face("panel", [ix0 + 0.0015, iy0 + i * pw, pz0], [0, 1, 0], [0, 0, 1], pw, pz1 - pz0, { fit: true });
      B.face("panel", [ix1 - 0.0015, iy0 + (i + 1) * pw, pz0], [0, -1, 0], [0, 0, 1], pw, pz1 - pz0, { fit: true });
    }

    B.face("dark", [ix0 + 0.002, iy0, f], [0, 1, 0], [0, 0, 1], iy1 - iy0, 0.11, { scale: 0.5 });
    B.face("dark", [ix1 - 0.002, iy1, f], [0, -1, 0], [0, 0, 1], iy1 - iy0, 0.11, { scale: 0.5 });
    B.face("dark", [ix0, iy1 - 0.002, f], [1, 0, 0], [0, 0, 1], bw, 0.11, { scale: 0.5 });
    B.face("dark", [-dh, iy0 + 0.002, f], [-1, 0, 0], [0, 0, 1], -dh - ix0, 0.11, { scale: 0.5 });
    B.face("dark", [ix1, iy0 + 0.002, f], [-1, 0, 0], [0, 0, 1], ix1 - dh, 0.11, { scale: 0.5 });

    const backPanels = Math.max(1, Math.round(bw / 0.6));
    const bpw = bw / backPanels;

    for (let i = 0; i < backPanels; i++) B.face("panel", [ix0 + i * bpw, iy1 - 0.0015, pz0], [1, 0, 0], [0, 0, 1], bpw, 0.8, { fit: true });

    const mz0 = pz0 + 0.84;
    const mz1 = pz1 - 0.04;

    B.face("mirror", [ix0 + 0.07, iy1 - 0.003, mz0], [1, 0, 0], [0, 0, 1], bw - 0.14, mz1 - mz0, { fit: true });
    B.box("steelv", [ix0 + 0.05, iy1 - 0.014, mz0 - 0.02], [ix1 - 0.05, iy1 - 0.001, mz0], {});
    B.box("steelv", [ix0 + 0.05, iy1 - 0.014, mz1], [ix1 - 0.05, iy1 - 0.001, mz1 + 0.02], {});
    B.box("steelv", [ix0 + 0.05, iy1 - 0.014, mz0], [ix0 + 0.07, iy1 - 0.001, mz1], {});
    B.box("steelv", [ix1 - 0.07, iy1 - 0.014, mz0], [ix1 - 0.05, iy1 - 0.001, mz1], {});

    B.face("panel", [-dh, iy0 + 0.0015, pz0], [-1, 0, 0], [0, 0, 1], -dh - ix0, pz1 - pz0, { fit: true });
    B.box("steelv", [-dh - 0.03, iy0, f], [-dh, iy0 + 0.014, L.doorH + 0.03], {});
    B.box("steelv", [dh, iy0, f], [dh + 0.03, iy0 + 0.014, L.doorH + 0.03], {});
    B.box("steelv", [-dh - 0.03, iy0, L.doorH], [dh + 0.03, iy0 + 0.014, L.doorH + 0.03], {});
    B.box("steel", [-0.2, iy0, H - 0.17], [0.2, iy0 + 0.012, H - 0.02], {});
    B.face("disp", [0.18, iy0 + 0.0125, H - 0.15], [-1, 0, 0], [0, 0, 1], 0.36, 0.11, { fit: true });

    const copW = L.copW || 0.18;
    const copX = L.copX || (dh + 0.03 + x1) / 2 + copW / 2;

    const copH = L.copH || copW * 4;
    const copZ0 = L.copZ0 || 1.62 - copH;

    B.box("steelv", [copX - copW - 0.01, iy0, copZ0 - 0.02], [copX + 0.01, iy0 + 0.006, copZ0 + copH + 0.02], {});
    B.face("cop", [copX, iy0 + 0.0065, copZ0], [-1, 0, 0], [0, 0, 1], copW, copH, { fit: true });

    const rz = 0.92;
    const r = 0.018;

    B.tube("steelv", [ix0 + 0.16, iy1 - 0.055, rz], [ix1 - 0.16, iy1 - 0.055, rz], r, 14);
    [ix0 + 0.24, ix1 - 0.24].forEach(function (x) { B.tube("steelv", [x, iy1 - 0.055, rz], [x, iy1, rz], 0.008, 8); });
    [[ix0, 1], [ix1, -1]].forEach(function (pair) {
      const wx = pair[0] + pair[1] * 0.055;
      const ya = iy0 + 0.42;
      const yb = iy1 - 0.16;

      B.tube("steelv", [wx, ya, rz], [wx, yb, rz], r, 14);
      [ya + 0.08, yb - 0.08].forEach(function (y) { B.tube("steelv", [wx, y, rz], [pair[0], y, rz], 0.008, 8); });
    });

    B.box("steel", [x0, y0, H], [x1, y1, H + 0.08], { collide: true });
    B.face("dark", [ix0, iy1, H - 0.001], [1, 0, 0], [0, -1, 0], bw, iy1 - iy0, { scale: 1 });
    B.face("light", [ix0 + 0.14, iy1 - 0.14, H - 0.006], [1, 0, 0], [0, -1, 0], bw - 0.28, iy1 - iy0 - 0.28, { fit: true });
    B.box("steel", [ix0 + 0.11, iy0 + 0.11, H - 0.025], [ix1 - 0.11, iy0 + 0.14, H - 0.001], {});
    B.box("steel", [ix0 + 0.11, iy1 - 0.14, H - 0.025], [ix1 - 0.11, iy1 - 0.11, H - 0.001], {});
    B.box("steel", [ix0 + 0.11, iy0 + 0.11, H - 0.025], [ix0 + 0.14, iy1 - 0.11, H - 0.001], {});
    B.box("steel", [ix1 - 0.14, iy0 + 0.11, H - 0.025], [ix1 - 0.11, iy1 - 0.11, H - 0.001], {});

    return B.done([{ x: 0, y: (y0 + y1) / 2, z: H - 0.3, colour: "#fff3e2", range: 4.5, intensity: 12 }]);
  }

  function leaf(e, M, landing) {
    const L = e.layout;
    const B = builder(M);
    const w = L.leaf;
    const h = L.doorH;

    B.box("steelv", [0, 0, 0], [w, L.leafT, h], { uvAll: { scale: 1.4 }, collide: true });
    B.box("black", [w - 0.008, -0.0015, 0.015], [w + 0.0015, L.leafT + 0.0015, h - 0.015], {});
    B.box("dark", [0, -0.001, h - 0.012], [w, L.leafT + 0.001, h + 0.001], {});

    if (landing) {
      B.box("steelv", [0.03, -0.003, 0.09], [w - 0.03, 0.0005, 0.095], {});
      B.box("steelv", [0.03, L.leafT - 0.0005, 0.09], [w - 0.03, L.leafT + 0.003, 0.095], {});
    }

    return B.done();
  }

  function fixture(e, M, kind) {
    const L = e.layout;
    const B = builder(M);
    const f = L.floor || 0.02;
    const dh = L.door / 2;
    const yo = -L.hd;
    const fw = 0.09;
    const top = L.doorH;

    B.box("steel", [-dh - fw, yo - 0.022, 0], [-dh, yo + 0.002, top + fw], { collide: true });
    B.box("steel", [dh, yo - 0.022, 0], [dh + fw, yo + 0.002, top + fw], { collide: true });
    B.box("steel", [-dh, yo - 0.022, top], [dh, yo + 0.002, top + fw], { collide: true });
    B.box("steelv", [-dh - fw - 0.012, yo - 0.012, 0], [-dh - fw, yo + 0.002, top + fw + 0.012], {});
    B.box("steelv", [dh + fw, yo - 0.012, 0], [dh + fw + 0.012, yo + 0.002, top + fw + 0.012], {});
    B.box("steelv", [-dh - fw - 0.012, yo - 0.012, top + fw], [dh + fw + 0.012, yo + 0.002, top + fw + 0.012], {});
    B.face("steelv", [-dh + 0.003, yo, 0], [0, 1, 0], [0, 0, 1], L.T, top, { scale: 1 });
    B.face("steelv", [dh - 0.003, L.yF, 0], [0, -1, 0], [0, 0, 1], L.T, top, { scale: 1 });
    B.face("steel", [-dh, L.yF, top - 0.003], [1, 0, 0], [0, -1, 0], L.door, L.T, { scale: 1 });
    B.box("sill", [-dh - 0.03, yo - 0.04, -0.01], [dh + 0.03, L.landB + 0.031, f * 0.6], { uv: { "+z": { scale: 0.25 } }, collide: true });

    const dz = top + fw + 0.04;

    B.box("steel", [-0.24, yo - 0.022, dz], [0.24, yo + 0.002, dz + 0.17], { collide: true });
    B.face("disp", [-0.21, yo - 0.0225, dz + 0.025], [1, 0, 0], [0, 0, 1], 0.42, 0.12, { fit: true });

    const px = L.callX || dh + fw + 0.18;

    B.box("steel", [px - 0.065, yo - 0.016, 0.95], [px + 0.065, yo + 0.002, 1.25], { collide: true });
    B.face("call_" + kind, [px - 0.06, yo - 0.0165, 0.955], [1, 0, 0], [0, 0, 1], 0.12, 0.29, { fit: true });

    return B.done();
  }

  function disc(M, key, radius) {
    const B = builder(M);

    B.disc(key, radius);

    return B.done();
  }

  function glyph(M, key) {
    const B = builder(M);

    B.face(key, [-0.05, 0, -0.05], [1, 0, 0], [0, 0, 1], 0.1, 0.1, { fit: true });

    return B.done();
  }

  LIFT.names = function (base, index) {
    const p = base + "_e" + index;

    return { cabin: p + "c", car: p + "k", landing: p + "d", fixture: [p + "f0", p + "f1", p + "f2"], up: p + "a", down: p + "b", callUp: p + "u", callDown: p + "w", digit: function (i) { return p + "n" + i; }, lit: function (i) { return p + "p" + i; } };
  };

  LIFT.parts = function (built, base) {
    const out = [];

    (built.elevators || []).forEach(function (e, i) {
      if (!e.layout || !e.stops || e.stops.length < 2) return;

      const labels = (e.labels || e.stops.map(function (z, k) { return String(k); }));
      const M = mats(labels);
      const N = LIFT.names(base, i + 1);
      const add = function (name, made, size) { out.push({ name: name, built: { pieces: [], doors: [], lamps: made.lamps, meshes: made.meshes, boxes: made.boxes }, textureSize: size || 512 }); };

      add(N.cabin, cabin(e, M), 1024);
      add(N.car, leaf(e, M, false));
      add(N.landing, leaf(e, M, true));
      add(N.fixture[0], fixture(e, M, "up"));
      add(N.fixture[1], fixture(e, M, "both"));
      add(N.fixture[2], fixture(e, M, "down"));
      add(N.up, glyph(M, "up"));
      add(N.down, glyph(M, "down"));
      const glowParams = Object.assign({}, M.up.params, { emissiveMultiplier: [1.1, 0, 0, 0] });

      labels.forEach(function (label, k) {
        const key = "dg" + k;
        const lit = "pl" + k;

        M[key] = { shader: "emissive", textures: { DiffuseSampler: "lift_d_" + label.replace("-", "m") }, params: M.up.params };
        M[lit] = { shader: "emissive", textures: { DiffuseSampler: "lift_p_" + label.replace("-", "m") }, params: glowParams };
        add(N.digit(k + 1), glyph(M, key));
        add(N.lit(k + 1), disc(M, lit, (e.layout.buttons && e.layout.buttons[k] ? e.layout.buttons[k][2] : 0.015)));
      });
      M.plu = { shader: "emissive", textures: { DiffuseSampler: "lift_p_up" }, params: glowParams };
      M.pld = { shader: "emissive", textures: { DiffuseSampler: "lift_p_down" }, params: glowParams };
      add(N.callUp, disc(M, "plu", e.layout.callR || 0.03));
      add(N.callDown, disc(M, "pld", e.layout.callR || 0.03));
    });

    return out;
  };

  LIFT.images = function (built) {
    const out = {};

    (built.elevators || []).forEach(function (e) {
      Object.assign(out, LIFT.textures(e.labels || e.stops.map(function (z, k) { return String(k); })));
    });

    return out;
  };

  if (typeof module !== "undefined" && module.exports) module.exports = LIFT;

  root.RTX_SHELLLIFT = LIFT;
})(typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : globalThis);
