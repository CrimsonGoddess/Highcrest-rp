globalThis.RTX_SHELL = (function () {
  const fs = require("fs");
  const path = require("path");
  const zlib = require("zlib");
  const RESOURCE = GetCurrentResourceName();
  const ROOT = path.resolve(GetResourcePath(RESOURCE));
  const DIR = path.join(ROOT, "data", "shells");
  const INDEX = path.join(DIR, "index.json");
  const G = globalThis.RTX_SHELLGEO;
  const LIMITS = { walls: 600, openings: 400, rooms: 120, stairs: 24, lights: 96, levels: 8, props: 2500, pools: 12, details: 300, span: 80, revisions: 30 };
  let kit = null;
  let index = {};
  const open = new Map();
  const timers = new Map();

  function ensureDir(folder) {
    if (!fs.existsSync(folder)) fs.mkdirSync(folder, { recursive: true });
  }

  function setup() {
    try {
      return globalThis.RTX_FILES.setup();
    } catch (error) {
      return { config: {} };
    }
  }

  function shellsConfig() {
    const config = setup().config || {};

    return config.Shells || {};
  }

  function kitData() {
    if (!kit) {
      try {
        kit = JSON.parse(fs.readFileSync(path.join(ROOT, "data", "kit.json"), "utf8"));
      } catch (error) {
        kit = { prefix: "rtx_tk_", materials: [], slots: [], doors: [], steps: [], rails: [], lights: [], views: [], glass: [] };
      }
    }

    return kit;
  }

  function loadIndex() {
    ensureDir(DIR);

    try {
      index = JSON.parse(fs.readFileSync(INDEX, "utf8")) || {};
    } catch (error) {
      index = {};
    }

    let fixed = false;

    Object.keys(index).forEach(function (id) {
      const item = index[id];

      if (!item || !Array.isArray(item.origin) || item.origin.length !== 3 || !item.origin.every(Number.isFinite)) {
        item.origin = spotOrigin(Number(item && item.spot) || 0);
        fixed = true;
      }
    });

    if (fixed) saveIndex();
  }

  function saveIndex() {
    fs.writeFileSync(INDEX, JSON.stringify(index));
  }

  function fileOf(id, revisions) {
    if (!/^[a-z0-9]{4,24}$/.test(String(id))) return null;

    return path.join(DIR, id + (revisions ? ".rev" : "") + ".json.gz");
  }

  function readGz(file, fallback) {
    try {
      return JSON.parse(zlib.gunzipSync(fs.readFileSync(file)).toString("utf8"));
    } catch (error) {
      return fallback;
    }
  }

  function writeGz(file, value) {
    const temp = file + ".tmp";

    fs.writeFileSync(temp, zlib.gzipSync(Buffer.from(JSON.stringify(value), "utf8"), { level: 6 }));

    try {
      fs.renameSync(temp, file);
    } catch (error) {
      if (!error || (error.code !== "EPERM" && error.code !== "EBUSY" && error.code !== "EACCES")) throw error;

      fs.writeFileSync(file, fs.readFileSync(temp));

      try {
        fs.unlinkSync(temp);
      } catch (ignored) {
      }
    }
  }

  function newId() {
    let id = "";

    do {
      id = "sh" + Date.now().toString(36).slice(-4) + Math.random().toString(36).slice(2, 6);
    } while (index[id]);

    return id;
  }

  function spotOrigin(spot) {
    const s = shellsConfig();
    const raw = s.buildzone || {};
    const picked = Array.isArray(raw) || ArrayBuffer.isView(raw) ? { x: raw[0], y: raw[1], z: raw[2] } : raw;
    const zone = [picked.x, picked.y, picked.z].every(function (v) { return Number.isFinite(Number(v)) && v !== null; }) ? picked : { x: 1700, y: 4400, z: 1500 };
    const spacing = Number(s.spacing) || 80;
    const columns = Number(s.columns) || 10;
    const col = spot % columns;
    const row = Math.floor(spot / columns);

    return [Math.round((Number(zone.x) + col * spacing) * 100) / 100, Math.round((Number(zone.y) + row * spacing) * 100) / 100, Math.round(Number(zone.z) * 100) / 100];
  }

  function freeSpot() {
    const used = new Set(Object.values(index).map(function (item) { return item.spot; }));
    let spot = 0;

    while (used.has(spot)) spot++;

    return spot;
  }

  function entry(id) {
    if (open.has(id)) return open.get(id);
    if (!index[id]) return null;

    const doc = readGz(fileOf(id), null);

    if (!doc) return null;

    const item = { doc: doc, built: null, revisions: null, lastSnapshot: 0 };

    item.built = G.build(doc, kitData());
    open.set(id, item);

    return item;
  }

  function summary(id) {
    const item = index[id];

    if (!item) return null;

    return { id: id, name: item.name, origin: item.origin, bounds: item.bounds, rev: item.rev, updated: item.updated, created: item.created, author: item.author, editor: item.editor, stats: item.stats, thumb: item.thumb || [], permanent: item.permanent || null, pic: item.pic || 0 };
  }

  const pictures = new Map();

  function pictureFile(id) {
    return path.join(DIR, id + ".pic.webp");
  }

  function pictureOf(id) {
    const item = index[id];

    if (!item || !item.pic) return null;

    const cached = pictures.get(id);

    if (cached && cached.at === item.pic) return cached.data;

    try {
      const data = fs.readFileSync(pictureFile(id)).toString("base64");

      pictures.set(id, { at: item.pic, data: data });

      return data;
    } catch (error) {
      return null;
    }
  }

  function savePicture(id, data) {
    const item = index[id];

    if (!item || typeof data !== "string" || data.length > 700000 || !/^[A-Za-z0-9+\/=]+$/.test(data)) return false;

    try {
      fs.writeFileSync(pictureFile(id), Buffer.from(data, "base64"));
      item.pic = Date.now();
      pictures.set(id, { at: item.pic, data: data });
      saveIndex();

      return true;
    } catch (error) {
      return false;
    }
  }

  function list() {
    return Object.keys(index).map(function (id) {
      const out = summary(id);

      out.picture = pictureOf(id);

      return out;
    }).sort(function (a, b) { return (b.updated || 0) - (a.updated || 0); });
  }

  function persist(id) {
    clearTimeout(timers.get(id));
    timers.set(id, setTimeout(function () {
      timers.delete(id);

      const item = open.get(id);

      if (!item) return;

      try {
        writeGz(fileOf(id), item.doc);

        if (item.revisions) writeGz(fileOf(id, true), item.revisions);

        saveIndex();
      } catch (error) {
        console.log("^1[RTX SHELL CREATOR] shell " + id + ": " + error.message + "^0");
      }
    }, 2500));
  }

  function flush() {
    timers.forEach(function (timer, id) {
      clearTimeout(timer);

      const item = open.get(id);

      if (item) {
        writeGz(fileOf(id), item.doc);
        if (item.revisions) writeGz(fileOf(id, true), item.revisions);
      }
    });
    timers.clear();
    saveIndex();
  }

  function touch(id, item, by) {
    const now = Math.floor(Date.now() / 1000);
    const meta = index[id];

    item.built = G.build(item.doc, kitData());
    meta.rev = item.doc.rev;
    meta.updated = now;
    meta.editor = by || meta.editor;
    meta.name = item.doc.name;
    meta.bounds = item.built.bounds;
    meta.stats = item.built.stats;
    meta.thumb = thumbOf(item.doc);
    persist(id);
  }

  function thumbOf(doc) {
    const levels = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
    const first = levels.length ? levels[0].id : "l1";
    const out = [];

    (doc.walls || []).forEach(function (wall) {
      if ((wall.level || "l1") !== first || out.length >= 300) return;

      const pts = G.wallPoints(wall);

      for (let i = 1; i < pts.length && out.length < 300; i++) out.push([pts[i - 1][0], pts[i - 1][1], pts[i][0], pts[i][1]].map(function (v) { return Math.round(v * 100) / 100; }));
    });

    return out;
  }

  function revisionsOf(id, item) {
    if (!item.revisions) item.revisions = readGz(fileOf(id, true), []);

    return item.revisions;
  }

  function snapshot(id, item, by, label, doc) {
    const revisions = revisionsOf(id, item);
    const source = doc || item.doc;

    revisions.unshift({ at: Math.floor(Date.now() / 1000), by: by || "", label: String(label || "").slice(0, 60), rev: source.rev, doc: G.clone(source) });

    while (revisions.length > LIMITS.revisions) revisions.pop();

    item.lastSnapshot = Date.now();
  }

  function finite(value, limit) {
    const n = Number(value);

    return isFinite(n) && Math.abs(n) <= limit;
  }

  function point2(p) {
    return Array.isArray(p) && p.length >= 2 && finite(p[0], LIMITS.span) && finite(p[1], LIMITS.span);
  }

  function point3(p) {
    return Array.isArray(p) && p.length >= 3 && finite(p[0], LIMITS.span) && finite(p[1], LIMITS.span) && finite(p[2], 40);
  }

  function validItem(name, item) {
    if (!item || typeof item !== "object" || typeof item.id !== "string" || item.id.length > 32) return false;
    if (name === "walls") return point2(item.a) && point2(item.b) && (item.bend === undefined || finite(item.bend, 40));
    if (name === "rooms") return point2(item.anchor);
    if (name === "openings") return typeof item.wall === "string" && finite(item.t || 0, 200);
    if (name === "stairs") return point2(item.at);
    if (name === "props") return typeof item.model === "string" && item.model.length < 64 && point3(item.p);
    if (name === "lights") return point3(item.p);
    if (name === "levels") return finite(item.z, 40) && finite(item.height || 2.8, 10);
    if (name === "pools") return point2(item.at) && finite(item.w || 4, 20) && finite(item.l || 8, 30) && finite(item.depth || 1.5, 4);
    if (name === "details") return point2(item.at) && typeof item.kind === "string" && item.kind.length < 24 && finite(item.w || 1, 40) && finite(item.d || 1, 20) && finite(item.h || 1, 6);

    return false;
  }

  function cleanPatch(patch) {
    if (!patch || typeof patch !== "object") return null;

    const clean = { set: {}, del: {}, root: {} };

    G.COLLECTIONS.forEach(function (name) {
      const set = patch.set && patch.set[name];
      const del = patch.del && patch.del[name];

      if (Array.isArray(set)) clean.set[name] = set.filter(function (item) { return validItem(name, item); }).slice(0, 3000);
      if (Array.isArray(del)) clean.del[name] = del.filter(function (id) { return typeof id === "string"; }).slice(0, 3000);
    });

    if (patch.root && typeof patch.root === "object") {
      ["name", "colours", "points", "settings"].forEach(function (key) {
        if (patch.root[key] !== undefined) clean.root[key] = patch.root[key];
      });

      if (patch.root.customs && typeof patch.root.customs === "object") {
        clean.root.customs = {};
        ["c1", "c2", "c3", "c4", "c5", "c6"].forEach(function (slot) {
          const file = patch.root.customs[slot];

          if (file === null || (typeof file === "string" && /^[A-Za-z0-9_-]{1,40}$/.test(file))) clean.root.customs[slot] = file;
        });
      }

      if (typeof clean.root.name === "string") clean.root.name = clean.root.name.slice(0, 60);
    }

    return clean;
  }

  function withinLimits(doc) {
    const config = shellsConfig();

    if ((doc.props || []).length > Math.max(LIMITS.props, Number(config.budget) * 2 || 0)) return false;

    return (doc.walls || []).length <= LIMITS.walls && (doc.openings || []).length <= LIMITS.openings && (doc.rooms || []).length <= LIMITS.rooms &&
      (doc.stairs || []).length <= LIMITS.stairs && (doc.lights || []).length <= LIMITS.lights && (doc.pools || []).length <= LIMITS.pools && (doc.details || []).length <= LIMITS.details && (doc.levels || []).length <= LIMITS.levels && (doc.levels || []).length >= 1;
  }

  function fromCode(code, name) {
    let raw;

    try {
      if (code.length > 400000) return null;

      raw = JSON.parse(zlib.inflateSync(Buffer.from(code, "base64"), { maxOutputLength: 8 * 1024 * 1024 }).toString("utf8"));
    } catch (error) {
      return null;
    }

    if (!raw || typeof raw !== "object" || raw.format !== "rtx-shell") return null;

    const doc = G.blank(name);
    const patchData = { set: {}, root: {} };

    G.COLLECTIONS.forEach(function (key) {
      if (Array.isArray(raw[key])) {
        patchData.set[key] = raw[key];
        doc[key] = [];
      }
    });
    ["colours", "points", "settings", "customs"].forEach(function (key) {
      if (raw[key] && typeof raw[key] === "object") patchData.root[key] = raw[key];
    });

    const clean = cleanPatch(patchData);

    if (!clean) return null;

    G.apply(doc, clean);

    if (!(doc.levels || []).length || !withinLimits(doc)) return null;

    return doc;
  }

  function shareCode(id) {
    const item = entry(id);

    if (!item) return null;

    const doc = G.clone(item.doc);

    delete doc.permanent;
    doc.format = "rtx-shell";

    return zlib.deflateSync(Buffer.from(JSON.stringify(doc), "utf8"), { level: 9 }).toString("base64");
  }

  const TEMPLATES = path.join(DIR, "templates.json");

  function readTemplates() {
    try {
      const list = JSON.parse(fs.readFileSync(TEMPLATES, "utf8"));

      return Array.isArray(list) ? list : [];
    } catch (error) {
      return [];
    }
  }

  function writeTemplates(list) {
    ensureDir(DIR);
    fs.writeFileSync(TEMPLATES, JSON.stringify(list));
  }

  function templates() {
    return readTemplates().map(function (t) { return { id: t.id, name: t.name, by: t.by, at: t.at, rooms: t.rooms, floors: t.floors, area: t.area }; });
  }

  function saveTemplate(id, name, by) {
    const item = entry(id);

    if (!item) return { ok: false, code: "missing" };

    const list = readTemplates();

    if (list.length >= 60) return { ok: false, code: "full" };

    const doc = G.clone(item.doc);

    delete doc.permanent;

    let built = null;

    try {
      built = G.build(doc, kitData());
    } catch (error) {
      built = null;
    }

    const tid = "tp" + Date.now().toString(36) + Math.random().toString(36).slice(2, 5);

    list.unshift({ id: tid, name: String(name || doc.name || "Template").slice(0, 60), by: by || "", at: Math.floor(Date.now() / 1000), rooms: (doc.rooms || []).length, floors: (doc.levels || []).length, area: built && built.stats ? Math.round(Number(built.stats.area) || 0) : 0, code: zlib.deflateSync(Buffer.from(JSON.stringify(doc), "utf8"), { level: 9 }).toString("base64") });
    writeTemplates(list);

    return { ok: true, id: tid };
  }

  function deleteTemplate(tid) {
    const list = readTemplates();
    const next = list.filter(function (t) { return t.id !== tid; });

    writeTemplates(next);

    return next.length !== list.length;
  }

  function fromTemplate(tid, name) {
    const t = readTemplates().find(function (x) { return x.id === tid; });

    return t ? fromCode(t.code, name) : null;
  }

  function create(name, by, choice) {
    const id = newId();
    const spot = freeSpot();
    const now = Math.floor(Date.now() / 1000);
    let doc;

    if (choice && choice.layout) doc = G.layout(Object.assign({}, choice.layout, { name: name }), kitData());
    else if (choice && choice.copy && entry(choice.copy)) doc = G.clone(entry(choice.copy).doc);
    else if (choice && typeof choice.code === "string") doc = fromCode(choice.code, name);
    else if (choice && typeof choice.template === "string") doc = fromTemplate(choice.template, name);
    else doc = G.blank(name);

    if (!doc) return null;

    if (choice && choice.layout && typeof choice.layout.type === "string") doc.type = choice.layout.type.replace(/[^a-z]/g, "").slice(0, 20);
    doc.name = String(name || doc.name || "Shell").slice(0, 60);
    doc.rev = 1;
    delete doc.permanent;
    index[id] = { id: id, name: doc.name, spot: spot, origin: spotOrigin(spot), rev: 1, created: now, updated: now, author: by || "", editor: by || "" };

    const item = { doc: doc, built: null, revisions: [], lastSnapshot: Date.now() };

    open.set(id, item);
    touch(id, item, by);

    return summary(id);
  }

  function patch(id, raw, by, baseRev) {
    const item = entry(id);

    if (!item) return { ok: false, code: "missing" };

    const clean = cleanPatch(raw);

    if (!clean) return { ok: false, code: "patch" };

    const before = G.clone(item.doc);

    if (Date.now() - item.lastSnapshot > 3 * 60 * 1000) snapshot(id, item, by, "", before);

    G.apply(item.doc, clean);

    if (!withinLimits(item.doc)) {
      item.doc = before;
      return { ok: false, code: "limits" };
    }

    item.doc.rev = (Number(item.doc.rev) || 0) + 1;

    const built = G.build(item.doc, kitData());

    if (built.derived.newRooms.length) {
      G.apply(item.doc, { set: { rooms: built.derived.newRooms } });
    }

    touch(id, item, by);

    return { ok: true, rev: item.doc.rev, base: baseRev, conflict: baseRev !== undefined && Number(baseRev) !== item.doc.rev - 1 };
  }

  function get(id) {
    const item = entry(id);

    if (!item) return null;

    const built = item.built;

    return {
      summary: summary(id), doc: item.doc,
      built: { pieces: built.pieces, doors: built.doors, lamps: built.lamps, ladders: built.ladders, elevators: built.elevators, slots: built.slots, bounds: built.bounds, zones: built.zones, levels: built.levels, voids: built.voids, stats: built.stats }
    };
  }

  function live(id) {
    const item = entry(id);

    if (!item) return null;

    const built = item.built;

    return { id: id, rev: item.doc.rev, origin: index[id].origin, colours: item.doc.colours, customs: item.doc.customs || {}, settings: item.doc.settings, points: item.doc.points, props: item.doc.props, pieces: built.pieces, doors: built.doors, lamps: built.lamps, ladders: built.ladders, elevators: built.elevators, slots: built.slots, bounds: built.bounds, zones: built.zones, levels: built.levels, voids: built.voids };
  }

  function rename(id, name) {
    const item = entry(id);

    if (!item) return null;

    item.doc.name = String(name || "").slice(0, 60) || item.doc.name;
    touch(id, item);

    return summary(id);
  }

  function remove(id) {
    if (!index[id]) return false;

    delete index[id];
    open.delete(id);
    clearTimeout(timers.get(id));
    timers.delete(id);

    [fileOf(id), fileOf(id, true), pictureFile(id)].forEach(function (file) {
      try {
        if (file && fs.existsSync(file)) fs.unlinkSync(file);
      } catch (error) {
        return null;
      }

      return null;
    });
    saveIndex();

    return true;
  }

  function revisions(id) {
    const item = entry(id);

    if (!item) return [];

    return revisionsOf(id, item).map(function (r, i) { return { index: i, at: r.at, by: r.by, label: r.label, rev: r.rev, rooms: (r.doc.rooms || []).length, props: (r.doc.props || []).length }; });
  }

  function saveRevision(id, by, label) {
    const item = entry(id);

    if (!item) return false;

    snapshot(id, item, by, label || "");
    persist(id);

    return true;
  }

  function restore(id, at, by) {
    const item = entry(id);

    if (!item) return { ok: false };

    const list = revisionsOf(id, item);
    const chosen = list[Number(at)];

    if (!chosen) return { ok: false };

    snapshot(id, item, by, "");

    const rev = (Number(item.doc.rev) || 0) + 1;

    item.doc = G.clone(chosen.doc);
    item.doc.rev = rev;
    touch(id, item, by);

    return { ok: true, rev: rev };
  }

  function markPermanent(id, info) {
    const item = entry(id);

    if (!item || !index[id]) return false;

    index[id].permanent = { resource: String(info.resource || ""), model: String(info.model || ""), output: info.output === "mlo" ? "mlo" : "shell", at: Math.floor(Date.now() / 1000) };
    item.doc.permanent = index[id].permanent;
    persist(id);

    return true;
  }

  let maps = null;

  function mapsPack() {
    if (maps !== null) return maps;

    maps = false;

    try {
      const bytes = fs.readFileSync(path.join(ROOT, "data", "maps.bin"));

      if (bytes.toString("ascii", 0, 4) !== "RTXM") return maps;

      const length = bytes.readUInt32LE(4);

      maps = { bytes: bytes, base: 8 + length, index: JSON.parse(bytes.toString("utf8", 8, 8 + length)) };
    } catch (error) {
      maps = false;
    }

    return maps;
  }

  const HOUSING = "rtx_housing";
  const HOUSING_FILE = "shells_rtx_shellcreator.lua";
  const HOUSING_LIST = path.join(DIR, "housing.json");

  function housingEntry(model, doc) {
    const p = doc.points || {};
    const n = function (value, places) { const x = Number(value); return (isFinite(x) ? x : 0).toFixed(places); };
    const v = function (a, lift) { return Array.isArray(a) ? "vector3(" + n(a[0], 6) + ", " + n(a[1], 6) + ", " + n((Number(a[2]) || 0) + (lift || 0), 6) + ")" : "vector3(0.000000, 0.000000, 0.000000)"; };
    const exit = p.exit || { p: [0, 0, 0], h: 0 };
    const label = String(doc.name || model).replace(/[\\"\r\n\[\]]/g, "").slice(0, 60) || model;
    const list = function (value) { return Array.isArray(value) ? value.filter(function (x) { return x && Array.isArray(x.p); }) : []; };

    return [
      "RTXShellCreatorShells[\"" + model + "\"] = {",
      "\tlabel = \"" + label + "\",",
      "\tobject = \"" + model + "\",",
      "\ttags = {\"Empty\", \"RTX\", \"creator\"},",
      "\texitcoords = {coords = " + v(exit.p, 0.47) + ", heading = " + n(exit.h || 0, 2) + "},",
      "\tmanagmentcoords = {coords = " + v(p.management && p.management.p, 0.47) + "},",
      "\twardrobecoords = {coords = " + v(p.wardrobe && p.wardrobe.p, 0.47) + "},",
      "\tstoragecoords = {coords = " + v(p.storage && p.storage.p, 0.47) + "},",
      "\tcookcoords = {coords = " + v(p.cook && p.cook.p, 0.48) + "},",
      "\tsinkcoords = {" + list(p.sinks).map(function (x) { return "{coordswater = " + v(x.water || x.p) + ", coordsplayer = " + v(x.p, 0.48) + ", heading = " + n(x.h || 0, 2) + "}"; }).join(", ") + "},",
      "\tshowercoords = {" + list(p.showers).map(function (x) { return "{coordswater = " + v(x.water || x.p) + ", coordsplayer = " + v(x.p, 0.62) + ", heading = " + n(x.h || 0, 2) + "}"; }).join(", ") + "},",
      "\tcleanpoints = {" + list(p.clean).map(function (x) { return "{coords = " + v(x.p, -0.02) + "}"; }).join(", ") + "},",
      "\timages = {}",
      "}"
    ].join("\r\n");
  }

  function housingAdd(id, model) {
    const item = entry(id);
    const name = String(model || "").toLowerCase();

    if (!item) return { ok: false, code: "missing" };
    if (!/^[a-z0-9][a-z0-9_\-]{1,47}$/.test(name)) return { ok: false, code: "name" };
    if (GetResourceState(HOUSING) === "missing") return { ok: false, code: "nohousing" };

    const folder = path.join(path.resolve(GetResourcePath(HOUSING)), "configs");
    const blocked = function () { return { ok: false, code: "write", message: globalThis.RTX_FILES.text("install_sandbox_housing", HOUSING, RESOURCE, HOUSING) }; };

    try {
      if (!fs.existsSync(folder)) return { ok: false, code: "nohousing" };
    } catch (error) {
      return blocked();
    }

    let list = {};

    try {
      list = fs.existsSync(HOUSING_LIST) ? JSON.parse(fs.readFileSync(HOUSING_LIST, "utf8")) || {} : {};
    } catch (error) {
      list = {};
    }

    list[name] = { id: id, at: Math.floor(Date.now() / 1000), text: housingEntry(name, item.doc) };

    const body = [
      "-- Made by Kanikuly (Nina) for RTX Development",
      "-- Shells exported from RTX Shell Creator. The shell creator writes this file, your own shells stay in shells.lua",
      "",
      "Config = Config or {}",
      "",
      "local RTXShellCreatorShells = {}",
      ""
    ].concat(Object.keys(list).sort().map(function (key) { return list[key].text + "\r\n"; }), [
      "local function AddRTXShellCreatorShells()",
      "\tConfig.HouseShells = Config.HouseShells or {}",
      "",
      "\tfor keydata, valuedata in pairs(RTXShellCreatorShells) do",
      "\t\tConfig.HouseShells[keydata] = valuedata",
      "\tend",
      "end",
      "",
      "AddRTXShellCreatorShells()",
      "CreateThread(AddRTXShellCreatorShells)",
      ""
    ]).join("\r\n");

    try {
      fs.writeFileSync(path.join(folder, HOUSING_FILE), body);
      fs.writeFileSync(HOUSING_LIST, JSON.stringify(list, null, 1));
    } catch (error) {
      if (error && (error.code === "ERR_ACCESS_DENIED" || /restricted|allow-fs/i.test(String(error.message || "")))) return blocked();
      return { ok: false, code: "write", message: String(error && error.message) };
    }

    return { ok: true, file: HOUSING + "/configs/" + HOUSING_FILE, state: GetResourceState(HOUSING), count: Object.keys(list).length };
  }

  function build(record) {
    return { ok: false, code: "nui", message: globalThis.RTX_FILES.text("shell_build_in_game") };
  }

  loadIndex();

  on("onResourceStop", function (name) {
    if (name === RESOURCE) flush();
  });

  exports("ShellList", function () { return list(); });
  exports("ShellCreate", function (name, by, choice) { return create(name, by, choice); });
  exports("ShellGet", function (id) { return get(id); });
  exports("ShellLive", function (id) { return live(id); });
  exports("ShellPatch", function (id, raw, by, baseRev) { return patch(id, raw, by, baseRev); });
  exports("ShellRename", function (id, name) { return rename(id, name); });
  exports("ShellDelete", function (id) { return remove(id); });
  exports("ShellRevisions", function (id) { return revisions(id); });
  exports("ShellSaveRevision", function (id, by, label) { return saveRevision(id, by, label); });
  exports("ShellRestore", function (id, at, by) { return restore(id, at, by); });
  exports("ShellPermanent", function (id, info) { return markPermanent(id, info); });
  exports("ShellCount", function () { return Object.keys(index).length; });
  exports("ShellHousingAdd", function (id, model) { return housingAdd(id, model); });
  exports("ShellShareCode", function (id) { return shareCode(id); });
  exports("ShellTemplates", function () { return templates(); });
  exports("ShellPicture", function (id, data) { return savePicture(id, data); });
  exports("ShellSaveTemplate", function (id, name, by) { return saveTemplate(id, name, by); });
  exports("ShellDeleteTemplate", function (tid) { return deleteTemplate(tid); });
  exports("ShellCustoms", function () {
    const config = shellsConfig();
    const names = config.customtextures && typeof config.customtextures === "object" ? config.customtextures : {};

    try {
      return fs.readdirSync(path.join(ROOT, "custom")).map(function (file) { return /^([A-Za-z0-9_-]{1,40})\.png$/.exec(file); }).filter(Boolean).map(function (m) {
        return { file: m[1], name: typeof names[m[1]] === "string" ? names[m[1]].slice(0, 40) : m[1].replace(/[_-]+/g, " ").replace(/^./, function (c) { return c.toUpperCase(); }) };
      }).sort(function (a, b) { return a.name.localeCompare(b.name); }).slice(0, 200);
    } catch (error) {
      return [];
    }
  });
  exports("ShellTexture", function (key, own) {
    const name = String(key || "");

    if (!/^[a-z0-9_]{1,32}$/.test(name)) return null;

    const pick = /^c[1-6]$/.test(name) ? (typeof own === "string" && /^[A-Za-z0-9_-]{1,40}$/.test(own) ? own : name) : null;
    const custom = pick ? path.join(ROOT, "custom", pick + ".png") : null;
    const file = custom && fs.existsSync(custom) ? custom : path.join(ROOT, "data", "tex", name + ".jpg");

    try {
      if (fs.existsSync(file)) return fs.readFileSync(file).toString("base64");

      const packed = mapsPack();
      const at = packed && packed.index[name];

      return at ? packed.bytes.subarray(packed.base + at[0], packed.base + at[0] + at[1]).toString("base64") : null;
    } catch (error) {
      return null;
    }
  });

  return { list: list, create: create, get: get, live: live, patch: patch, rename: rename, remove: remove, revisions: revisions, saveRevision: saveRevision, restore: restore, build: build, kit: kitData };
})();
