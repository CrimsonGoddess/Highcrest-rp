const SG = window.RTX_SHELLGEO;

const SHELL = {
  kit: null,
  kitLoading: null,
  doc: null,
  built: null,
  summary: null,
  editors: [],
  me: 0,
  mode: "split",
  tool: "select",
  sub: "door",
  level: "l1",
  view: { x: 0, y: 0, scale: 46 },
  sel: null,
  hover: null,
  undo: [],
  redo: [],
  pending: [],
  nextToken: 1,
  paint: { material: "white", target: "auto" },
  point: "exit",
  thick: 0.2,
  drag: null,
  draft: null,
  dims: {},
  patterns: {},
  images: {},
  dirty: true,
  checks: [],
  panel: "",
  walking: false,
  open: false,
  library: [],
  replies: {},
  presenceAt: 0,
  cursor: null,
  measure: null,
  stairs: { type: "straight", turn: "right", dir: "up", width: 1, material: "oak", rail: true },
  pool: { w: 4, l: 8, depth: 1.5, tile: "pooltile", edge: "terrazzo", ladder: true },
  details: { kind: "column", heading: 0, w: null, d: null, h: null, mat: null, top: null },
  part: { height: "lower", split: 1.1 },
  lamp: "round",
  ghostModel: null,
  ghostHeading: 0,
  ghostAt: null,
  available: null
};

const SHELL_TOOLS = [
  { id: "select", icon: "fa-arrow-pointer", key: "V" },
  { id: "walls", icon: "fa-pen-ruler", key: "W" },
  { id: "room", icon: "fa-vector-square", key: "R" },
  { id: "opening", icon: "fa-door-open", key: "D" },
  { id: "stairs", icon: "fa-stairs", key: "S" },
  { id: "pool", icon: "fa-water-ladder", key: "O" },
  { id: "details", icon: "fa-cubes-stacked", key: "X" },
  { id: "paint", icon: "fa-paint-roller", key: "P" },
  { id: "light", icon: "fa-lightbulb", key: "L" },
  { id: "points", icon: "fa-location-crosshairs", key: "T" },
  { id: "furniture", icon: "fa-couch", key: "F" },
  { id: "roof", icon: "fa-house-chimney", key: "U" },
  { id: "measure", icon: "fa-ruler", key: "M" },
  { id: "hammer", icon: "fa-hammer", key: "H" }
];

const SHELL_CAM_KEYS = { arrowup: "fwd", arrowdown: "back", arrowleft: "left", arrowright: "right", q: "rotl", e: "rotr", pageup: "up", pagedown: "down" };

const SHELL_OPENINGS = [
  { id: "door", icon: "fa-door-closed", group: "doors" },
  { id: "glassdoor", icon: "fa-door-open", group: "doors" },
  { id: "double", icon: "fa-dungeon", group: "doors" },
  { id: "french", icon: "fa-table-columns", group: "doors" },
  { id: "slider", icon: "fa-arrows-left-right", group: "doors" },
  { id: "fake", icon: "fa-ban", group: "doors" },
  { id: "window", icon: "fa-border-all", group: "windows" },
  { id: "tall", icon: "fa-grip-lines-vertical", group: "windows" },
  { id: "picture", icon: "fa-panorama", group: "windows" },
  { id: "strip", icon: "fa-window-minimize", group: "windows" },
  { id: "small", icon: "fa-square", group: "windows" },
  { id: "archwin", icon: "fa-archway", group: "windows" },
  { id: "round", icon: "fa-circle", group: "windows" },
  { id: "opening", icon: "fa-square-full", group: "openings" },
  { id: "arch", icon: "fa-archway", group: "openings" },
  { id: "wide", icon: "fa-arrows-left-right-to-line", group: "openings" },
  { id: "half", icon: "fa-grip-lines", group: "openings" },
  { id: "garage", icon: "fa-warehouse", group: "openings" }
];
const SHELL_PLANE_TOOLS = ["walls", "room", "details", "pool", "stairs", "measure", "light", "points"];
const SHELL_LINE_DETAILS = ["glassrail", "rail", "fence", "gardenwall", "hedge", "halfwall", "beam", "glasswall"];
const SHELL_FRAMES = ["white", "oak", "darkwood", "walnut", "steel", "blackm", "brass", "whitem", "marble", "concrete"];
const SHELL_SILLS = ["marble", "mblack", "white", "oak", "darkwood", "terrazzo", "granite", "slate"];

const SHELL_POINTS = [
  { id: "exit", icon: "fa-door-open", glyph: "" },
  { id: "management", icon: "fa-clipboard-list", glyph: "" },
  { id: "wardrobe", icon: "fa-shirt", glyph: "" },
  { id: "storage", icon: "fa-box-archive", glyph: "" },
  { id: "cook", icon: "fa-fire-burner", glyph: "" },
  { id: "sinks", icon: "fa-sink", glyph: "", many: true },
  { id: "showers", icon: "fa-shower", glyph: "", many: true },
  { id: "clean", icon: "fa-broom", glyph: "", many: true }
];

function shellKit() {
  if (SHELL.kit) return Promise.resolve(SHELL.kit);
  if (SHELL.kitLoading) return SHELL.kitLoading;

  SHELL.kitLoading = fetch("../data/kit.json").then(function (r) { return r.json(); }).then(function (kit) {
    SHELL.kit = kit;
    kit.all = (kit.materials || []).concat(kit.slots || [], kit.customs || []);

    if (kit.tints) {
      kit.tints.bases.forEach(function (base) {
        kit.tints.colours.forEach(function (hex, index) {
          const n = index + 1;

          kit.all.push({ key: base.prefix + (n < 10 ? "0" : "") + n, group: base.prefix === "p" ? "paint" : "stain", colour: hex, tint: true, name: hex });
        });
      });
    }
    kit.all.forEach(function (m) {
      const image = new Image();

      image.onload = function () { SHELL.dirty = true; };
      image.src = "img/kit/" + m.key + ".webp";
      SHELL.images[m.key] = image;
    });

    return kit;
  }).catch(function () {
    SHELL.kit = { prefix: "rtx_tk_", materials: [], slots: [], doors: [], all: [] };
    return SHELL.kit;
  });

  return SHELL.kitLoading;
}

function shellRequest(action, payload) {
  return new Promise(function (resolve) {
    const tokenId = "s" + SHELL.nextToken++;

    SHELL.replies[tokenId] = resolve;
    post("shell", { action: action, payload: payload || {}, token: tokenId });
  });
}

function shellCustomFile(slot) {
  const own = SHELL.doc && SHELL.doc.customs && SHELL.doc.customs[slot];

  return typeof own === "string" && own ? own : slot;
}

function shellCustomName(file) {
  const lib = (SHELL.customLib || []).find(function (x) { return x.file === file; });
  const names = (STATE.setup && STATE.setup.customtextures) || {};

  if (lib) return lib.name;
  if (typeof names[file] === "string") return names[file];

  return /^c[1-6]$/.test(file) ? T("sh_custom_slot", file.slice(1)) : file.replace(/[_-]+/g, " ").replace(/^./, function (c) { return c.toUpperCase(); });
}

function shellCustomImage(slot) {
  const file = shellCustomFile(slot);

  SHELL.customImages = SHELL.customImages || {};

  if (!SHELL.customImages[file]) {
    const image = new Image();

    image.onload = function () { SHELL.dirty = true; };
    image.src = "../custom/" + file + ".png";
    SHELL.customImages[file] = image;
  }

  return SHELL.customImages[file];
}

function shellCustomLibrary() {
  if (SHELL.customLib || SHELL.customLoading) return SHELL.customLoading || Promise.resolve(SHELL.customLib);

  SHELL.customLoading = shellRequest("customs", {}).then(function (reply) {
    SHELL.customLib = reply && Array.isArray(reply.list) ? reply.list : [];
    SHELL.customLoading = null;

    return SHELL.customLib;
  }, function () {
    SHELL.customLib = [];
    SHELL.customLoading = null;

    return SHELL.customLib;
  });

  return SHELL.customLoading;
}

function shellCustomUsed() {
  const used = {};
  const text = JSON.stringify(SHELL.doc || {}, function (k, v) { return k === "customs" ? undefined : v; });
  const re = /"(c[1-6])"/g;
  let m;

  while ((m = re.exec(text))) used[m[1]] = true;

  return used;
}

function shellCustomAssign(file) {
  const slots = ["c1", "c2", "c3", "c4", "c5", "c6"];
  const used = shellCustomUsed();
  const have = slots.find(function (slot) { return shellCustomFile(slot) === file; });

  if (have) return have;

  const free = slots.find(function (slot) { return !used[slot]; });

  if (!free) return null;

  const value = {};

  value[free] = file;
  shellCommit({ root: { customs: value } });

  return free;
}

function shellMaterialName(key) {
  const kit = SHELL.kit || { all: [] };
  const m = kit.all.find(function (x) { return x.key === key; });

  if (!m) return key || "-";
  if (m.group === "colour") return T("sh_colour_slot", key.slice(1));
  if (m.group === "paint" || m.group === "stain") return T(m.group === "paint" ? "sh_paint_colour" : "sh_stain_colour", key.slice(1));
  if (m.group === "custom") return shellCustomName(shellCustomFile(key));

  return T("mat_" + key) !== "mat_" + key ? T("mat_" + key) : m.name;
}

function shellPartsChip(parts) {
  if (!parts) return el("div", "sh-parts").attr("title", T("sh_parts_hint")).append(icon("fa-cubes"), $("<span></span>").text("–"));

  const allowed = parts.allowed !== undefined ? parts.allowed : parts.total;
  const loading = parts.shown + 5 < allowed;
  const ratio = Math.max(0, Math.min(1, parts.shown / Math.max(1, allowed)));
  const chip = el("div", "sh-parts" + (parts.full ? " bad" : loading ? " warn" : "")).attr("title", T("sh_parts_hint") + (loading ? " " + T("sh_parts_loading", Math.round(100 * ratio)) : "")).append(icon("fa-cubes"), $("<span></span>").text(T("sh_parts_count", parts.total)));

  if (loading) chip.append(el("i", "sh-parts-bar").css("width", Math.round(100 * ratio) + "%"));

  return chip;
}

function shellMatRow(keys, current, onPick) {
  const row = el("div", "sh-palette-row");

  keys.forEach(function (key) {
    row.append(el("button", "sh-mat" + (current === key ? " active" : "")).attr("title", shellMaterialName(key)).append(shellSwatch(key, "big")).on("click", function () { onPick(key); }));
  });

  return row;
}

function shellSwatch(key, size) {
  const node = el("span", "sh-swatch" + (size ? " " + size : ""));

  if (/^s[1-6]$/.test(String(key))) {
    node.css("background", (SHELL.doc && SHELL.doc.colours && SHELL.doc.colours[key]) || "#cccccc");
    node.addClass("slot");
  } else if (/^[pw]\d\d$/.test(String(key)) && SHELL.kit && SHELL.kit.tints) {
    const hex = SHELL.kit.tints.colours[Number(String(key).slice(1)) - 1] || "#cccccc";

    node.css("background", key[0] === "w" ? "repeating-linear-gradient(0deg, rgba(0,0,0,0.12) 0 1px, transparent 1px 6px), " + hex : hex);
    node.addClass("slot");
  } else if (/^c[1-6]$/.test(String(key)) || /^lib:/.test(String(key))) {
    const file = /^lib:/.test(String(key)) ? String(key).slice(4) : shellCustomFile(key);

    node.css({ "background-color": "#6b6f78", "background-image": "url(../custom/" + file + ".png)", "background-size": "cover" });
    node.addClass("custom");
  } else if (key) {
    node.css("background-image", "url(img/kit/" + key + ".webp)");
  }

  return node;
}

const SHELL_SFX = {
  ctx: null,
  out: null,
  noise: null,
  last: {},
  on: function () {
    if (STATE.setup && STATE.setup.shellsounds === false) return false;

    try {
      return localStorage.getItem("rtx_shell_sounds") !== "off";
    } catch (err) {
      return true;
    }
  },
  setOn: function (on) {
    try {
      localStorage.setItem("rtx_shell_sounds", on ? "on" : "off");
    } catch (err) {
      return;
    }
  },
  init: function () {
    if (this.ctx) return this.ctx;

    const Ctx = window.AudioContext || window.webkitAudioContext;

    if (!Ctx) return null;

    try {
      const ctx = new Ctx();
      const comp = ctx.createDynamicsCompressor();
      const gain = ctx.createGain();
      const length = Math.floor(ctx.sampleRate * 1.2);
      const buffer = ctx.createBuffer(1, length, ctx.sampleRate);
      const data = buffer.getChannelData(0);
      let seed = 1234567;

      for (let i = 0; i < length; i++) {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        data[i] = seed / 0x3fffffff - 1;
      }

      comp.threshold.value = -14;
      comp.ratio.value = 4;
      gain.gain.value = 4.5 * Math.max(0, Math.min(1, Number(STATE.setup && STATE.setup.shellvolume) || 0.6));
      gain.connect(comp);
      comp.connect(ctx.destination);
      this.ctx = ctx;
      this.out = gain;
      this.noise = buffer;
    } catch (err) {
      this.ctx = null;
    }

    return this.ctx;
  },
  tone: function (t, type, f0, f1, dur, vol, attack) {
    const ctx = this.ctx;
    const osc = ctx.createOscillator();
    const g = ctx.createGain();

    osc.type = type;
    osc.frequency.setValueAtTime(f0, t);
    if (f1 && f1 !== f0) osc.frequency.exponentialRampToValueAtTime(f1, t + dur);
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(vol, t + (attack || 0.004));
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    osc.connect(g);
    g.connect(this.out);
    osc.start(t);
    osc.stop(t + dur + 0.02);
  },
  hiss: function (t, kind, f0, f1, q, dur, vol, attack) {
    const ctx = this.ctx;
    const src = ctx.createBufferSource();
    const filter = ctx.createBiquadFilter();
    const g = ctx.createGain();

    src.buffer = this.noise;
    filter.type = kind;
    filter.Q.value = q || 1;
    filter.frequency.setValueAtTime(f0, t);
    if (f1 && f1 !== f0) filter.frequency.exponentialRampToValueAtTime(f1, t + dur);
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(vol, t + (attack || 0.003));
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    src.connect(filter);
    filter.connect(g);
    g.connect(this.out);
    src.start(t, Math.random() * 0.8);
    src.stop(t + dur + 0.02);
  },
  play: function (name) {
    if (!this.on() || !SHELL.open) return;

    const now = Date.now();

    if (this.last[name] && now - this.last[name] < (name === "paint" ? 70 : 35)) return;

    this.last[name] = now;

    const ctx = this.init();

    if (!ctx) return;
    if (ctx.state === "suspended" && ctx.resume) ctx.resume().catch(function () {});

    const t = ctx.currentTime + 0.005;
    const v = 0.9 + Math.random() * 0.2;
    const S = this;

    ({
      tick: function () {
        S.tone(t, "sine", 1900 * v, 1300 * v, 0.035, 0.08);
        S.hiss(t, "highpass", 5000, 5000, 0.7, 0.012, 0.03);
      },
      open: function () {
        S.tone(t, "sine", 520, 780, 0.12, 0.12, 0.01);
        S.tone(t + 0.07, "sine", 780, 1040, 0.16, 0.1, 0.01);
      },
      corner: function () {
        S.tone(t, "triangle", 980 * v, 760 * v, 0.05, 0.16);
        S.hiss(t, "bandpass", 2600, 1800, 3, 0.03, 0.08);
      },
      place: function () {
        S.tone(t, "sine", 330 * v, 620 * v, 0.07, 0.22, 0.004);
        S.tone(t + 0.045, "sine", 620 * v, 520 * v, 0.12, 0.12, 0.004);
        S.hiss(t, "bandpass", 1300, 900, 1.5, 0.05, 0.06);
      },
      build: function () {
        S.tone(t, "sine", 150 * v, 70 * v, 0.18, 0.4, 0.003);
        S.hiss(t, "lowpass", 1400, 300, 0.8, 0.12, 0.22);
        S.tone(t + 0.06, "triangle", 660 * v, 880 * v, 0.14, 0.07, 0.01);
      },
      paint: function () {
        S.hiss(t, "bandpass", 700 * v, 3200 * v, 1.2, 0.22, 0.18, 0.04);
        S.tone(t + 0.12, "sine", 420 * v, 560 * v, 0.1, 0.07, 0.01);
      },
      remove: function () {
        S.hiss(t, "lowpass", 2200, 400, 0.9, 0.16, 0.32);
        S.tone(t, "sine", 240 * v, 80 * v, 0.16, 0.32, 0.003);
        [0.03, 0.06, 0.1].forEach(function (d) { S.hiss(t + d, "bandpass", 3000 + Math.random() * 1500, 2000, 4, 0.025, 0.07); });
      },
      undo: function () {
        S.tone(t, "sine", 740, 600, 0.07, 0.12);
        S.tone(t + 0.06, "sine", 560, 440, 0.1, 0.1);
      },
      redo: function () {
        S.tone(t, "sine", 440, 560, 0.07, 0.1);
        S.tone(t + 0.06, "sine", 600, 740, 0.1, 0.12);
      },
      pick: function () {
        S.tone(t, "sine", 600, 1250, 0.09, 0.14, 0.004);
      },
      error: function () {
        S.tone(t, "triangle", 230, 210, 0.11, 0.14);
        S.tone(t + 0.11, "triangle", 180, 160, 0.16, 0.14);
      }
    }[name] || function () {})();
  }
};

function shellSfxFor(patch) {
  if (!patch) return "";

  const has = function (group, key) { return !!(patch[group] && Array.isArray(patch[group][key]) && patch[group][key].length); };

  if (patch.del && Object.keys(patch.del).some(function (k) { return has("del", k); })) return "remove";
  if (SHELL.tool === "paint") return "paint";
  if (has("set", "walls") || has("set", "levels")) return "build";
  if (patch.set && Object.keys(patch.set).length) return "place";

  return "tick";
}

function shellRebuild() {
  if (!SHELL.doc || !SHELL.kit) return;

  const started = performance.now();

  clearTimeout(SHELL.rebuildTimer);
  SHELL.rebuildTimer = null;
  SHELL.built = SG.build(SHELL.doc, SHELL.kit);
  SHELL.checks = SG.checks(SHELL.doc, SHELL.built, STATE.setup.budget || 800);
  SHELL.dirty = true;
  SHELL.rebuildCost = performance.now() - started;
  SHELL.rebuildAt = performance.now();
}

function shellRebuildSoon() {
  SHELL.dirty = true;

  if (SHELL.rebuildTimer) return;

  const cost = SHELL.rebuildCost || 0;
  const wait = cost < 40 ? 0 : Math.max(0, cost * 1.5 - (performance.now() - (SHELL.rebuildAt || 0)));

  if (wait <= 0) {
    shellRebuild();
    return;
  }

  SHELL.rebuildTimer = setTimeout(function () {
    SHELL.rebuildTimer = null;
    shellRebuild();
  }, wait);
}

function shellLocalApply() {
  if (!SHELL.built || !SHELL.doc || !SHELL.open) return;

  SHELL.paintPreviewShown = false;

  if (SHELL.paintPreviewKey && SHELL.paintPreviewPatch) {
    const patch = SHELL.paintPreviewPatch;

    SHELL.paintPreviewKey = "";
    setTimeout(function () { if (SHELL.tool === "paint") SHELL_UI.paintPreview(patch); }, 0);
  }

  const b = SHELL.built;

  toolAction("local", { pieces: b.pieces, doors: b.doors, lamps: b.lamps, ladders: b.ladders, elevators: b.elevators, slots: b.slots, bounds: b.bounds, zones: b.zones, levels: b.levels, voids: b.voids, colours: SHELL.doc.colours || {}, customs: SHELL.doc.customs || {}, props: SHELL.doc.props || [], points: SHELL.doc.points, settings: SHELL.doc.settings });
}

const SHELL_WALL_SUBS = { arts: "wall", clocks: "wall", hangers: "wall", walllights: "light", hoods: "hood" };
const SHELL_BACK_SUBS = { beds: 1, wardrobes: 1, drawers: 1, sofas: 1, tvstands: 1, shelves: 1, fireplaces: 1, curtains: 1, kitchenunits: 1, refrigerators: 1, sinks: 1, toilets: 1, bathtubs: 1, showerbooths: 1, desks: 1, barcounters: 1, kitchenappliances: 1, safes: 1, laundry: 1, sidetables: 1, audio: 1, fitness: 0 };
const SHELL_WALL_MOUNT = { wall: 1.55, tv: 1.3, light: 1.95, hood: 1.95 };

function shellPlaceKind(model) {
  const list = (STATE.lists && STATE.lists.furniture) || [];

  if (!SHELL.placeKinds || SHELL.placeKindsCount !== list.length) {
    SHELL.placeKinds = new Map();
    list.forEach(function (item) { SHELL.placeKinds.set(String(item.m).toLowerCase(), item.s); });
    SHELL.placeKindsCount = list.length;
  }

  const name = String(model || "").toLowerCase();
  const sub = SHELL.placeKinds.get(name);

  if (sub === "tvs" || /tv_flat|flatscreen|_screen|cinema_tv|tv_studio|tv_wall/.test(name)) return /stand|_tv_0\d|tv_0\d|trailer_tv|cs_tv/.test(name) && !/flat/.test(name) ? "back" : "tv";
  if (SHELL_WALL_SUBS[sub]) return SHELL_WALL_SUBS[sub];
  if (/painting|_art_|frame|poster|_clock|mirror|wall_light|walllight|sconce/.test(name)) return "wall";
  if (SHELL_BACK_SUBS[sub]) return "back";

  return "free";
}

function shellCommit(patch, options) {
  const o = options || {};

  if (!SHELL.doc || !patch) return;

  const inverse = SG.inverse(SHELL.doc, patch);

  SG.apply(SHELL.doc, patch);

  const last = SHELL.undo[SHELL.undo.length - 1];
  const merging = !o.history && o.merge && last && last.merge === o.merge && Date.now() - (last.at || 0) < 6000;

  if (merging) {
    last.patch = SG.clone(patch);
    last.at = Date.now();
    SHELL.redo = [];
  } else if (!o.history) {
    SHELL.undo.push({ patch: SG.clone(patch), inverse: inverse, merge: o.merge || null, at: Date.now() });

    if (SHELL.undo.length > 120) SHELL.undo.shift();

    SHELL.redo = [];
  }

  const tokenId = "p" + SHELL.nextToken++;

  SHELL.commits = (SHELL.commits || 0) + 1;
  SHELL.pending.push({ token: tokenId, patch: SG.clone(patch) });
  shellRebuild();
  shellLocalApply();
  if (!o.history && !merging && !o.quiet) SHELL_SFX.play(o.sound || shellSfxFor(patch));
  toolAction("patch", { patch: patch, rev: SHELL.doc.rev, token: tokenId, index: o.index === true });
  SHELL_UI.refresh();
}

function shellUndo() {
  const step = SHELL.undo.pop();

  if (!step) return;

  SHELL.redo.push(step);
  shellCommit(step.inverse, { history: true });
  SHELL_SFX.play("undo");
}

function shellRedo() {
  const step = SHELL.redo.pop();

  if (!step) return;

  SHELL.undo.push(step);
  shellCommit(step.patch, { history: true });
  SHELL_SFX.play("redo");
}

function shellServerDoc(doc, built, summary) {
  SHELL.doc = doc;
  SHELL.summary = summary || SHELL.summary;
  const docRev = Number(doc && doc.rev) || 0;

  SHELL.pending = SHELL.pending.filter(function (p) { return !(p.acked && docRev >= p.acked); });
  SHELL.pending.forEach(function (p) { SG.apply(SHELL.doc, p.patch); });
  shellRebuild();
  shellLocalApply();
  SHELL_UI.refresh();
}

function shellLevel() {
  return SG.levelOf(SHELL.doc, SHELL.level);
}

function shellLevels() {
  return (SHELL.doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
}

const SHELL_MOULD_MATS = ["", "white", "darkwood", "oak", "steel"];

function shellRoomsOnLevel(levelId) {
  if (!SHELL.built) return [];

  const id = levelId || SHELL.level;

  return SHELL.built.derived.rooms.filter(function (r) { return r.level === id; });
}

function shellRoomAt(p, list) {
  let best = null;
  let bestArea = Infinity;

  (list || shellRoomsOnLevel()).forEach(function (r) {
    if (!SG.insidePolygon(p, r.points)) return;

    let area = 0;

    for (let i = 0; i < r.points.length; i++) {
      const a = r.points[i];
      const b = r.points[(i + 1) % r.points.length];

      area += a[0] * b[1] - b[0] * a[1];
    }

    area = Math.abs(area) / 2;

    if (area < bestArea) { bestArea = area; best = r; }
  });

  return best;
}

function shellFind(kind, id) {
  const list = SHELL.doc && SHELL.doc[kind];

  return list ? list.find(function (x) { return x.id === id; }) : null;
}

const SHELL_UI = {
  root: null,
  start: function (args) {
    const ui = SHELL_UI;

    $("#shellplan").removeClass("hidden").empty();
    ui.root = $("#shellplan");
    SHELL.open = false;
    $("body").removeClass("sh-editing");
    SHELL.doc = null;
    SHELL.undo = [];
    SHELL.redo = [];
    SHELL.pending = [];
    SHELL.sel = null;
    SHELL.tool = "select";
    shellKit().then(function () {
      if (args && args.id) {
        ui.loading();
        toolAction("open", { id: args.id });
      } else {
        ui.library();
      }
    });
  },
  stop: function () {
    SHELL.open = false;
    $("body").removeClass("sh-editing");
    SHELL.doc = null;
    $("#shellplan").addClass("hidden").empty();
    $(document).off(".shell");
    $(window).off(".shell");
  },
  loading: function () {
    SHELL_UI.root.empty().append(el("div", "sh-loading").append(el("div", "sh-spinner"), el("div", "", T("sh_loading"))));
  },
  library: function () {
    const ui = SHELL_UI;
    const root = ui.root.empty().removeClass("editing");
    const wrap = el("div", "sh-library");
    const grid = el("div", "sh-cards");
    const head = el("div", "sh-lib-head").append(
      $("<div></div>").append(el("div", "tk-kicker accent", T("sh_kicker")), el("div", "sh-lib-title", T("sh_library_title")), el("div", "tk-hint", T("sh_library_text"))),
      el("div", "tk-row").append(
        button(T("sh_new"), "fa-plus", "primary", function () { ui.newDialog(); }),
        iconButton("fa-xmark", function () { post("toolStop"); }, T("close"))
      )
    );

    wrap.append(head, grid);
    root.append(wrap);
    grid.append(el("div", "sh-empty", T("sh_loading")));

    shellRequest("list").then(function (reply) {
      SHELL.library = (reply && reply.list) || [];
      grid.empty();

      if (!SHELL.library.length) {
        grid.append(el("div", "sh-empty").append(icon("fa-house-chimney"), el("div", "", T("sh_library_empty")), button(T("sh_new"), "fa-plus", "primary small", function () { ui.newDialog(); })));
        return;
      }

      SHELL.library.forEach(function (item) { grid.append(ui.card(item)); });
      grid.append(el("button", "sh-card sh-card-new").append(el("span", "sh-card-new-icon").append(icon("fa-plus")), el("span", "sh-card-new-title", T("sh_new")), el("span", "sh-card-new-text", T("sh_new_card_text"))).on("click", function () { ui.newDialog(); }));
    });
  },
  card: function (item) {
    const ui = SHELL_UI;
    const card = el("div", "sh-card");
    const stats = item.stats || {};
    const art = el("canvas", "sh-card-art");

    art.attr({ width: 280, height: 150 });
    card.append(
      art,
      el("div", "sh-card-body").append(
        el("div", "sh-card-name", item.name),
        el("div", "sh-card-meta").append(
          $("<span></span>").append(icon("fa-door-closed"), " " + (stats.rooms || 0)),
          $("<span></span>").append(icon("fa-ruler-combined"), " " + fmt(stats.area || 0, 0) + " m²"),
          $("<span></span>").append(icon("fa-couch"), " " + (stats.props || 0)),
          $("<span></span>").text(timeAgo(item.updated))
        ),
        item.permanent ? el("div", "tk-badge good sh-card-state", T("sh_permanent_badge", item.permanent.resource)) : el("div", "tk-badge sh-card-state idle", T("sh_not_built")),
        el("div", "sh-card-actions").append(
          button(T("sh_open"), "fa-pen-ruler", "primary small", function () { ui.loading(); toolAction("open", { id: item.id }); }),
          iconButton("fa-clone", function () { shellRequest("duplicate", { id: item.id, name: item.name }).then(function () { ui.library(); }); }, T("duplicate")),
          iconButton("fa-share-nodes", function () { ui.shareCode(item); }, T("sh_share")),
          STATE.setup && STATE.setup.community === false ? null : iconButton("fa-globe", function () { ui.publishDialog(item); }, T("sh_publish")),
          iconButton("fa-i-cursor", function () { askText(T("sh_rename"), item.name, function (name) { if (name) shellRequest("rename", { id: item.id, name: name }).then(function () { ui.library(); }); }); }, T("rename")),
          iconButton("fa-trash", function () { confirmBox(T("sh_delete_title"), T("sh_delete_text", item.name), function () { shellRequest("delete", { id: item.id }).then(function (reply) { if (reply && reply.ok === false && reply.message) showNotify({ title: T("notify_title"), text: reply.message, type: "error" }); ui.library(); }); }, true); }, T("delete"))
        )
      )
    );
    ui.cardArt(art[0], item);

    return card;
  },
  cardArt: function (canvas, item) {
    const ctx = canvas.getContext("2d");
    const b = item.bounds;

    if (item.picture) {
      const img = new Image();

      img.onload = function () {
        const k = Math.max(canvas.width / img.width, canvas.height / img.height);
        const w = img.width * k;
        const h = img.height * k;

        ctx.drawImage(img, (canvas.width - w) / 2, (canvas.height - h) / 2, w, h);
      };
      img.src = "data:image/webp;base64," + item.picture;
    }

    ctx.fillStyle = "#16161d";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    for (let x = 0; x < canvas.width; x += 14) {
      ctx.strokeStyle = "rgba(255,255,255,.04)";
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, canvas.height);
      ctx.stroke();
    }

    if (!b) return;

    const w = Math.max(1, b.max[0] - b.min[0]);
    const h = Math.max(1, b.max[1] - b.min[1]);
    const s = Math.min((canvas.width - 40) / w, (canvas.height - 30) / h);
    const ox = (canvas.width - w * s) / 2;
    const oy = (canvas.height - h * s) / 2;
    const map = function (p) { return [ox + (p[0] - b.min[0]) * s, oy + (b.max[1] - p[1]) * s]; };

    ctx.fillStyle = "rgba(255,102,255,.06)";
    ctx.fillRect(ox, oy, w * s, h * s);

    if (Array.isArray(item.thumb) && item.thumb.length) {
      ctx.strokeStyle = "rgba(255,102,255,.9)";
      ctx.lineWidth = 3;
      ctx.lineCap = "square";
      item.thumb.forEach(function (seg) {
        const a = map([seg[0], seg[1]]);
        const c = map([seg[2], seg[3]]);

        ctx.beginPath();
        ctx.moveTo(a[0], a[1]);
        ctx.lineTo(c[0], c[1]);
        ctx.stroke();
      });
    } else {
      ctx.strokeStyle = "rgba(255,102,255,.85)";
      ctx.lineWidth = 3;
      ctx.strokeRect(ox, oy, w * s, h * s);
    }
  },
  shareCode: function (item) {
    shellRequest("sharecode", { id: item.id }).then(function (reply) {
      if (!reply || !reply.code) {
        showNotify({ title: T("notify_title"), text: T("sh_share_failed"), type: "error" });
        return;
      }

      const code = "RTXS1:" + reply.code;
      const box = $("<textarea class='tk-input sh-code' rows='6' readonly spellcheck='false'></textarea>").val(code);
      const copy = function () {
        box.trigger("focus").trigger("select");

        try {
          document.execCommand("copy");
          showNotify({ title: T("notify_title"), text: T("sh_share_copied"), type: "success" });
        } catch (error) {
          return null;
        }

        return null;
      };

      const actions = [{ label: T("close") }];

      if (!(STATE.setup && STATE.setup.community === false)) actions.push({ label: T("sh_publish"), icon: "fa-globe", run: function () { setTimeout(function () { ui.publishDialog(item); }, 0); } });
      actions.push({ label: T("sh_share_copy"), kind: "primary", icon: "fa-copy", run: function () { copy(); return false; } });
      modal({ kicker: T("sh_kicker"), title: T("sh_share_title", item.name), body: [el("div", "tk-hint", T("sh_share_text")), box], actions: actions });
      setTimeout(copy, 50);
    });
  },
  publishDialog: function (item) {
    const ui = SHELL_UI;
    const me = (STATE.home && STATE.home.name) || (STATE.menu && STATE.menu.name) || "";
    const name = input(item.name, T("name"), null, { small: false });
    const author = input(me, T("sh_publish_author_hint"), null);
    const text = $('<textarea class="tk-input sh-publish-text" rows="3" maxlength="240" spellcheck="false"></textarea>').attr("placeholder", T("sh_publish_text_hint"));
    const art = el("canvas", "sh-publish-art").attr({ width: 640, height: 400 });

    ui.cardArt(art[0], item);
    name.attr("maxlength", 60);
    author.attr("maxlength", 40);
    modal({
      kicker: T("sh_kicker"),
      title: T("sh_publish_title"),
      body: [
        el("div", "sh-publish").append(
          art,
          el("div", "tk-stack tight").append(
            field(T("sh_publish_name"), name),
            field(T("sh_publish_author"), author),
            field(T("sh_publish_text"), text),
            el("div", "sh-publish-note").append(icon("fa-circle-info"), $("<span></span>").text(T("sh_publish_note")))
          )
        )
      ],
      wide: true,
      actions: [
        { label: T("cancel") },
        {
          label: T("sh_publish_send"), kind: "primary", icon: "fa-paper-plane",
          run: function () {
            const nameText = String(name.val() || "").trim();
            const authorText = String(author.val() || "").trim();
            let thumb = null;

            if (!nameText || !authorText) {
              showNotify({ title: T("notify_title"), text: T("sh_publish_missing"), type: "error" });
              return false;
            }

            try {
              thumb = art[0].toDataURL("image/webp", 0.82);
            } catch (error) {
              thumb = null;
            }

            showNotify({ title: T("notify_title"), text: T("sh_publish_sending"), type: "info", timeout: 2000 });
            shellRequest("publish", { id: item.id, name: nameText, author: authorText, text: String(text.val() || "").trim(), thumb: thumb }).then(function (reply) {
              if (reply && reply.ok) {
                showNotify({ title: T("notify_title"), text: T("sh_publish_done"), type: "success", timeout: 6000 });
                return;
              }

              const why = reply && reply.error ? String(reply.error) : "network";

              showNotify({ title: T("notify_title"), text: T("sh_publish_error_" + (["duplicate", "rate", "off", "code"].indexOf(why) >= 0 ? why : "network")), type: "error", timeout: 6000 });
            });
            return undefined;
          }
        }
      ]
    });
  },
  newDialog: function () {
    const ui = SHELL_UI;
    const name = input(T("sh_new_name_default"), T("name"));
    let start = "layout";
    const choice = { type: "house", floors: 1, size: "m", bedrooms: 1, baths: 1, kitchen: "open", scheme: "warm", furnish: false };
    const layoutBox = el("div", "tk-stack tight");
    const copyBox = el("div", "tk-stack tight hidden");
    const codeBox = el("div", "tk-stack tight hidden");
    const templateBox = el("div", "tk-stack tight hidden");
    const templateList = el("div", "tk-list sh-template-list");
    let templateId = "";
    const drawTemplates = function (list) {
      templateList.empty();

      if (!list.length) {
        templateList.append(el("div", "tk-empty", T("sh_template_none")));
        return;
      }

      list.forEach(function (t) {
        const row = el("div", "tk-item" + (templateId === t.id ? " active" : "")).append(icon("fa-bookmark"), $("<span></span>").text(t.name), el("span", "tk-item-sub", T("sh_template_meta", t.floors || 1, t.rooms || 0)));
        const del = iconButton("fa-trash", function (event) {
          event.stopPropagation();
          shellRequest("deletetemplate", { template: t.id }).then(function (reply) { if (templateId === t.id) templateId = ""; drawTemplates((reply && reply.list) || []); });
        }, T("delete"), "small");

        row.append(el("div", "tk-item-end").append(del));
        row.on("click", function () { templateId = t.id; templateList.children().removeClass("active"); row.addClass("active"); });
        templateList.append(row);
      });
    };

    templateBox.append(field(T("sh_start_template"), templateList), el("div", "tk-hint", T("sh_template_hint")));
    shellRequest("templates", {}).then(function (reply) { drawTemplates((reply && reply.list) || []); });
    const codeInput = $("<textarea class='tk-input sh-code' rows='4' spellcheck='false'></textarea>").attr("placeholder", T("sh_import_paste"));
    const copySelect = select([{ value: "", label: T("sh_new_copy_none") }].concat(SHELL.library.map(function (x) { return { value: x.id, label: x.name }; })), "");
    const schemes = el("div", "sh-schemes");

    Object.keys(SG.SCHEMES).forEach(function (id) {
      const s = SG.SCHEMES[id];
      const chip = el("button", "sh-scheme" + (id === choice.scheme ? " active" : "")).append(
        el("div", "sh-scheme-swatches").append(shellSwatch(s.walls), shellSwatch(s.floors._), shellSwatch(s.bathwalls)),
        el("span", "", T("scheme_" + id) !== "scheme_" + id ? T("scheme_" + id) : s.name)
      );

      chip.on("click", function () {
        choice.scheme = id;
        schemes.children().removeClass("active");
        chip.addClass("active");
      });
      schemes.append(chip);
    });

    const types = el("div", "sh-layout-types");
    const floorsField = field(T("sh_new_floors"), segment(["1", "2", "3", "4"].map(function (v) { return { value: v, label: v }; }), "1", function (v) { choice.floors = Number(v); }, true));
    const roomsField = el("div", "tk-grid2").append(
      field(T("sh_new_bedrooms"), segment(["0", "1", "2", "3", "4"].map(function (v) { return { value: v, label: v }; }), "1", function (v) { choice.bedrooms = Number(v); }, true)),
      field(T("sh_new_baths"), segment(["1", "2"].map(function (v) { return { value: v, label: v }; }), "1", function (v) { choice.baths = Number(v); }, true))
    );
    const kitchenField = field(T("sh_new_kitchen"), segment([{ value: "open", label: T("sh_kitchen_open") }, { value: "closed", label: T("sh_kitchen_closed") }], "open", function (v) { choice.kitchen = v; }, true));
    const sizeHint = el("div", "tk-hint");
    const showFor = function () {
      const t = choice.type;

      floorsField.toggleClass("hidden", t !== "house" && t !== "office");
      roomsField.toggleClass("hidden", t !== "house" && t !== "apartment");
      roomsField.find(".tk-segment").last().closest(".tk-field").toggleClass("hidden", t !== "house");
      kitchenField.toggleClass("hidden", t !== "house");
      sizeHint.text(T("sh_layout_" + t + "_hint"));
    };

    [["house", "fa-house"], ["apartment", "fa-building"], ["studio", "fa-bed"], ["garage", "fa-warehouse"], ["mechanic", "fa-screwdriver-wrench"], ["office", "fa-briefcase"], ["shop", "fa-store"], ["warehouse", "fa-boxes-stacked"]].forEach(function (pair) {
      const card = el("button", "sh-layout-type" + (choice.type === pair[0] ? " active" : "")).append(icon(pair[1]), el("span", "", T("sh_layout_" + pair[0])));

      card.on("click", function () {
        choice.type = pair[0];
        types.children().removeClass("active");
        card.addClass("active");
        showFor();
      });
      types.append(card);
    });

    layoutBox.append(
      field(T("sh_new_type"), types),
      sizeHint,
      el("div", "tk-grid2").append(
        field(T("sh_new_size"), segment([{ value: "s", label: T("sh_size_s") }, { value: "m", label: T("sh_size_m") }, { value: "l", label: T("sh_size_l") }], "m", function (v) { choice.size = v; }, true)),
        floorsField
      ),
      roomsField,
      kitchenField,
      field(T("sh_new_scheme"), schemes)
    );
    showFor();
    copyBox.append(field(T("sh_new_copy"), copySelect));
    codeBox.append(field(T("sh_import_code"), codeInput), el("div", "tk-hint", T("sh_import_hint")));

    modal({
      kicker: T("sh_kicker"),
      title: T("sh_new_title"),
      wide: true,
      body: [
        field(T("name"), name),
        field(T("sh_new_start"), segment([{ value: "layout", label: T("sh_start_layout"), icon: "fa-table-cells-large" }, { value: "empty", label: T("sh_start_empty"), icon: "fa-square" }, { value: "template", label: T("sh_start_template"), icon: "fa-bookmark" }, { value: "copy", label: T("sh_start_copy"), icon: "fa-clone" }, { value: "code", label: T("sh_start_code"), icon: "fa-file-import" }], "layout", function (v) {
          start = v;
          templateBox.toggleClass("hidden", v !== "template");
          layoutBox.toggleClass("hidden", v !== "layout");
          copyBox.toggleClass("hidden", v !== "copy");
          codeBox.toggleClass("hidden", v !== "code");
        }, true).css("grid-template-columns", "repeat(5, minmax(0, 1fr))").addClass("sh-start-seg")),
        layoutBox,
        templateBox,
        copyBox,
        codeBox,
        el("div", "tk-hint", T("sh_new_hint"))
      ],
      actions: [{ label: T("cancel") }, {
        label: T("sh_new_create"), kind: "primary", icon: "fa-check", run: function () {
          const payload = { name: String(name.val() || "").trim() || T("sh_new_name_default") };

          if (start === "layout") payload.choice = { layout: choice };
          SHELL.furnishAfterOpen = start === "layout" && choice.furnish === true;
          if (start === "copy" && copySelect.val()) payload.choice = { copy: copySelect.val() };
          if (start === "template") {
            if (!templateId) {
              showNotify({ title: T("notify_title"), text: T("sh_template_pick"), type: "warning" });
              return false;
            }

            payload.choice = { template: templateId };
          }
          if (start === "code") {
            const code = String(codeInput.val() || "").replace(/\s+/g, "");

            if (!/^RTXS1:[A-Za-z0-9+\/=]{20,}$/.test(code)) {
              showNotify({ title: T("notify_title"), text: T("sh_import_bad"), type: "error" });
              return false;
            }

            payload.choice = { code: code.slice(6) };
          }

          ui.loading();
          shellRequest("create", payload).then(function (reply) {
            if (reply && reply.ok && reply.shell) toolAction("open", { id: reply.shell.id });
            else {
              if (reply && reply.message) showNotify({ title: T("notify_title"), text: reply.message, type: "error" });
              else if (start === "code") showNotify({ title: T("notify_title"), text: T("sh_import_bad"), type: "error" });
              ui.library();
            }
          });
        }
      }]
    });
  },
  refresh: function () {
    if (!SHELL.open) return;

    SHELL.dirty = true;
    SHELL_UI.drawTop();
    SHELL_UI.drawSide();
  }
};

Object.assign(SHELL_UI, {
  enter: function (data) {
    const ui = SHELL_UI;

    SHELL.doc = data.doc;
    SHELL.summary = data.summary;
    SHELL.editors = data.editors || [];
    SHELL.me = data.me;
    SHELL.open = true;
    SHELL_SFX.play("open");
    SHELL.level = (shellLevels()[0] || { id: "l1" }).id;
    SHELL.thick = Number(SHELL.doc.settings && SHELL.doc.settings.thick) || 0.2;
    shellRebuild();

    const root = ui.root.empty().addClass("editing");

    $("body").addClass("sh-editing");

    ui.top = el("div", "sh-top");
    ui.tools = el("div", "sh-tools");
    ui.stage = el("div", "sh-stage");
    ui.canvas = $('<canvas class="sh-canvas"></canvas>');
    ui.status = el("div", "sh-status");
    ui.side = el("div", "sh-side");
    ui.walkBar = el("div", "sh-walkbar hidden").append(icon("fa-person-walking"), $("<span></span>").text(T("sh_walk_hint")), el("span", "tk-key", "BACKSPACE"));
    ui.stage.append(ui.canvas, ui.status);
    root.append(ui.top, ui.tools, ui.stage, ui.side, ui.walkBar);
    ui.ctx = ui.canvas[0].getContext("2d");
    ui.drawTools();
    ui.setMode(SHELL.mode);
    ui.fit();
    ui.bind();
    ui.refresh();
    ui.loop();

    const models = Array.from(new Set((SHELL.doc.props || []).map(function (prop) { return prop.model; })));

    if (models.length) toolAction("dims", { models: models.slice(0, 400) });

    SHELL.pictureRev = null;
    clearInterval(SHELL.pictureTimer);
    SHELL.pictureTimer = setInterval(function () { if (SHELL.open && !SHELL.walking && !SHELL.drag) ui.pictureNow(); }, 180000);
    if (!data.summary || !data.summary.pic) setTimeout(function () { ui.pictureNow(); }, 6000);

    if (SHELL.furnishAfterOpen) {
      SHELL.furnishAfterOpen = false;
      SHELL.furnishQueue = (SHELL.built.derived.rooms || []).map(function (r) { return r.id; });
      setTimeout(function () { ui.furnishNext(); }, 1200);
    }
    setTimeout(function () { if (typeof SHELL_GUIDE !== "undefined") SHELL_GUIDE.offer(); }, 600);
  },
  setMode: function (mode) {
    const changed = SHELL.mode !== mode;

    SHELL.mode = mode;
    SHELL_UI.root.attr("data-mode", mode);
    SHELL_UI.resize();

    if (changed && SHELL_UI.top && SHELL_UI.top.children().length) SHELL_UI.drawTop();

    if (mode === "3d" || mode === "split") toolAction("view", { view: mode === "3d" ? "iso" : "top" });
    if (changed && SHELL_UI.top) SHELL_UI.hints();

    SHELL.dirty = true;
  },
  resize: function () {
    const ui = SHELL_UI;

    if (!ui.canvas) return;

    const box = ui.stage[0].getBoundingClientRect();

    ui.canvas[0].width = Math.max(10, Math.round(box.width));
    ui.canvas[0].height = Math.max(10, Math.round(box.height));
    SHELL.dirty = true;
  },
  fit: function () {
    const ui = SHELL_UI;
    const b = SHELL.built && SHELL.built.bounds;

    ui.resize();

    if (!b) return;

    const w = ui.canvas[0].width;
    const h = ui.canvas[0].height;

    SHELL.view.x = (b.min[0] + b.max[0]) / 2;
    SHELL.view.y = (b.min[1] + b.max[1]) / 2;
    SHELL.view.scale = Math.max(8, Math.min(160, Math.min((w - 120) / Math.max(4, b.max[0] - b.min[0]), (h - 120) / Math.max(4, b.max[1] - b.min[1]))));
    SHELL.dirty = true;
  },
  toScreen: function (p) {
    const c = SHELL_UI.canvas[0];

    return [c.width / 2 + (p[0] - SHELL.view.x) * SHELL.view.scale, c.height / 2 - (p[1] - SHELL.view.y) * SHELL.view.scale];
  },
  toWorld: function (x, y) {
    const c = SHELL_UI.canvas[0];

    return [SHELL.view.x + (x - c.width / 2) / SHELL.view.scale, SHELL.view.y - (y - c.height / 2) / SHELL.view.scale];
  },
  drawTop: function () {
    const ui = SHELL_UI;
    const doc = SHELL.doc;
    const nameBox = input(doc.name, T("name"), function (value) { shellCommit({ root: { name: String(value).slice(0, 60) } }, { index: true }); }, { small: true });
    const levels = el("div", "sh-levels");
    const bad = SHELL.checks.filter(function (c) { return c.level === "bad"; }).length;
    const warn = SHELL.checks.filter(function (c) { return c.level === "warn"; }).length;

    const allLevels = shellLevels();
    const pickLevel = function (id) {
      SHELL.level = id;
      SHELL.sel = null;
      ui.refresh();
    };

    if (allLevels.length > 3) {
      const at = Math.max(0, allLevels.findIndex(function (l) { return l.id === SHELL.level; }));
      const current = allLevels[at] || allLevels[0];

      levels.addClass("compact").append(
        iconButton("fa-chevron-down", function () { if (at > 0) pickLevel(allLevels[at - 1].id); }, T("sh_level_below"), "small" + (at > 0 ? "" : " disabled")),
        select(allLevels.map(function (l, i) { return { value: l.id, label: l.name || T("sh_level_n", i + 1) }; }), current.id, function (v) { pickLevel(v); }).addClass("sh-level-select").on("dblclick", function () { ui.levelSettings(current); }),
        iconButton("fa-chevron-up", function () { if (at < allLevels.length - 1) pickLevel(allLevels[at + 1].id); }, T("sh_level_above"), "small" + (at < allLevels.length - 1 ? "" : " disabled")),
        iconButton("fa-sliders", function () { ui.levelSettings(current); }, T("sh_level_settings"), "small")
      );
    }

    (allLevels.length > 3 ? [] : allLevels).forEach(function (level, index) {
      const tab = el("button", "sh-level" + (level.id === SHELL.level ? " active" : ""), level.name || T("sh_level_n", index + 1));

      tab.on("click", function () {
        SHELL.level = level.id;
        SHELL.sel = null;
        ui.refresh();
      });
      tab.on("dblclick", function () { ui.levelSettings(level); });
      tab.on("contextmenu", function (event) { event.preventDefault(); ui.levelSettings(level); });
      levels.append(tab);
    });
    levels.append(iconButton("fa-plus", function () { ui.addLevel(); }, T("sh_level_add"), "small"));

    ui.top.empty().append(
      el("div", "sh-top-left").append(
        iconButton("fa-chevron-left", function () { SHELL_UI.pictureNow(); post("toolStop"); }, T("sh_back")),
        el("div", "sh-title").append(el("div", "tk-kicker accent", T("sh_kicker")), nameBox)
      ),
      segment([{ value: "plan", label: T("sh_mode_plan"), icon: "fa-map" }, { value: "split", label: T("sh_mode_split"), icon: "fa-table-columns" }, { value: "3d", label: T("sh_mode_3d"), icon: "fa-cube" }], SHELL.mode, function (value) { ui.setMode(value); }).addClass("sh-modes"),
      levels,
      el("div", "sh-top-right").append(
        iconButton("fa-rotate-left", shellUndo, T("undo") + " (Ctrl+Z)", SHELL.undo.length ? "" : "dim"),
        iconButton("fa-rotate-right", shellRedo, T("redo") + " (Ctrl+Y)", SHELL.redo.length ? "" : "dim"),
        shellPartsChip(SHELL.parts),
        el("button", "sh-checks-btn" + (bad ? " bad" : warn ? " warn" : " good")).append(icon(bad ? "fa-circle-exclamation" : warn ? "fa-triangle-exclamation" : "fa-circle-check"), $("<span></span>").text(bad + warn ? T("sh_checks_count", bad + warn) : T("sh_checks_ok"))).on("click", function () { SHELL.panel = "checks"; if (SHELL.sel) ui.select(null); ui.drawSide(); }),
        SHELL.mode !== "plan" ? segment([{ value: "all", label: "", icon: "fa-layer-group" }, { value: "above", label: "", icon: "fa-house" }, { value: "ceiling", label: "", icon: "fa-house-chimney-crack" }, { value: "solo", label: "", icon: "fa-vector-square" }], SHELL_UI.cutMode(), function (v) { SHELL.cut = v; ui.drawTop(); }).addClass("sh-cut").attr("title", T("sh_cut_hint")) : null,
        SHELL.mode !== "plan" ? el("div", "sh-box-group").append(
          el("button", "tk-btn small sh-box-btn" + (SHELL.box ? " primary-soft" : "")).attr("title", T("sh_box_hint")).append(icon("fa-cube"), $("<span></span>").text(SHELL.box ? T("sh_box_" + SHELL.box) : T("sh_box_short"))).on("click", function () { SHELL.box = SHELL.box ? false : (SHELL.boxColour || "white"); ui.drawTop(); }),
          SHELL.box ? el("button", "tk-btn small sh-box-colour").attr("title", T("sh_box_colour")).append(el("span", "sh-box-dot sh-box-" + SHELL.box)).on("click", function () { const order = ["white", "grey", "black"]; SHELL.box = order[(order.indexOf(SHELL.box === true ? "black" : SHELL.box) + 1) % order.length]; SHELL.boxColour = SHELL.box; ui.drawTop(); }) : null
        ) : null,
        el("button", "tk-btn small" + (SHELL.grid !== false ? " primary-soft" : "")).attr("title", T("sh_grid_toggle") + " (G)").append(icon("fa-border-all"), $("<span></span>").text(T("sh_grid_short"))).on("click", function () { ui.toggleGrid(); }),
        STATE.setup && STATE.setup.shellsounds === false ? null : el("button", "tk-btn small" + (SHELL_SFX.on() ? " primary-soft" : "")).attr("title", T("sh_sounds_hint")).append(icon(SHELL_SFX.on() ? "fa-volume-high" : "fa-volume-xmark")).on("click", function () { SHELL_SFX.setOn(!SHELL_SFX.on()); SHELL_SFX.play("tick"); ui.drawTop(); }),
        button(T("sh_walk"), "fa-person-walking", "small sh-walk-btn", function () { ui.walk(true); }).attr("title", T("sh_walk")),
        iconButton("fa-circle-question", function () { SHELL_GUIDE.menu(); }, T("sh_gd_title"), "sh-help-btn"),
        button(T("sh_finish"), "fa-flag-checkered", "primary small sh-finish-btn", function () { ui.finishDialog(); })
      )
    );
  },
  drawTools: function () {
    const ui = SHELL_UI;

    ui.tools.empty();
    SHELL_TOOLS.forEach(function (tool) {
      const btn = el("button", "sh-tool" + (SHELL.tool === tool.id ? " active" : "")).attr("data-tool", tool.id).append(icon(tool.icon), el("span", "sh-tool-key", tool.key));

      btn.attr("title", T("sh_tool_" + tool.id));
      btn.on("click", function () { ui.setTool(tool.id); });
      ui.tools.append(btn);
    });
    ui.tools.append(el("div", "sh-tools-gap"), iconButton("fa-expand", function () { ui.fit(); }, T("sh_fit"), "small"));
  },
  setTool: function (id) {
    const ui = SHELL_UI;

    if (id !== "paint") ui.paintPreview(null);
    if (id !== SHELL.tool) SHELL_SFX.play("tick");

    if (SHELL.tool === "furniture" && id !== "furniture") {
      SHELL.ghostModel = null;
      toolAction("ghost", {});
    }

    SHELL.ghostAt = null;
    SHELL.highlightKey = "";
    toolAction("highlight", { polys: [] });

    SHELL.tool = id;
    SHELL.draft = null;
    SHELL.wallPress = null;
    SHELL.previewKey = "";
    toolAction("tool", { id: id });

    if (id !== "select" && SHELL.sel && !(id === "furniture" && SHELL.sel.kind === "prop")) {
      SHELL.sel = null;
      toolAction("selectprop", {});
    }
    SHELL.measure = null;
    toolAction("pick", {});

    if (id === "furniture" && SHELL.mode === "plan") ui.setMode("split");

    ui.drawTools();
    ui.drawSide();
    ui.hints();
    SHELL.dirty = true;
  },
  hints: function () {
    const list = {
      select: [{ keys: ["LMB"], text: T("sh_hint_select") }, { keys: ["DEL"], text: T("sh_hint_delete") }, { keys: ["ESC"], text: T("sh_hint_clear") }],
      walls: [{ keys: ["LMB"], text: T("sh_hint_walls_drag") }, { keys: ["ENTER"], text: T("sh_hint_walls_end") }, { keys: ["SHIFT"], text: T("sh_hint_free_angle") }, { keys: ["ESC"], text: T("sh_hint_cancel") }],
      room: [{ keys: ["LMB"], text: T("sh_hint_room") }],
      opening: [{ keys: ["LMB"], text: T("sh_hint_opening") }],
      stairs: [{ keys: ["LMB"], text: T("sh_hint_stairs") }, { keys: ["R"], text: T("sh_hint_rotate") }],
      pool: [{ keys: ["LMB"], text: T("sh_hint_pool") }],
      details: [{ keys: ["LMB"], text: T("sh_hint_details") }, { keys: ["R"], text: T("sh_hint_rotate") }],
      paint: [{ keys: ["LMB"], text: T("sh_hint_paint") }, { keys: ["CTRL", "LMB"], text: T("sh_hint_pick") }],
      light: [{ keys: ["LMB"], text: T("sh_hint_light") }],
      points: [{ keys: ["LMB"], text: T("sh_hint_points") }],
      furniture: SHELL.ghostModel ? [{ keys: ["LMB"], text: T("sh_hint_furniture") }, { keys: ["R"], text: T("sh_hint_turn_90") }, { keys: ["SCROLL"], text: T("sh_hint_turn") }, { keys: ["SHIFT", "LMB"], text: T("sh_hint_more") }] : [{ keys: ["LMB"], text: T("sh_hint_furniture_pick") }, { keys: ["R"], text: T("sh_hint_turn_90") }, { keys: ["DEL"], text: T("sh_hint_delete") }],
      measure: [{ keys: ["LMB"], text: T("sh_hint_measure") }],
      hammer: [{ keys: ["LMB"], text: T("sh_hint_hammer") }, { keys: ["CTRL", "Z"], text: T("sh_hint_undo") }]
    }[SHELL.tool] || [];

    setHints(list.concat(SHELL.mode === "plan" ? [{ keys: ["MMB"], text: T("sh_hint_pan") }, { keys: ["SCROLL"], text: T("sh_hint_zoom") }] : [{ keys: ["↑", "↓", "←", "→"], text: T("sh_hint_cam_move") }, { keys: ["Q", "E"], text: T("sh_hint_cam_turn") }, { keys: ["MMB"], text: T("sh_hint_cam_orbit") }, { keys: ["SCROLL"], text: T("sh_hint_zoom") }, { keys: ["RMB"], text: T("sh_hint_cam_look") }]));
  },
  toggleGrid: function () {
    SHELL.grid = SHELL.grid === false;
    SHELL_UI.drawTop();
  },
  cutMode: function () {
    if (SHELL.cut) return SHELL.cut;

    const budget = Number(SHELL.parts && SHELL.parts.budget) || 3999;
    const count = SHELL.built && SHELL.built.pieces ? SHELL.built.pieces.length : 0;

    return shellLevels().length > 1 && count > budget - 50 ? "solo" : "ceiling";
  },
  addLevel: function () {
    SHELL_UI.levelDialog(null);
  },
  loop: function () {
    if (!SHELL.open) return;

    const gridOn = SHELL.grid !== false && SHELL.mode !== "plan" && !!(SHELL.built && SHELL.built.bounds);
    const gb = SHELL.built && SHELL.built.bounds;
    const tilePaint = SHELL.tool === "paint" && SHELL.paint && SHELL.paint.target === "tiles";
    const gridKey = gridOn ? [shellLevel().z || 0, gb.min[0], gb.min[1], gb.max[0], gb.max[1], Number(SHELL.doc.settings.grid) || 0.25, tilePaint ? SHELL.paint.brush || 2 : 0].join("|") : "off";

    if (SHELL.sentGrid !== gridKey) {
      SHELL.sentGrid = gridKey;

      if (gridOn) {
        const fine = Number(SHELL.doc.settings.grid) || 0.25;
        const step = tilePaint ? 0.25 * (SHELL.paint.brush || 2) : fine < 0.5 ? 0.5 : fine;

        const cx = (gb.min[0] + gb.max[0]) / 2;
        const cy = (gb.min[1] + gb.max[1]) / 2;
        const hx = Math.max(20, (gb.max[0] - gb.min[0]) / 2 + 12);
        const hy = Math.max(20, (gb.max[1] - gb.min[1]) / 2 + 12);

        toolAction("grid", { on: true, step: step, snap: fine, major: 1, z: shellLevel().z || 0, min: [Math.floor(cx - hx), Math.floor(cy - hy)], max: [Math.ceil(cx + hx), Math.ceil(cy + hy)] });
      } else {
        toolAction("grid", { on: false });
      }
    }

    const lv = shellLevel();
    const ceilingPaint = SHELL.tool === "paint" && SHELL.paint && SHELL.paint.target === "ceiling";
    const chosenCut = SHELL_UI.cutMode();
    const cutMode = SHELL.mode === "plan" || SHELL.walking ? "all" : ceilingPaint && chosenCut === "ceiling" ? "above" : ceilingPaint && chosenCut === "solo" ? "soloabove" : chosenCut;
    const upper = shellLevels().filter(function (l) { return (l.z || 0) > (lv.z || 0) + 0.5; }).sort(function (a, b) { return a.z - b.z; })[0];
    const cutTop = upper ? (upper.z || 0) - 0.03 : (lv.z || 0) + (lv.height || 2.8) + 1.5;
    const roofView = SHELL.tool === "roof" && SHELL.mode !== "plan" && !SHELL.walking;
    const cutZ = roofView ? (cutMode === "all" ? null : 999) : cutMode === "all" ? null : cutTop;
    const cutCeil = !roofView && (cutMode === "ceiling" || cutMode === "solo") ? (lv.z || 0) + (lv.height || 2.8) - 0.3 : null;
    const cutLow = cutMode === "solo" || cutMode === "soloabove" ? (lv.z || 0) - 0.25 : null;
    const below = cutLow === null ? null : shellLevels().filter(function (l) { return (l.z || 0) < (lv.z || 0) - 0.5; }).sort(function (a, b) { return b.z - a.z; })[0];
    const cutHoles = cutLow === null || !below || !SHELL.built ? [] : (SHELL.built.derived.holes || []).filter(function (h) { return h.level === lv.id && h.points && h.points.length >= 3; }).map(function (h) {
      const xs = h.points.map(function (q) { return q[0]; });
      const ys = h.points.map(function (q) { return q[1]; });

      return [SG.round(Math.min.apply(null, xs) - 0.35, 2), SG.round(Math.min.apply(null, ys) - 0.35, 2), SG.round(Math.max.apply(null, xs) + 0.35, 2), SG.round(Math.max.apply(null, ys) + 0.35, 2)];
    });
    const holeFloor = below ? SG.round((below.z || 0) - 0.1, 3) : null;
    const focusTop = upper ? (upper.z || 0) : (lv.z || 0) + (lv.height || 2.8);
    const cutKey = (cutZ === null ? "none" : String(SG.round(cutZ, 3)) + ":" + String(cutCeil) + ":" + String(cutLow) + ":" + JSON.stringify(cutHoles)) + "|" + (lv.z || 0);

    if (SHELL.sentCut !== cutKey) {
      SHELL.sentCut = cutKey;
      toolAction("cut", Object.assign(cutZ === null ? {} : { z: SG.round(cutZ, 3), ceil: cutCeil === null ? undefined : SG.round(cutCeil, 3), low: cutLow === null ? undefined : SG.round(cutLow, 3), holes: cutHoles.length ? cutHoles : undefined, holefloor: cutHoles.length ? holeFloor : undefined }, { focus: SG.round(lv.z || 0, 3), focustop: SG.round(focusTop, 3) }));
    }

    const ruler = SHELL.tool === "measure" && SHELL.measure && SHELL.measure.b && SHELL.mode !== "plan" ? SHELL.measure : null;
    const rulerZ = (shellLevel().z || 0) + 0.06;
    const rulerKey = ruler ? [ruler.a[0], ruler.a[1], ruler.b[0], ruler.b[1], rulerZ].map(function (v) { return SG.round(v, 3); }).join("|") : "off";

    if (SHELL.sentRuler !== rulerKey) {
      SHELL.sentRuler = rulerKey;
      toolAction("ruler", ruler ? { a: [SG.round(ruler.a[0], 3), SG.round(ruler.a[1], 3), SG.round(rulerZ, 3)], b: [SG.round(ruler.b[0], 3), SG.round(ruler.b[1], 3), SG.round(rulerZ, 3)], text: fmt(SG.vec.len(SG.vec.sub(ruler.b, ruler.a)), 2) + " m" } : {});
    }

    const boxOn = !!SHELL.box && SHELL.mode !== "plan" && !SHELL.walking && !!gb;
    const boxKey = boxOn ? [SHELL.box, gb.min[0], gb.min[1], gb.max[0], gb.max[1], gb.min[2], gb.max[2]].join("|") : "off";

    if (SHELL.sentBox !== boxKey) {
      SHELL.sentBox = boxKey;

      if (boxOn) {
        const margin = 160;
        const sx = gb.max[0] - gb.min[0] + margin * 2;
        const sy = gb.max[1] - gb.min[1] + margin * 2;
        const z0 = Math.min(gb.min[2], 0) - 0.06;

        toolAction("box", { on: true, colour: SHELL.box === true ? "black" : SHELL.box, x: SG.round((gb.min[0] + gb.max[0]) / 2, 3), y: SG.round((gb.min[1] + gb.max[1]) / 2, 3), z: SG.round(z0, 3), sx: SG.round(sx, 3), sy: SG.round(sy, 3), sz: SG.round(gb.max[2] - z0 + 140, 3), house: [SG.round(gb.min[0], 2), SG.round(gb.min[1], 2), SG.round(gb.min[2], 2), SG.round(gb.max[0], 2), SG.round(gb.max[1], 2), SG.round(gb.max[2], 2)] });
      } else {
        toolAction("box", { on: false });
      }
    }

    if (SHELL.sentLevel !== SHELL.level) {
      SHELL.sentLevel = SHELL.level;
      toolAction("level", { z: shellLevel().z || 0 });
    }

    if (SHELL.dirty) {
      SHELL.dirty = false;

      try {
        SHELL_UI.draw();
      } catch (error) {
        console.log(error && error.stack);
      }
    }

    requestAnimationFrame(SHELL_UI.loop);
  }
});

Object.assign(SHELL_UI, {
  pattern: function (key) {
    const ui = SHELL_UI;
    const custom = /^c[1-6]$/.test(String(key));
    const image = custom ? shellCustomImage(key) : SHELL.images[key];
    const cache = custom ? key + ":" + shellCustomFile(key) : key;

    if (/^s[1-6]$/.test(String(key))) return (SHELL.doc.colours && SHELL.doc.colours[key]) || "#cccccc";
    if (!image || !image.complete || !image.naturalWidth) return "#3a3d46";

    let pattern = SHELL.patterns[cache];

    if (!pattern) {
      pattern = ui.ctx.createPattern(image, "repeat");
      SHELL.patterns[cache] = pattern;
    }

    const material = (SHELL.kit.all || []).find(function (m) { return m.key === key; });
    const repeat = (material && material.repeat) || 2;
    const k = repeat * SHELL.view.scale / image.naturalWidth;
    const origin = ui.toScreen([0, 0]);

    if (pattern.setTransform) pattern.setTransform(new DOMMatrix([k, 0, 0, k, origin[0], origin[1]]));

    return pattern;
  },
  path: function (points) {
    const ctx = SHELL_UI.ctx;

    ctx.beginPath();
    points.forEach(function (p, i) {
      const s = SHELL_UI.toScreen(p);

      if (i === 0) ctx.moveTo(s[0], s[1]);
      else ctx.lineTo(s[0], s[1]);
    });
  },
  draw: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const c = ui.canvas[0];
    const doc = SHELL.doc;
    const built = SHELL.built;
    const level = shellLevel();
    const scale = SHELL.view.scale;

    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, c.width, c.height);
    ctx.fillStyle = "#121218";
    ctx.fillRect(0, 0, c.width, c.height);

    const step = scale > 36 ? 0.25 : scale > 14 ? 1 : 5;
    const tl = ui.toWorld(0, 0);
    const br = ui.toWorld(c.width, c.height);

    for (let x = Math.floor(tl[0] / step) * step; SHELL.grid !== false && x <= br[0]; x += step) {
      const s = ui.toScreen([x, 0]);
      const major = Math.abs(x - Math.round(x)) < 1e-6 && (step < 1 || Math.round(x) % 5 === 0);

      ctx.strokeStyle = major ? "rgba(255,255,255,.07)" : "rgba(255,255,255,.028)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(Math.round(s[0]) + 0.5, 0);
      ctx.lineTo(Math.round(s[0]) + 0.5, c.height);
      ctx.stroke();
    }

    for (let y = Math.floor(br[1] / step) * step; SHELL.grid !== false && y <= tl[1]; y += step) {
      const s = ui.toScreen([0, y]);
      const major = Math.abs(y - Math.round(y)) < 1e-6 && (step < 1 || Math.round(y) % 5 === 0);

      ctx.strokeStyle = major ? "rgba(255,255,255,.07)" : "rgba(255,255,255,.028)";
      ctx.beginPath();
      ctx.moveTo(0, Math.round(s[1]) + 0.5);
      ctx.lineTo(c.width, Math.round(s[1]) + 0.5);
      ctx.stroke();
    }

    const below = shellLevels().filter(function (l) { return l.z < level.z - 0.1; }).pop();

    if (below) {
      ctx.globalAlpha = 0.18;
      ui.drawWalls(below.id, true);
      ctx.globalAlpha = 1;
    }

    shellRoomsOnLevel().forEach(function (room) {
      ui.path(room.points);
      ctx.closePath();
      ctx.fillStyle = ui.pattern(room.record.floor || "oak");
      ctx.globalAlpha = 0.9;
      ctx.fill();
      ctx.globalAlpha = 1;

      Object.keys(room.record.tiles || {}).forEach(function (key) {
        const ij = key.split(",").map(Number);

        ctx.save();
        ui.path(room.points);
        ctx.closePath();
        ctx.clip();
        ui.path(SG.tilePoints(room, ij[0], ij[1]));
        ctx.closePath();
        ctx.fillStyle = ui.pattern(room.record.tiles[key]);
        ctx.fill();
        ctx.restore();
      });
      ui.path(room.points);
      ctx.closePath();

      if (SHELL.sel && SHELL.sel.kind === "room" && SHELL.sel.id === room.id) {
        ctx.fillStyle = "rgba(255,102,255,.12)";
        ctx.fill();
        ctx.strokeStyle = "rgba(255,102,255,.9)";
        ctx.lineWidth = 2;
        ctx.setLineDash([6, 4]);
        ctx.stroke();
        ctx.setLineDash([]);
      } else if (SHELL.hover && SHELL.hover.kind === "room" && SHELL.hover.id === room.id && (SHELL.tool === "paint" || SHELL.tool === "select" || SHELL.tool === "light")) {
        ctx.fillStyle = "rgba(255,255,255,.06)";
        ctx.fill();
      }
    });

    built.derived.holes.filter(function (h) { return h.level === SHELL.level; }).forEach(function (hole) {
      ui.path(hole.points);
      ctx.closePath();
      ctx.fillStyle = hole.pool ? "rgba(63,183,214,.55)" : "#121218";
      ctx.fill();
      ctx.strokeStyle = "rgba(255,255,255,.25)";
      ctx.setLineDash([4, 4]);
      ctx.stroke();
      ctx.setLineDash([]);
    });

    ui.drawWalls(SHELL.level, false);
    ui.drawOpenings();
    ui.drawStairs();
    ui.drawPools();
    ui.drawDetails();
    ui.drawProps();
    ui.drawGhost();
    ui.drawLights();
    ui.drawPoints();
    ui.drawLabels();
    ui.drawSelection();
    ui.drawDraft();
    ui.drawEditors();
  },
  drawWalls: function (levelId, ghost) {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const scale = SHELL.view.scale;
    const walls = (SHELL.doc.walls || []).filter(function (w) { return (w.level || "l1") === levelId; });

    walls.forEach(function (wall) {
      const pts = SG.wallPoints(wall);
      const selected = !ghost && SHELL.sel && SHELL.sel.kind === "wall" && SHELL.sel.id === wall.id;
      const hovered = !ghost && SHELL.hover && SHELL.hover.kind === "wall" && SHELL.hover.id === wall.id;

      ui.path(pts);
      ctx.lineWidth = Math.max(3, (Number(wall.thick) || SHELL.thick) * scale);
      ctx.lineCap = "square";
      ctx.lineJoin = "miter";
      ctx.strokeStyle = selected ? "#ff66ff" : hovered ? "#5b5f6e" : "#2f323c";
      ctx.stroke();
      ctx.lineWidth = 1;
      ctx.strokeStyle = selected ? "rgba(255,255,255,.7)" : "rgba(255,255,255,.18)";
      ctx.lineCap = "butt";

      if (!ghost) {
        const n = SG.vec.left(SG.vec.norm(SG.vec.sub(wall.b, wall.a)));
        const h = (Number(wall.thick) || SHELL.thick) / 2;

        if (Math.abs(Number(wall.bend) || 0) < 0.02) {
          [h, -h].forEach(function (off) {
            ui.path([SG.vec.add(wall.a, SG.vec.mul(n, off)), SG.vec.add(wall.b, SG.vec.mul(n, off))]);
            ctx.stroke();
          });
        }
      }
    });

    if (!ghost) {
      SHELL.built.derived.ends.filter(function (e) { return e.level === levelId; }).forEach(function (end) {
        const s = ui.toScreen(end.p);

        ctx.fillStyle = "#ffb62b";
        ctx.beginPath();
        ctx.arc(s[0], s[1], 4, 0, Math.PI * 2);
        ctx.fill();
      });
    }
  },
  drawOpenings: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const scale = SHELL.view.scale;

    SHELL.built.derived.openings.filter(function (o) { return o.level === SHELL.level; }).forEach(function (o) {
      const half = o.width / 2;
      const a = SG.vec.add(o.c, SG.vec.mul(o.d, -half));
      const b = SG.vec.add(o.c, SG.vec.mul(o.d, half));
      const selected = SHELL.sel && SHELL.sel.kind === "opening" && SHELL.sel.id === o.id;
      const hovered = SHELL.hover && SHELL.hover.kind === "opening" && SHELL.hover.id === o.id;

      const accent = selected ? "#ff66ff" : hovered ? "#ffffff" : "#c9ccd6";

      if (o.fake) {
        [-1, 1].forEach(function (sideSign) {
          const off = SG.vec.mul(o.n, sideSign * (o.depth / 2 + 0.05));

          ui.path([SG.vec.add(a, off), SG.vec.add(b, off)]);
          ctx.lineWidth = 3;
          ctx.strokeStyle = accent;
          ctx.stroke();
        });
        return;
      }

      ui.path([a, b]);
      ctx.lineWidth = Math.max(4, o.depth * scale + 2);
      ctx.strokeStyle = "#16161d";
      ctx.stroke();

      ctx.lineWidth = 1.5;
      ctx.strokeStyle = accent;

      if (SG.WINDOW_KINDS.indexOf(o.kind) >= 0) {
        [-0.04, 0.04].forEach(function (off) {
          ui.path([SG.vec.add(a, SG.vec.mul(o.n, off)), SG.vec.add(b, SG.vec.mul(o.n, off))]);
          ctx.stroke();
        });
        ui.path([a, b]);
        ctx.strokeStyle = o.glass === "frosted" ? "rgba(230,240,245,.9)" : "rgba(120,190,255,.95)";
        ctx.lineWidth = 2;
        ctx.stroke();
      } else if (SG.DOOR_KINDS[o.kind]) {
        const swing = o.swing ? -1 : 1;
        const two = SG.DOOR_KINDS[o.kind] === 2;
        const leaves = two ? [[a, 1], [b, -1]] : [[o.flip ? a : b, o.flip ? 1 : -1]];
        const leafWidth = two ? half : o.width;

        leaves.forEach(function (leaf) {
          const hinge = leaf[0];
          const dir = SG.vec.mul(o.d, leaf[1]);
          const open = SG.vec.add(hinge, SG.vec.mul(o.n, swing * leafWidth));
          const s = ui.toScreen(hinge);
          const r = leafWidth * scale;
          const start = Math.atan2(-dir[1], dir[0]);
          const end = Math.atan2(-(o.n[1] * swing), o.n[0] * swing);

          ui.path([hinge, open]);
          ctx.stroke();
          ctx.beginPath();
          ctx.setLineDash([3, 3]);
          ctx.arc(s[0], s[1], r, Math.min(start, end), Math.max(start, end), Math.abs(end - start) > Math.PI);
          ctx.stroke();
          ctx.setLineDash([]);
        });
      } else {
        ctx.setLineDash([5, 4]);
        [-o.depth / 2, o.depth / 2].forEach(function (off) {
          ui.path([SG.vec.add(a, SG.vec.mul(o.n, off)), SG.vec.add(b, SG.vec.mul(o.n, off))]);
          ctx.stroke();
        });
        ctx.setLineDash([]);
      }

      [a, b].forEach(function (p) {
        const q1 = SG.vec.add(p, SG.vec.mul(o.n, o.depth / 2));
        const q2 = SG.vec.add(p, SG.vec.mul(o.n, -o.depth / 2));

        ui.path([q1, q2]);
        ctx.lineWidth = 2;
        ctx.strokeStyle = accent;
        ctx.stroke();
      });
    });
  },
  drawStairs: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;

    SHELL.built.derived.stairs.filter(function (s) { return s.level === SHELL.level; }).forEach(function (s) {
      const selected = SHELL.sel && SHELL.sel.kind === "stairs" && SHELL.sel.id === s.id;
      const corner = function (x, y) { return SG.vec.add(SG.vec.add(s.at, SG.vec.mul(s.side, x)), SG.vec.mul(s.fwd, y)); };

      ui.path([corner(-s.width / 2, 0), corner(s.width / 2, 0), corner(s.width / 2, s.run), corner(-s.width / 2, s.run)]);
      ctx.closePath();
      ctx.fillStyle = "rgba(255,255,255,.08)";
      ctx.fill();
      ctx.lineWidth = selected ? 2 : 1;
      ctx.strokeStyle = selected ? "#ff66ff" : "rgba(255,255,255,.55)";
      ctx.stroke();

      for (let k = 1; k < s.count; k++) {
        ui.path([corner(-s.width / 2, k * s.stepRun), corner(s.width / 2, k * s.stepRun)]);
        ctx.lineWidth = 1;
        ctx.strokeStyle = "rgba(255,255,255,.25)";
        ctx.stroke();
      }

      ui.path([corner(0, 0.15), corner(0, s.run - 0.15)]);
      ctx.strokeStyle = selected ? "#ff66ff" : "#ffffff";
      ctx.lineWidth = 1.5;
      ctx.stroke();

      const tip = ui.toScreen(corner(0, s.run - 0.1));
      const back = ui.toScreen(corner(0, s.run - 0.45));
      const ang = Math.atan2(tip[1] - back[1], tip[0] - back[0]);

      ctx.beginPath();
      ctx.moveTo(tip[0], tip[1]);
      ctx.lineTo(tip[0] - Math.cos(ang - 0.45) * 9, tip[1] - Math.sin(ang - 0.45) * 9);
      ctx.lineTo(tip[0] - Math.cos(ang + 0.45) * 9, tip[1] - Math.sin(ang + 0.45) * 9);
      ctx.closePath();
      ctx.fillStyle = ctx.strokeStyle;
      ctx.fill();
    });
  },
  drawProps: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const level = shellLevel();

    (SHELL.doc.props || []).forEach(function (prop) {
      if (!prop.p || prop.p[2] < level.z - 0.3 || prop.p[2] > level.z + (level.height || 2.8)) return;

      const dims = SHELL.dims[prop.model] || { w: 0.6, d: 0.6 };
      const heading = ((prop.r && prop.r[2]) || 0) * Math.PI / 180;
      const ax = [Math.cos(heading), Math.sin(heading)];
      const ay = [-Math.sin(heading), Math.cos(heading)];
      const corner = function (x, y) { return SG.vec.add(SG.vec.add(prop.p, SG.vec.mul(ax, x)), SG.vec.mul(ay, y)); };
      const selected = SHELL.sel && SHELL.sel.kind === "prop" && SHELL.sel.id === prop.id;

      ui.path([corner(-dims.w / 2, -dims.d / 2), corner(dims.w / 2, -dims.d / 2), corner(dims.w / 2, dims.d / 2), corner(-dims.w / 2, dims.d / 2)]);
      ctx.closePath();
      ctx.fillStyle = selected ? "rgba(255,102,255,.35)" : "rgba(214,190,160,.28)";
      ctx.fill();
      ctx.lineWidth = selected ? 2 : 1;
      ctx.strokeStyle = selected ? "#ff66ff" : "rgba(240,220,190,.7)";
      ctx.stroke();
      ui.path([prop.p, corner(0, dims.d / 2)]);
      ctx.stroke();
    });
  },
  drawLights: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const level = shellLevel();

    (SHELL.doc.lights || []).forEach(function (light) {
      if (!light.p || light.p[2] < level.z || light.p[2] > level.z + (level.height || 2.8) + 0.3) return;

      const s = ui.toScreen(light.p);
      const selected = SHELL.sel && SHELL.sel.kind === "light" && SHELL.sel.id === light.id;
      const glow = ctx.createRadialGradient(s[0], s[1], 0, s[0], s[1], Math.max(14, (light.range || 7) * SHELL.view.scale * 0.35));

      glow.addColorStop(0, "rgba(255,226,189,.35)");
      glow.addColorStop(1, "rgba(255,226,189,0)");
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(s[0], s[1], Math.max(14, (light.range || 7) * SHELL.view.scale * 0.35), 0, Math.PI * 2);
      ctx.fill();
      ctx.beginPath();
      ctx.arc(s[0], s[1], 6, 0, Math.PI * 2);
      ctx.fillStyle = light.colour || "#ffe2bd";
      ctx.fill();
      ctx.lineWidth = selected ? 2.5 : 1;
      ctx.strokeStyle = selected ? "#ff66ff" : "#14141a";
      ctx.stroke();
    });
  },
  pointList: function () {
    const p = SHELL.doc.points || {};
    const out = [];

    SHELL_POINTS.forEach(function (def) {
      const value = p[def.id];

      if (def.many) (value || []).forEach(function (item, index) { if (item && item.p) out.push({ def: def, item: item, index: index }); });
      else if (value && value.p) out.push({ def: def, item: value, index: -1 });
    });

    return out;
  },
  drawPoints: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const level = shellLevel();

    ui.pointList().forEach(function (entry) {
      const p = entry.item.p;

      if (p[2] < level.z - 0.3 || p[2] > level.z + (level.height || 2.8)) return;

      const s = ui.toScreen(p);
      const selected = SHELL.sel && SHELL.sel.kind === "point" && SHELL.sel.name === entry.def.id && SHELL.sel.index === entry.index;

      ctx.beginPath();
      ctx.arc(s[0], s[1], 11, 0, Math.PI * 2);
      ctx.fillStyle = selected ? "#ff66ff" : "#1c1d24";
      ctx.fill();
      ctx.lineWidth = 2;
      ctx.strokeStyle = "#ff66ff";
      ctx.stroke();
      ctx.fillStyle = selected ? "#12060f" : "#ffffff";
      ctx.font = '900 10px "Font Awesome 6 Free"';
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      ctx.fillText(entry.def.glyph, s[0], s[1] + 0.5);

      if (entry.item.h !== undefined && entry.def.id === "exit") {
        const h = (entry.item.h + 90) * Math.PI / 180;

        ctx.beginPath();
        ctx.moveTo(s[0] + Math.cos(h) * 13, s[1] - Math.sin(h) * 13);
        ctx.lineTo(s[0] + Math.cos(h) * 21, s[1] - Math.sin(h) * 21);
        ctx.strokeStyle = "#ff66ff";
        ctx.stroke();
      }
    });
  },
  drawLabels: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;

    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    shellRoomsOnLevel().forEach(function (room) {
      const anchor = room.record.anchor || SG.interiorPoint(room.points);
      const s = ui.toScreen(anchor);
      const name = room.record.name || T("room_type_" + (room.record.type || "living"));
      const area = fmt(room.area, 1) + " m²";

      ctx.font = "700 12px Montserrat";

      const w = Math.max(ctx.measureText(name).width, 44) + 18;

      ctx.fillStyle = "rgba(14,14,19,.82)";
      ui.roundRect(s[0] - w / 2, s[1] - 18, w, 34, 8);
      ctx.fill();
      ctx.fillStyle = "#ffffff";
      ctx.fillText(name, s[0], s[1] - 6);
      ctx.font = "600 10px Montserrat";
      ctx.fillStyle = "#b1b7c3";
      ctx.fillText(area, s[0], s[1] + 8);
    });
  },
  roundRect: function (x, y, w, h, r) {
    const ctx = SHELL_UI.ctx;

    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
    ctx.closePath();
  },
  lengthLabel: function (a, b, offset) {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const l = SG.vec.len(SG.vec.sub(b, a));

    if (l < 0.05) return;

    const n = SG.vec.left(SG.vec.norm(SG.vec.sub(b, a)));
    const mid = SG.vec.add(SG.vec.mul(SG.vec.add(a, b), 0.5), SG.vec.mul(n, offset || 0.4));
    const s = ui.toScreen(mid);
    const text = fmt(l, 2) + " m";

    ctx.font = "700 11px Montserrat";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    const w = ctx.measureText(text).width + 12;

    ctx.fillStyle = "#ff66ff";
    ui.roundRect(s[0] - w / 2, s[1] - 10, w, 20, 6);
    ctx.fill();
    ctx.fillStyle = "#12060f";
    ctx.fillText(text, s[0], s[1] + 0.5);
  },
  detailEnds: function (item) {
    if (!item || SHELL_LINE_DETAILS.indexOf(item.kind) < 0 || !Array.isArray(item.at)) return null;

    const h = (Number(item.heading) || 0) * Math.PI / 180;
    const half = (Number(item.w) || 1) / 2;
    const d = [Math.cos(h) * half, Math.sin(h) * half];

    return [[item.at[0] - d[0], item.at[1] - d[1]], [item.at[0] + d[0], item.at[1] + d[1]]];
  },
  drawSelection: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const sel = SHELL.sel;

    if (sel && sel.kind === "detail") {
      const ends = ui.detailEnds(shellFind("details", sel.id));

      if (!ends) return;
      ui.lengthLabel(ends[0], ends[1], 0.35);
      ends.forEach(function (p) {
        const s = ui.toScreen(p);

        ctx.beginPath();
        ctx.arc(s[0], s[1], 7, 0, Math.PI * 2);
        ctx.fillStyle = "#ffffff";
        ctx.fill();
        ctx.lineWidth = 2.5;
        ctx.strokeStyle = "#ff66ff";
        ctx.stroke();
      });
      return;
    }

    if (!sel || sel.kind !== "wall") return;

    const wall = shellFind("walls", sel.id);

    if (!wall) return;

    ui.lengthLabel(wall.a, wall.b, (Number(wall.thick) || SHELL.thick) / 2 + 0.35);

    const mid = ui.bendHandle(wall);

    [wall.a, wall.b].forEach(function (p) {
      const s = ui.toScreen(p);

      ctx.beginPath();
      ctx.arc(s[0], s[1], 7, 0, Math.PI * 2);
      ctx.fillStyle = "#ffffff";
      ctx.fill();
      ctx.lineWidth = 2.5;
      ctx.strokeStyle = "#ff66ff";
      ctx.stroke();
    });

    const sm = ui.toScreen(mid);

    ctx.beginPath();
    ctx.rect(sm[0] - 5, sm[1] - 5, 10, 10);
    ctx.fillStyle = "#ff66ff";
    ctx.fill();
  },
  bendHandle: function (wall) {
    const mid = SG.vec.mul(SG.vec.add(wall.a, wall.b), 0.5);
    const n = SG.vec.left(SG.vec.norm(SG.vec.sub(wall.b, wall.a)));

    return SG.vec.add(mid, SG.vec.mul(n, Number(wall.bend) || 0));
  },
  drawDraft: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const d = SHELL.draft;
    const scale = SHELL.view.scale;

    ui.drawPart();

    if (SHELL.measure && SHELL.measure.b) {
      ui.path([SHELL.measure.a, SHELL.measure.b]);
      ctx.strokeStyle = "#5ab8ff";
      ctx.lineWidth = 2;
      ctx.setLineDash([6, 4]);
      ctx.stroke();
      ctx.setLineDash([]);
      ui.lengthLabel(SHELL.measure.a, SHELL.measure.b, 0.3);
    }

    if (SHELL.copyRoom && SHELL.copyAt) {
      const ghost = ui.copyRoomGhost(SHELL.copyAt);

      if (ghost) {
        ctx.beginPath();
        ghost.forEach(function (q, i) { const s2 = ui.toScreen(q); if (i) ctx.lineTo(s2[0], s2[1]); else ctx.moveTo(s2[0], s2[1]); });
        ctx.closePath();
        ctx.fillStyle = "rgba(255,102,255,0.14)";
        ctx.fill();
        ctx.setLineDash([6, 4]);
        ctx.strokeStyle = "#ff66ff";
        ctx.lineWidth = 2;
        ctx.stroke();
        ctx.setLineDash([]);
      }
    }

    if (!d) {
      if (SHELL.cursor && (SHELL.tool === "walls" || SHELL.tool === "room")) {
        const s = ui.toScreen(SHELL.cursor.p);

        ctx.beginPath();
        ctx.arc(s[0], s[1], SHELL.cursor.kind === "end" ? 7 : 4, 0, Math.PI * 2);
        ctx.strokeStyle = SHELL.cursor.kind === "end" ? "#3ddc84" : SHELL.cursor.kind === "wall" ? "#5ab8ff" : "#ff66ff";
        ctx.lineWidth = 2;
        ctx.stroke();
      }

      return;
    }

    if (d.kind === "walls") {
      let pts = [d.points[0]];

      for (let i = 1; i < d.points.length; i++) pts = pts.concat(SG.wallPoints({ a: d.points[i - 1], b: d.points[i], bend: (d.bends || [])[i - 1] || 0 }).slice(1));
      if (d.bulge) pts = pts.concat(SG.wallPoints({ a: d.bulge.a, b: d.bulge.b, bend: d.bulge.bend }).slice(1));
      else if (d.preview) pts.push(d.preview);

      ui.path(pts);
      ctx.lineWidth = Math.max(3, SHELL.thick * scale);
      ctx.strokeStyle = "rgba(255,102,255,.55)";
      ctx.lineCap = "square";
      ctx.lineJoin = "round";
      ctx.stroke();
      ctx.lineCap = "butt";
      ctx.lineJoin = "miter";

      if (d.bulge) {
        const mid = SG.vec.mul(SG.vec.add(d.bulge.a, d.bulge.b), 0.5);

        ui.path([d.bulge.a, d.bulge.b]);
        ctx.strokeStyle = "rgba(255,255,255,.35)";
        ctx.lineWidth = 1;
        ctx.setLineDash([4, 4]);
        ctx.stroke();
        ctx.setLineDash([]);
        ui.lengthLabel(mid, SG.vec.add(mid, SG.vec.mul(SG.vec.left(SG.vec.norm(SG.vec.sub(d.bulge.b, d.bulge.a))), d.bulge.bend || 0.001)), 0.25);
      } else if (d.preview && d.points.length) {
        ui.lengthLabel(d.points[d.points.length - 1], d.preview, SHELL.thick / 2 + 0.35);
      }
    } else if (d.kind === "room" && d.b && (SHELL.roomShape || "rect") !== "rect") {
      let pts = [];

      ui.roomWalls(d.a, d.b).forEach(function (seg) { pts = pts.concat(SG.wallPoints(seg).slice(pts.length ? 1 : 0)); });

      if (pts.length > 2) {
        ui.path(pts);
        ctx.closePath();
        ctx.fillStyle = "rgba(255,102,255,.1)";
        ctx.fill();
        ctx.lineWidth = Math.max(3, SHELL.thick * scale);
        ctx.strokeStyle = "rgba(255,102,255,.6)";
        ctx.stroke();
      }
    } else if (d.kind === "room" && d.b) {
      const a = d.a;
      const b = d.b;
      const pts = [a, [b[0], a[1]], b, [a[0], b[1]]];

      ui.path(pts);
      ctx.closePath();
      ctx.fillStyle = "rgba(255,102,255,.1)";
      ctx.fill();
      ctx.lineWidth = Math.max(3, SHELL.thick * scale);
      ctx.strokeStyle = "rgba(255,102,255,.6)";
      ctx.lineCap = "square";
      ctx.stroke();
      ctx.lineCap = "butt";
      ui.lengthLabel(a, [b[0], a[1]], -0.45);
      ui.lengthLabel([b[0], a[1]], b, -0.45);
    }
  },
  drawEditors: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;

    (SHELL.editors || []).forEach(function (editor) {
      if (editor.id === SHELL.me || !Array.isArray(editor.cursor)) return;
      if (editor.cursor[3] && editor.cursor[3] !== SHELL.level) return;

      const s = ui.toScreen(editor.cursor);

      ctx.fillStyle = editor.colour || "#5ad1ff";
      ctx.beginPath();
      ctx.moveTo(s[0], s[1]);
      ctx.lineTo(s[0] + 11, s[1] + 4);
      ctx.lineTo(s[0] + 4, s[1] + 11);
      ctx.closePath();
      ctx.fill();
      ctx.font = "700 10px Montserrat";
      ctx.textAlign = "left";
      ctx.fillText(editor.name || "", s[0] + 13, s[1] + 14);
    });
  }
});

Object.assign(SHELL_UI, {
  wallsOnLevel: function () {
    return (SHELL.doc.walls || []).filter(function (w) { return (w.level || "l1") === SHELL.level; });
  },
  distanceToWall: function (p, wall) {
    const pts = SG.wallPoints(wall);
    let best = Infinity;
    let at = null;

    for (let i = 1; i < pts.length; i++) {
      const a = pts[i - 1];
      const ab = SG.vec.sub(pts[i], a);
      const t = Math.max(0, Math.min(1, SG.vec.dot(SG.vec.sub(p, a), ab) / (SG.vec.dot(ab, ab) || 1)));
      const q = SG.vec.add(a, SG.vec.mul(ab, t));
      const d = SG.vec.len(SG.vec.sub(p, q));

      if (d < best) {
        best = d;
        at = q;
      }
    }

    return { distance: best, at: at };
  },
  hit: function (p) {
    const ui = SHELL_UI;
    const scale = SHELL.view.scale;
    const tol = 8 / scale;
    const level = shellLevel();

    const sel = SHELL.sel;

    if (sel && sel.kind === "wall") {
      const wall = shellFind("walls", sel.id);

      if (wall) {
        if (SG.vec.len(SG.vec.sub(p, wall.a)) < 10 / scale) return { kind: "handle", id: wall.id, end: "a" };
        if (SG.vec.len(SG.vec.sub(p, wall.b)) < 10 / scale) return { kind: "handle", id: wall.id, end: "b" };
        if (SG.vec.len(SG.vec.sub(p, ui.bendHandle(wall))) < 9 / scale) return { kind: "bend", id: wall.id };
      }
    }

    if (sel && sel.kind === "detail") {
      const ends = ui.detailEnds(shellFind("details", sel.id));

      if (ends) {
        if (SG.vec.len(SG.vec.sub(p, ends[0])) < 11 / scale) return { kind: "dethandle", id: sel.id, end: 0 };
        if (SG.vec.len(SG.vec.sub(p, ends[1])) < 11 / scale) return { kind: "dethandle", id: sel.id, end: 1 };
      }
    }

    for (const entry of ui.pointList()) {
      if (entry.item.p[2] < level.z - 0.3 || entry.item.p[2] > level.z + (level.height || 2.8)) continue;
      if (SG.vec.len(SG.vec.sub(p, entry.item.p)) < 12 / scale) return { kind: "point", name: entry.def.id, index: entry.index };
    }

    for (const light of SHELL.doc.lights || []) {
      if (!light.p || light.p[2] < level.z || light.p[2] > level.z + (level.height || 2.8) + 0.3) continue;
      if (SG.vec.len(SG.vec.sub(p, light.p)) < 9 / scale) return { kind: "light", id: light.id };
    }

    for (const o of SHELL.built.derived.openings) {
      if (o.level !== SHELL.level) continue;

      const rel = SG.vec.sub(p, o.c);

      if (Math.abs(SG.vec.dot(rel, o.d)) <= o.width / 2 && Math.abs(SG.vec.dot(rel, o.n)) <= o.depth / 2 + tol) return { kind: "opening", id: o.id };
    }

    let bestWall = null;

    ui.wallsOnLevel().forEach(function (wall) {
      const d = ui.distanceToWall(p, wall);

      if (d.distance <= Math.max(tol, (Number(wall.thick) || SHELL.thick) / 2 + 2 / scale) && (!bestWall || d.distance < bestWall.distance)) bestWall = { kind: "wall", id: wall.id, distance: d.distance, at: d.at };
    });

    if (bestWall) return bestWall;

    for (const prop of (SHELL.doc.props || []).slice().reverse()) {
      if (!prop.p || prop.p[2] < level.z - 0.3 || prop.p[2] > level.z + (level.height || 2.8)) continue;

      const dims = SHELL.dims[prop.model] || { w: 0.6, d: 0.6 };
      const h = ((prop.r && prop.r[2]) || 0) * Math.PI / 180;
      const rel = SG.vec.sub(p, prop.p);
      const x = rel[0] * Math.cos(h) + rel[1] * Math.sin(h);
      const y = -rel[0] * Math.sin(h) + rel[1] * Math.cos(h);

      if (Math.abs(x) <= dims.w / 2 && Math.abs(y) <= dims.d / 2) return { kind: "prop", id: prop.id };
    }

    for (const s of SHELL.built.derived.stairs) {
      if (s.level !== SHELL.level) continue;
      if ((s.footprint || []).some(function (poly) { return SG.insidePolygon(p, poly); })) return { kind: "stairs", id: s.id };
    }

    for (const det of SHELL.built.derived.details || []) {
      if (det.level !== SHELL.level) continue;

      const rel = SG.vec.sub(p, det.at);

      if (Math.abs(SG.vec.dot(rel, det.ax)) <= det.w / 2 + 0.08 && Math.abs(SG.vec.dot(rel, det.ay)) <= Math.max(det.d / 2, 0.15) + 0.05) return { kind: "detail", id: det.id };
    }

    for (const pool of SHELL.built.derived.pools || []) {
      if (pool.level !== SHELL.level) continue;
      if (SG.insidePolygon(p, pool.points)) return { kind: "pool", id: pool.id };
    }

    const room = shellRoomAt(p);

    if (room) return { kind: "room", id: room.id };

    return null;
  },
  snap: function (p, from, free) {
    const ui = SHELL_UI;
    const scale = SHELL.worldInput ? 34 : SHELL.view.scale;
    const grid = Number(SHELL.doc.settings && SHELL.doc.settings.grid) || 0.25;
    let best = null;

    ui.wallsOnLevel().forEach(function (wall) {
      [wall.a, wall.b].forEach(function (q) {
        const d = SG.vec.len(SG.vec.sub(p, q));

        if (d < 12 / scale && (!best || d < best.d)) best = { p: q.slice(), kind: "end", d: d };
      });
    });

    if (best) return best;

    ui.wallsOnLevel().forEach(function (wall) {
      const d = ui.distanceToWall(p, wall);

      if (d.distance < 8 / scale && (!best || d.distance < best.d)) best = { p: d.at.map(function (v) { return SG.round(v, 3); }), kind: "wall", d: d.distance };
    });

    if (best) return best;

    if (from && !free) {
      const v = SG.vec.sub(p, from);
      const len = SG.vec.len(v);
      const ang = Math.round(Math.atan2(v[1], v[0]) / (Math.PI / 12)) * (Math.PI / 12);
      const l = Math.max(grid, Math.round(len / grid) * grid);

      return { p: [SG.round(from[0] + Math.cos(ang) * l, 3), SG.round(from[1] + Math.sin(ang) * l, 3)], kind: "angle" };
    }

    if (free) return { p: [SG.round(p[0], 3), SG.round(p[1], 3)], kind: "free" };

    return { p: [Math.round(p[0] / grid) * grid, Math.round(p[1] / grid) * grid].map(function (v) { return SG.round(v, 3); }), kind: "grid" };
  },
  addWalls: function (segments) {
    const ui = SHELL_UI;
    const existing = ui.wallsOnLevel();
    const out = [];

    segments.forEach(function (seg) {
      if (Math.abs(Number(seg.bend) || 0) >= 0.02) {
        out.push({ id: SG.uid("w"), level: SHELL.level, a: seg.a, b: seg.b, thick: SHELL.thick, bend: SG.round(seg.bend, 3) });
        return;
      }

      let pieces = [[seg.a, seg.b]];

      existing.concat(out).forEach(function (wall) {
        if (Math.abs(Number(wall.bend) || 0) > 0.02) return;

        const d = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
        const next = [];

        pieces.forEach(function (piece) {
          const e = SG.vec.sub(piece[1], piece[0]);
          const el2 = SG.vec.len(e);

          if (el2 < 0.01 || Math.abs(SG.vec.cross(d, SG.vec.norm(e))) > 1e-3 || Math.abs(SG.vec.cross(d, SG.vec.sub(piece[0], wall.a))) > 0.01) {
            next.push(piece);
            return;
          }

          const w0 = 0;
          const w1 = SG.vec.dot(SG.vec.sub(wall.b, wall.a), d);
          const p0 = SG.vec.dot(SG.vec.sub(piece[0], wall.a), d);
          const p1 = SG.vec.dot(SG.vec.sub(piece[1], wall.a), d);
          const lo = Math.min(p0, p1);
          const hi = Math.max(p0, p1);
          const at = function (t) { return SG.vec.add(wall.a, SG.vec.mul(d, t)).map(function (v) { return SG.round(v, 4); }); };

          if (hi <= w0 + 0.01 || lo >= w1 - 0.01) {
            next.push(piece);
            return;
          }

          if (lo < w0 - 0.01) next.push([at(lo), at(w0)]);
          if (hi > w1 + 0.01) next.push([at(w1), at(hi)]);
        });
        pieces = next;
      });

      pieces.forEach(function (piece) {
        if (SG.vec.len(SG.vec.sub(piece[1], piece[0])) >= 0.05) out.push({ id: SG.uid("w"), level: SHELL.level, a: piece[0], b: piece[1], thick: SHELL.thick });
      });
    });

    if (out.length) shellCommit({ set: { walls: out } });

    return out;
  },
  connected: function (p, skip) {
    const out = [];

    (SHELL.doc.walls || []).forEach(function (wall) {
      if ((wall.level || "l1") !== SHELL.level) return;

      ["a", "b"].forEach(function (end) {
        if (skip && skip.id === wall.id && skip.end === end) return;
        if (SG.vec.len(SG.vec.sub(wall[end], p)) < 0.01) out.push({ id: wall.id, end: end });
      });
    });

    return out;
  },
  beginDetailEnd: function (hit) {
    const item = shellFind("details", hit.id);
    const ends = SHELL_UI.detailEnds(item);

    if (!ends) return;
    SHELL_UI.beginDrag("detailend", [{ coll: "details", id: hit.id }], { id: hit.id, fixed: ends[1 - hit.end], end: hit.end });
  },
  beginDrag: function (kind, ids, extra) {
    const originals = {};

    ids.forEach(function (ref) {
      const item = shellFind(ref.coll, ref.id);

      if (item) {
        originals[ref.coll] = originals[ref.coll] || [];

        if (!originals[ref.coll].some(function (x) { return x.id === item.id; })) originals[ref.coll].push(SG.clone(item));
      }
    });

    SHELL.drag = Object.assign({ kind: kind, originals: originals, moved: false, rootBefore: SG.clone(SHELL.doc.points || {}) }, extra || {});
  },
  endDrag: function () {
    const drag = SHELL.drag;

    SHELL.drag = null;

    if (!drag || !drag.moved) return;

    const patch = { set: {} };
    const inverse = { set: {} };

    Object.keys(drag.originals).forEach(function (coll) {
      patch.set[coll] = drag.originals[coll].map(function (o) { return SG.clone(shellFind(coll, o.id)); }).filter(Boolean);
      inverse.set[coll] = drag.originals[coll];
    });

    if (drag.kind === "point") {
      patch.root = { points: {} };
      inverse.root = { points: {} };
      patch.root.points[drag.name] = SG.clone(SHELL.doc.points[drag.name]);
      inverse.root.points[drag.name] = drag.rootBefore[drag.name] === undefined ? null : drag.rootBefore[drag.name];
    }

    SHELL.undo.push({ patch: SG.clone(patch), inverse: inverse });
    SHELL.redo = [];

    const tokenId = "p" + SHELL.nextToken++;

    SHELL.commits = (SHELL.commits || 0) + 1;
    SHELL.pending.push({ token: tokenId, patch: SG.clone(patch) });
    shellRebuild();
    toolAction("patch", { patch: patch, rev: SHELL.doc.rev, token: tokenId });
    SHELL_UI.refresh();
  },
  bind: function () {
    const ui = SHELL_UI;
    const canvas = ui.canvas;
    let pan = null;

    $(window).on("resize.shell", function () { ui.resize(); });

    canvas.on("contextmenu", function (event) { event.preventDefault(); });

    canvas.on("wheel", function (event) {
      const e = event.originalEvent;
      const rect = canvas[0].getBoundingClientRect();
      const before = ui.toWorld(e.clientX - rect.left, e.clientY - rect.top);

      SHELL.view.scale = Math.max(6, Math.min(260, SHELL.view.scale * (e.deltaY < 0 ? 1.15 : 1 / 1.15)));

      const after = ui.toWorld(e.clientX - rect.left, e.clientY - rect.top);

      SHELL.view.x += before[0] - after[0];
      SHELL.view.y += before[1] - after[1];
      SHELL.dirty = true;
      event.preventDefault();
    });

    canvas.on("mousedown", function (event) {
      const rect = canvas[0].getBoundingClientRect();
      const sx = event.clientX - rect.left;
      const sy = event.clientY - rect.top;
      const p = ui.toWorld(sx, sy);

      if (event.button === 1 || (event.button === 0 && ui.spaceDown)) {
        pan = { x: event.clientX, y: event.clientY, vx: SHELL.view.x, vy: SHELL.view.y };
        event.preventDefault();
        return;
      }

      if (event.button === 2) {
        if (SHELL.draft && SHELL.draft.kind === "walls") ui.finishWalls();
        else if (SHELL.tool !== "select") ui.setTool("select");
        else pan = { x: event.clientX, y: event.clientY, vx: SHELL.view.x, vy: SHELL.view.y };

        return;
      }

      ui.planPressed = true;
      ui.down(p, event);
    });

    $(document).on("mousemove.shell", function (event) {
      if (!SHELL.open) return;

      const rect = canvas[0].getBoundingClientRect();

      if (pan) {
        SHELL.view.x = pan.vx - (event.clientX - pan.x) / SHELL.view.scale;
        SHELL.view.y = pan.vy + (event.clientY - pan.y) / SHELL.view.scale;
        SHELL.dirty = true;
        return;
      }

      const sx = event.clientX - rect.left;
      const sy = event.clientY - rect.top;

      if (sx < 0 || sy < 0 || sx > rect.width || sy > rect.height) {
        if (!SHELL.drag) return;
      }

      const p = ui.toWorld(sx, sy);

      ui.move(p, event);
      ui.status.text(fmt(p[0], 2) + ", " + fmt(p[1], 2) + "  ·  " + (shellLevel().name || ""));

      const now = Date.now();

      if (now - SHELL.presenceAt > 180) {
        SHELL.presenceAt = now;
        toolAction("presence", { cursor: [SG.round(p[0], 2), SG.round(p[1], 2), shellLevel().z, SHELL.level], selection: SHELL.sel, tool: SHELL.tool });
      }
    });

    $(document).on("mouseup.shell", function (event) {
      if (!SHELL.open) return;

      if (pan) {
        pan = null;
        return;
      }

      if (!ui.planPressed && !SHELL.drag) return;

      ui.planPressed = false;

      const rect = canvas[0].getBoundingClientRect();

      ui.up(ui.toWorld(event.clientX - rect.left, event.clientY - rect.top), event);
    });

    canvas.on("dblclick", function () {
      if (SHELL.draft && SHELL.draft.kind === "walls") ui.finishWalls();
    });

    $(document).on("keydown.shell", function (event) {
      if (!SHELL.open || SHELL.walking || STATE.looking) return;
      if ($(event.target).is("input, textarea, select")) return;
      if (!$("#modal").hasClass("hidden")) return;

      const key = event.key.toLowerCase();

      if (SHELL_CAM_KEYS[key] && !event.ctrlKey && !event.altKey) {
        event.preventDefault();
        ui.camKey(key, true);
        return;
      }

      if (key === " ") {
        ui.spaceDown = true;
        return;
      }

      if (event.ctrlKey && key === "z") {
        shellUndo();
        event.preventDefault();
        return;
      }

      if (event.ctrlKey && (key === "y" || (event.shiftKey && key === "z"))) {
        shellRedo();
        event.preventDefault();
        return;
      }

      if (event.ctrlKey && key === "d") {
        ui.duplicate();
        event.preventDefault();
        return;
      }

      if (key === "delete" || key === "backspace") {
        ui.deleteSelection();
        return;
      }

      if (key === "enter") {
        if (SHELL.draft && SHELL.draft.kind === "walls") ui.finishWalls();
        return;
      }

      if (key === "g" && !event.ctrlKey && !event.altKey) {
        SHELL_UI.toggleGrid();
        return;
      }

      if (key === "r" && SHELL.tool === "details" && !SHELL.sel) {
        SHELL.details.heading = ((Number(SHELL.details.heading) || 0) + (event.shiftKey ? 15 : 90)) % 360;
        SHELL.dirty = true;
        return;
      }

      if (key === "r" && SHELL.ghostModel) {
        ui.turnGhost(event.shiftKey ? 15 : 90);
        return;
      }

      if (key === "r" && SHELL.sel) {
        ui.rotateSelection(event.shiftKey ? 15 : 90);
        return;
      }

      const tool = SHELL_TOOLS.find(function (t) { return t.key.toLowerCase() === key; });

      if (tool && !event.ctrlKey) ui.setTool(tool.id);
    });

    $(document).on("keyup.shell", function (event) {
      if (event.key === " ") ui.spaceDown = false;
      if (SHELL_CAM_KEYS[event.key.toLowerCase()]) ui.camKey(event.key.toLowerCase(), false);
    });

    $(window).on("blur.shell", function () { ui.camKey(null, false); });

    document.addEventListener("wheel", function (event) {
      if (!SHELL.open || SHELL.walking || STATE.looking || SHELL.mode === "plan") return;
      if (inPanel(event.target) || $(event.target).closest(".sh-side, .sh-top, .sh-tools, .sh-stage, .sh-canvas, #modal").length) return;
      if (SHELL.tool === "furniture" && SHELL.ghostModel) return;

      toolAction("cam", { zoom: event.deltaY > 0 ? 1 : -1, x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight });
    }, { passive: true });

    document.addEventListener("mousedown", function (event) {
      if (event.button !== 1 || !SHELL.open || SHELL.walking || SHELL.mode === "plan") return;
      if (inPanel(event.target) || $(event.target).closest(".sh-side, .sh-top, .sh-tools, .sh-stage, .sh-canvas, #modal").length) return;

      event.preventDefault();
      SHELL.orbit = { x: event.clientX, y: event.clientY, sent: 0, dx: 0, dy: 0 };
    }, true);

    document.addEventListener("mousemove", function (event) {
      const o = SHELL.orbit;

      if (!o) return;

      o.dx += event.clientX - o.x;
      o.dy += event.clientY - o.y;
      o.x = event.clientX;
      o.y = event.clientY;

      if (Date.now() - o.sent > 16 && (o.dx || o.dy)) {
        toolAction("cam", { orbit: [o.dx, o.dy] });
        o.dx = 0;
        o.dy = 0;
        o.sent = Date.now();
      }
    }, true);

    document.addEventListener("mouseup", function (event) {
      if (event.button === 1 && SHELL.orbit) {
        if (SHELL.orbit.dx || SHELL.orbit.dy) toolAction("cam", { orbit: [SHELL.orbit.dx, SHELL.orbit.dy] });
        SHELL.orbit = null;
      }
    }, true);
  },
  camKey: function (key, down) {
    const keys = SHELL.camKeys || (SHELL.camKeys = {});

    if (key === null) {
      if (!Object.keys(keys).length) return;
      SHELL.camKeys = {};
    } else {
      const name = SHELL_CAM_KEYS[key];

      if (!!keys[name] === down) return;
      if (down) keys[name] = true;
      else delete keys[name];
    }

    toolAction("cam", { keys: SHELL.camKeys });
  },
  escape: function () {
    if (SHELL.walking) return;
    if (SHELL_UI.cancelAction()) return;
    if (!SHELL.open) post("toolStop");
  }
});

Object.assign(SHELL_UI, {
  select: function (sel) {
    SHELL.sel = sel;

    const anchorColl = sel ? { stairs: "stairs", pool: "pools", detail: "details" }[sel.kind] : null;
    const anchorItem = anchorColl ? shellFind(anchorColl, sel.id) : null;
    const openingItem = sel && sel.kind === "opening" && SHELL.built ? (SHELL.built.derived.openings || []).find(function (o) { return o.id === sel.id; }) : null;

    SHELL.liveGhost = null;

    if (sel && sel.kind === "prop") toolAction("selectprop", { id: sel.id });
    else if (openingItem && SHELL.mode !== "plan") {
      const openingLevel = SG.levelOf(SHELL.doc, openingItem.level) || shellLevel();

      toolAction("selectanchor", { kind: "opening", id: sel.id, p: [openingItem.c[0], openingItem.c[1], (Number(openingLevel.z) || 0) + (Number(openingItem.z0) || 0) + 1.0], h: SG.round(Math.atan2(openingItem.d[1], openingItem.d[0]) * 180 / Math.PI, 1), slide: true });
    }
    else if (anchorItem && Array.isArray(anchorItem.at)) {
      const anchorLevel = SG.levelOf(SHELL.doc, anchorItem.level) || shellLevel();

      toolAction("selectanchor", { kind: sel.kind, id: sel.id, p: [anchorItem.at[0], anchorItem.at[1], Number(anchorLevel.z) || 0], h: Number(anchorItem.heading) || 0 });
    } else toolAction("selectprop", {});

    SHELL_UI.refresh();
  },
  down: function (p, event) {
    const ui = SHELL_UI;
    const tool = SHELL.tool;
    const level = shellLevel();

    if (SHELL.copyRoom) {
      ui.copyRoomAt(p);
      return;
    }

    if (tool === "roof") return;

    if (tool === "furniture" && SHELL.ghostModel) {
      ui.placeProp(p, event);
      return;
    }

    if (tool === "furniture") {
      const hit = ui.hit(p);

      if (hit && hit.kind === "prop") {
        const item = shellFind("props", hit.id);

        ui.select({ kind: "prop", id: hit.id });
        ui.beginDrag("move", [{ coll: "props", id: hit.id }], { coll: "props", id: hit.id, from: p, start: item.p.slice() });
      } else {
        ui.select(null);
      }

      return;
    }

    if (tool === "pool" || tool === "stairs") {
      const hitOwn = ui.hit(p);
      const own = tool === "pool" ? "pool" : "stairs";

      if (hitOwn && hitOwn.kind === own) {
        const coll = tool === "pool" ? "pools" : "stairs";
        const item = shellFind(coll, hitOwn.id);

        if (item) {
          ui.select({ kind: own, id: hitOwn.id });
          ui.beginDrag("move", [{ coll: coll, id: hitOwn.id }], { coll: coll, id: hitOwn.id, from: p, start: item.at.slice() });
          return;
        }
      }
    }

    if (tool === "pool") {
      ui.placePool(p);
      return;
    }

    if (tool === "details") {
      const hitDetail = ui.hit(p);
      const placingKind = (SHELL.details || {}).kind;
      const surfaceKinds = ["floorpatch", "platform", "balcony", "lawn", "terrace", "deck", "path", "void"];
      const lineKinds = SHELL_LINE_DETAILS;
      const hitItem = hitDetail && hitDetail.kind === "detail" ? shellFind("details", hitDetail.id) : null;
      const onSurface = hitItem && surfaceKinds.indexOf(hitItem.kind) >= 0 && surfaceKinds.indexOf(placingKind) < 0;

      if (hitDetail && hitDetail.kind === "dethandle") {
        ui.beginDetailEnd(hitDetail);
        return;
      }

      if (lineKinds.indexOf(placingKind) >= 0 && !(hitItem && hitItem.kind === placingKind && !event.shiftKey)) {
        SHELL.draft = { kind: "detailline", a: p, b: p };
        SHELL.dirty = true;
        return;
      }

      if (hitDetail && hitDetail.kind === "detail" && !onSurface) {
        const item = shellFind("details", hitDetail.id);

        ui.select({ kind: "detail", id: hitDetail.id });
        ui.beginDrag("move", [{ coll: "details", id: hitDetail.id }], { coll: "details", id: hitDetail.id, from: p, start: item.at.slice() });
        return;
      }

      ui.placeDetail(p);
      return;
    }

    if (tool === "paint" && SHELL.paint.target === "tiles") {
      SHELL.draft = { kind: "tiles", erase: event.button === 2 || event.altKey };
      ui.paintTiles(p, SHELL.draft.erase);
      return;
    }

    if (tool === "paint" && SHELL.paint.target === "part") {
      const near = ui.nearestWall(p, 0.6);

      if (!near || Math.abs(Number(near.wall.bend) || 0) >= 0.02) return;

      const dw = SG.vec.norm(SG.vec.sub(near.wall.b, near.wall.a));
      const sideKey = SG.vec.cross(SG.vec.sub(near.wall.b, near.wall.a), SG.vec.sub(p, near.wall.a)) >= 0 ? "l" : "r";

      SHELL.draft = { kind: "part", wall: near.wall.id, side: sideKey, a: SG.vec.dot(SG.vec.sub(p, near.wall.a), dw), b: SG.vec.dot(SG.vec.sub(p, near.wall.a), dw) };
      SHELL.dirty = true;
      return;
    }

    if (tool === "hammer") {
      ui.hammerAt(p);
      return;
    }

    if (tool === "select") {
      const hit = ui.hit(p);

      if (!hit) {
        ui.select(null);
        return;
      }

      if (hit.kind === "handle") {
        const wall = shellFind("walls", hit.id);
        const linked = ui.connected(wall[hit.end], null);

        ui.beginDrag("vertex", linked.map(function (l) { return { coll: "walls", id: l.id }; }), { linked: linked });
        return;
      }

      if (hit.kind === "bend") {
        ui.beginDrag("bend", [{ coll: "walls", id: hit.id }], { id: hit.id });
        return;
      }

      if (hit.kind === "dethandle") {
        ui.beginDetailEnd(hit);
        return;
      }

      if (hit.kind === "point") {
        ui.select({ kind: "point", name: hit.name, index: hit.index });
        ui.beginDrag("point", [], { name: hit.name, index: hit.index, from: p });
        return;
      }

      if (hit.kind === "room") {
        ui.select({ kind: "room", id: hit.id });
        return;
      }

      ui.select({ kind: hit.kind, id: hit.id });

      if (hit.kind === "wall") {
        const wall = shellFind("walls", hit.id);
        const linked = ui.connected(wall.a, { id: wall.id, end: "a" }).concat(ui.connected(wall.b, { id: wall.id, end: "b" }));

        ui.beginDrag("wall", [{ coll: "walls", id: wall.id }].concat(linked.map(function (l) { return { coll: "walls", id: l.id }; })), { id: wall.id, from: p, a: wall.a.slice(), b: wall.b.slice(), linked: linked.map(function (l) { return Object.assign({ p: shellFind("walls", l.id)[l.end].slice() }, l); }) });
      } else if (hit.kind === "opening") {
        ui.beginDrag("opening", [{ coll: "openings", id: hit.id }], { id: hit.id });
      } else if (hit.kind === "stairs" || hit.kind === "light" || hit.kind === "prop" || hit.kind === "pool" || hit.kind === "detail") {
        const coll = hit.kind === "stairs" ? "stairs" : hit.kind === "light" ? "lights" : hit.kind === "pool" ? "pools" : hit.kind === "detail" ? "details" : "props";
        const item = shellFind(coll, hit.id);

        ui.beginDrag("move", [{ coll: coll, id: hit.id }], { coll: coll, id: hit.id, from: p, start: (item.at || item.p).slice() });
      }

      return;
    }

    if (tool === "walls") {
      if (SHELL.draft && SHELL.draft.kind === "walls" && SHELL.draft.points.length > 1 && SG.vec.len(SG.vec.sub(p, SHELL.draft.points[SHELL.draft.points.length - 1])) < 0.2) {
        ui.finishWalls();
        return;
      }

      if (SHELL.draft && SHELL.draft.bulge) {
        const bulge = SHELL.draft.bulge;

        ui.bulgeTo(p);

        SHELL.draft.points.push(bulge.b);
        SHELL.draft.bends.push(SG.round(bulge.bend || 0, 3));
        SHELL.draft.bulge = null;

        if (bulge.end && SHELL.draft.points.length > 2) ui.finishWalls();

        SHELL.dirty = true;
        return;
      }

      const snapped = ui.snap(p, SHELL.draft && SHELL.draft.points.length ? SHELL.draft.points[SHELL.draft.points.length - 1] : null, event.shiftKey);

      SHELL.wallPress = SHELL.wallShape === "curve" ? null : { at: snapped.p.slice(), world: SHELL.worldInput === true };

      if (!SHELL.draft) {
        SHELL.draft = { kind: "walls", points: [snapped.p], bends: [], preview: null };
        SHELL_SFX.play("corner");
      } else {
        const last = SHELL.draft.points[SHELL.draft.points.length - 1];
        const finishReach = SHELL.draft.points.length > 1 ? (SHELL.mode === "plan" ? Math.max(0.2, 10 / SHELL.view.scale) : 0.5) : 0.05;

        if (SG.vec.len(SG.vec.sub(snapped.p, last)) < finishReach || SG.vec.len(SG.vec.sub(p, last)) < finishReach) {
          SHELL.wallPress = null;
          ui.finishWalls();
          return;
        }

        if (SHELL.wallShape === "curve" && SG.vec.len(SG.vec.sub(snapped.p, last)) >= 0.5) {
          SHELL.draft.bulge = { a: last, b: snapped.p, bend: 0, end: snapped.kind === "end" };
          SHELL.dirty = true;
          return;
        }

        SHELL.draft.points.push(snapped.p);
        SHELL_SFX.play("corner");
        SHELL.draft.bends.push(0);

        if (snapped.kind === "end" && SHELL.draft.points.length > 2) ui.finishWalls();
      }

      SHELL.dirty = true;
      return;
    }

    if (tool === "room") {
      SHELL.draft = { kind: "room", a: ui.snap(p, null, event.shiftKey).p, b: null };
      return;
    }

    if (tool === "measure") {
      SHELL.measure = { a: ui.snap(p, null, true).p, b: null, active: true };
      return;
    }

    if (tool === "opening") {
      const hit = ui.hit(p);

      if (!hit || hit.kind !== "wall") return;

      const wall = shellFind("walls", hit.id);

      if (Math.abs(Number(wall.bend) || 0) > 0.02) {
        showNotify({ title: T("notify_title"), text: T("sh_curved_no_openings"), type: "warning", timeout: 3000 });
        return;
      }

      const d = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
      const t = Math.round(SG.vec.dot(SG.vec.sub(p, wall.a), d) / 0.05) * 0.05;
      const opening = { id: SG.uid("o"), wall: wall.id, kind: SHELL.sub, t: SG.round(t, 3) };

      if (SG.DOOR_KINDS[SHELL.sub] || SHELL.sub === "fake") opening.door = SHELL.sub === "door" || SHELL.sub === "double" || SHELL.sub === "fake" ? SHELL.lastDoor || (SG.OPENINGS[SHELL.sub] || {}).door || "plain_white" : (SG.OPENINGS[SHELL.sub] || {}).door;

      shellCommit({ set: { openings: [opening] } });
      ui.select({ kind: "opening", id: opening.id });
      return;
    }

    if (tool === "stairs") {
      ui.placeStairs(p);
      return;
    }

    if (tool === "paint") {
      ui.paintAt(p);
      return;
    }

    if (tool === "light") {
      const room = shellRoomAt(p);

      if (SHELL.lamp === "sconce") {
        ui.placeSconce(p);
        return;
      }

      if (!room) return;

      const light = { id: SG.uid("li"), p: [SG.round(p[0], 3), SG.round(p[1], 3), SG.round(room.z + room.height - 0.01, 3)], shape: SHELL.lamp || "round", colour: "#ffe2bd", range: SHELL.lamp === "spot" ? 5 : 7, intensity: SHELL.lamp === "chandelier" ? 8 : 6 };

      shellCommit({ set: { lights: [light] } });
      ui.select({ kind: "light", id: light.id });
      return;
    }

    if (tool === "points") {
      const room = shellRoomAt(p);
      const z = room ? room.z : level.z;
      const def = SHELL_POINTS.find(function (x) { return x.id === SHELL.point; });
      const value = { p: [SG.round(p[0], 3), SG.round(p[1], 3), SG.round(z, 3)], h: 0 };
      const points = {};

      if (def.many) {
        const list = SG.clone((SHELL.doc.points && SHELL.doc.points[def.id]) || []);

        if (def.id !== "clean") value.water = [value.p[0], value.p[1], SG.round(z + (def.id === "showers" ? 2.0 : 0.95), 3)];

        list.push(value);
        points[def.id] = list;
        shellCommit({ root: { points: points } });
        ui.select({ kind: "point", name: def.id, index: list.length - 1 });
      } else {
        points[def.id] = value;
        shellCommit({ root: { points: points } });
        ui.select({ kind: "point", name: def.id, index: -1 });
      }

      ui.beginDrag("heading", [], { name: def.id, index: def.many ? (SHELL.doc.points[def.id] || []).length - 1 : -1, from: p });
    }
  },
  move: function (p, event) {
    const ui = SHELL_UI;
    const drag = SHELL.drag;

    if (SHELL.copyRoom) {
      SHELL.copyAt = p;
      SHELL.dirty = true;
    }

    if (drag) {
      drag.moved = true;

      if (drag.kind === "vertex") {
        const snapped = ui.snap(p, null, event.shiftKey);

        drag.linked.forEach(function (l) {
          const wall = shellFind("walls", l.id);

          if (wall) wall[l.end] = snapped.p.slice();
        });
      } else if (drag.kind === "bend") {
        const wall = shellFind("walls", drag.id);
        const mid = SG.vec.mul(SG.vec.add(wall.a, wall.b), 0.5);
        const n = SG.vec.left(SG.vec.norm(SG.vec.sub(wall.b, wall.a)));
        let bend = Math.round(SG.vec.dot(SG.vec.sub(p, mid), n) / 0.05) * 0.05;

        if (Math.abs(bend) < 0.1) bend = 0;

        wall.bend = SG.round(bend, 3);

        (SHELL.doc.openings || []).forEach(function (o) {
          if (o.wall === wall.id && bend !== 0) drag.blocked = true;
        });
      } else if (drag.kind === "wall") {
        const grid = Number(SHELL.doc.settings && SHELL.doc.settings.grid) || 0.25;
        let delta = SG.vec.sub(p, drag.from);

        if (!event.shiftKey) delta = [Math.round(delta[0] / grid) * grid, Math.round(delta[1] / grid) * grid];

        const wall = shellFind("walls", drag.id);

        wall.a = SG.vec.add(drag.a, delta).map(function (v) { return SG.round(v, 4); });
        wall.b = SG.vec.add(drag.b, delta).map(function (v) { return SG.round(v, 4); });
        drag.linked.forEach(function (l) {
          const other = shellFind("walls", l.id);

          if (other) other[l.end] = SG.vec.add(l.p, delta).map(function (v) { return SG.round(v, 4); });
        });
      } else if (drag.kind === "opening") {
        const o = shellFind("openings", drag.id);
        const wall = shellFind("walls", o.wall);
        const d = SG.vec.norm(SG.vec.sub(wall.b, wall.a));

        o.t = SG.round(Math.round(SG.vec.dot(SG.vec.sub(p, wall.a), d) / 0.05) * 0.05, 3);
      } else if (drag.kind === "detailend") {
        const item = shellFind("details", drag.id);
        const q = ui.snap(p, drag.fixed, event.shiftKey).p;
        const v = SG.vec.sub(q, drag.fixed);
        const length = SG.vec.len(v);

        if (item && length >= 0.3) {
          const a = drag.end === 1 ? drag.fixed : q;
          const b = drag.end === 1 ? q : drag.fixed;

          item.at = [SG.round((a[0] + b[0]) / 2, 3), SG.round((a[1] + b[1]) / 2, 3)];
          item.w = SG.round(Math.min(20, length), 3);
          item.heading = SG.round(((Math.atan2(b[1] - a[1], b[0] - a[0]) * 180 / Math.PI) % 360 + 360) % 360, 1);
        }
      } else if (drag.kind === "move") {
        const item = shellFind(drag.coll, drag.id);
        let delta = SG.vec.sub(p, drag.from);

        if (!event.shiftKey && drag.coll !== "props") delta = [Math.round(delta[0] / 0.05) * 0.05, Math.round(delta[1] / 0.05) * 0.05];

        if (drag.coll === "stairs" || drag.coll === "pools" || drag.coll === "details") item.at = SG.vec.add(drag.start, delta).map(function (v) { return SG.round(v, 3); });
        else item.p = [SG.round(drag.start[0] + delta[0], 3), SG.round(drag.start[1] + delta[1], 3), drag.start[2]];
      } else if (drag.kind === "point") {
        const target = drag.index >= 0 ? SHELL.doc.points[drag.name][drag.index] : SHELL.doc.points[drag.name];
        const delta = SG.vec.sub(p, drag.from);

        drag.from = p;
        target.p = [SG.round(target.p[0] + delta[0], 3), SG.round(target.p[1] + delta[1], 3), target.p[2]];

        if (target.water) target.water = [SG.round(target.water[0] + delta[0], 3), SG.round(target.water[1] + delta[1], 3), target.water[2]];
      } else if (drag.kind === "heading") {
        const target = drag.index >= 0 ? SHELL.doc.points[drag.name][drag.index] : SHELL.doc.points[drag.name];
        const v = SG.vec.sub(p, drag.from);

        if (SG.vec.len(v) > 0.25) target.h = SG.round(((Math.atan2(v[1], v[0]) * 180 / Math.PI - 90) % 360 + 360) % 360, 1);
      }

      if (drag.kind === "point" || drag.kind === "heading") SHELL.dirty = true;
      else shellRebuildSoon();
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "tiles") {
      ui.paintTiles(p, SHELL.draft.erase);
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "detailline") {
      SHELL.draft.b = ui.snap(p, SHELL.draft.a, event && event.shiftKey).p;
      SHELL.dirty = true;
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "part") {
      const wall = shellFind("walls", SHELL.draft.wall);

      if (wall) {
        const dw = SG.vec.norm(SG.vec.sub(wall.b, wall.a));

        SHELL.draft.b = Math.max(0, Math.min(SG.vec.len(SG.vec.sub(wall.b, wall.a)), SG.vec.dot(SG.vec.sub(p, wall.a), dw)));
        SHELL.dirty = true;
      }

      return;
    }

    if ((SHELL.tool === "furniture" && SHELL.ghostModel) || SHELL.tool === "pool" || SHELL.tool === "details") {
      SHELL.ghostAt = p;
      SHELL.dirty = true;
    }

    if (SHELL.tool === "walls" || SHELL.tool === "room") {
      const from = SHELL.draft && SHELL.draft.kind === "walls" && SHELL.draft.points.length ? SHELL.draft.points[SHELL.draft.points.length - 1] : null;
      const snapped = ui.snap(p, from, event.shiftKey);

      SHELL.cursor = snapped;

      if (SHELL.draft && SHELL.draft.kind === "walls" && SHELL.draft.bulge) ui.bulgeTo(p);
      else if (SHELL.draft && SHELL.draft.kind === "walls") SHELL.draft.preview = snapped.p;
      if (SHELL.draft && SHELL.draft.kind === "room") SHELL.draft.b = snapped.p;

      SHELL.dirty = true;
      return;
    }

    if (SHELL.measure && SHELL.measure.active) {
      SHELL.measure.b = ui.snap(p, SHELL.measure.a, event.shiftKey).p;
      SHELL.dirty = true;
      return;
    }

    const hit = ui.hit(p);
    const key = hit ? hit.kind + (hit.id || hit.name || "") : "";

    if (key !== SHELL.hoverKey) {
      SHELL.hoverKey = key;
      SHELL.hover = hit;
      SHELL.dirty = true;
    }
  },
  up: function (p, event) {
    const ui = SHELL_UI;

    if (SHELL.drag) {
      if (SHELL.drag.kind === "bend" && SHELL.drag.blocked) {
        const wall = shellFind("walls", SHELL.drag.id);

        wall.bend = SHELL.drag.originals.walls[0].bend || 0;
        SHELL.drag = null;
        shellRebuild();
        showNotify({ title: T("notify_title"), text: T("sh_curved_has_openings"), type: "warning", timeout: 3000 });
        return;
      }

      if (SHELL.drag.kind === "heading") {
        SHELL.drag.kind = "point";
        SHELL.drag.moved = true;
      }

      ui.endDrag();
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "tiles") {
      SHELL.draft = null;
      return;
    }

    if (SHELL.tool === "walls" && SHELL.wallPress) {
      ui.releaseWall(p, event);
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "detailline") {
      const a = SHELL.draft.a;
      const b = SHELL.draft.b || a;
      const length = SG.vec.len(SG.vec.sub(b, a));

      SHELL.draft = null;

      if (length < 0.3) {
        ui.placeDetail(a);
        return;
      }

      const det = ui.detailFor(SG.vec.mul(SG.vec.add(a, b), 0.5));

      det.at = [SG.round((a[0] + b[0]) / 2, 3), SG.round((a[1] + b[1]) / 2, 3)];
      det.w = SG.round(Math.min(20, length), 3);
      det.heading = SG.round(((Math.atan2(b[1] - a[1], b[0] - a[0]) * 180 / Math.PI) % 360 + 360) % 360, 1);
      SHELL.previewKey = "";
      toolAction("preview", { pieces: [] });
      shellCommit({ set: { details: [det] } });
      ui.select({ kind: "detail", id: det.id });
      SHELL.dirty = true;
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "part") {
      ui.commitPart(SHELL.draft);
      SHELL.draft = null;
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "room" && SHELL.draft.b) {
      const a = SHELL.draft.a;
      const b = SHELL.draft.b;

      SHELL.draft = null;

      if (SHELL.roomFloorOnly) {
        const shape = SHELL.roomShape || "rect";
        const rx = shape === "round" ? SG.vec.len(SG.vec.sub(b, a)) : Math.abs(b[0] - a[0]) / (shape === "rect" ? 2 : 1);
        const ry = shape === "round" ? rx : Math.abs(b[1] - a[1]) / (shape === "rect" ? 2 : 1);
        const at = shape === "rect" ? [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2] : a;

        if (rx >= 0.25 && ry >= 0.25) {
          const det = { id: SG.uid("dt"), level: SHELL.level, kind: "floorpatch", shape: shape, at: [SG.round(at[0], 3), SG.round(at[1], 3)], w: SG.round(rx * 2, 3), d: SG.round(ry * 2, 3), h: 0, heading: 0, mat: SHELL.floorPatchMat || "oak", top: "darkwood" };

          shellCommit({ set: { details: [det] } });
          ui.select({ kind: "detail", id: det.id });
        }

        SHELL.dirty = true;
        return;
      }

      const segs = ui.roomWalls(a, b);

      if (segs.length) ui.addWalls(segs);

      SHELL.dirty = true;
      return;
    }

    if (SHELL.draft && SHELL.draft.kind === "room") SHELL.draft = null;
    if (SHELL.measure) SHELL.measure.active = false;
  },
  detailPoint: function (hit, fallback) {
    const base = SG.DETAILS[(SHELL.details || {}).kind] || {};
    const p3 = hit && hit.p;
    const normal = (hit && hit.normal) || [0, 0, 1];
    const lv = shellLevel();
    const lz = lv.z || 0;

    if (!Array.isArray(p3)) return fallback;
    if (base.wall && Math.abs(normal[2] || 0) < 0.5 && p3[2] > lz - 0.1 && p3[2] < lz + (lv.height || 2.8) + 0.2) return [p3[0] + normal[0] * 0.05, p3[1] + normal[1] * 0.05];
    if (!hit.plane && Math.abs(normal[2] || 0) >= 0.5) return [p3[0], p3[1]];

    return fallback;
  },
  floorLevelAt: function (p3) {
    const levels = shellLevels().slice().sort(function (a, b) { return (Number(a.z) || 0) - (Number(b.z) || 0); });
    const z = Number(p3 && p3[2]) || 0;

    return levels.slice().reverse().find(function (l) { return z >= (Number(l.z) || 0) - 0.3; }) || levels[0] || shellLevel();
  },
  rayRefine: function (data) {
    if (!data || !data.ray || !SHELL.built) return data;

    const hit = SHELL_UI.rayPick(data.ray);

    if (!hit) return data;

    return Object.assign({}, data, { p: hit.p, normal: hit.normal, rayKind: hit.kind, rayId: hit.id });
  },
  rayPick: function (ray) {
    const V = SG.vec;
    const O = ray.o;
    const Dl = Math.hypot(ray.d[0], ray.d[1], ray.d[2]) || 1;
    const D = [ray.d[0] / Dl, ray.d[1] / Dl, ray.d[2] / Dl];
    const levels = shellLevels();
    const cur = shellLevel();
    const placing = (SHELL.tool === "furniture" && SHELL.ghostModel) || SHELL.tool === "pool" || SHELL.tool === "details" || SHELL.tool === "lights";
    const visible = levels.filter(function (l) { const cutNow = SHELL_UI.cutMode(); return placing || cutNow === "solo" ? l.id === cur.id : cutNow === "all" || (Number(l.z) || 0) <= (Number(cur.z) || 0) + 0.01; });
    const curZ = Number(cur.z) || 0;
    const curTop = curZ + (Number(cur.height) || 2.8);
    const visibleIds = {};
    let best = null;

    visible.forEach(function (l) { visibleIds[l.id] = l; });

    const dot3 = function (a, b) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; };
    const consider = function (t, normal, kind, id) {
      if (!(t > 0.05) || (best && t >= best.t)) return;
      best = { t: t, normal: normal, kind: kind, id: id };
    };
    const box = function (c, u, v, w, ext, kind, id) {
      let t0 = -Infinity;
      let t1 = Infinity;
      let nrm = null;
      const axes = [u, v, w];

      for (let i = 0; i < 3; i++) {
        const a = axes[i];
        const o = dot3([O[0] - c[0], O[1] - c[1], O[2] - c[2]], a);
        const d = dot3(D, a);

        if (Math.abs(d) < 1e-9) {
          if (o < ext[i][0] || o > ext[i][1]) return;
          continue;
        }

        let ta = (ext[i][0] - o) / d;
        let tb = (ext[i][1] - o) / d;
        let sign = -1;

        if (ta > tb) { const x = ta; ta = tb; tb = x; sign = 1; }
        if (ta > t0) { t0 = ta; nrm = [a[0] * sign, a[1] * sign, a[2] * sign]; }
        if (tb < t1) t1 = tb;
        if (t0 > t1) return;
      }

      if (t1 < 0.05) return;
      consider(t0 > 0.05 ? t0 : t1, nrm || [0, 0, 1], kind, id);
    };
    const flat = function (pts) {
      const a = pts[0];
      const b = pts[1];
      const ex = V.norm(V.sub(b, a));
      const ey = [-ex[1], ex[0]];
      let u0 = Infinity, u1 = -Infinity, v0 = Infinity, v1 = -Infinity;

      pts.forEach(function (q) {
        const r = V.sub(q, a);
        const u = V.dot(r, ex);
        const v = V.dot(r, ey);

        u0 = Math.min(u0, u); u1 = Math.max(u1, u); v0 = Math.min(v0, v); v1 = Math.max(v1, v);
      });

      return { a: a, ex: ex, ey: ey, u: [u0, u1], v: [v0, v1] };
    };

    visible.forEach(function (l) {
      const lz = Number(l.z) || 0;

      if (Math.abs(D[2]) > 1e-6) {
        const t = (lz - O[2]) / D[2];

        if (t > 0.05 && (!best || t < best.t)) {
          const q = [O[0] + D[0] * t, O[1] + D[1] * t];

          const onFloor = (SHELL.built.derived.rooms || []).some(function (r) { return r.level === l.id && SG.insidePolygon(q, r.points); }) || (SHELL.built.derived.details || []).some(function (det) { return det.level === l.id && det.kind === "floorpatch" && det.points && SG.insidePolygon(q, det.points); });

          if ((onFloor || placing) && !(SHELL.built.derived.holes || []).some(function (h) { return h.level === l.id && SG.insidePolygon(q, h.points); })) consider(t, [0, 0, D[2] > 0 ? -1 : 1], "floor", l.id);
        }
      }
    });

    (SHELL.doc.walls || []).forEach(function (w) {
      const l = visibleIds[w.level];

      if (!l) return;

      const lz = Number(l.z) || 0;
      const h = Number(w.height) || Number(l.height) || 2.8;
      const half = Math.max(0.08, Number(w.thick) || SHELL.thick || 0.2) / 2;
      const pts = SG.wallPoints(w);

      for (let i = 1; i < pts.length; i++) {
        const a = pts[i - 1];
        const b = pts[i];
        const L = V.len(V.sub(b, a));

        if (L < 0.01) continue;

        const d = V.norm(V.sub(b, a));

        box([a[0], a[1], lz], [d[0], d[1], 0], [-d[1], d[0], 0], [0, 0, 1], [[-half, L + half], [-half, half], [0, h]], "wall", w.id);
      }
    });

    (SHELL.built.derived.stairs || []).forEach(function (st) {
      if (!visibleIds[st.level] || placing) return;

      (st.footprint || []).forEach(function (poly) {
        if (!poly || poly.length < 3) return;

        const f = poly.length > 4 ? { a: [0, 0], ex: [1, 0], ey: [0, 1], u: [Math.min.apply(null, poly.map(function (q) { return q[0]; })), Math.max.apply(null, poly.map(function (q) { return q[0]; }))], v: [Math.min.apply(null, poly.map(function (q) { return q[1]; })), Math.max.apply(null, poly.map(function (q) { return q[1]; }))] } : flat(poly);

        box([f.a[0], f.a[1], st.z], [f.ex[0], f.ex[1], 0], [f.ey[0], f.ey[1], 0], [0, 0, 1], [f.u, f.v, [0, st.rise + 0.1]], "stairs", st.id);
      });
    });

    (SHELL.doc.props || []).forEach(function (prop) {
      if (!prop.p) return;
      if (placing && (prop.p[2] < curZ - 0.3 || prop.p[2] > curTop)) return;

      const dims = SHELL.dims[prop.model] || { w: 0.6, d: 0.6, h: 1.2 };
      const hd = ((prop.r && prop.r[2]) || 0) * Math.PI / 180;
      const ex = [Math.cos(hd), Math.sin(hd), 0];
      const ey = [-Math.sin(hd), Math.cos(hd), 0];

      box(prop.p, ex, ey, [0, 0, 1], [[-(dims.w || 0.6) / 2, (dims.w || 0.6) / 2], [-(dims.d || 0.6) / 2, (dims.d || 0.6) / 2], [0, dims.h || 1.2]], "prop", prop.id);
    });

    (SHELL.built.derived.pools || []).forEach(function (pool) {
      box([pool.at[0], pool.at[1], pool.z - (Number(pool.depth) || 1.5)], [pool.ax[0], pool.ax[1], 0], [pool.ay[0], pool.ay[1], 0], [0, 0, 1], [[-pool.w / 2 - 0.3, pool.w / 2 + 0.3], [-pool.l / 2 - 0.3, pool.l / 2 + 0.3], [0, (Number(pool.depth) || 1.5) + 0.05]], "pool", pool.id);
    });

    (SHELL.built.derived.details || []).forEach(function (det) {
      if (!det.points || det.points.length < 3 || (det.level && !visibleIds[det.level])) return;

      const f = flat(det.points);
      const z0 = (Number(det.z) || 0) + (Number(det.lift) || 0);
      const top = det.h === 0 ? (Number(det.z) || 0) + (Number(det.height) || 2.8) : z0 + (Number(det.h) || 0.05);

      box([f.a[0], f.a[1], z0], [f.ex[0], f.ex[1], 0], [f.ey[0], f.ey[1], 0], [0, 0, 1], [f.u, f.v, [0, Math.max(0.05, top - z0)]], "detail", det.id);
    });

    if (!best) return null;

    return { p: [O[0] + D[0] * best.t, O[1] + D[1] * best.t, O[2] + D[2] * best.t], normal: best.normal, kind: best.kind, id: best.id, t: best.t };
  },
  worldClick: function (clicked) {
    clicked = SHELL_UI.rayRefine(clicked);
    SHELL.worldInput = true;

    try {
      SHELL_UI.worldClickInner(clicked);
    } finally {
      SHELL.worldInput = false;
    }

    if (SHELL.lastHover) {
      SHELL.highlightKey = "";
      SHELL_UI.hover3d(Object.assign({}, SHELL.lastHover, clicked.plane ? { plane: clicked.plane } : {}));
    }
  },
  worldClickInner: function (clicked) {
    const ui = SHELL_UI;
    const p3 = clicked.p || [0, 0, 0];
    const normal = clicked.normal || [0, 0, 1];
    const ev = { shiftKey: clicked.shift === true, button: 0 };
    const tool = SHELL.tool;
    const onPlane = SHELL_PLANE_TOOLS.indexOf(tool) >= 0 && Array.isArray(clicked.plane);
    let p = onPlane ? [clicked.plane[0], clicked.plane[1]] : [p3[0], p3[1]];

    if (!onPlane) {
      const level = shellLevels().slice().reverse().find(function (l) { return p3[2] >= l.z - 0.3; });

      if (level && level.id !== SHELL.level && SHELL_UI.cutMode() !== "all" && SHELL_UI.cutMode() !== "solo") {
        SHELL.level = level.id;
        ui.drawSide();
      }
    }

    if (SHELL.copyRoom) {
      if (clicked.phase !== "release") ui.copyRoomAt(Array.isArray(clicked.plane) ? [clicked.plane[0], clicked.plane[1]] : p);
      return;
    }

    if (tool === "details") p = ui.detailPoint(clicked, p);

    if (clicked.phase === "release") {
      if (tool === "walls") ui.releaseWall(p, ev);

      if (tool === "room" && SHELL.draft && SHELL.draft.kind === "room" && SHELL.draft.a) {
        if (SG.vec.len(SG.vec.sub(p, SHELL.draft.a)) > 0.3) {
          SHELL.draft.b = ui.snap(p, null, ev.shiftKey).p;
          ui.up(p, ev);
        } else {
          showNotify({ title: T("notify_title"), text: T("sh_room_second_corner"), type: "info", timeout: 2500 });
        }
      }

      SHELL.dirty = true;
      return;
    }

    if (tool === "walls") {
      ui.down(p, ev);
      SHELL.dirty = true;
      return;
    }

    if (tool === "hammer") {
      ui.hammerHit(p3, normal, clicked);
      SHELL.dirty = true;
      return;
    }

    if (tool === "paint" && SHELL.paint.target === "part") {
      const near = ui.nearestWall(p, 0.6);

      if (!near || Math.abs(Number(near.wall.bend) || 0) >= 0.02) return;

      const wall = near.wall;
      const dw = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
      const probe = [p[0] + normal[0] * 0.3, p[1] + normal[1] * 0.3];
      const sideKey = SG.vec.cross(SG.vec.sub(wall.b, wall.a), SG.vec.sub(probe, wall.a)) >= 0 ? "l" : "r";
      const u = SG.vec.dot(SG.vec.sub(p, wall.a), dw);
      const zLocal = p3[2] - (shellLevel().z || 0);

      if (SHELL.draft && SHELL.draft.kind === "part3d" && SHELL.draft.wall === wall.id && SHELL.draft.side === sideKey) {
        const d = SHELL.draft;
        const free = Math.abs(zLocal - d.z) > 0.25;

        ui.commitPart({ wall: wall.id, side: sideKey, a: d.a, b: u, z0: free ? Math.min(d.z, zLocal) : undefined, z1: free ? Math.max(d.z, zLocal) : undefined });
        SHELL.draft = null;
      } else {
        SHELL.draft = { kind: "part3d", wall: wall.id, side: sideKey, a: u, z: zLocal };
        showNotify({ title: T("notify_title"), text: T("sh_part_second"), type: "info", timeout: 2500 });
      }
    } else if (tool === "paint" && SHELL.paint.target === "tiles") {
      if (Math.abs(normal[2] || 0) > 0.5) ui.paintTiles(p, clicked.shift === true, ui.floorLevelAt(p3).id);
    } else if (tool === "paint" && clicked.ctrl === true) {
      ui.pickPaint(p, normal);
    } else if (tool === "paint") {
      ui.paintAt(p, normal, p3);
    } else if (tool === "furniture") {
      const hit = ui.hit(p);

      if (hit && hit.kind === "prop") ui.select({ kind: "prop", id: hit.id });
    } else if (tool === "select" && !onPlane && ui.pick3d(p3, normal)) {
      const picked = ui.pick3d(p3, normal);

      if (picked.kind === "wall") {
        const hit = ui.hit(p);

        ui.select(hit && hit.kind === "point" ? { kind: "point", name: hit.name, index: hit.index } : picked);
      } else {
        ui.select(picked);
      }
    } else if (tool === "select") {
      const hit = ui.hit(p);

      if (hit && hit.kind !== "handle" && hit.kind !== "bend" && hit.kind !== "dethandle") ui.select(hit.kind === "point" ? { kind: "point", name: hit.name, index: hit.index } : { kind: hit.kind, id: hit.id });
      else ui.select(null);
    } else if (tool === "room") {
      if (SHELL.draft && SHELL.draft.kind === "room") {
        SHELL.draft.b = ui.snap(p, null, ev.shiftKey).p;
        ui.up(p, ev);
      } else {
        ui.down(p, ev);
        if (clicked.phase !== "press") showNotify({ title: T("notify_title"), text: T("sh_room_second_corner"), type: "info", timeout: 2500 });
      }
    } else if (tool === "details" && SHELL_LINE_DETAILS.indexOf((SHELL.details || {}).kind) >= 0) {
      if (SHELL.draft && SHELL.draft.kind === "detailline") {
        SHELL.draft.b = ui.snap(p, SHELL.draft.a, ev.shiftKey).p;
        ui.up(p, ev);
      } else {
        ui.down(p, ev);

        if (SHELL.draft && SHELL.draft.kind === "detailline") showNotify({ title: T("notify_title"), text: T("sh_detail_line_second"), type: "info", timeout: 2500 });
        else ui.up(p, ev);
      }
    } else if (tool === "measure") {
      if (SHELL.measure && SHELL.measure.active) {
        SHELL.measure.b = ui.snap(p, null, true).p;
        SHELL.measure.active = false;
      } else {
        ui.down(p, ev);
      }

      ui.drawSide();
    } else if (tool === "opening") {
      const near = ui.nearestWall(p, 0.6);

      if (near) {
        const d = SG.vec.norm(SG.vec.sub(near.b, near.a));

        p = [near.a[0] + d[0] * SG.vec.dot(SG.vec.sub(p, near.a), d), near.a[1] + d[1] * SG.vec.dot(SG.vec.sub(p, near.a), d)];
      }

      ui.down(p, ev);
    } else {
      if (tool === "light" || tool === "points") {
        if (Math.abs(normal[2] || 0) < 0.5) p = [p[0] + normal[0] * 0.3, p[1] + normal[1] * 0.3];
      }

      ui.down(p, ev);
      ui.up(p, ev);
    }

    SHELL.dirty = true;
  },
  bulgeTo: function (p) {
    const bulge = SHELL.draft.bulge;
    const chord = SG.vec.sub(bulge.b, bulge.a);
    const l = SG.vec.len(chord);
    const n = SG.vec.left(SG.vec.norm(chord));
    const m = SG.vec.mul(SG.vec.add(bulge.a, bulge.b), 0.5);
    const raw = SG.vec.dot(SG.vec.sub(p, m), n);
    const snapStep = l / 20;
    let bend = Math.max(-l / 2, Math.min(l / 2, Math.round(raw / snapStep) * snapStep));

    if (Math.abs(Math.abs(bend) - l / 2) < snapStep * 1.5) bend = bend > 0 ? l / 2 : -l / 2;

    bulge.bend = Math.abs(bend) < 0.05 ? 0 : bend;
    SHELL.dirty = true;
  },
  roomWalls: function (a, b) {
    const shape = SHELL.roomShape || "rect";

    if (shape === "rect") {
      if (Math.abs(b[0] - a[0]) < 0.8 || Math.abs(b[1] - a[1]) < 0.8) return [];

      const x0 = Math.min(a[0], b[0]);
      const y0 = Math.min(a[1], b[1]);
      const x1 = Math.max(a[0], b[0]);
      const y1 = Math.max(a[1], b[1]);

      return [{ a: [x0, y0], b: [x1, y0] }, { a: [x1, y0], b: [x1, y1] }, { a: [x1, y1], b: [x0, y1] }, { a: [x0, y1], b: [x0, y0] }];
    }

    const rx = shape === "round" ? SG.vec.len(SG.vec.sub(b, a)) : Math.abs(b[0] - a[0]);
    const ry = shape === "round" ? rx : Math.abs(b[1] - a[1]);

    if (rx < 0.9 || ry < 0.9) return [];

    const r = function (v) { return SG.round(v, 3); };
    const pts = [[a[0] + rx, a[1]], [a[0], a[1] + ry], [a[0] - rx, a[1]], [a[0], a[1] - ry]].map(function (q) { return [r(q[0]), r(q[1])]; });
    const out = [];

    for (let i = 0; i < 4; i++) {
      const p0 = pts[i];
      const p1 = pts[(i + 1) % 4];
      const l = SG.vec.len(SG.vec.sub(p1, p0));
      const rr = shape === "round" ? rx : Math.sqrt((rx * rx + ry * ry) / 2);
      const sag = shape === "round" ? rx * (1 - Math.SQRT1_2) : Math.max(0.05, Math.min(l / 2 - 0.01, rr - Math.sqrt(Math.max(0, rr * rr - l * l / 4))));

      out.push({ a: p0, b: p1, bend: -SG.round(sag, 3) });
    }

    return out;
  },
  releaseWall: function (p, event) {
    const press = SHELL.wallPress;

    SHELL.wallPress = null;

    if (!press || !SHELL.draft || SHELL.draft.kind !== "walls" || SHELL.draft.bulge) return;

    const pts = SHELL.draft.points;
    const last = pts[pts.length - 1];
    const end = SHELL_UI.snap(p, last, event && event.shiftKey).p;

    if (SG.vec.len(SG.vec.sub(end, press.at)) < 0.3 || SG.vec.len(SG.vec.sub(end, last)) < 0.3) return;

    pts.push(end);
    SHELL.draft.bends.push(0);
    SHELL_SFX.play("corner");
    SHELL_UI.finishWalls();
  },
  cancelAction: function () {
    if (SHELL.drag) return true;

    if (SHELL.copyRoom) {
      SHELL.copyRoom = null;
      SHELL.copyAt = null;
      toolAction("preview", { pieces: [] });
      SHELL.dirty = true;
      return true;
    }

    if (SHELL.draft) {
      if (SHELL.draft.kind === "walls" && SHELL.draft.points.length > 1) SHELL_UI.finishWalls();
      SHELL.draft = null;
      SHELL.wallPress = null;
      SHELL.measure = null;
      SHELL.previewKey = "";
      toolAction("preview", { pieces: [] });
      SHELL.dirty = true;
      return true;
    }

    if (SHELL.ghostModel) {
      SHELL_UI.setGhost(null);
      return true;
    }

    if (SHELL.sel) {
      SHELL_UI.select(null);
      return true;
    }

    if (SHELL.tool !== "select") {
      SHELL_UI.setTool("select");
      return true;
    }

    return false;
  },
  finishWalls: function () {
    const d = SHELL.draft;

    SHELL.draft = null;

    if (!d || d.points.length < 2) {
      SHELL.dirty = true;
      return;
    }

    const segments = [];

    for (let i = 1; i < d.points.length; i++) segments.push({ a: d.points[i - 1], b: d.points[i], bend: (d.bends || [])[i - 1] || 0 });

    SHELL_UI.addWalls(segments);
  },
  nearestWall: function (p, limit) {
    let best = null;

    SHELL_UI.wallsOnLevel().forEach(function (wall) {
      const pts = SG.wallPoints(wall);

      for (let i = 1; i < pts.length; i++) {
        const a = pts[i - 1];
        const b = pts[i];
        const ab = SG.vec.sub(b, a);
        const len2 = SG.vec.dot(ab, ab) || 1e-9;
        const t = Math.max(0, Math.min(1, SG.vec.dot(SG.vec.sub(p, a), ab) / len2));
        const q = [a[0] + ab[0] * t, a[1] + ab[1] * t];
        const d = SG.vec.len(SG.vec.sub(p, q));

        if (d <= limit && (!best || d < best.d)) best = { wall: wall, a: a, b: b, d: d };
      }
    });

    return best;
  },
  paintTiles: function (p, erase, levelId) {
    const room = shellRoomAt(p, levelId ? shellRoomsOnLevel(levelId) : null);

    if (!room) return false;

    const f = SG.tileFrame(room, true);
    const ci = Math.floor((SG.vec.dot(p, f.ax) - f.minx) / f.size + 1e-6);
    const cj = Math.floor((SG.vec.dot(p, f.ay) - f.miny) / f.size + 1e-6);
    const brush = SHELL.paint.brush || 2;
    const i0 = Math.floor(ci / brush) * brush;
    const j0 = Math.floor(cj / brush) * brush;
    const record = SG.clone(room.record);
    const tiles = Object.assign({}, SG.alignTiles(room));
    let changed = record.tileGrid !== 1 && !!(record.tiles && Object.keys(record.tiles).length);

    record.tileGrid = 1;
    const material = SHELL.paint.material;

    for (let i = i0; i < i0 + brush; i++) {
      for (let j = j0; j < j0 + brush; j++) {
        const key = i + "," + j;

        if (erase || material === (record.floor || "oak")) {
          if (tiles[key] !== undefined) { delete tiles[key]; changed = true; }
        } else if (tiles[key] !== material) {
          tiles[key] = material;
          changed = true;
        }
      }
    }

    if (!changed) return true;

    if (Object.keys(tiles).length) record.tiles = tiles;
    else delete record.tiles;

    const patch = { set: { rooms: [record] } };
    const stroke = SHELL.draft && SHELL.draft.kind === "tiles" ? SHELL.draft : null;
    const last = SHELL.undo[SHELL.undo.length - 1];

    if (stroke && stroke.room === record.id && last && last.stroke === stroke) {
      last.patch = SG.clone(patch);
      shellCommit(patch, { history: true });
    } else {
      shellCommit(patch);

      if (stroke) {
        stroke.room = record.id;
        SHELL.undo[SHELL.undo.length - 1].stroke = stroke;
      }
    }

    return true;
  },
  tileHover: function (p, levelId) {
    const room = shellRoomAt(p, levelId ? shellRoomsOnLevel(levelId) : null);

    if (!room) return null;

    const f = SG.tileFrame(room, true);
    const ci = Math.floor((SG.vec.dot(p, f.ax) - f.minx) / f.size + 1e-6);
    const cj = Math.floor((SG.vec.dot(p, f.ay) - f.miny) / f.size + 1e-6);
    const brush = SHELL.paint.brush || 2;
    const i0 = Math.floor(ci / brush) * brush;
    const j0 = Math.floor(cj / brush) * brush;
    const raw = SG.tileFrame(room, false);
    const x0 = Math.max(raw.minx, f.minx + i0 * f.size);
    const y0 = Math.max(raw.miny, f.miny + j0 * f.size);
    const x1 = Math.min(f.maxx, f.minx + (i0 + brush) * f.size);
    const y1 = Math.min(f.maxy, f.miny + (j0 + brush) * f.size);
    const corner = function (x, y) { return SG.vec.add(SG.vec.mul(f.ax, x), SG.vec.mul(f.ay, y)); };

    return { room: room, points: [corner(x0, y0), corner(x1, y0), corner(x1, y1), corner(x0, y1)] };
  },
  hammerHit: function (p3, normal, clicked) {
    let sel = SHELL_UI.pick3d(p3, normal);

    if (!sel && clicked && clicked.rayKind && ["wall", "stairs", "prop", "pool", "detail"].indexOf(clicked.rayKind) >= 0) sel = { kind: clicked.rayKind, id: clicked.rayId };

    if (sel) {
      SHELL_UI.select(sel);
      SHELL_UI.deleteSelection();
      return;
    }

    showNotify({ title: T("notify_title"), text: T("sh_hammer_nothing"), type: "info", timeout: 1500 });
    SHELL_SFX.play("error");
  },
  pick3d: function (p3, normal) {
    const ui = SHELL_UI;
    const D = SHELL.built.derived;
    const flat = Math.abs(normal[2] || 0) >= 0.5;
    const q = flat ? [p3[0], p3[1]] : [p3[0] - normal[0] * 0.04, p3[1] - normal[1] * 0.04];
    const z = p3[2] - (flat ? (normal[2] > 0 ? 0.02 : -0.02) : 0);
    const levels = shellLevels();
    const lv = levels.slice().reverse().find(function (l) { return z >= (Number(l.z) || 0) - 0.3; }) || levels[0];
    const lz = Number(lv.z) || 0;
    const top = lz + (Number(lv.height) || 2.8) + 0.3;
    const done = function (sel) { return sel; };

    for (const prop of (SHELL.doc.props || []).slice().reverse()) {
      if (!prop.p) continue;

      const dims = SHELL.dims[prop.model] || { w: 0.6, d: 0.6, h: 1.2 };
      const h = ((prop.r && prop.r[2]) || 0) * Math.PI / 180;
      const rel = SG.vec.sub(q, prop.p);
      const x = rel[0] * Math.cos(h) + rel[1] * Math.sin(h);
      const y = -rel[0] * Math.sin(h) + rel[1] * Math.cos(h);

      if (Math.abs(x) <= (dims.w || 0.6) / 2 + 0.08 && Math.abs(y) <= (dims.d || 0.6) / 2 + 0.08 && z >= prop.p[2] - 0.15 && z <= prop.p[2] + (dims.h || 1.5) + 0.15) return done({ kind: "prop", id: prop.id });
    }

    for (const det of D.details || []) {
      const z0 = (Number(det.z) || 0) + (Number(det.lift) || 0) - 0.08;
      const z1 = det.kind === "elevator" ? Math.max.apply(null, levels.map(function (l) { return (Number(l.z) || 0) + (Number(l.height) || 2.8); })) : det.h === 0 ? (Number(det.z) || 0) + (Number(det.height) || 2.8) : z0 + (Number(det.h) || 0) + 0.4;

      if (z < z0 || z > z1) continue;
      if (SG.insidePolygon(q, det.points) || SG.vec.len(SG.vec.sub(q, det.at)) < 0.25) return done({ kind: "detail", id: det.id });
    }

    for (const st of D.stairs || []) {
      if (z < st.z - 0.2 || z > st.z + st.rise + 1.2) continue;
      if ((st.footprint || []).some(function (poly) { return SG.insidePolygon(q, poly); })) return done({ kind: "stairs", id: st.id });
    }

    for (const pool of D.pools || []) {
      if (z < pool.z - (Number(pool.depth) || 1.5) - 0.4 || z > pool.z + 0.4) continue;
      const rel = SG.vec.sub(q, pool.at);

      if (Math.abs(SG.vec.dot(rel, pool.ax)) <= pool.w / 2 + 0.36 && Math.abs(SG.vec.dot(rel, pool.ay)) <= pool.l / 2 + 0.36) return done({ kind: "pool", id: pool.id });
    }

    for (const light of SHELL.doc.lights || []) {
      if (light.p && Math.hypot(light.p[0] - p3[0], light.p[1] - p3[1], light.p[2] - p3[2]) < 0.45) return done({ kind: "light", id: light.id });
    }

    for (const o of D.openings || []) {
      if (o.level !== lv.id) continue;

      const rel = SG.vec.sub(q, o.c);

      if (Math.abs(SG.vec.dot(rel, o.d)) <= o.width / 2 + 0.05 && Math.abs(SG.vec.dot(rel, o.n)) <= o.depth / 2 + 0.12 && z >= lz + o.z0 - 0.1 && z <= lz + o.z1 + 0.15) return done({ kind: "opening", id: o.id });
    }

    if (!flat && z <= top) {
      let best = null;

      (SHELL.doc.walls || []).forEach(function (wall) {
        if (wall.level !== lv.id) return;

        const d = ui.distanceToWall(q, wall);

        if (d.distance <= Math.max(0.08, Number(wall.thick) || SHELL.thick || 0.2) / 2 + 0.08 && (!best || d.distance < best.distance)) best = { id: wall.id, distance: d.distance };
      });

      if (best) return done({ kind: "wall", id: best.id });
    }

    return null;
  },
  hammerAt: function (p, onWall) {
    const ui = SHELL_UI;
    let hit = ui.hit(p);

    if (hit && hit.kind === "dethandle") hit = { kind: "detail", id: hit.id };

    if (!onWall && hit && (hit.kind === "wall" || hit.kind === "handle" || hit.kind === "bend")) {
      const others = ["detail", "stairs", "pool", "prop", "light"];
      const keep = hit;

      hit = null;

      for (const det of SHELL.built.derived.details || []) {
        if (det.level === SHELL.level && SG.insidePolygon(p, det.points)) { hit = { kind: "detail", id: det.id }; break; }
      }

      if (!hit && others.indexOf(keep.kind) >= 0) hit = keep;
    }

    if (!hit || hit.kind === "room" || hit.kind === "handle" || hit.kind === "bend") {
      showNotify({ title: T("notify_title"), text: T("sh_hammer_nothing"), type: "info", timeout: 1500 });
      SHELL_SFX.play("error");
      return;
    }

    ui.select(hit.kind === "point" ? { kind: "point", name: hit.name, index: hit.index } : { kind: hit.kind, id: hit.id });
    ui.deleteSelection();
  },
  autoTarget: function (p, normal) {
    if (normal && Math.abs(normal[2] || 0) >= 0.5) return normal[2] > 0 ? "floor" : "ceiling";
    if (normal) return "side";

    return SHELL_UI.nearestWall(p, 0.22) ? "side" : "floor";
  },
  pickPaint: function (p, normal) {
    const ui = SHELL_UI;
    const target = ui.autoTarget(p, normal);
    let key = "";

    if (target === "side") {
      const near = ui.nearestWall(p, 0.6);

      if (near) {
        const probe = normal ? [p[0] + normal[0] * 0.3, p[1] + normal[1] * 0.3] : p;
        const side = SG.vec.cross(SG.vec.sub(near.b, near.a), SG.vec.sub(probe, near.a)) >= 0 ? "ml" : "mr";
        const room = shellRoomAt(probe);

        key = near.wall[side] || (room && room.record && room.record.walls) || "";
      }
    } else {
      const q = normal && Math.abs(normal[2] || 0) < 0.5 ? [p[0] + normal[0] * 0.3, p[1] + normal[1] * 0.3] : p;
      const room = shellRoomAt(q);

      key = (room && room.record && room.record[target]) || "";
    }

    if (!key || !(SHELL.kit.all || []).some(function (m) { return m.key === key; }) && !/^s[1-6]$/.test(key)) {
      showNotify({ title: T("notify_title"), text: T("sh_paint_pick_none"), type: "info", timeout: 2000 });
      SHELL_SFX.play("error");
      return;
    }

    SHELL.paint.material = key;
    showNotify({ title: T("notify_title"), text: T("sh_paint_picked", shellMaterialName(key)), type: "success", timeout: 1800 });
    SHELL_SFX.play("pick");
    ui.drawSide();
  },
  paintPatch: function (p, normal, p3) {
    const ui = SHELL_UI;
    const material = SHELL.paint.material;

    if (material && p3 && ["auto", "walls", "side", "part"].indexOf(SHELL.paint.target) >= 0) {
      const lift = ui.pick3d(p3, normal || [0, 0, 1]);
      const shaft = lift && lift.kind === "detail" ? shellFind("details", lift.id) : null;

      if (shaft && shaft.kind === "elevator") {
        if (shaft.wall === material) return null;

        return { set: { details: [Object.assign(SG.clone(shaft), { wall: material })] } };
      }
    }

    if (material && p3 && SHELL.paint.target === "auto") {
      const picked = ui.pick3d(p3, normal || [0, 0, 1]);
      const up = normal && (normal[2] || 0) > 0.5;

      if (picked && picked.kind === "detail") {
        const det = SG.clone(shellFind("details", picked.id));
        const derived = (SHELL.built.derived.details || []).find(function (d) { return d.id === picked.id; });

        if (det) {
          const topZ = derived ? (Number(derived.z) || 0) + (Number(derived.lift) || 0) + (Number(derived.h) || 0) : null;
          const ownTop = !!(SG.DETAILS[det.kind] || {}).top;
          const key = ownTop && up && (topZ === null || Math.abs(p3[2] - topZ) < 0.12) ? "top" : "mat";

          if (det[key] === material && (ownTop || !det.top)) return null;

          det[key] = material;
          if (!ownTop) delete det.top;
          return { set: { details: [det] } };
        }
      }

      if (picked && picked.kind === "stairs") {
        const st = SG.clone(shellFind("stairs", picked.id));

        if (st && (SHELL.kit.steps || []).some(function (x) { return x.material === material; }) && st.material !== material) {
          st.material = material;
          return { set: { stairs: [st] } };
        }

        if (st) return null;
      }

      if (picked && picked.kind === "pool") {
        const pool = SG.clone(shellFind("pools", picked.id));
        const derived = (SHELL.built.derived.pools || []).find(function (d) { return d.id === picked.id; });

        if (pool) {
          const key = up && derived && Math.abs(p3[2] - derived.z) < 0.1 ? "edge" : "tile";

          if (pool[key] === material) return null;

          pool[key] = material;
          return { set: { pools: [pool] } };
        }
      }
    }

    const target = SHELL.paint.target === "auto" ? ui.autoTarget(p, normal) : SHELL.paint.target;

    if (!material || target === "part" || target === "tiles") return null;

    if (target === "side") {
      const near = ui.nearestWall(p, 0.6);

      if (!near) return null;

      const wall = SG.clone(near.wall);
      const probe = normal ? [p[0] + normal[0] * 0.3, p[1] + normal[1] * 0.3] : p;
      const side = SG.vec.cross(SG.vec.sub(near.b, near.a), SG.vec.sub(probe, near.a)) >= 0 ? "ml" : "mr";

      if (wall[side] === material) return null;

      wall[side] = material;
      return { set: { walls: [wall] } };
    }

    if (normal && Math.abs(normal[2] || 0) < 0.5) p = [p[0] + normal[0] * 0.3, p[1] + normal[1] * 0.3];

    const room = shellRoomAt(p);

    if (!room) return null;

    const record = SG.clone(room.record);

    if (record[target] === material) return null;

    record[target] = material;
    return { set: { rooms: [record] } };
  },
  paintAt: function (p, normal, p3) {
    const patch = SHELL_UI.paintPatch(p, normal, p3);

    SHELL.paintPreviewKey = "";
    clearTimeout(SHELL.paintPreviewTimer);

    if (patch) shellCommit(patch);
  },
  previewWorker: function () {
    if (SHELL.previewWorker === false) return null;
    if (SHELL.previewWorker) return SHELL.previewWorker;

    try {
      const worker = new Worker("shellpreview.js");

      worker.onmessage = function (event) {
        const data = event.data || {};

        if (!data.ok || data.id !== SHELL.paintPreviewId || !SHELL.paintPreviewKey || SHELL.tool !== "paint" || !SHELL.open) return;

        SHELL.paintPreviewShown = true;
        toolAction("local", { pieces: data.pieces, doors: data.doors, lamps: data.lamps, ladders: data.ladders, elevators: data.elevators, slots: data.slots, colours: SHELL.doc.colours || {}, customs: SHELL.doc.customs || {}, props: SHELL.doc.props || [] });
      };
      worker.onerror = function () { SHELL.previewWorker = false; };
      worker.postMessage({ kit: SHELL.kit });
      SHELL.previewWorker = worker;
      return worker;
    } catch (err) {
      SHELL.previewWorker = false;
      return null;
    }
  },
  paintPreview: function (patch) {
    const key = patch ? JSON.stringify(patch) : "";

    if (key === SHELL.paintPreviewKey) return;

    SHELL.paintPreviewKey = key;
    SHELL.paintPreviewPatch = patch;
    clearTimeout(SHELL.paintPreviewTimer);

    if (!patch) {
      if (SHELL.paintPreviewShown) {
        SHELL.paintPreviewShown = false;
        shellLocalApply();
      }
      return;
    }

    SHELL.paintPreviewTimer = setTimeout(function () {
      const worker = SHELL_UI.previewWorker();

      if (!worker || SHELL.paintPreviewKey !== key) return;

      const doc = SG.clone(SHELL.doc);

      SG.apply(doc, patch);
      SHELL.paintPreviewId = (SHELL.paintPreviewId || 0) + 1;
      worker.postMessage({ id: SHELL.paintPreviewId, doc: doc });
    }, 140);
  },
  deleteSelection: function () {
    const sel = SHELL.sel;

    if (!sel) return;

    if (sel.kind === "wall") {
      const openings = (SHELL.doc.openings || []).filter(function (o) { return o.wall === sel.id; }).map(function (o) { return o.id; });

      shellCommit({ del: { walls: [sel.id], openings: openings } });
    } else if (sel.kind === "opening") {
      shellCommit({ del: { openings: [sel.id] } });
    } else if (sel.kind === "stairs") {
      shellCommit({ del: { stairs: [sel.id] } });
    } else if (sel.kind === "pool") {
      shellCommit({ del: { pools: [sel.id] } });
    } else if (sel.kind === "detail") {
      shellCommit({ del: { details: [sel.id] } });
    } else if (sel.kind === "light") {
      shellCommit({ del: { lights: [sel.id] } });
    } else if (sel.kind === "prop") {
      shellCommit({ del: { props: [sel.id] } });
    } else if (sel.kind === "point") {
      const points = {};

      if (sel.index >= 0) {
        const list = SG.clone(SHELL.doc.points[sel.name] || []);

        list.splice(sel.index, 1);
        points[sel.name] = list;
      } else {
        points[sel.name] = null;
      }

      shellCommit({ root: { points: points } });
    } else if (sel.kind === "room") {
      const room = SHELL.built.derived.rooms.find(function (r) { return r.id === sel.id; });

      if (!room) return;

      const walls = room.edges.map(function (e) { return e.wall; });
      const shared = walls.filter(function (id) { return SHELL.built.derived.rooms.some(function (r) { return r !== room && r.edges.some(function (e) { return e.wall === id; }); }); });
      const own = walls.filter(function (id) { return shared.indexOf(id) < 0; });

      if (!own.length) return;

      confirmBox(T("sh_room_delete_title"), T("sh_room_delete_text"), function () {
        shellCommit({ del: { walls: own, openings: (SHELL.doc.openings || []).filter(function (o) { return own.indexOf(o.wall) >= 0; }).map(function (o) { return o.id; }), rooms: [room.id] } });
      }, true);
      return;
    }

    SHELL_UI.select(null);
  },
  turnGhost: function (by) {
    SHELL.ghostTurn = ((Number(SHELL.ghostTurn) || 0) + by) % 360;
    SHELL.ghostHeading = SHELL.ghostTurn;
    toolAction("ghostturn", { by: by });
    SHELL.dirty = true;
  },
  wallSnapSelection: function () {
    const sel = SHELL.sel;

    if (!sel || sel.kind !== "prop") return;

    const prop = shellFind("props", sel.id);

    toolAction("wallsnap", { id: sel.id }).then(function (r) {
      if (r && r.ok) {
        shellCommit({ set: { props: [Object.assign(SG.clone(prop), { p: r.p, r: [0, 0, r.h] })] } });
        return;
      }

      const g = SHELL_UI.ghostPlaceFor(prop);

      if (g) shellCommit({ set: { props: [Object.assign(SG.clone(prop), { p: [SG.round(g.p[0], 3), SG.round(g.p[1], 3), prop.p[2]], r: [0, 0, SG.round(g.h, 1)] })] } });
      else showNotify({ title: T("notify_title"), text: T("sh_prop_no_wall"), type: "info", timeout: 2500 });
    });
  },
  ghostPlaceFor: function (prop) {
    const keep = { model: SHELL.ghostModel, kind: SHELL.ghostKind, turn: SHELL.ghostTurn, snap: SHELL.snapWalls };

    SHELL.ghostModel = prop.model;
    SHELL.ghostKind = shellPlaceKind(prop.model) === "free" ? "back" : shellPlaceKind(prop.model);
    SHELL.ghostTurn = 0;
    SHELL.snapWalls = true;

    const g = SHELL_UI.ghostPlace(prop.p);

    SHELL.ghostModel = keep.model;
    SHELL.ghostKind = keep.kind;
    SHELL.ghostTurn = keep.turn;
    SHELL.snapWalls = keep.snap;

    return g.snapped ? g : null;
  },
  rotateSelection: function (by) {
    const sel = SHELL.sel;

    if (!sel) return;

    if (sel.kind === "stairs" || sel.kind === "pool" || sel.kind === "detail") {
      const coll = sel.kind === "pool" ? "pools" : sel.kind === "detail" ? "details" : "stairs";
      const s = SG.clone(shellFind(coll, sel.id));
      const patch = { set: {} };

      s.heading = ((Number(s.heading) || 0) + by) % 360;
      patch.set[coll] = [s];
      shellCommit(patch);
      SHELL_UI.select(sel);
    } else if (sel.kind === "prop") {
      const prop = SG.clone(shellFind("props", sel.id));

      prop.r = prop.r || [0, 0, 0];
      prop.r[2] = SG.round(((prop.r[2] + by) % 360 + 360) % 360, 1);
      shellCommit({ set: { props: [prop] } });
    } else if (sel.kind === "point") {
      const points = {};

      if (sel.index >= 0) {
        const list = SG.clone(SHELL.doc.points[sel.name]);

        list[sel.index].h = ((list[sel.index].h || 0) + by) % 360;
        points[sel.name] = list;
      } else {
        points[sel.name] = Object.assign(SG.clone(SHELL.doc.points[sel.name]), { h: ((SHELL.doc.points[sel.name].h || 0) + by) % 360 });
      }

      shellCommit({ root: { points: points } });
    } else if (sel.kind === "opening") {
      const o = SG.clone(shellFind("openings", sel.id));

      o.flip = !o.flip;
      shellCommit({ set: { openings: [o] } });
    }
  },
  duplicate: function () {
    const sel = SHELL.sel;

    if (!sel) return;

    if (sel.kind === "prop" || sel.kind === "light") {
      const coll = sel.kind === "prop" ? "props" : "lights";
      const item = SG.clone(shellFind(coll, sel.id));

      item.id = SG.uid(sel.kind === "prop" ? "p" : "li");
      item.p = [SG.round(item.p[0] + 0.5, 3), SG.round(item.p[1] + 0.5, 3), item.p[2]];

      const patch = { set: {} };

      patch.set[coll] = [item];
      shellCommit(patch);
      SHELL_UI.select({ kind: sel.kind, id: item.id });
    } else if (sel.kind === "stairs" || sel.kind === "pool" || sel.kind === "detail") {
      const coll = sel.kind === "pool" ? "pools" : sel.kind === "detail" ? "details" : "stairs";
      const item = SG.clone(shellFind(coll, sel.id));

      if (!item || !Array.isArray(item.at)) return;

      const h = (Number(item.heading) || 0) * Math.PI / 180;
      const step = sel.kind === "pool" ? (Number(item.w) || 4) + 1 : sel.kind === "stairs" ? (Number(item.width) || 1) + 0.5 : (Number(item.w) || 1) + 0.1;

      item.id = SG.uid(sel.kind === "pool" ? "pl" : sel.kind === "detail" ? "dt" : "st");
      item.at = [SG.round(item.at[0] + Math.cos(h) * step, 3), SG.round(item.at[1] + Math.sin(h) * step, 3)];

      const patch = { set: {} };

      patch.set[coll] = [item];
      shellCommit(patch);
      SHELL_UI.select({ kind: sel.kind, id: item.id });
    }
  }
});

Object.assign(SHELL_UI, {
  palette: function (current, onPick, groups, prefer) {
    const wrap = el("div", "sh-palette");
    const kit = SHELL.kit;
    const order = groups || ["walls", "paint", "floors", "stain", "outside", "ceilings", "other", "colour", "custom"];
    const present = order.filter(function (group) { return kit.all.some(function (m) { return m.group === group; }); });
    const CATS = [
      { id: "walls", groups: ["walls"] },
      { id: "floors", groups: ["floors"] },
      { id: "ceilings", groups: ["ceilings"] },
      { id: "outside", groups: ["outside"] },
      { id: "colours", groups: ["paint", "stain", "colour"] },
      { id: "more", groups: ["other", "custom"] }
    ].map(function (c) { return { id: c.id, groups: c.groups.filter(function (g) { return present.indexOf(g) >= 0; }) }; }).filter(function (c) { return c.groups.length; });
    const state = SHELL.palState = SHELL.palState || { cat: null, q: "", prefer: null, recent: [] };
    const catOf = function (id) { return CATS.find(function (c) { return c.id === id; }) || null; };

    if (state.prefer !== (prefer || null)) {
      state.prefer = prefer || null;
      state.cat = prefer && catOf(prefer) ? prefer : null;
    }

    if (state.cat && !catOf(state.cat)) state.cat = null;

    const nameOf = function (m) { return shellMaterialName(m.key); };
    const groupName = function (g) { return T(g === "custom" ? "sh_pal_custom" : "sh_group_" + g); };
    const card = el("div", "sh-pal-current");
    const drawCard = function (key) {
      const m = kit.all.find(function (x) { return x.key === key; });

      card.empty().append(shellSwatch(key, "mid"), el("div", "sh-pal-current-text").append(el("div", "sh-pal-current-name", m ? nameOf(m) : T("sh_none")), el("div", "sh-pal-current-group", m ? groupName(m.group) : "")));
    };
    const search = $('<input type="text" class="sh-pal-search"/>').attr("placeholder", T("sh_pal_search")).val(state.q || "");
    const searchWrap = el("label", "sh-pal-searchwrap").append(icon("fa-magnifying-glass"), search);
    const cats = el("div", "sh-pal-cats");
    const grid = el("div", "sh-pal-body");
    const libOf = function () { return (SHELL.customLib || []).map(function (x) { return { key: "lib:" + x.file, group: "custom", file: x.file, name: x.name }; }); };
    const isActive = function (m) { return m.file ? /^c[1-6]$/.test(String(current)) && shellCustomFile(current) === m.file : m.key === current; };
    const pick = function (m) {
      const shown = m.key;

      if (m.file) {
        const slot = shellCustomAssign(m.file);

        if (!slot) {
          showNotify({ title: T("notify_title"), text: T("sh_custom_full"), type: "error" });
          return;
        }

        m = kit.all.find(function (x) { return x.key === slot; }) || { key: slot, group: "custom" };
      }

      current = m.key;
      wrap.find(".sh-mat").removeClass("active");
      wrap.find('.sh-mat[data-key="' + shown + '"]').addClass("active");
      state.recent = [shown].concat((state.recent || []).filter(function (k) { return k !== shown; })).slice(0, 9);
      drawCard(m.key);
      onPick(m.key);
    };
    const chipOf = function (m, named) {
      const chip = el("button", "sh-mat" + (named ? " named" : "") + (isActive(m) ? " active" : "")).attr("data-key", m.key).attr("title", m.file ? m.name : nameOf(m)).append(shellSwatch(m.key, "big"));

      if (named) chip.append(el("span", "sh-mat-name", m.file ? m.name : nameOf(m)));
      chip.on("click", function () { pick(m); });

      return chip;
    };
    const compact = function (group) { return group === "paint" || group === "stain" || group === "colour"; };
    const section = function (group, named) {
      if (group === "custom") {
        const lib = libOf();
        const used = Object.keys(shellCustomUsed()).length;
        const label = el("div", "sh-palette-label", groupName(group) + (lib.length ? "  ·  " + T("sh_custom_count", used) : ""));

        if (!SHELL.customLib) {
          shellCustomLibrary().then(function () { if (wrap.closest("body").length) drawGrid(); });
          return [label, el("div", "tk-hint sh-pal-empty", "…")];
        }

        if (!lib.length) return [label, el("div", "tk-hint sh-pal-empty", T("sh_custom_empty"))];

        return [label, el("div", "sh-pal-grid" + (named ? " named" : "")).append(lib.map(function (m) { return chipOf(m, named); }))];
      }

      const list = kit.all.filter(function (m) { return m.group === group; });

      return [el("div", "sh-palette-label", groupName(group)), el("div", "sh-pal-grid" + (named ? " named" : "")).append(list.map(function (m) { return chipOf(m, named); }))];
    };
    const drawGrid = function () {
      const q = String(state.q || "").trim().toLowerCase();

      grid.empty();
      cats.find(".sh-pal-cat").each(function () { $(this).toggleClass("active", ($(this).attr("data-cat") || null) === (state.cat || null)); });

      if (q) {
        const found = kit.all.filter(function (m) { return m.group !== "custom" && present.indexOf(m.group) >= 0 && (nameOf(m).toLowerCase().indexOf(q) >= 0 || groupName(m.group).toLowerCase().indexOf(q) >= 0); }).concat(present.indexOf("custom") >= 0 ? libOf().filter(function (m) { return m.name.toLowerCase().indexOf(q) >= 0 || groupName("custom").toLowerCase().indexOf(q) >= 0; }) : []);

        if (!found.length) grid.append(el("div", "tk-hint sh-pal-empty", T("sh_pal_nothing")));
        else grid.append(el("div", "sh-pal-grid named").append(found.slice(0, 60).map(function (m) { return chipOf(m, true); })));

        return;
      }

      if (!state.cat) {
        const recent = (state.recent || []).map(function (k) { return /^lib:/.test(k) ? libOf().find(function (m) { return m.key === k; }) : kit.all.find(function (m) { return m.key === k && m.group !== "custom" && present.indexOf(m.group) >= 0; }); }).filter(Boolean);

        if (recent.length) grid.append(el("div", "sh-palette-label", T("sh_pal_recent")), el("div", "sh-pal-grid").append(recent.map(function (m) { return chipOf(m, false); })));
        present.forEach(function (group) { grid.append(section(group, false)); });

        return;
      }

      catOf(state.cat).groups.forEach(function (group) { grid.append(section(group, !compact(group))); });
    };

    cats.append(el("button", "sh-pal-cat", T("sh_pal_all")).attr("data-cat", "").on("click", function () { state.cat = null; drawGrid(); }));
    CATS.forEach(function (c) {
      cats.append(el("button", "sh-pal-cat", T("sh_pal_cat_" + c.id)).attr("data-cat", c.id).on("click", function () { state.cat = c.id; drawGrid(); }));
    });
    search.on("input", function () { state.q = search.val(); drawGrid(); });
    search.on("keydown", function (e) { e.stopPropagation(); if (e.key === "Escape") { state.q = ""; search.val(""); drawGrid(); search.blur(); } });

    drawCard(current);
    wrap.append(card, el("div", "sh-pal-tools").append(searchWrap), cats, grid);
    drawGrid();

    return wrap;
  },
  colourSlots: function () {
    const wrap = el("div", "sh-slots");
    const colours = SHELL.doc.colours || {};

    ["s1", "s2", "s3", "s4", "s5", "s6"].forEach(function (slot) {
      const picker = $('<input type="color" class="sh-slot-picker"/>').val(colours[slot] || "#cccccc");

      picker.on("change", function () {
        const value = {};

        value[slot] = picker.val();
        shellCommit({ root: { colours: value } });
      });
      wrap.append(el("label", "sh-slot").append(picker, el("span", "", T("sh_colour_slot", slot.slice(1)))));
    });

    return wrap;
  },
  drawSide: function () {
    const ui = SHELL_UI;

    if (!ui.side) return;

    const side = ui.side.empty();
    const body = el("div", "sh-side-body");
    const tabs = el("div", "sh-side-tabs");

    const sel = SHELL.sel;

    side.toggleClass("sh-side-focus", !!sel);
    side.append(body);

    if (sel) {
      ui.selectionPanel(body, sel);
      return;
    }

    side.append(tabs);
    ui.toolPanel(body);

    [["rooms", "fa-layer-group"], ["checks", "fa-list-check"], ["revisions", "fa-clock-rotate-left"], ["house", "fa-sliders"], ["team", "fa-user-group"]].forEach(function (pair) {
      const tab = el("button", "sh-side-tab" + (SHELL.panel === pair[0] ? " active" : "")).append(icon(pair[1]), el("span", "", T("sh_panel_" + pair[0])));

      if (pair[0] === "checks" && SHELL.checks.length) tab.append(el("b", "sh-count", SHELL.checks.filter(function (c) { return c.level !== "info"; }).length || ""));

      tab.on("click", function () {
        SHELL.panel = SHELL.panel === pair[0] ? "" : pair[0];
        ui.drawSide();
      });
      tabs.append(tab);
    });

    if (SHELL.panel) {
      const panel = el("div", "sh-side-panel");

      side.append(panel);

      if (typeof ui["panel_" + SHELL.panel] === "function") ui["panel_" + SHELL.panel](panel);
      else SHELL.panel = "";
    }
  },
  toolPanel: function (body) {
    const ui = SHELL_UI;
    const tool = SHELL.tool;
    const head = el("div", "sh-side-head").append(el("div", "tk-kicker accent", T("sh_tool")), el("div", "sh-side-title", T("sh_tool_" + tool)), el("div", "tk-hint", T("sh_tool_" + tool + "_text")));

    body.append(head);

    if (tool === "walls" || tool === "room") {
      if (tool === "walls") body.append(field(T("sh_wall_shape"), segment([{ value: "straight", label: T("sh_wall_straight"), icon: "fa-minus" }, { value: "curve", label: T("sh_wall_curve"), icon: "fa-bezier-curve" }], SHELL.wallShape || "straight", function (v) { SHELL.wallShape = v; SHELL.draft = null; ui.drawSide(); }, true), T(SHELL.wallShape === "curve" ? "sh_wall_curve_hint" : "sh_wall_straight_hint")));
      if (tool === "room") body.append(field(T("sh_room_shape"), segment([{ value: "rect", label: T("sh_room_rect"), icon: "fa-square" }, { value: "round", label: T("sh_room_round"), icon: "fa-circle" }, { value: "oval", label: T("sh_room_oval"), icon: "fa-egg" }], SHELL.roomShape || "rect", function (v) { SHELL.roomShape = v; ui.drawSide(); }, true), T("sh_room_shape_" + (SHELL.roomShape || "rect") + "_hint")));
      if (tool === "room") body.append(field(T("sh_room_build"), segment([{ value: "walls", label: T("sh_room_walls"), icon: "fa-border-all" }, { value: "floor", label: T("sh_room_floor_only"), icon: "fa-square-full" }], SHELL.roomFloorOnly ? "floor" : "walls", function (v) { SHELL.roomFloorOnly = v === "floor"; ui.drawSide(); }, true), T(SHELL.roomFloorOnly ? "sh_room_floor_only_hint" : "sh_room_walls_hint")));
      body.append(
        field(T("sh_thickness"), segment([0.1, 0.15, 0.2, 0.3].map(function (v) { return { value: v, label: fmt(v * 100, 0) + " cm" }; }), SHELL.thick, function (v) { SHELL.thick = Number(v); }, true)),
        field(T("sh_grid"), segment([0.05, 0.1, 0.25, 0.5].map(function (v) { return { value: v, label: fmt(v * 100, 0) + " cm" }; }), Number(SHELL.doc.settings.grid) || 0.25, function (v) { shellCommit({ root: { settings: { grid: Number(v) } } }); }, true))
      );
    } else if (tool === "opening") {
      ["doors", "windows", "openings"].forEach(function (group) {
        const kinds = el("div", "sh-kinds sh-kinds-3");

        SHELL_OPENINGS.filter(function (kind) { return kind.group === group; }).forEach(function (kind) {
          const chip = el("button", "sh-kind" + (SHELL.sub === kind.id ? " active" : "")).append(icon(kind.icon), el("span", "", T("sh_opening_" + kind.id)));

          chip.on("click", function () {
            SHELL.sub = kind.id;
            body.find(".sh-kind").removeClass("active");
            chip.addClass("active");
            hintText.text(T("sh_opening_" + kind.id + "_text"));
          });
          kinds.append(chip);
        });
        body.append(el("div", "sh-palette-label", T("sh_opening_group_" + group)), kinds);
      });

      const hintText = el("div", "tk-hint", T("sh_opening_" + SHELL.sub + "_text"));

      body.append(hintText);
    } else if (tool === "paint") {
      const targets = el("div", "sh-kinds sh-kinds-3");

      [["auto", "fa-wand-magic-sparkles"], ["floor", "fa-border-none"], ["walls", "fa-border-all"], ["ceiling", "fa-arrow-up"], ["side", "fa-grip-lines-vertical"], ["part", "fa-paint-roller"], ["tiles", "fa-chess-board"]].forEach(function (pair) {
        const chip = el("button", "sh-kind" + (SHELL.paint.target === pair[0] ? " active" : "")).append(icon(pair[1]), el("span", "", T("sh_paint_" + pair[0])));

        chip.on("click", function () {
          SHELL.paint.target = pair[0];
          SHELL.draft = null;
          ui.drawSide();
        });
        targets.append(chip);
      });
      body.append(field(T("sh_paint_target"), targets), el("div", "tk-hint", T("sh_paint_" + SHELL.paint.target + "_text")));

      if (SHELL.paint.target === "tiles") {
        body.append(field(T("sh_tiles_brush"), segment([{ value: 1, label: "25 cm" }, { value: 2, label: "50 cm" }, { value: 4, label: "1 m" }], SHELL.paint.brush || 2, function (v) { SHELL.paint.brush = Number(v); }, true)), el("div", "tk-hint", T("sh_tiles_erase_hint")));
      }

      if (SHELL.paint.target === "part") {
        body.append(
          field(T("sh_part_height"), segment([{ value: "lower", label: T("sh_part_lower") }, { value: "upper", label: T("sh_part_upper") }, { value: "full", label: T("sh_part_full") }], SHELL.part.height, function (v) { SHELL.part.height = v; }, true)),
          field(T("sh_part_split"), slider(0.3, 2.4, 0.05, SHELL.part.split, function (v) { SHELL.part.split = v; }, { places: 2 }))
        );
      }

      body.append(
        ui.palette(SHELL.paint.material, function (key) { SHELL.paint.material = key; }, null, { floor: "floors", tiles: "floors", walls: "walls", side: "walls", part: "walls", ceiling: "ceilings" }[SHELL.paint.target] || null),
        group(T("sh_colours"), [ui.colourSlots(), el("div", "tk-hint", T("sh_colours_hint"))])
      );
    } else if (tool === "roof") {
      const lv = shellLevel();
      const tops = shellLevels().filter(function (l) { return (l.z || 0) >= -0.01; });
      const topLevel = tops[tops.length - 1] || lv;
      const roof = Object.assign({ type: "none", pitch: 30, ridge: "auto", outside: "slategrey", inside: "", flip: false, overhang: 0.35 }, SG.clone(lv.roof || {}));
      const save = function () { ui.setRoof(lv, roof); };
      const pick = el("div", "sh-kinds sh-kinds-3");

      SG.ROOF_TYPES.forEach(function (t) {
        pick.append(el("button", "sh-kind" + (roof.type === t ? " active" : "")).append(icon({ none: "fa-square", gable: "fa-house", shed: "fa-house-flag" }[t] || "fa-house"), el("span", "", T("sh_roof_" + t))).on("click", function () { roof.type = t; save(); ui.drawSide(); }));
      });
      body.append(el("div", "sh-palette-label", T("sh_roof_on", lv.name || "")), pick);

      if (lv.id !== topLevel.id) {
        body.append(el("div", "tk-hint", T("sh_roof_not_top")), button(T("sh_roof_top_floor"), "fa-arrow-up", "small", function () { SHELL.level = topLevel.id; SHELL.dirty = true; ui.drawSide(); }));
      }

      if (roof.type !== "none") {
        body.append(
          field(T("sh_roof_pitch"), slider(10, 50, 1, roof.pitch, function (v, final) { if (final) { roof.pitch = Number(v); save(); } }, { places: 0, unit: "°" })),
          field(T("sh_roof_ridge"), segment([{ value: "auto", label: T("sh_roof_ridge_auto") }, { value: "x", label: T("sh_roof_ridge_x") }, { value: "y", label: T("sh_roof_ridge_y") }], roof.ridge, function (v) { roof.ridge = v; save(); }, true)),
          roof.type === "shed" ? switchRow(T("sh_roof_flip"), roof.flip === true, function (on) { roof.flip = on; save(); }) : null,
          field(T("sh_roof_overhang"), slider(0, 1, 0.05, roof.overhang, function (v, final) { if (final) { roof.overhang = Number(v); save(); } }, { places: 2, unit: " m" })),
          field(T("sh_roof_outside"), ui.palette(roof.outside, function (k) { roof.outside = k; save(); })),
          field(T("sh_roof_inside"), segment([{ value: "", label: T("sh_roof_inside_room") }].concat(["white", "teak", "oak", "darkwood", "concpan"].map(function (k) { return { value: k, label: shellMaterialName(k) }; })), roof.inside || "", function (v) { roof.inside = v; save(); }, true))
        );
      }

      body.append(el("div", "tk-hint", T("sh_roof_hint")));
    } else if (tool === "light") {
      body.append(field(T("sh_lamp_shape"), ui.lampPicker(SHELL.lamp, function (v) { SHELL.lamp = v; ui.drawSide(); })), el("div", "tk-hint", T(SHELL.lamp === "sconce" ? "sh_lamp_sconce_hint" : "sh_lamp_ceiling_hint")));
    } else if (tool === "points") {
      const list = el("div", "tk-list sh-points-list");

      SHELL_POINTS.forEach(function (def) {
        const value = SHELL.doc.points && SHELL.doc.points[def.id];
        const count = def.many ? (value || []).length : value ? 1 : 0;
        const row = el("div", "tk-item" + (SHELL.point === def.id ? " active" : "")).append(icon(def.icon), $("<span></span>").text(T("sh_point_" + def.id)), el("span", "tk-item-sub", count ? (def.many ? "× " + count : T("sh_point_set")) : T("sh_point_missing")));

        row.on("click", function () {
          SHELL.point = def.id;
          ui.drawSide();
        });
        list.append(row);
      });
      body.append(list, el("div", "tk-row wrap").append(button(T("sh_point_pick3d"), "fa-crosshairs", "small", function () {
        if (SHELL.mode === "plan") ui.setMode("split");
        toolAction("pick", { kind: "point", name: SHELL.point });
      })), el("div", "tk-hint", T("sh_points_hint")));
    } else if (tool === "furniture") {
      const room = SHELL.sel && SHELL.sel.kind === "room" ? SHELL.sel.id : null;

      body.append(
        SHELL.ghostModel ? el("div", "sh-ghost-wrap").append(
          el("div", "sh-ghost-card").append(
            propImg($("<img/>"), SHELL.ghostModel).on("error", function () { $(this).attr("src", "img/noimage.webp").off("error"); }),
            $("<div></div>").append(el("div", "tk-kicker accent", T("sh_furniture_placing")), el("div", "sh-ghost-name", SHELL.ghostModel), el("div", "tk-hint", T("sh_place_kind_" + (SHELL.ghostKind || "free")))),
            iconButton("fa-xmark", function () { ui.setGhost(null); }, T("cancel"), "small")
          ),
          el("div", "sh-turn-row").append(
            button(T("sh_turn_left"), "fa-rotate-left", "small", function () { ui.turnGhost(-90); }),
            button(T("sh_turn_right"), "fa-rotate-right", "small primary", function () { ui.turnGhost(90); }).append(el("span", "tk-key", "R")),
            button("180°", "fa-repeat", "small", function () { ui.turnGhost(180); })
          ),
          SHELL.ghostKind && SHELL.ghostKind !== "free" ? switchRow(T("sh_snap_walls"), SHELL.snapWalls !== false, function (on) { SHELL.snapWalls = on; toolAction("ghostsnap", { on: on }); SHELL.dirty = true; }, T("sh_snap_walls_hint")) : null
        ) : null,
        propBrowser(function (model) { ui.setGhost(model); }, { catalogue: true, available: true, fill: true, keep: "shell" })
      );
      body.addClass("sh-fill");
      head.find(".tk-hint").attr("title", T(room ? "sh_furniture_hint" : "sh_furnish_pick_room"));
    } else if (tool === "stairs") {
      body.append(ui.stairsOptions(SHELL.stairs, function (values) { Object.assign(SHELL.stairs, values); ui.drawSide(); }, true));
    } else if (tool === "pool") {
      body.append(ui.poolOptions(SHELL.pool, function (values) { Object.assign(SHELL.pool, values); ui.drawSide(); }));
    } else if (tool === "details") {
      body.append(ui.detailOptions(SHELL.details, function (values) {
        if (values.kind && values.kind !== SHELL.details.kind) Object.assign(SHELL.details, { w: null, d: null, h: null, mat: null, top: null });
        Object.assign(SHELL.details, values);
        ui.drawSide();
      }, true));
    } else if (tool === "measure") {
      body.append(el("div", "tk-hint", SHELL.measure && SHELL.measure.b ? T("sh_measure_result", fmt(SG.vec.len(SG.vec.sub(SHELL.measure.b, SHELL.measure.a)), 2)) : T("sh_measure_hint")));
    } else {
      const stats = SHELL.built.stats;

      body.append(el("div", "sh-stats").append(
        el("div", "tk-stat").append(el("b", "", stats.rooms), el("span", "", T("sh_stat_rooms"))),
        el("div", "tk-stat").append(el("b", "", fmt(stats.area, 0)), el("span", "", "m²")),
        el("div", "tk-stat").append(el("b", "", stats.props + " / " + (STATE.setup.budget || 800)), el("span", "", T("sh_stat_props"))),
        el("div", "tk-stat").append(el("b", "", stats.pieces), el("span", "", T("sh_stat_pieces")))
      ), el("div", "tk-hint", T("sh_select_hint")));
    }
  },
  selectionPanel: function (body, sel) {
    const ui = SHELL_UI;
    const head = function (title, sub) {
      body.append(el("div", "sh-side-head").append(
        el("div", "tk-row between").append(el("div", "tk-kicker accent", T("sh_sel_" + sel.kind)), button(T("sh_deselect"), "fa-xmark", "small sh-deselect", function () { ui.select(null); }).attr("title", T("sh_deselect_hint"))),
        el("div", "sh-side-title", title),
        sub ? el("div", "tk-hint", sub) : null
      ));
    };

    if (sel.kind === "wall") {
      const wall = shellFind("walls", sel.id);

      if (!wall) return ui.select(null);

      const length = SG.wallLength(wall);

      head(T("sh_wall_title", fmt(length, 2)));
      body.append(
        field(T("sh_wall_length"), input(fmt(SG.vec.len(SG.vec.sub(wall.b, wall.a)), 2), "", function (value) {
          const l = Number(value);

          if (!(l > 0.1)) return;

          const d = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
          const changed = SG.clone(wall);

          changed.b = SG.vec.add(wall.a, SG.vec.mul(d, l)).map(function (v) { return SG.round(v, 4); });
          shellCommit({ set: { walls: [changed] } });
        }, { small: true })),
        field(T("sh_thickness"), segment([0.1, 0.15, 0.2, 0.3].map(function (v) { return { value: v, label: fmt(v * 100, 0) + " cm" }; }), Number(wall.thick) || SHELL.thick, function (v) { shellCommit({ set: { walls: [Object.assign(SG.clone(wall), { thick: Number(v) })] } }); }, true)),
        field(T("sh_wall_bend"), slider(-3, 3, 0.05, Number(wall.bend) || 0, function (v, final) {
          if (!final) return;
          if ((SHELL.doc.openings || []).some(function (o) { return o.wall === wall.id; }) && Math.abs(v) > 0.02) {
            showNotify({ title: T("notify_title"), text: T("sh_curved_has_openings"), type: "warning" });
            return;
          }
          shellCommit({ set: { walls: [Object.assign(SG.clone(wall), { bend: Math.abs(v) < 0.08 ? 0 : SG.round(v, 3) })] } });
        }, { places: 2 }), T("sh_wall_bend_hint")),
        field(T("sh_skirting"), segment([{ value: "auto", label: T("sh_skirting_auto") }].concat(SHELL_MOULD_MATS.map(function (m) { return { value: m, label: m ? shellMaterialName(m) : T("sh_none") }; })), wall.skirting === undefined || wall.skirting === null ? "auto" : wall.skirting, function (v) {
          const changed = SG.clone(wall);

          if (v === "auto") delete changed.skirting;
          else changed.skirting = v;

          shellCommit({ set: { walls: [changed] } });
        }, true), T("sh_wall_skirting_hint")),
        group(T("sh_wall_sides"), [
          ui.sideRow(wall, "ml", T("sh_wall_left")),
          ui.sideRow(wall, "mr", T("sh_wall_right"))
        ]),
        (wall.paints || []).length ? group(T("sh_wall_parts"), (wall.paints || []).map(function (part, index) {
          return el("div", "tk-item").append(shellSwatch(part.m, "small"), $("<span></span>").text(shellMaterialName(part.m)), el("span", "tk-item-sub", fmt(Math.abs(part.b - part.a), 2) + " m · " + T(part.side === "l" ? "sh_wall_left" : "sh_wall_right")), el("div", "tk-item-end").append(iconButton("fa-trash", function () {
            const changed = SG.clone(wall);

            changed.paints = (changed.paints || []).filter(function (x, i) { return i !== index; });
            shellCommit({ set: { walls: [changed] } });
          }, T("delete"), "small")));
        })) : null,
        el("div", "tk-row wrap").append(
          button(T("sh_wall_split"), "fa-scissors", "small", function () {
            const mid = SG.vec.mul(SG.vec.add(wall.a, wall.b), 0.5).map(function (v) { return SG.round(v, 4); });
            const first = Object.assign(SG.clone(wall), { b: mid, bend: 0 });
            const second = Object.assign(SG.clone(wall), { id: SG.uid("w"), a: mid, bend: 0 });
            const half = SG.vec.len(SG.vec.sub(mid, wall.a));
            const moved = (SHELL.doc.openings || []).filter(function (o) { return o.wall === wall.id && o.t > half; }).map(function (o) { return Object.assign(SG.clone(o), { wall: second.id, t: SG.round(o.t - half, 3) }); });

            shellCommit({ set: { walls: [first, second], openings: moved } });
          }),
          button(T("sh_wall_reverse"), "fa-arrow-right-arrow-left", "small", function () {
            const length2 = SG.vec.len(SG.vec.sub(wall.b, wall.a));
            const changed = Object.assign(SG.clone(wall), { a: wall.b.slice(), b: wall.a.slice(), ml: wall.mr, mr: wall.ml, bend: -(Number(wall.bend) || 0) });
            const moved = (SHELL.doc.openings || []).filter(function (o) { return o.wall === wall.id; }).map(function (o) { return Object.assign(SG.clone(o), { t: SG.round(length2 - o.t, 3) }); });

            shellCommit({ set: { walls: [changed], openings: moved } });
          }),
          button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
        )
      );
    } else if (sel.kind === "opening") {
      const o = shellFind("openings", sel.id);
      const derived = SHELL.built.derived.openings.find(function (x) { return x.id === sel.id; });

      if (!o || !derived) return ui.select(null);

      const set = function (values) { shellCommit({ set: { openings: [Object.assign(SG.clone(o), values)] } }); };
      const kindSelect = select(SHELL_OPENINGS.map(function (k) { return { value: k.id, label: T("sh_opening_" + k.id) }; }), o.kind, function (v) { set({ kind: v, width: undefined, height: undefined, sill: undefined }); });

      head(T("sh_opening_" + o.kind), fmt(derived.width, 2) + " × " + fmt(derived.z1 - derived.z0, 2) + " m");

      const isWindow = SG.WINDOW_KINDS.indexOf(o.kind) >= 0 && o.kind !== "slider";
      const isDoor = !!SG.DOOR_KINDS[o.kind] || o.kind === "fake";
      const matRow = function (keys, current, onPick, extra) {
        const row = el("div", "sh-palette-row");

        (extra || []).forEach(function (item) {
          row.append(el("button", "sh-mat sh-mat-text" + (current === item.value ? " active" : "")).attr("title", item.label).append(el("span", "", item.short)).on("click", function () { onPick(item.value); }));
        });
        keys.forEach(function (key) {
          row.append(el("button", "sh-mat" + (current === key ? " active" : "")).attr("title", shellMaterialName(key)).append(shellSwatch(key, "big")).on("click", function () { onPick(key); }));
        });

        return row;
      };

      body.append(
        field(T("sh_opening_kind"), kindSelect),
        el("div", "tk-grid2").append(
          field(T("sh_width"), slider(0.4, 4, 0.05, derived.width, function (v, final) { if (final) set({ width: SG.round(v, 3) }); }, { places: 2 })),
          o.kind === "half" ? field(T("sh_half_height"), slider(0.4, 1.6, 0.05, derived.z0, function (v, final) { if (final) set({ sill: SG.round(v, 3) }); }, { places: 2 })) : o.kind === "round" ? null : field(T("sh_height"), slider(0.4, 3, 0.05, derived.z1 - derived.z0, function (v, final) { if (final) set({ height: SG.round(v, 3) }); }, { places: 2 }))
        ),
        isWindow ? field(T("sh_sill"), slider(0, 2.2, 0.05, derived.z0, function (v, final) { if (final) set({ sill: SG.round(v, 3) }); }, { places: 2 })) : null
      );

      if (isDoor) {
        const doors = el("div", "sh-doors");

        (SHELL.kit.doors || []).forEach(function (door) {
          const chip = el("button", "sh-door" + ((o.door || "plain_white") === door.key ? " active" : "")).append(el("span", "sh-door-art").css("background-image", "url(img/doors/" + door.key + ".webp)"), el("span", "", T("sh_door_" + door.key)));

          chip.on("click", function () {
            SHELL.lastDoor = door.key;
            set({ door: door.key });
          });
          doors.append(chip);
        });
        body.append(field(T("sh_door_style"), doors), el("div", "tk-row wrap").append(
          button(T("sh_door_flip"), "fa-left-right", "small", function () { set({ flip: !o.flip }); }),
          o.kind === "fake" ? null : button(T("sh_door_swing"), "fa-rotate", "small", function () { set({ swing: !o.swing }); })
        ));

        if (o.kind !== "fake") body.append(field(T("sh_door_use"), segment([{ value: "auto", label: T("sh_door_use_auto") }, { value: "open", label: T("sh_door_use_open") }, { value: "fixed", label: T("sh_door_use_fixed") }], o.use || "auto", function (v) { set({ use: v === "auto" ? undefined : v }); }, true), T("sh_door_use_hint")));

        if (o.kind === "fake") body.append(el("div", "tk-hint", T("sh_opening_fake_text")));
      }

      if (o.kind === "opening" || o.kind === "arch" || o.kind === "wide") {
        const doors = el("div", "sh-doors");

        (SHELL.kit.doors || []).forEach(function (door) {
          const chip = el("button", "sh-door").append(el("span", "sh-door-art").css("background-image", "url(img/doors/" + door.key + ".webp)"), el("span", "", T("sh_door_" + door.key)));

          chip.on("click", function () {
            SHELL.lastDoor = door.key;
            set({ kind: derived.width > 1.5 ? "double" : "door", door: door.key, width: undefined, height: undefined, sill: undefined, shape: undefined });
          });
          doors.append(chip);
        });
        body.append(field(T("sh_doorway_door"), doors, T("sh_doorway_door_hint")));
      }

      if (o.kind === "garage") {
        const current = o.garage === undefined ? "white" : o.garage;

        body.append(field(T("sh_garage_door"), segment(["none", "white", "grey", "wood"].map(function (k) { return { value: k, label: T("sh_garage_" + k) }; }), current, function (v) { set({ garage: v }); }, true), T("sh_garage_hint")));
      }

      if (isWindow || o.kind === "slider") {
        const glass = el("div", "sh-kinds sh-kinds-4");

        (SHELL.kit.glass || []).map(function (g) { return g.key; }).concat(["none"]).forEach(function (key) {
          glass.append(el("button", "sh-kind" + ((o.glass || (SG.OPENINGS[o.kind] || {}).glass || "glass") === key ? " active" : "")).append(el("span", "sh-glass-dot " + key), el("span", "", T("sh_glass_" + key))).on("click", function () { set({ glass: key }); }));
        });
        body.append(field(T("sh_glass"), glass));
      }

      if (isWindow) {
        body.append(
          field(T("sh_bars"), segment(SG.BAR_KINDS.map(function (b) { return { value: b, label: T("sh_bars_" + b) }; }), o.bars || "none", function (v) { set({ bars: v === "none" ? undefined : v }); }, true)),
          field(T("sh_window_sill"), matRow(SHELL_SILLS, o.sillMat || "", function (v) { set({ sillMat: v || undefined }); }, [{ value: "", short: "—", label: T("sh_none") }])),
          SHELL.kit.blinds ? field(T("sh_shade"), segment([{ value: "", label: T("sh_none") }].concat(SHELL.kit.blinds.styles.map(function (b) { return { value: b.key, label: T("sh_shade_" + b.key) }; })), o.shade || "", function (v) { set({ shade: v || undefined }); }, true), T("sh_shade_hint")) : null,
          SHELL.kit.blinds && o.shade ? field(T("sh_shade_drop"), slider(0.15, 1, 0.05, Number(o.shadeDrop) || 0.6, function (v, final) { if (final) set({ shadeDrop: SG.round(v, 2) }); }, { places: 2 })) : null,
          derived.exterior ? field(T("sh_view"), segment([{ value: "", label: T("sh_view_house") }, { value: "city", label: T("sh_view_city") }, { value: "sky", label: T("sh_view_sky") }, { value: "trees", label: T("sh_view_trees") }, { value: "none", label: T("sh_view_none") }], o.view === undefined ? "" : o.view, function (v) { set({ view: v === "" ? undefined : v }); }, true), T("sh_view_hint")) : el("div", "tk-hint", T("sh_view_inner"))
        );
      }

      if (o.kind !== "half" && o.kind !== "wide") {
        body.append(
          field(T("sh_frame"), matRow(SHELL_FRAMES, o.trim || "", function (v) { set({ trim: v || undefined }); }, [{ value: "", short: "≡", label: T("sh_frame_house") }, { value: "none", short: "—", label: T("sh_none") }])),
          field(T("sh_frame_width"), segment([{ value: 0.04, label: T("sh_frame_thin") }, { value: 0.06, label: T("sh_frame_normal") }, { value: 0.1, label: T("sh_frame_wide") }], Number(o.trimw) || 0.06, function (v) { set({ trimw: Number(v) }); }, true))
        );
      }

      body.append(
        field(T("sh_reveal"), matRow(["white", "warm", "oak", "darkwood", "steel", "marble", "concrete", "brick"], o.frame || "", function (v) { set({ frame: v || undefined }); }, [{ value: "", short: "≡", label: T("sh_frame_house") }])),
        el("div", "tk-row wrap").append(button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); }))
      );
    } else if (sel.kind === "room") {
      ui.roomPanel(body, sel, head);
    } else if (sel.kind === "stairs") {
      const s = shellFind("stairs", sel.id);

      if (!s) return ui.select(null);

      const set = function (values) { shellCommit({ set: { stairs: [Object.assign(SG.clone(s), values)] } }); };

      head(T("sh_stairs_type_" + (s.type || "straight")), T("sh_stairs_text"));
      body.append(
        ui.stairsOptions(s, function (values) { set(values); }, false),
        el("div", "tk-row wrap").append(
          button(T("sh_rotate_90"), "fa-rotate-right", "small", function () { ui.rotateSelection(90); }),
          button(T("duplicate"), "fa-clone", "small", function () { ui.duplicate(); }),
          button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
        ),
        el("div", "tk-hint", T("sh_gizmo_hint"))
      );
    } else if (sel.kind === "detail") {
      const det = shellFind("details", sel.id);

      if (!det) return ui.select(null);

      const shape = SG.detailShape(det);

      head(T("sh_detail_" + shape.kind), shape.kind === "column" || shape.kind === "pillar" ? shellMaterialName(shape.mat) : fmt(shape.w, 2) + " m");
      body.append(
        ui.detailOptions(det, function (values) { shellCommit({ set: { details: [Object.assign(SG.clone(det), values)] } }); }, false),
        el("div", "tk-row wrap").append(
          button(T("sh_rotate_90"), "fa-rotate-right", "small", function () { ui.rotateSelection(90); }),
          button(T("sh_rotate_15"), "fa-rotate-right", "small", function () { ui.rotateSelection(15); }),
          button(T("duplicate"), "fa-clone", "small", function () { ui.duplicate(); }),
          button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
        ),
        el("div", "tk-hint", T("sh_gizmo_hint"))
      );
    } else if (sel.kind === "pool") {
      const pool = shellFind("pools", sel.id);

      if (!pool) return ui.select(null);

      head(T("sh_sel_pool"), fmt(Number(pool.w) || 4, 1) + " × " + fmt(Number(pool.l) || 8, 1) + " m");
      body.append(
        ui.poolOptions(pool, function (values) { shellCommit({ set: { pools: [Object.assign(SG.clone(pool), values)] } }); }),
        el("div", "tk-row wrap").append(
          button(T("sh_rotate_90"), "fa-rotate-right", "small", function () { ui.rotateSelection(90); }),
          button(T("duplicate"), "fa-clone", "small", function () { ui.duplicate(); }),
          button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
        ),
        el("div", "tk-hint", T("sh_gizmo_hint"))
      );
    } else if (sel.kind === "light") {
      const light = shellFind("lights", sel.id);

      if (!light) return ui.select(null);

      const set = function (values) { shellCommit({ set: { lights: [Object.assign(SG.clone(light), values)] } }); };
      const colour = $('<input type="color" class="tk-input small"/>').val(light.colour || "#ffe2bd");

      colour.on("change", function () { set({ colour: colour.val() }); });
      head(T("sh_sel_light"));
      body.append(
        el("div", "tk-grid2").append(field(T("sh_light_colour"), colour), field(T("sh_lamp_shape"), select(SG.LAMP_SHAPES.map(function (v) { return { value: v, label: T("sh_lamp_" + v) }; }), light.shape || "round", function (v) { set({ shape: v }); }))),
        el("div", "sh-light-presets").append(["#ffe2bd", "#fff4e0", "#ffd08a", "#dfe9ff", "#ff9ad5"].map(function (hex) {
          return el("button", "sh-light-preset").css("background", hex).on("click", function () { set({ colour: hex }); });
        })),
        field(T("sh_light_range"), slider(2, 20, 0.5, Number(light.range) || 7, function (v, final) { if (final) set({ range: v }); }, { places: 1 })),
        field(T("sh_light_strength"), slider(1, 20, 0.5, Number(light.intensity) || 6, function (v, final) { if (final) set({ intensity: v }); }, { places: 1 })),
        switchRow(T("sh_light_shadow"), light.shadow !== false, function (on) { set({ shadow: on }); }),
        el("div", "tk-row wrap").append(
          button(T("sh_look_at"), "fa-eye", "small", function () { toolAction("teleport", { point: light.p }); }),
          button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
        )
      );
    } else if (sel.kind === "prop") {
      const prop = shellFind("props", sel.id);

      if (!prop) return ui.select(null);

      const set = function (values) { shellCommit({ set: { props: [Object.assign(SG.clone(prop), values)] } }); };

      head(prop.model, fmt(prop.p[0], 2) + ", " + fmt(prop.p[1], 2) + ", " + fmt(prop.p[2], 2));
      body.append(
        el("div", "sh-prop-pic").append(propImg($("<img/>"), prop.model).on("error", function () { $(this).attr("src", "img/noimage.webp").off("error"); })),
        el("div", "sh-turn-row").append(
          button(T("sh_turn_left"), "fa-rotate-left", "small", function () { ui.rotateSelection(-90); }),
          button(T("sh_turn_right"), "fa-rotate-right", "small primary", function () { ui.rotateSelection(90); }).append(el("span", "tk-key", "R")),
          button("180°", "fa-repeat", "small", function () { ui.rotateSelection(180); })
        ),
        field(T("sh_prop_turn"), slider(0, 359, 1, Math.round(((prop.r || [0, 0, 0])[2] % 360 + 360) % 360), function (v, final) { if (final) set({ r: [0, 0, SG.round(v, 1)] }); }, { places: 0 })),
        button(T("sh_prop_wall"), "fa-border-top-left", "small sh-wide-btn", function () { ui.wallSnapSelection(); }),
        field(T("sh_prop_height"), slider(-1, 3, 0.01, SG.round(prop.p[2] - shellLevel().z, 2), function (v, final) { if (final) set({ p: [prop.p[0], prop.p[1], SG.round(shellLevel().z + v, 3)] }); }, { places: 2 })),
        group(T("gizmo_title"), [gizmoControls()]),
        el("div", "tk-row wrap").append(
          button(T("sh_prop_ground"), "fa-arrows-down-to-line", "small", function () { toolAction("groundprop"); }),
          button(T("duplicate"), "fa-clone", "small", function () { ui.duplicate(); }),
          button(T("sh_look_at"), "fa-eye", "small", function () { toolAction("teleport", { point: prop.p }); }),
          button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
        ),
        el("div", "tk-hint", T("sh_prop_hint")),
        SHELL.tool === "furniture" ? button(T("sh_place_more"), "fa-couch", "primary sh-wide-btn sh-place-more", function () { ui.select(null); }) : null
      );
    } else if (sel.kind === "point") {
      const value = sel.index >= 0 ? (SHELL.doc.points[sel.name] || [])[sel.index] : SHELL.doc.points[sel.name];

      if (!value) return ui.select(null);

      head(T("sh_point_" + sel.name), fmt(value.p[0], 2) + ", " + fmt(value.p[1], 2) + ", " + fmt(value.p[2], 2));
      body.append(
        field(T("sh_heading"), slider(0, 359, 1, Number(value.h) || 0, function (v, final) {
          if (!final) return;

          const points = {};

          if (sel.index >= 0) {
            const list = SG.clone(SHELL.doc.points[sel.name]);

            list[sel.index].h = v;
            points[sel.name] = list;
          } else {
            points[sel.name] = Object.assign(SG.clone(value), { h: v });
          }

          shellCommit({ root: { points: points } });
        }, { places: 0 })),
        el("div", "tk-row wrap").append(
          button(T("sh_point_pick3d"), "fa-crosshairs", "small", function () {
            if (SHELL.mode === "plan") ui.setMode("split");
            SHELL.repick = sel;
            toolAction("pick", { kind: "point", name: sel.name });
          }),
          button(T("sh_look_at"), "fa-eye", "small", function () { toolAction("teleport", { point: value.p }); }),
          button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
        ),
        el("div", "tk-hint", T("sh_point_" + sel.name + "_text"))
      );
    }
  },
  sideRow: function (wall, side, label) {
    const ui = SHELL_UI;
    const row = el("div", "tk-row between");
    const current = wall[side];

    row.append(
      el("div", "tk-row").append(shellSwatch(current || "", "small"), $("<span></span>").text(label + ": " + (current ? shellMaterialName(current) : T("sh_wall_room_default")))),
      el("div", "tk-row").append(
        iconButton("fa-paint-roller", function () {
          modal({
            kicker: T("sh_kicker"), title: label, wide: true,
            body: [ui.palette(current, function (key) {
              const changed = SG.clone(wall);

              changed[side] = key;
              shellCommit({ set: { walls: [changed] } });
              closeModal();
            })]
          });
        }, T("sh_paint_side"), "small"),
        current ? iconButton("fa-eraser", function () {
          const changed = SG.clone(wall);

          delete changed[side];
          shellCommit({ set: { walls: [changed] } });
        }, T("sh_wall_room_default"), "small") : null
      )
    );

    return row;
  },
  roomPanel: function (body, sel, head) {
    const ui = SHELL_UI;
    const room = SHELL.built.derived.rooms.find(function (r) { return r.id === sel.id; });

    if (!room) return ui.select(null);

    const record = room.record;
    const set = function (values) { shellCommit({ set: { rooms: [Object.assign(SG.clone(record), values)] } }); };
    const perimeter = room.edges.reduce(function (s, e) { return s + e.length; }, 0);
    const matRow = function (part, label, fallback) {
      const row = el("div", "sh-room-mat").append(shellSwatch(record[part] || fallback, "big"), el("div", "").append(el("div", "tk-tool-name", label), el("div", "tk-hint", shellMaterialName(record[part] || fallback))));

      row.on("click", function () {
        modal({
          kicker: record.name || T("room_type_" + (record.type || "living")), title: label, wide: true,
          body: [ui.palette(record[part] || fallback, function (key) {
            const values = {};

            values[part] = key;
            set(values);
            closeModal();
          })]
        });
      });

      return row;
    };

    head(record.name || T("room_type_" + (record.type || "living")), fmt(room.area, 1) + " m²  ·  " + T("sh_perimeter", fmt(perimeter, 1)));
    body.append(
      field(T("name"), input(record.name || "", T("room_type_" + (record.type || "living")), function (v) { set({ name: String(v).slice(0, 30) }); }, { small: true })),
      field(T("sh_room_type"), select(SG.ROOM_TYPES.map(function (t) { return { value: t, label: T("room_type_" + t) }; }), record.type || "living", function (v) { set({ type: v }); })),
      el("div", "sh-room-mats").append(matRow("floor", T("sh_paint_floor"), "oak"), matRow("walls", T("sh_paint_walls"), "white"), matRow("ceiling", T("sh_paint_ceiling"), "ceil")),
      group(T("sh_inside"), [
        segment([{ value: "", label: T("sh_inside_house") }, { value: "night", label: T("sh_inside_night"), icon: "fa-moon" }, { value: "day", label: T("sh_inside_day"), icon: "fa-sun" }], record.inside || "", function (v) { set({ inside: v || undefined }); }, true),
        el("div", "tk-hint", T("sh_inside_hint"))
      ]),
      group(T("sh_mouldings"), [
        field(T("sh_skirting"), segment([{ value: "house", label: T("sh_inside_house") }].concat(SHELL_MOULD_MATS.map(function (m) { return { value: m, label: m ? shellMaterialName(m) : T("sh_none") }; })), record.skirting === undefined ? "house" : record.skirting, function (v) { set({ skirting: v === "house" ? undefined : v }); }, true)),
        field(T("sh_crown"), segment([{ value: "house", label: T("sh_inside_house") }].concat(SHELL_MOULD_MATS.map(function (m) { return { value: m, label: m ? shellMaterialName(m) : T("sh_none") }; })), record.crown === undefined ? "house" : record.crown, function (v) { set({ crown: v === "house" ? undefined : v }); }, true)),
        el("div", "tk-hint", T("sh_mouldings_hint"))
      ]),
      switchRow(T("sh_room_ceiling"), record.ceilingOff !== true, function (on) { set({ ceilingOff: !on }); }),
      switchRow(T("sh_room_open_above"), record.openAbove === true, function (on) { set({ openAbove: on || undefined }); }, T("sh_room_open_above_text")),
      record.openAbove === true ? field(T("sh_void_rail"), segment([{ value: "glass", label: T("sh_rail_glass") }, { value: "metal", label: T("sh_rail_metal") }, { value: "none", label: T("sh_none") }], record.openRail || "glass", function (v) { set({ openRail: v }); }, true)) : null,
      el("div", "tk-row wrap").append(
        button(T("sh_furnish"), "fa-couch", "small primary", function () { ui.furnish(room); }),
        button(T("sh_add_light"), "fa-lightbulb", "small", function () {
          const a = record.anchor || SG.interiorPoint(room.points);

          shellCommit({ set: { lights: [{ id: SG.uid("li"), p: [SG.round(a[0], 3), SG.round(a[1], 3), SG.round(room.z + room.height - 0.01, 3)], shape: "round", colour: "#ffe2bd", range: 7, intensity: 6 }] } });
        }),
        button(T("sh_copy_room"), "fa-clone", "small", function () { SHELL.copyRoom = { id: room.id }; SHELL.copyAt = null; showNotify({ title: T("notify_title"), text: T("sh_copy_room_hint"), type: "info", timeout: 4000 }); SHELL.dirty = true; }),
        button(T("sh_look_at"), "fa-eye", "small", function () { const a = record.anchor || SG.interiorPoint(room.points); toolAction("teleport", { point: [a[0], a[1], room.z + 1.2] }); }),
        button(T("delete"), "fa-trash", "small danger", function () { ui.deleteSelection(); })
      )
    );
  },
  copyRoomDelta: function (p) {
    const room = SHELL.copyRoom && (SHELL.built.derived.rooms || []).find(function (r) { return r.id === SHELL.copyRoom.id; });

    if (!room) return null;

    const anchor = room.record.anchor || SG.interiorPoint(room.points);
    const step = Number(SHELL.doc.settings.grid) || 0.25;
    const target = [Math.round(p[0] / step) * step, Math.round(p[1] / step) * step];

    return { room: room, d: [SG.round(target[0] - anchor[0], 3), SG.round(target[1] - anchor[1], 3)] };
  },
  copyRoomGhost: function (p) {
    const info = SHELL_UI.copyRoomDelta(p);

    if (!info) return null;

    return info.room.points.map(function (q) { return [q[0] + info.d[0], q[1] + info.d[1]]; });
  },
  copyRoomAt: function (p) {
    const info = SHELL_UI.copyRoomDelta(p);

    SHELL.copyRoom = null;
    SHELL.copyAt = null;
    SHELL.dirty = true;

    if (!info) return;

    const room = info.room;
    const d = info.d;
    const src = (SHELL.doc.levels || []).find(function (l) { return l.id === room.level; }) || shellLevel();
    const dst = shellLevel();
    const dz = SG.round((Number(dst.z) || 0) - (Number(src.z) || 0), 3);
    const top = (Number(src.z) || 0) + (Number(src.height) || 2.8) + 0.3;
    const inside = function (q) { return SG.insidePolygon([q[0], q[1]], room.points); };
    const shift = function (q) { return [SG.round(q[0] + d[0], 3), SG.round(q[1] + d[1], 3)]; };
    const map = {};
    const walls = [];

    room.edges.forEach(function (edge) {
      if (!edge.wall || map[edge.wall]) return;

      const w = shellFind("walls", edge.wall);

      if (!w) return;

      const copy = SG.clone(w);

      copy.id = SG.uid("w");
      copy.level = dst.id;
      copy.a = shift(w.a);
      copy.b = shift(w.b);
      map[w.id] = copy.id;
      walls.push(copy);
    });

    const openings = (SHELL.doc.openings || []).filter(function (o) { return map[o.wall]; }).map(function (o) { return Object.assign(SG.clone(o), { id: SG.uid("o"), wall: map[o.wall] }); });
    const details = (SHELL.doc.details || []).filter(function (det) { return (det.level || "l1") === room.level && det.at && inside(det.at); }).map(function (det) { return Object.assign(SG.clone(det), { id: SG.uid("dt"), level: dst.id, at: shift(det.at) }); });
    const inLevel = function (z) { return z >= (Number(src.z) || 0) - 0.3 && z <= top; };
    const props = (SHELL.doc.props || []).filter(function (prop) { return prop.p && inside(prop.p) && inLevel(prop.p[2]); }).map(function (prop) { return Object.assign(SG.clone(prop), { id: SG.uid("p"), p: shift(prop.p).concat([SG.round(prop.p[2] + dz, 3)]) }); });
    const lights = (SHELL.doc.lights || []).filter(function (l) { return l.p && inside(l.p) && inLevel(l.p[2]); }).map(function (l) { return Object.assign(SG.clone(l), { id: SG.uid("li"), p: shift(l.p).concat([SG.round(l.p[2] + dz, 3)]) }); });
    const record = Object.assign(SG.clone(room.record), { id: SG.uid("r"), level: dst.id, anchor: shift(room.record.anchor || SG.interiorPoint(room.points)) });

    shellCommit({ set: { walls: walls, rooms: [record], openings: openings, details: details, props: props, lights: lights } });
    SHELL_SFX.play("corner");
    showNotify({ title: T("notify_title"), text: T("sh_copy_room_done"), type: "success", timeout: 2500 });
  },
  furnishNext: function () {
    const queue = SHELL.furnishQueue || [];

    while (queue.length) {
      const id = queue.shift();
      const room = (SHELL.built.derived.rooms || []).find(function (r) { return r.id === id; });

      if (room) {
        SHELL.furnishing = true;
        SHELL_UI.furnish(room, true);
        return;
      }
    }

    if (SHELL.furnishing) {
      SHELL.furnishing = false;
      showNotify({ title: T("notify_title"), text: T("sh_furnish_all_done"), type: "success" });
    }
  },
  furnish: function (room, quiet) {
    const holes = [];

    room.edges.forEach(function (edge, index) {
      (edge.holes || []).forEach(function (h) { holes.push({ edge: index + 1, u0: h.u0, u1: h.u1 }); });
    });

    toolAction("furnish", { room: { id: room.id, type: room.record.type || "living", points: room.points, z: room.z, anchor: room.record.anchor || SG.interiorPoint(room.points), holes: holes }, seed: Date.now() % 100000 });
    if (!quiet) showNotify({ title: T("notify_title"), text: T("sh_furnish_working"), type: "info", timeout: 2500 });
  }
});

Object.assign(SHELL_UI, {
  panel_rooms: function (panel) {
    const list = el("div", "tk-list");

    shellLevels().forEach(function (level) {
      const rooms = SHELL.built.derived.rooms.filter(function (r) { return r.level === level.id; });

      if (!rooms.length) return;

      list.append(el("div", "sh-list-label", level.name || ""));
      rooms.forEach(function (room) {
        const row = el("div", "tk-item" + (SHELL.sel && SHELL.sel.id === room.id ? " active" : "")).append(shellSwatch(room.record.floor || "oak", "small"), $("<span></span>").text(room.record.name || T("room_type_" + (room.record.type || "living"))), el("span", "tk-item-sub", fmt(room.area, 1) + " m²"));

        row.on("click", function () {
          SHELL.level = level.id;
          SHELL_UI.select({ kind: "room", id: room.id });
          const a = room.record.anchor || SG.interiorPoint(room.points);

          SHELL.view.x = a[0];
          SHELL.view.y = a[1];
          toolAction("teleport", { point: [a[0], a[1], room.z + 1.2] });
        });
        list.append(row);
      });
    });

    if (!SHELL.built.derived.rooms.length) list.append(el("div", "tk-empty", T("sh_rooms_empty")));

    panel.append(list);
  },
  panel_checks: function (panel) {
    const ui = SHELL_UI;
    const list = el("div", "tk-list");

    if (!SHELL.checks.length) list.append(el("div", "tk-empty").append(icon("fa-circle-check"), " " + T("sh_checks_all_good")));

    SHELL.checks.forEach(function (item) {
      const row = el("div", "sh-check " + item.level).append(icon(item.level === "bad" ? "fa-circle-exclamation" : item.level === "warn" ? "fa-triangle-exclamation" : "fa-circle-info"), $("<span></span>").text(T(item.text)));

      if (item.fix) {
        row.append(button(T("sh_fix"), "fa-wand-magic", "small", function () {
          const patch = SG.fix(SHELL.doc, SHELL.built, item);

          if (patch) shellCommit(patch);
        }));
      }

      row.on("click", function (event) {
        if ($(event.target).closest("button").length) return;

        const target = item.target ? String(item.target).split(":")[0] : null;

        if (!target) return;

        if (shellFind("walls", target)) ui.select({ kind: "wall", id: target });
        else if (shellFind("openings", target)) ui.select({ kind: "opening", id: target });
        else if (shellFind("props", target)) ui.select({ kind: "prop", id: target });
        else if (SHELL.built.derived.rooms.some(function (r) { return r.id === target; })) ui.select({ kind: "room", id: target });
      });
      list.append(row);
    });
    panel.append(list);
  },
  panel_revisions: function (panel) {
    const list = el("div", "tk-list");
    const label = input("", T("sh_revision_label"), null, { small: true });

    panel.append(el("div", "tk-row").append(label, button(T("sh_revision_save"), "fa-bookmark", "small primary", function () {
      shellRequest("saverevision", { id: SHELL.summary.id, label: label.val() }).then(function () { SHELL_UI.drawSide(); });
    })), list);
    list.append(el("div", "tk-empty", T("sh_loading")));
    shellRequest("revisions", { id: SHELL.summary.id }).then(function (reply) {
      list.empty();

      const items = (reply && reply.list) || [];

      if (!items.length) list.append(el("div", "tk-empty", T("sh_revisions_empty")));

      items.forEach(function (r) {
        list.append(el("div", "tk-item").append(icon(r.label ? "fa-bookmark" : "fa-clock"), $("<span></span>").text(r.label || T("sh_revision_auto")), el("span", "tk-item-sub", (r.by || "") + " · " + timeAgo(r.at)), el("div", "tk-item-end").append(button(T("sh_revision_restore"), null, "small", function () {
          confirmBox(T("sh_revision_restore"), T("sh_revision_restore_text"), function () {
            SHELL.pending = [];
            shellRequest("restore", { id: SHELL.summary.id, index: r.index });
          });
        }))));
      });
    });
  },
  saveTemplate: function () {
    const name = input(SHELL.doc.name || T("sh_template_default"), T("name"));

    modal({ kicker: T("sh_kicker"), title: T("sh_template_save_title"), body: [el("div", "tk-hint", T("sh_template_save_text")), field(T("name"), name)], actions: [{ label: T("cancel") }, {
      label: T("sh_template_save"), kind: "primary", icon: "fa-bookmark", run: function () {
        shellRequest("savetemplate", { id: SHELL.summary.id, name: String(name.val() || "").trim() || SHELL.doc.name }).then(function (reply) {
          showNotify({ title: T("notify_title"), text: reply && reply.ok ? T("sh_template_saved") : T(reply && reply.code === "full" ? "sh_template_full" : "sh_template_failed"), type: reply && reply.ok ? "success" : "error" });
        });
      }
    }] });
  },
  panel_house: function (panel) {
    panel.append(el("div", "tk-row wrap").append(button(T("sh_template_save"), "fa-bookmark", "small", function () { SHELL_UI.saveTemplate(); })));

    const settings = SHELL.doc.settings || {};
    const set = function (values) { shellCommit({ root: { settings: values } }); };
    const schemes = el("div", "sh-schemes");

    Object.keys(SG.SCHEMES).forEach(function (id) {
      const s = SG.SCHEMES[id];
      const chip = el("button", "sh-scheme").append(el("div", "sh-scheme-swatches").append(shellSwatch(s.walls), shellSwatch(s.floors._), shellSwatch(s.bathwalls)), el("span", "", T("scheme_" + id) !== "scheme_" + id ? T("scheme_" + id) : s.name));

      chip.on("click", function () {
        const patch = SG.scheme(SHELL.doc, SHELL.built, id);

        if (patch) shellCommit(patch);
      });
      schemes.append(chip);
    });

    panel.append(
      field(T("sh_inside_default"), segment([{ value: "night", label: T("sh_inside_night"), icon: "fa-moon" }, { value: "day", label: T("sh_inside_day"), icon: "fa-sun" }], settings.inside || "night", function (v) { set({ inside: v }); }, true)),
      el("div", "tk-grid2").append(
        field(T("sh_hour"), slider(0, 23, 1, Number(settings.hour) || 21, function (v, final) { if (final) set({ hour: v }); }, { places: 0 })),
        field(T("sh_weather"), select(["EXTRASUNNY", "CLEAR", "CLOUDS", "OVERCAST", "SMOG", "FOGGY"].map(function (w) { return { value: w, label: w }; }), settings.weather || "EXTRASUNNY", function (v) { set({ weather: v }); }))
      ),
      field(T("sh_skirting"), segment(SHELL_MOULD_MATS.map(function (m) { return { value: m, label: m ? shellMaterialName(m) : T("sh_none") }; }), settings.skirting || "", function (v) { set({ skirting: v }); }, true)),
      settings.skirting ? field(T("sh_skirting_height"), slider(0.05, 0.25, 0.01, Number(settings.skirtH) || 0.1, function (v, final) { if (final) set({ skirtH: v }); }, { places: 2, unit: " m" })) : null,
      field(T("sh_crown"), segment(SHELL_MOULD_MATS.map(function (m) { return { value: m, label: m ? shellMaterialName(m) : T("sh_none") }; }), settings.crown || "", function (v) { set({ crown: v }); }, true), T("sh_crown_hint")),
      settings.crown ? field(T("sh_crown_height"), slider(0.04, 0.25, 0.01, Number(settings.crownH) || 0.08, function (v, final) { if (final) set({ crownH: v }); }, { places: 2, unit: " m" })) : null,
      field(T("sh_frames"), segment([{ value: "", label: T("sh_none") }, { value: "white", label: shellMaterialName("white") }, { value: "darkwood", label: shellMaterialName("darkwood") }, { value: "steel", label: shellMaterialName("steel") }], settings.frames || "", function (v) { set({ frames: v }); }, true)),
      field(T("sh_view_default"), segment([{ value: "city", label: T("sh_view_city") }, { value: "sky", label: T("sh_view_sky") }, { value: "trees", label: T("sh_view_trees") }, { value: "none", label: T("sh_view_none") }], settings.view || "city", function (v) { set({ view: v }); }, true)),
      field(T("sh_apply_scheme"), schemes, T("sh_apply_scheme_hint")),
      group(T("sh_colours"), [SHELL_UI.colourSlots()])
    );
  },
  panel_team: function (panel) {
    const list = el("div", "tk-list");

    (SHELL.editors || []).forEach(function (editor) {
      list.append(el("div", "tk-item").append(el("span", "sh-dot").css("background", editor.colour || "#ff66ff"), $("<span></span>").text(editor.name + (editor.id === SHELL.me ? "  (" + T("sh_you") + ")" : "")), el("span", "tk-item-sub", editor.tool ? T("sh_tool_" + editor.tool) : "")));
    });
    panel.append(list, el("div", "tk-hint", T("sh_team_hint")));
  },
  walk: function (on, baked) {
    if (on && baked === undefined && SHELL_UI.walkNeedsBake()) {
      SHELL_UI.walkBake();
      return;
    }

    SHELL.walking = on;
    SHELL_UI.root.toggleClass("walking", on);
    SHELL_UI.walkBar.toggleClass("hidden", !on);
    toolAction("walk", Object.assign({ on: on }, on && baked ? { baked: baked } : {}));
  },
  walkNeedsBake: function () {
    if (!SHELL.built || !SHELL.summary || SHELL.walkBakeOn === false) return false;

    return (SHELL.built.pieces || []).some(function (p) { return typeof p[13] !== "number"; });
  },
  walkParts: function (built, model) {
    const levels = (SHELL.doc.levels || []).map(function (l) { return Number(l.z) || 0; }).sort(function (a, b) { return a - b; });
    const levelOf = function (z) {
      let index = 0;

      levels.forEach(function (lz, i) { if (lz - 0.18 <= z) index = i; });

      return index;
    };
    const groups = levels.length ? levels.map(function () { return { pieces: [], lamps: [] }; }) : [{ pieces: [], lamps: [] }];

    (built.pieces || []).forEach(function (p) {
      if (typeof p[13] === "number") return;
      groups[levels.length ? levelOf(Number(p[3]) || 0) : 0].pieces.push(p);
    });

    return groups.map(function (g, i) {
      return { name: model + "_" + i, built: { pieces: g.pieces, doors: [], lamps: [] } };
    }).filter(function (part) {
      return part.built.pieces.some(function (p) { return !/^rtx_tk_(fx_|cx_)/.test(String(p[0])); });
    });
  },
  walkBake: function () {
    const ui = SHELL_UI;
    const rev = SHELL.doc.rev + "|" + (SHELL.commits || 0) + "|" + SHELL.summary.id + "|" + JSON.stringify(SHELL.doc.colours || {}) + "|" + JSON.stringify(SHELL.doc.customs || {}) + "|" + (SHELL.walkBakeMode || "");
    const cached = SHELL.walkBaked;

    if (cached && cached.rev === rev) {
      ui.walk(true, cached.models);
      return;
    }

    const bar = el("div", "sh-progress").append(el("div", "sh-progress-fill"));
    const line = el("div", "tk-hint", T("sh_walk_baking"));
    const fill = function (ratio) { bar.find(".sh-progress-fill").css("width", Math.round(Math.max(0, Math.min(1, ratio)) * 100) + "%"); };
    const model = "rtx_tkw_" + Date.now().toString(36);
    const fallback = function (text, noace) {
      bar.removeClass("busy");
      closeModal();

      const body = [el("div", "tk-hint", noace ? T("sh_walk_noace") : T("sh_walk_bake_failed", text || ""))];

      if (noace) {
        body.push(el("pre", "sh-ace-lines").text(["refresh", "ensure", "start", "stop"].map(function (c) { return "add_ace resource." + (STATE.resource || "rtx_shellcreator") + " command." + c + " allow"; }).join("\n")));
      }

      showNotify({ title: T("notify_title"), text: T("sh_walk_failed_title"), type: "error", timeout: 7000 });
      modal({ kicker: T("sh_kicker"), title: T("sh_walk_failed_title"), body: body, actions: [{ label: T("sh_walk_plain"), kind: "", run: function () { setTimeout(function () { ui.walk(true, false); }, 50); } }, { label: T("close"), kind: "primary" }] });
    };

    modal({ kicker: T("sh_kicker"), title: T("sh_walk_baking_title"), body: [el("div", "tk-hint", T("sh_walk_baking_text")), line, bar], actions: [] });

    let built;

    try {
      built = SG.build(SHELL.doc, SHELL.kit);
    } catch (error) {
      fallback(String(error && error.message));
      return;
    }

    const lifts = ui.liftParts(model, built);

    ui.bakeFiles(model, built, {
      parts: lifts.parts.length ? [{ name: model, built: built }].concat(lifts.parts) : null,
      images: lifts.images,
      progress: function (text, ratio, busy) {
        line.text(text);
        fill(ratio * 0.85);
        bar.toggleClass("busy", busy);
      }
    }).then(function (result) {
      bar.removeClass("busy");

      const names = [model];
      const manifest = ["fx_version 'cerulean'", "game 'gta5'", "", "description 'RTX Shell Creator walk mode, rebuilt when the house changes'", ""].concat([model].concat(lifts.parts.map(function (p) { return p.name; })).map(function (n) { return "data_file 'DLC_ITYP_REQUEST' 'stream/" + n + ".ytyp'"; })).concat([""]);
      const files = result.files.concat([{ rel: "fxmanifest.lua", text: manifest.join("\r\n") }]);

      line.text(T("sh_walk_sending"));

      return uploadResource("rtx_shellcreator_walk", files, function (ratio) { fill(0.85 + 0.15 * ratio); }).then(function (reply) {
        if (!reply || !reply.ok || reply.state !== "started") {
          fallback(reply && reply.code === "nostart" ? T("sh_walk_nostart", reply.state || "") : ((reply && (reply.message || reply.state || reply.code)) || ""), reply && reply.code === "noace");
          return;
        }

        SHELL.walkBaked = { rev: rev, models: names };
        closeModal();
        ui.walk(true, names);
      });
    }).catch(function (error) {
      fallback(String((error && error.message) || error));
    });
  }
});

Object.assign(SHELL_UI, {
  setGhost: function (model) {
    SHELL.ghostModel = model || null;
    SHELL.ghostHeading = 0;
    SHELL.ghostTurn = 0;
    SHELL.ghostAt = null;
    SHELL.ghostSnap = null;

    if (model) {
      SHELL.ghostKind = shellPlaceKind(model);
      toolAction("ghost", { model: model, place: SHELL.ghostKind, snap: SHELL.snapWalls !== false });
      if (!SHELL.dims[model]) toolAction("dims", { models: [model] });
    } else {
      toolAction("ghost", {});
    }

    SHELL_UI.drawSide();
    SHELL_UI.hints();
    SHELL.dirty = true;
  },
  ghostPlace: function (p) {
    const kind = SHELL.ghostKind || "free";
    const dims = SHELL.dims[SHELL.ghostModel] || { w: 0.6, d: 0.6, h: 1, lift: 0 };
    const turn = Number(SHELL.ghostTurn) || 0;
    const level = shellLevel();
    const room = shellRoomAt(p);
    const floor = room ? room.z : level.z || 0;
    const mount = SHELL_WALL_MOUNT[kind];
    const near = kind !== "free" && SHELL.snapWalls !== false ? SHELL_UI.nearestWall(p, mount ? 1.6 : Math.max(0.9, dims.d / 2 + 0.7)) : null;
    const out = { p: p.slice(0, 2), h: ((turn % 360) + 360) % 360, z: floor + (dims.lift || 0), snapped: false };

    if (near) {
      const d = SG.vec.norm(SG.vec.sub(near.b, near.a));
      const sideSign = SG.vec.cross(SG.vec.sub(near.b, near.a), SG.vec.sub(p, near.a)) >= 0 ? 1 : -1;
      const n = SG.vec.mul(SG.vec.left(d), sideSign);
      const t = Math.max(0.08, Number(near.wall.thick) || SHELL.thick) / 2;
      const u = Math.max(0, Math.min(SG.vec.len(SG.vec.sub(near.b, near.a)), SG.vec.dot(SG.vec.sub(p, near.a), d)));
      const at = SG.vec.add(SG.vec.add(near.a, SG.vec.mul(d, u)), SG.vec.mul(n, t + dims.d / 2 + 0.02));

      out.p = at;
      out.h = (((Math.atan2(n[0], -n[1]) * 180 / Math.PI + turn) % 360) + 360) % 360;
      out.snapped = true;

      if (mount) out.z = floor + mount - ((dims.h || 0) / 2 - (dims.lift || 0));
    }

    return out;
  },
  placeProp: function (p, event) {
    const g = SHELL_UI.ghostPlace(p);
    const prop = { id: SG.uid("p"), model: SHELL.ghostModel, p: [SG.round(g.p[0], 3), SG.round(g.p[1], 3), SG.round(g.z, 3)], r: [0, 0, SG.round(g.h, 1)] };

    shellCommit({ set: { props: [prop] } });
    toolAction("dims", { models: [prop.model] });

    if (!(event && event.shiftKey)) {
      SHELL_UI.setGhost(null);
      SHELL_UI.select({ kind: "prop", id: prop.id });
    }
  },
  placePool: function (p) {
    const o = SHELL.pool;
    const at = [Math.round(p[0] / 0.25) * 0.25, Math.round(p[1] / 0.25) * 0.25];
    const pool = { id: SG.uid("pl"), level: SHELL.level, at: at, w: o.w, l: o.l, depth: o.depth, heading: 0, tile: o.tile, edge: o.edge, ladder: o.ladder };

    shellCommit({ set: { pools: [pool] } });
    SHELL_UI.select({ kind: "pool", id: pool.id });
  },
  placeSconce: function (p) {
    const near = SHELL_UI.nearestWall(p, 1.2);

    if (!near) {
      showNotify({ title: T("notify_title"), text: T("sh_lamp_sconce_hint"), type: "info", timeout: 2500 });
      return;
    }

    const wall = near.wall;
    const d = SG.vec.norm(SG.vec.sub(near.b, near.a));
    const sideSign = SG.vec.cross(SG.vec.sub(near.b, near.a), SG.vec.sub(p, near.a)) >= 0 ? 1 : -1;
    const n = SG.vec.mul(SG.vec.left(d), sideSign);
    const t = Math.max(0.08, Number(wall.thick) || SHELL.thick) / 2 + 0.01;
    const u = Math.max(0, Math.min(SG.vec.len(SG.vec.sub(near.b, near.a)), SG.vec.dot(SG.vec.sub(p, near.a), d)));
    const at = SG.vec.add(SG.vec.add(near.a, SG.vec.mul(d, u)), SG.vec.mul(n, t));
    const level = shellLevel();
    const light = { id: SG.uid("li"), p: [SG.round(at[0], 3), SG.round(at[1], 3), SG.round((level.z || 0) + 1.95, 3)], h: SG.round(Math.atan2(-n[0], n[1]) * 180 / Math.PI, 1), shape: "sconce", colour: "#ffd9a8", range: 5, intensity: 4 };

    shellCommit({ set: { lights: [light] } });
    SHELL_UI.select({ kind: "light", id: light.id });
  },
  placeStairs: function (p) {
    const o = SHELL.stairs;
    const levels = shellLevels();
    const current = shellLevel();
    const at = [SG.round(Math.round(p[0] / 0.05) * 0.05, 3), SG.round(Math.round(p[1] / 0.05) * 0.05, 3)];
    const make = function (levelId) {
      const stair = { id: SG.uid("st"), level: levelId, at: at, heading: Number(o.heading) || 0, width: o.width, material: o.material, rail: o.rail, closed: o.closed, type: o.type, turn: o.turn };
      const fitted = SG.fitStairs(SHELL.doc, stair, 1.5);

      if (fitted && (fitted[0] !== at[0] || fitted[1] !== at[1])) {
        stair.at = fitted;
        showNotify({ title: T("notify_title"), text: T("sh_stairs_fitted"), type: "info", timeout: 2500 });
      }

      shellCommit({ set: { stairs: [stair] } });
      SHELL.level = levelId;
      SHELL_UI.refresh();
      SHELL_UI.select({ kind: "stairs", id: stair.id });
    };

    if (o.dir === "down") {
      const below = levels.filter(function (l) { return l.z < current.z - 0.5; }).pop();

      if (below) make(below.id);
      else SHELL_UI.levelDialog("below", function (id) { make(id); });
      return;
    }

    const above = levels.find(function (l) { return l.z > current.z + 0.5; });

    if (above) make(current.id);
    else SHELL_UI.levelDialog("above", function () { make(current.id); });
  },
  outerWalls: function (levelId) {
    const count = {};

    SHELL.built.derived.rooms.forEach(function (room) {
      if (room.level !== levelId) return;

      room.edges.forEach(function (edge) {
        count[edge.wall] = count[edge.wall] || {};
        count[edge.wall][edge.side] = true;
      });
    });

    return (SHELL.doc.walls || []).filter(function (w) {
      const c = count[w.id];

      return (w.level || "l1") === levelId && c && !(c.l && c.r);
    });
  },
  makeLevel: function (where, copyOuter, copyAll) {
    const levels = shellLevels();
    const top = levels[levels.length - 1];
    const bottom = levels[0];
    const ref = where === "below" ? bottom : top;
    const id = SG.uid("l");
    const basements = levels.filter(function (l) { return l.z < 0; }).length;
    const height = ref.height || 2.8;
    const level = where === "below"
      ? { id: id, name: basements ? T("sh_basement_n", basements + 1) : T("sh_basement"), z: SG.round(bottom.z - height - 0.2, 3), height: height }
      : { id: id, name: T("sh_level_n", levels.filter(function (l) { return l.z >= 0; }).length + 1), z: SG.round(top.z + (top.height || 2.8) + 0.2, 3), height: height };
    if (copyAll) {
      const dz = (Number(level.z) || 0) - (Number(ref.z) || 0);
      const refTop = (Number(ref.z) || 0) + (Number(ref.height) || 2.8);
      const wallMap = {};
      const walls = (SHELL.doc.walls || []).filter(function (w) { return w.level === ref.id; }).map(function (w) {
        const nw = Object.assign(SG.clone(w), { id: SG.uid("w"), level: id });

        wallMap[w.id] = nw.id;
        return nw;
      });
      const openings = (SHELL.doc.openings || []).filter(function (o) { return wallMap[o.wall]; }).map(function (o) {
        const no = Object.assign(SG.clone(o), { id: SG.uid("o"), wall: wallMap[o.wall] });

        if (no.door === "front") no.door = "plain_white";
        return no;
      });
      const rooms = (SHELL.doc.rooms || []).filter(function (r) { return r.level === ref.id; }).map(function (r) { return Object.assign(SG.clone(r), { id: SG.uid("r"), level: id }); });
      const details = (SHELL.doc.details || []).filter(function (d) { return d.level === ref.id && d.kind !== "ladder"; }).map(function (d) { return Object.assign(SG.clone(d), { id: SG.uid("dt"), level: id }); });
      const lights = (SHELL.doc.lights || []).filter(function (l) { return l.p && l.p[2] >= (Number(ref.z) || 0) - 0.05 && l.p[2] <= refTop + 0.05; }).map(function (l) { return Object.assign(SG.clone(l), { id: SG.uid("li"), p: [l.p[0], l.p[1], SG.round(l.p[2] + dz, 3)] }); });

      shellCommit({ set: { levels: [level], walls: walls, openings: openings, rooms: rooms, details: details, lights: lights } });

      return id;
    }

    const copy = copyOuter ? SHELL_UI.outerWalls(ref.id).map(function (w) { return Object.assign(SG.clone(w), { id: SG.uid("w"), level: id, ml: undefined, mr: undefined, paints: undefined }); }) : [];

    shellCommit({ set: { levels: [level], walls: copy } });

    return id;
  },
  levelSettings: function (level) {
    let name = level.name || "";
    let height = Number(level.height) || 2.8;
    const nameBox = input(name, T("name"), function (v) { name = String(v).slice(0, 30); }, { small: true });
    const presets = [2.6, 2.8, 3, 3.5, 4, 5, 6];
    let slide = null;
    const seg = segment(presets.map(function (v) { return { value: v, label: fmt(v, 1) + " m" }; }), presets.indexOf(height) >= 0 ? height : null, function (v) {
      height = Number(v);
      slide.replaceWith(slide = makeSlide());
    }, true);
    const makeSlide = function () { return slider(2.4, 6, 0.05, height, function (v) { height = Number(v); }, { places: 2, unit: " m" }); };

    slide = makeSlide();

    const roof = Object.assign({ type: "none", pitch: 30, ridge: "auto", outside: "slategrey", inside: "", flip: false, overhang: 0.35 }, SG.clone(level.roof || {}));
    const roofBox = el("div", "tk-stack");
    const drawRoof = function () {
      roofBox.empty().append(field(T("sh_roof"), segment(SG.ROOF_TYPES.map(function (t) { return { value: t, label: T("sh_roof_" + t) }; }), roof.type, function (v) { roof.type = v; drawRoof(); }, true)));

      if (roof.type === "none") return;

      roofBox.append(
        field(T("sh_roof_pitch"), slider(10, 50, 1, roof.pitch, function (v) { roof.pitch = Number(v); }, { places: 0, unit: "°" })),
        field(T("sh_roof_ridge"), segment([{ value: "auto", label: T("sh_roof_ridge_auto") }, { value: "x", label: T("sh_roof_ridge_x") }, { value: "y", label: T("sh_roof_ridge_y") }], roof.ridge, function (v) { roof.ridge = v; }, true)),
        roof.type === "shed" ? switchRow(T("sh_roof_flip"), roof.flip === true, function (on) { roof.flip = on; }) : null,
        field(T("sh_roof_overhang"), slider(0, 1, 0.05, roof.overhang, function (v) { roof.overhang = Number(v); }, { places: 2, unit: " m" })),
        field(T("sh_roof_outside"), segment(["slategrey", "slate", "terracotta", "concdark", "steel", "decking"].map(function (k) { return { value: k, label: shellMaterialName(k) }; }), roof.outside, function (v) { roof.outside = v; }, true)),
        field(T("sh_roof_inside"), segment([{ value: "", label: T("sh_roof_inside_room") }].concat(["white", "teak", "oak", "darkwood", "concpan"].map(function (k) { return { value: k, label: shellMaterialName(k) }; })), roof.inside || "", function (v) { roof.inside = v; }, true)),
        el("div", "tk-hint", T("sh_roof_hint"))
      );
    };

    drawRoof();
    modal({
      kicker: T("sh_kicker"),
      title: T("sh_level_settings"),
      wide: true,
      body: [field(T("name"), nameBox), field(T("sh_level_height"), seg), slide, el("div", "tk-hint", T("sh_level_height_hint")), roofBox],
      actions: [
        { label: T("sh_level_delete"), icon: "fa-trash-can", kind: "danger", run: function () {
          setTimeout(function () {
            confirmBox(T("sh_level_delete"), T("sh_level_delete_text", level.name || ""), function () { SHELL_UI.deleteLevel(level); }, true);
          }, 0);
        } },
        { label: T("cancel") },
        { label: T("save"), kind: "primary", run: function () { SHELL_UI.applyLevel(level, name, height, roof.type === "none" ? null : roof); } }
      ]
    });
  },
  deleteLevel: function (level) {
    const doc = SHELL.doc;
    const levels = shellLevels();

    if (levels.length <= 1) {
      showNotify({ title: T("notify_title"), text: T("sh_level_delete_last"), type: "error" });
      return;
    }

    const id = level.id;
    const z = Number(level.z) || 0;
    const height = Number(level.height) || 2.8;
    const step = SG.round(height + 0.2, 3);
    const up = z >= 0;
    const inside = function (pz) { return pz >= z - 0.05 && pz <= z + height + 0.15; };
    const beyond = function (pz) { return up ? pz > z + height + 0.15 : pz < z - 0.05; };
    const onLevel = function (item) { return (item.level || "l1") === id; };
    const walls = (doc.walls || []).filter(onLevel).map(function (w) { return w.id; });
    const wallSet = new Set(walls);
    const del = {
      levels: [id],
      walls: walls,
      openings: (doc.openings || []).filter(function (o) { return wallSet.has(o.wall); }).map(function (o) { return o.id; }),
      rooms: (doc.rooms || []).filter(onLevel).map(function (r) { return r.id; }),
      details: (doc.details || []).filter(onLevel).map(function (d) { return d.id; }),
      stairs: (doc.stairs || []).filter(onLevel).map(function (st) { return st.id; }),
      pools: (doc.pools || []).filter(onLevel).map(function (pl) { return pl.id; }),
      props: (doc.props || []).filter(function (pr) { return pr.p && inside(pr.p[2]); }).map(function (pr) { return pr.id; }),
      lights: (doc.lights || []).filter(function (li) { return li.p && inside(li.p[2]); }).map(function (li) { return li.id; })
    };
    const shift = up ? -step : step;
    const moved = function (list) {
      return (list || []).filter(function (item) { return item.p && beyond(item.p[2]) && del.props.indexOf(item.id) < 0 && del.lights.indexOf(item.id) < 0; }).map(function (item) {
        const copy = SG.clone(item);

        copy.p[2] = SG.round(copy.p[2] + shift, 3);
        return copy;
      });
    };
    const set = {
      levels: levels.filter(function (l) { return l.id !== id && (up ? (Number(l.z) || 0) > z + 0.05 : (Number(l.z) || 0) < z - 0.05); }).map(function (l) { return Object.assign(SG.clone(l), { z: SG.round((Number(l.z) || 0) + shift, 3) }); }),
      props: moved(doc.props),
      lights: moved(doc.lights)
    };

    if (SHELL.level === id) {
      const next = levels.filter(function (l) { return l.id !== id; }).sort(function (a, b) { return Math.abs((Number(a.z) || 0) - z) - Math.abs((Number(b.z) || 0) - z); })[0];

      SHELL.level = next ? next.id : SHELL.level;
    }

    SHELL_UI.select(null);
    shellCommit({ del: del, set: set });
    SHELL_UI.refresh();
  },
  setRoof: function (level, roof) {
    const copy = SG.clone(level);

    if (roof && roof.type !== "none") copy.roof = { type: roof.type, pitch: SG.round(roof.pitch, 1), ridge: roof.ridge, outside: roof.outside, inside: roof.inside || undefined, flip: roof.flip === true || undefined, overhang: SG.round(roof.overhang, 2) };
    else delete copy.roof;

    shellCommit({ set: { levels: [copy] } });
  },
  applyLevel: function (level, name, height, roof) {
    const doc = SHELL.doc;
    const old = Number(level.height) || 2.8;
    const delta = SG.round(Math.max(2.2, Math.min(6.5, height)) - old, 3);
    const z = Number(level.z) || 0;
    const up = z >= 0;
    const moves = function (pz) { return up ? pz > z + old - 0.05 : pz < z + 0.05; };
    const shift = up ? delta : -delta;
    const levels = (doc.levels || []).map(function (l) {
      const copy = SG.clone(l);

      if (l.id === level.id) {
        copy.name = name || copy.name;
        copy.height = SG.round(old + delta, 3);
        if (roof) copy.roof = { type: roof.type, pitch: SG.round(roof.pitch, 1), ridge: roof.ridge, outside: roof.outside, inside: roof.inside || undefined, flip: roof.flip === true || undefined, overhang: SG.round(roof.overhang, 2) };
        else delete copy.roof;
        if (!up) copy.z = SG.round(z - delta, 3);
      } else if (up ? (Number(l.z) || 0) > z + 0.05 : (Number(l.z) || 0) < z - 0.05) {
        copy.z = SG.round((Number(l.z) || 0) + shift, 3);
      }

      return copy;
    });
    const patch = { set: { levels: levels } };

    if (Math.abs(delta) > 0.001) {
      const move = function (list) {
        return (list || []).filter(function (item) { return item.p && moves(item.p[2]); }).map(function (item) {
          const copy = SG.clone(item);

          copy.p[2] = SG.round(copy.p[2] + shift, 3);
          return copy;
        });
      };

      patch.set.props = move(doc.props);
      patch.set.lights = move(doc.lights);
    }

    shellCommit(patch);
  },
  levelDialog: function (where, done) {
    let copy = true;
    let copyAll = false;
    const choose = function (side) {
      const id = SHELL_UI.makeLevel(side, copy, copyAll);

      closeModal();

      if (done) done(id);
      else {
        SHELL.level = id;
        SHELL_UI.refresh();
      }
    };
    const card = function (side, iconName) {
      return el("button", "sh-level-card").append(icon(iconName), el("div", "sh-level-card-title", T("sh_add_" + side)), el("div", "tk-hint", T("sh_add_" + side + "_text"))).on("click", function () { choose(side); });
    };
    const cards = el("div", "sh-level-cards");

    if (where !== "below") cards.append(card("above", "fa-building"));
    if (where !== "above") cards.append(card("below", "fa-house-flood-water"));

    modal({
      kicker: T("sh_kicker"),
      title: where === "above" ? T("sh_need_above") : where === "below" ? T("sh_need_below") : T("sh_level_add"),
      body: [cards, switchRow(T("sh_copy_outer"), copy, function (on) { copy = on; }), el("div", "tk-hint", T("sh_copy_outer_text")), switchRow(T("sh_copy_all"), copyAll, function (on) { copyAll = on; }), el("div", "tk-hint", T("sh_copy_all_text"))],
      actions: [{ label: T("cancel") }]
    });
  },
  commitPart: function (d) {
    const wall = shellFind("walls", d.wall);

    if (!wall) return;

    const a = Math.min(d.a, d.b);
    const b = Math.max(d.a, d.b);

    if (b - a < 0.1) return;

    const split = SG.round(SHELL.part.split, 3);
    const range = d.z0 !== undefined ? [SG.round(Math.max(0, d.z0), 3), SG.round(d.z1, 3)] : SHELL.part.height === "lower" ? [0, split] : SHELL.part.height === "upper" ? [split, 99] : [0, 99];
    const changed = SG.clone(wall);

    changed.paints = (changed.paints || []).concat([{ side: d.side, a: SG.round(a, 3), b: SG.round(b, 3), z0: range[0], z1: range[1], m: SHELL.paint.material }]).slice(-24);
    shellCommit({ set: { walls: [changed] } });
  },
  lampPicker: function (current, onPick) {
    const wrap = el("div", "sh-kinds sh-kinds-3");
    const icons = { round: "fa-circle", square: "fa-square", strip: "fa-grip-lines", spot: "fa-circle-dot", pendant: "fa-bell", chandelier: "fa-sun", bulb: "fa-lightbulb", sconce: "fa-plug", none: "fa-ban" };

    SG.LAMP_SHAPES.forEach(function (shape) {
      const chip = el("button", "sh-kind" + (current === shape ? " active" : "")).append(icon(icons[shape] || "fa-lightbulb"), el("span", "", T("sh_lamp_" + shape)));

      chip.on("click", function () { onPick(shape); });
      wrap.append(chip);
    });

    return wrap;
  },
  stairsOptions: function (o, onChange, forTool) {
    const wrap = el("div", "tk-stack");
    const types = el("div", "sh-kinds sh-kinds-3");
    const icons = { straight: "fa-stairs", landing: "fa-grip-lines", l: "fa-l", u: "fa-u", grand: "fa-landmark", spiral: "fa-rotate", floating: "fa-feather" };
    const type = o.type || "straight";

    SG.STAIR_TYPES.forEach(function (t) {
      const chip = el("button", "sh-kind" + (type === t ? " active" : "")).append(icon(icons[t]), el("span", "", T("sh_stairs_type_" + t)));

      chip.on("click", function () { onChange({ type: t }); });
      types.append(chip);
    });
    wrap.append(field(T("sh_stairs_type"), types));

    if (forTool) wrap.append(field(T("sh_stairs_dir"), segment([{ value: "up", label: T("sh_stairs_up"), icon: "fa-arrow-up" }, { value: "down", label: T("sh_stairs_down"), icon: "fa-arrow-down" }], o.dir || "up", function (v) { onChange({ dir: v }); }, true)));
    if (type !== "straight" && type !== "landing") wrap.append(field(T("sh_stairs_turn"), segment([{ value: "left", label: T("sh_stairs_left"), icon: "fa-arrow-turn-up fa-flip-horizontal" }, { value: "right", label: T("sh_stairs_right"), icon: "fa-arrow-turn-up" }], o.turn || "right", function (v) { onChange({ turn: v }); }, true)));

    if (type === "spiral") {
      wrap.append(field(T("sh_stairs_size"), segment(SG.SPIRAL_SIZES.map(function (r) { return { value: r, label: fmt(r * 2, 1) + " m" }; }), SG.SPIRAL_SIZES.reduce(function (best, r) { return Math.abs(r - (Number(o.width) || 1)) < Math.abs(best - (Number(o.width) || 1)) ? r : best; }, 1), function (v) { onChange({ width: Number(v) }); }, true)));
    } else {
      wrap.append(field(T("sh_width"), slider(0.6, 4, 0.05, Number(o.width) || 1, function (v, final) { if (final || forTool) onChange({ width: SG.round(v, 3) }); }, { places: 2 })));
    }

    wrap.append(
      field(T("sh_stairs_material"), shellMatRow(Array.from(new Set((SHELL.kit.steps || []).filter(function (x) { return x.width === 1; }).map(function (x) { return x.material; }))), o.material || "oak", function (v) { onChange({ material: v }); })),
      switchRow(T("sh_stairs_rail"), type === "floating" ? o.rail === true : o.rail !== false, function (on) { onChange({ rail: on }); }),
      type !== "spiral" && type !== "floating" ? switchRow(T("sh_stairs_open"), o.floating === true, function (on) { onChange({ floating: on }); }) : null,
      type !== "spiral" && type !== "floating" && o.floating !== true ? switchRow(T("sh_stairs_closed"), o.closed !== false, function (on) { onChange({ closed: on }); }) : null,
      type === "floating" ? el("div", "tk-hint", T("sh_stairs_floating_hint")) : null,
      el("div", "tk-hint", T(forTool ? "sh_stairs_tool_hint" : "sh_stairs_level_hint"))
    );

    return wrap;
  },
  detailFor: function (p) {
    const o = SHELL.details;
    const base = SG.DETAILS[o.kind] || SG.DETAILS.column;
    const det = { id: SG.uid("dt"), level: SHELL.level, kind: o.kind, at: [SG.round(Math.round(p[0] / 0.05) * 0.05, 3), SG.round(Math.round(p[1] / 0.05) * 0.05, 3)], heading: Number(o.heading) || 0, w: o.w || base.w, d: o.d || base.d, h: o.h || base.h, mat: o.mat || base.mat };

    if (base.top) det.top = o.top || base.top;
    if (base.rail) det.rail = o.rail || base.rail;
    if (base.glass) det.glass = o.glass || base.glass;

    if (base.wall) {
      const near = SHELL_UI.nearestWall(p, 1.5);

      if (near) {
        const wall = near.wall;
        const wd = SG.vec.norm(SG.vec.sub(near.b, near.a));
        const sign = SG.vec.cross(SG.vec.sub(near.b, near.a), SG.vec.sub(p, near.a)) >= 0 ? 1 : -1;
        const inward = SG.vec.mul(SG.vec.left(wd), sign);
        const back = SG.vec.mul(inward, -1);
        const ax = [back[1], -back[0]];
        const total = SG.vec.len(SG.vec.sub(near.b, near.a));
        const thick = Math.max(0.08, Number(wall.thick) || SHELL.thick || 0.2);
        const lo = det.w / 2 + thick / 2 + 0.004;
        const hi = total - det.w / 2 - thick / 2 - 0.004;
        let u = SG.vec.dot(SG.vec.sub(p, near.a), wd);

        if (hi >= lo) {
          u = Math.max(lo, Math.min(hi, u));
          if (u - lo < 0.35) u = lo;
          if (hi - u < 0.35) u = hi;
        } else {
          u = total / 2;
        }

        const foot = SG.vec.add(near.a, SG.vec.mul(wd, u));
        const at = SG.vec.add(foot, SG.vec.mul(inward, thick / 2 + det.d / 2 + 0.004));

        det.at = [SG.round(at[0], 3), SG.round(at[1], 3)];
        det.heading = SG.round(((Math.atan2(ax[1], ax[0]) * 180 / Math.PI) % 360 + 360) % 360, 1);
      }
    }

    return det;
  },
  previewDetail: function (det) {
    const level = shellLevel();
    const key = det ? JSON.stringify([det.kind, det.at, det.heading, det.w, det.d, det.h, det.mat, det.top, det.built, det.shape, det.level]) : "";

    if (key === SHELL.previewKey) return;

    SHELL.previewKey = key;
    clearTimeout(SHELL.previewTimer);

    if (!det) {
      toolAction("preview", { pieces: [] });
      return;
    }

    SHELL.previewTimer = setTimeout(function () {
      try {
        const mini = { format: "rtx-shell", version: 1, name: "", levels: SHELL.doc.levels, walls: [], rooms: [], openings: [], stairs: [], props: [], lights: [], points: {}, settings: Object.assign({}, SHELL.doc.settings, { fill: false }), pools: [], details: [Object.assign({}, det, { id: "__preview", level: level.id })] };
        const built = SG.build(mini, SHELL.kit);
        const pieces = built.pieces.filter(function (pc) { return !/_cx_|_bk_|_view_/.test(String(pc[0])); }).slice(0, 220).map(function (pc) { return pc.slice(0, 12); });

        toolAction("preview", { pieces: pieces });
      } catch (err) {
        toolAction("preview", { pieces: [] });
      }
    }, 120);
  },
  placeDetail: function (p) {
    const det = SHELL_UI.detailFor(p);

    SHELL.previewKey = "";
    toolAction("preview", { pieces: [] });

    shellCommit({ set: { details: [det] } });
    SHELL_UI.select({ kind: "detail", id: det.id });
  },
  detailOptions: function (o, onChange, picking) {
    const ui = SHELL_UI;
    const wrap = el("div", "tk-stack");
    const kind = SG.DETAILS[o.kind] ? o.kind : "column";
    const base = SG.DETAILS[kind];
    const icons = {
      column: "fa-square", pillar: "fa-circle", floorpatch: "fa-square-full", ladder: "fa-water-ladder", elevator: "fa-elevator", beam: "fa-grip-lines", halfwall: "fa-border-none", glasswall: "fa-table-cells-large", void: "fa-up-down", platform: "fa-layer-group", glassrail: "fa-table-columns", rail: "fa-bars",
      wardrobe: "fa-door-closed", kitchen: "fa-kitchen-set", wallcab: "fa-box-archive", counter: "fa-champagne-glasses", sinkrun: "fa-sink", hobrun: "fa-fire-burner", tallcab: "fa-box", fridge: "fa-temperature-low", hood: "fa-wind", island: "fa-table", bar: "fa-martini-glass", vanity: "fa-soap", media: "fa-tv", shelves: "fa-book", fireplace: "fa-fire", bench: "fa-couch", shower: "fa-shower", bathtub: "fa-bath", panelling: "fa-grip-vertical", mirror: "fa-user",
      balcony: "fa-building", lawn: "fa-seedling", terrace: "fa-border-all", deck: "fa-water", path: "fa-shoe-prints", flowerbed: "fa-spa", hedge: "fa-tree", planter: "fa-leaf", fence: "fa-bars-staggered", gardenwall: "fa-dungeon", pergola: "fa-archway"
    };

    if (picking) {
      const group = SHELL.detailGroup || base.group || "structure";
      const kinds = el("div", "sh-kinds sh-kinds-3");

      wrap.append(segment(SG.DETAIL_GROUPS.map(function (g) { return { value: g, label: T("sh_detail_group_" + g) }; }), group, function (v) { SHELL.detailGroup = v; ui.drawSide(); }, true));
      Object.keys(SG.DETAILS).filter(function (key) { return SG.DETAILS[key].group === group && (!SG.DETAILS[key].retired || key === kind); }).forEach(function (key) {
        kinds.append(el("button", "sh-kind" + (kind === key ? " active" : "")).append(icon(icons[key] || "fa-cube"), el("span", "", T("sh_detail_" + key))).on("click", function () { SHELL.detailGroup = group; onChange({ kind: key }); }));
      });
      wrap.append(kinds, el("div", "tk-hint", T("sh_detail_" + kind + "_text")), el("div", "tk-row wrap").append(
        button(T("sh_rotate_place", fmt(Number(SHELL.details.heading) || 0, 0)), "fa-rotate-right", "small", function () { SHELL.details.heading = ((Number(SHELL.details.heading) || 0) + 90) % 360; SHELL.dirty = true; ui.drawSide(); })
      ));
    }

    const mat = o.mat || base.mat;
    const sizes = el("div", "tk-grid2");
    const round = kind === "pillar" || kind === "ladder";
    const square = kind === "column";
    const thin = kind === "glassrail" || kind === "rail" || kind === "glasswall";

    if (!round && !square) sizes.append(field(T("sh_detail_length"), slider(0.2, 20, 0.05, Number(o.w) || base.w, function (v, final) { if (final) onChange({ w: v }); }, { places: 2 })));
    if (square) sizes.append(field(T("sh_detail_size"), slider(0.15, 1.2, 0.05, Number(o.w) || base.w, function (v, final) { if (final) onChange({ w: v, d: v }); }, { places: 2 })));
    if (!round && !square && !thin) sizes.append(field(T("sh_detail_depth"), slider(0.02, 8, 0.01, Number(o.d) || base.d, function (v, final) { if (final) onChange({ d: v }); }, { places: 2 })));
    if (base.h) sizes.append(field(T(kind === "balcony" ? "sh_detail_slab" : "sh_detail_height"), slider(0.02, 4, 0.01, Number(o.h) || base.h, function (v, final) { if (final) onChange({ h: v }); }, { places: 2 })));
    if (base.lift !== undefined) sizes.append(field(T("sh_detail_lift"), slider(0, 3, 0.05, o.lift === undefined ? base.lift : Number(o.lift), function (v, final) { if (final) onChange({ lift: v }); }, { places: 2 })));
    if (sizes.children().length) wrap.append(sizes);

    if (base.rail) wrap.append(field(T("sh_void_rail"), segment([{ value: "glass", label: T("sh_rail_glass") }, { value: "metal", label: T("sh_rail_metal") }, { value: "none", label: T("sh_none") }], o.rail || base.rail, function (v) { onChange({ rail: v }); }, true)));

    if (base.glass) {
      const glass = el("div", "sh-kinds sh-kinds-3");

      (SHELL.kit.glass || []).forEach(function (g) {
        glass.append(el("button", "sh-kind" + ((o.glass || base.glass) === g.key ? " active" : "")).append(el("span", "sh-glass-dot " + g.key), el("span", "", T("sh_glass_" + g.key))).on("click", function () { onChange({ glass: g.key }); }));
      });
      wrap.append(field(T("sh_glass"), glass));
    }

    if (kind === "elevator") {
      const lv = (SHELL.doc.levels || []).find(function (l) { return l.id === o.level; }) || { z: 0 };
      const room = o.at && SHELL.built && SHELL.built.derived ? SHELL.built.derived.rooms.find(function (r) { return Math.abs((Number(r.z) || 0) - (Number(lv.z) || 0)) < 0.3 && SG.insidePolygon && SG.insidePolygon(o.at, r.points); }) : null;
      const roomWall = (room && room.record && room.record.walls) || "white";

      wrap.append(
        el("div", "tk-hint", T("sh_elevator_hint")),
        field(T("sh_elevator_wall"), segment([{ value: "room", label: T("sh_elevator_wall_room") }, { value: "own", label: T("sh_elevator_wall_own") }], o.wall ? "own" : "room", function (v) { onChange({ wall: v === "own" ? roomWall : undefined }); }, true)),
        ui.palette(o.wall || roomWall, function (key) { onChange({ wall: key }); }, null, "walls")
      );
    }

    if (kind === "elevator") {
    } else if (kind === "ladder") {
      wrap.append(field(T("sh_detail_material"), segment([{ value: "steel", label: T("sh_ladder_metal") }, { value: "oak", label: T("sh_ladder_wood") }], ["oak", "darkwood", "walnut", "teak", "ash", "drift"].indexOf(mat) >= 0 ? "oak" : "steel", function (v) { onChange({ mat: v }); }, true)), el("div", "tk-hint", T("sh_ladder_hint")));
    } else if (round) {
      const row = el("div", "sh-palette-row");

      SG.PILLAR_MATERIALS.forEach(function (key) {
        row.append(el("button", "sh-mat" + (mat === key ? " active" : "")).attr("title", shellMaterialName(key)).append(shellSwatch(key, "big")).on("click", function () { onChange({ mat: key }); }));
      });
      wrap.append(field(T("sh_detail_material"), row));
    } else if (kind !== "rail" && kind !== "void" && kind !== "glassrail") {
      wrap.append(field(T(kind === "mirror" || kind === "glasswall" || kind === "shower" ? "sh_detail_frame" : "sh_detail_material"), ui.palette(mat, function (key) { onChange(base.top ? { mat: key } : { mat: key, top: undefined }); })));
    }

    if (base.built) wrap.append(field(T("sh_built_in"), segment([{ value: "", label: T("sh_none") }, { value: "sink", label: T("sh_built_sink") }, { value: "hob", label: T("sh_built_hob") }, { value: "both", label: T("sh_built_both") }], o.built || "", function (v) { onChange({ built: v || undefined }); }, true)));
    if (base.shaped) wrap.append(field(T("sh_detail_shape"), segment([{ value: "rect", label: T("sh_room_rect"), icon: "fa-square" }, { value: "round", label: T("sh_room_round"), icon: "fa-circle" }, { value: "oval", label: T("sh_room_oval"), icon: "fa-egg" }], o.shape || "rect", function (v) { onChange({ shape: v }); }, true)));
    if (base.top) wrap.append(field(T(kind === "shower" ? "sh_detail_tray" : kind === "bench" ? "sh_detail_seat" : kind === "floorpatch" ? "sh_detail_edge" : "sh_detail_top"), ui.palette(o.top || base.top, function (key) { onChange({ top: key }); })));
    if (base.handles || kind === "media") wrap.append(field(T("sh_handles"), segment(["bar", "long", "knob", "none"].map(function (h) { return { value: h, label: T("sh_handles_" + h) }; }), o.handles || (kind === "media" ? "none" : "bar"), function (v) { onChange({ handles: v }); }, true)));
    if (base.fronts) wrap.append(field(T("sh_fronts"), segment([0.4, 0.5, 0.6, 0.8, 1].map(function (f) { return { value: f, label: fmt(f * 100, 0) + " cm" }; }), Number(o.fronts) || base.fronts, function (v) { onChange({ fronts: Number(v) }); }, true)));
    if (picking) wrap.append(el("div", "tk-hint", T(SHELL_LINE_DETAILS.indexOf(kind) >= 0 ? "sh_detail_hint_line" : base.wall ? "sh_detail_hint_wall" : "sh_detail_hint")));

    return wrap;
  },
  drawDetails: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;

    (SHELL.built.derived.details || []).filter(function (det) { return det.level === SHELL.level; }).forEach(function (det) {
      const selected = SHELL.sel && SHELL.sel.kind === "detail" && SHELL.sel.id === det.id;

      if (det.kind === "pillar") {
        const c = ui.toScreen(det.at);

        ctx.beginPath();
        ctx.arc(c[0], c[1], Math.max(3, 0.22 * SHELL.view.scale), 0, Math.PI * 2);
      } else {
        ui.path(det.points);
        ctx.closePath();
      }

      ctx.fillStyle = det.kind === "beam" ? "rgba(120,80,50,.28)" : det.kind === "glassrail" ? "rgba(170,210,255,.35)" : det.kind === "platform" ? "rgba(255,255,255,.08)" : "rgba(230,230,240,.55)";
      ctx.fill();
      ctx.lineWidth = selected ? 2.5 : 1.2;
      ctx.strokeStyle = selected ? "#ff66ff" : det.kind === "beam" ? "rgba(255,200,150,.8)" : "rgba(255,255,255,.75)";
      if (det.kind === "beam") ctx.setLineDash([6, 4]);
      ctx.stroke();
      ctx.setLineDash([]);
    });
  },
  poolOptions: function (o, onChange) {
    const wrap = el("div", "tk-stack");
    const tiles = el("div", "sh-palette-row");
    const edges = el("div", "sh-palette-row");

    ["pooltile", "aqua", "mosaicw", "mosaicb", "subway", "hex", "marble"].forEach(function (key) {
      tiles.append(el("button", "sh-mat" + ((o.tile || "pooltile") === key ? " active" : "")).attr("title", shellMaterialName(key)).append(shellSwatch(key, "big")).on("click", function () { onChange({ tile: key }); }));
    });
    ["terrazzo", "marble", "slate", "polished", "oak", "white"].forEach(function (key) {
      edges.append(el("button", "sh-mat" + ((o.edge || "terrazzo") === key ? " active" : "")).attr("title", shellMaterialName(key)).append(shellSwatch(key, "big")).on("click", function () { onChange({ edge: key }); }));
    });

    wrap.append(
      el("div", "tk-grid2").append(
        field(T("sh_pool_width"), slider(1, 12, 0.25, Number(o.w) || 4, function (v, final) { if (final) onChange({ w: v }); }, { places: 2 })),
        field(T("sh_pool_length"), slider(1, 20, 0.25, Number(o.l) || 8, function (v, final) { if (final) onChange({ l: v }); }, { places: 2 }))
      ),
      field(T("sh_pool_depth"), slider(0.4, 3, 0.05, Number(o.depth) || 1.5, function (v, final) { if (final) onChange({ depth: v }); }, { places: 2 })),
      field(T("sh_pool_tile"), tiles),
      field(T("sh_pool_edge"), edges),
      switchRow(T("sh_pool_ladder"), o.ladder !== false, function (on) { onChange({ ladder: on }); }),
      el("div", "tk-hint", T("sh_pool_hint"))
    );

    return wrap;
  },
  drawStairs: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;

    SHELL.built.derived.stairs.filter(function (s) { return s.level === SHELL.level; }).forEach(function (s) {
      const selected = SHELL.sel && SHELL.sel.kind === "stairs" && SHELL.sel.id === s.id;
      const stroke = selected ? "#ff66ff" : "rgba(255,255,255,.55)";

      (s.footprint || []).forEach(function (poly) {
        ui.path(poly);
        ctx.closePath();
        ctx.fillStyle = "rgba(255,255,255,.08)";
        ctx.fill();
        ctx.lineWidth = selected ? 2 : 1;
        ctx.strokeStyle = stroke;
        ctx.stroke();
      });

      if (s.spiral) {
        const sp = s.spiral;

        for (let k = 0; k <= sp.count; k++) {
          const a = (sp.start + sp.sign * k * sp.angle) * Math.PI / 180;

          ui.path([sp.centre, SG.vec.add(sp.centre, [Math.cos(a) * sp.radius, Math.sin(a) * sp.radius])]);
          ctx.lineWidth = 1;
          ctx.strokeStyle = "rgba(255,255,255,.28)";
          ctx.stroke();
        }

        return;
      }

      let last = null;

      s.flights.forEach(function (f) {
        const corner = function (x, y) { return SG.vec.add(SG.vec.add(f.at, SG.vec.mul(f.side, x)), SG.vec.mul(f.fwd, y)); };

        for (let k = 1; k < f.count; k++) {
          ui.path([corner(-s.width / 2, k * s.stepRun), corner(s.width / 2, k * s.stepRun)]);
          ctx.lineWidth = 1;
          ctx.strokeStyle = "rgba(255,255,255,.25)";
          ctx.stroke();
        }

        ui.path([corner(0, 0.15), corner(0, f.count * s.stepRun - 0.15)]);
        ctx.strokeStyle = selected ? "#ff66ff" : "#ffffff";
        ctx.lineWidth = 1.5;
        ctx.stroke();
        last = { tip: corner(0, f.count * s.stepRun - 0.1), back: corner(0, f.count * s.stepRun - 0.45) };
      });

      if (last) {
        const tip = ui.toScreen(last.tip);
        const back = ui.toScreen(last.back);
        const ang = Math.atan2(tip[1] - back[1], tip[0] - back[0]);

        ctx.beginPath();
        ctx.moveTo(tip[0], tip[1]);
        ctx.lineTo(tip[0] - Math.cos(ang - 0.45) * 9, tip[1] - Math.sin(ang - 0.45) * 9);
        ctx.lineTo(tip[0] - Math.cos(ang + 0.45) * 9, tip[1] - Math.sin(ang + 0.45) * 9);
        ctx.closePath();
        ctx.fillStyle = selected ? "#ff66ff" : "#ffffff";
        ctx.fill();
      }
    });
  },
  drawPools: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;

    (SHELL.built.derived.pools || []).filter(function (pool) { return pool.level === SHELL.level; }).forEach(function (pool) {
      const selected = SHELL.sel && SHELL.sel.kind === "pool" && SHELL.sel.id === pool.id;

      ui.path(pool.points);
      ctx.closePath();
      ctx.lineWidth = selected ? 2.5 : 1.5;
      ctx.strokeStyle = selected ? "#ff66ff" : "rgba(160,230,255,.9)";
      ctx.stroke();

      const c = ui.toScreen(pool.at);

      ctx.font = "700 11px Montserrat, sans-serif";
      ctx.fillStyle = "rgba(255,255,255,.9)";
      ctx.textAlign = "center";
      ctx.fillText(T("sh_sel_pool") + " · " + fmt(pool.depth, 1) + " m", c[0], c[1] + 4);
    });
  },
  drawGhost: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const at = SHELL.ghostAt;

    if (SHELL.draft && SHELL.draft.kind === "detailline" && SHELL.draft.b) {
      const a = SHELL.draft.a;
      const b = SHELL.draft.b;
      const mid = ui.toScreen(SG.vec.mul(SG.vec.add(a, b), 0.5));

      ui.path([a, b]);
      ctx.strokeStyle = "#ff66ff";
      ctx.lineWidth = 3;
      ctx.stroke();
      ctx.fillStyle = "#fff";
      ctx.font = "600 12px Montserrat, sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(fmt(SG.vec.len(SG.vec.sub(b, a)), 2) + " m", mid[0], mid[1] - 8);
      return;
    }

    if (!at) return;

    if (SHELL.tool === "furniture" && SHELL.ghostModel) {
      const dims = SHELL.dims[SHELL.ghostModel] || { w: 0.6, d: 0.6 };
      const g = ui.ghostPlace(at);
      const h = g.h * Math.PI / 180;
      const ax = [Math.cos(h), Math.sin(h)];
      const ay = SG.vec.left(ax);
      const centre = g.p;
      const corner = function (x, y) { return SG.vec.add(SG.vec.add(centre, SG.vec.mul(ax, x)), SG.vec.mul(ay, y)); };

      ui.path([corner(-dims.w / 2, -dims.d / 2), corner(dims.w / 2, -dims.d / 2), corner(dims.w / 2, dims.d / 2), corner(-dims.w / 2, dims.d / 2)]);
      ctx.closePath();
      ctx.fillStyle = "rgba(255,102,255,.22)";
      ctx.fill();
      ctx.strokeStyle = g.snapped ? "#3ddc84" : "#ff66ff";
      ctx.lineWidth = 1.5;
      ctx.stroke();
      ui.path([centre, corner(0, -dims.d / 2 - 0.25)]);
      ctx.stroke();
    } else if (SHELL.tool === "details") {
      const shape = SG.detailShape(ui.detailFor(at));

      ui.path(shape.points);
      ctx.closePath();
      ctx.fillStyle = "rgba(255,102,255,.22)";
      ctx.fill();
      ctx.strokeStyle = "#ff66ff";
      ctx.setLineDash([5, 4]);
      ctx.lineWidth = 1.5;
      ctx.stroke();
      ctx.setLineDash([]);
    } else if (SHELL.tool === "pool") {
      const o = SHELL.pool;
      const c = [Math.round(at[0] / 0.25) * 0.25, Math.round(at[1] / 0.25) * 0.25];

      ui.path([[c[0] - o.w / 2, c[1] - o.l / 2], [c[0] + o.w / 2, c[1] - o.l / 2], [c[0] + o.w / 2, c[1] + o.l / 2], [c[0] - o.w / 2, c[1] + o.l / 2]]);
      ctx.closePath();
      ctx.fillStyle = "rgba(63,183,214,.25)";
      ctx.fill();
      ctx.strokeStyle = "rgba(160,230,255,.9)";
      ctx.setLineDash([5, 4]);
      ctx.stroke();
      ctx.setLineDash([]);
    }
  },
  drawPart: function () {
    const ui = SHELL_UI;
    const ctx = ui.ctx;
    const d = SHELL.draft;

    if (!d || (d.kind !== "part" && d.kind !== "part3d")) return;

    const wall = shellFind("walls", d.wall);

    if (!wall) return;

    const dw = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
    const n = SG.vec.mul(SG.vec.left(dw), d.side === "l" ? 1 : -1);
    const off = (Math.max(0.08, Number(wall.thick) || SHELL.thick) / 2 + 0.04);
    const pa = SG.vec.add(SG.vec.add(wall.a, SG.vec.mul(dw, d.a)), SG.vec.mul(n, off));
    const pb = SG.vec.add(SG.vec.add(wall.a, SG.vec.mul(dw, d.kind === "part" ? d.b : d.a + 0.05)), SG.vec.mul(n, off));

    ui.path([pa, pb]);
    ctx.lineWidth = 6;
    ctx.lineCap = "round";
    ctx.strokeStyle = "#ff66ff";
    ctx.stroke();
    ctx.lineCap = "butt";

    if (d.kind === "part") ui.lengthLabel(pa, pb, 0.35);
  },
  matColour: function (key) {
    SHELL.matColours = SHELL.matColours || {};

    if (!key) return [255, 102, 255];
    if (/^s[1-6]$/.test(key)) {
      const hex = (SHELL.doc.colours && SHELL.doc.colours[key]) || "#cccccc";

      return [parseInt(hex.slice(1, 3), 16), parseInt(hex.slice(3, 5), 16), parseInt(hex.slice(5, 7), 16)];
    }
    const src = /^c[1-6]$/.test(key) ? "../custom/" + shellCustomFile(key) + ".png" : "img/kit/" + key + ".webp";
    const cache = /^c[1-6]$/.test(key) ? key + ":" + shellCustomFile(key) : key;

    if (SHELL.matColours[cache]) return SHELL.matColours[cache].rgb || [255, 102, 255];

    SHELL.matColours[cache] = { rgb: null };

    const img = new Image();

    img.onload = function () {
      try {
        const c = document.createElement("canvas");

        c.width = 16;
        c.height = 16;
        c.getContext("2d").drawImage(img, 0, 0, 16, 16);

        const d = c.getContext("2d").getImageData(0, 0, 16, 16).data;
        let r = 0, g = 0, b = 0;

        for (let i = 0; i < d.length; i += 4) { r += d[i]; g += d[i + 1]; b += d[i + 2]; }
        SHELL.matColours[cache].rgb = [Math.round(r / 256), Math.round(g / 256), Math.round(b / 256)];
        SHELL.highlightKey = "";
        if (SHELL.lastHover) SHELL_UI.hover3d(SHELL.lastHover);
      } catch (error) {
        SHELL.matColours[cache].rgb = [255, 102, 255];
      }
    };
    img.src = src;

    return [255, 102, 255];
  },
  hover3d: function (hover) {
    SHELL.worldInput = true;

    try {
      return SHELL_UI.hover3dInner(hover);
    } finally {
      SHELL.worldInput = false;
    }
  },
  hover3dInner: function (hover) {
    const ui = SHELL_UI;

    hover = ui.rayRefine(hover);
    const p3 = hover.p || [0, 0, 0];
    const normal = hover.normal || [0, 0, 1];
    const tool = SHELL.tool;

    if (tool === "paint" && !hover.none) ui.paintPreview(ui.paintPatch([p3[0], p3[1]], normal, p3));
    const onPlane = SHELL_PLANE_TOOLS.indexOf(tool) >= 0 && Array.isArray(hover.plane);
    const p = onPlane ? [hover.plane[0], hover.plane[1]] : [p3[0], p3[1]];

    if (tool === "measure" && SHELL.measure && SHELL.measure.active) {
      SHELL.measure.b = ui.snap(p, SHELL.measure.a, false).p;
      SHELL.dirty = true;
    }
    const levels = shellLevels();
    const level = onPlane ? shellLevel() : levels.slice().reverse().find(function (l) { return p3[2] >= l.z - 0.3; }) || shellLevel();
    const lz = level.z || 0;
    const height = level.height || 2.8;
    const polys = [];
    const PINK = [255, 102, 255, 70];
    const add = function (points, colour, outline) { polys.push({ p: points, c: colour || PINK, o: outline !== false }); };
    const line = function (a, b) { polys.push({ p: [a, b], c: [255, 102, 255, 0], o: true }); };
    const labels = [];
    const label = function (q, text) { labels.push({ p: [SG.round(q[0], 2), SG.round(q[1], 2), SG.round(q[2], 2)], t: text }); };
    const metres = function (v) { return fmt(v, v < 10 ? 2 : 1) + " m"; };
    const prism = function (pts, z0, z1, colour) {
      for (let i = 0; i < pts.length; i++) {
        const a = pts[i];
        const b = pts[(i + 1) % pts.length];

        add([[a[0], a[1], z0], [b[0], b[1], z0], [b[0], b[1], z1], [a[0], a[1], z1]], colour, true);
      }
      add(pts.map(function (q) { return [q[0], q[1], z1]; }), colour, false);
    };
    const segmentBox = function (a, b, t, z0, z1, colour) {
      const d = SG.vec.norm(SG.vec.sub(b, a));
      const n = SG.vec.mul(SG.vec.left(d), t / 2);

      if (SG.vec.len(SG.vec.sub(b, a)) < 0.01) return;
      prism([SG.vec.add(a, n), SG.vec.add(b, n), SG.vec.sub(b, n), SG.vec.sub(a, n)], z0, z1, colour);
    };
    const post = function (q, colour) { segmentBox([q[0] - 0.04, q[1]], [q[0] + 0.04, q[1]], 0.08, lz, lz + height, colour || [255, 102, 255, 160]); };

    if (SHELL.copyRoom) {
      const groundP = Array.isArray(hover.plane) ? [hover.plane[0], hover.plane[1]] : p;
      const ghost = ui.copyRoomGhost(groundP);

      SHELL.copyAt = groundP;
      if (ghost) prism(ghost, (shellLevel().z || 0) + 0.02, (shellLevel().z || 0) + (shellLevel().height || 2.8), [255, 102, 255, 70]);
    }
    const wallFace = function (wall, sideKey, u0, u1, z0, z1, colour) {
      const dw = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
      const n = SG.vec.mul(SG.vec.left(dw), sideKey === "l" ? 1 : -1);
      const off = Math.max(0.08, Number(wall.thick) || SHELL.thick) / 2 + 0.02;
      const a = SG.vec.add(SG.vec.add(wall.a, SG.vec.mul(dw, u0)), SG.vec.mul(n, off));
      const b = SG.vec.add(SG.vec.add(wall.a, SG.vec.mul(dw, u1)), SG.vec.mul(n, off));

      add([[a[0], a[1], lz + z0], [b[0], b[1], lz + z0], [b[0], b[1], lz + z1], [a[0], a[1], lz + z1]], colour);
    };
    const roomAt = function (q) {
      return shellRoomAt(q, SHELL.built.derived.rooms.filter(function (r) { return r.level === level.id; }));
    };
    const inward = Math.abs(normal[2] || 0) < 0.5 ? [p[0] + normal[0] * 0.3, p[1] + normal[1] * 0.3] : p;
    const paintColour = function () { const c = ui.matColour(SHELL.paint.material); return [c[0], c[1], c[2], 215]; };

    SHELL.lastHover = hover;

    if (tool === "walls") {
      const d = SHELL.draft && SHELL.draft.kind === "walls" ? SHELL.draft : null;

      if (d && d.bulge) ui.bulgeTo(p);
      const from = d && d.points.length ? d.points[d.points.length - 1] : null;
      const snapped = ui.snap(p, from, false).p;
      const t = SHELL.thick || 0.2;

      const arc = function (a, b, bend, colour) {
        const pts = SG.wallPoints({ a: a, b: b, bend: bend || 0 });

        for (let i = 1; i < pts.length; i++) segmentBox(pts[i - 1], pts[i], t, lz, lz + height, colour);
      };

      if (d) {
        for (let i = 1; i < d.points.length; i++) arc(d.points[i - 1], d.points[i], (d.bends || [])[i - 1], [255, 255, 255, 120]);
        if (d.bulge) arc(d.bulge.a, d.bulge.b, d.bulge.bend, [255, 102, 255, 90]);
        else segmentBox(from, snapped, t, lz, lz + height, [255, 102, 255, 90]);

        if (!d.bulge && from && SG.vec.len(SG.vec.sub(snapped, from)) > 0.05) label([(from[0] + snapped[0]) / 2, (from[1] + snapped[1]) / 2, lz + height + 0.35], metres(SG.vec.len(SG.vec.sub(snapped, from))));
      }
      post(d && d.bulge ? d.bulge.b : snapped);
    } else if (tool === "room") {
      const snapped = ui.snap(p, null, false).p;
      const d = SHELL.draft && SHELL.draft.kind === "room" ? SHELL.draft : null;

      if (d && d.a && (SHELL.roomShape || "rect") !== "rect") {
        const t = SHELL.thick || 0.2;
        let ring = [];

        ui.roomWalls(d.a, snapped).forEach(function (seg) {
          const pts = SG.wallPoints(seg);

          for (let i = 1; i < pts.length; i++) segmentBox(pts[i - 1], pts[i], t, lz, lz + height, [255, 102, 255, 80]);
          ring = ring.concat(pts.slice(ring.length ? 1 : 0));
        });
        if (ring.length > 2) add(ring.map(function (q) { return [q[0], q[1], lz + 0.03]; }), [255, 102, 255, 50]);
      } else if (d && d.a) {
        const a = d.a;
        const c = snapped;
        const corners = [[a[0], a[1]], [c[0], a[1]], [c[0], c[1]], [a[0], c[1]]];
        const t = SHELL.thick || 0.2;

        for (let i = 0; i < 4; i++) segmentBox(corners[i], corners[(i + 1) % 4], t, lz, lz + height, [255, 102, 255, 80]);
        add(corners.map(function (q) { return [q[0], q[1], lz + 0.03]; }), [255, 102, 255, 50]);

        const wx = Math.abs(c[0] - a[0]);
        const wy = Math.abs(c[1] - a[1]);

        if (wx > 0.05 && wy > 0.05) label([(a[0] + c[0]) / 2, (a[1] + c[1]) / 2, lz + 0.4], fmt(wx, 2) + " x " + fmt(wy, 2) + " m   " + fmt(wx * wy, 1) + " m2");
      } else {
        post(snapped);
      }
    } else if (tool === "details" && SHELL.draft && SHELL.draft.kind === "detailline") {
      const a = SHELL.draft.a;
      const b = ui.snap(p, a, false).p;
      const length = SG.vec.len(SG.vec.sub(b, a));

      SHELL.draft.b = b;

      if (length >= 0.3) {
        const det = ui.detailFor(SG.vec.mul(SG.vec.add(a, b), 0.5));

        det.at = [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];
        det.w = Math.min(20, length);
        det.heading = ((Math.atan2(b[1] - a[1], b[0] - a[0]) * 180 / Math.PI) % 360 + 360) % 360;

        const shape = SG.detailShape(det);

        add(shape.points.map(function (q) { return [q[0], q[1], lz + 0.03]; }), [255, 102, 255, 70]);
        ui.previewDetail(det);
      } else {
        post(a);
      }
    } else if (tool === "details") {
      const det = ui.detailFor(ui.detailPoint(hover, p));
      const shape = SG.detailShape(det);

      add(shape.points.map(function (q) { return [q[0], q[1], lz + 0.03]; }), [255, 102, 255, 70]);
      ui.previewDetail(det);
    } else if (tool === "pool") {
      const o = SHELL.pool;
      const c = [Math.round(p[0] / 0.25) * 0.25, Math.round(p[1] / 0.25) * 0.25];
      const pts = [[c[0] - o.w / 2, c[1] - o.l / 2], [c[0] + o.w / 2, c[1] - o.l / 2], [c[0] + o.w / 2, c[1] + o.l / 2], [c[0] - o.w / 2, c[1] + o.l / 2]];

      add(pts.map(function (q) { return [q[0], q[1], lz + 0.03]; }), [63, 183, 214, 140]);
      prism(pts, lz - o.depth, lz + 0.02, [63, 183, 214, 50]);
    } else if (tool === "stairs") {
      const o = SHELL.stairs;
      const h = (Number(SHELL.ghostHeading) || 0) * Math.PI / 180;
      const fwd = [Math.cos(h + Math.PI / 2), Math.sin(h + Math.PI / 2)];
      const side = [fwd[1], -fwd[0]];
      const w = o.width || 1;
      const run = o.type === "spiral" ? 2 : o.type === "straight" ? 4.8 : o.type === "landing" ? 5.8 : 2.8;
      const span = o.type === "u" ? w * 2 + 0.1 : o.type === "l" ? w + 1.5 : w;
      const q = [Math.round(p[0] / 0.05) * 0.05, Math.round(p[1] / 0.05) * 0.05];
      const pts = [SG.vec.add(q, SG.vec.mul(side, -w / 2)), SG.vec.add(q, SG.vec.mul(side, span - w / 2)), SG.vec.add(SG.vec.add(q, SG.vec.mul(side, span - w / 2)), SG.vec.mul(fwd, run)), SG.vec.add(SG.vec.add(q, SG.vec.mul(side, -w / 2)), SG.vec.mul(fwd, run))];

      add(pts.map(function (r) { return [r[0], r[1], lz + 0.03]; }), [255, 102, 255, 70]);
    } else if (tool === "light" || tool === "points") {
      const z = tool === "light" ? lz + height - 0.05 : lz + 0.05;

      segmentBox([p[0] - 0.15, p[1]], [p[0] + 0.15, p[1]], 0.3, z - 0.02, z, [255, 220, 150, 200]);
      line([p[0], p[1], lz + 0.02], [p[0], p[1], lz + height]);
    } else if (tool === "paint" && (SHELL.paint.target === "side" || SHELL.paint.target === "part" || SHELL.paint.target === "auto" && ui.autoTarget(p, normal) === "side") || tool === "opening") {
      const near = ui.nearestWall(p, 0.6);

      if (near) {
        const wall = near.wall;
        const dw = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
        const sideKey = SG.vec.cross(SG.vec.sub(wall.b, wall.a), SG.vec.sub(inward, wall.a)) >= 0 ? "l" : "r";
        const total = SG.vec.len(SG.vec.sub(wall.b, wall.a));
        const u = SG.vec.dot(SG.vec.sub(p, wall.a), dw);

        if (tool === "opening") {
          const def = SG.OPENINGS[SHELL.sub] || SG.OPENINGS.door;
          const w = def.width;
          const z0 = def.sill || 0;
          const z1 = SHELL.sub === "round" ? z0 + w : z0 + (def.height || height - z0);

          wallFace(wall, sideKey, Math.max(0, u - w / 2), Math.min(total, u + w / 2), z0, Math.min(height, z1), [255, 255, 255, 110]);
        } else if (SHELL.paint.target === "part") {
          const d = SHELL.draft && SHELL.draft.kind === "part3d" && SHELL.draft.wall === wall.id ? SHELL.draft : null;
          const split = SHELL.part.split;
          const range = SHELL.part.height === "lower" ? [0, split] : SHELL.part.height === "upper" ? [split, height] : [0, height];

          if (d) {
            const zl = p3[2] - lz;
            const free = Math.abs(zl - d.z) > 0.25;

            wallFace(wall, sideKey, Math.min(d.a, u), Math.max(d.a, u), free ? Math.min(d.z, zl) : range[0], free ? Math.max(d.z, zl) : range[1], paintColour());
          } else {
            wallFace(wall, sideKey, Math.max(0, u - 0.25), Math.min(total, u + 0.25), range[0], range[1], paintColour());
          }
        } else {
          wallFace(wall, sideKey, 0, total, 0, height, paintColour());
        }
      }
    } else if (tool === "paint" && SHELL.paint.target === "tiles") {
      const cell = Math.abs(normal[2] || 0) > 0.5 ? ui.tileHover(p, ui.floorLevelAt(p3).id) : null;

      if (cell) add(cell.points.map(function (q) { return [q[0], q[1], cell.room.z + 0.03]; }), paintColour());
    } else if (tool === "hammer" || tool === "select") {
      const onWall = Math.abs(normal[2] || 0) < 0.5;
      const q = onWall ? [p[0] - normal[0] * 0.05, p[1] - normal[1] * 0.05] : p;
      let hit = ui.pick3d(p3, normal) || ui.hit(q);
      const red = tool === "hammer" ? [255, 60, 70, 110] : [255, 102, 255, 70];

      if (!onWall && hit && hit.kind === "wall") {
        hit = null;
        (SHELL.built.derived.details || []).forEach(function (det) { if (!hit && det.level === SHELL.level && SG.insidePolygon(q, det.points)) hit = { kind: "detail", id: det.id }; });
      }

      if (hit && hit.kind === "wall") {
        const wall = shellFind("walls", hit.id);

        if (wall) segmentBox(wall.a, wall.b, (Number(wall.thick) || SHELL.thick || 0.2) + 0.05, lz, lz + height + 0.03, red);
      } else if (hit && hit.kind === "opening") {
        const o = SHELL.built.derived.openings.find(function (x) { return x.id === hit.id; });

        if (o) segmentBox(SG.vec.add(o.c, SG.vec.mul(o.d, -o.width / 2)), SG.vec.add(o.c, SG.vec.mul(o.d, o.width / 2)), o.depth + 0.08, lz + o.z0, lz + o.z1, red);
      } else if (hit && hit.kind === "detail") {
        const item = (SHELL.built.derived.details || []).find(function (x) { return x.id === hit.id; });

        if (item) {
          const z0 = (Number(item.z) || lz) + (Number(item.lift) || 0);
          const z1 = item.kind === "elevator" ? Math.max.apply(null, levels.map(function (l) { return (Number(l.z) || 0) + (Number(l.height) || 2.8); })) : item.h === 0 ? (Number(item.z) || lz) + (Number(item.height) || height) : z0 + (Number(item.h) || 0.9);

          prism(item.points, z0 + 0.01, z1 + 0.04, red);
        }
      } else if (hit && hit.kind === "pool") {
        const item = (SHELL.built.derived.pools || []).find(function (x) { return x.id === hit.id; });

        if (item) prism(item.points, lz + 0.01, lz + 0.3, red);
      } else if (hit && hit.kind === "prop") {
        const prop = shellFind("props", hit.id);

        if (prop && prop.p) {
          const dims = SHELL.dims[prop.model] || { w: 0.6, d: 0.6, h: 1.2 };
          const hr = ((prop.r && prop.r[2]) || 0) * Math.PI / 180;
          const ax = [Math.cos(hr), Math.sin(hr)];
          const ay = [-Math.sin(hr), Math.cos(hr)];
          const hw = (dims.w || 0.6) / 2 + 0.04;
          const hd = (dims.d || 0.6) / 2 + 0.04;
          const corner = function (sx, sy) { return [prop.p[0] + ax[0] * sx * hw + ay[0] * sy * hd, prop.p[1] + ax[1] * sx * hw + ay[1] * sy * hd]; };

          prism([corner(-1, -1), corner(1, -1), corner(1, 1), corner(-1, 1)], prop.p[2] + 0.01, prop.p[2] + (dims.h || 1.2) + 0.04, red);
        }
      } else if (hit && hit.kind === "stairs") {
        const st = SHELL.built.derived.stairs.find(function (x) { return x.id === hit.id; });

        if (st) (st.footprint || []).forEach(function (poly) { prism(poly, lz + 0.01, lz + 1.2, red); });
      } else if (hit && hit.kind === "light") {
        segmentBox([p[0] - 0.2, p[1]], [p[0] + 0.2, p[1]], 0.4, lz + height - 0.1, lz + height, red);
      } else if (tool === "select") {
        const room = roomAt(inward);

        if (room) add(room.points.map(function (pt) { return [pt[0], pt[1], room.z + 0.03]; }), [255, 102, 255, 50]);
      }
    } else if (tool === "paint") {
      const room = roomAt(inward);

      if (room) {
        const target = SHELL.paint.target === "auto" ? ui.autoTarget(p, normal) : SHELL.paint.target;
        const colour = paintColour();

        if (target === "walls") {
          room.edges.forEach(function (e) {
            const d = SG.vec.norm(SG.vec.sub(e.b, e.a));
            const n = SG.vec.left(d);
            const a = SG.vec.add(e.a, SG.vec.mul(n, 0.02));
            const b = SG.vec.add(e.b, SG.vec.mul(n, 0.02));

            add([[a[0], a[1], room.z], [b[0], b[1], room.z], [b[0], b[1], room.z + room.height], [a[0], a[1], room.z + room.height]], colour);
          });
        } else {
          const z = target === "ceiling" ? room.z + room.height - 0.03 : room.z + 0.03;

          add(room.points.map(function (q) { return [q[0], q[1], z]; }), colour);
        }
      }
    }

    if (SHELL.liveGhost && SHELL.sel && SHELL.liveGhost.id === SHELL.sel.id) {
      const g = SHELL.liveGhost;
      const D = SHELL.built.derived;
      const gp = [Number(g.p[0]) || 0, Number(g.p[1]) || 0];
      const ghostColour = [120, 220, 255, 90];
      const moveShape = function (pts, at, fromH) {
        const dh = ((Number(g.h) || 0) - (Number(fromH) || 0)) * Math.PI / 180;
        const c = Math.cos(dh);
        const sn = Math.sin(dh);

        return pts.map(function (q) { const x = q[0] - at[0]; const y = q[1] - at[1]; return [gp[0] + x * c - y * sn, gp[1] + x * sn + y * c]; });
      };

      if (g.kind === "opening") {
        const o = (D.openings || []).find(function (x) { return x.id === g.id; });
        const wall = o ? shellFind("walls", o.wall) : null;

        if (o && wall) {
          const d = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
          const t = SG.vec.dot(SG.vec.sub(gp, wall.a), d);
          const c = SG.vec.add(wall.a, SG.vec.mul(d, Math.round(t / 0.05) * 0.05));
          const oz = (Number((SG.levelOf(SHELL.doc, o.level) || {}).z) || 0);

          segmentBox(SG.vec.add(c, SG.vec.mul(d, -o.width / 2)), SG.vec.add(c, SG.vec.mul(d, o.width / 2)), o.depth + 0.1, oz + o.z0, oz + o.z1, ghostColour);
        }
      } else {
        const coll = { stairs: "stairs", pool: "pools", detail: "details" }[g.kind];
        const src = coll ? shellFind(coll, g.id) : null;
        const item = g.kind === "stairs" ? (D.stairs || []).find(function (x) { return x.id === g.id; }) : g.kind === "pool" ? (D.pools || []).find(function (x) { return x.id === g.id; }) : (D.details || []).find(function (x) { return x.id === g.id; });

        if (src && item && Array.isArray(src.at)) {
          const gz = Number(item.z) || (Number((SG.levelOf(SHELL.doc, src.level) || {}).z) || 0);
          const shapes = g.kind === "stairs" ? (item.footprint || []) : [item.points || []];
          const tall = g.kind === "stairs" ? Math.max(1.2, Number(item.rise) || 2.8) : g.kind === "pool" ? 0.3 : item.kind === "elevator" ? 2.8 : Math.max(0.3, Number(item.h) || Number(item.height) || 1);

          shapes.forEach(function (poly) { if (poly.length > 2) prism(moveShape(poly, src.at, src.heading), gz + 0.02, gz + tall, ghostColour); });
        }
      }
    }

    const key = JSON.stringify(polys);
    const labelKey = JSON.stringify(labels);

    if (key === SHELL.highlightKey && labelKey === SHELL.labelKey) return;

    SHELL.highlightKey = key;
    SHELL.labelKey = labelKey;
    toolAction("highlight", { polys: polys.map(function (poly) { return { p: poly.p.map(function (q) { return q.map(function (v) { return SG.round(v, 3); }); }), c: poly.c, o: poly.o }; }), labels: labels });
  }
});

TOOL_UI.shell = {
  panel: "shell",
  hover: true,
  group: "build",
  start: function (args) {
    SHELL_UI.start(args || {});
  },
  stop: function () {
    SHELL_UI.stop();
  },
  escape: function () {
    SHELL_UI.escape();
  },
  data: function (data) {
    if (data.opened === true) {
      SHELL.sentCut = null;
      SHELL.sentGrid = null;
      SHELL.sentBox = null;
      shellKit().then(function () { SHELL.sentCut = null; SHELL.sentGrid = null; SHELL.sentBox = null; SHELL_UI.enter(data); SHELL_UI.hints(); });
      return;
    }

    if (data.opened === false) {
      SHELL_UI.library();
      return;
    }

    if (data.doc && SHELL.open) shellServerDoc(data.doc, data.built, data.summary);

    if (data.patched) {
      const ackRev = data.patched && data.patched.ok !== false ? Number(data.patched.rev) || 0 : 0;
      const shownRev = Number(SHELL.doc && SHELL.doc.rev) || 0;

      SHELL.pending = SHELL.pending.filter(function (p) {
        if (p.token !== data.token) return true;
        if (ackRev > shownRev) {
          p.acked = ackRev;
          return true;
        }

        return false;
      });

      if (data.patched.ok === false) {
        SHELL.pending = [];
        showNotify({ title: T("notify_title"), text: data.patched.message || T("sh_patch_failed"), type: "error" });
        SHELL_SFX.play("error");
      }
    }

    if (data.editors) {
      SHELL.editors = data.editors;
      SHELL.dirty = true;

      if (SHELL.panel === "team") SHELL_UI.drawSide();
    }

    if (data.walkbake === false) {
      SHELL.walkBaked = null;
      showNotify({ title: T("notify_title"), text: T("sh_walk_bake_failed", ""), type: "error", timeout: 7000 });
    }

    if (data.walking === false) {
      SHELL.walking = false;
      SHELL_UI.root.removeClass("walking");
      SHELL_UI.walkBar.addClass("hidden");
    }

    if (data.placed && SHELL.open) {
      const prop = { id: SG.uid("p"), model: data.placed.model, p: data.placed.p, r: data.placed.r };

      shellCommit({ set: { props: [prop] } });
      toolAction("dims", { models: [prop.model] });

      if (!data.placed.keep) {
        SHELL.ghostModel = null;
        SHELL.ghostAt = null;
        SHELL_UI.select({ kind: "prop", id: prop.id });
      }
    }

    if (data.propmoved && SHELL.open) {
      const prop = shellFind("props", data.propmoved.id);

      if (prop) shellCommit({ set: { props: [Object.assign(SG.clone(prop), { p: data.propmoved.p, r: data.propmoved.r })] } }, { merge: "prop:" + prop.id });
    }

    if (data.anchorlive && SHELL.open) {
      SHELL.liveGhost = data.anchorlive;
      SHELL.highlightKey = "";
      if (SHELL.lastHover) SHELL_UI.hover3dInner(SHELL.lastHover);
    }

    if (data.anchormoved && SHELL.open) {
      const am = data.anchormoved;
      const coll = { stairs: "stairs", pool: "pools", detail: "details", opening: "openings" }[am.kind];
      const item = coll ? shellFind(coll, am.id) : null;

      SHELL.liveGhost = null;

      if (item && Array.isArray(am.p) && am.kind === "opening") {
        const wall = shellFind("walls", item.wall);

        if (wall) {
          const d = SG.vec.norm(SG.vec.sub(wall.b, wall.a));
          const t = SG.round(Math.round(SG.vec.dot(SG.vec.sub([Number(am.p[0]) || 0, Number(am.p[1]) || 0], wall.a), d) / 0.05) * 0.05, 3);

          if (t !== item.t) shellCommit({ set: { openings: [Object.assign(SG.clone(item), { t: t })] } }, { merge: "opening:" + item.id });
        }
      } else if (item && Array.isArray(am.p)) {
        const patch = { set: {} };
        const moved = Object.assign(SG.clone(item), { at: [SG.round(Number(am.p[0]) || 0, 3), SG.round(Number(am.p[1]) || 0, 3)], heading: SG.round(Number(am.h) || 0, 1) });

        patch.set[coll] = [moved];
        shellCommit(patch, { merge: am.kind + ":" + item.id });
      }
    }

    if (data.selected && SHELL.open && SHELL.tool === "hammer") {
      SHELL_UI.select({ kind: data.selected.kind, id: data.selected.id });
      SHELL_UI.deleteSelection();
    } else if (data.selected && SHELL.open && (SHELL.tool === "select" || SHELL.tool === "furniture")) SHELL_UI.select({ kind: data.selected.kind, id: data.selected.id });

    if (data.parts && SHELL.open) {
      const before = SHELL.parts ? [SHELL.parts.shown, SHELL.parts.total, SHELL.parts.full].join("|") : "";

      SHELL.parts = data.parts;
      if (before !== [data.parts.shown, data.parts.total, data.parts.full].join("|")) SHELL_UI.root.find(".sh-parts").replaceWith(shellPartsChip(data.parts));
    }

    if (data.clicked && SHELL.open) SHELL_UI.worldClick(data.clicked);

    if (data.hover && SHELL.open) SHELL_UI.hover3d(data.hover);

    if (data.picked && SHELL.open) {
      const points = {};
      const name = data.picked.name;
      const def = SHELL_POINTS.find(function (x) { return x.id === name; });
      const value = { p: data.picked.p, h: SG.round(((data.picked.h % 360) + 360) % 360, 1) };

      if (def && def.many) {
        const list = SG.clone(SHELL.doc.points[name] || []);
        const re = SHELL.repick && SHELL.repick.name === name ? SHELL.repick.index : -1;

        if (name !== "clean") value.water = [value.p[0], value.p[1], SG.round(value.p[2] + (name === "showers" ? 2.0 : 0.95), 3)];
        if (re >= 0 && list[re]) list[re] = value;
        else list.push(value);

        points[name] = list;
      } else if (def) {
        points[name] = value;
      }

      SHELL.repick = null;
      shellCommit({ root: { points: points } });
    }

    if (data.furnished && SHELL.open) {
      const props = (data.furnished.props || []).map(function (item) { return { id: SG.uid("p"), model: item.model, p: item.p, r: item.r }; });

      if (props.length) {
        shellCommit({ set: { props: props } });
        toolAction("dims", { models: props.map(function (p) { return p.model; }) });
        if (!SHELL.furnishing) showNotify({ title: T("notify_title"), text: T("sh_furnished", props.length), type: "success" });
      } else if (!SHELL.furnishing) {
        showNotify({ title: T("notify_title"), text: T("sh_furnish_nothing"), type: "warning" });
      }

      if (SHELL.furnishing) setTimeout(function () { SHELL_UI.furnishNext(); }, 250);
    }

    if (data.dims) {
      Object.assign(SHELL.dims, data.dims);
      SHELL.dirty = true;
    }

    if (data.index && !SHELL.open && SHELL_UI.root) SHELL_UI.library();
  }
};

function shellSlug(text) {
  return String(text || "shell").toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "").slice(0, 28) || "shell";
}

function shellHex(buffer) {
  return Array.prototype.map.call(new Uint8Array(buffer), function (b) { return b.toString(16).padStart(2, "0"); }).join("");
}

function shellBase64(bytes) {
  let out = "";
  const step = 0x8000;

  for (let i = 0; i < bytes.length; i += step) out += String.fromCharCode.apply(null, bytes.subarray(i, i + step));

  return btoa(out);
}

function uploadRequest(action, payload) {
  return new Promise(function (resolve) {
    const tokenId = "u" + SHELL.nextToken++;

    SHELL.replies[tokenId] = resolve;
    post("upload", { action: action, payload: payload, token: tokenId });
  });
}

const COLLECTION_DEFAULTS = { shells: "rtx_custom_shells", mlos: "rtx_custom_mlos", clothes: "rtx_custom_clothes", vehicles: "rtx_custom_vehicles", tattoos: "rtx_custom_tattoos", weapons: "rtx_custom_weapons" };

function collectionName(kind) {
  const list = (STATE.setup && STATE.setup.collections) || {};
  const value = String(list[kind] || "").toLowerCase().replace(/[^a-z0-9_\-]/g, "");

  return /^[a-z0-9][a-z0-9_\-]{1,47}$/.test(value) ? value : COLLECTION_DEFAULTS[kind];
}

function collectionDone(reply) {
  return reply.item ? T("sh_make_done_collection", reply.item, reply.resource, reply.items, T("state_" + reply.state)) : T("sh_make_done", reply.resource, T("state_" + reply.state));
}

function uploadResource(name, files, progress, collection) {
  const encoder = new TextEncoder();
  const list = files.map(function (f) { return { rel: f.rel, bytes: f.bytes instanceof Uint8Array ? f.bytes : f.bytes ? new Uint8Array(f.bytes) : encoder.encode(f.text || "") }; });

  return Promise.all(list.map(function (f) { return crypto.subtle.digest("SHA-256", f.bytes); })).then(function (hashes) {
    return uploadRequest("begin", { name: name, collection: collection || null, files: list.map(function (f, i) { return { path: f.rel, size: f.bytes.length, sha256: shellHex(hashes[i]) }; }) });
  }).then(function (reply) {
    if (!reply || !reply.ok) return reply || { ok: false };

    const session = reply.session;
    const size = 196608;
    const total = list.reduce(function (s, f) { return s + f.bytes.length; }, 0) || 1;
    let sent = 0;
    let chain = Promise.resolve({ ok: true });

    list.forEach(function (file, index) {
      for (let offset = 0; offset < file.bytes.length || (offset === 0 && file.bytes.length === 0); offset += size) {
        const part = file.bytes.subarray(offset, offset + size);
        const at = offset;

        chain = chain.then(function (last) {
          if (!last || !last.ok) return last;
          if (part.length === 0) return { ok: true };

          return uploadRequest("chunk", { session: session, index: index, offset: at, data: shellBase64(part) }).then(function (r) {
            sent += part.length;
            if (progress) progress(sent / total);
            return r;
          });
        });

        if (file.bytes.length === 0) break;
      }
    });

    return chain.then(function (last) {
      if (!last || !last.ok) return last || { ok: false };

      return uploadRequest("finish", { session: session });
    });
  });
}

function shellHousingTexts(model, doc) {
  const p = doc.points || {};
  const v = function (a, lift) { return a ? "vector3(" + fmt(a[0], 6) + ", " + fmt(a[1], 6) + ", " + fmt(a[2] + (lift || 0), 6) + ")" : "vector3(0.000000, 0.000000, 0.000000)"; };
  const exit = p.exit || { p: [0, 0, 0], h: 0 };
  const name = String(doc.name || model).replace(/"/g, "'");
  const rtx = [
    "[\"" + model + "\"] = {",
    "\tlabel = \"" + name + "\",",
    "\tobject = \"" + model + "\",",
    "\ttags = {\"Empty\", \"RTX\", \"creator\"},",
    "\texitcoords = {coords = " + v(exit.p, 0.47) + ", heading = " + fmt(exit.h || 0, 2) + "},",
    "\tmanagmentcoords = {coords = " + v(p.management && p.management.p, 0.47) + "},",
    "\twardrobecoords = {coords = " + v(p.wardrobe && p.wardrobe.p, 0.47) + "},",
    "\tstoragecoords = {coords = " + v(p.storage && p.storage.p, 0.47) + "},",
    "\tcookcoords = {coords = " + v(p.cook && p.cook.p, 0.48) + "},",
    "\tsinkcoords = {" + (p.sinks || []).map(function (s) { return "{coordswater = " + v(s.water) + ", coordsplayer = " + v(s.p, 0.48) + ", heading = " + fmt(s.h || 0, 2) + "}"; }).join(", ") + "},",
    "\tshowercoords = {" + (p.showers || []).map(function (s) { return "{coordswater = " + v(s.water) + ", coordsplayer = " + v(s.p, 0.62) + ", heading = " + fmt(s.h || 0, 2) + "}"; }).join(", ") + "},",
    "\tcleanpoints = {",
    (p.clean || []).map(function (c) { return "\t\t{coords = " + v(c.p, -0.02) + "},"; }).join("\n"),
    "\t},",
    "\timages = {},",
    "},"
  ].filter(function (line) { return line !== ""; }).join("\n");
  const ps = [
    "[\"" + name + "\"] = {",
    "\tlabel = \"" + name + "\",",
    "\thash = `" + model + "`,",
    "\tdoorOffset = { x = " + fmt(exit.p[0], 4) + ", y = " + fmt(exit.p[1], 4) + ", z = " + fmt(exit.p[2], 4) + ", h = " + fmt(exit.h || 0, 2) + ", width = 2.0 },",
    "\tstash = { maxweight = 1000000, slots = 15 },",
    "\timgs = {},",
    "},"
  ].join("\n");
  const qb = "local shell = exports['qb-interior']:CreateShell(spawn, {x = " + fmt(exit.p[0], 4) + ", y = " + fmt(exit.p[1], 4) + ", z = " + fmt(exit.p[2] + 0.47, 4) + ", h = " + fmt(exit.h || 0, 2) + "}, \"" + model + "\")";
  const offsets = {};

  SHELL_POINTS.forEach(function (def) {
    const value = p[def.id];

    if (def.many) offsets[def.id] = (value || []).map(function (x) { return { coords: { x: x.p[0], y: x.p[1], z: x.p[2] }, heading: x.h || 0, water: x.water ? { x: x.water[0], y: x.water[1], z: x.water[2] } : undefined }; });
    else if (value) offsets[def.id] = { coords: { x: value.p[0], y: value.p[1], z: value.p[2] }, heading: value.h || 0 };
  });

  const lua = "ShellOffsets = {\n\tmodel = \"" + model + "\",\n" + Object.keys(offsets).map(function (key) {
    const value = offsets[key];

    if (Array.isArray(value)) return "\t" + key + " = {" + value.map(function (x) { return "vector4(" + [x.coords.x, x.coords.y, x.coords.z, x.heading].map(function (n) { return fmt(n, 4); }).join(", ") + ")"; }).join(", ") + "},";

    return "\t" + key + " = vector4(" + [value.coords.x, value.coords.y, value.coords.z, value.heading].map(function (n) { return fmt(n, 4); }).join(", ") + "),";
  }).join("\n") + "\n}";

  const base = [0, 0, 500];
  const vv = function (a, lift) { return "vector3(" + fmt(base[0] + a[0], 4) + ", " + fmt(base[1] + a[1], 4) + ", " + fmt(base[2] + a[2] + (lift || 0), 4) + ")"; };
  const v4 = function (a, h, lift) { return "vector4(" + fmt(base[0] + a[0], 4) + ", " + fmt(base[1] + a[1], 4) + ", " + fmt(base[2] + a[2] + (lift || 0), 4) + ", " + fmt(h || 0, 2) + ")"; };
  const vmsTarget = function (spot, kind) {
    const water = spot.water || spot.p;
    const options = kind === "shower"
      ? ["\t\t\t\t\t{ timeUsage = 10000, targetIcon = \"fa-solid fa-shower\", type = 'shower', waterUsage = 20000, billType = 'water', coords = { particles = " + vv(water) + ", player = " + v4(spot.p, spot.h, 1.0) + " } },"]
      : ["\t\t\t\t\t{ timeUsage = 7000, targetIcon = \"fa-solid fa-sink\", type = 'sink', waterUsage = 5000, billType = 'water', coords = { particles = " + vv(water) + ", player = " + v4(spot.p, spot.h, 1.0) + " } },",
        "\t\t\t\t\t{ timeUsage = 5000, targetIcon = \"fa-solid fa-glass-water-droplet\", type = 'sink_drink', waterUsage = 300, billType = 'water', coords = { particles = " + vv(water) + ", player = " + v4(spot.p, spot.h, 1.0) + " } },"];

    return ["\t\t\t{", "\t\t\t\ttarget = " + v4(water, spot.h, 0) + ",", "\t\t\t\ttargetSize = vector3(0.9, 0.8, 2.0),", "\t\t\t\toptions = {"].concat(options, ["\t\t\t\t}", "\t\t\t},"]).join("\n");
  };
  const rooms = SHELL.built && SHELL.built.derived ? SHELL.built.derived.rooms.length : 1;
  const vms = [
    "local shells = {",
    "\t['" + model + "'] = {",
    "\t\tlabel = '" + name.replace(/['\\]/g, "") + "',",
    "\t\ttags = {'rtx', 'creator'},",
    "\t\trooms = " + rooms + ",",
    "\t\tmodel = '" + model + "',",
    "\t\tdoors = { x = " + fmt(base[0] + exit.p[0], 4) + ", y = " + fmt(base[1] + exit.p[1], 4) + ", z = " + fmt(base[2] + exit.p[2] + 1.0, 4) + ", heading = " + fmt(exit.h || 0, 2) + " },",
    "\t\tinteractable = {",
    (p.sinks || []).map(function (sp) { return vmsTarget(sp, "sink"); }).concat((p.showers || []).map(function (sp) { return vmsTarget(sp, "shower"); })).join("\n"),
    "\t\t},",
    "\t\timages = {},",
    "\t},",
    "}",
    "",
    "addShells(shells)"
  ].filter(function (line) { return line !== ""; }).join("\n").replace("}\naddShells", "}\n\naddShells");

  const ex = exit.p || [0, 0, 0];
  const v3 = function (a) { return "vector3(" + fmt(a[0], 6) + ", " + fmt(a[1], 6) + ", " + fmt(a[2], 6) + ")"; };
  const plain = name.replace(/["'\\`]/g, "");
  const heading = fmt(exit.h || 0, 2);
  const esxPositions = [];

  if (p.wardrobe && p.wardrobe.p) esxPositions.push("\t\tWardrobe = " + v3([ex[0] - p.wardrobe.p[0], ex[1] - p.wardrobe.p[1], ex[2] - p.wardrobe.p[2] - 1]) + ",");
  if (p.storage && p.storage.p) esxPositions.push("\t\tStorage = " + v3([ex[0] - p.storage.p[0], ex[1] - p.storage.p[1], ex[2] - p.storage.p[2] - 1]) + ",");

  const esx = [
    "{",
    "\tlabel = \"" + plain + "\",",
    "\tvalue = \"" + model + "\",",
    "\tpositions = {",
    esxPositions.join("\n"),
    "\t},",
    "\ttype = \"shell\",",
    "\tpos = " + v3([-ex[0], -ex[1], -ex[2]]),
    "},"
  ].filter(function (line) { return line !== ""; }).join("\n");
  const area = SHELL.built && SHELL.built.derived ? SHELL.built.derived.rooms.reduce(function (sum, r) { return sum + (Number(r.area) || 0); }, 0) : 0;
  const flat = /flat|apartment|studio|motel|hotel/.test(String(doc.type || "")) ;
  const category = flat ? (area > 90 || rooms > 5 ? "highend_apartment" : "lowtier_apartment") : (area > 180 || rooms > 8 ? "highend_house" : area > 70 || rooms > 4 ? "midtier_house" : "lowtier_house");
  const loaf = [
    "[\"" + plain + "\"] = {",
    "\tobject = `" + model + "`,",
    "\tcategory = \"" + category + "\",",
    "\tdoorOffset = " + v3(ex) + ",",
    "\tdoorHeading = " + heading + ",",
    "},"
  ].join("\n");
  const nolag = [
    "CreateThread(function()",
    "\tlocal shells = {",
    "\t\t{",
    "\t\t\tnameTier = `" + model + "`,",
    "\t\t\toffset = vector4(" + fmt(ex[0], 6) + ", " + fmt(ex[1], 6) + ", " + fmt(ex[2] + 0.47, 6) + ", " + heading + "),",
    "\t\t\tlabel = '" + plain + "',",
    "\t\t\tinventory = { weight = 500000, slots = 40 }",
    "\t\t},",
    "\t}",
    "",
    "\tinsertInteriors(shells)",
    "end)"
  ].join("\n");
  const bcs = "[\"" + model + "\"] = vec4(" + fmt(ex[0], 6) + ", " + fmt(ex[1], 6) + ", " + fmt(ex[2], 6) + ", " + heading + "),";
  const spot = function (point) { return point && point.p ? point.p : ex; };
  const rx = [
    "Config.Shells[\"" + model + "\"] = {",
    "\toffsets = {",
    "\t\tdoor = " + v3(ex) + ",",
    "\t\tdoorHeading = " + heading + ",",
    "\t\tlaptop = " + v3(spot(p.management)) + ",",
    "\t\tlaptopHeading = " + fmt((p.management && p.management.h) || exit.h || 0, 2) + ",",
    "\t\tstash = " + v3(spot(p.storage)) + ",",
    "\t\tclothing = " + v3(spot(p.wardrobe)) + ",",
    "\t},",
    "}"
  ].join("\n");

  return { rtx_housing: rtx, "ps-housing": ps, vms_housing: vms, "qb-interior": qb, esx_property: esx, loaf_housing: loaf, nolag_properties: nolag, bcs_housing: bcs, RxHousing: rx, lua: lua, json: JSON.stringify({ model: model, name: name, points: offsets }, null, 1) };
}

const SHELL_HOUSING_FILES = [["rtx_housing", "rtx_housing.lua"], ["ps-housing", "ps-housing.lua"], ["vms_housing", "vms_housing.lua"], ["qb-interior", "qb-interior.lua"], ["esx_property", "esx_property.lua"], ["loaf_housing", "loaf_housing.lua"], ["nolag_properties", "nolag_properties.lua"], ["bcs_housing", "bcs_housing.lua"], ["RxHousing", "RxHousing.lua"], ["lua", "offsets.lua"], ["json", "offsets.json"]];

function shellHousingFiles(texts) {
  return SHELL_HOUSING_FILES.filter(function (f) { return texts[f[0]]; }).map(function (f) { return { rel: "housing/" + f[1], text: texts[f[0]] + "\r\n" }; });
}

Object.assign(SHELL_UI, {
  finishDialog: function () {
    const ui = SHELL_UI;
    const bad = SHELL.checks.filter(function (c) { return c.level === "bad"; });
    const permanent = SHELL.doc.permanent || (SHELL.summary && SHELL.summary.permanent);
    const nameBox = input((permanent && permanent.output === "shell" && (permanent.model || permanent.resource)) || "rtx_shell_" + shellSlug(SHELL.doc.name), "", null, { mono: true, small: true });
    const nameField = field(T(ui.collect !== false ? "sh_finish_item" : "sh_finish_resource"), nameBox, T(ui.collect !== false ? "sh_finish_item_hint" : "sh_finish_resource_hint"));
    const collectRow = switchRow(T("sh_collect"), ui.collect !== false, function (on) {
      ui.collect = on;
      nameField.find(".tk-field-label span").text(T(on ? "sh_finish_item" : "sh_finish_resource"));
      nameField.children(".tk-hint").text(T(on ? "sh_finish_item_hint" : "sh_finish_resource_hint"));
    }, T("sh_collect_hint", collectionName("shells"), collectionName("mlos"))).addClass("sh-collect-row");
    const card = function (iconName, title, text, action) {
      return el("button", "sh-finish-card").append(el("div", "sh-finish-icon").append(icon(iconName)), el("div", "").append(el("div", "tk-tool-name", title), el("div", "tk-hint", text))).on("click", action);
    };

    modal({
      kicker: T("sh_kicker"),
      title: T("sh_finish_title"),
      wide: true,
      body: [
        bad.length ? el("div", "sh-finish-warn").append(icon("fa-circle-exclamation"), $("<span></span>").text(T("sh_finish_bad", bad.length))) : null,
        collectRow,
        nameField,
        el("div", "sh-finish-grid").append(
          card("fa-house-chimney-window", T("sh_finish_shell"), T("sh_finish_shell_text"), function () { closeModal(); ui.make("shell", nameBox.val()); }),
          card("fa-building", T("sh_finish_mlo"), T("sh_finish_mlo_text"), function () { const mloName = nameBox.val().replace(/^rtx_shell_/, "rtx_mlo_"); closeModal(); ui.placeMlo(mloName); }),
          card("fa-file-code", T("sh_finish_export"), T("sh_finish_export_text"), function () { closeModal(); ui.exportDialog((permanent && permanent.model) || shellSlug(nameBox.val())); })
        ),
        permanent ? el("div", "tk-hint", T("sh_finish_already", permanent.resource, timeAgo(permanent.at))) : null
      ],
      actions: [{ label: T("close") }]
    });
  },
  make: function (output, rawName, place) {
    const ui = SHELL_UI;
    const name = shellSlug(rawName).replace(/^_+/, "");
    const bar = el("div", "sh-progress").append(el("div", "sh-progress-fill"));
    const line = el("div", "tk-hint", T("sh_make_building"));

    if (!/^[a-z0-9][a-z0-9_\-]{1,47}$/.test(name)) {
      showNotify({ title: T("notify_title"), text: T("sh_make_bad_name"), type: "error" });
      return;
    }

    modal({ kicker: T("sh_kicker"), title: output === "mlo" ? T("sh_finish_mlo") : T("sh_finish_shell"), body: [line, bar], actions: [] });

    const options = { name: name, output: output };
    const fill = function (ratio) { bar.find(".sh-progress-fill").css("width", Math.round(Math.max(0, Math.min(1, ratio)) * 100) + "%"); };
    const images = {};
    const flags = {};
    const loadTextures = function () {
      let keys = [];

      try {
        const project = SG.toProject(SHELL.doc, SHELL.kit, { name: name, output: output }).project;

        keys = (project.materials || []).filter(function (m) { return m.source === "builtin" && /^m_/.test(m.id) && !/^m_s[1-6]$/.test(m.id) && !/^m_[pw]\d\d$/.test(m.id); }).map(function (m) { return m.id.slice(2); });
      } catch (error) {
        keys = [];
      }

      let chain = Promise.resolve();

      keys.forEach(function (key, index) {
        chain = chain.then(function () {
          line.text(T("sh_make_textures", index + 1, keys.length));
          fill(0.3 * index / Math.max(1, keys.length));

          return shellRequest("texture", /^c[1-6]$/.test(key) ? { key: key, file: shellCustomFile(key) } : { key: key }).then(function (reply) {
            if (!reply || !reply.data) return null;

            return new Promise(function (resolve) {
              const img = new Image();

              img.onload = function () {
                try {
                  const canvas = document.createElement("canvas");

                  canvas.width = img.width;
                  canvas.height = img.height;

                  const ctx = canvas.getContext("2d");

                  ctx.drawImage(img, 0, 0);
                  images["kit/" + key] = { width: img.width, height: img.height, rgba: new Uint8Array(ctx.getImageData(0, 0, img.width, img.height).data.buffer) };
                  flags[key] = true;
                } catch (error) {
                  flags[key] = false;
                }

                resolve(null);
              };
              img.onerror = function () { resolve(null); };
              img.src = "data:image/jpeg;base64," + reply.data;
            });
          });
        });
      });

      return chain;
    };
    const go = function () {
      let worker;
      const started = Date.now();
      const ticker = setInterval(function () {
        const seconds = Math.round((Date.now() - started) / 1000);

        line.text(T("sh_make_building_time", seconds) + (seconds > 20 ? "  ·  " + T("sh_make_patience") : ""));
        fill(0.3 + 0.62 * (1 - Math.exp(-seconds / 50)));
        bar.addClass("busy");
      }, 500);

      try {
        worker = new Worker("shellworker.js");
      } catch (error) {
        line.text(T("sh_make_failed", String(error && error.message)));
        $("#modal-actions").append(button(T("close"), null, "", closeModal));
        return;
      }

      worker.onmessage = function (event) {
        const result = event.data || {};

        clearInterval(ticker);
        bar.removeClass("busy");
        worker.terminate();

        if (!result.ok) {
          line.text(T("sh_make_failed", result.message || ""));
          $("#modal-actions").append(button(T("close"), null, "", closeModal));
          return;
        }

        const texts = shellHousingTexts(name, SHELL.doc);
        const runtime = output === "shell" ? SHELL_RUNTIME.files(name, SHELL.doc, SHELL.built, [], ui.collect !== false ? collectionName("shells") : null) : [];
        const replaced = new Set(runtime.map(function (f) { return f.rel; }));
        const files = result.files.filter(function (f) { return !replaced.has(f.rel); }).concat(runtime).concat(shellHousingFiles(texts)).concat([
          { rel: "furniture.json", text: JSON.stringify((SHELL.doc.props || []).map(function (prop) { return { model: prop.model, coords: prop.p, rotation: prop.r }; }), null, 1) + "\r\n" }
        ]);

        line.text(T("sh_make_sending", (files.reduce(function (s, f) { return s + (f.bytes ? f.bytes.length : (f.text || "").length); }, 0) / 1048576).toFixed(1)));
        const kind = output === "mlo" ? "mlos" : "shells";
        const collection = ui.collect !== false ? (kind === "shells" ? SHELL_RUNTIME.collection(collectionName(kind), name, SHELL.doc.name) : { kind: kind, item: name, label: SHELL.doc.name || name, head: [], shared: [], keep: [] }) : null;

        uploadResource(collection ? collectionName(kind) : name, files, function (ratio) { fill(0.8 + 0.2 * ratio); }, collection).then(function (reply) {
          if (!reply || !reply.ok) {
            line.text((reply && reply.message) || T("sh_make_failed", ""));
            $("#modal-actions").append(button(T("close"), null, "", closeModal));
            return;
          }

          shellRequest("permanent", { id: SHELL.summary.id, resource: reply.resource, model: name, output: output });
          bar.find(".sh-progress-fill").css("width", "100%");
          line.text(collectionDone(reply));
          $("#modal-actions").empty().append(
            output === "shell" ? button(T("sh_finish_export"), "fa-file-code", "", function () { closeModal(); ui.exportDialog(name); }) : null,
            button(T("close"), null, "primary", closeModal)
          );
        });
      };
      worker.onerror = function (error) {
        clearInterval(ticker);
        worker.terminate();
        line.text(T("sh_make_failed", String(error && error.message)));
        $("#modal-actions").append(button(T("close"), null, "", closeModal));
      };
      const transfer = Object.keys(images).map(function (k) { return images[k].rgba.buffer; });

      worker.postMessage({ doc: SHELL.doc, kit: SHELL.kit, options: Object.assign({}, options, { images: flags }), images: images }, transfer);
    };

    if (output === "shell") {
      ui.bakeShell(name, line, fill, bar);
      return;
    }

    if (output === "mlo" && place) {
      options.position = place.position;
      options.heading = place.heading;
      loadTextures().then(go);
    } else if (output === "mlo") {
      toolAction("standing").then(function (reply) {
        options.position = reply.position || [0, 0, 0];
        options.heading = reply.heading || 0;
        loadTextures().then(go);
      });
    } else {
      loadTextures().then(go);
    }
  },
  housingAdd: function (name, line) {
    line.text(T("sh_housing_adding"));

    return shellRequest("housingadd", { id: SHELL.summary.id, model: name }).then(function (reply) {
      if (reply && reply.ok) line.text(T("sh_housing_added", reply.file || "rtx_housing"));
      else if (reply && reply.code === "nohousing") line.text(T("sh_housing_none"));
      else line.text(T("sh_housing_failed", (reply && (reply.message || reply.code)) || ""));
    });
  },
  pictureNow: function () {
    if (!SHELL.open || !SHELL.summary || !SHELL.built) return;
    if (SHELL.pictureRev === SHELL.doc.rev) return;

    SHELL.pictureRev = SHELL.doc.rev;
    SHELL_UI.renderPicture(SHELL.summary.id);
  },
  renderPicture: function (id) {
    const doc = SHELL.doc;
    const built = SHELL.built;
    const kit = SHELL.kit;

    if (!doc || !built || !built.bounds || !kit || typeof dzThree !== "function") return Promise.resolve(null);

    return Promise.all([dzThree(), SHELL_UI.kitMesh()]).then(function (got) {
      const THREE = window.THREE;
      const pack = got[1];

      if (!THREE || !pack) return null;

      const levels = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
      const top = levels[levels.length - 1] || { z: 0, height: 2.8 };
      const topCeil = (Number(top.z) || 0) + (Number(top.height) || 2.8);
      const skip = function (p) {
        const z = Number(p[3]) || 0;
        const name = String(p[0]);

        if (/_view_|_bk_/.test(name)) return true;
        if (z > topCeil + 0.15) return true;
        if (z > topCeil - 0.4 && (Number(p[4]) || 0) < -45) return true;

        return false;
      };
      const meshes = RTX_SHELLBAKE.meshes(kit, pack.km, built, skip);
      const W = 640;
      const H = 400;
      const canvas = document.createElement("canvas");

      canvas.width = W;
      canvas.height = H;

      let renderer;

      try {
        renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true, alpha: false, preserveDrawingBuffer: true });
      } catch (error) {
        return null;
      }

      renderer.setSize(W, H, false);
      renderer.setClearColor(0x16161d, 1);

      const scene = new THREE.Scene();
      const materials = new Set(kit.all ? kit.all.map(function (m) { return m.key; }) : (kit.materials || []).map(function (m) { return m.key; }));
      const loader = new THREE.TextureLoader();
      const waits = [];
      const textureOf = function (key) {
        if (!materials.has(key)) return null;

        const tex = loader.load("img/kit/" + key + ".webp");

        tex.wrapS = THREE.RepeatWrapping;
        tex.wrapT = THREE.RepeatWrapping;
        if (THREE.SRGBColorSpace) tex.colorSpace = THREE.SRGBColorSpace;
        waits.push(new Promise(function (resolve) {
          const started = Date.now();
          const poll = function () { if ((tex.image && tex.image.complete) || Date.now() - started > 4000) resolve(); else setTimeout(poll, 40); };

          poll();
        }));

        return tex;
      };
      const colourOf = function (hex, fallback) {
        const h = String(hex || "").replace("#", "");

        return /^[0-9a-f]{6}$/i.test(h) ? parseInt(h, 16) : fallback;
      };

      meshes.forEach(function (m) {
        if (!m.indices.length) return;

        const geom = new THREE.BufferGeometry();

        geom.setAttribute("position", new THREE.Float32BufferAttribute(m.positions, 3));
        geom.setAttribute("normal", new THREE.Float32BufferAttribute(m.normals, 3));
        geom.setAttribute("uv", new THREE.Float32BufferAttribute(m.uvs, 2));
        geom.setIndex(m.indices);

        const key = m.key.split("|")[0];
        let mat;

        if (/\|glass$/.test(m.key)) {
          mat = new THREE.MeshLambertMaterial({ color: 0xa9d4ff, transparent: true, opacity: 0.32, depthWrite: false });
        } else if (key.indexOf("@slot:") === 0) {
          mat = new THREE.MeshLambertMaterial({ color: colourOf((doc.colours || {})[key.slice(6)], 0xd8d8d8) });
        } else if (key.indexOf("@tint:") === 0) {
          const parts = key.split(":");

          mat = new THREE.MeshLambertMaterial({ color: colourOf((kit.tints && kit.tints.colours || [])[Number(parts[2]) || 0], 0xffffff) });
        } else if (key.indexOf("@flat:") === 0) {
          const tex = textureOf(key.slice(6));

          mat = new THREE.MeshLambertMaterial(tex ? { map: tex } : { color: 0xc8c8c8 });
        } else if (key === "lamp" || /^lamp/.test(key)) {
          return;
        } else {
          const tex = textureOf(key);

          mat = new THREE.MeshLambertMaterial(tex ? { map: tex } : { color: 0xbdbdbd });
        }

        scene.add(new THREE.Mesh(geom, mat));
      });

      const b = built.bounds;
      const centre = new THREE.Vector3((b.min[0] + b.max[0]) / 2, (b.min[1] + b.max[1]) / 2, ((Number(levels[0].z) || 0) + topCeil) / 2);
      const dir = new THREE.Vector3(-0.85, -1.25, 1.35).normalize();
      const radius = Math.max(4, Math.hypot(b.max[0] - b.min[0], b.max[1] - b.min[1], topCeil - (Number(levels[0].z) || 0)));
      const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, radius * 6);

      camera.up.set(0, 0, 1);
      camera.position.copy(centre).addScaledVector(dir, radius * 2);
      camera.lookAt(centre);
      camera.updateMatrixWorld();

      const inv = camera.matrixWorldInverse;
      let x0 = Infinity, x1 = -Infinity, y0 = Infinity, y1 = -Infinity;

      [b.min[0], b.max[0]].forEach(function (x) {
        [b.min[1], b.max[1]].forEach(function (y) {
          [Number(levels[0].z) || 0, topCeil].forEach(function (z) {
            const v = new THREE.Vector3(x, y, z).applyMatrix4(inv);

            x0 = Math.min(x0, v.x); x1 = Math.max(x1, v.x); y0 = Math.min(y0, v.y); y1 = Math.max(y1, v.y);
          });
        });
      });

      const cx = (x0 + x1) / 2;
      const cy = (y0 + y1) / 2;
      let hw = (x1 - x0) / 2 * 1.08;
      let hh = (y1 - y0) / 2 * 1.08;

      if (hw / hh > W / H) hh = hw * H / W; else hw = hh * W / H;

      camera.left = cx - hw;
      camera.right = cx + hw;
      camera.top = cy + hh;
      camera.bottom = cy - hh;
      camera.updateProjectionMatrix();

      const hemi = new THREE.HemisphereLight(0xffffff, 0x5a5a66, 1.25);

      hemi.position.set(0, 0, 1);
      scene.add(hemi);

      const sun = new THREE.DirectionalLight(0xffffff, 1.1);

      sun.position.set(-0.6, -1, 1.6);
      scene.add(sun);
      scene.add(new THREE.AmbientLight(0xffffff, 0.35));

      return Promise.all(waits).then(function () {
        renderer.render(scene, camera);

        const url = canvas.toDataURL("image/webp", 0.82);

        renderer.dispose();
        scene.traverse(function (o) { if (o.geometry) o.geometry.dispose(); if (o.material) { if (o.material.map) o.material.map.dispose(); o.material.dispose(); } });

        if (!/^data:image\/(webp|png)/.test(url)) return null;
        if (id) shellRequest("picture", { id: id, data: url.split(",")[1] });

        return url;
      });
    }).catch(function () { return null; });
  },
  kitMesh: function () {
    if (SHELL.kitMesh) return Promise.resolve(SHELL.kitMesh);

    return fetch("data/kitmesh.json").then(function (r) { return r.json(); }).then(function (pack) {
      const raw = atob(pack.data);
      const packed = new Uint8Array(raw.length);

      for (let i = 0; i < raw.length; i++) packed[i] = raw.charCodeAt(i);

      let bytes;

      try {
        bytes = pako.inflate(packed);
      } catch (error) {
        throw new Error("kitmesh: " + String((error && error.message) || error));
      }

      SHELL.kitMesh = { bytes: bytes, km: RTX_SHELLBAKE.parse(bytes) };

      return SHELL.kitMesh;
    });
  },
  decodeImage: function (src) {
    return new Promise(function (resolve) {
      const img = new Image();

      img.onload = function () {
        try {
          const canvas = document.createElement("canvas");

          canvas.width = img.width;
          canvas.height = img.height;

          const ctx = canvas.getContext("2d");

          ctx.drawImage(img, 0, 0);
          resolve({ width: img.width, height: img.height, rgba: new Uint8Array(ctx.getImageData(0, 0, img.width, img.height).data.buffer) });
        } catch (error) {
          resolve(null);
        }
      };
      img.onerror = function () { resolve(null); };
      img.src = src;
    });
  },
  bakeFiles: function (name, built, options) {
    const ui = SHELL_UI;
    const o = options || {};
    const say = function (text, ratio, busy) { if (o.progress) o.progress(text, ratio, busy === true); };
    const images = Object.assign({}, o.images || {});

    return ui.kitMesh().then(function (pack) {
      const planned = o.parts && o.parts.length ? { pieces: [].concat.apply([], o.parts.map(function (p) { return p.built.pieces || []; })) } : built;
      const plan = o.collisionOnly ? { server: [], embedded: [] } : RTX_SHELLBAKE.plan(SHELL.kit, pack.km, planned, SHELL.doc.colours || {});
      const total = plan.server.length + plan.embedded.length;
      let done = 0;
      const step = function () {
        done++;
        say(T("sh_make_textures", done, total), 0.3 * done / Math.max(1, total));
      };
      let chain = Promise.resolve();

      plan.embedded.forEach(function (key) {
        chain = chain.then(function () {
          const blob = new Blob([RTX_SHELLBAKE.texBytes(pack.km, key)], { type: "image/png" });
          const url = URL.createObjectURL(blob);

          return ui.decodeImage(url).then(function (img) {
            URL.revokeObjectURL(url);
            if (img) images[key] = img;
            step();
          });
        });
      });
      plan.server.forEach(function (key) {
        chain = chain.then(function () {
          return shellRequest("texture", /^c[1-6]$/.test(key) ? { key: key, file: shellCustomFile(key) } : { key: key }).then(function (reply) {
            if (!reply || !reply.data) { step(); return null; }

            return ui.decodeImage("data:image/" + (/^c[1-6]$/.test(key) ? "png" : "jpeg") + ";base64," + reply.data).then(function (img) {
              if (img) images[key] = img;
              step();
            });
          });
        });
      });

      return chain.then(function () { return pack; });
    }).then(function (pack) {
      return new Promise(function (resolve, reject) {
        const started = Date.now();
        const ticker = setInterval(function () {
          const seconds = Math.round((Date.now() - started) / 1000);

          say(T("sh_make_building_time", seconds) + (seconds > 20 ? "  ·  " + T("sh_make_patience") : ""), 0.3 + 0.5 * (1 - Math.exp(-seconds / 15)), true);
        }, 500);
        let worker;

        try {
          worker = new Worker("shellworker.js");
        } catch (error) {
          clearInterval(ticker);
          reject(error);
          return;
        }

        worker.onmessage = function (event) {
          const result = event.data || {};

          if (result.progress) {
            if (o.partProgress) o.partProgress(result.index, result.total);
            return;
          }

          clearInterval(ticker);
          worker.terminate();

          if (!result.ok) reject(new Error(result.message || "bake"));
          else resolve(result);
        };
        worker.onerror = function (error) {
          clearInterval(ticker);
          worker.terminate();
          reject(new Error((error && (error.message || error.type)) || "worker"));
        };

        const transfer = Object.keys(images).map(function (k) { return images[k].rgba.buffer; });
        const kmBytes = pack.bytes.slice();

        transfer.push(kmBytes.buffer);
        worker.postMessage({ mode: "bake", name: name, km: kmBytes, kit: SHELL.kit, built: { pieces: built.pieces, doors: built.doors, lamps: o.lamps === false ? [] : built.lamps }, parts: o.parts || null, extra: o.extra || {}, colours: SHELL.doc.colours || {}, images: images, collisionOnly: o.collisionOnly === true }, transfer);
      });
    });
  },
  liftParts: function (model, built) {
    if (typeof RTX_SHELLLIFT === "undefined" || !built || !(built.elevators || []).length) return { parts: [], images: {} };

    try {
      return { parts: RTX_SHELLLIFT.parts(built, model), images: RTX_SHELLLIFT.images(built) };
    } catch (error) {
      return { parts: [], images: {} };
    }
  },
  bakeShell: function (name, line, fill, bar) {
    const ui = SHELL_UI;
    const fail = function (text) {
      bar.removeClass("busy");
      line.text(T("sh_make_failed", text || ""));
      $("#modal-actions").append(button(T("close"), null, "", closeModal));
    };
    let built;

    try {
      built = SG.build(SHELL.doc, SHELL.kit);
    } catch (error) {
      fail(String(error && error.message));
      return;
    }

    const lifts = ui.liftParts(name, built);

    ui.bakeFiles(name, built, {
      parts: lifts.parts.length ? [{ name: name, built: built }].concat(lifts.parts) : null,
      images: lifts.images,
      progress: function (text, ratio, busy) {
        line.text(text);
        fill(ratio);
        bar.toggleClass("busy", busy);
      }
    }).then(function (result) {
      bar.removeClass("busy");

      const texts = shellHousingTexts(name, SHELL.doc);
      const into = ui.collect !== false ? collectionName("shells") : null;
      const runtime = SHELL_RUNTIME.files(name, SHELL.doc, built, lifts.parts.map(function (p) { return p.name; }), into);
      const replaced = new Set(runtime.map(function (f) { return f.rel; }));
      const files = result.files.filter(function (f) { return !replaced.has(f.rel); }).concat(runtime).concat(shellHousingFiles(texts)).concat([
        { rel: "furniture.json", text: JSON.stringify((SHELL.doc.props || []).map(function (prop) { return { model: prop.model, coords: prop.p, rotation: prop.r }; }), null, 1) + "\r\n" }
      ]);

      line.text(T("sh_make_sending", (files.reduce(function (s, f) { return s + (f.bytes ? f.bytes.length : (f.text || "").length); }, 0) / 1048576).toFixed(1)));
      uploadResource(into || name, files, function (ratio) { fill(0.8 + 0.2 * ratio); }, into ? SHELL_RUNTIME.collection(into, name, SHELL.doc.name) : null).then(function (reply) {
        if (!reply || !reply.ok) {
          line.text((reply && reply.message) || T("sh_make_failed", ""));
          $("#modal-actions").append(button(T("close"), null, "", closeModal));
          return;
        }

        shellRequest("permanent", { id: SHELL.summary.id, resource: reply.resource, model: name, output: "shell" });
        bar.find(".sh-progress-fill").css("width", "100%");
        line.text(collectionDone(reply));

        const house = el("div", "tk-hint", T("sh_housing_adding"));

        line.after(house);
        ui.housingAdd(name, house);
        $("#modal-actions").empty().append(
          button(T("sh_housing_add"), "fa-house-circle-check", "", function () { ui.housingAdd(name, house); }),
          button(T("sh_finish_export"), "fa-file-code", "", function () { closeModal(); ui.exportDialog(name); }),
          button(T("close"), null, "primary", closeModal)
        );
      });
    }).catch(function (error) {
      fail(String((error && error.message) || error));
    });
  },
  placeMlo: function (name) {
    const at = { position: [0, 0, 0], heading: 0 };
    const boxes = [0, 1, 2].map(function (k) { return input("0", ["X", "Y", "Z"][k], function (v) { at.position[k] = Number(v) || 0; }, { mono: true, small: true }); });
    const turn = input("0", T("sh_mlo_heading"), function (v) { at.heading = Number(v) || 0; }, { mono: true, small: true });
    const fill = function () {
      toolAction("standing").then(function (reply) {
        at.position = (reply.position || [0, 0, 0]).slice();
        at.heading = reply.heading || 0;
        boxes.forEach(function (box, k) { box.val(fmt(at.position[k], 3)); });
        turn.val(fmt(at.heading, 1));
      });
    };

    fill();
    modal({
      kicker: T("sh_kicker"),
      title: T("sh_mlo_place_title"),
      body: [
        el("div", "tk-hint", T("sh_mlo_place_text")),
        el("div", "tk-grid2").append(field("X", boxes[0]), field("Y", boxes[1]), field("Z", boxes[2]), field(T("sh_mlo_heading"), turn)),
        button(T("sh_mlo_place_here"), "fa-location-crosshairs", "small", fill),
        el("div", "tk-hint", T("sh_mlo_place_props"))
      ],
      actions: [{ label: T("cancel") }, { label: T("sh_finish_mlo"), kind: "primary", icon: "fa-building", run: function () { setTimeout(function () { SHELL_UI.make("mlo", name, { position: at.position.map(function (v) { return SG.round(v, 3); }), heading: SG.round(at.heading, 2) }); }, 30); } }]
    });
  },
  exportDialog: function (model) {
    const texts = shellHousingTexts(model, SHELL.doc);
    const first = STATE.setup.housing || "rtx_housing";
    const order = SHELL_HOUSING_FILES.map(function (f) { return f[0]; });
    const sorted = [first].concat(order.filter(function (x) { return x !== first; })).filter(function (x) { return texts[x]; });

    exportModal(T("sh_export_title"), sorted.map(function (key) {
      return { label: T("sh_export_" + key) !== "sh_export_" + key ? T("sh_export_" + key) : key, hint: T("sh_export_where_" + key) !== "sh_export_where_" + key ? T("sh_export_where_" + key) : "", text: function () { return texts[key]; } };
    }), el("div", "tk-hint", T("sh_export_hint")));
  }
});
