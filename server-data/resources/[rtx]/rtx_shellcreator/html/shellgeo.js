(function (root) {
  const EPS = 1e-6;
  const CELL = 0.125;
  const SIZES = [2, 1, 0.5, 0.25];
  const WIDE = [4, 2, 1, 0.5, 0.25];
  const CODES = { 4: "e", 2: "a", 1: "b", 0.5: "c", 0.25: "d", 2.8: "f", 3: "g" };
  const COLLECTIONS = ["levels", "walls", "rooms", "openings", "stairs", "props", "lights", "pools", "details"];
  const DETAILS = {
    column: { group: "structure", w: 0.4, d: 0.4, h: 0, mat: "white" },
    pillar: { group: "structure", w: 0.44, d: 0.44, h: 0, mat: "white" },
    beam: { group: "structure", w: 4, d: 0.25, h: 0.3, mat: "darkwood" },
    halfwall: { group: "structure", w: 2, d: 0.15, h: 1, mat: "white" },
    glasswall: { group: "structure", w: 3, d: 0.06, h: 0, mat: "steel", glass: "glass" },
    void: { group: "structure", w: 3, d: 2, h: 0, mat: "white", rail: "glass" },
    platform: { group: "structure", w: 2, d: 2, h: 0.2, mat: "oak", top: "oak" },
    floorpatch: { group: "structure", w: 3, d: 3, h: 0, mat: "oak", top: "darkwood", shaped: true },
    glassrail: { group: "structure", w: 2, d: 0.06, h: 1, mat: "steel" },
    rail: { group: "structure", w: 2, d: 0.06, h: 1, mat: "steel" },
    wardrobe: { group: "builtin", w: 2.4, d: 0.6, h: 0, mat: "white", wall: true, fronts: 0.6, handles: true },
    kitchen: { group: "kitchen", w: 3, d: 0.62, h: 0.9, mat: "white", top: "marble", wall: true, fronts: 0.6, handles: true, built: true },
    sinkrun: { group: "kitchen", w: 1.2, d: 0.62, h: 0.9, mat: "white", top: "marble", wall: true, fronts: 0.6, handles: true },
    hobrun: { group: "kitchen", retired: true, w: 0.9, d: 0.62, h: 0.9, mat: "white", top: "marble", wall: true, fronts: 0.9, handles: true },
    wallcab: { group: "kitchen", w: 2.4, d: 0.35, h: 0.7, lift: 1.45, mat: "white", wall: true, fronts: 0.6, handles: true },
    tallcab: { group: "kitchen", w: 1.2, d: 0.62, h: 2.2, mat: "white", wall: true, fronts: 0.6, handles: true },
    fridge: { group: "kitchen", retired: true, w: 0.9, d: 0.68, h: 2, mat: "steel", wall: true },
    hood: { group: "kitchen", retired: true, w: 0.9, d: 0.5, h: 0, lift: 1.55, mat: "steel", wall: true },
    island: { group: "kitchen", w: 2.4, d: 1, h: 0.92, mat: "white", top: "marble", fronts: 0.6, handles: true, built: true },
    bar: { group: "kitchen", w: 2, d: 0.55, h: 1.08, mat: "walnut", top: "marble" },
    counter: { group: "kitchen", w: 2, d: 0.6, h: 0.92, mat: "walnut", top: "marble" },
    vanity: { group: "builtin", w: 1.2, d: 0.48, h: 0.5, lift: 0.35, mat: "walnut", top: "white", wall: true, fronts: 0.6, handles: true },
    media: { group: "builtin", w: 2.4, d: 0.4, h: 0.42, lift: 0.25, mat: "walnut", wall: true, fronts: 0.6 },
    shelves: { group: "builtin", w: 1.6, d: 0.35, h: 2.2, mat: "oak", wall: true },
    fireplace: { group: "builtin", w: 1.6, d: 0.45, h: 0, mat: "stone", top: "marble", wall: true },
    bench: { group: "builtin", w: 1.6, d: 0.45, h: 0.45, mat: "oak", top: "fabric", wall: true },
    shower: { group: "builtin", w: 1, d: 1, h: 2, mat: "steel", top: "tilecream", glass: "glass", wall: true },
    bathtub: { group: "builtin", w: 1.7, d: 0.75, h: 0.55, mat: "white", top: "white", wall: true },
    panelling: { group: "builtin", w: 3, d: 0.025, h: 1, mat: "teak", top: "darkwood", wall: true },
    mirror: { group: "builtin", w: 1, d: 0.02, h: 1.2, lift: 0.9, mat: "brass", wall: true },
    balcony: { group: "outdoor", w: 3, d: 1.5, h: 0.2, mat: "white", top: "decking", wall: true, outside: true, rail: "glass" },
    lawn: { group: "outdoor", w: 4, d: 3, h: 0.1, mat: "soil", top: "grass" },
    terrace: { group: "outdoor", w: 4, d: 3, h: 0.15, mat: "stone", top: "pavers" },
    deck: { group: "outdoor", w: 4, d: 3, h: 0.25, mat: "darkwood", top: "decking" },
    path: { group: "outdoor", w: 1.2, d: 4, h: 0.04, mat: "flag", top: "paverss" },
    flowerbed: { group: "outdoor", w: 2, d: 0.8, h: 0.3, mat: "stone", top: "soil" },
    hedge: { group: "outdoor", w: 2, d: 0.6, h: 1.2, mat: "hedge", top: "hedge" },
    planter: { group: "outdoor", w: 1.2, d: 0.5, h: 0.55, mat: "concrete", top: "hedge" },
    fence: { group: "outdoor", w: 3, d: 0.05, h: 1.4, mat: "slats", top: "darkwood" },
    gardenwall: { group: "outdoor", w: 3, d: 0.25, h: 0.9, mat: "stone", top: "concrete" },
    pergola: { group: "outdoor", w: 3, d: 3, h: 2.5, mat: "darkwood" },
    ladder: { group: "structure", w: 0.5, d: 0.12, h: 0, mat: "steel", wall: true },
    elevator: { group: "structure", w: 1.9, d: 1.9, h: 0, mat: "steel" }
  };
  const LADDER_HEIGHTS = [1.5, 2, 2.2, 2.4, 2.6, 2.8, 3, 3.2, 3.4, 3.6, 3.8, 4, 4.25, 4.5, 5, 5.5, 6, 6.5];
  const LADDER_WOODS = ["oak", "darkwood", "walnut", "teak", "ash", "drift"];

  function ladderHatch(det) {
    return rectOf(det, -0.45, -0.95, 0.45, det.d / 2 - 0.005);
  }
  const DETAIL_GROUPS = ["structure", "kitchen", "builtin", "outdoor"];
  const PILLAR_MATERIALS = ["white", "concrete", "marble", "mblack", "darkwood", "steel", "brick", "polished"];
  const STAIR_TYPES = ["straight", "landing", "l", "u", "grand", "spiral", "floating"];
  const SPIRAL_ANGLE = 24;
  const STAIR_HEADROOM = 2.0;
  const RING8 = [[1, 0], [0.7071, 0.7071], [0, 1], [-0.7071, 0.7071], [-1, 0], [-0.7071, -0.7071], [0, -1], [0.7071, -0.7071]];
  const SPIRAL_SIZES = [0.8, 1, 1.25];
  const LAMP_SHAPES = ["round", "square", "strip", "spot", "pendant", "chandelier", "bulb", "sconce", "none"];
  const OPENINGS = {
    door: { width: 1, height: 2.1, sill: 0, door: "plain_white" },
    double: { width: 2, height: 2.1, sill: 0, door: "plain_white" },
    window: { width: 1.4, height: 1.2, sill: 0.9, glass: "glass" },
    opening: { width: 1.2, height: 2.3, sill: 0 },
    arch: { width: 1.4, height: 2.4, sill: 0, shape: "arch" },
    wide: { width: 2.6, height: 2.5, sill: 0 },
    half: { width: 2, height: 0, sill: 1.05 },
    garage: { width: 3, height: 2.5, sill: 0 },
    glassdoor: { width: 1, height: 2.1, sill: 0, door: "glass_full" },
    french: { width: 2, height: 2.1, sill: 0, door: "glass_white" },
    slider: { width: 2.4, height: 2.2, sill: 0, glass: "glass" },
    fake: { width: 1, height: 2.1, sill: 0, door: "panels6_white" },
    tall: { width: 1.2, height: 2.2, sill: 0.15, glass: "glass" },
    small: { width: 0.6, height: 0.6, sill: 1.6, glass: "frosted" },
    strip: { width: 2.4, height: 0.5, sill: 1.75, glass: "glass" },
    picture: { width: 2.6, height: 1.7, sill: 0.45, glass: "glass" },
    archwin: { width: 1.2, height: 1.7, sill: 0.8, glass: "glass", shape: "arch" },
    round: { width: 0.9, height: 0.9, sill: 1.2, glass: "glass", shape: "round" }
  };
  const WINDOW_KINDS = ["window", "tall", "small", "strip", "picture", "archwin", "round", "slider"];
  const DOOR_KINDS = { door: 1, glassdoor: 1, double: 2, french: 2 };
  const BAR_KINDS = ["none", "cross", "grid", "vertical", "horizontal", "transom"];
  const RING_MATERIALS = ["white", "darkwood", "oak", "steel", "blackm", "brass"];
  const ROOM_TYPES = ["living", "bedroom", "kitchen", "bathroom", "hall", "office", "dining", "garage", "storage", "kids", "laundry", "other"];
  const SCHEMES = {
    warm: { name: "Warm home", walls: "warm", ceiling: "ceil", floors: { bathroom: "hex", kitchen: "checker", garage: "concrete", laundry: "hex", _: "oak" }, bathwalls: "tilebath", skirting: "darkwood" },
    nordic: { name: "Nordic light", walls: "white", ceiling: "ceil", floors: { bathroom: "terrazzo", kitchen: "terrazzo", garage: "polished", _: "ash" }, bathwalls: "subway", skirting: "white" },
    loft: { name: "City loft", walls: "brick", ceiling: "ceilpan", floors: { bathroom: "slate", kitchen: "polished", bedroom: "darkwood", _: "polished" }, bathwalls: "slate", skirting: "steel" },
    classic: { name: "Classic", walls: "stripes", ceiling: "coffer", floors: { bathroom: "checker", kitchen: "checker", hall: "herring", _: "parquet" }, bathwalls: "marble", skirting: "darkwood" },
    luxe: { name: "Dark luxe", walls: "walnut", ceiling: "ceil", floors: { bathroom: "mblack", kitchen: "mblack", bedroom: "carpet", _: "herring" }, bathwalls: "marble", skirting: "darkwood" },
    beach: { name: "Beach house", walls: "wash", ceiling: "ceil", floors: { bathroom: "hex", kitchen: "hex", _: "ash" }, bathwalls: "subway", skirting: "white" }
  };

  function round(value, places) {
    const k = Math.pow(10, places === undefined ? 3 : places);
    return Math.round(value * k) / k;
  }

  function clone(value) {
    return JSON.parse(JSON.stringify(value));
  }

  function uid(prefix) {
    return prefix + Date.now().toString(36).slice(-5) + Math.random().toString(36).slice(2, 7);
  }

  function blank(name) {
    return {
      format: "rtx-shell", version: 1, name: name || "Shell", rev: 0,
      levels: [{ id: "l1", name: "Ground floor", z: 0, height: 2.8 }],
      walls: [], rooms: [], openings: [], stairs: [], props: [], lights: [],
      colours: { s1: "#e9e4da", s2: "#c9d6cf", s3: "#d8c5b0", s4: "#9fb4c7", s5: "#3c3f45", s6: "#b8574a" },
      points: { exit: null, management: null, wardrobe: null, storage: null, cook: null, sinks: [], showers: [], clean: [] },
      settings: { thick: 0.2, skirting: "darkwood", frames: "white", inside: "night", hour: 21, weather: "EXTRASUNNY", grid: 0.25, view: "city" }
    };
  }

  function levelOf(doc, id) {
    return (doc.levels || []).find(function (level) { return level.id === id; }) || (doc.levels || [])[0] || { id: "l1", z: 0, height: 2.8 };
  }

  function apply(doc, patch) {
    const next = doc;

    if (!patch) return next;

    COLLECTIONS.forEach(function (name) {
      next[name] = next[name] || [];

      const removed = patch.del && patch.del[name];

      if (removed && removed.length) {
        const gone = new Set(removed);

        next[name] = next[name].filter(function (item) { return !gone.has(item.id); });
      }

      const set = patch.set && patch.set[name];

      if (set && set.length) {
        set.forEach(function (item) {
          if (!item || !item.id) return;

          const index = next[name].findIndex(function (x) { return x.id === item.id; });

          if (index >= 0) next[name][index] = clone(item);
          else next[name].push(clone(item));
        });
      }
    });

    if (patch.root) {
      Object.keys(patch.root).forEach(function (key) {
        if (COLLECTIONS.indexOf(key) >= 0) return;

        const value = patch.root[key];

        if (value && typeof value === "object" && !Array.isArray(value) && next[key] && typeof next[key] === "object" && !Array.isArray(next[key])) {
          next[key] = Object.assign({}, next[key], clone(value));
        } else {
          next[key] = clone(value);
        }
      });
    }

    return next;
  }

  function inverse(doc, patch) {
    const back = { set: {}, del: {}, root: {} };

    COLLECTIONS.forEach(function (name) {
      const list = doc[name] || [];
      const find = function (id) { return list.find(function (x) { return x.id === id; }); };

      ((patch.set && patch.set[name]) || []).forEach(function (item) {
        const old = find(item.id);

        if (old) (back.set[name] = back.set[name] || []).push(clone(old));
        else (back.del[name] = back.del[name] || []).push(item.id);
      });
      ((patch.del && patch.del[name]) || []).forEach(function (id) {
        const old = find(id);

        if (old) (back.set[name] = back.set[name] || []).push(clone(old));
      });
    });

    Object.keys(patch.root || {}).forEach(function (key) {
      const value = patch.root[key];

      if (value && typeof value === "object" && !Array.isArray(value) && doc[key] && typeof doc[key] === "object" && !Array.isArray(doc[key])) {
        back.root[key] = {};
        Object.keys(value).forEach(function (sub) { back.root[key][sub] = doc[key][sub] === undefined ? null : clone(doc[key][sub]); });
      } else {
        back.root[key] = doc[key] === undefined ? null : clone(doc[key]);
      }
    });

    return back;
  }

  function sub(a, b) { return [a[0] - b[0], a[1] - b[1]]; }
  function add(a, b) { return [a[0] + b[0], a[1] + b[1]]; }
  function mul(a, k) { return [a[0] * k, a[1] * k]; }
  function dot(a, b) { return a[0] * b[0] + a[1] * b[1]; }
  function cross(a, b) { return a[0] * b[1] - a[1] * b[0]; }
  function len(a) { return Math.hypot(a[0], a[1]); }
  function norm(a) { const l = len(a) || 1; return [a[0] / l, a[1] / l]; }
  function left(a) { return [-a[1], a[0]]; }
  function yaw(d) { return Math.atan2(d[1], d[0]) * 180 / Math.PI; }

  function wallPoints(wall) {
    const a = wall.a;
    const b = wall.b;
    const bend = Number(wall.bend) || 0;
    const chord = sub(b, a);
    const l = len(chord);

    if (Math.abs(bend) < 0.02 || l < 0.1) return [a.slice(), b.slice()];

    const s = Math.max(-l / 2, Math.min(l / 2, bend));
    const r = (l * l / 4 + s * s) / (2 * Math.abs(s));
    const n = left(norm(chord));
    const m = mul(add(a, b), 0.5);
    const sign = s > 0 ? 1 : -1;
    const c = add(m, mul(n, s - sign * r));
    const a0 = Math.atan2(a[1] - c[1], a[0] - c[0]);
    const a1 = Math.atan2(b[1] - c[1], b[0] - c[0]);
    const apex = add(m, mul(n, s));
    const ap = Math.atan2(apex[1] - c[1], apex[0] - c[0]);
    const wrap = function (x) { while (x <= -Math.PI) x += 2 * Math.PI; while (x > Math.PI) x -= 2 * Math.PI; return x; };
    let d = wrap(a1 - a0);
    const mid = wrap(ap - a0);

    if (d * mid < 0 || Math.abs(mid) > Math.abs(d)) d = d > 0 ? d - 2 * Math.PI : d + 2 * Math.PI;

    const facet = r < 2 ? 0.25 : 0.5;
    const steps = Math.max(4, Math.min(96, Math.max(Math.round(r * Math.abs(d) / facet), Math.ceil(Math.abs(d) / (15 * Math.PI / 180)))));
    const out = [];

    for (let i = 0; i <= steps; i++) {
      const t = a0 + d * i / steps;

      out.push(i === 0 ? a.slice() : i === steps ? b.slice() : [c[0] + Math.cos(t) * r, c[1] + Math.sin(t) * r]);
    }

    return out;
  }

  function wallLength(wall) {
    const pts = wallPoints(wall);
    let total = 0;

    for (let i = 1; i < pts.length; i++) total += len(sub(pts[i], pts[i - 1]));

    return total;
  }

  function keyOf(p) {
    return Math.round(p[0] * 200) + "," + Math.round(p[1] * 200);
  }

  function segmentHit(p1, p2, p3, p4) {
    const r = sub(p2, p1);
    const s = sub(p4, p3);
    const den = cross(r, s);

    if (Math.abs(den) < 1e-9) return null;

    const qp = sub(p3, p1);
    const t = cross(qp, s) / den;
    const u = cross(qp, r) / den;

    if (t < -1e-6 || t > 1 + 1e-6 || u < -1e-6 || u > 1 + 1e-6) return null;

    return { t: Math.max(0, Math.min(1, t)), u: Math.max(0, Math.min(1, u)) };
  }

  function pointOnSegment(p, a, b, tolerance) {
    const ab = sub(b, a);
    const l2 = dot(ab, ab);

    if (l2 < EPS) return null;

    const t = dot(sub(p, a), ab) / l2;

    if (t <= 1e-4 || t >= 1 - 1e-4) return null;

    const q = add(a, mul(ab, t));

    return len(sub(p, q)) <= tolerance ? t : null;
  }

  function levelGraph(walls) {
    const segs = [];

    walls.forEach(function (wall) {
      const pts = wallPoints(wall);

      for (let i = 1; i < pts.length; i++) {
        if (len(sub(pts[i], pts[i - 1])) > 0.01) segs.push({ a: pts[i - 1], b: pts[i], wall: wall, cuts: [0, 1] });
      }
    });

    for (let i = 0; i < segs.length; i++) {
      for (let j = i + 1; j < segs.length; j++) {
        const hit = segmentHit(segs[i].a, segs[i].b, segs[j].a, segs[j].b);

        if (hit) {
          segs[i].cuts.push(hit.t);
          segs[j].cuts.push(hit.u);
        } else {
          [[i, j], [j, i]].forEach(function (pair) {
            const s = segs[pair[0]];
            const o = segs[pair[1]];

            [o.a, o.b].forEach(function (p) {
              const t = pointOnSegment(p, s.a, s.b, 0.02);

              if (t !== null) s.cuts.push(t);
            });
          });
        }
      }
    }

    const vertices = new Map();
    const vertex = function (p) {
      const k = keyOf(p);

      if (!vertices.has(k)) vertices.set(k, { key: k, p: p.slice(), out: [] });

      return vertices.get(k);
    };
    const edges = new Map();

    segs.forEach(function (s) {
      const cuts = Array.from(new Set(s.cuts.map(function (t) { return Math.round(t * 1e5) / 1e5; }))).sort(function (x, y) { return x - y; });

      for (let i = 1; i < cuts.length; i++) {
        const p = add(s.a, mul(sub(s.b, s.a), cuts[i - 1]));
        const q = add(s.a, mul(sub(s.b, s.a), cuts[i]));
        const u = vertex(p);
        const v = vertex(q);

        if (u === v) continue;

        const k = u.key < v.key ? u.key + "|" + v.key : v.key + "|" + u.key;

        if (edges.has(k)) continue;

        edges.set(k, { u: u, v: v, wall: s.wall });
      }
    });

    edges.forEach(function (e) {
      e.u.out.push({ to: e.v, edge: e });
      e.v.out.push({ to: e.u, edge: e });
    });

    let pruned = true;

    while (pruned) {
      pruned = false;
      vertices.forEach(function (v) {
        if (v.out.length === 1) {
          const h = v.out[0];

          v.out = [];
          h.to.out = h.to.out.filter(function (x) { return x.edge !== h.edge; });
          h.edge.dead = true;
          pruned = true;
        }
      });
    }

    const ends = [];

    walls.forEach(function (wall) {
      [wall.a, wall.b].forEach(function (p, i) {
        const v = vertices.get(keyOf(p));

        if (!v || v.out.length === 0) ends.push({ wall: wall.id, end: i === 0 ? "a" : "b", p: p.slice() });
      });
    });

    vertices.forEach(function (v) {
      v.out.forEach(function (h) { h.angle = Math.atan2(h.to.p[1] - v.p[1], h.to.p[0] - v.p[0]); });
      v.out.sort(function (x, y) { return x.angle - y.angle; });
    });

    const faces = [];
    const seen = new Set();

    vertices.forEach(function (start) {
      start.out.forEach(function (first) {
        const id0 = start.key + ">" + first.to.key;

        if (seen.has(id0)) return;

        const loop = [];
        let from = start;
        let h = first;
        let guard = 0;

        while (guard++ < 5000) {
          const id = from.key + ">" + h.to.key;

          if (seen.has(id)) break;

          seen.add(id);
          loop.push({ p: from.p, wall: h.edge.wall, forward: len(sub(h.to.p, from.p)) > 0 && dot(sub(h.to.p, from.p), sub(h.edge.wall.b, h.edge.wall.a)) >= 0 });

          const at = h.to;
          const back = at.out.findIndex(function (x) { return x.to === from; });

          if (back < 0) break;

          const next = at.out[(back - 1 + at.out.length) % at.out.length];

          from = at;
          h = next;

          if (from === start && h === first) break;
        }

        if (loop.length >= 3) {
          const area = polygonArea(loop.map(function (x) { return x.p; }));

          if (area > 0.05) faces.push({ loop: loop, area: area });
        }
      });
    });

    return { faces: faces, ends: ends };
  }

  function polygonArea(points) {
    let area = 0;

    for (let i = 0; i < points.length; i++) {
      const a = points[i];
      const b = points[(i + 1) % points.length];

      area += a[0] * b[1] - b[0] * a[1];
    }

    return area / 2;
  }

  function insidePolygon(p, points) {
    let inside = false;

    for (let i = 0, j = points.length - 1; i < points.length; j = i++) {
      const a = points[i];
      const b = points[j];

      if (((a[1] > p[1]) !== (b[1] > p[1])) && (p[0] < (b[0] - a[0]) * (p[1] - a[1]) / (b[1] - a[1]) + a[0])) inside = !inside;
    }

    return inside;
  }

  function distanceToEdges(p, points) {
    let best = Infinity;

    const px = p[0];
    const py = p[1];

    for (let i = 0; i < points.length; i++) {
      const a = points[i];
      const b = points[(i + 1) % points.length];
      const abx = b[0] - a[0];
      const aby = b[1] - a[1];
      const t = Math.max(0, Math.min(1, ((px - a[0]) * abx + (py - a[1]) * aby) / ((abx * abx + aby * aby) || 1)));
      const dx = px - a[0] - abx * t;
      const dy = py - a[1] - aby * t;
      const d2 = dx * dx + dy * dy;

      if (d2 < best) best = d2;
    }

    best = Math.sqrt(best);

    return best;
  }

  function centroid(points) {
    let x = 0;
    let y = 0;
    let a = 0;

    for (let i = 0; i < points.length; i++) {
      const p = points[i];
      const q = points[(i + 1) % points.length];
      const f = p[0] * q[1] - q[0] * p[1];

      x += (p[0] + q[0]) * f;
      y += (p[1] + q[1]) * f;
      a += f;
    }

    if (Math.abs(a) < EPS) return points[0].slice();

    return [x / (3 * a), y / (3 * a)];
  }

  function interiorPoint(points) {
    const c = centroid(points);

    if (insidePolygon(c, points) && distanceToEdges(c, points) > 0.2) return c;

    let best = c;
    let bestDistance = -1;
    let minx = Infinity, miny = Infinity, maxx = -Infinity, maxy = -Infinity;

    points.forEach(function (p) {
      minx = Math.min(minx, p[0]); maxx = Math.max(maxx, p[0]);
      miny = Math.min(miny, p[1]); maxy = Math.max(maxy, p[1]);
    });

    for (let i = 1; i < 12; i++) {
      for (let j = 1; j < 12; j++) {
        const q = [minx + (maxx - minx) * i / 12, miny + (maxy - miny) * j / 12];

        if (!insidePolygon(q, points)) continue;

        const d = distanceToEdges(q, points);

        if (d > bestDistance) {
          bestDistance = d;
          best = q;
        }
      }
    }

    return best;
  }

  function inset(loop, thickOf) {
    const merged = [];

    loop.forEach(function (item, i) {
      const next = loop[(i + 1) % loop.length];
      const prev = merged[merged.length - 1];
      const d = norm(sub(next.p, item.p));

      if (prev && prev.wall === item.wall && Math.abs(cross(prev.d, d)) < 1e-4 && dot(prev.d, d) > 0) {
        prev.b = next.p;
        return;
      }

      merged.push({ a: item.p, b: next.p, wall: item.wall, forward: item.forward, d: d });
    });

    if (merged.length > 2) {
      const first = merged[0];
      const last = merged[merged.length - 1];

      if (last.wall === first.wall && Math.abs(cross(last.d, first.d)) < 1e-4 && dot(last.d, first.d) > 0) {
        first.a = last.a;
        merged.pop();
      }
    }

    const lines = merged.map(function (e) {
      const d = norm(sub(e.b, e.a));
      const n = left(d);
      const h = thickOf(e.wall) / 2;

      return { p: add(e.a, mul(n, h)), d: d, e: e };
    });
    const points = [];

    for (let i = 0; i < lines.length; i++) {
      const l1 = lines[(i - 1 + lines.length) % lines.length];
      const l2 = lines[i];
      const den = cross(l1.d, l2.d);
      let p;

      if (Math.abs(den) < 1e-6) {
        p = add(l2.e.a, mul(left(l2.d), thickOf(l2.e.wall) / 2));
      } else {
        const t = cross(sub(l2.p, l1.p), l2.d) / den;

        p = add(l1.p, mul(l1.d, t));

        const corner = l2.e.a;

        if (len(sub(p, corner)) > 4 * thickOf(l2.e.wall)) p = add(corner, mul(norm(sub(p, corner)), 4 * thickOf(l2.e.wall)));
      }

      points.push([round(p[0], 4), round(p[1], 4)]);
    }

    const edges = points.map(function (p, i) {
      const q = points[(i + 1) % points.length];
      const source = lines[i].e;

      return { a: p, b: q, wall: source.wall.id, side: source.forward ? "l" : "r", length: round(len(sub(q, p)), 4), curved: Math.abs(Number(source.wall.bend) || 0) >= 0.02 };
    });

    return { points: points, edges: edges };
  }

  function right(a) { return [a[1], -a[0]]; }

  function rectAt(at, fwd, side, width, from, to) {
    return [add(add(at, mul(side, -width / 2)), mul(fwd, from)), add(add(at, mul(side, width / 2)), mul(fwd, from)), add(add(at, mul(side, width / 2)), mul(fwd, to)), add(add(at, mul(side, -width / 2)), mul(fwd, to))];
  }

  function stairGeometry(s, level, above, frameAxis) {
    const floatType = s.type === "floating";
    const type = floatType ? "straight" : STAIR_TYPES.indexOf(s.type) >= 0 ? s.type : "straight";
    const floating = floatType || (s.floating === true && type !== "spiral");
    const rise = above.z - level.z;
    const width = Math.max(0.6, Math.min(4, Number(s.width) || 1));
    const h = (Number(s.heading) || 0) * Math.PI / 180;
    const fwd = [-Math.sin(h), Math.cos(h)];
    const side = [Math.cos(h), Math.sin(h)];
    const at = s.at || [0, 0];
    const turnSign = s.turn === "left" ? -1 : 1;
    const g = { id: s.id, type: type, level: level.id, top: above.id, at: at, fwd: fwd, side: side, heading: Number(s.heading) || 0, width: width, z: Number(level.z) || 0, rise: rise, material: s.material || "oak", rail: floatType ? s.rail === true : s.rail !== false, closed: !floating && type !== "spiral" && s.closed !== false, floating: floating, turn: s.turn === "left" ? "left" : "right", flights: [], landings: [], footprint: [], holes: [], spiral: null };

    if (type === "spiral") {
      const radius = SPIRAL_SIZES.reduce(function (best, r) { return Math.abs(r - width) < Math.abs(best - width) ? r : best; }, SPIRAL_SIZES[1]);
      const base = Math.max(8, Math.round(rise / 0.17));
      const frameDir = frameAxis ? norm(frameAxis) : [1, 0];
      const phi0 = Math.atan2(frameDir[1], frameDir[0]) * 180 / Math.PI;
      const spinSign = s.turn === "left" ? 1 : -1;
      const startDeg = Number(s.heading) || 0;
      let count = base;
      let turnFix = 0;
      let best = Infinity;

      [0, 1, -1, 2, -2].forEach(function (delta) {
        const c = base + delta;

        if (c < 8 || rise / c > 0.185 || rise / c < 0.145) return;

        const residue = ((((startDeg + spinSign * (c + 1) * SPIRAL_ANGLE - phi0) % 90) + 90) % 90);
        const fix = residue <= 45 ? -residue : 90 - residue;
        const perTurn = 360 / SPIRAL_ANGLE * (rise / c);
        const landClear = (360 / SPIRAL_ANGLE - 2) * (rise / c) - 0.07;
        const cost = Math.abs(fix) + Math.abs(delta) * 3 + (perTurn < 2.45 ? 300 : 0) + (landClear < 2.2 ? 200 : 0);

        if (cost < best) { best = cost; count = c; turnFix = fix; }
      });

      const ring = [];

      for (let i = 0; i < 20; i++) ring.push(add(at, [Math.cos(i * Math.PI / 10) * (radius + 0.04), Math.sin(i * Math.PI / 10) * (radius + 0.04)]));

      g.count = count;
      g.stepRise = rise / count;
      g.stepRun = 0;
      g.run = radius * 2;
      g.spiral = { centre: at, radius: radius, count: count, stepRise: rise / count, angle: SPIRAL_ANGLE, start: startDeg + turnFix, sign: s.turn === "left" ? 1 : -1 };
      g.footprint.push(ring);

      const sign = g.spiral.sign;
      const holeR = radius + 0.08;
      const ax = frameAxis ? norm(frameAxis) : [1, 0];
      const ay = left(ax);
      const angle = SPIRAL_ANGLE;

      const exitDeg = g.spiral.start + sign * count * angle;
      const pts = [
        add(at, add(mul(ax, -holeR), mul(ay, -holeR))),
        add(at, add(mul(ax, holeR), mul(ay, -holeR))),
        add(at, add(mul(ax, holeR), mul(ay, holeR))),
        add(at, add(mul(ax, -holeR), mul(ay, holeR)))
      ];
      const landDeg = exitDeg + sign * angle;
      const landDir = [Math.cos(landDeg * Math.PI / 180), Math.sin(landDeg * Math.PI / 180)];
      const normals = [mul(ay, -1), ax, ay, mul(ax, -1)];
      let open = 0;

      normals.forEach(function (n, i) { if (dot(n, landDir) > dot(normals[open], landDir)) open = i; });

      g.spiral.exit = exitDeg;
      g.spiral.landing = sign * angle * 2;
      g.spiral.square = { ax: ax, ay: ay, half: holeR };
      g.holes.push({ points: pts, open: open, quiet: [] });
      return g;
    }

    const count = Math.max(4, Math.round(rise / 0.18));
    const stepRise = rise / count;
    const stepRun = Number(s.run) > 0.2 ? Number(s.run) : 0.28;

    g.count = count;
    g.stepRise = stepRise;
    g.stepRun = stepRun;

    const ceilingRel = Math.min(rise, Number(level.height) || 2.8);
    const headFrom = function (first, steps, fallback) {
      for (let k = 0; k < steps; k++) {
        if ((first + k + 1) * stepRise + STAIR_HEADROOM > ceilingRel) return Math.max(0, Math.min(fallback, k * stepRun - 0.1));
      }

      return fallback;
    };

    if (type === "straight") {
      const run = count * stepRun;

      g.run = run;
      g.flights.push({ at: at, fwd: fwd, side: side, count: count, first: 0 });
      g.footprint.push(rectAt(at, fwd, side, width, 0, run));
      g.holes.push({ points: rectAt(at, fwd, side, width + 0.1, headFrom(0, count, run * 0.35), run + 0.05), open: 2 });
      return g;
    }

    if (type === "landing") {
      const n1 = Math.max(2, Math.floor((count - 1) / 2));
      const n2 = Math.max(1, count - 1 - n1);
      const run1 = n1 * stepRun;
      const run2 = n2 * stepRun;
      const depth = Math.max(1, Math.min(2, width));
      const landingAt = add(at, mul(fwd, run1));
      const landing = rectAt(landingAt, fwd, side, width, 0, depth);
      const total = run1 + depth + run2;

      g.flights.push({ at: at, fwd: fwd, side: side, count: n1, first: 0 });
      g.landings.push({ points: landing, top: (n1 + 1) * stepRise, fwd: fwd, side: side, width: width, depth: depth, at: landingAt });
      g.flights.push({ at: add(landingAt, mul(fwd, depth)), fwd: fwd, side: side, count: n2, first: n1 + 1 });
      g.footprint.push(rectAt(at, fwd, side, width, 0, total));
      g.holes.push({ points: rectAt(at, fwd, side, width + 0.1, (n1 + 1) * stepRise + STAIR_HEADROOM > ceilingRel ? headFrom(0, n1, run1) : run1 + depth * 0.5, total + 0.05), open: 2 });
      g.run = total;
      return g;
    }

    if (type === "grand") {
      const n1 = Math.max(2, Math.floor((count - 1) / 2));
      const n2 = Math.max(1, count - 1 - n1);
      const run1 = n1 * stepRun;
      const run2 = n2 * stepRun;
      const side2w = Math.max(0.8, Math.min(2, Math.round(width * 0.6 / 0.25) * 0.25));
      const gap = 0;
      const depth = Math.max(1, side2w);
      const total = width + 2 * (gap + side2w);
      const landingAt = add(at, mul(fwd, run1));
      const landing = rectAt(landingAt, fwd, side, total, 0, depth);

      g.flights.push({ at: at, fwd: fwd, side: side, count: n1, first: 0 });
      g.footprint.push(rectAt(at, fwd, side, width, 0, run1), landing);
      g.landings.push({ points: landing, top: (n1 + 1) * stepRise, fwd: fwd, side: side, width: total, depth: depth, at: landingAt });

      [-1, 1].forEach(function (sign) {
        const offset = sign * (width / 2 + gap + side2w / 2);
        const at2 = add(landingAt, mul(side, offset));
        const fwd2 = mul(fwd, -1);
        const side2 = right(fwd2);

        g.flights.push({ at: at2, fwd: fwd2, side: side2, count: n2, first: n1 + 1, width: side2w });
        g.footprint.push(rectAt(at2, fwd2, side2, side2w, 0, run2));
        g.holes.push({ points: rectAt(add(at, mul(side, offset)), fwd, side, side2w + 0.1, run1 - run2 - 0.05, run1 + depth + 0.05), open: 0 });
      });

      g.run = run1 + depth;
      g.wide = total;
      g.holes.push({ points: rectAt(at, fwd, side, width + 2 * gap - 0.1, headFrom(0, n1, run1 * 0.4), run1 + depth + 0.05), open: -1 });
      return g;
    }

    const n1 = Math.max(2, Math.floor((count - 1) / 2));
    const n2 = Math.max(1, count - 1 - n1);
    const run1 = n1 * stepRun;
    const run2 = n2 * stepRun;
    const landingTop = (n1 + 1) * stepRise;

    g.flights.push({ at: at, fwd: fwd, side: side, count: n1, first: 0 });
    g.footprint.push(rectAt(at, fwd, side, width, 0, run1));

    if (type === "l") {
      const centre = add(at, mul(fwd, run1 + width / 2));
      const fwd2 = mul(side, turnSign);
      const side2 = right(fwd2);
      const at2 = add(centre, mul(fwd2, width / 2));
      const landing = rectAt(add(at, mul(fwd, run1)), fwd, side, width, 0, width);

      g.landings.push({ points: landing, top: landingTop, fwd: fwd, side: side, width: width, depth: width, at: add(at, mul(fwd, run1)) });
      g.flights.push({ at: at2, fwd: fwd2, side: side2, count: n2, first: n1 + 1 });
      g.footprint.push(landing, rectAt(at2, fwd2, side2, width, 0, run2));
      g.run = run1 + width;
      g.holes.push({ points: rectAt(add(centre, mul(fwd2, -width / 2)), fwd2, side2, width + 0.1, 0, width + run2 + 0.05), open: 2 });
      g.holes.push({ points: rectAt(at, fwd, side, width + 0.1, headFrom(0, n1, run1 * 0.45), run1), open: -1 });
      return g;
    }

    const gap = 0.12;
    const shift = (width + gap) / 2 * turnSign;
    const landingAt = add(add(at, mul(fwd, run1)), mul(side, shift));
    const landing = rectAt(landingAt, fwd, side, width * 2 + gap, 0, width);
    const at2 = add(add(at, mul(fwd, run1)), mul(side, shift * 2));
    const fwd2 = mul(fwd, -1);
    const side2 = right(fwd2);

    g.landings.push({ points: landing, top: landingTop, fwd: fwd, side: side, width: width * 2 + gap, depth: width, at: landingAt });
    g.flights.push({ at: at2, fwd: fwd2, side: side2, count: n2, first: n1 + 1 });
    g.footprint.push(landing, rectAt(at2, fwd2, side2, width, 0, run2));
    g.run = run1 + width;
    g.holes.push({ points: rectAt(add(landingAt, mul(fwd, width)), fwd2, side, width * 2 + gap + 0.1, 0, Math.max(run1, run2) + width + 0.05), open: 2 });
    return g;
  }

  function derive(doc, kit) {
    const out = { rooms: [], ends: [], openings: [], stairs: [], pools: [], details: [], holes: [], newRooms: [], warnings: [], walls: {} };
    const thick = Number(doc.settings && doc.settings.thick) || 0.2;
    const wallById = new Map((doc.walls || []).map(function (w) { return [w.id, w]; }));
    const thickOf = function (wall) { return Math.max(0.08, Number(wall.thick) || thick); };
    const used = new Set();

    (doc.levels || []).forEach(function (level) {
      const walls = (doc.walls || []).filter(function (w) { return (w.level || "l1") === level.id; });
      const graph = levelGraph(walls);

      out.ends = out.ends.concat(graph.ends.map(function (e) { return Object.assign({ level: level.id }, e); }));

      graph.faces.forEach(function (face) {
        const shape = inset(face.loop, thickOf);

        if (shape.points.length < 3 || polygonArea(shape.points) < 0.3) return;

        const outline = face.loop.map(function (x) { return x.p; });
        let record = (doc.rooms || []).find(function (r) { return !used.has(r.id) && (r.level || "l1") === level.id && r.anchor && insidePolygon(r.anchor, outline); });

        if (!record) {
          record = { id: uid("r"), level: level.id, anchor: interiorPoint(shape.points).map(function (v) { return round(v, 3); }), name: "", type: "living" };
          out.newRooms.push(record);
        }

        used.add(record.id);
        out.rooms.push({
          id: record.id, level: level.id, z: Number(level.z) || 0, height: Number(record.height) > 1.8 ? Number(record.height) : Number(level.height) || 2.8,
          points: shape.points, edges: shape.edges, outline: outline, area: round(polygonArea(shape.points), 2), record: record
        });
      });
    });

    const sortedLevels = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
    const levelAboveOf = function (level) { return sortedLevels.find(function (l) { return l.z > level.z + 0.5; }) || null; };
    const levelBelowOf = function (level) { return sortedLevels.slice().reverse().find(function (l) { return l.z < level.z - 0.5; }) || null; };

    out.rooms.forEach(function (room) {
      if (room.record.openAbove !== true) return;

      const level = levelOf(doc, room.level);
      const above = levelAboveOf(level);

      if (!above) return;

      room.height = round(Number(above.z) - room.z, 3);
      room.openAbove = above.id;
      out.holes.push({ level: above.id, points: room.points, open: -1, void: room.id, below: level.id, rail: room.record.openRail || "glass", fascia: false });
    });

    (doc.details || []).forEach(function (det) {
      if (det.kind !== "ladder") return;

      const level = levelOf(doc, det.level);
      const above = (doc.levels || []).filter(function (l) { return (Number(l.z) || 0) > (Number(level.z) || 0) + 0.5; }).sort(function (a, b) { return a.z - b.z; })[0];

      if (!above) return;

      out.holes.push({ level: above.id, points: ladderHatch(detailShape(det)), open: -1, void: det.id, below: level.id, rail: "none", fascia: true, hatch: true });
    });

    (doc.details || []).forEach(function (det) {
      if (det.kind !== "elevator") return;

      const level = levelOf(doc, det.level);
      const shape = detailShape(det);
      const inner = rectOf(shape, -shape.w / 2 + 0.02, -shape.d / 2 + 0.02, shape.w / 2 - 0.02, shape.d / 2 - 0.02);
      let below = level;

      sortedLevels.filter(function (l) { return l.z > (Number(level.z) || 0) + 0.5; }).forEach(function (l) {
        out.holes.push({ level: l.id, points: inner, open: -1, void: det.id, below: below.id, rail: "none", fascia: true, shaft: true });
        below = l;
      });
    });

    (doc.details || []).forEach(function (det) {
      if (det.kind !== "void") return;

      const level = levelOf(doc, det.level);
      const below = levelBelowOf(level);
      const shape = detailShape(det);

      out.holes.push({ level: level.id, points: shape.points, open: -1, void: det.id, below: below ? below.id : null, rail: det.rail || "glass", fascia: true });
    });

    (doc.openings || []).forEach(function (o) {
      const wall = wallById.get(o.wall);

      if (!wall) return;

      const defaults = OPENINGS[o.kind] || OPENINGS.door;
      const chord = sub(wall.b, wall.a);
      const total = len(chord);

      if (total < 0.2 || Math.abs(Number(wall.bend) || 0) >= 0.02) return;

      const d = norm(chord);
      const width = Math.max(0.3, Math.min(total - 0.1, Number(o.width) || defaults.width));
      const t = Math.max(width / 2 + 0.05, Math.min(total - width / 2 - 0.05, Number(o.t) || total / 2));
      const c = add(wall.a, mul(d, t));
      const level = levelOf(doc, wall.level);
      const sides = out.rooms.filter(function (room) {
        return room.edges.some(function (e) {
          if (e.wall !== wall.id) return false;

          const u = dot(sub(c, e.a), norm(sub(e.b, e.a)));

          return u + width / 2 > 0.02 && u - width / 2 < e.length - 0.02;
        });
      });
      const roomHeight = sides.length ? Math.min.apply(null, sides.map(function (r) { return r.height; })) : Number(level.height) || 2.8;
      const sill = Math.max(0, Math.min(roomHeight - 0.2, Number(o.sill !== undefined ? o.sill : defaults.sill) || 0));
      let height = o.kind === "half" ? roomHeight - sill : o.kind === "round" ? width : Number(o.height) || defaults.height;

      height = Math.max(0.2, Math.min(roomHeight - sill, height));

      const item = {
        id: o.id, kind: o.kind || "door", wall: wall.id, level: level.id, c: c, d: d, n: left(d), t: t, width: width, z0: sill, z1: sill + height, depth: thickOf(wall),
        door: o.door === undefined ? defaults.door : o.door, glass: o.glass === undefined ? defaults.glass : o.glass, view: o.view, flip: !!o.flip, swing: !!o.swing, frame: o.frame === undefined ? null : o.frame, shape: o.shape || defaults.shape || "rect",
        rooms: sides.map(function (r) { return r.id; }), exterior: sides.length < 2,
        bars: BAR_KINDS.indexOf(o.bars) > 0 ? o.bars : "none", trim: o.trim || "", trimw: Math.max(0.02, Math.min(0.2, Number(o.trimw) || 0.06)), sillMat: o.sillMat || "", shade: o.shade || "", shadeDrop: Number(o.shadeDrop) || 0.6, fake: o.kind === "fake", garage: o.kind === "garage" ? (o.garage === undefined ? "white" : o.garage) : null
      };

      out.openings.push(item);

      if (item.fake) return;

      sides.forEach(function (room) {
        room.edges.forEach(function (edge) {
          if (edge.wall !== wall.id) return;

          const ed = norm(sub(edge.b, edge.a));
          const u = dot(sub(c, edge.a), ed);
          const u0 = Math.max(0, u - width / 2);
          const u1 = Math.min(edge.length, u + width / 2);

          if (u1 - u0 < 0.05) return;

          (edge.holes = edge.holes || []).push({ u0: round(u0, 4), u1: round(u1, 4), z0: item.z0, z1: item.z1, opening: o.id });
        });
      });
    });

    (doc.stairs || []).forEach(function (s) {
      const level = levelOf(doc, s.level);
      const sorted = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
      const above = sorted.find(function (l) { return l.z > level.z + 0.5; });

      if (!above) {
        out.warnings.push({ code: "stairs-top", id: s.id });
        return;
      }

      let frameAxis = null;

      if (s.type === "spiral") {
        const host = out.rooms.find(function (r) { return r.level === above.id && insidePolygon(s.at || [0, 0], r.points); }) || out.rooms.find(function (r) { return r.level === level.id && insidePolygon(s.at || [0, 0], r.points); });

        if (host) frameAxis = tileFrame(host).ax;
      }

      const g = stairGeometry(snapStairToWalls(doc, s, level, above), level, above, frameAxis);

      out.stairs.push(g);
      g.holes.forEach(function (h, index) {
        const n = h.points.length;
        let twice = 0;

        for (let i = 0; i < n; i++) twice += h.points[i][0] * h.points[(i + 1) % n][1] - h.points[(i + 1) % n][0] * h.points[i][1];

        const flip = twice < 0;
        const points = flip ? h.points.slice().reverse() : h.points;
        const open = flip && h.open >= 0 ? ((n - 2 - h.open) % n + n) % n : h.open;

        const quiet = (h.quiet || []).map(function (q) { return flip ? ((n - 2 - q) % n + n) % n : q; });

        if (n === 4 && !g.spiral) {
          const nearWalls = (doc.walls || []).filter(function (w) { return (w.level === above.id || w.level === level.id) && w.a && w.b && Math.abs(Number(w.bend) || 0) < 0.02; });

          for (let i = 0; i < 4; i++) {
            const a = points[i];
            const b = points[(i + 1) % 4];
            const dir = norm(sub(b, a));
            const nrm = [dir[1], -dir[0]];
            const length = len(sub(b, a));
            let move = null;
            let deep = 0.02;

            nearWalls.forEach(function (w) {
              const wd = sub(w.b, w.a);
              const wl = len(wd);

              if (wl < 0.3 || Math.abs(dot(mul(wd, 1 / wl), dir)) < 0.995) return;

              const ta = dot(sub(w.a, a), dir);
              const tb = dot(sub(w.b, a), dir);

              if (Math.min(ta, tb) > length * 0.7 || Math.max(ta, tb) < length * 0.3) return;

              const face = dot(sub(w.a, a), nrm) - Math.max(0.08, Number(w.thick) || thick) / 2;

              if (face > -0.15 && face < 0.35 && (move === null || face < move)) {
                move = face;
                deep = -0.001;
              }
            });

            if (move !== null && Math.abs(move + deep) > 0.0005) {
              const shift = mul(nrm, move + deep);

              points[i] = add(points[i], shift);
              points[(i + 1) % 4] = add(points[(i + 1) % 4], shift);
            }
          }
        }

        h.points = points;
        h.open = open;
        h.quiet = quiet;
        out.holes.push({ level: above.id, points: points, open: open, quiet: quiet, stair: s.id, part: index });
      });
    });

    (doc.pools || []).forEach(function (pool) {
      const level = levelOf(doc, pool.level);
      const w = Math.max(1, Math.min(12, Number(pool.w) || 4));
      const l = Math.max(1, Math.min(20, Number(pool.l) || 8));
      const depth = Math.max(0.4, Math.min(3, Number(pool.depth) || 1.5));
      const h = (Number(pool.heading) || 0) * Math.PI / 180;
      const ax = [Math.cos(h), Math.sin(h)];
      const ay = left(ax);
      const c = pool.at || [0, 0];
      const corner = function (x, y) { return add(add(c, mul(ax, x)), mul(ay, y)); };
      const points = [corner(-w / 2, -l / 2), corner(w / 2, -l / 2), corner(w / 2, l / 2), corner(-w / 2, l / 2)];

      out.pools.push({ id: pool.id, level: level.id, z: Number(level.z) || 0, points: points, w: w, l: l, depth: depth, ax: ax, ay: ay, at: c, heading: Number(pool.heading) || 0, tile: pool.tile || "pooltile", edge: pool.edge || "terrazzo", ladder: pool.ladder !== false, water: pool.water !== false });
      out.holes.push({ level: level.id, points: points, pool: pool.id });
    });

    (doc.details || []).forEach(function (det) {
      const level = levelOf(doc, det.level);
      const shape = detailShape(det);

      const aboveLevel = (doc.levels || []).filter(function (l) { return (Number(l.z) || 0) > (Number(level.z) || 0) + 0.5; }).sort(function (a, b) { return a.z - b.z; })[0];

      out.details.push(Object.assign(shape, { id: det.id, level: level.id, z: Number(level.z) || 0, height: Number(level.height) || 2.8, climb: aboveLevel ? round((Number(aboveLevel.z) || 0) - (Number(level.z) || 0), 3) : Number(level.height) || 2.8 }));
    });

    return out;
  }

  function sizeSplit(length, tall, sizes) {
    const parts = [];
    let left = length;
    let at = 0;

    if (tall && wideKit && left >= 3 - 1e-6 && left < 3.25) {
      parts.push({ at: 0, size: 3, kit: true });
      at = 3;
      left -= 3;
    } else if (tall && left >= 2.8 - 1e-6) {
      parts.push({ at: 0, size: 2.8, kit: true });
      at = 2.8;
      left -= 2.8;
    }

    for (const size of (sizes || SIZES)) {
      while (left >= size - 1e-6) {
        parts.push({ at: at, size: size, kit: true });
        at += size;
        left -= size;
      }
    }

    if (left > 0.004) parts.push({ at: at, size: left, kit: false });

    return parts;
  }

  function pieceWorld(origin, d, along, z) {
    return [origin[0] + d[0] * along, origin[1] + d[1] * along, z];
  }

  const QG = 0.25;
  const QE = 0.0001;
  let quadKit = null;

  function quadIndex(list, w, p) {
    for (let i = 0; i < list.length; i++) if (Math.abs(list[i][0] - w) < QE * 10 && Math.abs(list[i][1] - p) < QE * 10) return i;

    return -1;
  }

  function hostOf(list, start) {
    const phase = Math.round(((((start % 1) + 1) % 1) / QG)) * QG % 1;

    return quadIndex(list, QG, phase);
  }

  function remnant(list, at, size, start) {
    const idx = hostOf(list, start);

    if (idx >= 0) return { at: at, size: size, idx: idx, scale: size / QG };

    const phase = Math.round(((((start % 1) + 1) % 1) / QG)) * QG % 1;
    let best = -1;

    for (let i = 0; i < list.length; i++) {
      if (Math.abs(list[i][1] - phase) < QE * 10 && (best < 0 || list[i][0] < list[best][0])) best = i;
    }

    return { at: at, size: size, idx: best, scale: best >= 0 ? size / list[best][0] : 1 };
  }

  const PLAIN = new Set(["white", "warm", "grey", "stucco", "beige", "roughw", "ceil", "ceilc", "rawconc", "concrete", "polished", "sage", "navy", "terracotta", "charcoal", "blush", "forest", "sand", "carpet", "carpetn", "carpetr", "rubber", "steel", "brass", "whitem", "blackm", "fabric", "soil", "sandb", "s1", "s2", "s3", "s4", "s5", "s6"]);
  const PLAIN_SIZES = [0.25, 0.5, 0.75, 1, 2, 4];

  function decomposePlain(a, b, list) {
    const out = [];
    const length = b - a;

    if (length < 0.002) return out;

    for (const special of [2.8, 3]) {
      if (Math.abs(length - special) < 0.002 && quadIndex(list, special, 0) >= 0) return [{ at: a, size: length, idx: quadIndex(list, special, 0) }];
    }

    let x = a;

    for (const big of [4, 2, 1]) {
      while (b - x >= big - QE) {
        out.push({ at: x, size: big, idx: quadIndex(list, big, 0) });
        x += big;
      }
    }

    const rest = b - x;

    if (rest > 0.002) {
      const last = out[out.length - 1];
      const merged = last ? last.size + rest : rest;
      const host = PLAIN_SIZES.find(function (s) { return s >= merged - 1e-6; });

      if (last && host && merged / host >= 0.5 && host - merged <= length - merged + 0.002) {
        out[out.length - 1] = { at: last.at, size: merged, idx: quadIndex(list, host, 0), scale: merged / host };
      } else {
        const own = PLAIN_SIZES.find(function (s) { return s >= rest - 1e-6; });

        out.push({ at: x, size: rest, idx: quadIndex(list, own, 0), scale: rest / own });
      }
    }

    out.forEach(function (c) { if (c.scale !== undefined && Math.abs(c.scale - 1) < 1e-4) delete c.scale; });

    const scaledAt = out.findIndex(function (c) { return c.scale !== undefined; });

    if (scaledAt > 0) {
      const moved = out.splice(scaledAt, 1)[0];
      let at = a;

      out.unshift(moved);
      out.forEach(function (c) { c.at = at; at += c.size; });
    }

    return out;
  }

  function decompose(a, b, list, mat) {
    if (mat && (PLAIN.has(mat) || /^p\d\d$/.test(mat))) return decomposePlain(a, b, list);

    const out = [];

    if (b - a < 0.002) return out;

    for (const special of [2.8, 3]) {
      if (Math.abs(a - Math.round(a)) < QE && Math.abs(b - a - special) < 0.002 && quadIndex(list, special, 0) >= 0) {
        out.push({ at: a, size: b - a, idx: quadIndex(list, special, 0) });
        return out;
      }
    }

    const a2 = Math.ceil(a / QG - QE) * QG;
    const b2 = Math.floor(b / QG + QE) * QG;

    if (b2 - a2 < QG - QE) {
      if (b2 - a2 > -QE && a2 - a > 0.002 && b - a2 > 0.002) {
        out.push(remnant(list, a, a2 - a, a2 - QG), remnant(list, a2, b - a2, a2));
        return absorbSlivers(out);
      }

      out.push(remnant(list, a, b - a, Math.floor(a / QG + QE) * QG));
      return out;
    }

    if (a2 - a > 0.002) out.push(remnant(list, a, a2 - a, a2 - QG));

    let x = a2;
    const phase = x - Math.floor(x + QE);

    if (phase > QE) {
      const n = Math.floor(x + QE) + 1;
      const to = b2 >= n - QE ? n : b2;

      out.push({ at: x, size: to - x, idx: quadIndex(list, to - x, phase) });
      x = to;
    }

    if (b2 - x > QE) {
      for (const special of [2.8, 3]) {
        if (Math.abs(b - x - special) < 0.002 && quadIndex(list, special, 0) >= 0) {
          out.push({ at: x, size: b - x, idx: quadIndex(list, special, 0) });
          return out;
        }
      }
    }

    for (const big of [4, 2, 1]) {
      while (b2 - x >= big - QE) {
        out.push({ at: x, size: big, idx: quadIndex(list, big, 0) });
        x += big;
      }
    }

    if (b2 - x > QE) {
      out.push({ at: x, size: b2 - x, idx: quadIndex(list, b2 - x, 0) });
      x = b2;
    }

    if (b - x > 0.002) out.push(remnant(list, x, b - x, x));

    return absorbSlivers(out);
  }

  function absorbSlivers(out) {
    if (out.length < 2) return out;

    const tiny = function (c) { return c.scale !== undefined && c.size < 0.045; };
    const grow = function (c, extra, front) {
      const base = c.scale || 1;
      const host = c.size / base;
      const size = c.size + extra;

      return { at: front ? c.at - extra : c.at, size: size, idx: c.idx, scale: size / host };
    };

    const fits = function (c, extra) { return (c.size + extra) / (c.size / (c.scale || 1)) <= 1.12; };

    if (tiny(out[out.length - 1]) && out[out.length - 2].scale === undefined && fits(out[out.length - 2], out[out.length - 1].size)) {
      const last = out.pop();

      out[out.length - 1] = grow(out[out.length - 1], last.size, false);
    }

    if (out.length >= 2 && tiny(out[0]) && out[1].scale === undefined && fits(out[1], out[0].size)) {
      const first = out.shift();

      out[0] = grow(out[0], first.size, true);
    }

    return out;
  }

  function quadName(prefix, mat, ui, vi) {
    return prefix + mat + "_q" + quadKit.code[ui] + quadKit.code[vi];
  }

  function emitFace(pieces, mat, A, d, z, u0, u1, za, zb, prefix, anchor, anchorV) {
    const yw = round(yaw(d), 2);
    const W = u1 - u0;
    const H = zb - za;

    if (W < 0.002 || H < 0.002) return;

    if (!quadKit || !trimSet || !trimSet.has(mat)) {
      trimPiece(pieces, prefix, mat, pieceWorld(A, d, u0, z + za), 0, yw, W, H);
      return;
    }

    const base = Number(anchor) || 0;
    const baseV = Number(anchorV) || 0;
    const vs = decompose(za + baseV, zb + baseV, quadKit.v, mat).map(function (cv) { return Object.assign({}, cv, { at: cv.at - baseV }); });

    if (curveMode && curveKit && curveKit.materials.indexOf(baseMat(mat)) >= 0 && W > 0.01) {
      const width = W <= 0.375 ? curveKit.widths[0] : curveKit.widths[curveKit.widths.length - 1];
      const sx = (W + 0.003) / width.size;
      const wantTilt = Math.abs(curveBend) / 2 * Math.PI / 180;
      const tilt = Math.atan(Math.tan(wantTilt) / Math.max(0.2, sx)) * 180 / Math.PI;
      const bend = Math.max(1, Math.min(curveKit.bends[curveKit.bends.length - 1], Math.round(tilt)));
      const hosts = Array.isArray(curveKit.heights) ? curveKit.heights : [[curveKit.height, ""]];
      const host = hosts.find(function (hh) { return hh[0] >= H - 1e-6; }) || hosts[hosts.length - 1];
      const code = width.code + (curveBend >= 0 ? "n" : "p") + bend + host[1];
      const rows = Math.max(1, Math.ceil(H / host[0] - 1e-6));
      const step = H / rows;

      for (let k = 0; k < rows; k++) {
        const at = pieceWorld(A, d, u0 - 0.0015, z + za + step * k);

        pieces.push([prefix + "curve_" + mat + "_" + code, round(at[0]), round(at[1]), round(at[2]), 0, yw, round(sx, 4), round(step / host[0], 4)]);
      }

      return;
    }

    if (curveMode && W > 0.12) {
      let unit = 0.5;
      let count = Math.max(1, Math.round(W / unit));

      if (W / (count * unit) > 1.0001 || Math.abs(W / (count * unit) - 1) > 0.2) {
        unit = W > 0.5 ? 0.5 : 0.25;
        count = Math.max(1, Math.ceil(W / unit - 1e-6));
      }

      const scale = W / (count * unit);
      const okV = vs.filter(function (cv) { return cv.idx >= 0; });

      for (let k = 0; k < count; k++) {
        const phase = Math.round((((base + u0 + k * unit * scale) % 1) + 1) % 1 / QG) * QG % 1;
        let ui = quadIndex(quadKit.u, unit, phase);

        if (ui < 0) ui = quadIndex(quadKit.u, unit, 0);

        okV.forEach(function (cv) {
          const at = pieceWorld(A, d, u0 + k * unit * scale, z + cv.at);

          pieces.push([quadName(prefix, mat, ui, cv.idx), round(at[0]), round(at[1]), round(at[2]), 0, yw, round(scale, 4), round(cv.scale || 1, 4)]);
        });
      }

      vs.forEach(function (cv) {
        if (cv.idx < 0) trimPiece(pieces, prefix, mat, pieceWorld(A, d, u0, z + cv.at), 0, yw, W, cv.size);
      });

      return;
    }

    const us = decompose(base + u0, base + u1, quadKit.u, mat);

    us.forEach(function (cu) {
      const hostU = cu.idx >= 0 ? quadKit.u[cu.idx][0] : cu.size;
      const over = cu.at - base + hostU > u1 + 0.01;
      let colTop = null;

      vs.forEach(function (cv) {
        const at = pieceWorld(A, d, cu.at - base, z + cv.at);

        if (cu.idx < 0 || cv.idx < 0) {
          trimPiece(pieces, prefix, mat, at, 0, yw, cu.size, cv.size);
          return;
        }

        const sx = cu.scale || 1;
        const sz = cv.scale || 1;
        const piece = [quadName(prefix, mat, cu.idx, cv.idx), round(at[0]), round(at[1]), round(at[2]), 0, yw];

        if (sx !== 1 || sz !== 1) piece.push(round(sx, 4), round(sz, 4));

        if (over) {
          noCollide(piece);
          if (cv.at < 2.0) colTop = Math.max(colTop || 0, cv.at + cv.size);
        }

        pieces.push(piece);
      });

      if (faceCols && colTop !== null && cu.size > 0.04 && colTop - za > 0.04) {
        const at = pieceWorld(A, d, cu.at - base, z + za);

        faceCols.push({ origin: [at[0], at[1], at[2]], pitch: 0, yaw: yw, roll: 0, x0: 0, x1: cu.size, y0: -0.1, z0: 0, z1: colTop - za });
      }
    });
  }

  const SEAM = 0.0015;

  function mergeRects(rects) {
    const snap = function (v) { return Math.round(v / 0.002) * 0.002; };
    const us = Array.from(new Set(rects.flatMap(function (r) { return [snap(r[0]), snap(r[1])]; }))).sort(function (a, b) { return a - b; });
    const vs = Array.from(new Set(rects.flatMap(function (r) { return [snap(r[2]), snap(r[3])]; }))).sort(function (a, b) { return a - b; });
    const nu = us.length - 1;
    const nv = vs.length - 1;
    const out = [];

    if (nu < 1 || nv < 1) return out;

    const cell = new Uint8Array(nu * nv);

    rects.forEach(function (r) {
      const i0 = us.indexOf(snap(r[0]));
      const i1 = us.indexOf(snap(r[1]));
      const j0 = vs.indexOf(snap(r[2]));
      const j1 = vs.indexOf(snap(r[3]));

      for (let j = j0; j < j1; j++) for (let i = i0; i < i1; i++) cell[j * nu + i] = 1;
    });

    for (let j = 0; j < nv; j++) {
      for (let i = 0; i < nu; i++) {
        if (cell[j * nu + i] !== 1) continue;

        let i1 = i;

        while (i1 + 1 < nu && cell[j * nu + i1 + 1] === 1) i1++;

        let j1 = j;

        for (;;) {
          if (j1 + 1 >= nv) break;

          let full = true;

          for (let k = i; k <= i1; k++) if (cell[(j1 + 1) * nu + k] !== 1) { full = false; break; }

          if (!full) break;
          j1++;
        }

        for (let jj = j; jj <= j1; jj++) for (let k = i; k <= i1; k++) cell[jj * nu + k] = 2;

        out.push([us[i], us[i1 + 1], vs[j], vs[j1 + 1]]);
      }
    }

    return out;
  }

  function quadColliders(pieces, count, colliders, above, rooms) {
    const re = /_q([0-9a-j])([0-9a-j])$/;
    const groups = new Map();

    for (let i = 0; i < count; i++) {
      const p = pieces[i];

      if (p.noCol || Number(p[10]) === 1) continue;

      const m = re.exec(p[0]);

      if (!m) continue;

      const ui = quadKit.code.indexOf(m[1]);
      const vi = quadKit.code.indexOf(m[2]);

      if (ui < 0 || vi < 0 || !quadKit.u[ui] || !quadKit.v[vi]) continue;

      const pitch = Number(p[4]) || 0;
      const yw = Number(p[5]) || 0;
      const roll = Number(p[8]) || 0;
      const ax = axesOf(pitch, roll, yw);

      if (ax[1][2] < -0.7) continue;

      const sx = p[6] === undefined || p[6] === null ? 1 : Number(p[6]);
      const sz = p[7] === undefined || p[7] === null ? 1 : Number(p[7]);
      const W = quadKit.u[ui][0] * sx;
      const H = quadKit.v[vi][0] * sz;

      if (W < 0.01 || H < 0.01) continue;

      const pos = [Number(p[1]), Number(p[2]), Number(p[3])];
      const proj = function (k) { return pos[0] * ax[k][0] + pos[1] * ax[k][1] + pos[2] * ax[k][2]; };
      const u = proj(0);
      const n = proj(1);
      const v = proj(2);
      const wallish = Math.abs(ax[1][2]) < 0.3;
      let band = 0;

      if (wallish) {
        const zb = Math.min(pos[2], pos[2] + ax[0][2] * W, pos[2] + ax[2][2] * H);

        band = Math.round(zb + 0.3 - above(zb + 0.3));

        if (rooms && rooms.length) {
          const probes = [0.05, 0.5, 0.95].map(function (f) { return [0, 1].map(function (k) { return pos[k] + ax[0][k] * W * f + ax[2][k] * H / 2 + ax[1][k] * 0.12; }); });

          if (!rooms.some(function (room) { return Math.abs((Number(room.z) || 0) - band) < 0.6 && probes.some(function (probe) { return insidePolygon(probe, room.points); }); })) continue;
        }
      }

      const key = [Math.round(pitch * 10), Math.round(((yw % 360) + 360) % 360 * 10), Math.round(roll * 10), Math.round(n * 200), band].join("|");

      if (!groups.has(key)) groups.set(key, { pitch: pitch, yaw: yw, roll: roll, n: n, rects: [], wall: wallish, band: band });
      groups.get(key).rects.push([u, u + W, v, v + H]);
    }

    groups.forEach(function (g) {
      const ax = axesOf(g.pitch, g.roll, g.yaw);

      mergeRects(g.rects).forEach(function (r) {
        let down = 0;

        if (g.wall) {
          const z0 = Math.min(ax[2][2] * r[2], ax[2][2] * r[3]);
          const z1 = Math.max(ax[2][2] * r[2], ax[2][2] * r[3]);
          const base = [ax[0][0] * r[0] + ax[1][0] * g.n, ax[0][1] * r[0] + ax[1][1] * g.n, ax[0][2] * r[0] + ax[1][2] * g.n + z0];

          if (base[2] - g.band >= 2.0) return;
          if (z1 <= g.band + 0.05) return;

          if (Math.abs(g.pitch) < 1 && Math.abs(g.roll) < 1) down = Math.max(0, Math.min(0.45, base[2] - (g.band - 0.3)));
        }

        colliders.push({ origin: [0, 0, 0], pitch: g.pitch, yaw: g.yaw, roll: g.roll, x0: r[0], x1: r[1], y0: g.n - 0.1, z0: r[2], z1: r[3], tight: true, down: down });
      });
    });

    for (let i = 0; i < count; i++) if (re.test(pieces[i][0]) && !pieces[i].noCol) noCollide(pieces[i]);
  }

  function mergePlainQuads(pieces, prefix, levelZs) {
    const re = /^(.*)_q([0-9a-j])([0-9a-j])$/;
    const hostsU = [0.25, 0.5, 0.75, 1, 2, 4];
    const hostsV = [0.25, 0.5, 0.75, 1, 2, 3, 4];
    const groups = new Map();
    const order = new Map();
    const replace = new Map();

    pieces.forEach(function (p, i) { order.set(p, i); });

    const hostFor = function (list, hosts, size) {
      const host = hosts.find(function (s) { return s >= size - 0.0005; });

      if (host === undefined) return null;

      const idx = quadIndex(list, host, 0);

      return idx >= 0 ? { size: host, idx: idx } : null;
    };

    pieces.forEach(function (p) {
      const m = re.exec(p[0]);
      const mat = m && String(m[1]).indexOf(prefix) === 0 ? String(m[1]).slice(prefix.length) : null;

      if (!m || p.trim || !(PLAIN.has(mat) || /^p\d\d$/.test(mat))) return;

      const ui = quadKit.code.indexOf(m[2]);
      const vi = quadKit.code.indexOf(m[3]);

      if (ui < 0 || vi < 0 || !quadKit.u[ui] || !quadKit.v[vi] || quadKit.u[ui][1] !== 0 || quadKit.v[vi][1] !== 0) return;

      const pitch = Number(p[4]) || 0;
      const yw = Number(p[5]) || 0;
      const roll = Number(p[8]) || 0;
      const ax = axesOf(pitch, roll, yw);
      const sx = p[6] === undefined || p[6] === null ? 1 : Number(p[6]);
      const sz = p[7] === undefined || p[7] === null ? 1 : Number(p[7]);
      const W = quadKit.u[ui][0] * sx;
      const H = quadKit.v[vi][0] * sz;
      const pos = [Number(p[1]), Number(p[2]), Number(p[3])];
      const proj = function (k) { return pos[0] * ax[k][0] + pos[1] * ax[k][1] + pos[2] * ax[k][2]; };
      const zmin = Math.min(pos[2], pos[2] + ax[0][2] * W, pos[2] + ax[2][2] * H, pos[2] + ax[0][2] * W + ax[2][2] * H);
      const band = levelZs.filter(function (z) { return z - 0.03 < zmin - 0.0005; }).length;
      const tail = JSON.stringify(p.slice(9).map(function (v, i) { return i === 1 ? (p.noCol || Number(v) === 1 ? 1 : 0) : v === undefined ? null : v; }));
      const key = [mat, Math.round(pitch * 100), Math.round((((yw % 360) + 360) % 360) * 100), Math.round(roll * 100), Math.round(proj(1) * 1000), band, p.noCol ? 1 : 0, tail].join("|");

      if (!groups.has(key)) groups.set(key, { mat: mat, ax: ax, n: proj(1), src: p, rects: [] });
      groups.get(key).rects.push({ u0: proj(0), u1: proj(0) + W, v0: proj(2), v1: proj(2) + H, p: p, first: order.get(p) });
    });

    groups.forEach(function (g) {
      if (g.rects.length < 2) return;

      const split = function (list) {
        const res = [];

        list.forEach(function (r) {
          const nu = Math.max(1, Math.ceil((r[1] - r[0]) / 4 - 0.0005));
          const nv = Math.max(1, Math.ceil((r[3] - r[2]) / 4 - 0.0005));
          const du = (r[1] - r[0]) / nu;
          const dv = (r[3] - r[2]) / nv;

          for (let i = 0; i < nu; i++) for (let j = 0; j < nv; j++) res.push([r[0] + du * i, r[0] + du * (i + 1), r[2] + dv * j, r[2] + dv * (j + 1)]);
        });

        return res;
      };
      const rows = split(mergeRects(g.rects.map(function (r) { return [r.u0, r.u1, r.v0, r.v1]; })));
      const cols = split(mergeRects(g.rects.map(function (r) { return [r.v0, r.v1, r.u0, r.u1]; })).map(function (r) { return [r[2], r[3], r[0], r[1]]; }));
      const tiles = cols.length < rows.length ? cols : rows;

      if (tiles.length >= g.rects.length) return;
      if (tiles.some(function (t) { return t[1] - t[0] < 0.002 || t[3] - t[2] < 0.002 || !hostFor(quadKit.u, hostsU, t[1] - t[0]) || !hostFor(quadKit.v, hostsV, t[3] - t[2]); })) return;

      let first = g.rects[0];

      g.rects.forEach(function (r) { if (r.first < first.first) first = r; replace.set(r.p, null); });

      const made = tiles.map(function (t) {
        const hu = hostFor(quadKit.u, hostsU, t[1] - t[0]);
        const hv = hostFor(quadKit.v, hostsV, t[3] - t[2]);
        const ax = g.ax;
        const w = [0, 1, 2].map(function (k) { return ax[0][k] * t[0] + ax[1][k] * g.n + ax[2][k] * t[2]; });
        const piece = first.p.slice();

        piece[0] = quadName(prefix, g.mat, hu.idx, hv.idx);
        piece[1] = round(w[0], 4);
        piece[2] = round(w[1], 4);
        piece[3] = round(w[2], 4);
        while (piece.length < 8) piece.push(1);
        piece[6] = round((t[1] - t[0]) / hu.size, 5);
        piece[7] = round((t[3] - t[2]) / hv.size, 5);
        if (first.p.noCol) piece.noCol = true;

        return piece;
      });

      replace.set(first.p, made);
    });

    if (!replace.size) return;

    const out = [];

    pieces.forEach(function (p) {
      if (!replace.has(p)) out.push(p);
      else if (replace.get(p)) replace.get(p).forEach(function (q) { out.push(q); });
    });
    pieces.length = 0;
    out.forEach(function (p) { pieces.push(p); });
  }

  function overlapQuads(pieces) {
    const re = /_q([0-9a-j])([0-9a-j])$/;

    pieces.forEach(function (piece) {
      const m = re.exec(piece[0]);

      if (!m) return;

      const ui = quadKit.code.indexOf(m[1]);
      const vi = quadKit.code.indexOf(m[2]);

      if (ui < 0 || vi < 0 || !quadKit.u[ui] || !quadKit.v[vi]) return;

      const sx = piece[6] === undefined || piece[6] === null ? 1 : Number(piece[6]);
      const sz = piece[7] === undefined || piece[7] === null ? 1 : Number(piece[7]);
      const W = quadKit.u[ui][0] * sx;
      const H = quadKit.v[vi][0] * sz;

      if (W < 0.004 || H < 0.004) return;

      const ax = axesOf(Number(piece[4]) || 0, Number(piece[8]) || 0, Number(piece[5]) || 0);

      for (let k = 0; k < 3; k++) piece[k + 1] = round(piece[k + 1] - ax[0][k] * SEAM - ax[2][k] * SEAM, 4);

      while (piece.length < 8) piece.push(1);
      piece[6] = round(sx * (W + 2 * SEAM) / W, 5);
      piece[7] = round(sz * (H + 2 * SEAM) / H, 5);
    });
  }

  function bigRings(pieces, prefix, base) {
    const re = new RegExp("^" + prefix + "(ring|halfring|tube|halftube)_[a-z]+$");

    pieces.forEach(function (piece) {
      if (!re.test(piece[0])) return;

      const sx = Number(piece[6]) || 1;
      const sz = Number(piece[7]) || 1;

      if (Math.max(sx, sz) <= 1.0001) return;

      piece[0] = piece[0] + "_b";
      piece[6] = round(sx / base, 5);
      piece[7] = round(sz / base, 5);
      if (piece.length > 9 && piece[9] !== undefined && piece[9] !== null) piece[9] = round((Number(piece[9]) || 1) / base, 5);
      else {
        while (piece.length < 9) piece.push(0);
        piece[9] = round(1 / base, 5);
      }
    });
  }

  let tintKit = null;

  function tintOf(mat) {
    const m = /^([pw])(\d\d)$/.exec(String(mat || ""));

    if (!m || !tintKit) return null;

    const base = tintKit.bases.find(function (b) { return b.prefix === m[1]; });
    const row = Number(m[2]) - 1;

    return base && row >= 0 && row < tintKit.colours.length ? { base: base.key, row: row, colour: tintKit.colours[row], builtin: base.builtin } : null;
  }

  function baseMat(mat) {
    const t = tintOf(mat);

    return t ? t.base : mat;
  }

  function tintPieces(pieces) {
    pieces.forEach(function (piece) {
      const parts = String(piece[0]).split("_");

      for (let i = 2; i < parts.length; i++) {
        const t = /^[pw]\d\d$/.test(parts[i]) ? tintOf(parts[i]) : null;

        if (!t) continue;

        parts[i] = t.base;
        piece[0] = parts.join("_");

        const defaults = [null, null, null, null, 0, 0, 1, 1, 0, 1, 0];

        for (let k = piece.length; k < 11; k++) piece.push(defaults[k]);
        piece[11] = t.row;
        break;
      }
    });
  }

  function noCollide(piece) {
    while (piece.length < 10) piece.push(piece.length === 6 || piece.length === 7 ? 1 : piece.length === 9 ? 1 : 0);
    piece[10] = 1;
    piece.noCol = true;
  }

  function emitBacking(pieces, prefix, mat, at, pitch, yw, sx, sz) {
    if (!backingSet || sx < 0.01 || sz < 0.01) return;

    const key = backingSet.has(mat) ? mat : "white";

    if (!backingSet.has(key)) return;

    const piece = [prefix + "bk_" + key, round(at[0]), round(at[1]), round(at[2]), pitch, round(yw, 2), round(sx, 4), round(sz, 4)];

    piece.noCol = true;
    pieces.push(piece);
  }

  function detailShape(det) {
    const kind = DETAILS[det.kind] ? det.kind : "column";
    const base = DETAILS[kind];
    const num = function (v, fallback, lo, hi) { const n = Number(v); return Math.max(lo, Math.min(hi, isFinite(n) && n > 0 ? n : fallback)); };
    const round2 = kind === "pillar" || kind === "ladder";
    const w = round2 ? base.w : num(det.w, base.w, 0.1, 30);
    const d = round2 ? base.d : kind === "glassrail" || kind === "rail" || kind === "glasswall" ? base.d : num(det.d, base.d, 0.01, 12);
    const h = base.h === 0 ? 0 : num(det.h, base.h, 0.05, 4);
    const hd = (Number(det.heading) || 0) * Math.PI / 180;
    const ax = [Math.cos(hd), Math.sin(hd)];
    const ay = left(ax);
    const c = det.at || [0, 0];
    const corner = function (x, y) { return add(add(c, mul(ax, x)), mul(ay, y)); };

    const lift = base.lift === undefined ? 0 : num(det.lift, base.lift, 0, 4);
    const shape = base.shaped && (det.shape === "round" || det.shape === "oval") ? det.shape : "rect";
    const outline = shape === "rect" ? null : (function () {
      const out = [];
      const ry = shape === "round" ? w / 2 : d / 2;
      const steps = 64;

      for (let i = 0; i < steps; i++) {
        const a = i / steps * Math.PI * 2;

        out.push(corner(Math.cos(a) * w / 2, Math.sin(a) * ry));
      }

      return out;
    })();

    return { kind: kind, shape: shape, outline: outline, group: base.group, w: w, d: d, h: h, lift: lift, at: c, ax: ax, ay: ay, heading: Number(det.heading) || 0, mat: det.mat || base.mat, top: det.top || base.top || det.mat || base.mat, glass: det.glass || base.glass || "glass", rail: det.rail || base.rail || "glass", fronts: Number(det.fronts) > 0.2 ? Number(det.fronts) : base.fronts, handles: det.handles || (base.handles ? "bar" : undefined), built: det.built, wall: det.wall || undefined, points: outline || [corner(-w / 2, -d / 2), corner(w / 2, -d / 2), corner(w / 2, d / 2), corner(-w / 2, d / 2)] };
  }

  function elevatorLayout(det) {
    const T = 0.12;
    const iw = det.w / 2 - T;
    const yF = -det.d / 2 + T;
    const door = Math.max(0.7, Math.min(1.2, Math.floor((iw - 0.035) * 4 / 3 * 20 + 1e-6) / 20));
    const cy0 = yF + 0.165;
    const cwH = iw - 0.04;
    const dh = door / 2;
    const copW = round(Math.max(0.1, Math.min(0.2, cwH - dh - 0.1)), 3);
    const copX = round((dh + cwH) / 2 + copW / 2, 4);

    return {
      T: T, door: round(door, 3), doorH: 2.15, CH: 2.35, floor: 0.02, cwH: round(cwH, 4), cy0: round(cy0, 4), cy1: round(det.d / 2 - T - 0.04, 4), yF: round(yF, 4), hd: round(det.d / 2, 4), hw: round(det.w / 2, 4),
      leaf: round(door / 4 + 0.016, 4), leafT: 0.03, landA: round(yF + 0.006, 4), landB: round(yF + 0.041, 4), carB: round(cy0 - 0.08, 4), carA: round(cy0 - 0.045, 4), copW: copW, copX: copX,
      copH: round(copW * 4, 4), copZ0: round(1.62 - copW * 4, 4), copDZ: round(1.62 - copW * 4 + copW * 4 * (1 - 97 / 1024), 4),
      callX: round(dh + 0.27, 4), callR: 0.033
    };
  }

  function copButtons(n) {
    const cols = n > 6 ? 2 : 1;
    const rows = Math.ceil(n / cols);
    const top = 210;
    const bottom = 1024 - 250;
    const r = Math.min(36, (bottom - top) / Math.max(1, rows) * 0.36, cols === 2 ? 40 : 50);
    const gap = rows === 1 ? 0 : Math.min((bottom - top) / (rows - 1), r * 2.9);
    const out = [];

    for (let j = 0; j < n; j++) {
      const i = n - 1 - j;
      const row = Math.floor(i / cols);
      const col = i % cols;

      out.push({ cx: cols === 1 ? 128 : 128 + (col === 0 ? -56 : 56), cy: top + 20 + row * gap, r: r });
    }

    return out;
  }

  function rectOf(det, x0, y0, x1, y1) {
    const c = det.at;
    const corner = function (x, y) { return add(add(c, mul(det.ax, x)), mul(det.ay, y)); };

    return [corner(x0, y0), corner(x1, y0), corner(x1, y1), corner(x0, y1)];
  }

  const CASING_DEPTH = 0.024;
  const SKIRT_DEPTH = 0.014;
  const CROWN_DEPTH = 0.03;

  let beamKit = null;
  let bigBoxKit = null;

  function beamPieces(pieces, prefix, mat, p0, dir, w, d, h, z0) {
    const yw = yaw(dir);
    const base = axesOf(0, 0, yw);
    const dims = [w, d, h];
    const order = [0, 1, 2].sort(function (a, b) { return dims[b] - dims[a]; });
    const long = order[0];

    if (dims[long] < 0.3 || dims[order[1]] > 0.35) return false;

    const want = base[long];
    let pick = null;

    for (const pitch of [0, 90, -90, 180]) {
      for (const roll of [0, 90, -90, 180]) {
        for (const add2 of [0, 90, 180, 270]) {
          const ax = axesOf(pitch, roll, yw + add2);

          if (Math.abs(ax[0][0] - want[0]) + Math.abs(ax[0][1] - want[1]) + Math.abs(ax[0][2] - want[2]) < 1e-3) {
            pick = { pitch: pitch, roll: roll, yaw: yw + add2, ax: ax };
            break;
          }
        }
        if (pick) break;
      }
      if (pick) break;
    }

    if (!pick) return false;

    const lengthOf = function (k) {
      let best = 0;

      for (let j = 0; j < 3; j++) {
        const dp = pick.ax[k][0] * base[j][0] + pick.ax[k][1] * base[j][1] + pick.ax[k][2] * base[j][2];

        if (Math.abs(dp) > 0.99) best = { box: j, sign: dp > 0 ? 1 : -1 };
      }

      return best;
    };
    const map = [lengthOf(0), lengthOf(1), lengthOf(2)];

    if (map.some(function (m) { return !m; })) return false;

    const total = dims[long];
    const sizes = beamKit.sizes;
    const host = sizes.find(function (b) { return b.size >= total - 1e-6; }) || sizes[sizes.length - 1];
    const n = Math.max(1, Math.ceil(total / host.size - 1e-6));
    const step = total / n;
    const use = sizes.find(function (b) { return b.size >= step - 1e-6; }) || host;
    const corner = [p0[0], p0[1], z0];

    for (let k = 0; k < n; k++) {
      const origin = corner.slice();

      for (let c = 0; c < 3; c++) origin[c] += base[long][c] * step * k;
      for (let a = 1; a < 3; a++) {
        if (map[a].sign < 0) for (let c = 0; c < 3; c++) origin[c] += base[map[a].box][c] * dims[map[a].box];
      }

      const piece = [prefix + "beam_" + mat + "_" + use.code, round(origin[0]), round(origin[1]), round(origin[2]), pick.pitch, round(((pick.yaw % 360) + 360) % 360, 2), round(step / use.size, 4), round(dims[map[2].box] / beamKit.section, 4), pick.roll, round(dims[map[1].box] / beamKit.section, 4)];

      piece.noCol = true;
      pieces.push(piece);
    }

    return true;
  }

  function boxPiece(pieces, prefix, mat, p0, dir, w, d, z0, h) {
    if (w < 0.004 || d < 0.004 || h < 0.004) return;

    if (beamKit && (!beamKit.materials || beamKit.materials.indexOf(mat) >= 0) && beamPieces(pieces, prefix, mat, p0, dir, w, d, h, z0)) return;

    const big = bigBoxKit && Math.max(w, d, h) > 1.0001 && bigBoxKit.materials.indexOf(baseMat(mat)) >= 0 ? bigBoxKit.size : 1;
    const piece = [prefix + "box_" + mat + (big > 1 ? "_b" : ""), round(p0[0]), round(p0[1]), round(z0), 0, round(yaw(dir), 2), round(w / big, 5), round(h / big, 5), 0, round(d / big, 5)];

    piece.noCol = true;
    pieces.push(piece);
  }

  function prismPiece(pieces, prefix, mat, p0, dir, run, width, z0, rise) {
    if (run < 0.01 || width < 0.01 || rise < 0.01) return;

    const big = bigBoxKit && Math.max(run, rise, width) > 1.0001 && bigBoxKit.materials.indexOf(baseMat(mat)) >= 0 ? bigBoxKit.size : 1;
    const piece = [prefix + "prism_" + mat + (big > 1 ? "_b" : ""), round(p0[0]), round(p0[1]), round(z0), 0, round(yaw(dir), 2), round(run / big, 5), round(rise / big, 5), 0, round(width / big, 5)];

    piece.noCol = true;
    pieces.push(piece);
  }

  function emitBox(pieces, prefix, note, p, z0, z1, mat, topMat, bottomMat, skip) {
    if (z1 - z0 < 0.004) return;

    {
      const bw = len(sub(p[1], p[0]));
      const bd = len(sub(p[3], p[0]));
      const bh = z1 - z0;
      const big = Math.max(bw, bd, bh);
      const thin = Math.min(bw, bd, bh);

      if (trimSet && trimSet.has(mat) && (big <= 1.2 || thin <= 0.08) && (!topMat || topMat === mat)) {
        boxPiece(pieces, prefix, note(mat), p[0], sub(p[1], p[0]), bw, bd, z0, bh);
        return;
      }
    }

    const m = note(mat);

    for (let i = 0; i < 4; i++) {
      if (skip && skip.indexOf(i) >= 0) continue;

      const a = p[(i + 1) % 4];
      const b = p[i];

      emitFace(pieces, m, a, norm(sub(b, a)), z0, 0, len(sub(b, a)), 0, z1 - z0, prefix);
    }

    const room = { points: p, edges: [{ a: p[0], b: p[1], length: len(sub(p[1], p[0])) }], z: 0, height: 0 };
    const bw = len(sub(p[1], p[0]));
    const bd = len(sub(p[3], p[0]));
    const fits = function (v) { return v >= 0.249 && Math.abs(v / CELL - Math.round(v / CELL)) < 0.004; };
    const ax = norm(sub(p[1], p[0]));

    if (fits(bw) && fits(bd)) {
      if (topMat) tileRoom(pieces, prefix, Object.assign({}, room, { z: z1 }), [], note(topMat), false);
      if (bottomMat) tileRoom(pieces, prefix, Object.assign({}, room, { z: z0 }), [], note(bottomMat), true);
    } else {
      if (topMat) emitTrim(pieces, prefix, note(topMat), p[3].concat([z1]), 90, yaw(ax), bw, bd);
      if (bottomMat) emitTrim(pieces, prefix, note(bottomMat), p[0].concat([z0]), -90, yaw(ax), bw, bd);
    }
  }

  function emitFrontLines(pieces, prefix, note, det, z0, z1, every, handles) {
    const count = Math.max(1, Math.round(det.w / every));
    const step = det.w / count;
    const out = mul(det.ay, -(det.d / 2 + 0.003));
    const lineMat = note("blackm");
    const handleMat = note("steel");

    for (let i = 1; i < count; i++) {
      const x = -det.w / 2 + step * i;
      const at = add(add(det.at, mul(det.ax, x + 0.004)), out);

      emitTrim(pieces, prefix, lineMat, at.concat([z0 + 0.01]), 0, yaw(mul(det.ax, -1)), 0.008, z1 - z0 - 0.02);
    }

    if (!handles || det.handles === "none") return;

    const outward = mul(det.ay, -1);
    const along = mul(det.ax, -1);
    const style = det.handles === "knob" ? "knob" : det.handles === "long" ? "long" : "bar";

    for (let i = 0; i < count; i++) {
      const x = -det.w / 2 + step * i + (i % 2 === 0 ? step - 0.06 : 0.06);
      const front = add(add(det.at, mul(det.ax, x)), mul(det.ay, -(det.d / 2 + 0.0005)));
      const hz = handles === "top" ? z1 - 0.12 : handles === "low" ? z0 + 0.06 : (z0 + z1) / 2 - 0.08;
      const tall = style === "knob" ? 0.025 : style === "long" ? Math.min(0.6, z1 - z0 - 0.1) : handles === "top" || handles === "low" ? 0.1 : 0.18;
      const bz = style === "long" ? (z0 + z1) / 2 - tall / 2 : hz;
      const start = add(front, mul(along, -0.0125));

      boxPiece(pieces, prefix, handleMat, add(start, mul(outward, 0)), along, 0.025, style === "knob" ? 0.03 : 0.028, bz, tall);
    }
  }

  function detailBox(pieces, prefix, note, det, x0, y0, x1, y1, z0, z1, mat) {
    if (x1 - x0 < 0.004 || y1 - y0 < 0.004 || z1 - z0 < 0.004) return;

    const p0 = add(add(det.at, mul(det.ax, x0)), mul(det.ay, y0));

    boxPiece(pieces, prefix, note(mat), p0, det.ax, x1 - x0, y1 - y0, z0, z1 - z0);
  }

  function counterTop(pieces, prefix, note, det, z, front, back, sides) {
    emitBox(pieces, prefix, note, rectOf(det, -det.w / 2 - sides, -det.d / 2 - front, det.w / 2 + sides, det.d / 2 + back), z - 0.04, z, det.top, det.top, null);
  }

  function counterHole(pieces, prefix, note, det, z, hole, front, back, sides) {
    const x0 = -det.w / 2 - sides;
    const x1 = det.w / 2 + sides;
    const y0 = -det.d / 2 - front;
    const y1 = det.d / 2 + back;
    const part = function (a, b, c, e) { if (c - a > 0.004 && e - b > 0.004) emitBox(pieces, prefix, note, rectOf(det, a, b, c, e), z - 0.04, z, det.top, det.top, null); };

    part(x0, y0, x1, hole[1]);
    part(x0, hole[3], x1, y1);
    part(x0, hole[1], hole[0], hole[3]);
    part(hole[2], hole[1], x1, hole[3]);
  }

  function rectMinus(x0, y0, x1, y1, holes) {
    const xs = [x0, x1];
    const ys = [y0, y1];

    holes.forEach(function (h) {
      [h[0], h[2]].forEach(function (v) { if (v > x0 + 0.001 && v < x1 - 0.001) xs.push(v); });
      [h[1], h[3]].forEach(function (v) { if (v > y0 + 0.001 && v < y1 - 0.001) ys.push(v); });
    });
    xs.sort(function (a, b) { return a - b; });
    ys.sort(function (a, b) { return a - b; });

    const cells = [];

    for (let j = 1; j < ys.length; j++) {
      let run = null;

      for (let i = 1; i < xs.length; i++) {
        const mx = (xs[i - 1] + xs[i]) / 2;
        const my = (ys[j - 1] + ys[j]) / 2;
        const free = xs[i] - xs[i - 1] > 0.002 && ys[j] - ys[j - 1] > 0.002 && !holes.some(function (h) { return mx > h[0] && mx < h[2] && my > h[1] && my < h[3]; });

        if (free && run) run[2] = xs[i];
        else if (free) run = [xs[i - 1], ys[j - 1], xs[i], ys[j]];
        else if (run) { cells.push(run); run = null; }
      }

      if (run) cells.push(run);
    }

    return cells;
  }

  function hobRings(pieces, prefix, det, r, top) {
    const cols = r[2] - r[0] > 0.45 ? 2 : 1;
    const rows = r[3] - r[1] > 0.4 ? 2 : 1;
    const size = Math.min(0.19, (r[2] - r[0]) / cols - 0.07, (r[3] - r[1]) / rows - 0.07);

    if (size < 0.08) return;

    for (let i = 0; i < cols; i++) {
      for (let j = 0; j < rows; j++) {
        const cx = r[0] + (r[2] - r[0]) * (i + 0.5) / cols;
        const cy = r[1] + (r[3] - r[1]) * (j + 0.5) / rows;
        const s = size * (i === j ? 1 : 0.82);
        const at = add(add(det.at, mul(det.ax, cx - s / 2)), mul(det.ay, cy - s / 2));

        const piece = [prefix + "ring_steel", round(at[0]), round(at[1]), round(top), -90, round(yaw(det.ax), 2), round(s, 4), round(s, 4), 0, 0.02];

        noCollide(piece);
        pieces.push(piece);
      }
    }
  }

  let fxKit = null;

  function fxPiece(pieces, prefix, name, det, x, y, z, sx, sy, sz, noCol) {
    const at = add(add(det.at, mul(det.ax, x)), mul(det.ay, y));
    const piece = [prefix + "fx_" + name, round(at[0]), round(at[1]), round(z), 0, round(yaw(det.ax), 2), round(Math.min(1, sx), 4), round(Math.min(1, sz), 4), 0, round(Math.min(1, sy), 4)];

    if (noCol) noCollide(piece);
    pieces.push(piece);
  }

  function fxSinkFor(maxW, maxD) {
    if (!fxKit || !Array.isArray(fxKit.sinks)) return null;

    return fxKit.sinks.find(function (sk) { return sk.w <= maxW + 1e-6 && sk.d <= maxD + 1e-6; }) || null;
  }

  function fxSink(pieces, prefix, det, hole, top) {
    if (!fxKit || !Array.isArray(fxKit.sinks)) return false;

    const hw = hole[2] - hole[0];
    const hd = hole[3] - hole[1];
    const sk = fxKit.sinks.find(function (x) { return Math.abs(x.w - hw) < 0.002 && Math.abs(x.d - hd) < 0.002; });

    if (!sk) return false;

    fxPiece(pieces, prefix, sk.name, det, (hole[0] + hole[2]) / 2, (hole[1] + hole[3]) / 2, top, 1, 1, 1, true);

    return true;
  }

  function fxTap(pieces, prefix, det, x, y, top) {
    if (!fxKit || !fxKit.tap) return false;

    fxPiece(pieces, prefix, "tap", det, x, y, top, 1, 1, 1, true);

    return true;
  }

  function fxHob(pieces, prefix, det, hole, top) {
    if (!fxKit || !fxKit.hob4) return false;

    const hw = hole[2] - hole[0];
    const hd = hole[3] - hole[1];
    const key = Math.abs(hw - fxKit.hob4.w) < 0.002 ? "hob4" : Math.abs(hw - fxKit.hob2.w) < 0.002 ? "hob2" : null;

    if (!key || Math.abs(hd - fxKit[key].d) > 0.002) return false;

    fxPiece(pieces, prefix, key, det, (hole[0] + hole[2]) / 2, (hole[1] + hole[3]) / 2, top, 1, 1, 1, false);

    return true;
  }

  function fxVessel(pieces, prefix, det, rect, top) {
    if (!fxKit || !fxKit.vessel) return false;

    const s = Math.min(1, (rect[2] - rect[0]) / (fxKit.vessel.rx * 2), (rect[3] - rect[1]) / (fxKit.vessel.ry * 2));

    fxPiece(pieces, prefix, "vessel", det, (rect[0] + rect[2]) / 2, (rect[1] + rect[3]) / 2, top, s, s, 1, true);

    return true;
  }

  function basin(pieces, prefix, note, det, hole, top, depth, mat, t) {
    detailBox(pieces, prefix, note, det, hole[0], hole[1], hole[2], hole[3], top - depth, top - depth + t, mat);
    detailBox(pieces, prefix, note, det, hole[0], hole[1], hole[2], hole[1] + t, top - depth + t, top, mat);
    detailBox(pieces, prefix, note, det, hole[0], hole[3] - t, hole[2], hole[3], top - depth + t, top, mat);
    detailBox(pieces, prefix, note, det, hole[0], hole[1] + t, hole[0] + t, hole[3] - t, top - depth + t, top, mat);
    detailBox(pieces, prefix, note, det, hole[2] - t, hole[1] + t, hole[2], hole[3] - t, top - depth + t, top, mat);
  }

  function tap(pieces, prefix, note, det, x, z) {
    const back = det.d / 2 - 0.08;

    detailBox(pieces, prefix, note, det, x - 0.015, back - 0.015, x + 0.015, back + 0.015, z, z + 0.285, "steel");
    detailBox(pieces, prefix, note, det, x - 0.012, back - 0.2, x + 0.012, back + 0.012, z + 0.27, z + 0.3, "steel");
  }

  function emitRailing(pieces, prefix, note, a, b, z, kind, side) {
    const dir = norm(sub(b, a));
    const length = len(sub(b, a));

    if (length < 0.05 || kind === "none") return;

    const inset = add(a, mul(left(dir), 0.04 * (side || 1)));

    if (kind === "metal") {
      const count = Math.max(1, Math.ceil(length / 1.2));
      const t0 = Math.min(0.03, length / 2);
      const t1 = Math.max(length - 0.03, length / 2);

      for (let i = 0; i <= count; i++) {
        const at = add(inset, mul(dir, t0 + (t1 - t0) * i / count));

        pieces.push([prefix + "post_steel", round(at[0]), round(at[1]), round(z), 0, 0, 1, 0.92]);
      }

      barPiece(pieces, prefix, "steel", add(inset, mul(dir, t0)), z + 0.9, add(inset, mul(dir, t1)), z + 0.9);
      barPiece(pieces, prefix, "steel", add(inset, mul(dir, t0)), z + 0.45, add(inset, mul(dir, t1)), z + 0.45);
      return;
    }

    const count = Math.max(1, Math.ceil(length / 1.5));
    const stops = [];

    for (let i = 0; i <= count; i++) stops.push(Math.min(length - 0.03, Math.max(0.03, length * i / count)));

    stops.forEach(function (t, i) {
      const at = add(inset, mul(dir, t));

      pieces.push([prefix + "post_steel", round(at[0]), round(at[1]), round(z), 0, 0, 1, 0.985]);

      if (i > 0) {
        const from = stops[i - 1] + 0.035;
        const to = t - 0.035;

        if (to - from > 0.05) emitGlass(pieces, prefix, "glass", add(inset, mul(dir, from)), dir, z + 0.06, to - from, 0.88);
      }
    });

    barPiece(pieces, prefix, "steel", add(inset, mul(dir, stops[0])), z + 1.0, add(inset, mul(dir, stops[stops.length - 1])), z + 1.0);
  }

  function barPiece(pieces, prefix, mat, a, az, b, bz) {
    const d = sub(b, a);
    const run = len(d);
    const total = Math.hypot(run, bz - az);

    if (total < 0.02) return;

    if (!barKit || !barKit.length) {
      pieces.push([prefix + "bar_" + mat, round(a[0]), round(a[1]), round(az), 0, round(yaw(run > 1e-6 ? d : [1, 0]), 2), round(total, 4), 1, round(-Math.atan2(bz - az, run) * 180 / Math.PI, 2)]);
      return;
    }

    const lengths = barKit;
    const host = lengths.find(function (l) { return l >= total - 1e-6; }) || lengths[lengths.length - 1];
    const n = Math.max(1, Math.ceil(total / host - 1e-6));
    const step = total / n;
    const model = function (l) { return l === 1 ? prefix + "bar_" + mat : prefix + "bar_" + mat + "_l" + l; };
    const pick = lengths.find(function (l) { return l >= step - 1e-6; }) || host;
    const pitchRoll = round(-Math.atan2(bz - az, run) * 180 / Math.PI, 2);
    const yw = round(yaw(run > 1e-6 ? d : [1, 0]), 2);

    for (let k = 0; k < n; k++) {
      const t = k / n;
      const at = add(a, mul(d, t));

      pieces.push([model(pick), round(at[0]), round(at[1]), round(az + (bz - az) * t), 0, yw, round(step / pick, 4), 1, pitchRoll]);
    }
  }

  function detailExtra(pieces, prefix, note, det, H, lamps) {
    const z = det.z + (det.lift || 0);
    const full = det.h === 0 ? H - (det.lift || 0) : det.h;
    const p = det.points;
    const w = det.w;
    const d = det.d;

    if (det.kind === "floorpatch") {
      const poly = p;
      const top = det.z + 0.014 + (Number(det.patchLift) || 0);
      const longest = poly.reduce(function (best, q, i) { const nx = poly[(i + 1) % poly.length]; const l = len(sub(nx, q)); return l > best.length ? { a: q, b: nx, length: l } : best; }, { length: 0 });
      const edges = det.shape === "rect" ? poly.map(function (q, i) { const nx = poly[(i + 1) % poly.length]; return { a: q, b: nx, length: len(sub(nx, q)) }; }) : [{ a: add(det.at, mul(det.ax, -w / 2)), b: add(det.at, mul(det.ax, w / 2)), length: w }];

      tileRoom(pieces, prefix, { points: poly, edges: det.shape === "rect" ? edges : edges.concat([longest]).slice(0, 1), z: top, height: 0 }, (det.cuts || []).map(function (h) { return { points: h.points }; }), note(det.mat), false, false);

      const rim = note(det.top || "darkwood");

      for (let i = 0; i < poly.length; i++) {
        const a = poly[i];
        const b = poly[(i + 1) % poly.length];
        const dir = norm(sub(b, a));
        const l = len(sub(b, a));
        const ext = det.shape === "rect" ? 0.03 : 0.012;

        if (l < 0.01) continue;

        boxPiece(pieces, prefix, rim, add(add(a, mul(dir, -ext)), mul(left(dir), -0.04)), dir, l + 2 * ext, 0.08, det.z, 0.024);
      }

      return;
    }

    if (det.kind === "glasswall") {
      const start = add(det.at, mul(det.ax, -w / 2));
      const glassKey = det.glass || "glass";

      emitGlass(pieces, prefix, glassKey, start, det.ax, z + 0.05, w, full - 0.1);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -0.03, w / 2, 0.03), z, z + 0.05, det.mat, det.mat, null);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -0.03, w / 2, 0.03), z + full - 0.05, z + full, det.mat, null, det.mat);
      [-w / 2, w / 2 - 0.05].forEach(function (x) { emitBox(pieces, prefix, note, rectOf(det, x, -0.03, x + 0.05, 0.03), z + 0.05, z + full - 0.05, det.mat, null, null); });
      for (let x = -w / 2 + 1.2; x < w / 2 - 0.3; x += 1.2) emitBox(pieces, prefix, note, rectOf(det, x - 0.02, -0.03, x + 0.02, 0.03), z + 0.05, z + full - 0.05, det.mat, null, null);
    } else if (det.kind === "wardrobe") {
      emitBox(pieces, prefix, note, p, z, z + full, det.mat, null, null, [2]);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2 - 0.01, -d / 2 - 0.01, w / 2 + 0.01, -d / 2 + 0.05), z, z + 0.08, "blackm", null, null, [2]);
      emitFrontLines(pieces, prefix, note, det, z + 0.08, z + full, det.fronts || 0.6, "mid");
    } else if (det.kind === "kitchen" && !det.built) {
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2 + 0.06, w / 2, d / 2), z, z + 0.1, "blackm", null, null, [2]);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2, w / 2, d / 2), z + 0.1, z + full - 0.04, det.mat, null, null, [2]);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2 - 0.01, -d / 2 - 0.03, w / 2 + 0.01, d / 2), z + full - 0.04, z + full, det.top, det.top, null, [2]);
      emitFrontLines(pieces, prefix, note, det, z + 0.1, z + full - 0.04, det.fronts || 0.6, "top");
    } else if (det.kind === "sinkrun" || det.kind === "hobrun") {
      const topZ = z + full;

      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2 + 0.06, w / 2, d / 2), z, z + 0.1, "blackm", null, null, [2]);

      if (det.kind === "sinkrun") {
        const sk = fxSinkFor(w - 0.16, 0.42);
        const bw = sk ? sk.w : Math.min(w - 0.2, 0.7);
        const hole = sk ? [-bw / 2, -d / 2 + 0.08, bw / 2, -d / 2 + 0.08 + sk.d] : [-bw / 2, -0.21, bw / 2, 0.17];

        emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2, w / 2, d / 2), z + 0.1, topZ - 0.24, det.mat, det.mat, null, [2]);
        emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2, w / 2, hole[1]), topZ - 0.24, topZ - 0.04, det.mat, det.mat, null, [2]);
        emitBox(pieces, prefix, note, rectOf(det, -w / 2, hole[3], w / 2, d / 2), topZ - 0.24, topZ - 0.04, det.mat, det.mat, null, [2]);
        emitBox(pieces, prefix, note, rectOf(det, -w / 2, hole[1], hole[0], hole[3]), topZ - 0.24, topZ - 0.04, det.mat, det.mat, null);
        emitBox(pieces, prefix, note, rectOf(det, hole[2], hole[1], w / 2, hole[3]), topZ - 0.24, topZ - 0.04, det.mat, det.mat, null);
        counterHole(pieces, prefix, note, det, topZ, hole, 0.03, 0, 0.01);
        if (!fxSink(pieces, prefix, det, hole, topZ)) basin(pieces, prefix, note, det, hole, topZ - 0.001, 0.2, "steel", 0.012);
        if (!fxTap(pieces, prefix, det, 0, Math.min(d / 2 - 0.06, hole[3] + 0.05), topZ)) tap(pieces, prefix, note, det, 0, topZ);
        emitFrontLines(pieces, prefix, note, det, z + 0.1, topZ - 0.04, det.fronts || 0.6, "top");
      } else {
        const hobKey = fxKit && fxKit.hob4 ? (w - 0.1 >= fxKit.hob4.w ? "hob4" : w - 0.08 >= fxKit.hob2.w ? "hob2" : null) : null;
        const hw = hobKey ? fxKit[hobKey].w : Math.min(w - 0.1, 0.6);
        const hole = hobKey ? [-hw / 2, -d / 2 + 0.05, hw / 2, -d / 2 + 0.05 + fxKit[hobKey].d] : [-hw / 2, -0.26, hw / 2, 0.24];

        emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2, w / 2, d / 2), z + 0.1, topZ - 0.04, det.mat, null, null, [2]);
        counterHole(pieces, prefix, note, det, topZ, hole, 0.03, 0, 0.01);
        if (!fxHob(pieces, prefix, det, hole, topZ + 0.004)) detailBox(pieces, prefix, note, det, hole[0], hole[1], hole[2], hole[3], topZ - 0.04, topZ + 0.005, "mblack");
        emitTrim(pieces, prefix, note("mblack"), add(add(det.at, mul(det.ax, Math.min(w, 0.6) / 2 - 0.0)), mul(det.ay, -(d / 2 + 0.003))).concat([z + 0.16]), 0, yaw(mul(det.ax, -1)), Math.min(w - 0.04, 0.6), 0.58);
        detailBox(pieces, prefix, note, det, -Math.min(w, 0.6) / 2 + 0.05, -d / 2 - 0.035, Math.min(w, 0.6) / 2 - 0.05, -d / 2 - 0.005, z + 0.66, z + 0.68, "steel");
      }
    } else if (det.kind === "tallcab") {
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2 + 0.06, w / 2, d / 2), z, z + 0.1, "blackm", null, null, [2]);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2, w / 2, d / 2), z + 0.1, z + full, det.mat, det.mat, null, [2]);
      emitTrim(pieces, prefix, note("blackm"), add(add(det.at, mul(det.ax, w / 2)), mul(det.ay, -(d / 2 + 0.003))).concat([z + 0.92]), 0, yaw(mul(det.ax, -1)), w, 0.008);
      emitFrontLines(pieces, prefix, note, det, z + 0.1, z + 0.92, det.fronts || 0.6, "top");
      emitFrontLines(pieces, prefix, note, det, z + 0.93, z + full, det.fronts || 0.6, "low");
    } else if (det.kind === "fridge") {
      const split = Math.min(full - 0.4, 1.25);

      emitBox(pieces, prefix, note, p, z, z + full, det.mat, det.mat, null, [2]);
      emitTrim(pieces, prefix, note("blackm"), add(add(det.at, mul(det.ax, w / 2)), mul(det.ay, -(d / 2 + 0.003))).concat([z + split]), 0, yaw(mul(det.ax, -1)), w, 0.01);
      emitTrim(pieces, prefix, note("blackm"), add(add(det.at, mul(det.ax, 0.004)), mul(det.ay, -(d / 2 + 0.003))).concat([z + split + 0.01]), 0, yaw(mul(det.ax, -1)), 0.008, full - split - 0.02);
      [-0.06, 0.04].forEach(function (x) {
        detailBox(pieces, prefix, note, det, x, -d / 2 - 0.045, x + 0.02, -d / 2 - 0.005, z + split - 0.75, z + split - 0.1, "steel");
        detailBox(pieces, prefix, note, det, x, -d / 2 - 0.045, x + 0.02, -d / 2 - 0.005, z + split + 0.1, z + split + 0.6, "steel");
      });
    } else if (det.kind === "hood") {
      const canopy = 0.12;

      detailBox(pieces, prefix, note, det, -w / 2, -d / 2, w / 2, d / 2, z, z + canopy, det.mat);
      detailBox(pieces, prefix, note, det, -0.16, d / 2 - 0.26, 0.16, d / 2, z + canopy, z + full, det.mat);
    } else if (det.kind === "island" || det.kind === "bar" || det.kind === "counter" || det.kind === "kitchen") {
      const seat = det.kind === "island" ? Math.min(0.3, d * 0.3) : det.kind === "bar" ? 0.12 : 0;
      const topZ = z + full;
      const body = [-d / 2, d / 2 - seat];

      const built = det.kind === "island" || det.kind === "kitchen" ? String(det.built || "") : "";
      const holes = [];

      const share = built === "both" ? 2 : 1;

      if (/sink|both/.test(built) && w >= 0.7) {
        const sk = fxSinkFor(w / share - 0.16, body[1] - body[0] - 0.2);
        const bw = sk ? sk.w : Math.min(0.62, w / share - 0.2);
        const bd = sk ? sk.d : Math.min(0.4, body[1] - body[0] - 0.22);
        const cx = built === "both" ? -w / 4 : 0;

        if (bw > 0.25 && bd > 0.25) holes.push({ kind: "sink", r: [cx - bw / 2, body[0] + 0.09, cx + bw / 2, body[0] + 0.09 + bd] });
      }

      if (/hob|both/.test(built) && w >= 0.5) {
        const room = w / share - 0.12;
        const key = fxKit && fxKit.hob4 ? (room >= fxKit.hob4.w ? "hob4" : room >= fxKit.hob2.w ? "hob2" : null) : null;
        const hw = key ? fxKit[key].w : Math.min(0.6, w / share - 0.14);
        const hd = key ? Math.min(fxKit[key].d, body[1] - body[0] - 0.1) : Math.min(0.5, body[1] - body[0] - 0.12);
        const cx = built === "both" ? w / 4 : 0;

        if (hw > 0.25 && hd > 0.3) holes.push({ kind: "hob", r: [cx - hw / 2, body[0] + 0.06, cx + hw / 2, body[0] + 0.06 + hd] });
      }

      detailBox(pieces, prefix, note, det, -w / 2 + 0.06, body[0] + 0.06, w / 2 - 0.06, body[1] - 0.06, z, z + 0.1, "blackm");

      const sink = holes.find(function (h) { return h.kind === "sink"; });

      if (sink) {
        emitBox(pieces, prefix, note, rectOf(det, -w / 2, body[0], w / 2, body[1]), z + 0.1, topZ - 0.24, det.mat, det.mat, null);
        rectMinus(-w / 2, body[0], w / 2, body[1], [sink.r]).forEach(function (r) { emitBox(pieces, prefix, note, rectOf(det, r[0], r[1], r[2], r[3]), topZ - 0.24, topZ - 0.04, det.mat, null, null); });
      } else {
        emitBox(pieces, prefix, note, rectOf(det, -w / 2, body[0], w / 2, body[1]), z + 0.1, topZ - 0.04, det.mat, null, null);
      }

      if (holes.length) {
        rectMinus(-w / 2 - 0.03, -d / 2 - 0.03, w / 2 + 0.03, d / 2 + 0.02, holes.map(function (h) { return h.r; })).forEach(function (r) {
          emitBox(pieces, prefix, note, rectOf(det, r[0], r[1], r[2], r[3]), topZ - 0.04, topZ, det.top, det.top, null);
        });
        holes.forEach(function (h) {
          if (h.kind === "sink") {
            if (!fxSink(pieces, prefix, det, h.r, topZ)) basin(pieces, prefix, note, det, h.r, topZ - 0.001, 0.2, "steel", 0.012);

            if (!fxTap(pieces, prefix, det, (h.r[0] + h.r[2]) / 2, h.r[3] + 0.05, topZ)) {
              detailBox(pieces, prefix, note, det, (h.r[0] + h.r[2]) / 2 - 0.015, h.r[3] + 0.03, (h.r[0] + h.r[2]) / 2 + 0.015, h.r[3] + 0.06, topZ, topZ + 0.285, "steel");
              detailBox(pieces, prefix, note, det, (h.r[0] + h.r[2]) / 2 - 0.012, h.r[3] - 0.15, (h.r[0] + h.r[2]) / 2 + 0.012, h.r[3] + 0.06, topZ + 0.27, topZ + 0.3, "steel");
            }
          } else if (!fxHob(pieces, prefix, det, h.r, topZ + 0.004)) {
            detailBox(pieces, prefix, note, det, h.r[0], h.r[1], h.r[2], h.r[3], topZ - 0.04, topZ + 0.004, "blackm");
            hobRings(pieces, prefix, det, h.r, topZ + 0.0075);
          }
        });
      } else {
        counterTop(pieces, prefix, note, det, topZ, 0.03, 0.02, 0.03);
      }

      if (det.kind !== "counter") emitFrontLines(pieces, prefix, note, Object.assign({}, det, { d: body[1] - body[0], at: add(det.at, mul(det.ay, (body[0] + body[1]) / 2)) }), z + 0.1, topZ - 0.04, det.fronts || 0.6, det.kind === "island" || det.kind === "kitchen" ? "top" : false);
    } else if (det.kind === "vanity" || det.kind === "media") {
      emitBox(pieces, prefix, note, p, z, z + full - (det.kind === "vanity" ? 0.03 : 0), det.mat, det.kind === "media" ? det.mat : null, det.mat, [2]);

      if (det.kind === "vanity") {
        counterTop(pieces, prefix, note, det, z + full, 0.01, 0, 0.01);
        const bw = Math.min(0.48, w - 0.1);

        if (!fxVessel(pieces, prefix, det, [-bw / 2, -d / 2 + 0.04, bw / 2, d / 2 - 0.1], z + full)) basin(pieces, prefix, note, det, [-bw / 2, -d / 2 + 0.04, bw / 2, d / 2 - 0.1], z + full + 0.13, 0.13, "white", 0.015);
        if (!fxTap(pieces, prefix, Object.assign({}, det, { d: d + 0.02 }), 0, d / 2 - 0.06, z + full)) tap(pieces, prefix, note, Object.assign({}, det, { d: d + 0.02 }), 0, z + full);
      }

      emitFrontLines(pieces, prefix, note, det, z, z + full - 0.03, det.fronts || 0.6, det.handles === undefined && det.kind === "media" ? false : "mid");
    } else if (det.kind === "wallcab") {
      emitBox(pieces, prefix, note, p, z, z + full, det.mat, det.mat, det.mat, [2]);
      emitFrontLines(pieces, prefix, note, det, z, z + full, det.fronts || 0.6, "low");
    } else if (det.kind === "shelves") {
      const t = 0.025;

      emitBox(pieces, prefix, note, rectOf(det, -w / 2, d / 2 - t, w / 2, d / 2), z, z + full, det.mat, null, null);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2, -w / 2 + t, d / 2 - t), z, z + full, det.mat, det.mat, null);
      emitBox(pieces, prefix, note, rectOf(det, w / 2 - t, -d / 2, w / 2, d / 2 - t), z, z + full, det.mat, det.mat, null);
      const rows = Math.max(2, Math.round(full / 0.38));

      for (let i = 0; i <= rows; i++) {
        const sz = z + (full - t) * i / rows;

        emitBox(pieces, prefix, note, rectOf(det, -w / 2 + t, -d / 2, w / 2 - t, d / 2 - t), sz, sz + t, det.mat, det.mat, i > 0 ? det.mat : null);
      }
    } else if (det.kind === "fireplace") {
      const fw = Math.min(w - 0.4, 0.9);
      const fh = Math.min(full - 0.6, 0.75);

      emitBox(pieces, prefix, note, p, z, z + full, det.mat, null, null, [2]);
      emitTrim(pieces, prefix, note("mblack"), add(add(det.at, mul(det.ax, fw / 2)), mul(det.ay, -(d / 2 + 0.004))).concat([z + 0.15]), 0, yaw(mul(det.ax, -1)), fw, fh);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2 - 0.1, -d / 2 - 0.4, w / 2 + 0.1, -d / 2), z, z + 0.08, det.top, det.top, null);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2 - 0.08, -d / 2 - 0.18, w / 2 + 0.08, -d / 2), z + 0.15 + fh + 0.25, z + 0.15 + fh + 0.32, det.top, det.top, det.top);

      if (lamps) {
        const glow = add(det.at, mul(det.ay, -(d / 2 + 0.2)));

        lamps.push({ id: det.id + "_fire", x: round(glow[0]), y: round(glow[1]), z: round(z + 0.45), colour: "#ff8a3d", range: 4.5, intensity: 5, shadow: false });
      }
    } else if (det.kind === "bench") {
      emitBox(pieces, prefix, note, p, z, z + full - 0.08, det.mat, null, null, [2]);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2 - 0.01, w / 2, d / 2), z + full - 0.08, z + full, det.top, det.top, null, [2]);
    } else if (det.kind === "shower") {
      const tray = 0.05;
      const glassH = full - tray;
      const frame = ["steel", "blackm", "brass", "whitem"].indexOf(det.mat) >= 0 ? det.mat : "steel";
      const pf = 0.024;
      const walled = Array.isArray(det.walled) && det.walled.some(Boolean) ? det.walled : [true, false, false, true];
      const W = w / 2;
      const D = d / 2;
      const local = function (x, y) { return add(add(det.at, mul(det.ax, x)), mul(det.ay, y)); };
      const posts = {};
      const post = function (x, y) {
        const key = Math.round(x * 100) + ":" + Math.round(y * 100);

        if (posts[key]) return;
        posts[key] = true;
        detailBox(pieces, prefix, note, det, x - pf / 2, y - pf / 2, x + pf / 2, y + pf / 2, z + tray, z + full, frame);
      };
      const pane = function (x0, y0, x1, y1) {
        const A = local(x0, y0);
        const B = local(x1, y1);
        const L = len(sub(B, A));

        if (L < 0.1) return;

        emitGlass(pieces, prefix, det.glass || "glass", A, norm(sub(B, A)), z + tray, L, glassH - pf);
        detailBox(pieces, prefix, note, det, Math.min(x0, x1) - (x0 === x1 ? pf / 2 : 0), Math.min(y0, y1) - (y0 === y1 ? pf / 2 : 0), Math.max(x0, x1) + (x0 === x1 ? pf / 2 : 0), Math.max(y0, y1) + (y0 === y1 ? pf / 2 : 0), z + full - pf, z + full, frame);
        detailBox(pieces, prefix, note, det, Math.min(x0, x1) - (x0 === x1 ? 0.006 : 0), Math.min(y0, y1) - (y0 === y1 ? 0.006 : 0), Math.max(x0, x1) + (x0 === x1 ? 0.006 : 0), Math.max(y0, y1) + (y0 === y1 ? 0.006 : 0), z + tray, z + tray + 0.02, frame);
        post(x0, y0);
        post(x1, y1);
      };

      emitBox(pieces, prefix, note, p, z, z + tray, det.top, det.top, null);

      if (!walled[0]) pane(-W, D, -W, -D);
      if (!walled[1]) pane(W, -D, W, D);
      if (!walled[3]) pane(W, D, -W, D);
      if (!walled[2]) {
        const open = Math.min(0.62, w * 0.45);

        if (walled[0] && !walled[1]) pane(W, -D, -W + open, -D);
        else pane(-W, -D, W - open, -D);
      }

      const wallSide = walled[3] ? 3 : walled[0] ? 0 : walled[1] ? 1 : walled[2] ? 2 : -1;
      const sideDet = wallSide === 3 ? det : wallSide === 0 ? { at: det.at, ax: det.ay, ay: mul(det.ax, -1) } : wallSide === 1 ? { at: det.at, ax: mul(det.ay, -1), ay: det.ax } : { at: det.at, ax: mul(det.ax, -1), ay: mul(det.ay, -1) };
      const reach = wallSide === 0 || wallSide === 1 ? W : D;
      const span = wallSide === 0 || wallSide === 1 ? d : w;

      detailBox(pieces, prefix, note, sideDet, -span / 2 + 0.15, reach - 0.16, span / 2 - 0.15, reach - 0.1, z + tray, z + tray + 0.002, "steel");

      if (fxKit && fxKit.shower && reach * 2 >= 0.7 && glassH >= 1.85) {
        fxPiece(pieces, prefix, "shower", sideDet, 0, reach, z + tray, 1, 1, 1, true);
      } else {
        detailBox(pieces, prefix, note, sideDet, -0.012, reach - 0.05, 0.012, reach, z + 1.15, z + 1.95, "steel");
        detailBox(pieces, prefix, note, sideDet, -0.13, reach - 0.4, 0.13, reach - 0.14, z + 1.95, z + 1.97, "steel");
      }
    } else if (det.kind === "bathtub") {
      const topZ = z + full;
      const tub = fxKit && Array.isArray(fxKit.tubs) ? fxKit.tubs.find(function (tb) { return tb.w <= w + 0.02 && tb.d <= d + 0.02 && tb.depth <= full - 0.06; }) : null;

      if (tub) {
        emitBox(pieces, prefix, note, p, z, topZ - 0.03, det.mat, null, null, [2]);
        rectMinus(-w / 2, -d / 2, w / 2, d / 2, [[-tub.w / 2, -tub.d / 2, tub.w / 2, tub.d / 2]]).forEach(function (r) {
          detailBox(pieces, prefix, note, det, r[0], r[1], r[2], r[3], topZ - 0.03, topZ, det.top);
        });
        detailBox(pieces, prefix, note, det, -tub.w / 2 + 0.25, -tub.d / 2 + 0.2, tub.w / 2 - 0.25, tub.d / 2 - 0.2, topZ - tub.depth - 0.04, topZ - tub.depth - 0.01, det.mat);
        fxPiece(pieces, prefix, tub.name, det, 0, 0, topZ, 1, 1, 1, true);
        if (fxKit.tubtap) fxPiece(pieces, prefix, "tubtap", det, tub.w / 2 - 0.0375, 0, topZ, 1, 1, 1, true);
      } else {
        const r = 0.07;
        const o = 0.008;
        const depth = Math.max(0.12, Math.min(0.42, full - 0.08));

        emitBox(pieces, prefix, note, p, z, topZ - 0.02, det.mat, null, null, [2]);
        emitBox(pieces, prefix, note, rectOf(det, -w / 2 - o, -d / 2 - o, w / 2 + o, -d / 2 + r), topZ - 0.02, topZ, det.top, det.top, null);
        emitBox(pieces, prefix, note, rectOf(det, -w / 2 - o, d / 2 - r, w / 2 + o, d / 2), topZ - 0.02, topZ, det.top, det.top, null);
        emitBox(pieces, prefix, note, rectOf(det, -w / 2 - o, -d / 2 + r, -w / 2 + r, d / 2 - r), topZ - 0.02, topZ, det.top, det.top, null);
        emitBox(pieces, prefix, note, rectOf(det, w / 2 - r, -d / 2 + r, w / 2 + o, d / 2 - r), topZ - 0.02, topZ, det.top, det.top, null);
        basin(pieces, prefix, note, det, [-w / 2 + r, -d / 2 + r, w / 2 - r, d / 2 - r], topZ - 0.02, depth, det.top, 0.015);
        detailBox(pieces, prefix, note, det, w / 2 - r / 2 - 0.015, -0.015, w / 2 - r / 2 + 0.015, 0.015, topZ, topZ + 0.14, "steel");
        detailBox(pieces, prefix, note, det, w / 2 - r / 2 - 0.15, -0.012, w / 2 - r / 2 + 0.012, 0.012, topZ + 0.12, topZ + 0.145, "steel");
      }
    } else if (det.kind === "panelling") {
      emitBox(pieces, prefix, note, p, z, z + full, det.mat, null, null, [2]);
      emitBox(pieces, prefix, note, rectOf(det, -w / 2, -d / 2 - 0.025, w / 2, d / 2), z + full, z + full + 0.05, det.top, det.top, det.top, [2]);
      emitFrontLines(pieces, prefix, note, det, z, z + full, 0.5, false);
    } else if (det.kind === "mirror") {
      emitBox(pieces, prefix, note, p, z, z + full, det.mat, det.mat, det.mat, [2]);
      emitGlass(pieces, prefix, "mirror", add(add(det.at, mul(det.ax, w / 2 - 0.04)), mul(det.ay, -(d / 2 + 0.004))), mul(det.ax, -1), z + 0.04, w - 0.08, full - 0.08);
    } else if (det.kind === "balcony") {
      const slab = det.h || 0.2;

      emitBox(pieces, prefix, note, p, det.z - slab, det.z, det.mat, det.top, det.mat, [2]);
      emitRailing(pieces, prefix, note, p[0], p[1], det.z, det.rail);
      emitRailing(pieces, prefix, note, p[1], p[2], det.z, det.rail);
      emitRailing(pieces, prefix, note, p[3], p[0], det.z, det.rail);
    } else if (det.kind === "pergola") {
      const post = 0.14;
      const top = z + full;

      [[-w / 2, -d / 2], [w / 2 - post, -d / 2], [w / 2 - post, d / 2 - post], [-w / 2, d / 2 - post]].forEach(function (c) {
        emitBox(pieces, prefix, note, rectOf(det, c[0], c[1], c[0] + post, c[1] + post), z, top, det.mat, null, null);
      });
      [-d / 2, d / 2 - post].forEach(function (y) { emitBox(pieces, prefix, note, rectOf(det, -w / 2 - 0.15, y, w / 2 + 0.15, y + post), top, top + 0.2, det.mat, det.mat, det.mat); });
      for (let x = -w / 2 + 0.1; x <= w / 2 - 0.1; x += 0.4) emitBox(pieces, prefix, note, rectOf(det, x, -d / 2 - 0.2, x + 0.05, d / 2 + 0.2), top + 0.2, top + 0.32, det.mat, det.mat, det.mat);
    } else {
      emitBox(pieces, prefix, note, p, z, z + full, det.mat, det.top, det.lift ? det.mat : null);

      if (det.kind === "gardenwall" || det.kind === "fence") emitBox(pieces, prefix, note, rectOf(det, -w / 2 - 0.02, -d / 2 - 0.02, w / 2 + 0.02, d / 2 + 0.02), z + full, z + full + 0.05, det.top, det.top, det.top);
    }
  }

  const COLLIDER_SIZES = [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.45, 0.5, 0.6, 0.75, 0.9, 1, 1.25, 1.5, 2, 2.5, 3];

  let colliderSizes = null;

  function colliderTiles(length, tight) {
    const S = colliderSizes || COLLIDER_SIZES;

    if (length <= S[0] + 0.03) return [{ index: 0, at: (length - S[0]) / 2 }];

    for (let i = 0; i < S.length; i++) {
      if (S[i] >= length - 0.0005 && S[i] <= (tight ? length + 0.02 : Math.max(length + 0.03, length * 1.08))) return [{ index: i, at: (length - S[i]) / 2 }];
    }

    for (let n = 2; n < 400; n++) {
      for (let i = 0; i < S.length; i++) {
        if (S[i] * n >= length - 0.0005 && S[i] <= length) {
          const out = [];

          for (let k = 0; k < n; k++) out.push({ index: i, at: k * (length - S[i]) / (n - 1) });

          return out;
        }
      }
    }

    return [];
  }

  function axesOf(pitch, roll, yw) {
    const p = pitch * Math.PI / 180;
    const r = roll * Math.PI / 180;
    const y = yw * Math.PI / 180;
    const cp = Math.cos(p), sp = Math.sin(p), cr = Math.cos(r), sr = Math.sin(r), cy = Math.cos(y), sy = Math.sin(y);
    const m = [[cr, 0, sr], [sp * sr, cp, -sp * cr], [-cp * sr, sp, cp * cr]];
    const z = [[cy, -sy, 0], [sy, cy, 0], [0, 0, 1]];
    const o = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];

    for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) o[i][j] = z[i][0] * m[0][j] + z[i][1] * m[1][j] + z[i][2] * m[2][j];

    return [[o[0][0], o[1][0], o[2][0]], [o[0][1], o[1][1], o[2][1]], [o[0][2], o[1][2], o[2][2]]];
  }

  function markAbove(pieces, from, z) {
    for (let i = from; i < pieces.length; i++) {
      const p = pieces[i];

      while (p.length < 14) p.push(null);
      p[14] = round(z, 3);
    }
  }

  function markBelow(pieces, from, z) {
    for (let i = from; i < pieces.length; i++) {
      const p = pieces[i];

      if (typeof p[13] === "number" || typeof p[14] === "number" || !(Number(p[3]) < z - 0.02)) continue;

      while (p.length < 14) p.push(null);
      p[14] = round(z, 3);
    }
  }

  let colQueue = null;

  function mergeColliders(list) {
    const groups = new Map();
    const out = [];

    list.forEach(function (c) {
      const ax = axesOf(c.pitch || 0, c.roll || 0, c.yaw || 0);
      const o = c.origin;
      const d = o[0] * ax[1][0] + o[1] * ax[1][1] + o[2] * ax[1][2];
      const u = o[0] * ax[0][0] + o[1] * ax[0][1] + o[2] * ax[0][2];
      const v = o[0] * ax[2][0] + o[1] * ax[2][1] + o[2] * ax[2][2];
      const key = [ax[0], ax[1], ax[2]].map(function (a) { return a.map(function (x) { return Math.round(x * 1000); }).join(","); }).join("|") + "|" + Math.round((d + (c.y0 || 0)) * 500);
      const rect = { u0: u + c.x0, u1: u + c.x1, v0: v + c.z0, v1: v + c.z1, src: c, ax: ax, d: d, tight: !!c.tight, down: Number(c.down) || 0 };

      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(rect);
    });

    const near = function (a, b) { return Math.abs(a - b) <= 0.004; };

    groups.forEach(function (rects) {
      let changed = true;

      while (changed) {
        changed = false;

        for (let i = 0; i < rects.length && !changed; i++) {
          for (let j = i + 1; j < rects.length && !changed; j++) {
            const a = rects[i];
            const b = rects[j];

            if (near(a.v0, b.v0) && near(a.v1, b.v1) && a.u0 <= b.u1 + 0.004 && b.u0 <= a.u1 + 0.004) {
              a.u0 = Math.min(a.u0, b.u0);
              a.u1 = Math.max(a.u1, b.u1);
              a.tight = a.tight || b.tight;
              a.down = Math.max(a.down, b.down);
              rects.splice(j, 1);
              changed = true;
            } else if (near(a.u0, b.u0) && near(a.u1, b.u1) && a.v0 <= b.v1 + 0.004 && b.v0 <= a.v1 + 0.004 && (a.v0 <= b.v0 ? b.down : a.down) === 0) {
              a.down = a.v0 <= b.v0 ? a.down : b.down;
              a.v0 = Math.min(a.v0, b.v0);
              a.v1 = Math.max(a.v1, b.v1);
              a.tight = a.tight || b.tight;
              rects.splice(j, 1);
              changed = true;
            }
          }
        }
      }

      rects.forEach(function (r) {
        const n = r.ax[1];

        out.push(Object.assign({}, r.src, { origin: [n[0] * r.d, n[1] * r.d, n[2] * r.d], x0: r.u0, x1: r.u1, z0: r.v0, z1: r.v1, tight: r.tight, down: r.down }));
      });
    });

    return out;
  }

  function pairWallColliders(list) {
    const info = list.map(function (c) {
      const ax = axesOf(c.pitch || 0, c.roll || 0, c.yaw || 0);

      if (Math.abs(ax[1][2]) > 0.05 || Math.abs(ax[0][2]) > 0.05 || c.ramp) return null;

      const o = c.origin;
      const proj = function (k) { return o[0] * ax[k][0] + o[1] * ax[k][1] + o[2] * ax[k][2]; };
      const u = proj(0);
      const v = proj(2);

      return { ax: ax, face: proj(1) + (c.y0 || 0) + 0.1, u0: u + c.x0, u1: u + c.x1, v0: v + c.z0, v1: v + c.z1 };
    });
    const used = new Array(list.length).fill(false);
    const out = [];
    const close = function (a, b) { return Math.abs(a - b) < 0.02; };

    for (let i = 0; i < list.length; i++) {
      if (used[i]) continue;

      const a = info[i];
      let match = -1;

      if (a) {
        for (let j = i + 1; j < list.length; j++) {
          const b = info[j];

          if (used[j] || !b) continue;
          if (a.ax[1][0] * b.ax[1][0] + a.ax[1][1] * b.ax[1][1] > -0.999) continue;

          const thick = a.face + b.face;

          if (thick < 0.06 || thick > 0.225) continue;
          if (!close(a.u0, -b.u1) || !close(a.u1, -b.u0) || !close(a.v0, b.v0) || !close(a.v1, b.v1)) continue;

          match = j;
          break;
        }
      }

      if (match < 0) {
        out.push(list[i]);
        continue;
      }

      const b = info[match];
      const c = list[i];
      const centre = (a.face - b.face) / 2;
      const n = a.ax[1];
      const d = centre + 0.05;

      used[match] = true;
      out.push(Object.assign({}, c, {
        origin: [n[0] * d + a.ax[0][0] * a.u0 + a.ax[2][0] * a.v0, n[1] * d + a.ax[0][1] * a.u0 + a.ax[2][1] * a.v0, n[2] * d + a.ax[0][2] * a.u0 + a.ax[2][2] * a.v0],
        x0: 0, x1: a.u1 - a.u0, y0: -0.1, z0: 0, z1: a.v1 - a.v0,
        tight: !!(c.tight || list[match].tight), down: Math.max(Number(c.down) || 0, Number(list[match].down) || 0)
      }));
    }

    return out;
  }

  function emitCollider(pieces, prefix, c) {
    if (colQueue) {
      colQueue.push(c);
      return;
    }

    const ax = axesOf(c.pitch || 0, c.roll || 0, c.yaw || 0);
    const xs = colliderTiles(c.x1 - c.x0, c.tight);
    let zs = null;

    if (c.down) {
      const S = colliderSizes || COLLIDER_SIZES;
      const L = c.z1 - c.z0;
      const i = S.findIndex(function (v) { return v >= L - 0.0005 && v <= L + c.down; });

      if (i >= 0) zs = [{ index: i, at: L - S[i] }];
    }

    if (!zs) zs = colliderTiles(c.z1 - c.z0, c.tight);

    xs.forEach(function (tx) {
      zs.forEach(function (tz) {
        const lx = c.x0 + tx.at;
        const ly = c.y0;
        const lz = c.z0 + tz.at;
        const w = [0, 1, 2].map(function (k) { return c.origin[k] + ax[0][k] * lx + ax[1][k] * ly + ax[2][k] * lz; });

        pieces.push([prefix + "cx_" + tx.index + "_" + tz.index, round(w[0]), round(w[1]), round(w[2]), round(c.pitch || 0, 2), round(c.yaw || 0, 2), 1, 1, round(c.roll || 0, 2)]);
      });
    });
  }

  let trimSet = null;
  let faceCols = null;
  let barKit = null;
  let curveKit = null;
  let curveBend = 0;
  let curveMode = false;
  let wideKit = false;
  let backingSet = null;

  function trimBase(size) {
    return size <= 0.1001 ? [0.1, "c"] : size <= 0.2501 ? [0.25, "b"] : [1, "a"];
  }

  function trimPiece(pieces, prefix, mat, at, pitch, yw, sx, sz, whole) {
    if (whole && quadKit && trimSet && trimSet.has(mat) && sx > 0.002 && sz > 0.002 && sz <= 4) {
      const n = Math.max(1, Math.ceil(sx / 4 - 1e-6));
      const step = sx / n;
      const hostU = [0.25, 0.5, 0.75, 1, 2, 4].find(function (s) { return s >= step - 1e-6; });
      const hostV = [0.25, 0.5, 0.75, 1, 2, 4].find(function (s) { return s >= sz - 1e-6; });
      const iu = quadIndex(quadKit.u, hostU, 0);
      const iv = quadIndex(quadKit.v, hostV, 0);

      if (iu >= 0 && iv >= 0) {
        const ax = axesOf(pitch, 0, yw);

        for (let k = 0; k < n; k++) {
          const w = [0, 1, 2].map(function (c) { return at[c] + ax[0][c] * step * k; });
          const piece = [quadName(prefix, mat, iu, iv), round(w[0]), round(w[1]), round(w[2]), pitch, round(yw, 2), round(step / hostU, 4), round(sz / hostV, 4)];

          piece.noCol = true;
          pieces.push(piece);
        }
        return;
      }
    }

    if (quadKit && trimSet && trimSet.has(mat) && sx > 0.002 && sz > 0.002) {
      const us = decompose(0, sx, quadKit.u, mat);
      const vs = decompose(0, sz, quadKit.v, mat);

      if (us.length && vs.length && us.every(function (c) { return c.idx >= 0; }) && vs.every(function (c) { return c.idx >= 0; })) {
        const ax = axesOf(pitch, 0, yw);
        const flat = Math.abs(pitch) > 1;

        us.forEach(function (cu) {
          vs.forEach(function (cv) {
            const w = [0, 1, 2].map(function (k) { return at[k] + ax[0][k] * cu.at + ax[2][k] * cv.at; });
            const piece = [quadName(prefix, mat, cu.idx, cv.idx), round(w[0]), round(w[1]), round(w[2]), pitch, round(yw, 2)];
            const scx = cu.scale || 1;
            const scz = cv.scale || 1;

            if (scx !== 1 || scz !== 1) piece.push(round(scx, 4), round(scz, 4));

            if (cu.at + quadKit.u[cu.idx][0] > sx + 0.01 || cv.at + quadKit.v[cv.idx][0] > sz + 0.01) {
              noCollide(piece);
              if (!flat && faceCols && cu.size > 0.04 && cv.size > 0.04) faceCols.push({ origin: w, pitch: pitch, yaw: yw, roll: 0, x0: 0, x1: cu.size, y0: -0.1, z0: 0, z1: cv.size, low: true });
            }

            pieces.push(piece);
          });
        });
        return;
      }
    }

    if (!trimSet || !trimSet.has(mat)) {
      const piece = [prefix + mat + "_t", round(at[0]), round(at[1]), round(at[2]), pitch, round(yw, 2), round(sx, 4), round(sz, 4)];

      piece.trim = { sx: sx, sz: sz, mat: mat };
      pieces.push(piece);
      return;
    }

    const nx = !whole && sx > 1.0005 ? Math.ceil(sx - 0.0005) : 1;
    const nz = !whole && sz > 1.0005 ? Math.ceil(sz - 0.0005) : 1;
    const cx = sx / nx;
    const cz = sz / nz;
    const bx = trimBase(cx);
    const bz = trimBase(cz);
    const name = bx[1] === "a" && bz[1] === "a" ? prefix + mat + "_t" : prefix + mat + "_t" + bx[1] + bz[1];
    const ax = axesOf(pitch, 0, yw);

    for (let i = 0; i < nx; i++) {
      for (let j = 0; j < nz; j++) {
        const w = [0, 1, 2].map(function (k) { return at[k] + ax[0][k] * cx * i + ax[2][k] * cz * j; });
        const piece = [name, round(w[0]), round(w[1]), round(w[2]), pitch, round(yw, 2), round(cx / bx[0], 4), round(cz / bz[0], 4)];

        piece.trim = { sx: cx, sz: cz, mat: mat };
        pieces.push(piece);
      }
    }
  }

  function emitTrim(pieces, prefix, mat, at, pitch, yw, sx, sz, whole) {
    if (sx < 0.004 || sz < 0.004) return;

    trimPiece(pieces, prefix, mat, at, pitch, yw, sx, sz, whole);
  }

  function emitGlass(pieces, prefix, glass, A, d, z, w, h) {
    const yw = round(yaw(d), 2);

    sizeSplit(w).forEach(function (col) {
      sizeSplit(h).forEach(function (row) {
        const at = pieceWorld(A, d, col.at, z + row.at);

        if (col.kit && row.kit && CODES[col.size] && CODES[row.size]) pieces.push([prefix + glass + "_" + CODES[col.size] + CODES[row.size], round(at[0]), round(at[1]), round(at[2]), 0, yw]);
        else {
          const cw = col.kit && CODES[col.size] ? CODES[col.size] : "d";
          const ch = row.kit && CODES[row.size] ? CODES[row.size] : "d";

          pieces.push([prefix + glass + "_" + cw + ch, round(at[0]), round(at[1]), round(at[2]), 0, yw, round(cw === "d" && !col.kit ? col.size / 0.25 : 1, 4), round(ch === "d" && !row.kit ? row.size / 0.25 : 1, 4)]);
        }
      });
    });
  }

  function materialOf(doc, room, part, fallback) {
    const record = room.record || {};
    const value = record[part];

    return value || fallback;
  }

  function tileFrame(room, forceAligned) {
    let best = 0;
    let axis = [1, 0];

    room.edges.forEach(function (e) {
      if (e.length > best && !e.curved) {
        best = e.length;
        axis = norm(sub(e.b, e.a));
      }
    });

    if (Math.abs(axis[0]) > 0.999) axis = [axis[0] > 0 ? 1 : -1, 0];
    if (Math.abs(axis[1]) > 0.999) axis = [0, axis[1] > 0 ? 1 : -1];
    if (axis[0] < -0.5 || axis[1] < -0.5) axis = [-axis[0], -axis[1]];

    const ay = left(axis);
    let minx = Infinity, miny = Infinity, maxx = -Infinity, maxy = -Infinity;

    room.points.forEach(function (p) {
      const x = dot(p, axis);
      const y = dot(p, ay);

      minx = Math.min(minx, x); maxx = Math.max(maxx, x);
      miny = Math.min(miny, y); maxy = Math.max(maxy, y);
    });

    const aligned = forceAligned !== undefined ? forceAligned : tilesAligned(room.record);

    if (aligned) {
      minx = alignTile(minx);
      miny = alignTile(miny);
    }

    return { ax: axis, ay: ay, minx: minx, miny: miny, maxx: maxx, maxy: maxy, size: 0.25, aligned: aligned };
  }

  function alignTile(v) {
    return Math.floor(v + 1e-6);
  }

  function tilesAligned(record) {
    return !record || record.tileGrid === 1 || !record.tiles || !Object.keys(record.tiles).length;
  }

  function alignTiles(room) {
    const record = room.record;

    if (!record || !record.tiles || record.tileGrid === 1) return record ? record.tiles || {} : {};

    const before = tileFrame(room, false);
    const after = tileFrame(room, true);
    const out = {};

    Object.keys(record.tiles).forEach(function (key) {
      const ij = key.split(",").map(Number);
      const cx = before.minx + (ij[0] + 0.5) * before.size;
      const cy = before.miny + (ij[1] + 0.5) * before.size;
      const i = Math.floor((cx - after.minx) / after.size + 1e-6);
      const j = Math.floor((cy - after.miny) / after.size + 1e-6);

      out[i + "," + j] = record.tiles[key];
    });

    return out;
  }

  function tileCell(room, p) {
    const f = tileFrame(room);
    const i = Math.floor((dot(p, f.ax) - f.minx) / f.size + 1e-6);
    const j = Math.floor((dot(p, f.ay) - f.miny) / f.size + 1e-6);
    const corner = function (x, y) { return add(mul(f.ax, f.minx + x * f.size), mul(f.ay, f.miny + y * f.size)); };

    return { i: i, j: j, key: i + "," + j, inside: i >= 0 && j >= 0 && f.minx + i * f.size < f.maxx && f.miny + j * f.size < f.maxy, points: [corner(i, j), corner(i + 1, j), corner(i + 1, j + 1), corner(i, j + 1)] };
  }

  function tilePoints(room, i, j) {
    const f = tileFrame(room);
    const x0 = f.minx + i * f.size;
    const y0 = f.miny + j * f.size;
    const x1 = Math.min(f.maxx, x0 + f.size);
    const y1 = Math.min(f.maxy, y0 + f.size);
    const corner = function (x, y) { return add(mul(f.ax, x), mul(f.ay, y)); };

    return [corner(x0, y0), corner(x1, y0), corner(x1, y1), corner(x0, y1)];
  }

  const ROOF_TYPES = ["none", "gable", "shed"];
  const OUTDOOR_FLOORS = ["floorpatch", "balcony", "terrace", "deck", "lawn", "path", "platform"];

  function roofOf(doc, level) {
    const r = level && level.roof;

    if (!r || ROOF_TYPES.indexOf(r.type) < 1) return null;

    const walls = (doc.walls || []).filter(function (w) { return (w.level || "l1") === level.id; });

    if (walls.length < 3) return null;

    const thick = Number(doc.settings && doc.settings.thick) || 0.2;
    let t = 0;
    let minx = Infinity, miny = Infinity, maxx = -Infinity, maxy = -Infinity;

    walls.forEach(function (w) {
      wallPoints(w).forEach(function (p) {
        minx = Math.min(minx, p[0]); maxx = Math.max(maxx, p[0]);
        miny = Math.min(miny, p[1]); maxy = Math.max(maxy, p[1]);
      });
      t = Math.max(t, Math.max(0.08, Number(w.thick) || thick));
    });

    const sx = maxx - minx;
    const sy = maxy - miny;
    const ridgeX = r.ridge === "x" ? true : r.ridge === "y" ? false : sx >= sy;
    const d = ridgeX ? [1, 0] : [0, 1];
    const L = left(d);
    const pitch = Math.max(10, Math.min(50, Number(r.pitch) || 30));
    const half = t / 2;
    const along = ridgeX ? [minx + half, maxx - half] : [miny + half, maxy - half];
    const across = ridgeX ? [miny + half, maxy - half] : [-(maxx - half), -(minx + half)];

    return { type: r.type, flip: r.flip === true, d: d, L: L, pitch: pitch, tan: Math.tan(pitch * Math.PI / 180), cos: Math.cos(pitch * Math.PI / 180), a0: along[0], a1: along[1], b0: across[0], b1: across[1], t: t, z: (Number(level.z) || 0) + (Number(level.height) || 2.8), outside: r.outside || "slategrey", inside: r.inside || "", overhang: r.overhang === undefined ? 0.35 : Math.max(0, Math.min(1, Number(r.overhang) || 0)), thick: 0.22 };
  }

  function roofPoint(rf, a, b) {
    return add(mul(rf.d, a), mul(rf.L, b));
  }

  function emitSlope(pieces, prefix, mat, origin, d, U, V, angle, top) {
    if (U < 0.004 || V < 0.004) return;

    const th = angle * Math.PI / 180;
    const xdir = top ? mul(d, -1) : d;
    const L = left(d);
    const zdir = [L[0] * Math.cos(th), L[1] * Math.cos(th), Math.sin(th)];
    const start = top ? [origin[0] + d[0] * U, origin[1] + d[1] * U, origin[2]] : origin;
    const pitch = round(top ? 90 - angle : -90 + angle, 3);
    const yw = round(yaw(xdir), 2);
    const at = function (u, v) { return [start[0] + xdir[0] * u + zdir[0] * v, start[1] + xdir[1] * u + zdir[1] * v, start[2] + zdir[2] * v]; };

    if (!quadKit || !trimSet || !trimSet.has(mat)) {
      trimPiece(pieces, prefix, mat, at(0, 0), pitch, yw, U, V);
      return;
    }

    const us = decompose(0, U, quadKit.u, mat);
    const vs = decompose(0, V, quadKit.v, mat);

    us.forEach(function (cu) {
      vs.forEach(function (cv) {
        const p = at(cu.at, cv.at);

        if (cu.idx < 0 || cv.idx < 0) {
          trimPiece(pieces, prefix, mat, p, pitch, yw, cu.size, cv.size);
          return;
        }

        const piece = [quadName(prefix, mat, cu.idx, cv.idx), round(p[0]), round(p[1]), round(p[2]), pitch, yw];

        if ((cu.scale || 1) !== 1 || (cv.scale || 1) !== 1) piece.push(round(cu.scale || 1, 4), round(cv.scale || 1, 4));
        piece.noCol = true;
        pieces.push(piece);
      });
    });
  }

  function emitRoof(pieces, prefix, note, doc, level, rf, insideMat, gableIn) {
    const ov = rf.overhang;
    const t = rf.t;
    const out = note(rf.outside);
    const inside = note(insideMat);
    const W = rf.b1 - rf.b0;
    const length = rf.a1 - rf.a0;
    const ext = t + ov;
    const vThick = rf.thick / rf.cos;
    const sides = rf.type === "gable" ? [{ sign: 1 }, { sign: -1 }] : [{ sign: rf.flip ? -1 : 1 }];
    const run = rf.type === "gable" ? W / 2 : W;
    const frames = note("white");
    const colW = rf.pitch > 35 ? 0.25 : 0.5;
    const zAt = function (b) {
      if (rf.type === "gable") return rf.z + Math.min(b - rf.b0, rf.b1 - b) * rf.tan;
      return rf.z + (rf.flip ? rf.b1 - b : b - rf.b0) * rf.tan;
    };

    sides.forEach(function (side) {
      const dd = side.sign > 0 ? rf.d : mul(rf.d, -1);
      const a = side.sign > 0 ? rf.a0 - ext : rf.a1 + ext;
      const b = side.sign > 0 ? rf.b0 - ext : rf.b1 + ext;
      const base = roofPoint(rf, a, b);
      const z0 = rf.z - ext * rf.tan;
      const V = (run + ext) / rf.cos;
      const U = length + 2 * ext;
      const ridgeFree = rf.type === "shed" ? ext / rf.cos : 0;

      emitSlope(pieces, prefix, inside, [base[0], base[1], z0], dd, U, V + ridgeFree, rf.pitch, false);
      emitSlope(pieces, prefix, out, [base[0], base[1], z0 + vThick], dd, U, V + ridgeFree, rf.pitch, true);

      const Lside = left(dd);
      const fasciaAt = sub(base, mul(Lside, 0.03));
      const fascia = [prefix + "box_white", round(fasciaAt[0]), round(fasciaAt[1]), round(z0 - 0.01), 0, round(yaw(dd), 2), round(U, 4), round(vThick + 0.02, 4), 0, 0.03];

      fascia.noCol = true;
      pieces.push(fascia);

      [0, 1].forEach(function (end) {
        const slopeDir = Lside;
        const yawSlope = yaw(slopeDir);
        const along = end === 0 ? 0 : U;
        const cornerAt = add(base, mul(dd, along));
        const p0 = end === 0 ? cornerAt : add(cornerAt, mul(dd, 0.03));
        const barge = [prefix + "box_white", round(p0[0]), round(p0[1]), round(z0), 0, round(yawSlope, 2), round(V + ridgeFree, 4), round(rf.thick, 4), round(-rf.pitch, 3), 0.03];

        barge.noCol = true;
        pieces.push(barge);
      });
      note("white");
    });

    const outsideWall = note((doc.settings && doc.settings.outside) || "white");

    if (rf.type === "shed") {
      const sign = rf.flip ? -1 : 1;
      const high = sign > 0 ? rf.b1 : rf.b0;
      const top = zAt(high);
      const inFace = sign > 0 ? { o: roofPoint(rf, rf.a1, high), f: mul(rf.d, -1) } : { o: roofPoint(rf, rf.a0, high), f: rf.d };
      const outFace = sign > 0 ? { o: roofPoint(rf, rf.a0 - t, high + t), f: rf.d } : { o: roofPoint(rf, rf.a1 + t, high - t), f: mul(rf.d, -1) };
      const farB = sign > 0 ? rf.b1 + ext : rf.b0 - ext;
      const far = roofPoint(rf, sign > 0 ? rf.a0 - ext : rf.a1 + ext, farB);
      const fz = rf.z + (W + ext) * rf.tan;
      const fd = sign > 0 ? rf.d : mul(rf.d, -1);
      const fascia = [prefix + "box_white", round(far[0]), round(far[1]), round(fz - 0.01), 0, round(yaw(fd), 2), round(length + 2 * ext, 4), round(vThick + 0.02, 4), 0, 0.03];

      emitFace(pieces, gableIn, inFace.o, inFace.f, rf.z, 0, length, 0, top - rf.z + 0.01, prefix, 0);
      emitFace(pieces, outsideWall, outFace.o, outFace.f, rf.z, 0, length + 2 * t, 0, top - rf.z + t * rf.tan + 0.01, prefix, 0);
      fascia.noCol = true;
      pieces.push(fascia);
    }

    [0, 1].forEach(function (end) {
      const faces = end === 0
        ? [{ o: roofPoint(rf, rf.a0, rf.b1), f: mul(rf.L, -1), from: rf.b1, step: -1, mat: gableIn, lo: rf.b0, hi: rf.b1 }, { o: roofPoint(rf, rf.a0 - t, rf.b0 - t), f: rf.L, from: rf.b0 - t, step: 1, mat: outsideWall, lo: rf.b0 - t, hi: rf.b1 + t }]
        : [{ o: roofPoint(rf, rf.a1, rf.b0), f: rf.L, from: rf.b0, step: 1, mat: gableIn, lo: rf.b0, hi: rf.b1 }, { o: roofPoint(rf, rf.a1 + t, rf.b1 + t), f: mul(rf.L, -1), from: rf.b1 + t, step: -1, mat: outsideWall, lo: rf.b0 - t, hi: rf.b1 + t }];

      faces.forEach(function (face) {
        const total = face.hi - face.lo;
        const mid = (rf.b0 + rf.b1) / 2;
        const cuts = [];
        const midU = (mid - face.from) * face.step;

        for (let u = 0; u < total - 0.004; u += colW) cuts.push(u);
        if (rf.type === "gable" && midU > 0.004 && midU < total - 0.004 && !cuts.some(function (c) { return Math.abs(c - midU) < 0.004; })) cuts.push(midU);
        cuts.sort(function (x, y) { return x - y; });
        cuts.push(total);

        for (let i = 0; i + 1 < cuts.length; i++) {
          const u = cuts[i];
          const u1 = cuts[i + 1];

          if (u1 - u < 0.004) continue;

          const zA = zAt(face.from + face.step * u);
          const zB = zAt(face.from + face.step * u1);
          const low = Math.min(zA, zB);
          const rise = Math.abs(zA - zB);

          if (low - rf.z > 0.02) emitFace(pieces, face.mat, face.o, face.f, rf.z, u, u1, 0, low - rf.z + 0.002, prefix, 0);
          if (rise > 0.005) {
            const up = zB >= zA;
            const dir = up ? face.f : mul(face.f, -1);
            const start = add(face.o, mul(face.f, up ? u : u1));
            const plate = 0.012;

            prismPiece(pieces, prefix, face.mat, add(start, mul(left(dir), -plate / 2)), dir, u1 - u, plate, low, rise + 0.004);
          }
        }
      });
    });

    return rf.z + run * rf.tan + vThick;
  }

  function largestRects(codes, nx, ny) {
    const out = [];
    const heights = new Int32Array(nx);
    const stack = new Int32Array(nx + 1);

    for (let guard = 0; guard < 4000; guard++) {
      let best = null;
      const present = new Set();

      for (let n = 0; n < nx * ny; n++) if (codes[n] >= 10) present.add(codes[n]);
      if (!present.size) break;

      present.forEach(function (code) {
        heights.fill(0);

        for (let j = 0; j < ny; j++) {
          for (let i = 0; i < nx; i++) heights[i] = codes[j * nx + i] === code ? heights[i] + 1 : 0;

          let top = 0;

          for (let i = 0; i <= nx; i++) {
            const h = i < nx ? heights[i] : 0;

            while (top > 0 && heights[stack[top - 1]] >= h) {
              const hh = heights[stack[--top]];
              const from = top > 0 ? stack[top - 1] + 1 : 0;
              const area = hh * (i - from);

              if (hh > 0 && (!best || area > best.area)) best = { area: area, i0: from, i1: i, j0: j - hh + 1, j1: j + 1, code: code };
            }

            stack[top++] = i;
          }
        }
      });

      if (!best) break;

      for (let y = best.j0; y < best.j1; y++) for (let x = best.i0; x < best.i1; x++) codes[y * nx + x] = 2;

      out.push([best.i0, best.j0, best.i1, best.j1, best.code]);
    }

    return out;
  }

  function tileRoom(pieces, prefix, room, holes, baseMat, ceiling, noBacking, tiles) {
    let best = 0;
    let axis = [1, 0];

    room.edges.forEach(function (e) {
      if (e.length > best && !e.curved) {
        best = e.length;
        axis = norm(sub(e.b, e.a));
      }
    });

    if (Math.abs(axis[0]) > 0.999) axis = [axis[0] > 0 ? 1 : -1, 0];
    if (Math.abs(axis[1]) > 0.999) axis = [0, axis[1] > 0 ? 1 : -1];
    if (axis[0] < -0.5 || axis[1] < -0.5) axis = [-axis[0], -axis[1]];

    const gridAxis = room.gridAxis;
    const globalGrid = !!(gridAxis && quadKit && !room.graceEdges && !(tiles && Object.keys(tiles).length) && !isPlain(baseMat) && (Math.abs(dot(axis, gridAxis)) > 0.985 || Math.abs(dot(axis, left(gridAxis))) > 0.985));

    if (globalGrid) axis = gridAxis.slice();

    const ax = axis;
    const ay = left(axis);
    const local = function (p) { return [dot(p, ax), dot(p, ay)]; };
    const world = function (x, y) { return add(mul(ax, x), mul(ay, y)); };
    const poly = room.points.map(local);
    const holeList = holes.map(function (h) { return h.points.map(local); });
    let minx = Infinity, miny = Infinity, maxx = -Infinity, maxy = -Infinity;

    poly.forEach(function (p) {
      minx = Math.min(minx, p[0]); maxx = Math.max(maxx, p[0]);
      miny = Math.min(miny, p[1]); maxy = Math.max(maxy, p[1]);
    });

    const G = 0.25;
    const xs = [];
    const ys = [];
    const phased = !!(quadKit && room.under && !isPlain(baseMat));
    const depthProfile = function (edge, a0, a1, alongX, dirSign) {
      const out = [];
      const n = Math.max(2, Math.ceil((a1 - a0) / 0.1));

      for (let k = 0; k <= n; k++) {
        const t = a0 + (a1 - a0) * (0.02 + 0.96 * k / n);
        let depth = 0;

        for (let e = 0.002; e <= G + 0.03; e += 0.005) {
          const v = edge + dirSign * e;
          const q = alongX ? world(v, t) : world(t, v);

          if (!room.under(q)) break;
          depth = e;
        }

        out.push(depth);
      }

      return out;
    };
    const pickOrigin = function (mn, mx, a0, a1, alongX) {
      if (!phased) return mn;

      const low = depthProfile(mn, a0, a1, alongX, -1);
      const high = depthProfile(mx, a0, a1, alongX, 1);
      const share = function (profile, need) { let ok = 0; profile.forEach(function (dp) { if (dp >= need + 0.012) ok++; }); return ok / profile.length; };
      let best = mn;
      let score = -1;

      for (let k = 0; k < 50; k++) {
        const off = k * 0.005;
        const origin = mn - off;
        const last = origin + Math.floor((mx - origin) / G + 1e-6) * G;
        const rem = mx - last;
        const lowExt = off > 0.002 ? share(low, off) : 1;
        const highExt = rem > 0.002 ? share(high, G - rem) : 1;
        const value = lowExt + highExt - (off > 0.002 ? 0.001 : 0) - 0.002 * Math.max(off, rem > 0.002 ? G - rem : 0);

        if (value > score + 1e-9) { score = value; best = origin; }
      }

      return best;
    };
    const roomExt = room.under ? Math.max(0.03, (Number(room.ext) || 0.075) + 0.01) : 0;
    const tiled = !!(tiles && Object.keys(tiles).length);
    const tileAligned = tiled && room.record && room.record.tileGrid === 1;
    const originX = globalGrid ? Math.floor(minx - roomExt - 1e-6) : tiled ? (tileAligned ? alignTile(minx) : minx) : minx - roomExt;
    const originY = globalGrid ? Math.floor(miny - roomExt - 1e-6) : tiled ? (tileAligned ? alignTile(miny) : miny) : miny - roomExt;

    void pickOrigin;

    xs.push(minx);
    for (let x = originX + G; x < maxx - 0.004; x += G) if (x > minx + 0.004) xs.push(x);
    xs.push(maxx);
    ys.push(miny);
    for (let y = originY + G; y < maxy - 0.004; y += G) if (y > miny + 0.004) ys.push(y);
    ys.push(maxy);

    holeList.forEach(function (h) {
      if (h.length !== 4) return;

      const axisAligned = h.every(function (q, i) { const r = h[(i + 1) % 4]; return Math.abs(q[0] - r[0]) < 0.002 || Math.abs(q[1] - r[1]) < 0.002; });

      if (!axisAligned) return;

      h.forEach(function (q) {
        if (q[0] > minx + 0.01 && q[0] < maxx - 0.01 && !xs.some(function (v) { return Math.abs(v - q[0]) < 0.004; })) xs.push(q[0]);
        if (q[1] > miny + 0.01 && q[1] < maxy - 0.01 && !ys.some(function (v) { return Math.abs(v - q[1]) < 0.004; })) ys.push(q[1]);
      });
    });
    xs.sort(function (a, b) { return a - b; });
    ys.sort(function (a, b) { return a - b; });

    const nx = xs.length - 1;
    const ny = ys.length - 1;

    if (nx <= 0 || ny <= 0 || nx * ny > 200000) return 0;

    const grid = new Uint8Array(nx * ny);
    const masks = new Map();
    const holeBoxes = holeList.map(function (h) {
      let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;

      h.forEach(function (q) { x0 = Math.min(x0, q[0]); x1 = Math.max(x1, q[0]); y0 = Math.min(y0, q[1]); y1 = Math.max(y1, q[1]); });

      return [x0, y0, x1, y1];
    });
    const graceSegs = (room.graceEdges || []).map(function (e) { return [local(e[0]), local(e[1])]; });
    const graceDist = Number(room.grace) || 0;
    const nearCurve = function (q, limit) {
      const lim = limit === undefined ? graceDist : limit;

      for (const sg of graceSegs) {
        const abx = sg[1][0] - sg[0][0];
        const aby = sg[1][1] - sg[0][1];
        const t = Math.max(0, Math.min(1, ((q[0] - sg[0][0]) * abx + (q[1] - sg[0][1]) * aby) / ((abx * abx + aby * aby) || 1e-9)));
        const dx = q[0] - sg[0][0] - abx * t;
        const dy = q[1] - sg[0][1] - aby * t;

        if (dx * dx + dy * dy <= lim * lim) return true;
      }

      return false;
    };
    const straightSegs = [];

    for (let k = 0; k < poly.length; k++) {
      const pa = poly[k];
      const pb = poly[(k + 1) % poly.length];
      const mid = [(pa[0] + pb[0]) / 2, (pa[1] + pb[1]) / 2];

      if (!graceSegs.length || !nearCurve(mid, 0.02)) straightSegs.push([pa, pb]);
    }

    const distanceToStraight = function (q) {
      let best = Infinity;

      for (const sg of straightSegs) {
        const abx = sg[1][0] - sg[0][0];
        const aby = sg[1][1] - sg[0][1];
        const t = Math.max(0, Math.min(1, ((q[0] - sg[0][0]) * abx + (q[1] - sg[0][1]) * aby) / ((abx * abx + aby * aby) || 1e-9)));

        best = Math.min(best, Math.hypot(q[0] - sg[0][0] - abx * t, q[1] - sg[0][1] - aby * t));
      }

      return best;
    };
    const inRoom = function (q) { return insidePolygon(q, poly) || distanceToEdges(q, poly) <= 0.004 || graceSegs.length > 0 && nearCurve(q); };
    const coarse = graceSegs.length > 0 && graceDist > 0.1;
    const FINE = 5;
    const covered = function (q, near) {
      if (coarse) {
        if (!(insidePolygon(q, poly) || nearCurve(q, graceDist - 0.09))) return false;
      } else if (!inRoom(q)) {
        return false;
      }

      if (!near.some(function (h) { return insidePolygon(q, h); })) return true;
      if (near.some(function (h) { return insidePolygon(q, h) && distanceToEdges(q, h) > 0.028; })) return false;
      if (near.length < 2) return true;

      return !RING8.every(function (o) { const p = [q[0] + o[0] * 0.029, q[1] + o[1] * 0.029]; return near.some(function (h) { return insidePolygon(p, h); }); });
    };

    for (let j = 0; j < ny; j++) {
      for (let i = 0; i < nx; i++) {
        const cx0 = xs[i];
        const cy0 = ys[j];
        const cw = xs[i + 1] - cx0;
        const ch = ys[j + 1] - cy0;
        const near = holeList.filter(function (h, index) { const b = holeBoxes[index]; return cx0 < b[2] + 0.03 && cx0 + cw > b[0] - 0.03 && cy0 < b[3] + 0.03 && cy0 + ch > b[1] - 0.03; });
        const inset = 0.002;
        const corners = [[cx0 + inset, cy0 + inset], [cx0 + cw - inset, cy0 + inset], [cx0 + cw - inset, cy0 + ch - inset], [cx0 + inset, cy0 + ch - inset], [cx0 + cw / 2, cy0 + ch / 2]];

        if (!near.length && corners.every(function (q) { return insidePolygon(q, poly); }) && distanceToEdges([cx0 + cw / 2, cy0 + ch / 2], poly) > Math.max(cw, ch) * 0.75) {
          grid[j * nx + i] = 1;
          continue;
        }

        if (graceSegs.length && !near.length && corners.every(inRoom)) {
          grid[j * nx + i] = 1;
          continue;
        }

        const bits = [];
        let count = 0;
        const R = coarse && !near.length && nearCurve([cx0 + cw / 2, cy0 + ch / 2], graceDist + 0.2) && distanceToStraight([cx0 + cw / 2, cy0 + ch / 2]) > 0.3 ? 2 : FINE;
        const low = [];

        for (let v = 0; v < R; v++) for (let u = 0; u < R; u++) low.push(covered([cx0 + (u + 0.5) * cw / R, cy0 + (v + 0.5) * ch / R], near) ? 1 : 0);

        for (let v = 0; v < FINE; v++) {
          for (let u = 0; u < FINE; u++) {
            const on = R === FINE ? low[v * FINE + u] : low[Math.min(R - 1, Math.floor((v + 0.5) / FINE * R)) * R + Math.min(R - 1, Math.floor((u + 0.5) / FINE * R))];

            bits.push(on ? 1 : 0);
            if (on) count++;
          }
        }

        if (count === FINE * FINE) grid[j * nx + i] = 1;
        else if (count > 0) masks.set(j * nx + i, bits);
      }
    }

    const z = ceiling ? room.z + room.height : room.z;
    const pitch = ceiling ? -90 : 90;
    const yw = round(yaw(ax), 2);
    const palette = [baseMat];
    const matOf = function (i, j) {
      if (!tiles) return 0;

      const ti = Math.floor(((xs[i] + xs[i + 1]) / 2 - (tileAligned ? originX : minx)) / G + 1e-6);
      const tj = Math.floor(((ys[j] + ys[j + 1]) / 2 - (tileAligned ? originY : miny)) / G + 1e-6);
      const own = tiles[ti + "," + tj];

      if (!own || own === baseMat) return 0;

      let index = palette.indexOf(own);

      if (index < 0) {
        palette.push(own);
        index = palette.length - 1;
      }

      return index;
    };
    let count = 0;
    let suppressCol = false;
    const bandCollider = function (x0, y0, x1, y1) {
      if (ceiling || !colliderSizes || x1 - x0 < 0.05 || y1 - y0 < 0.05) return;

      const at = world(x0, y1);

      emitCollider(pieces, prefix, { origin: [at[0], at[1], room.z], pitch: 90, yaw: round(yaw(ax), 2), roll: 0, x0: 0, x1: x1 - x0, y0: -0.1, z0: 0, z1: y1 - y0 });
    };
    const emitRect = function (mat, x0, y0, x1, y1, exact) {
      if (exact && roomExt > 0) {
        const strip = function (ax, ay, bx, by) {
          let hit = 0;
          let n = 0;
          const nu = Math.max(3, Math.ceil((bx - ax) / 0.25));
          const nv = Math.max(3, Math.ceil((by - ay) / 0.25));

          for (let i = 0; i <= nu; i++) {
            for (let j = 0; j <= nv; j++) {
              n++;
              if (room.under(world(ax + (bx - ax) * (0.05 + 0.9 * i / nu), ay + (by - ay) * (0.05 + 0.9 * j / nv)))) hit++;
            }
          }

          return hit / n >= 0.6;
        };
        const e = roomExt;
        const l = strip(x0 - e, y0, x0, y1);
        const r = strip(x1, y0, x1 + e, y1);
        const b = strip(x0, y0 - e, x1, y0);
        const t = strip(x0, y1, x1, y1 + e);

        if (l) x0 -= e;
        if (r) x1 += e;
        if (b) y0 -= e;
        if (t) y1 += e;
      }

      return emitCore(mat, x0, y0, x1, y1);
    };
    const emitCore = function (mat, x0, y0, x1, y1) {
      const useQuads = !!(quadKit && trimSet && trimSet.has(mat));

      if (!useQuads) {
        const at = world(x0, ceiling ? y0 : y1);

        trimPiece(pieces, prefix, mat, [at[0], at[1], z], pitch, yw, x1 - x0, y1 - y0);
        count++;
        return;
      }

      const topY = globalGrid ? Math.ceil(maxy + roomExt + 1e-6) : maxy + roomExt;

      if (globalGrid) {
        const hidden = function (ax0, ay0, ax1, ay1) {
          if (ax1 - ax0 < 0.0005 || ay1 - ay0 < 0.0005) return true;

          const nu = Math.max(2, Math.ceil((ax1 - ax0) / 0.04));
          const nv = Math.max(2, Math.ceil((ay1 - ay0) / 0.04));

          for (let i = 0; i <= nu; i++) {
            for (let j = 0; j <= nv; j++) {
              const q = world(ax0 + (ax1 - ax0) * (0.02 + 0.96 * i / nu), ay0 + (ay1 - ay0) * (0.02 + 0.96 * j / nv));

              if (!((room.under && room.under(q)) || (room.sameFloor && room.sameFloor(q, mat)))) return false;
            }
          }

          return true;
        };
        const gx0 = originX + Math.floor((x0 - originX) / G + 1e-6) * G;
        const gx1 = originX + Math.ceil((x1 - originX) / G - 1e-6) * G;

        if (x0 - gx0 > 0.002 && hidden(gx0, y0, x0, y1)) x0 = gx0;
        if (gx1 - x1 > 0.002 && hidden(x1, y0, gx1, y1)) x1 = gx1;

        const gy0 = originY + Math.floor((y0 - originY) / G + 1e-6) * G;
        const gy1 = originY + Math.ceil((y1 - originY) / G - 1e-6) * G;

        if (y0 - gy0 > 0.002 && hidden(x0, gy0, x1, y0)) y0 = gy0;
        if (gy1 - y1 > 0.002 && hidden(x0, y1, x1, gy1)) y1 = gy1;
      }

      const absorb = function (list) {
        const real = function (c) { return c.size * (c.scale || 1); };

        if (list.length >= 2) {
          const last = list[list.length - 1];
          const prev = list[list.length - 2];

          if (real(last) < 0.21 && prev.idx >= 0 && last.idx >= 0 && prev.size >= 0.99) {
            prev.scale = (real(prev) + real(last)) / prev.size;
            list.pop();
          }
        }

        if (list.length >= 2) {
          const first = list[0];
          const next = list[1];

          if (real(first) < 0.21 && next.idx >= 0 && first.idx >= 0 && next.size >= 0.99) {
            next.scale = (real(first) + real(next)) / next.size;
            next.at = first.at;
            list.shift();
          }
        }

        return list;
      };
      let floorCol = false;
      const fit = function (a, b, list) {
        const L = b - a;

        if (L < 0.002) return [];
        if (PLAIN.has(mat) || /^p\d\d$/.test(mat)) return decompose(a, b, list, mat);
        if (globalGrid) return decompose(a, b, list, mat);

        let q = 0.25;

        for (const step of [1, 0.5]) {
          const m = Math.max(step, Math.round(L / step) * step);

          if (Math.abs(L / m - 1) <= 0.08) { q = step; break; }
        }

        let M = Math.max(q, Math.round(L / q) * q);

        if (L / M > 1.15) M += q;

        const k = L / M;
        const out = [];
        let rest = M;
        let at = a;

        [4, 2, 1, 0.75, 0.5, 0.25].forEach(function (size) {
          while (rest >= size - 1e-6) {
            const idx = quadIndex(list, size, 0);

            if (idx < 0) break;

            out.push({ at: at, size: size, idx: idx, scale: k });
            at += size * k;
            rest -= size;
          }
        });

        if (rest > 1e-6 || !out.length) return absorb(decompose(a, b, list, mat));

        return out;
      };
      const vs = ceiling ? fit(y0 - originY, y1 - originY, quadKit.v) : fit(topY - y1, topY - y0, quadKit.v);
      const yOf = function (vAt) { return ceiling ? originY + vAt : topY - vAt; };
      const us = fit(x0 - originX, x1 - originX, quadKit.u);

      us.forEach(function (cu) {
        vs.forEach(function (cv) {
          const at = world(originX + cu.at, yOf(cv.at));

          if (cu.idx < 0 || cv.idx < 0) {
            trimPiece(pieces, prefix, mat, [at[0], at[1], z], pitch, yw, cu.size, cv.size);
            if (!ceiling) floorCol = true;
          } else {
            const piece = [quadName(prefix, mat, cu.idx, cv.idx), round(at[0]), round(at[1]), round(z), pitch, yw];
            const sx = cu.scale || 1;
            const sz = cv.scale || 1;

            if (sx !== 1 || sz !== 1) {
              piece.push(round(sx, 4), round(sz, 4));
              piece.noCol = true;
              noCollide(piece);
              if (!ceiling) floorCol = true;
            }
            pieces.push(piece);
          }
          count++;
        });
      });

      if (floorCol && colliderSizes && !suppressCol) {
        const at = world(x0, y1);

        emitCollider(pieces, prefix, { origin: [at[0], at[1], z], pitch: 90, yaw: yw, roll: 0, x0: 0, x1: x1 - x0, y0: -0.1, z0: 0, z1: y1 - y0 });
      }
    };
    const boxRoom = !noBacking && !holeList.length && poly.length === 4 && poly.every(function (q) { return (Math.abs(q[0] - minx) < 0.002 || Math.abs(q[0] - maxx) < 0.002) && (Math.abs(q[1] - miny) < 0.002 || Math.abs(q[1] - maxy) < 0.002); });
    const backingMat = { key: null };
    const backing = function (mat, x0, y0, x1, y1) {
      if (noBacking) return;

      if (boxRoom) {
        if (backingMat.key === null) backingMat.key = mat;
        return;
      }

      const at = world(x0, ceiling ? y0 : y1);

      emitBacking(pieces, prefix, mat, [at[0], at[1], z + (ceiling ? 0.02 : -0.02)], pitch, yw, x1 - x0, y1 - y0);
    };
    const codes = new Int16Array(nx * ny);

    if (graceSegs.length && !(tiles && Object.keys(tiles).length)) {
      const crossings = function (y) {
        const out = [];

        for (let k = 0; k < poly.length; k++) {
          const a = poly[k];
          const b = poly[(k + 1) % poly.length];

          if ((a[1] <= y) !== (b[1] <= y)) out.push(a[0] + (y - a[1]) * (b[0] - a[0]) / (b[1] - a[1]));
        }

        return out.sort(function (p, q) { return p - q; });
      };
      const strips = [];

      for (let j = 0; j < ny; j++) {
        const y0 = ys[j];
        const y1 = ys[j + 1];
        const lines = [y0 + 0.003, (y0 + y1) / 2, y1 - 0.003].map(crossings);

        if (!lines.every(function (c) { return c.length === 2; })) continue;

        let xa = Math.min(lines[0][0], lines[1][0], lines[2][0]);
        let xb = Math.max(lines[0][1], lines[1][1], lines[2][1]);
        const ga = Math.max(minx, originX + Math.floor((xa - originX) / G + 1e-6) * G);
        const gb = Math.min(maxx, originX + Math.ceil((xb - originX) / G - 1e-6) * G);

        if ([[ga, y0], [ga, y1]].every(inRoom)) xa = ga;
        if ([[gb, y0], [gb, y1]].every(inRoom)) xb = gb;
        const blocked = holeBoxes.some(function (b) { return xa < b[2] && xb > b[0] && y0 < b[3] && y1 > b[1]; });

        if (blocked || ![[xa, y0], [xb, y0], [xa, y1], [xb, y1]].every(inRoom)) continue;

        const last = strips[strips.length - 1];

        if (last && last.j1 === j && Math.abs(last.xa - xa) < 0.004 && Math.abs(last.xb - xb) < 0.004) last.j1 = j + 1;
        else strips.push({ j0: j, j1: j + 1, xa: xa, xb: xb });

        for (let i = 0; i < nx; i++) {
          grid[j * nx + i] = 0;
          masks.delete(j * nx + i);
        }
      }

      const done = new Uint8Array(ny);

      strips.forEach(function (st) { for (let j = st.j0; j < st.j1; j++) done[j] = 1; });

      const crossingsX = function (x) {
        const out = [];

        for (let k = 0; k < poly.length; k++) {
          const a = poly[k];
          const b = poly[(k + 1) % poly.length];

          if ((a[0] <= x) !== (b[0] <= x)) out.push(a[1] + (x - a[0]) * (b[1] - a[1]) / (b[0] - a[0]));
        }

        return out.sort(function (p, q) { return p - q; });
      };
      const cols = [];

      for (let jA = 0; jA < ny; jA++) {
        if (done[jA]) continue;

        let jB = jA;

        while (jB < ny && !done[jB]) jB++;

        const yA = ys[jA];
        const yB = ys[jB];

        for (let i = 0; i < nx; i++) {
          const x0 = xs[i];
          const x1 = xs[i + 1];
          const lines = [x0 + 0.003, (x0 + x1) / 2, x1 - 0.003].map(crossingsX);

          if (!lines.every(function (c) { return c.length === 2; })) continue;

          let ya = Math.max(yA, Math.min(lines[0][0], lines[1][0], lines[2][0]));
          let yb = Math.min(yB, Math.max(lines[0][1], lines[1][1], lines[2][1]));
          const gya = Math.max(yA, originY + Math.floor((ya - originY) / G + 1e-6) * G);
          const gyb = Math.min(yB, maxy, originY + Math.ceil((yb - originY) / G - 1e-6) * G);

          if ([[x0, gya], [x1, gya]].every(inRoom)) ya = gya;
          if ([[x0, gyb], [x1, gyb]].every(inRoom)) yb = gyb;

          if (yb - ya < 0.004) continue;

          const blocked = holeBoxes.some(function (b) { return x0 < b[2] && x1 > b[0] && ya < b[3] && yb > b[1]; });

          if (blocked || ![[x0, ya], [x1, ya], [x0, yb], [x1, yb]].every(inRoom)) continue;

          const last = cols[cols.length - 1];

          if (last && last.i1 === i && last.block === jA && Math.abs(last.ya - ya) < 0.004 && Math.abs(last.yb - yb) < 0.004) last.i1 = i + 1;
          else cols.push({ block: jA, i0: i, i1: i + 1, ya: ya, yb: yb });

          for (let j = jA; j < jB; j++) {
            if (ys[j + 1] <= ya + 0.0001 || ys[j] >= yb - 0.0001) continue;
            grid[j * nx + i] = 0;
            masks.delete(j * nx + i);
          }
        }

        jA = jB;
      }

      const rows = [];

      strips.forEach(function (st) { for (let j = st.j0; j < st.j1; j++) rows[j] = st; });

      const edgeRuns = [];
      const pushEdge = function (side, j, x0, x1) {
        if (x1 - x0 < 0.002) return;

        const open = edgeRuns.find(function (e) { return e.side === side && e.j1 === j; });

        if (open) {
          const nx0 = side === "r" ? open.x0 : Math.min(open.x0, x0);
          const nx1 = side === "l" ? open.x1 : Math.max(open.x1, x1);
          const sameInner = side === "l" ? Math.abs(open.x1 - x1) < 0.004 : side === "r" ? Math.abs(open.x0 - x0) < 0.004 : true;
          let ok = sameInner;

          for (let r = open.j0; ok && r <= j + 1; r++) {
            const yy = r <= open.j0 ? ys[r] + 0.003 : r >= j + 1 ? ys[r] - 0.003 : ys[r];

            if (!inRoom([nx0, yy]) || !inRoom([nx1, yy])) ok = false;
          }

          if (ok) {
            open.x0 = nx0;
            open.x1 = nx1;
            open.j1 = j + 1;
            return;
          }
        }

        edgeRuns.push({ side: side, j0: j, j1: j + 1, x0: x0, x1: x1 });
      };
      const snapIn = function (v, up) { return originX + (up ? Math.ceil((v - originX) / G - 1e-6) : Math.floor((v - originX) / G + 1e-6)) * G; };
      let j = 0;

      while (j < ny) {
        if (!rows[j]) { j++; continue; }

        let k = j;
        let ca = -Infinity;
        let cb = Infinity;

        while (k < ny && rows[k] && k - j < 16) {
          const na = Math.max(ca, rows[k].xa);
          const nb = Math.min(cb, rows[k].xb);
          const wide = rows[k].xb - rows[k].xa;

          if (k > j && snapIn(nb, false) - snapIn(na, true) < Math.max(1, wide * 0.55)) break;

          ca = na;
          cb = nb;
          k++;
        }

        const core0 = snapIn(ca, true);
        const core1 = snapIn(cb, false);
        let wa = Infinity;
        let wb = -Infinity;

        for (let r = j; r < k; r++) { wa = Math.min(wa, rows[r].xa); wb = Math.max(wb, rows[r].xb); }
        bandCollider(wa, ys[j], wb, ys[k]);
        suppressCol = true;

          if (core1 - core0 >= 0.5) {
          emitRect(baseMat, core0, ys[j], core1, ys[k], true);
          backing(baseMat, core0, ys[j], core1, ys[k]);

          for (let r = j; r < k; r++) {
            pushEdge("l", r, rows[r].xa, core0);
            pushEdge("r", r, core1, rows[r].xb);
          }
        } else {
          for (let r = j; r < k; r++) pushEdge("m", r, rows[r].xa, rows[r].xb);
        }

        j = k;
      }

      edgeRuns.forEach(function (e) { emitRect(baseMat, e.x0, ys[e.j0], e.x1, ys[e.j1], true); });
      suppressCol = false;
      cols.forEach(function (c) {
        emitRect(baseMat, xs[c.i0], c.ya, xs[c.i1], c.yb, true);
        backing(baseMat, xs[c.i0], c.ya, xs[c.i1], c.yb);
      });
    }

    if (globalGrid && masks.size) {
      Array.from(masks.keys()).forEach(function (index) {
        const i = index % nx;
        const j = Math.floor(index / nx);
        const x0 = xs[i];
        const y0 = ys[j];
        const cw = xs[i + 1] - x0;
        const ch = ys[j + 1] - y0;
        const nearHoles = holeList.filter(function (h, k) { const b = holeBoxes[k]; return x0 < b[2] + 0.03 && x0 + cw > b[0] - 0.03 && y0 < b[3] + 0.03 && y0 + ch > b[1] - 0.03; });

        if (nearHoles.length || matOf(i, j) !== 0) return;

        let ok = true;

        for (let v = 0; ok && v <= 6; v++) {
          for (let u = 0; ok && u <= 6; u++) {
            const q = [x0 + cw * (0.02 + 0.96 * u / 6), y0 + ch * (0.02 + 0.96 * v / 6)];

            if (inRoom(q)) continue;

            const wq = world(q[0], q[1]);

            if (!((room.under && room.under(wq)) || (room.sameFloor && room.sameFloor(wq, baseMat)))) ok = false;
          }
        }

        if (ok) {
          grid[index] = 1;
          masks.delete(index);
        }
      });
    }

    for (let j = 0; j < ny; j++) for (let i = 0; i < nx; i++) codes[j * nx + i] = grid[j * nx + i] === 1 ? 10 + matOf(i, j) : 0;

    largestRects(codes, nx, ny).forEach(function (r) {
      emitRect(palette[r[4] - 10], xs[r[0]], ys[r[1]], xs[r[2]], ys[r[3]], true);
      backing(palette[r[4] - 10], xs[r[0]], ys[r[1]], xs[r[2]], ys[r[3]]);
    });

    if (masks.size) {
      const fx = nx * FINE;
      const fy = ny * FINE;
      const cells = new Int16Array(fx * fy);
      const fxAt = function (n) { if (n >= nx * FINE) return xs[nx]; const c = Math.floor(n / FINE); return xs[c] + (n - c * FINE) * (xs[c + 1] - xs[c]) / FINE; };
      const fyAt = function (n) { if (n >= ny * FINE) return ys[ny]; const c = Math.floor(n / FINE); return ys[c] + (n - c * FINE) * (ys[c + 1] - ys[c]) / FINE; };

      masks.forEach(function (bits, index) {
        const i = index % nx;
        const j = Math.floor(index / nx);
        const code = 10 + matOf(i, j);

        for (let v = 0; v < FINE; v++) for (let u = 0; u < FINE; u++) if (bits[v * FINE + u]) cells[(j * FINE + v) * fx + i * FINE + u] = code;
      });

      for (let j = 0; j < fy; j++) {
        for (let i = 0; i < fx; i++) {
          const code = cells[j * fx + i];

          if (code < 10) continue;

          let k = i;

          while (k < fx && cells[j * fx + k] === code) k++;

          let m = j + 1;

          while (m < fy) {
            let row = true;

            for (let x = i; x < k; x++) if (cells[m * fx + x] !== code) { row = false; break; }
            if (!row) break;
            m++;
          }

          for (let y = j; y < m; y++) for (let x = i; x < k; x++) cells[y * fx + x] = 2;

          emitRect(palette[code - 10], fxAt(i), fyAt(j), fxAt(k), fyAt(m), false);
          if (!graceSegs.length || Math.min(fxAt(k) - fxAt(i), fyAt(m) - fyAt(j)) > 0.2) backing(palette[code - 10], fxAt(i), fyAt(j), fxAt(k), fyAt(m));
        }
      }
    }

    if (boxRoom && backingMat.key) {
      const at = world(minx, ceiling ? miny : maxy);

      emitBacking(pieces, prefix, backingMat.key, [at[0], at[1], z + (ceiling ? 0.02 : -0.02)], pitch, yw, maxx - minx, maxy - miny);
    }

    return count;
  }

  function kitDoor(kit, key) {
    const list = (kit && kit.doors) || [];

    return list.find(function (d) { return d.key === key; }) || list[0] || null;
  }

  function slotOf(key) {
    return /^s[1-6]$/.test(String(key || ""));
  }

  function stepRow(pieces, prefix, mat, base, fwd, side, width, top) {
    const codes = { 1: "a", 0.5: "b", 0.25: "c" };
    const yw = round(Math.atan2(fwd[0], -fwd[1]) * 180 / Math.PI, 2);
    const start = add(base, mul(side, -width / 2));

    sizeSplit(width, false, [1, 0.5, 0.25]).forEach(function (p) {
      const at = add(start, mul(side, p.at));
      const origin = dot(left(fwd), side) > 0 ? at : add(at, mul(side, p.size));

      if (p.kit && codes[p.size]) pieces.push([prefix + "step_" + mat + "_" + codes[p.size], round(origin[0]), round(origin[1]), round(top), 0, yw]);
      else if (p.size > 0.01) pieces.push([prefix + "step_" + mat + "_c", round(origin[0]), round(origin[1]), round(top), 0, yw, round(p.size / 0.25, 4), 1]);
    });
  }

  function paintsOf(wall, side, A, d) {
    const list = Array.isArray(wall && wall.paints) ? wall.paints : [];

    if (!list.length || Math.abs(Number(wall.bend) || 0) >= 0.02) return [];

    const dw = norm(sub(wall.b, wall.a));
    const sign = dot(d, dw) >= 0 ? 1 : -1;
    const wa = dot(sub(A, wall.a), dw);

    return list.filter(function (r) { return r && r.side === side && r.m; }).map(function (r) {
      const u0 = sign * (Number(r.a) - wa);
      const u1 = sign * (Number(r.b) - wa);

      return { u0: Math.min(u0, u1), u1: Math.max(u0, u1), z0: Math.max(0, Number(r.z0) || 0), z1: Number(r.z1) > 0 ? Number(r.z1) : 99, m: r.m };
    });
  }

  function emitPainted(pieces, mat, rawRegions, A, d, z, ua, ub, za, zb, prefix, note, anchor, anchorV) {
    const SNAP = 0.16;
    const regions = rawRegions.map(function (r) {
      const out = Object.assign({}, r);

      if (out.u0 > ua && out.u0 - ua < SNAP && out.u1 > ua + SNAP) out.u0 = ua;
      if (out.u1 < ub && ub - out.u1 < SNAP && out.u0 < ub - SNAP) out.u1 = ub;
      if (out.z0 > za && out.z0 - za < SNAP && out.z1 > za + SNAP) out.z0 = za;
      if (out.z1 < zb && zb - out.z1 < SNAP && out.z0 < zb - SNAP) out.z1 = zb;

      return out;
    });

    if (!regions.length) {
      emitFace(pieces, mat, A, d, z, ua, ub, za, zb, prefix, anchor, anchorV);
      return;
    }

    const us = [ua, ub];
    const zs = [za, zb];

    regions.forEach(function (r) {
      [r.u0, r.u1].forEach(function (u) { if (u > ua + 0.004 && u < ub - 0.004) us.push(u); });
      [r.z0, r.z1].forEach(function (v) { if (v > za + 0.004 && v < zb - 0.004) zs.push(v); });
    });

    const ux = Array.from(new Set(us.map(function (v) { return round(v, 4); }))).sort(function (x, y) { return x - y; });
    const zx = Array.from(new Set(zs.map(function (v) { return round(v, 4); }))).sort(function (x, y) { return x - y; });

    for (let i = 1; i < ux.length; i++) {
      for (let j = 1; j < zx.length; j++) {
        const um = (ux[i - 1] + ux[i]) / 2;
        const zm = (zx[j - 1] + zx[j]) / 2;
        let pick = mat;

        regions.forEach(function (r) { if (um > r.u0 && um < r.u1 && zm > r.z0 && zm < r.z1) pick = r.m; });

        if (ux[i] - ux[i - 1] > 0.004 && zx[j] - zx[j - 1] > 0.004) emitFace(pieces, note(pick), A, d, z, ux[i - 1], ux[i], zx[j - 1], zx[j], prefix, anchor, anchorV);
      }
    }
  }

  function isPlain(mat) {
    return !mat || PLAIN.has(mat) || /^p\d\d$/.test(mat) || !quadKit || !trimSet || !trimSet.has(mat);
  }

  function mergeCells(xs, zs, free) {
    const nx = xs.length - 1;
    const nz = zs.length - 1;
    const used = new Uint8Array(nx * nz);
    const out = [];

    for (let j = 0; j < nz; j++) {
      for (let i = 0; i < nx; i++) {
        if (used[j * nx + i] || !free(i, j)) continue;

        let k = i;

        while (k < nx && !used[j * nx + k] && free(k, j)) k++;

        let m = j + 1;

        while (m < nz) {
          let row = true;

          for (let x = i; x < k; x++) if (used[m * nx + x] || !free(x, m)) { row = false; break; }
          if (!row) break;
          m++;
        }

        for (let y = j; y < m; y++) for (let x = i; x < k; x++) used[y * nx + x] = 1;
        out.push([xs[i], zs[j], xs[k], zs[m]]);
      }
    }

    return out;
  }

  function gridPhase(candidates, cost) {
    let best = 0;
    let score = Infinity;

    candidates.forEach(function (c) {
      const v = ((c % QG) + QG) % QG;
      const value = cost(v) + (v > 0.0005 ? 0.0005 : 0);

      if (value < score - 1e-9) { score = value; best = v; }
    });

    return best;
  }

  function emitGridded(pieces, mat, regions, A, d, z, length, height, holes, prefix, note, ext) {
    const L = length;
    const H = height;
    const cover = ext.cover || 0;
    const fl = function (v, ph) { return Math.floor((v + ph) / QG + QE * 10) * QG - ph; };
    const ce = function (v, ph) { return Math.ceil((v + ph) / QG - QE * 10) * QG - ph; };
    const vis = function (r) { return r < 0.004 ? 0 : Math.max(0, r - cover) + 0.02; };
    const list = holes.map(function (h) { return { u0: Math.max(0, h.u0), u1: Math.min(L, h.u1), z0: Math.max(0, h.z0), z1: Math.min(H, h.z1) }; }).filter(function (h) { return h.u1 - h.u0 > 0.004 && h.z1 - h.z0 > 0.004; });
    const endCost = function (ph, size, start, end, extA, extB) {
      let c = 0;
      const ra = ce(start, ph) - start;
      const rb = end - fl(end, ph);

      if (ra > 0.004 && !(QG - ra <= extA + 1e-6)) c += size * ra;
      if (rb > 0.004 && !(QG - rb <= extB + 1e-6)) c += size * rb;

      return c;
    };
    const candU = [0];
    const candV = [0];

    list.forEach(function (h) { candU.push(-h.u0, -h.u1); candV.push(-h.z0, -h.z1); });

    const pu = gridPhase(candU, function (ph) {
      let c = endCost(ph, H, 0, L, ext.start || 0, ext.end || 0);

      list.forEach(function (h) {
        const hh = h.z1 - h.z0;

        if (h.u0 > 0.004) c += hh * vis(h.u0 - fl(h.u0, ph));
        if (h.u1 < L - 0.004) c += hh * vis(ce(h.u1, ph) - h.u1);
      });

      return c;
    });
    const pv = gridPhase(candV, function (ph) {
      let c = endCost(ph, L, 0, H, ext.bottom || 0, ext.top || 0);

      list.forEach(function (h) {
        const ww = h.u1 - h.u0;

        if (h.z0 > 0.004) c += ww * vis(h.z0 - fl(h.z0, ph));
        if (h.z1 < H - 0.004) c += ww * vis(ce(h.z1, ph) - h.z1);
      });

      return c;
    });
    let boxes = list.map(function (h) { return { u0: Math.max(0, fl(h.u0, pu)), u1: Math.min(L, ce(h.u1, pu)), z0: Math.max(0, fl(h.z0, pv)), z1: Math.min(H, ce(h.z1, pv)), holes: [h] }; });
    let merged = true;

    while (merged) {
      merged = false;

      for (let i = 0; i < boxes.length && !merged; i++) {
        for (let j = i + 1; j < boxes.length && !merged; j++) {
          const a = boxes[i];
          const b = boxes[j];

          if (a.u0 < b.u1 - 0.001 && b.u0 < a.u1 - 0.001 && a.z0 < b.z1 - 0.001 && b.z0 < a.z1 - 0.001) {
            boxes[i] = { u0: Math.min(a.u0, b.u0), u1: Math.max(a.u1, b.u1), z0: Math.min(a.z0, b.z0), z1: Math.max(a.z1, b.z1), holes: a.holes.concat(b.holes) };
            boxes.splice(j, 1);
            merged = true;
          }
        }
      }
    }

    const draw = function (r) {
      let ua = r[0];
      let ub = r[2];
      let za = r[1];
      let zb = r[3];

      if (ua <= 0.0005) { const g = fl(0, pu); if (-g > 0.0005 && -g <= (ext.start || 0) + 1e-6) ua = g; }
      if (ub >= L - 0.0005) { const g = ce(L, pu); if (g - L > 0.0005 && g - L <= (ext.end || 0) + 1e-6) ub = g; }
      if (za <= 0.0005) { const g = fl(0, pv); if (-g > 0.0005 && -g <= (ext.bottom || 0) + 1e-6) za = g; }
      if (zb >= H - 0.0005) { const g = ce(H, pv); if (g - H > 0.0005 && g - H <= (ext.top || 0) + 1e-6) zb = g; }
      if (ub - ua > 0.004 && zb - za > 0.004) emitPainted(pieces, mat, regions, A, d, z, ua, ub, za, zb, prefix, note, pu, pv);
    };
    const uniq = function (arr) { return Array.from(new Set(arr.map(function (v) { return round(v, 4); }))).sort(function (a, b) { return a - b; }); };
    const xs = uniq([0, L].concat.apply([0, L], boxes.map(function (b) { return [b.u0, b.u1]; })));
    const zs = uniq([0, H].concat.apply([0, H], boxes.map(function (b) { return [b.z0, b.z1]; })));

    mergeCells(xs, zs, function (i, j) {
      const mx = (xs[i] + xs[i + 1]) / 2;
      const mz = (zs[j] + zs[j + 1]) / 2;

      return xs[i + 1] - xs[i] > 0.002 && zs[j + 1] - zs[j] > 0.002 && !boxes.some(function (b) { return mx > b.u0 && mx < b.u1 && mz > b.z0 && mz < b.z1; });
    }).forEach(draw);

    boxes.forEach(function (b) {
      const bx = uniq([b.u0, b.u1].concat.apply([b.u0, b.u1], b.holes.map(function (h) { return [h.u0, h.u1]; }))).filter(function (v) { return v >= b.u0 - 1e-6 && v <= b.u1 + 1e-6; });
      const bz = uniq([b.z0, b.z1].concat.apply([b.z0, b.z1], b.holes.map(function (h) { return [h.z0, h.z1]; }))).filter(function (v) { return v >= b.z0 - 1e-6 && v <= b.z1 + 1e-6; });

      mergeCells(bx, bz, function (i, j) {
        const mx = (bx[i] + bx[i + 1]) / 2;
        const mz = (bz[j] + bz[j + 1]) / 2;

        return bx[i + 1] - bx[i] > 0.002 && bz[j + 1] - bz[j] > 0.002 && !b.holes.some(function (h) { return mx > h.u0 && mx < h.u1 && mz > h.z0 && mz < h.z1; });
      }).forEach(draw);
    });

    const top = Number(ext.top) || 0;

    if (top > 0.004) {
      const g = ce(H, pv);
      const drawn = g - H > 0.0005 && g - H <= top + 1e-6 ? g : H;

      if (H + top - drawn > 0.004) {
        let ua = 0;
        let ub = L;
        const gs = fl(0, pu);
        const ge = ce(L, pu);

        if (-gs > 0.0005 && -gs <= (ext.start || 0) + 1e-6) ua = gs;
        if (ge - L > 0.0005 && ge - L <= (ext.end || 0) + 1e-6) ub = ge;
        const from = pieces.length;

        emitPainted(pieces, mat, regions, A, d, z, ua, ub, drawn, H + top, prefix, note, pu, pv);

        if (ext.cutAt !== undefined) {
          for (let k = from; k < pieces.length; k++) {
            while (pieces[k].length < 13) pieces[k].push(pieces[k].length === 6 || pieces[k].length === 7 || pieces[k].length === 9 ? 1 : pieces[k].length === 11 ? null : 0);
            pieces[k][13] = ext.cutAt;
          }
        }
      }
    }
  }

  function emitStrips(pieces, mat, regions, A, d, z, length, height, holes, prefix, note, anchor, extEnd, ext) {
    if (!curveMode && ext && !(isPlain(mat) && regions.every(function (r) { return isPlain(r.m); }))) {
      emitGridded(pieces, mat, regions, A, d, z, length, height, holes, prefix, note, Object.assign({ end: extEnd || 0 }, ext));
      return;
    }

    const sorted = holes.slice().sort(function (a, b) { return a.u0 - b.u0; });
    const cuts = [0, length];

    sorted.forEach(function (h) { cuts.push(h.u0, h.u1); });

    const xs = Array.from(new Set(cuts.map(function (v) { return round(Math.max(0, Math.min(length, v)), 4); }))).sort(function (a, b) { return a - b; });

    for (let i = 1; i < xs.length; i++) {
      const ua = xs[i - 1];
      const ub = xs[i];

      if (ub - ua < 0.004) continue;

      const mid = (ua + ub) / 2;
      let solid = [[0, height]];

      sorted.forEach(function (h) {
        if (h.u0 <= mid && h.u1 >= mid) {
          const next = [];

          solid.forEach(function (sg) {
            if (h.z1 <= sg[0] || h.z0 >= sg[1]) next.push(sg);
            else {
              if (h.z0 > sg[0]) next.push([sg[0], h.z0]);
              if (h.z1 < sg[1]) next.push([h.z1, sg[1]]);
            }
          });
          solid = next;
        }
      });
      solid.forEach(function (sg) {
        if (sg[1] - sg[0] > 0.004) {
          const grid = Math.ceil((ub + (Number(anchor) || 0)) / QG - QE) * QG - (Number(anchor) || 0);
          const ubDraw = ub >= length - 0.0005 && extEnd && grid - ub > 0.0005 && grid - ub <= extEnd ? grid : ub;
          const z0 = ext && sg[0] <= 0.0005 ? -(Number(ext.bottom) || 0) : sg[0];
          const z1 = ext && sg[1] >= height - 0.0005 ? height + (Number(ext.top) || 0) : sg[1];

          emitPainted(pieces, mat, regions, A, d, z, ua, ubDraw, z0, z1, prefix, note, anchor);
        }
      });
    }
  }

  function build(doc, kit, buildOptions) {
    const derived = derive(doc, kit);
    const prefix = (kit && kit.prefix) || "rtx_tk_";
    const pieces = [];
    const spiralEnds = [];
    const doors = [];
    const lamps = [];
    const elevators = [];
    const ladders = [];
    const settings = doc.settings || {};
    const skirting = settings.skirting || "";
    const wallGaps = function (levelId, at, fwd, side, halfW, t0, t1) {
      const gaps = { "1": null, "-1": null };

      (doc.walls || []).forEach(function (w) {
        if ((w.level || "l1") !== levelId || Math.abs(Number(w.bend) || 0) >= 0.02 || !w.a || !w.b) return;

        const d = sub(w.b, w.a);
        const length = len(d);

        if (length < 0.3 || Math.abs(dot(mul(d, 1 / length), fwd)) < 0.995) return;

        const wa = dot(sub(w.a, at), fwd);
        const wb = dot(sub(w.b, at), fwd);

        if (Math.min(wa, wb) > t1 - 0.2 || Math.max(wa, wb) < t0 + 0.2) return;

        const thick = Math.max(0.08, Number(w.thick) || Number(settings.thick) || 0.2);

        [1, -1].forEach(function (sign) {
          const gap = dot(sub(w.a, at), side) * sign - thick / 2 - halfW;

          if (gap > 0.005 && gap < 0.3 && (gaps[sign] === null || gap < gaps[sign])) gaps[sign] = gap;
        });
      });

      return gaps;
    };
    const frames = settings.frames || "";
    const usedSlots = new Set();
    const note = function (mat) { if (slotOf(mat)) usedSlots.add(mat); return mat; };
    const roomById = new Map(derived.rooms.map(function (r) { return [r.id, r]; }));
    const colliders = [];

    colQueue = kit && kit.colliders ? [] : null;
    faceCols = colliders;
    beamKit = kit && kit.beams && Array.isArray(kit.beams.sizes) ? kit.beams : null;
    curveKit = kit && kit.curves ? kit.curves : null;
    bigBoxKit = kit && kit.bigBoxes ? kit.bigBoxes : null;
    colliderSizes = kit && kit.colliders && Array.isArray(kit.colliders.sizes) ? kit.colliders.sizes.slice() : null;
    barKit = kit && Array.isArray(kit.barLengths) ? kit.barLengths.slice().sort(function (x, y) { return x - y; }) : null;
    wideKit = !!(kit && (kit.sizes || []).some(function (x) { return x.size === 4; }));
    quadKit = kit && kit.quads ? Object.assign({}, kit.quads, { v: kit.quads.v.map(function (e) { return e && Math.abs(e[0] - 2.8) < 1e-6 && Math.abs(e[1]) < 1e-6 ? [-99, -99] : e; }) }) : null;
    backingSet = kit && kit.backing ? new Set(Object.keys(kit.backing.colours || {})) : null;
    trimSet = kit && kit.trims ? new Set(((kit.materials || []).concat(kit.slots || [], kit.customs || [])).map(function (m) { return m.key; })) : null;
    tintKit = kit && kit.tints ? kit.tints : null;
    fxKit = kit && kit.fixtures && kit.fixtures.sinks ? kit.fixtures : null;

    if (trimSet && tintKit) {
      tintKit.bases.forEach(function (b) {
        for (let i = 1; i <= tintKit.colours.length; i++) trimSet.add(b.prefix + (i < 10 ? "0" : "") + i);
      });
    }

    const roofed = new Map();

    (doc.levels || []).forEach(function (level) {
      const rf = roofOf(doc, level);

      if (rf) roofed.set(level.id, rf);
    });

    const levelsAsc = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
    const underCache = {};
    const exceptCache = {};
    const upperUnderExcept = function (levelId, skipId) {
      const key = levelId + "|" + skipId;

      if (exceptCache[key]) return exceptCache[key];

      const lines = [];

      (doc.walls || []).forEach(function (w) {
        if (w.level !== levelId || w.id === skipId || !w.a || !w.b) return;

        const pts = wallPoints(w);
        const t = Math.max(0.08, Number(w.thick) || Number(settings.thick) || 0.2);

        for (let i = 1; i < pts.length; i++) lines.push([pts[i - 1], pts[i], t / 2 - 0.01]);
      });

      exceptCache[key] = function (q) {
        return lines.some(function (ln) {
          const ab = sub(ln[1], ln[0]);
          const L2 = dot(ab, ab) || 1e-9;
          const k = Math.max(0, Math.min(1, dot(sub(q, ln[0]), ab) / L2));

          return len(sub(q, add(ln[0], mul(ab, k)))) <= ln[2];
        });
      };

      return exceptCache[key];
    };
    const upperCache = {};
    const upperUnder = function (levelId) {
      if (upperCache[levelId]) return upperCache[levelId];

      const lines = [];

      (doc.walls || []).forEach(function (w) {
        if (w.level !== levelId || !w.a || !w.b) return;

        const pts = wallPoints(w);
        const t = Math.max(0.08, Number(w.thick) || Number(settings.thick) || 0.2);

        for (let i = 1; i < pts.length; i++) lines.push([pts[i - 1], pts[i], t / 2 + 0.01]);
      });

      upperCache[levelId] = function (q) {
        return lines.some(function (ln) {
          const ab = sub(ln[1], ln[0]);
          const L2 = dot(ab, ab) || 1e-9;
          const k = Math.max(0, Math.min(1, dot(sub(q, ln[0]), ab) / L2));

          return len(sub(q, add(ln[0], mul(ab, k)))) <= ln[2];
        });
      };

      return upperCache[levelId];
    };
    const underOf = function (levelId) {
      if (underCache[levelId]) return underCache[levelId];

      const boxes = [];

      (doc.walls || []).forEach(function (w) {
        if (w.level !== levelId || wallPoints(w).length > 2) return;

        const ab = sub(w.b, w.a);
        const L = len(ab);

        if (L < 0.05) return;

        const t = Math.max(0.08, Number(w.thick) || Number(settings.thick) || 0.2);
        const doorsOn = derived.openings.filter(function (o) { return o.wall === w.id && o.z0 < 0.1 && !o.fake; }).map(function (o) { return [o.t - o.width / 2, o.t + o.width / 2]; });

        boxes.push({ a: w.a, d: mul(ab, 1 / L), L: L, h: t / 2 + 0.003, doors: doorsOn });
      });

      underCache[levelId] = function (q) {
        for (let i = 0; i < boxes.length; i++) {
          const b = boxes[i];
          const rx = q[0] - b.a[0];
          const ry = q[1] - b.a[1];
          const u = rx * b.d[0] + ry * b.d[1];

          if (u <= -b.h || u >= b.L + b.h) continue;

          const v = Math.abs(rx * b.d[1] - ry * b.d[0]);

          if (v >= b.h) continue;

          let door = false;

          for (let k = 0; k < b.doors.length; k++) if (u > b.doors[k][0] - 0.01 && u < b.doors[k][1] + 0.01) { door = true; break; }
          if (!door) return true;
        }

        return false;
      };

      return underCache[levelId];
    };

    const levelAxes = {};
    const levelAxis = function (levelId) {
      if (levelAxes[levelId]) return levelAxes[levelId];

      const buckets = new Map();

      (doc.walls || []).forEach(function (w) {
        if (w.level !== levelId || Math.abs(Number(w.bend) || 0) >= 0.02 || !w.a || !w.b) return;

        const L = len(sub(w.b, w.a));

        if (L < 0.3) return;

        let deg = Math.atan2(w.b[1] - w.a[1], w.b[0] - w.a[0]) * 180 / Math.PI;

        deg = ((deg % 90) + 90) % 90;

        const key = Math.round(deg * 4) / 4 % 90;

        buckets.set(key, (buckets.get(key) || 0) + L);
      });

      let bestKey = 0;
      let bestLen = -1;

      buckets.forEach(function (total, key) { if (total > bestLen) { bestLen = total; bestKey = key; } });

      const r = bestKey * Math.PI / 180;

      levelAxes[levelId] = Math.abs(bestKey) < 1e-6 ? [1, 0] : [Math.cos(r), Math.sin(r)];

      return levelAxes[levelId];
    };
    const floorsByLevel = {};

    derived.rooms.forEach(function (room) {
      const xs = room.points.map(function (q) { return q[0]; });
      const ys = room.points.map(function (q) { return q[1]; });

      (floorsByLevel[room.level] = floorsByLevel[room.level] || []).push({ points: room.points, mat: materialOf(doc, room, "floor", "oak"), box: [Math.min.apply(null, xs) - 0.01, Math.min.apply(null, ys) - 0.01, Math.max.apply(null, xs) + 0.01, Math.max.apply(null, ys) + 0.01] });
    });

    const doorwaysByLevel = {};

    derived.openings.forEach(function (o) {
      if (o.fake || o.z0 > 0.1 || !o.c || !o.d) return;

      const wall = (doc.walls || []).find(function (w) { return w.id === o.wall; });

      if (!wall || wallPoints(wall).length > 2) return;

      const mats = (o.rooms || []).map(function (id) { const r = derived.rooms.find(function (x) { return x.id === id; }); return r ? materialOf(doc, r, "floor", "oak") : null; });

      if (mats.length < 2 || mats.some(function (m) { return m !== mats[0]; })) return;

      const thick = Math.max(0.08, Number(wall.thick) || Number(settings.thick) || 0.2);

      (doorwaysByLevel[wall.level] = doorwaysByLevel[wall.level] || []).push({ c: o.c, d: o.d, half: o.width / 2 + 0.01, depth: thick / 2 + 0.02, mat: mats[0] });
    });

    const sameFloorOf = function (room) {
      const list = (floorsByLevel[room.level] || []).filter(function (f) { return f.points !== room.points; });
      const doors = doorwaysByLevel[room.level] || [];

      return function (q, mat) {
        if (doors.some(function (dw) { const r = sub(q, dw.c); return dw.mat === mat && Math.abs(dot(r, dw.d)) <= dw.half && Math.abs(dot(r, left(dw.d))) <= dw.depth; })) return true;

        return list.some(function (f) { return f.mat === mat && q[0] >= f.box[0] && q[0] <= f.box[2] && q[1] >= f.box[1] && q[1] <= f.box[3] && (insidePolygon(q, f.points) || distanceToEdges(q, f.points) <= 0.002); });
      };
    };

    derived.rooms.forEach(function (room) {
      const roomFrom = pieces.length;
      const wallMat = note(materialOf(doc, room, "walls", "white"));
      const floorMat = note(materialOf(doc, room, "floor", "oak"));
      const ceilMat = note(materialOf(doc, room, "ceiling", "ceil"));
      const wallById = new Map((doc.walls || []).map(function (w) { return [w.id, w]; }));

      const roomLift = 0.003 + 0.0015 * (derived.rooms.indexOf(room) % 4);
      const pick = function (own, house) { return own !== undefined && own !== null ? own : house || ""; };
      const moulds = {
        skirt: pick(room.record.skirting, skirting),
        crown: pick(room.record.crown, settings.crown),
        skirtH: Math.max(0.04, Math.min(0.3, Number(settings.skirtH) || 0.1)),
        crownH: Math.max(0.03, Math.min(0.3, Number(settings.crownH) || 0.08)),
        lift: roomLift
      };

      let curveRun = 0;

      room.edges.forEach(function (edge, edgeIndex) {
        const wall = wallById.get(edge.wall) || {};
        const mat = note((edge.side === "l" ? wall.ml : wall.mr) || wallMat);
        const d = norm(sub(edge.b, edge.a));
        const holes = (edge.holes || []).slice().sort(function (a, b) { return a.u0 - b.u0; });
        const next = room.edges[(edgeIndex + 1) % room.edges.length];
        const nextWall = next ? wallById.get(next.wall) : null;
        const nd = next ? norm(sub(next.b, next.a)) : d;
        const convex = d[0] * nd[1] - d[1] * nd[0] > 0.5;
        const extEnd = convex && nextWall ? Math.max(0, Math.max(0.08, Number(nextWall.thick) || Number(settings.thick) || 0.2) - 0.015) : 0;

        const prevEdge = room.edges[(edgeIndex + room.edges.length - 1) % room.edges.length];
        const curved = Math.abs(Number(wall.bend) || 0) >= 0.02;

        if (!curved) curveRun = 0;
        else if (edgeIndex > 0 && prevEdge && prevEdge.wall === edge.wall) curveRun += prevEdge.length;
        else curveRun = 0;

        curveMode = curved;
        curveBend = 0;

        if (curved) {
          const pd = prevEdge ? norm(sub(prevEdge.b, prevEdge.a)) : d;
          const turnIn = prevEdge && prevEdge.wall === edge.wall ? Math.atan2(pd[0] * d[1] - pd[1] * d[0], dot(pd, d)) : 0;
          const turnOut = next && next.wall === edge.wall ? Math.atan2(d[0] * nd[1] - d[1] * nd[0], dot(d, nd)) : 0;

          curveBend = (Math.abs(turnIn) > Math.abs(turnOut) ? turnIn : turnOut) * 180 / Math.PI;
        }

        const pdir = prevEdge ? norm(sub(prevEdge.b, prevEdge.a)) : d;
        const prevWall = prevEdge ? wallById.get(prevEdge.wall) : null;
        const extStart = prevWall && pdir[0] * d[1] - pdir[1] * d[0] > 0.5 ? Math.max(0, Math.max(0.08, Number(prevWall.thick) || Number(settings.thick) || 0.2) - 0.015) : 0;
        const probe = add(mul(add(edge.a, edge.b), 0.5), mul(left(d), 0.3));
        const above = levelsAsc.find(function (l) { return l.z > room.z + 0.5; });
        const gapTop = above ? Number(above.z) - (room.z + room.height) : 0;
        const coveredAbove = above && room.record.ceilingOff !== true && !room.openAbove && !roofed.has(room.level) && derived.rooms.some(function (r) { return r.level === above.id && insidePolygon(probe, r.points); });
        const below = levelsAsc.slice().reverse().find(function (l) { return l.z < room.z - 0.5; });
        const gapBottom = below ? room.z - (Number(below.z) + (Number(below.height) || 2.8)) : 0.2;
        const coveredBelow = below && derived.rooms.some(function (r) { return r.level === below.id && r.record.ceilingOff !== true && insidePolygon(probe, r.points); }) && (doc.walls || []).some(function (w) { return w.level === below.id && wallPoints(w).length === 2 && Math.abs(Number(w.bend) || 0) < 0.02 && (function () { const ab = sub(w.b, w.a); const L2 = dot(ab, ab) || 1e-9; const mid = mul(add(edge.a, edge.b), 0.5); const k = Math.max(0, Math.min(1, dot(sub(mid, w.a), ab) / L2)); return len(sub(mid, add(w.a, mul(ab, k)))) < 0.2; })(); });
        const reachAbove = above && (doc.walls || []).some(function (w) { return w.level === above.id; });
        const ceilinged = room.record.ceilingOff !== true && !room.openAbove && !roofed.has(room.level);
        const seenThrough = above && derived.holes.some(function (h) {
          if (h.level !== above.id) return false;

          for (let k = 0; k <= 10; k++) {
            const q = add(add(edge.a, mul(d, edge.length * k / 10)), mul(left(d), 0.12));

            if (insidePolygon(q, h.points) || distanceToEdges(q, h.points) < 0.15) return true;
          }

          return false;
        });
        const ext = { cutAt: above && ceilinged && !seenThrough ? round(Number(above.z) - 0.03, 3) : undefined, start: extStart, top: coveredAbove || reachAbove ? Math.max(0, Math.min(0.4, gapTop) - 0.001) : 0, bottom: coveredBelow ? 0 : Math.max(0, Math.min(0.17, gapBottom - 0.03)), cover: frames ? 0.05 : 0 };

        emitStrips(pieces, mat, paintsOf(wall, edge.side, edge.a, d), edge.a, d, room.z, edge.length, room.height, holes, prefix, note, curved ? curveRun % 4 : 0, extEnd, ext);
        curveMode = false;

        const turn = next ? d[0] * nd[1] - d[1] * nd[0] : 0;
        const curvedEdge = Math.abs(Number(wall.bend) || 0) >= 0.02;
        const nextHoles = next ? (next.holes || []) : [];
        const floorGaps = [];

        {
          const levelHoles = derived.holes.filter(function (h) { return h.level === room.level; });

          if (levelHoles.length) {
            const n = Math.max(2, Math.ceil(edge.length / 0.04));
            let start = null;

            for (let k = 0; k <= n; k++) {
              const u = edge.length * k / n;
              const probe = add(add(edge.a, mul(d, u)), mul(left(d), 0.06));
              const open = levelHoles.some(function (h) { return insidePolygon(probe, h.points); });

              if (open && start === null) start = u;
              if ((!open || k === n) && start !== null) {
                floorGaps.push({ u0: start - 0.02, u1: (open ? u : u - edge.length / n) + 0.02, z0: 0, z1: 99 });
                start = null;
              }
            }
          }
        }

        const mouldRun = function (mat, depth, z0, height, low) {
          const cuts = holes.filter(function (h) { return low ? h.z0 < z0 - room.z + height + 0.01 : h.z1 > z0 - room.z - 0.01; }).concat(low ? floorGaps : []);
          const nextFree = !nextHoles.some(function (h) { return h.u0 < depth + 0.02 && (low ? h.z0 < 0.05 : h.z1 > z0 - room.z - 0.01); });
          const endShift = turn > 0.5 && nextFree ? -depth : turn < -0.5 ? depth : 0;
          const inset = frames ? 0.012 : 0;
          let from = 0;

          cuts.concat([{ u0: edge.length + endShift + inset, u1: edge.length }]).sort(function (a, b) { return a.u0 - b.u0; }).forEach(function (h) {
            const to = h.u0 - inset;

            const jitter = Math.abs(turn) <= 0.5 && Math.abs(turn) > 0.001 || curvedEdge ? 0.0012 * (edgeIndex % 2) : 0;

            if (to - from > 0.03) {
              boxPiece(pieces, prefix, mat, add(add(edge.a, mul(d, from)), mul(left(d), 0.001)), d, to - from, depth, z0 + (low ? 0.001 : -jitter), height - (low ? 0.001 - jitter : 0));
              pieces[pieces.length - 1].tag = "mould";
            }

            from = Math.max(from, h.u1 + inset);
          });
        };

        const edgeSkirt = wall.skirting !== undefined && wall.skirting !== null ? wall.skirting : moulds.skirt;

        if (edgeSkirt) mouldRun(note(edgeSkirt), SKIRT_DEPTH, room.z, moulds.skirtH, true);
        if (moulds.crown && room.record.ceilingOff !== true && !roofed.has(room.level)) mouldRun(note(moulds.crown), CROWN_DEPTH, room.z + room.height - moulds.lift - moulds.crownH, moulds.crownH, false);
      });

      const inner = derived.rooms.filter(function (other) { return other !== room && other.level === room.level && other.points.every(function (q) { return insidePolygon(q, room.points); }); }).map(function (other) { return { points: other.points }; });
      const roomHoles = derived.holes.filter(function (h) { return h.level === room.level; }).concat(inner);

      const lift = roomLift;

      Object.keys(room.record.tiles || {}).forEach(function (key) { note(room.record.tiles[key]); });
      const graceEdges = [];
      let graceMin = 1;

      room.edges.forEach(function (edge) {
        const wall = wallById.get(edge.wall);

        if (wall && Math.abs(Number(wall.bend) || 0) >= 0.02) {
          graceEdges.push([edge.a, edge.b]);
          graceMin = Math.min(graceMin, Math.max(0.08, Number(wall.thick) || Number(settings.thick) || 0.2));
        }
      });

      const graced = graceEdges.length ? { graceEdges: graceEdges, grace: Math.max(0.03, graceMin - 0.04) } : {};

      const under = underOf(room.level);
      const extOf = room.edges.reduce(function (m, edge) { const wall = wallById.get(edge.wall); return Math.min(m, Math.max(0.08, (wall && Number(wall.thick)) || Number(settings.thick) || 0.2) / 2); }, 0.15);
      graced.ext = extOf;

      tileRoom(pieces, prefix, Object.assign({}, room, graced, { z: room.z + lift, height: room.height - 2 * lift, under: under, gridAxis: levelAxis(room.level), sameFloor: sameFloorOf(room) }), roomHoles, floorMat, false, false, room.record.tiles);

      if (room.record.ceilingOff !== true && !room.openAbove && !roofed.has(room.level)) {
        const upperHoles = derived.holes.filter(function (h) { return h.level !== room.level && (derived.stairs.some(function (s) { return s.id === h.stair && s.level === room.level; }) || (h.void && h.below === room.level)); }).concat(inner);

        tileRoom(pieces, prefix, Object.assign({}, room, graced, { z: room.z + lift, height: room.height - 2 * lift, under: under }), upperHoles, ceilMat, true);
      }

      markBelow(pieces, roomFrom, room.z);
    });

    const covered = {};

    derived.rooms.forEach(function (room) {
      room.edges.forEach(function (edge) {
        const wall = (doc.walls || []).find(function (w) { return w.id === edge.wall; });

        if (!wall) return;

        const dw = norm(sub(wall.b, wall.a));
        const key = wall.id + ":" + edge.side;
        const u0 = dot(sub(edge.a, wall.a), dw);
        const u1 = dot(sub(edge.b, wall.a), dw);

        (covered[key] = covered[key] || []).push([Math.min(u0, u1) - 0.01, Math.max(u0, u1) + 0.01]);
      });
    });

    const levelsByZ = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
    const joinExt = function (wall, end) {
      const p = wall[end];
      let best = 0;

      (doc.walls || []).forEach(function (other) {
        if (other === wall || other.level !== wall.level || wallPoints(other).length > 2) return;

        const half = Math.max(0.08, Number(other.thick) || Number(settings.thick) || 0.2) / 2;
        const ab = sub(other.b, other.a);
        const L2 = dot(ab, ab);

        if (L2 < 1e-6) return;

        const t = Math.max(0, Math.min(1, dot(sub(p, other.a), ab) / L2));
        const dist = len(sub(p, add(other.a, mul(ab, t))));

        if (dist < half + 0.02) best = Math.max(best, half);
      });

      return best;
    };

    const walledIds = new Set();

    derived.rooms.forEach(function (rm) { rm.edges.forEach(function (e) { walledIds.add(e.wall); }); });

    const wallJoins = function (wall, q) {
      return (doc.walls || []).some(function (other) {
        if (other === wall || other.level !== wall.level) return false;

        const op = wallPoints(other);

        const reach = Math.max(0.08, Number(other.thick) || Number(settings.thick) || 0.2) / 2 + 0.02;

        for (let i = 1; i < op.length; i++) {
          const ab = sub(op[i], op[i - 1]);
          const k = Math.max(0, Math.min(1, dot(sub(q, op[i - 1]), ab) / (dot(ab, ab) || 1e-9)));

          if (len(sub(q, add(op[i - 1], mul(ab, k)))) < reach) return true;
        }

        return false;
      });
    };
    const freeSkirt = function (wall, start, d, length, z) {
      if (wall.skirting !== undefined && wall.skirting !== null) return wall.skirting || "";

      const probe = add(add(start, mul(d, length / 2)), mul(left(d), 0.12));
      const room = derived.rooms.find(function (rm) { return rm.level === wall.level && insidePolygon(probe, rm.points); });

      if (room) return room.record.skirting !== undefined && room.record.skirting !== null ? room.record.skirting : skirting;

      return walledIds.has(wall.id) ? "" : skirting;
    };

    (doc.walls || []).forEach(function (wall, wallIndex) {
      const wallFrom = pieces.length;
      const level = levelOf(doc, wall.level);
      const z = Number(level.z) || 0;
      const nextLevel = levelsByZ.find(function (l) { return l.z > z + 0.5; });
      const ownHeight = Number(level.height) || 2.8;
      const height = nextLevel && (doc.walls || []).some(function (w) { return w.level === nextLevel.id; }) ? Math.max(ownHeight, Number(nextLevel.z) - z) : ownHeight;
      const t = Math.max(0.08, Number(wall.thick) || Number(settings.thick) || 0.2);
      const pts = wallPoints(wall);
      const curved = pts.length > 2;
      const total = wallLength(wall);
      const capMat = note(wall.ml || wall.mr || settings.outside || "white");

      ["l", "r"].forEach(function (side) {
        const ranges = (covered[wall.id + ":" + side] || []).sort(function (a, b) { return a[0] - b[0]; });
        const mat = note((side === "l" ? wall.ml : wall.mr) || settings.outside || "white");
        let free = [[0, total]];

        if (curved) free = ranges.length ? [] : [[0, total]];
        else {
          ranges.forEach(function (r) {
            const next = [];

            free.forEach(function (f) {
              if (r[1] <= f[0] || r[0] >= f[1]) next.push(f);
              else {
                if (r[0] > f[0]) next.push([f[0], r[0]]);
                if (r[1] < f[1]) next.push([r[1], f[1]]);
              }
            });
            free = next;
          });
        }

        if (!curved && free.length) {
          const dw = norm(sub(wall.b, wall.a));
          const nrm = mul(left(dw), (side === "l" ? 1 : -1) * (t / 2 + 0.004));
          const hidden = upperUnderExcept(wall.level, wall.id);
          const cut = [];

          free.forEach(function (f) {
            const n = Math.max(1, Math.ceil((f[1] - f[0]) / 0.025));
            let start = null;

            for (let k = 0; k < n; k++) {
              const ua = f[0] + (f[1] - f[0]) * k / n;
              const ub = f[0] + (f[1] - f[0]) * (k + 1) / n;
              const q = add(add(wall.a, mul(dw, (ua + ub) / 2)), nrm);
              const isHidden = hidden(q);

              if (!isHidden && start === null) start = ua;
              if (isHidden && start !== null) { cut.push([start, ua]); start = null; }
            }

            if (start !== null) cut.push([start, f[1]]);
          });
          free = cut.map(function (f) { return [f[0] > 0.001 ? Math.max(0, f[0] - 0.03) : f[0], f[1] < total - 0.001 ? Math.min(total, f[1] + 0.03) : f[1]]; });
        }

        free = free.filter(function (f) { return f[1] - f[0] > 0.05; });

        if (!free.length) return;

        if (!curved) {
          free = free.map(function (f) {
            return [f[0] <= 0.001 ? -joinExt(wall, "a") : f[0], f[1] >= total - 0.001 ? total + joinExt(wall, "b") : f[1]];
          });
        }

        if (curved) {
          let run = 0;
          const order = [];

          for (let i = 1; i < pts.length; i++) order.push(i);
          if (side === "r") order.reverse();

          const dirOf = function (i) { const dd = norm(sub(pts[i], pts[i - 1])); return side === "l" ? dd : mul(dd, -1); };

          order.forEach(function (i, k) {
            const a = pts[i - 1];
            const b = pts[i];
            const dseg = norm(sub(b, a));
            const off = mul(left(dseg), side === "l" ? t / 2 : -t / 2);
            const A = side === "l" ? add(a, off) : add(b, off);
            const d = side === "l" ? dseg : mul(dseg, -1);
            const segLen = len(sub(b, a));
            const other = order[k + 1] !== undefined ? dirOf(order[k + 1]) : order[k - 1] !== undefined ? dirOf(order[k - 1]) : d;
            const forward = order[k + 1] !== undefined;
            const turn = forward ? Math.atan2(d[0] * other[1] - d[1] * other[0], dot(d, other)) : Math.atan2(other[0] * d[1] - other[1] * d[0], dot(other, d));

            const keepCols = faceCols;
            const turnOf = function (d1, d2) { return Math.atan2(d1[0] * d2[1] - d1[1] * d2[0], dot(d1, d2)); };
            const awayAt = function (q) {
              for (const other of doc.walls || []) {
                if (other === wall || other.level !== wall.level) continue;

                const op = wallPoints(other);

                if (len(sub(op[0], q)) < 0.01) return norm(sub(op[1], q));
                if (len(sub(op[op.length - 1], q)) < 0.01) return norm(sub(op[op.length - 2], q));
              }

              return null;
            };
            const startPt = side === "l" ? a : b;
            const endPt = side === "l" ? b : a;
            const awayIn = order[k - 1] === undefined ? awayAt(startPt) : null;
            const awayOut = order[k + 1] === undefined ? awayAt(endPt) : null;
            const turnIn = order[k - 1] !== undefined ? turnOf(dirOf(order[k - 1]), d) : awayIn ? turnOf(mul(awayIn, -1), d) : 0;
            const turnOut = order[k + 1] !== undefined ? turnOf(d, dirOf(order[k + 1])) : awayOut ? turnOf(d, awayOut) : 0;
            const extA = turnIn < -0.001 ? t / 2 * Math.tan(-turnIn / 2) : 0;
            const extB = turnOut < -0.001 ? t / 2 * Math.tan(-turnOut / 2) : 0;

            if (derived.rooms.some(function (rm) { return rm.edges.some(function (e) { return e.wall === wall.id; }); })) faceCols = null;
            curveMode = true;
            curveBend = turn * 180 / Math.PI;
            emitFace(pieces, mat, A, d, z, -extA, segLen + extB, 0, height, prefix, run % 4);
            curveMode = false;
            curveBend = 0;
            faceCols = keepCols;
            run += segLen;
          });

          return;
        }

        const dw = norm(sub(wall.b, wall.a));
        const off = mul(left(dw), side === "l" ? t / 2 : -t / 2);
        const A = side === "l" ? add(wall.a, off) : add(wall.b, off);
        const d = side === "l" ? dw : mul(dw, -1);
        const holes = derived.openings.filter(function (o) { return o.wall === wall.id && !o.fake; }).map(function (o) {
          const c = side === "l" ? o.t : total - o.t;

          return { u0: c - o.width / 2, u1: c + o.width / 2, z0: o.z0, z1: o.z1 };
        });
        const regions = paintsOf(wall, side, A, d);

        free.forEach(function (f) {
          const fa = side === "l" ? f[0] : total - f[1];
          const fb = side === "l" ? f[1] : total - f[0];
          const start = add(A, mul(d, fa));
          const local = holes.map(function (h) { return { u0: h.u0 - fa, u1: h.u1 - fa, z0: h.z0, z1: h.z1 }; }).filter(function (h) { return h.u1 > 0 && h.u0 < fb - fa; });
          const localRegions = regions.map(function (r) { return { u0: r.u0 - fa, u1: r.u1 - fa, z0: r.z0, z1: r.z1, m: r.m }; });

          emitStrips(pieces, mat, localRegions, start, d, z, fb - fa, height, local, prefix, note, 0, 0, { cover: frames ? 0.05 : 0 });

          const skirtMat = freeSkirt(wall, start, d, fb - fa, z);

          if (skirtMat) {
            const skirtH = Math.max(0.04, Math.min(0.3, Number(settings.skirtH) || 0.1));
            const lone = !walledIds.has(wall.id);
            const atA = lone && fa <= 0.001 - joinExt(wall, side === "l" ? "a" : "b") && !wallJoins(wall, side === "l" ? wall.a : wall.b);
            const atB = lone && fb >= total - 0.001 + joinExt(wall, side === "l" ? "b" : "a") && !wallJoins(wall, side === "l" ? wall.b : wall.a);
            const u0 = atA ? -SKIRT_DEPTH : 0;
            const u1 = fb - fa + (atB ? SKIRT_DEPTH : 0);
            let from = u0;

            local.filter(function (h) { return h.z0 < skirtH + 0.01; }).sort(function (a, b) { return a.u0 - b.u0; }).concat([{ u0: u1, u1: u1 }]).forEach(function (h) {
              const to = Math.min(u1, h.u0);

              if (to - from > 0.03) {
                boxPiece(pieces, prefix, note(skirtMat), add(add(start, mul(d, from)), mul(left(d), 0.001)), d, to - from, SKIRT_DEPTH, z + 0.001, skirtH - 0.001);
                pieces[pieces.length - 1].tag = "mould";
              }

              from = Math.max(from, h.u1);
            });

            if (atB && side === "l") {
              const end = add(wall.b, mul(left(dw), t / 2 + SKIRT_DEPTH));

              boxPiece(pieces, prefix, note(skirtMat), add(end, mul(dw, 0.001)), mul(left(dw), -1), t + 2 * SKIRT_DEPTH, SKIRT_DEPTH, z + 0.001, skirtH - 0.001);
              pieces[pieces.length - 1].tag = "mould";
            }

            if (atB && side === "r") {
              const end = add(wall.a, mul(left(dw), -t / 2 - SKIRT_DEPTH));

              boxPiece(pieces, prefix, note(skirtMat), add(end, mul(dw, -0.001)), left(dw), t + 2 * SKIRT_DEPTH, SKIRT_DEPTH, z + 0.001, skirtH - 0.001);
              pieces[pieces.length - 1].tag = "mould";
            }
          }
        });
      });

      const ceilingRoom = derived.rooms.find(function (r) { return r.level === wall.level && r.edges.some(function (e) { return e.wall === wall.id; }) && r.record.ceilingOff !== true && !r.openAbove; });

      if (curved) {
        for (let i = 1; i < pts.length; i += 2) {
          const a = pts[i - 1];
          const b = pts[Math.min(pts.length - 1, i + 1)];
          const dseg = norm(sub(b, a));
          const mid = pts[i];
          const chordMid = mul(add(a, b), 0.5);
          const sag = len(sub(mid, chordMid));

          const pushCol = function (p0, p1) { const dd = norm(sub(p1, p0)); colliders.push({ origin: [p0[0], p0[1], z], pitch: 0, yaw: yaw(dd), roll: 0, x0: -0.02, x1: len(sub(p1, p0)) + 0.02, y0: -0.05, z0: 0, z1: Math.min(height, 2.4) }); };

          if (b === mid || sag >= t / 2 - 0.02) {
            pushCol(a, mid);
            if (b !== mid) pushCol(mid, b);
          } else {
            pushCol(a, b);
          }
        }
      }

      for (let i = 1; i < pts.length; i++) {
        const a = pts[i - 1];
        const b = pts[i];
        const dseg = norm(sub(b, a));


        const turnAt = function (p0, p1, p2) { const u = norm(sub(p1, p0)); const v = norm(sub(p2, p1)); return Math.abs(Math.atan2(u[0] * v[1] - u[1] * v[0], dot(u, v))); };
        const capA = pts.length === 2 ? joinExt(wall, "a") : i > 1 ? t / 2 * Math.tan(turnAt(pts[i - 2], a, b) / 2) + 0.002 : 0;
        const capB = pts.length === 2 ? joinExt(wall, "b") : i < pts.length - 1 ? t / 2 * Math.tan(turnAt(a, b, pts[i + 1]) / 2) + 0.002 : 0;
        const capLift = 0.001 * (wallIndex % 5) + (pts.length > 2 ? 0.0012 * (i % 2) : 0);

        const reaches = nextLevel && height >= Number(nextLevel.z) - z - 0.01;
        const midSeg = mul(add(a, b), 0.5);
        const sideIn = function (sg) { const q = add(midSeg, mul(left(dseg), sg * (t / 2 + 0.05))); return derived.rooms.some(function (r) { return r.level === nextLevel.id && insidePolygon(q, r.points); }); };
        const coveredAbove = reaches && (upperUnder(nextLevel.id)(midSeg) || sideIn(1) && sideIn(-1));

        if (!coveredAbove) emitTrim(pieces, prefix, capMat, add(add(a, mul(dseg, -capA)), mul(left(dseg), t / 2)).concat([z + height - (height > ownHeight + 0.01 ? 0.03 : 0) + capLift]), 90, yaw(dseg), len(sub(b, a)) + capA + capB, t, true);

        if (reaches) {
          const cutAt = round(Number(nextLevel.z) - 0.03, 3);
          const from = pieces.length;

          emitTrim(pieces, prefix, capMat, add(add(a, mul(dseg, -capA)), mul(left(dseg), t / 2)).concat([cutAt - 0.012 + capLift]), 90, yaw(dseg), len(sub(b, a)) + capA + capB, t, true);

          for (let k = from; k < pieces.length; k++) {
            while (pieces[k].length < 13) pieces[k].push(pieces[k].length === 6 || pieces[k].length === 7 || pieces[k].length === 9 ? 1 : pieces[k].length === 11 ? null : 0);
            pieces[k][13] = cutAt;
            pieces[k][10] = 1;
            pieces[k].noCol = true;
          }
        }
      }

      markBelow(pieces, wallFrom, z);
    });

    let roofTop = 0;

    roofed.forEach(function (rf, levelId) {
      const level = levelOf(doc, levelId);
      const first = derived.rooms.find(function (r) { return r.level === levelId; });
      const inside = rf.inside || (first ? materialOf(doc, first, "ceiling", "ceil") : "ceil");
      const gableIn = note(first ? materialOf(doc, first, "walls", "white") : "white");

      const roofFrom = pieces.length;

      roofTop = Math.max(roofTop, emitRoof(pieces, prefix, note, doc, level, rf, inside, gableIn));

      for (let i = roofFrom; i < pieces.length; i++) pieces[i].tag = "roof";
      markAbove(pieces, roofFrom, (Number(level.z) || 0) + (Number(level.height) || 2.8) + 2.0);
    });

    derived.ends.forEach(function (end) {
      const wall = (doc.walls || []).find(function (w) { return w.id === end.wall; });

      if (!wall) return;

      const level = levelOf(doc, wall.level);
      const t = Math.max(0.08, Number(wall.thick) || Number(settings.thick) || 0.2);
      const pts = wallPoints(wall);
      const d = end.end === "a" ? norm(sub(pts[1], pts[0])) : norm(sub(pts[pts.length - 1], pts[pts.length - 2]));
      const p = end.end === "a" ? pts[0] : pts[pts.length - 1];
      const u = end.end === "a" ? left(d) : mul(left(d), -1);
      const origin = end.end === "a" ? add(p, mul(left(d), -t / 2)) : add(p, mul(left(d), t / 2));

      emitTrim(pieces, prefix, note(wall.ml || wall.mr || settings.outside || "white"), origin.concat([Number(level.z) || 0]), 0, yaw(u), t, Number(level.height) || 2.8);
    });

    const casingRoom = function (o, fw) {
      const u = dot(o.c, o.d);
      let before = Infinity;
      let after = Infinity;

      derived.openings.forEach(function (other) {
        if (other === o || other.wall !== o.wall || other.level !== o.level) return;
        if (Math.min(other.z1, o.z1) - Math.max(other.z0, o.z0) < -0.1) return;

        const ou = dot(other.c, o.d);
        const half = other.width / 2;

        if (ou < u) before = Math.min(before, (u - o.width / 2) - (ou + half));
        else after = Math.min(after, (ou - half) - (u + o.width / 2));
      });

      return [Math.max(0, Math.min(fw, before / 2)), Math.max(0, Math.min(fw, after / 2))];
    };

    const backdrops = [];

    const sourceOpening = function (id) { return (doc.openings || []).find(function (x) { return x.id === id; }); };
    const sideWalkable = function (o, sign) {
      const lvZ = Number(levelOf(doc, o.level).z) || 0;
      const q = add(o.c, mul(o.n, sign * (o.depth / 2 + 0.6)));

      return derived.rooms.some(function (r) { return r.level === o.level && insidePolygon(q, r.points); }) || derived.details.some(function (det) {
        return det.points && OUTDOOR_FLOORS.indexOf(det.kind) >= 0 && Math.abs((Number(det.z) || 0) - lvZ) < 0.6 && insidePolygon(q, det.points);
      }) || derived.pools.some(function (p) { return Math.abs(p.z - lvZ) < 0.6 && insidePolygon(q, p.points); });
    };
    const bothSidesWalkable = function (o) { return sideWalkable(o, 1) && sideWalkable(o, -1); };
    const outsideWalkable = function (o) {
      const lvZ = Number(levelOf(doc, o.level).z) || 0;

      return [1, -1].some(function (sign) {
        const q = add(o.c, mul(o.n, sign * (o.depth / 2 + 0.6)));

        if (derived.rooms.some(function (r) { return r.level === o.level && insidePolygon(q, r.points); })) return false;

        return derived.details.some(function (det) {
          return det.points && OUTDOOR_FLOORS.indexOf(det.kind) >= 0 && Math.abs((Number(det.z) || 0) - lvZ) < 0.6 && insidePolygon(q, det.points);
        }) || derived.pools.some(function (p) { return Math.abs(p.z - lvZ) < 0.6 && insidePolygon(q, p.points); });
      });
    };

    derived.openings.forEach(function (o) {
      const level = levelOf(doc, o.level);
      const z = Number(level.z) || 0;
      const D = o.depth;
      const w = o.width;
      const h = o.z1 - o.z0;
      const firstRoom = roomById.get(o.rooms[0]);
      const lining = o.trim === "none" ? "" : o.trim || frames || "white";
      const revealMat = note(o.frame || ((DOOR_KINDS[o.kind] || o.kind === "slider" || o.shape === "arch" || o.shape === "round" || o.kind === "garage") && lining ? lining : firstRoom ? materialOf(doc, firstRoom, "walls", "white") : "white"));
      const floorMat = firstRoom ? materialOf(doc, firstRoom, "floor", "oak") : "oak";
      const c = o.c;
      const d = o.d;
      const n = o.n;
      const L = add(c, mul(d, -w / 2));
      const R = add(c, mul(d, w / 2));
      const roomTop = firstRoom ? firstRoom.height : 2.8;

      const sideRoom = function (sideSign) {
        for (const id of o.rooms) {
          const room = roomById.get(id);

          if (room && room.edges.some(function (e) { return e.wall === o.wall && (sideSign > 0 ? e.side === "l" : e.side === "r"); })) return room;
        }

        return null;
      };
      const sideMat = function (sideSign) {
        const room = sideRoom(sideSign);
        const wallRec = (doc.walls || []).find(function (x) { return x.id === o.wall; }) || {};
        const own = sideSign > 0 ? wallRec.ml : wallRec.mr;
        const zMid = (o.z0 + o.z1) / 2;
        let painted = null;

        (Array.isArray(wallRec.paints) ? wallRec.paints : []).forEach(function (r) {
          if (!r || !r.m || r.side !== (sideSign > 0 ? "l" : "r")) return;

          const a = Math.min(Number(r.a), Number(r.b));
          const b = Math.max(Number(r.a), Number(r.b));
          const z0 = Math.max(0, Number(r.z0) || 0);
          const z1 = Number(r.z1) > 0 ? Number(r.z1) : 99;

          if (o.t > a && o.t < b && zMid > z0 && zMid < z1) painted = r.m;
        });

        return note(painted || own || (room ? materialOf(doc, room, "walls", "white") : settings.outside || "white"));
      };
      const frameMat = lining;
      const shaped = o.shape === "arch" || o.shape === "round";
      const ringOf = function (m) {
        if (!m) return "white";
        if (RING_MATERIALS.indexOf(m) >= 0) return m;

        const base = baseMat(m);

        if (RING_MATERIALS.indexOf(base) >= 0) return base;

        const hex = /^s[1-6]$/.test(base) ? String((doc.colours || {})[base] || "") : "";
        const want = /^#?[0-9a-f]{6}$/i.test(hex) ? [parseInt(hex.replace("#", "").slice(0, 2), 16), parseInt(hex.replace("#", "").slice(2, 4), 16), parseInt(hex.replace("#", "").slice(4, 6), 16)] : ((kit && kit.backing && kit.backing.colours) || {})[base];

        if (!want) return "white";

        let best = "white";
        let bestScore = Infinity;

        RING_MATERIALS.forEach(function (r) {
          const c = ((kit && kit.backing && kit.backing.colours) || {})[r];

          if (!c) return;

          const score = (c[0] - want[0]) * (c[0] - want[0]) + (c[1] - want[1]) * (c[1] - want[1]) + (c[2] - want[2]) * (c[2] - want[2]);

          if (score < bestScore) { bestScore = score; best = r; }
        });

        return best;
      };

      if (o.fake) {
        const leaf = kitDoor(kit, o.door || "panels6_white");

        if (leaf) {
          [1, -1].forEach(function (sideSign) {
            if (!sideRoom(sideSign)) return;

            const at = add(add(c, mul(d, o.flip ? -leaf.along : leaf.along)), mul(n, sideSign * (D / 2 + (leaf.thickness || 0.05) / 2 + 0.006)));

            pieces.push([leaf.model, round(at[0]), round(at[1]), round(z + o.z0 + leaf.lift), 0, round((((yaw(d) + (o.flip ? 0 : 180)) % 360) + 360) % 360, 2)]);
          });
        }
      } else if (o.shape === "round") {
        emitTrim(pieces, prefix, note(floorMat === revealMat ? revealMat : revealMat), add(L, mul(n, D / 2)).concat([z + o.z0 - 0.002]), 90, yaw(d), w, D);
      } else {
        const sideH = o.shape === "arch" ? Math.max(0.05, h - w / 2) : h;

        emitTrim(pieces, prefix, revealMat, add(L, mul(n, D / 2)).concat([z + o.z0]), 0, yaw(mul(n, -1)), D, sideH);
        emitTrim(pieces, prefix, revealMat, add(R, mul(n, -D / 2)).concat([z + o.z0]), 0, yaw(n), D, sideH);

        if (o.z1 < roomTop - 0.01 && o.shape !== "arch") emitTrim(pieces, prefix, revealMat, add(L, mul(n, -D / 2)).concat([z + o.z1]), -90, yaw(d), w, D);
        const sideA = sideRoom(1);
        const sideB = sideRoom(-1);
        const seamless = sideA && sideB && materialOf(doc, sideA, "floor", "oak") === floorMat && materialOf(doc, sideB, "floor", "oak") === floorMat && !isPlain(floorMat);

        if (o.z0 > 0.01) emitTrim(pieces, prefix, revealMat, add(L, mul(n, D / 2)).concat([z + o.z0]), 90, yaw(d), w, D);
        else {
          emitTrim(pieces, prefix, note(floorMat), add(L, mul(n, D / 2 + 0.025)).concat([z + (seamless ? 0.0008 : 0.011)]), 90, yaw(d), w, D + 0.05);
          if (!seamless) emitTrim(pieces, prefix, note(floorMat), add(L, mul(n, D / 2 + 0.06)).concat([z - 0.004]), 90, yaw(d), w, D + 0.12);
        }
      }

      const fills = kit && kit.archfill ? kit.archfill : null;
      const filled = {};

      if (shaped && !o.fake && fills) {
        const kind = o.shape === "round" ? "round" : "arch";
        const set = fills[kind] || [];
        const base = set.find(function (b) { return b.size >= w - 1e-6; }) || set[set.length - 1];
        const spring = o.shape === "round" ? 0 : h - w / 2;

        [1, -1].forEach(function (sideSign) {
          const own = sideMat(sideSign);
          const mat = own;

          if (!base || (fills.materials && fills.materials.indexOf(baseMat(mat)) < 0)) return;

          const off = mul(n, sideSign * (D / 2 + 0.0004));
          const dir = sideSign > 0 ? d : mul(d, -1);
          const start = sideSign > 0 ? add(L, off) : add(R, off);
          const k = w / base.size;

          pieces.push([prefix + kind + "fill_" + mat + "_" + base.code, round(start[0]), round(start[1]), round(z + o.z0 + spring), 0, round(yaw(dir), 2), round(k, 4), round(k, 4)]);
          filled[sideSign] = true;

          if (mat !== own && (sideRoom(sideSign) || o.exterior)) {
            const edge = 0.045;
            const lift = mul(n, sideSign * (D / 2 + 0.003));
            const from = add(sideSign > 0 ? L : R, lift);
            const left = add(from, mul(dir, -edge));
            const right = add(from, mul(dir, w));
            const top = o.shape === "round" ? h : spring + w / 2;
            const bottom = o.shape === "round" ? -edge : spring;

            const lap = 0.012;

            emitTrim(pieces, prefix, mat, left.concat([z + o.z0 + bottom]), 0, yaw(dir), edge + lap, top + edge - bottom);
            emitTrim(pieces, prefix, mat, add(right, mul(dir, -lap)).concat([z + o.z0 + bottom]), 0, yaw(dir), edge + lap, top + edge - bottom);
            emitTrim(pieces, prefix, mat, from.concat([z + o.z0 + top - lap]), 0, yaw(dir), w, edge + lap);
            if (o.shape === "round") emitTrim(pieces, prefix, mat, from.concat([z + o.z0 - edge]), 0, yaw(dir), w, edge + lap);
          }
        });
      }

      if (shaped && !o.fake) {
        const steps = 20;
        const r = w / 2;
        const spring = o.shape === "round" ? h / 2 : h - r;

        for (let i = 0; i < steps; i++) {
          const x0 = r * (1 - Math.cos(Math.PI * i / steps));
          const x1 = r * (1 - Math.cos(Math.PI * (i + 1) / steps));
          const xm = (x0 + x1) / 2 - r;
          const arc = Math.sqrt(Math.max(0, r * r - xm * xm));
          const top = Math.min(h, spring + arc);
          const bottom = o.shape === "round" ? Math.max(0, spring - arc) : 0;

          [1, -1].forEach(function (sideSign) {
            if (filled[sideSign]) return;

            const mat = sideMat(sideSign);
            const off = mul(n, sideSign * (D / 2 + 0.0004));
            const dir = sideSign > 0 ? d : mul(d, -1);
            const start = sideSign > 0 ? add(add(L, mul(d, x0)), off) : add(add(L, mul(d, x1)), off);

            if (h - top > 0.004) emitTrim(pieces, prefix, mat, start.concat([z + o.z0 + top]), 0, yaw(dir), x1 - x0, h - top);
            if (bottom > 0.004) emitTrim(pieces, prefix, mat, start.concat([z + o.z0]), 0, yaw(dir), x1 - x0, bottom);
          });
        }

        const tubeMat = ringOf(frameMat);

        if (o.shape === "round") pieces.push([prefix + "tube_" + tubeMat, round(L[0]), round(L[1]), round(z + o.z0), 0, round(yaw(d), 2), round(w, 4), round(h, 4), 0, round(D + 0.004, 4)]);
        else pieces.push([prefix + "halftube_" + tubeMat, round(L[0]), round(L[1]), round(z + o.z0 + spring - w / 2), 0, round(yaw(d), 2), round(w, 4), round(w, 4), 0, round(D + 0.004, 4)]);
      }

      if (shaped && !o.fake) {
        const ringMat = ringOf(frameMat);
        const r = w / 2;
        const spring = o.shape === "round" ? h / 2 : h - r;

        [1, -1].forEach(function (sideSign) {
          if (!sideRoom(sideSign) && !o.exterior) return;

          const off = mul(n, sideSign * (D / 2 + 0.006));
          const dir = sideSign > 0 ? d : mul(d, -1);
          const start = sideSign > 0 ? add(L, off) : add(R, off);
          const grow = 0.09;

          if (o.shape === "round") {
            pieces.push([prefix + "ring_" + ringMat, round(add(start, mul(dir, -grow / 2))[0]), round(add(start, mul(dir, -grow / 2))[1]), round(z + o.z0 - grow / 2), 0, round(yaw(dir), 2), round(w + grow, 4), round(h + grow, 4)]);
          } else {
            const at = add(start, mul(dir, -grow / 2));

            pieces.push([prefix + "halfring_" + ringMat, round(at[0]), round(at[1]), round(z + o.z0 + spring - (w + grow) / 2), 0, round(yaw(dir), 2), round(w + grow, 4), round(w + grow, 4)]);
            const band = 0.09 * (w + grow);

            emitTrim(pieces, prefix, note(ringMat), add(start, mul(dir, -grow / 2)).concat([z + o.z0]), 0, yaw(dir), band, spring);
            emitTrim(pieces, prefix, note(ringMat), add(start, mul(dir, w + grow / 2 - band)).concat([z + o.z0]), 0, yaw(dir), band, spring);
          }
        });
      }

      if (frameMat && o.kind !== "half" && o.kind !== "wide" && !shaped) {
        const fw = o.trimw || 0.07;
        const frames = note(frameMat);
        const room = casingRoom(o, fw);
        const cd = CASING_DEPTH;
        const head = o.z1 < roomTop - 0.07 ? Math.min(fw, roomTop - o.z1 - 0.01) : 0;
        const sill = o.z0 > 0.07 ? Math.min(fw, o.z0 - 0.01) : 0;

        [1, -1].forEach(function (sideSign) {
          if (!o.exterior || o.rooms.length && roomById.get(o.rooms[0]).edges.some(function (e) { return e.wall === o.wall && (sideSign > 0 ? e.side === "l" : e.side === "r"); })) {
            const face = mul(n, sideSign * (D / 2 + 0.0005));
            const dir = sideSign > 0 ? d : mul(d, -1);
            const start = add(sideSign > 0 ? L : R, face);
            const end = add(sideSign > 0 ? R : L, face);
            const wa = sideSign > 0 ? room[0] : room[1];
            const wb = sideSign > 0 ? room[1] : room[0];

            if (wa > 0.005) boxPiece(pieces, prefix, frames, add(start, mul(dir, -wa)), dir, wa, cd, z + o.z0, h + head);
            if (wb > 0.005) boxPiece(pieces, prefix, frames, end, dir, wb, cd, z + o.z0, h + head);
            if (head > 0.005) boxPiece(pieces, prefix, frames, start, dir, w, cd, z + o.z1, head);
            if (sill > 0.005) boxPiece(pieces, prefix, frames, add(start, mul(dir, -wa - 0.02)), dir, w + wa + wb + 0.04, cd + 0.025, z + o.z0 - sill, sill);
          }
        });
      }

      const glassKey = (kit && kit.glass || []).some(function (g) { return g.key === o.glass; }) ? o.glass : "glass";
      const isWindow = WINDOW_KINDS.indexOf(o.kind) >= 0;

      if (o.kind === "slider" && o.glass !== "none") {
        const half = w / 2 + 0.03;
        const sm = note(frameMat || "steel");
        const fr = function (x0, x1, z0, z1) {
          const pts = [add(add(L, mul(d, x0)), mul(n, -0.04)), add(add(L, mul(d, x1)), mul(n, -0.04)), add(add(L, mul(d, x1)), mul(n, 0.04)), add(add(L, mul(d, x0)), mul(n, 0.04))];

          emitBox(pieces, prefix, function (k) { return k; }, pts, z + o.z0 + z0, z + o.z0 + z1, sm, sm, sm);
        };

        fr(0, 0.05, 0, h);
        fr(w - 0.05, w, 0, h);
        fr(0.05, w - 0.05, h - 0.05, h);
        fr(0.05, half, 0, 0.04);

        emitGlass(pieces, prefix, glassKey, L, d, z + o.z0, half, h);
        [1, -1].forEach(function (sideSign) {
          const off = mul(n, sideSign * 0.03);
          const dir = sideSign > 0 ? d : mul(d, -1);
          const at = sideSign > 0 ? add(add(L, mul(d, half - 0.05)), off) : add(add(L, mul(d, half)), off);

          emitTrim(pieces, prefix, note(frameMat || "steel"), at.concat([z + o.z0]), 0, yaw(dir), 0.05, h);
        });
      } else if (o.glass && o.glass !== "none" && (isWindow || o.glass === "glass" || o.glass === "frosted")) {
        emitGlass(pieces, prefix, glassKey, L, d, z + o.z0, w, h);
      }

      if (isWindow && o.kind !== "slider" && frameMat && !o.fake && o.glass !== "none") {
        const sash = note(frameMat);
        const fw2 = Math.max(0.035, Math.min(0.08, (o.trimw || 0.06) * 0.9));
        const half = 0.04;
        const box = function (x0, x1, z0, z1, skip, ends) {
          const pts = [add(add(L, mul(d, x0)), mul(n, -half)), add(add(L, mul(d, x1)), mul(n, -half)), add(add(L, mul(d, x1)), mul(n, half)), add(add(L, mul(d, x0)), mul(n, half))];

          emitBox(pieces, prefix, function (k) { return k; }, pts, z + o.z0 + z0, z + o.z0 + z1, sash, ends === true || ends === "high" ? null : sash, ends === true || ends === "low" ? null : sash, skip);
        };

        if (shaped) {
          if (o.sash === true) {
            const ringMat = ringOf(frameMat);
            const r = w / 2;
            const spring = o.shape === "round" ? h / 2 : h - r;

            [1, -1].forEach(function (sideSign) {
              const off = mul(n, sideSign * 0.042);
              const dir = sideSign > 0 ? d : mul(d, -1);
              const start = sideSign > 0 ? add(L, off) : add(R, off);
              const g = -0.02;

              if (o.shape === "round") pieces.push([prefix + "ring_" + ringMat, round(add(start, mul(dir, g))[0]), round(add(start, mul(dir, g))[1]), round(z + o.z0 + g), 0, round(yaw(dir), 2), round(w - 2 * g, 4), round(h - 2 * g, 4)]);
              else pieces.push([prefix + "halfring_" + ringMat, round(add(start, mul(dir, g))[0]), round(add(start, mul(dir, g))[1]), round(z + o.z0 + spring - (w - 2 * g) / 2), 0, round(yaw(dir), 2), round(w - 2 * g, 4), round(w - 2 * g, 4)]);
            });

            if (o.shape === "arch") {
              box(0, fw2, 0, spring);
              box(w - fw2, w, 0, spring);
              box(0, w, 0, fw2);
            }
          }
        } else {
          box(0, fw2, 0, h, [3], true);
          box(w - fw2, w, 0, h, [1], true);
          box(fw2, w - fw2, 0, fw2, [1, 3], "low");
          box(fw2, w - fw2, h - fw2, h, [1, 3], "high");
        }
      }

      if (isWindow && o.kind !== "slider" && o.bars !== "none" && !o.fake) {
        const bw = 0.035;
        const barMat = note(frameMat || "white");
        const vertical = o.bars === "cross" || o.bars === "vertical" ? [0.5] : o.bars === "grid" ? [1 / 3, 2 / 3] : [];
        const horizontal = o.bars === "cross" || o.bars === "horizontal" ? [0.5] : o.bars === "grid" ? [0.5] : o.bars === "transom" ? [0.72] : [];

        [1, -1].forEach(function (sideSign) {
          const off = mul(n, sideSign * 0.014);
          const dir = sideSign > 0 ? d : mul(d, -1);

          vertical.forEach(function (f) {
            const x = w * f;
            const at = sideSign > 0 ? add(add(L, mul(d, x - bw / 2)), off) : add(add(L, mul(d, x + bw / 2)), off);

            emitTrim(pieces, prefix, barMat, at.concat([z + o.z0]), 0, yaw(dir), bw, h);
          });
          horizontal.forEach(function (f) {
            const at = sideSign > 0 ? add(L, off) : add(add(L, mul(d, w)), off);

            emitTrim(pieces, prefix, barMat, at.concat([z + o.z0 + h * f - bw / 2]), 0, yaw(dir), w, bw);
          });
        });
      }

      if (isWindow && o.sillMat && o.sillMat !== "none" && o.z0 > 0.2) {
        const sm = note(o.sillMat);

        [1, -1].forEach(function (sideSign) {
          if (!sideRoom(sideSign) && !o.exterior) return;

          const out = sideSign > 0 ? n : mul(n, -1);
          const topStart = sideSign > 0 ? add(add(R, mul(d, 0.05)), mul(n, D / 2)) : add(add(L, mul(d, -0.05)), mul(n, -D / 2));
          const topDir = sideSign > 0 ? mul(d, -1) : d;
          const frontStart = sideSign > 0 ? add(add(L, mul(d, -0.05)), mul(out, D / 2 + 0.07)) : add(add(R, mul(d, 0.05)), mul(out, D / 2 + 0.07));
          const frontDir = sideSign > 0 ? d : mul(d, -1);

          emitTrim(pieces, prefix, sm, topStart.concat([z + o.z0 + 0.03]), 90, yaw(topDir), w + 0.1, 0.07);
          emitTrim(pieces, prefix, sm, frontStart.concat([z + o.z0 - 0.01]), 0, yaw(frontDir), w + 0.1, 0.04);
        });
      }

      if (isWindow && o.shade && kit && kit.blinds && o.rooms.length) {
        const style = kit.blinds.styles.find(function (b) { return b.key === o.shade; });
        const room = roomById.get(o.rooms[0]);
        const edge = room ? room.edges.find(function (e) { return e.wall === o.wall; }) : null;

        if (style && edge) {
          const along = norm(sub(edge.b, edge.a));
          const inward = left(along);
          const bw = w + 0.12;
          const drop = Math.max(0.2, (h + 0.08) * Math.max(0.15, Math.min(1, Number(o.shadeDrop) || 0.6)));
          const base = kit.blinds.sizes.find(function (b) { return b[0] >= bw - 1e-6 && b[1] >= drop - 1e-6; }) || kit.blinds.sizes[kit.blinds.sizes.length - 1];
          const at = add(add(c, mul(inward, D / 2 + 0.045)), mul(along, -bw / 2));

          pieces.push([prefix + "blind_" + style.key + "_" + base[2], round(at[0]), round(at[1]), round(z + o.z1 + 0.08), 0, round(yaw(along), 2), round(bw / base[0], 4), round(drop / base[1], 4)]);
        }
      }

      if (o.exterior && o.rooms.length && isWindow) {
        const view = o.view === undefined ? settings.view : o.view;

        if (view && view !== "none") {
          const room = roomById.get(o.rooms[0]);
          const edge = room.edges.find(function (e) { return e.wall === o.wall; });
          const inward = edge ? left(norm(sub(edge.b, edge.a))) : n;
          const across = [inward[1], -inward[0]];
          const centre = add(c, mul(inward, -(D / 2 + 1.4)));

          backdrops.push({ key: o.wall + ":" + view + ":" + round(inward[0], 2) + ":" + round(inward[1], 2), view: view, across: across, centre: centre, u: dot(centre, across), w: w + 2.4, z0: z + o.z0 - 0.8, z1: z + o.z0 + h + 0.8 });
        }
      }

      if (o.kind === "garage" && o.garage && o.garage !== "none" && kit && Array.isArray(kit.garages)) {
        const options = kit.garages.filter(function (g) { return g.style === o.garage; });
        const pick = options.slice().sort(function (a, b) { return Math.abs(a.width - w) + Math.abs(a.height - h) - Math.abs(b.width - w) - Math.abs(b.height - h); })[0];

        if (pick) doors.push({ model: pick.model, x: round(c[0]), y: round(c[1]), z: round(z + o.z0), h: round(((yaw(d) % 360) + 360) % 360, 2), id: o.id, garage: true, sx: round(w / pick.width, 4), sz: round(h / pick.height, 4), height: round(h, 3) });
      }

      if (DOOR_KINDS[o.kind] && o.door) {
        const leaf = kitDoor(kit, o.door);

        if (leaf) {
          const base = yaw(d);
          const leaves = DOOR_KINDS[o.kind] === 2 ? [[w / 2 - 0.012, 180], [-(w / 2 - 0.012), 0]] : [[o.flip ? -leaf.along : leaf.along, o.flip ? 0 : 180]];

          leaves.forEach(function (entry) {
            const at = add(c, mul(d, entry[0]));
            const heading = base + entry[1] + (o.swing ? 0 : 0);

            const mode = (sourceOpening(o.id) || {}).use || "auto";
            const fixed = mode === "fixed" || (mode !== "open" && (o.exterior === true ? !outsideWalkable(o) : !bothSidesWalkable(o)));

            doors.push({ model: leaf.model, x: round(at[0]), y: round(at[1]), z: round(z + o.z0 + leaf.lift + Math.max(0, Math.min(0.009, (o.z1 - o.z0) - (leaf.height || 2.078) - 0.013))), h: round(((heading % 360) + 360) % 360, 2), id: o.id, swing: o.swing, locked: fixed, fixed: fixed || undefined });
          });
        }
      }
    });

    const viewSizes = kit && Array.isArray(kit.viewSizes) ? kit.viewSizes : null;
    const groups = new Map();

    backdrops.forEach(function (b) {
      if (!groups.has(b.key)) groups.set(b.key, []);
      groups.get(b.key).push(b);
    });

    groups.forEach(function (list) {
      list.sort(function (x, y) { return (x.u - x.w / 2) - (y.u - y.w / 2); });

      const clusters = [];

      list.forEach(function (b) {
        const last = clusters[clusters.length - 1];
        const ua = b.u - b.w / 2;
        const ub = b.u + b.w / 2;

        if (last && ua <= last.ub + 0.3) {
          last.ub = Math.max(last.ub, ub);
          last.z0 = Math.min(last.z0, b.z0);
          last.z1 = Math.max(last.z1, b.z1);
        } else {
          clusters.push({ ua: ua, ub: ub, z0: b.z0, z1: b.z1, ref: b });
        }
      });

      clusters.forEach(function (cl) {
        const b = cl.ref;
        const at = add(b.centre, mul(b.across, cl.ua - b.u));
        const vw = cl.ub - cl.ua;
        const vh = cl.z1 - cl.z0;
        const base = viewSizes ? viewSizes.find(function (sz) { return sz[0] >= vw - 1e-6 && sz[1] >= vh - 1e-6; }) : null;

        if (base) pieces.push([prefix + "view_" + b.view + "_" + base[2], round(at[0]), round(at[1]), round(cl.z0), 0, round(yaw(b.across), 2), round(vw / base[0], 4), round(vh / base[1], 4)]);
        else pieces.push([prefix + "view_" + b.view, round(at[0]), round(at[1]), round(cl.z0), 0, round(yaw(b.across), 2), round(vw, 3), round(vh, 3)]);
      });
    });

    derived.stairs.forEach(function (s) {
      const mat = (kit && (kit.steps || []).some(function (x) { return x.material === s.material; })) ? s.material : "oak";

      if (s.spiral) {
        const sp = s.spiral;
        const size = sp.radius === 0.8 ? "a" : sp.radius === 1 ? "b" : "c";

        const reachScale = function (turnAt) {
          if (!sp.square) return 1;

          let reach = 0;

          for (let a = 0; a <= sp.angle + 1e-6; a += sp.angle / 12) {
            const r = (turnAt + a) * Math.PI / 180;
            const dir = [Math.cos(r), Math.sin(r)];

            reach = Math.max(reach, sp.square.half / Math.max(Math.abs(dot(dir, sp.square.ax)), Math.abs(dot(dir, sp.square.ay)), 1e-6));
          }

          return Math.max(1, round((reach + 0.04) / sp.radius, 4));
        };
        const flatTreads = [];

        for (let k = 0; k < sp.count; k++) {
          const turnAt = sp.sign > 0 ? sp.start + k * sp.angle : sp.start - (k + 1) * sp.angle;
          const grow = k === sp.count - 1 ? reachScale(turnAt) : 1;

          if (grow > 1.001) {
            flatTreads.push({ turnAt: turnAt, scale: grow });
            continue;
          }

          pieces.push([prefix + "spiral_" + mat + "_" + size, round(sp.centre[0]), round(sp.centre[1]), round(s.z + (k + 1) * sp.stepRise), 0, round(((turnAt % 360) + 360) % 360, 2)]);
        }

        pieces.push([prefix + "spiral_pole", round(sp.centre[0]), round(sp.centre[1]), round(s.z), 0, 0, 1, round(s.rise + 1.0, 3)]);

        const topZ = s.z + s.rise;

        for (let k = 0; k < 2; k++) flatTreads.push({ turnAt: sp.sign > 0 ? sp.start + (sp.count + k) * sp.angle : sp.start - (sp.count + k + 1) * sp.angle });

        flatTreads.forEach(function (entry, flatIndex) {
          const turnAt = entry.turnAt;
          const landScale = entry.scale || reachScale(turnAt);
          const landZ = topZ - 0.02 - 0.004 * flatIndex;
          const land = [prefix + "spiral_" + mat + "_" + size, round(sp.centre[0]), round(sp.centre[1]), round(landZ, 4), 0, round(((turnAt % 360) + 360) % 360, 2), landScale, 1, 0, landScale];

          land.noCol = true;
          pieces.push(land);

          const m = (turnAt + sp.angle / 2) * Math.PI / 180;
          const radial = [Math.cos(m), Math.sin(m)];
          const t = [-Math.sin(m), Math.cos(m)];
          const outer = sp.radius * landScale - 0.03;
          const half = Math.tan(sp.angle * Math.PI / 360);
          const bands = entry.scale ? [[0.2, 0.3], [0.3, 0.4], [0.4, 0.5], [0.5, 0.6], [0.6, 0.7], [0.7, 0.8], [0.8, 0.9]] : [[0.3, 0.5], [0.5, 0.7], [0.7, 0.9]];

          for (let r = 0.9; r < outer - 0.02; r += 0.25) bands.push([r, Math.min(outer, r + 0.25 > outer - 0.08 ? outer : r + 0.25)]);

          bands.forEach(function (band) {
            if (band[1] - band[0] < 0.05) return;

            const wide = entry.scale ? 2 * band[0] * half + 0.01 : (band[0] + band[1]) * half + 0.03;
            const start = add(add(sp.centre, mul(radial, band[0])), mul(t, -wide / 2));

            colliders.push({ origin: [start[0], start[1], landZ], pitch: 90, yaw: yaw(t), roll: 0, x0: 0, x1: wide, y0: -0.1, z0: 0, z1: band[1] - band[0], ramp: true });
          });
        });

        if (s.rail) {
          const railMat = s.material === "steel" ? "blackm" : "steel";
          const tops = [];

          const lastStep = sp.count - 1;

          for (let k = 0; k < lastStep; k++) {
            const turnAt = sp.sign > 0 ? sp.start + k * sp.angle : sp.start - (k + 1) * sp.angle;
            const angle = (turnAt + 12.5) * Math.PI / 180;
            const at = add(sp.centre, [Math.cos(angle) * (sp.radius - 0.06), Math.sin(angle) * (sp.radius - 0.06)]);
            const z = s.z + (k + 1) * sp.stepRise;

            pieces.push([prefix + "post_" + railMat, round(at[0]), round(at[1]), round(z), 0, 0, 1, 0.92]);
            tops.push([at[0], at[1], z + 0.9]);
          }

          if (lastStep > 0) {
            const prevAt = sp.sign > 0 ? sp.start + (lastStep - 1) * sp.angle : sp.start - lastStep * sp.angle;
            const edgeDeg = sp.sign > 0 ? prevAt + sp.angle - 1.5 : prevAt + 1.5;
            const angle = edgeDeg * Math.PI / 180;
            const at = add(sp.centre, [Math.cos(angle) * (sp.radius - 0.06), Math.sin(angle) * (sp.radius - 0.06)]);
            const z = s.z + lastStep * sp.stepRise;

            pieces.push([prefix + "post_" + railMat, round(at[0]), round(at[1]), round(z), 0, 0, 1, round(0.92 + sp.stepRise * 0.5, 4)]);
            tops.push([at[0], at[1], z + 0.9 + sp.stepRise * 0.5]);
          }

          for (let k = 0; k + 1 < tops.length; k++) {
            const a = tops[k];
            const b = tops[k + 1];
            const chord = Math.hypot(b[0] - a[0], b[1] - a[1]);

            if (chord > 0.01) barPiece(pieces, prefix, railMat, [a[0], a[1]], a[2], [b[0], b[1]], b[2]);
          }

          if (tops.length) spiralEnds.push({ end: tops[tops.length - 1], floor: topZ, mat: railMat, centre: sp.centre, radius: sp.radius });
        }
      }

      if (s.closed) {
        const supportKey = "white";
        const supportMat = note(supportKey);
        const from = pieces.length;
        const walls = [];
        const plate = function (a, d, length, height) { if (length > 0.05 && height > 0.05) walls.push({ a: a, d: d, length: length, height: height }); };

        s.flights.forEach(function (flight, index) {
          const fw = flight.width || s.width;
          const half = fw / 2;
          const last = index === s.flights.length - 1 || s.type === "grand" && index > 0;
          const bottomOf = function (k) { return (flight.first + k + 1) * s.stepRise - 0.2; };
          let blockFrom = -1;

          for (let k = 0; k < flight.count; k++) {
            if (blockFrom < 0 && bottomOf(k) >= 1.0) blockFrom = k;
          }

          const ext0 = flight.first > 0 ? 0.03 : 0;
          const ext1 = last ? 0.02 : 0.03;
          const run = flight.count * s.stepRun + ext0 + ext1;
          const inner = 0.018;
          const corner = sub(sub(flight.at, mul(flight.fwd, ext0)), mul(left(flight.fwd), half - inner));
          const base = flight.first * s.stepRise;

          if (base > 0.01) boxPiece(pieces, prefix, supportKey, corner, flight.fwd, run, fw - 2 * inner, s.z, base);

          const seam = function (u, height) {
            if (height < 0.05) return;

            [-1, 1].forEach(function (sign) {
              const off = sign * (half - 0.012);
              const w0 = sign > 0 ? off : off - 0.004;
              const at = add(add(flight.at, mul(flight.fwd, u - 0.025)), mul(left(flight.fwd), w0));

              boxPiece(pieces, prefix, supportKey, at, flight.fwd, 0.05, 0.004, s.z, height);
            });
          };

          if (flight.first > 0) seam(0, base - 0.2);
          if (!last) seam(flight.count * s.stepRun, (flight.first + flight.count) * s.stepRise - 0.2);
          prismPiece(pieces, prefix, supportKey, corner, flight.fwd, run, fw - 2 * inner, s.z + base, flight.count * s.stepRise - 0.004);
          if (blockFrom >= 0) {
            const start = add(flight.at, mul(flight.fwd, blockFrom * s.stepRun));
            const length = (flight.count - blockFrom) * s.stepRun + (last ? 0.02 : 0);

            plate(add(start, mul(flight.side, -half)), flight.fwd, length, 1.0);
            plate(add(add(start, mul(flight.fwd, length)), mul(flight.side, half)), mul(flight.fwd, -1), length, 1.0);

            if (last) plate(add(add(start, mul(flight.fwd, length)), mul(flight.side, -half)), flight.side, fw, 1.0);
          }
        });

        s.landings.forEach(function (landing) {
          const h = landing.top - 0.2;
          const p = landing.points;

          if (h < 0.02) return;

          {
            const ex = norm(sub(p[1], p[0]));
            const ey = norm(sub(p[3], p[0]));
            const inner = 0.012;

            boxPiece(pieces, prefix, supportKey, add(add(p[0], mul(ex, inner)), mul(ey, inner)), ex, len(sub(p[1], p[0])) - 2 * inner, len(sub(p[3], p[0])) - 2 * inner, s.z, h - 0.003);
          }

          for (let i = 0; i < 4; i++) {
            const a = p[(i + 1) % 4];
            const b = p[i];

            plate(a, norm(sub(b, a)), len(sub(b, a)), Math.min(1.0, h));
          }
        });

        for (let i = from; i < pieces.length; i++) pieces[i].noCol = true;

        walls.forEach(function (w) {
          colliders.push({ origin: [w.a[0], w.a[1], s.z], pitch: 0, yaw: yaw(w.d), roll: 0, x0: 0, x1: w.length, y0: -0.1, z0: 0, z1: w.height });
        });
      }

      s.flights.forEach(function (flight) {
        for (let k = 0; k < flight.count; k++) {
          stepRow(pieces, prefix, mat, add(add(flight.at, mul(flight.fwd, k * s.stepRun)), mul(flight.side, k % 2 ? 0.002 : 0)), flight.fwd, flight.side, flight.width || s.width, s.z + (flight.first + k + 1) * s.stepRise);
        }

        if (flight.count > 0 && s.stepRun > 0.05) {
          const run = flight.count * s.stepRun;
          const rise = flight.count * s.stepRise;
          const alpha = Math.atan2(rise, run);
          const fw = (flight.width || s.width) / 2 - 0.04;
          const start = add(flight.at, mul(flight.fwd, -0.5 * s.stepRun));
          const sideV = [flight.fwd[1], -flight.fwd[0]];

          colliders.push({ origin: [start[0], start[1], s.z + flight.first * s.stepRise], pitch: alpha * 180 / Math.PI - 90, yaw: yaw(sideV), roll: 0, x0: -fw, x1: fw, y0: 0, z0: 0, z1: Math.hypot(run, rise) * (flight.count + 0.45) / flight.count, ramp: true });

          const halfW = (flight.width || s.width) / 2;
          const gaps = wallGaps(s.level, flight.at, flight.fwd, flight.side, halfW, 0, run);

          s.flights.forEach(function (other) {
            if (other === flight || Math.abs(dot(other.fwd, flight.fwd)) < 0.99) return;

            const c = dot(sub(other.at, flight.at), flight.side);
            const h2 = (other.width || s.width) / 2;

            [1, -1].forEach(function (sign) {
              if (sign * c > 0 && sign * c - h2 < halfW + 0.35) gaps[sign] = null;
            });
          });
          const stringerMat = note(settings.skirting || "white");
          const theta = Math.atan2(s.stepRise, s.stepRun);
          const ts = -0.3;
          const te = (flight.count - 0.5) * s.stepRun;
          const hgt = 0.28;
          const length = (te - ts) / Math.cos(theta);
          const big = bigBoxKit && length > 1.0001 && bigBoxKit.materials.indexOf(baseMat(stringerMat)) >= 0 ? bigBoxKit.size : 1;

          [1, -1].forEach(function (sign) {
            const gap = gaps[sign];

            if (gap === null) return;

            colliders.push({ origin: [start[0], start[1], s.z + flight.first * s.stepRise], pitch: alpha * 180 / Math.PI - 90, yaw: yaw(sideV), roll: 0, x0: sign > 0 ? fw : -(halfW + gap), x1: sign > 0 ? halfW + gap : -fw, y0: 0, z0: 0, z1: Math.hypot(run, rise) * (flight.count + 0.45) / flight.count, ramp: true });

            const lateral = sign > 0 ? halfW + gap + 0.01 : -(halfW - 0.01);
            const topZ = s.z + (flight.first + 1) * s.stepRise + ts * Math.tan(theta) + 0.03;
            const base = add(add(flight.at, mul(flight.fwd, ts + Math.sin(theta) * hgt)), mul(flight.side, lateral));
            const piece = [prefix + "box_" + stringerMat + (big > 1 ? "_b" : ""), round(base[0]), round(base[1]), round(topZ - Math.cos(theta) * hgt), 0, round(yaw(flight.fwd), 2), round(length / big, 5), round(hgt / big, 5), round(-theta * 180 / Math.PI, 3), round((gap + 0.02) / big, 5)];

            piece.noCol = true;
            if (!s.floating) pieces.push(piece);
          });

          if (s.type !== "spiral" && !s.closed && !s.floating) {
            const boardMat = note(mat);
            const halfW = (flight.width || s.width) / 2;
            const ang = Math.atan2(s.stepRise, s.stepRun);
            const tall = 0.2;
            const thick = 0.04;
            const length = Math.max(0.1, flight.count * s.stepRun / Math.cos(ang) - tall * Math.tan(ang) - 0.04);
            const ax = axesOf(0, -ang * 180 / Math.PI, yaw(flight.fwd));
            const base0 = add(flight.at, mul(flight.fwd, 0.02));
            const z0 = s.z + flight.first * s.stepRise + s.stepRise - 0.06 - 0.02 * Math.tan(ang);

            [-1, 1].forEach(function (sign) {
              const sideAt = add(base0, mul(flight.side, sign * (halfW + 0.004 + (sign > 0 ? 0 : thick))));
              const o = [sideAt[0] + ax[2][0] * -tall, sideAt[1] + ax[2][1] * -tall, z0 + ax[2][2] * -tall];
              const yOff = dot(left(flight.fwd), flight.side) > 0 ? 0 : -thick;

              pieces.push([prefix + "box_" + boardMat, round(o[0] + left(flight.fwd)[0] * yOff), round(o[1] + left(flight.fwd)[1] * yOff), round(o[2]), 0, round(yaw(flight.fwd), 2), round(length, 4), round(tall, 4), round(-ang * 180 / Math.PI, 2), round(thick, 4)]);
              noCollide(pieces[pieces.length - 1]);
            });
          }
        }
      });

      s.landings.forEach(function (landing) {
        const lp = landing.points;
        const ex = norm(sub(lp[1], lp[0]));
        const ey = sub(lp[3], lp[0]);
        const W = len(sub(lp[1], lp[0]));
        const D = len(ey);

        if (W < 0.05 || D < 0.05) return;

        const at = dot(left(ex), ey) > 0 ? lp[3] : lp[0];

        colliders.push({ origin: [at[0], at[1], s.z + landing.top], pitch: 90, yaw: yaw(ex), roll: 0, x0: 0, x1: W, y0: -0.1, z0: 0, z1: D, ramp: true });
      });

      if (s.spiral) {
        const sp = s.spiral;
        const th = sp.angle * Math.PI / 180;
        const R = sp.radius - 0.02;
        const rw = sp.radius * 0.62;
        const rIn = Math.max(0.14, rw - 0.26);
        const L = R * th + 0.06;
        const tanA = sp.stepRise / (rw * th);
        const alpha = Math.atan(tanA);

        for (let k = 0; k < sp.count; k++) {
          const turnAt = sp.sign > 0 ? sp.start + k * sp.angle : sp.start - (k + 1) * sp.angle;
          const m = (turnAt + sp.angle / 2) * Math.PI / 180;
          const radial = [Math.cos(m), Math.sin(m)];
          const t = sp.sign > 0 ? [-Math.sin(m), Math.cos(m)] : [Math.sin(m), -Math.cos(m)];
          const sideV = [t[1], -t[0]];
          const centre = add(sp.centre, mul(radial, rw));
          const origin = add(centre, mul(t, -L / 2));
          const outward = dot(sideV, radial) > 0;
          const zTop = s.z + (k + 1) * sp.stepRise;

          colliders.push({ origin: [origin[0], origin[1], zTop - (L / 2) * tanA], pitch: alpha * 180 / Math.PI - 90, yaw: yaw(sideV), roll: 0, x0: outward ? rIn - rw : rw - R, x1: outward ? R - rw : rw - rIn, y0: 0, z0: 0, z1: L / Math.cos(alpha), ramp: true, tight: true });
        }
      }

      s.landings.forEach(function (landing) {
        const top = s.z + landing.top;

        emitBox(pieces, prefix, note, landing.points, top - 0.2, top, mat, mat, s.closed ? null : mat);

        const gaps = wallGaps(s.level, landing.at, landing.fwd, landing.side, landing.width / 2, 0, landing.depth);

        [1, -1].forEach(function (sign) {
          const gap = gaps[sign];

          if (gap === null) return;

          const inner = sign > 0 ? landing.width / 2 : -(landing.width / 2 + gap + 0.01);
          const p0 = add(landing.at, mul(landing.side, inner));
          const p1 = add(p0, mul(landing.side, gap + 0.01));
          const p2 = add(p1, mul(landing.fwd, landing.depth));
          const p3 = add(p0, mul(landing.fwd, landing.depth));

          emitBox(pieces, prefix, note, [p0, p1, p2, p3], top - 0.2, top, mat, mat, s.closed ? null : mat);
          colliders.push({ origin: [p3[0], p3[1], top], pitch: 90, yaw: yaw(landing.side), roll: 0, x0: 0, x1: gap + 0.02, y0: -0.1, z0: 0, z1: landing.depth, ramp: true });
        });
      });

      const top = levelOf(doc, s.top);
      const holes = derived.holes.filter(function (h) { return h.stair === s.id; });
      const lowLevel = levelOf(doc, s.level);
      const lowTop = (Number(lowLevel.z) || 0) + (Number(lowLevel.height) || 2.8);

      const openSpans = function (hole, a, b) {
        const dir = sub(b, a);
        const length = len(dir);

        if (length < 0.02) return [];

        const off = mul(right(norm(dir)), 0.03);
        const pa = add(a, off);
        const ts = [0, 1];

        holes.forEach(function (other) {
          if (other === hole) return;

          const pts = other.points;

          for (let i = 0; i < pts.length; i++) {
            const c = pts[i];
            const e = sub(pts[(i + 1) % pts.length], c);
            const den = dir[0] * e[1] - dir[1] * e[0];

            if (Math.abs(den) < 1e-9) continue;

            const w = sub(c, pa);
            const t = (w[0] * e[1] - w[1] * e[0]) / den;
            const u = (w[0] * dir[1] - w[1] * dir[0]) / den;

            if (t > 0 && t < 1 && u >= -1e-6 && u <= 1 + 1e-6) ts.push(t);
          }
        });
        ts.sort(function (x, y) { return x - y; });

        const out = [];
        let start = null;
        let end = null;

        for (let k = 0; k + 1 < ts.length; k++) {
          const t0 = ts[k];
          const t1 = ts[k + 1];

          if (t1 - t0 < 1e-6) continue;

          const mid = add(pa, mul(dir, (t0 + t1) / 2));
          const free = !holes.some(function (other) { return other !== hole && insidePolygon(mid, other.points); });

          if (free) {
            if (start === null) start = t0;
            end = t1;
          } else if (start !== null) {
            if ((end - start) * length > 0.05) out.push([add(a, mul(dir, start)), add(a, mul(dir, end))]);
            start = null;
          }
        }

        if (start !== null && (end - start) * length > 0.05) out.push([add(a, mul(dir, start)), add(a, mul(dir, end))]);

        return out;
      };

      holes.forEach(function (hole) {
        const p = hole.points;

        for (let i = 0; i < p.length; i++) {
          const ea = p[i];
          const eb = p[(i + 1) % p.length];

          [].concat.apply([], openSpans(hole, ea, eb).map(function (span) { return unwalledSpans(doc, lowLevel.id, span[0], span[1]); })).forEach(function (raw) {
            const unit = norm(sub(raw[1], raw[0]));
            const span = [add(raw[0], mul(unit, -0.03)), add(raw[1], mul(unit, 0.03))];
            const dir = sub(span[1], span[0]);

            if (dot(dir, unit) < 0.02) return;

            if ((Number(top.z) || 0) - lowTop > 0.01) {
              const keepCols = faceCols;

              faceCols = null;
              const fromPiece = pieces.length;

              const sp = s.spiral;
              const underTread = function (q) {
                if (!sp) return false;

                const d = ((Math.atan2(q[1] - sp.centre[1], q[0] - sp.centre[0]) * 180 / Math.PI - sp.exit) % 360 + 540) % 360 - 180;

                return d >= Math.min(sp.landing, -sp.sign * sp.angle) - 1 && d <= Math.max(sp.landing, -sp.sign * sp.angle) + 1;
              };
              const parts = [];
              const steps = Math.max(1, Math.ceil(len(dir) / 0.05));

              for (let k = 0; k < steps; k++) {
                const covered = underTread(add(span[0], mul(dir, (k + 0.5) / steps)));
                const last = parts[parts.length - 1];

                if (last && last.covered === covered) last.t1 = (k + 1) / steps;
                else parts.push({ t0: k / steps, t1: (k + 1) / steps, covered: covered });
              }

              parts.forEach(function (part) {
                const from = add(span[0], mul(dir, part.t0));
                const high = (Number(top.z) || 0) - (part.covered ? 0.04 : -0.003);

                if (high - lowTop > 0.01) emitFace(pieces, note("white"), add(from, mul(left(norm(dir)), 0.005)), norm(dir), lowTop - 0.004, 0, len(dir) * (part.t1 - part.t0), 0, high - lowTop + 0.004, prefix);
              });
              markAbove(pieces, fromPiece, Number(top.z) || 0);
              faceCols = keepCols;
            }
          });
        }
      });

      if (s.rail) {
        const railMat = s.material === "steel" ? "blackm" : "steel";
        const topZ = Number(top.z) || 0;
        const posts = [];
        const upperWalls = (doc.walls || []).filter(function (w) { return w.level === s.top && wallPoints(w).length === 2; });
        const nearWall = function (q, pad) {
          return upperWalls.some(function (w) {
            const wd = sub(w.b, w.a);
            const wl2 = dot(wd, wd);

            if (wl2 < 1e-6) return false;

            const t = dot(sub(q, w.a), wd) / wl2;

            if (t < -0.02 || t > 1.02) return false;

            const near = add(w.a, mul(wd, Math.max(0, Math.min(1, t))));

            return len(sub(q, near)) < Math.max(0.08, Number(w.thick) || Number(settings.thick) || 0.2) / 2 + pad;
          });
        };
        const railSpans = function (a, b) {
          const dir = sub(b, a);
          const length = len(dir);
          const n = Math.max(2, Math.ceil(length / 0.02));
          const out = [];
          let start = null;

          for (let k = 0; k <= n; k++) {
            const t = k / n;
            const free = !nearWall(add(a, mul(dir, t)), 0.06);

            if (free && start === null) start = t;
            if ((!free || k === n) && start !== null) {
              const end = free ? t : (k - 1) / n;

              if ((end - start) * length > 0.12) out.push([add(a, mul(dir, start)), add(a, mul(dir, end))]);
              start = null;
            }
          }

          return out;
        };
        const postAt = function (q, z) {
          if (posts.some(function (o) { return Math.abs(o.z - z) < 0.25 && len(sub(o.p, q)) < 0.2; })) return;
          if (nearWall(q, 0.02)) return;
          posts.push({ p: q, z: z, guard: true });
          pieces.push([prefix + "post_" + railMat, round(q[0]), round(q[1]), round(z), 0, 0, 1, 0.92]);
        };
        const newelAt = function (q, base, top) {
          const h = top - base + 0.02;

          if (h < 0.3) return;
          if (posts.some(function (o) { return (Math.abs(o.z - base) < 0.25 && len(sub(o.p, q)) < 0.06) || (o.guard && Math.abs(o.z - base) < 0.05 && len(sub(o.p, q)) < 0.25); })) return;
          if (nearWall(q, 0.02)) return;
          posts.push({ p: q, z: base });
          pieces.push([prefix + "post_" + railMat, round(q[0]), round(q[1]), round(base), 0, 0, 1, round(h, 4)]);
        };
        const barAt = function (a, az, b, bz) {
          if (len(sub(b, a)) < 0.02) return;
          barPiece(pieces, prefix, railMat, a, az, b, bz);
        };
        const runLine = function (points) {
          points.forEach(function (pt) { postAt(pt.p, pt.z); });

          let from = 0;

          for (let i = 1; i < points.length; i++) {
            const next = points[i + 1];
            const a = points[from];
            const b = points[i];
            const da = [b.p[0] - a.p[0], b.p[1] - a.p[1], b.z - a.z];
            const keep = next && (function () {
              const db = [next.p[0] - b.p[0], next.p[1] - b.p[1], next.z - b.z];
              const la = Math.hypot(da[0], da[1], da[2]);
              const lb = Math.hypot(db[0], db[1], db[2]);

              return la > 0.001 && lb > 0.001 && (da[0] * db[0] + da[1] * db[1] + da[2] * db[2]) / (la * lb) > 0.999;
            })();

            if (keep) continue;

            barAt(a.p, a.z + 0.9, b.p, b.z + 0.9);
            from = i;
          }
        };
        const hit = function (p, d, q, e) {
          const den = d[0] * e[1] - d[1] * e[0];

          if (Math.abs(den) < 1e-6) return null;

          const t = ((q[0] - p[0]) * e[1] - (q[1] - p[1]) * e[0]) / den;

          return add(p, mul(d, t));
        };
        const lineOf = function (f, sign, t) { return add(add(f.at, mul(f.side, sign * ((f.width || s.width) / 2 - 0.05))), mul(f.fwd, t)); };
        const byWallEarly = function (q) {
          return (doc.walls || []).some(function (w) {
            if (!(w.level === s.level || w.level === s.top) || !w.a || !w.b) return false;

            const wd = sub(w.b, w.a);
            const wl2 = dot(wd, wd);

            if (wl2 < 1e-6) return false;

            const t = dot(sub(q, w.a), wd) / wl2;

            if (t < -0.02 || t > 1.02) return false;

            return len(sub(q, add(w.a, mul(wd, Math.max(0, Math.min(1, t)))))) < Math.max(0.08, Number(w.thick) || Number(settings.thick) || 0.2) / 2 + 0.35;
          });
        };
        const flightPoints = function (f, sign) {
          const out = [];
          const ks = [];

          for (let k = 0; k < f.count; k += 3) ks.push(k);
          if (ks[ks.length - 1] !== f.count - 1) ks.push(f.count - 1);
          ks.forEach(function (k) { out.push({ p: lineOf(f, sign, (k + 0.5) * s.stepRun), z: s.z + (f.first + k + 1) * s.stepRise }); });

          return out;
        };
        const f1 = s.flights[0];
        const f2 = s.flights[1];
        const main = holes.find(function (h) { return h.open >= 0; });
        const openA = main ? main.points[main.open] : null;
        const openB = main ? main.points[(main.open + 1) % main.points.length] : null;
        const sideWalls = (doc.walls || []).filter(function (w) { return (w.level === s.level || w.level === s.top) && wallPoints(w).length === 2; });
        const byWall = function (q) {
          return sideWalls.some(function (w) {
            const wd = sub(w.b, w.a);
            const wl2 = dot(wd, wd);

            if (wl2 < 1e-6) return false;

            const t = dot(sub(q, w.a), wd) / wl2;

            if (t < -0.02 || t > 1.02) return false;

            return len(sub(q, add(w.a, mul(wd, Math.max(0, Math.min(1, t)))))) < Math.max(0.08, Number(w.thick) || Number(settings.thick) || 0.2) / 2 + 0.35;
          });
        };
        const guards = [];
        const topRooms = derived.rooms.filter(function (r) { return r.level === s.top && r.points && r.points.length > 2; });

        holes.forEach(function (hole) {
          const p = hole.points;

          for (let i = 0; i < p.length; i++) {
            if (i === hole.open || (hole.quiet || []).indexOf(i) >= 0) continue;

            openSpans(hole, p[i], p[(i + 1) % p.length]).forEach(function (open) {
              railSpans(open[0], open[1]).forEach(function (span) {
                const dir = sub(span[1], span[0]);
                const length = len(dir);
                const out = right(norm(dir));
                const n = Math.max(2, Math.ceil(length / 0.1));
                let start = null;

                for (let k = 0; k <= n; k++) {
                  const q = add(add(span[0], mul(dir, k / n)), mul(out, 0.15));
                  const floor = topRooms.some(function (r) { return insidePolygon(q, r.points); });

                  if (floor && start === null) start = k / n;
                  if ((!floor || k === n) && start !== null) {
                    const end = floor ? k / n : (k - 1) / n;

                    if ((end - start) * length > 0.12) guards.push(start === 0 && end === 1 ? span : [add(span[0], mul(dir, start)), add(span[0], mul(dir, end))]);
                    start = null;
                  }
                }
              });
            });
          }
        });

        const ends = [];

        guards.forEach(function (g) { ends.push(g[0], g[1]); });
        ends.forEach(function (q) {
          const group = ends.filter(function (o) { return len(sub(o, q)) < 0.12; });

          if (group.length < 2) return;

          const mid = mul(group.reduce(function (acc, o) { return add(acc, o); }, [0, 0]), 1 / group.length);

          group.forEach(function (o) { o[0] = mid[0]; o[1] = mid[1]; });
        });

        guards.forEach(function (span) {
          const a = span[0];
          const b = span[1];
          const dir = sub(b, a);
          const count = Math.max(1, Math.ceil(len(dir) / 1.6));

          const over = function (q) {
            return s.flights.some(function (f) {
              return [1, -1].some(function (sign) {
                const w = (f.width || s.width) / 2;
                const v = dot(sub(q, f.at), f.side) * sign;
                const u = dot(sub(q, f.at), f.fwd);

                return Math.abs(dot(norm(dir), f.fwd)) > 0.98 && Math.abs(v - w) < 0.2 && u > -0.1 && u < f.count * s.stepRun + 0.1;
              });
            });
          };
          let hits = 0;

          for (let k = 0; k < 10; k++) if (over(add(a, mul(dir, (k + 0.5) / 10)))) hits++;

          for (let k = 0; k <= count; k++) postAt(add(a, mul(dir, k / count)), topZ);
          barAt(a, topZ + 0.9, b, topZ + 0.9);
          if (hits < 5) barAt(a, topZ + 0.45, b, topZ + 0.45);
        });

        const onGuard = function (q) {
          return guards.some(function (g) {
            const d = sub(g[1], g[0]);
            const l2 = dot(d, d);

            if (l2 < 1e-6) return false;

            const t = Math.max(0, Math.min(1, dot(sub(q, g[0]), d) / l2));

            return len(sub(q, add(g[0], mul(d, t)))) < 0.07;
          });
        };
        const railZ = function (f, t) { return s.z + (f.first + 0.5 + t / s.stepRun) * s.stepRise + 0.9; };
        const treadAt = function (f, t) { return s.z + (f.first + Math.max(0, Math.min(f.count - 1, Math.floor(t / s.stepRun))) + 1) * s.stepRise; };
        const tOf = function (f, q) { return dot(sub(q, f.at), f.fwd); };
        const node = function (q, z, base, out) { return { p: q, z: z, base: base, out: out || null }; };
        const surfaceAt = function (q) {
          let best = null;

          s.flights.forEach(function (f) {
            const u = dot(sub(q, f.at), f.fwd);
            const v = dot(sub(q, f.at), f.side);
            const w = (f.width || s.width) / 2;

            if (u >= 0 && u <= f.count * s.stepRun && Math.abs(v) <= w) {
              const z = treadAt(f, u);

              if (best === null || z > best) best = z;
            }
          });
          s.landings.forEach(function (l) {
            if (l.points && insidePolygon(q, l.points)) {
              const z = s.z + l.top;

              if (best === null || z > best) best = z;
            }
          });

          return best;
        };
        const flightNodes = function (f, sign, from, to) {
          const out = [];
          const t0 = from === undefined ? 0.5 * s.stepRun : from;
          const t1 = to === undefined ? (f.count - 0.5) * s.stepRun : to;

          if (t1 < t0 - 1e-6) return out;

          const n = Math.max(1, Math.round((t1 - t0) / 1.1));

          for (let k = 0; k <= n; k++) {
            const t = t0 + (t1 - t0) * k / n;
            const tc = Math.max(0.5 * s.stepRun, Math.min((f.count - 0.5) * s.stepRun, t));

            out.push(node(lineOf(f, sign, t), railZ(f, t), treadAt(f, tc), mul(f.side, sign)));
          }

          return out;
        };
        const paths = [];

        if (s.type === "grand" && f1 && f2 && s.flights[2]) {
          const landing = s.landings[0];
          const lz = s.z + landing.top;
          const run1 = f1.count * s.stepRun;
          const fars = [];

          [1, -1].forEach(function (sign) { paths.push(flightNodes(f1, sign).concat([node(lineOf(f1, sign, run1), railZ(f1, run1), lz), node(lineOf(f1, sign, run1), lz + 0.9, lz)])); });
          [f2, s.flights[2]].forEach(function (f) {
            const si = dot(f.side, sub(f1.at, f.at)) >= 0 ? 1 : -1;
            const far = lineOf(f, -si, -landing.depth + 0.05);

            fars.push(far);
            paths.push([node(lineOf(f, si, 0), lz + 0.9, lz), node(lineOf(f, si, 0), railZ(f, 0), lz)].concat(flightNodes(f, si)));
            paths.push([node(far, lz + 0.9, lz), node(lineOf(f, -si, 0), lz + 0.9, lz), node(lineOf(f, -si, 0), railZ(f, 0), lz)].concat(flightNodes(f, -si)));
          });
          paths.push([node(fars[0], lz + 0.9, lz), node(fars[1], lz + 0.9, lz)]);
        } else if (f1 && !f2) {
          paths.push(flightNodes(f1, 1), flightNodes(f1, -1));
        } else if (s.type === "landing" && f1 && f2) {
          const lz = s.z + s.landings[0].top;
          const run1 = f1.count * s.stepRun;

          [1, -1].forEach(function (sign) {
            paths.push(flightNodes(f1, sign).concat([node(lineOf(f1, sign, run1), railZ(f1, run1), lz), node(lineOf(f1, sign, run1), lz + 0.9, lz), node(lineOf(f2, sign, 0), lz + 0.9, lz), node(lineOf(f2, sign, 0), railZ(f2, 0), lz)], flightNodes(f2, sign)));
          });
        } else if (f1 && f2) {
          const landing = s.landings[0];
          const lz = s.z + landing.top;
          const s1 = dot(f1.side, sub(f2.at, f1.at)) >= 0 ? 1 : -1;
          const s2 = dot(f2.side, sub(f1.at, f2.at)) >= 0 ? 1 : -1;
          const run1 = f1.count * s.stepRun;

          if (s.type === "l") {
            const corner = hit(lineOf(f1, s1, 0), f1.fwd, lineOf(f2, s2, 0), f2.fwd);
            const outerCorner = hit(lineOf(f1, -s1, 0), f1.fwd, lineOf(f2, -s2, 0), f2.fwd);

            if (corner) {
              const c1 = tOf(f1, corner);
              const c2 = tOf(f2, corner);
              const z1 = railZ(f1, Math.min(c1, run1));
              const z2 = railZ(f2, Math.max(c2, 0));
              const base = treadAt(f1, run1);

              paths.push(flightNodes(f1, s1, 0.5 * s.stepRun, Math.min((f1.count - 0.5) * s.stepRun, c1 - 0.3)).concat([node(corner, z1, base), node(corner, z2, base)], flightNodes(f2, s2, Math.max(0.5 * s.stepRun, c2 + 0.3))));
            }

            if (outerCorner) {
              paths.push(flightNodes(f1, -s1).concat([node(lineOf(f1, -s1, run1), railZ(f1, run1), lz), node(lineOf(f1, -s1, run1), lz + 0.9, lz), node(outerCorner, lz + 0.9, lz), node(lineOf(f2, -s2, 0), lz + 0.9, lz), node(lineOf(f2, -s2, 0), railZ(f2, 0), lz)], flightNodes(f2, -s2)));
            }
          } else {
            const near = lineOf(f1, s1, run1 + 0.05);
            const other = hit(near, f1.side, lineOf(f2, s2, 0), f2.fwd);
            const far = lineOf(f1, -s1, run1 + landing.depth - 0.05);
            const corner = hit(far, f1.side, lineOf(f2, -s2, 0), f2.fwd);
            const inner = flightNodes(f1, s1).concat([node(lineOf(f1, s1, run1), railZ(f1, run1), lz), node(lineOf(f1, s1, run1), lz + 0.9, lz), node(near, lz + 0.9, lz)]);

            if (other) inner.push(node(other, lz + 0.9, lz));
            inner.push(node(lineOf(f2, s2, 0), lz + 0.9, lz), node(lineOf(f2, s2, 0), railZ(f2, 0), lz));
            paths.push(inner.concat(flightNodes(f2, s2)));

            const outer = flightNodes(f1, -s1).concat([node(lineOf(f1, -s1, run1), railZ(f1, run1), lz), node(lineOf(f1, -s1, run1), lz + 0.9, lz), node(far, lz + 0.9, lz)]);

            if (corner) outer.push(node(corner, lz + 0.9, lz));
            outer.push(node(lineOf(f2, -s2, 0), lz + 0.9, lz), node(lineOf(f2, -s2, 0), railZ(f2, 0), lz));
            paths.push(outer.concat(flightNodes(f2, -s2)));
          }
        }

        if (main && s.type === "u" && f1) {
          const mid = mul(add(openA, openB), 0.5);
          const from = len(sub(openA, f1.at)) < len(sub(openB, f1.at)) ? openA : openB;
          const count = Math.max(1, Math.ceil(len(sub(mid, from)) / 1.2));

          for (let i = 0; i <= count; i++) postAt(add(from, mul(sub(mid, from), i / count)), topZ);
          barAt(from, topZ + 0.9, mid, topZ + 0.9);
          barAt(from, topZ + 0.45, mid, topZ + 0.45);
        }

        paths.forEach(function (path) {
          if (path.length < 2) return;

          const end = path[path.length - 1];

          if (main && Math.abs(end.z - 0.9 - topZ) < 0.05) {
            const options = [openA, openB];
            let best = null;

            if (s.type === "u") options.push(mul(add(openA, openB), 0.5));
            options.forEach(function (q) { if (len(sub(q, end.p)) < 0.75 && (!best || len(sub(q, end.p)) < len(sub(best, end.p)))) best = q; });
            if (best && len(sub(best, end.p)) > 0.05 && !onGuard(mul(add(best, end.p), 0.5))) path.push(node(best, topZ + 0.9, topZ));
          }

          const inLine = function (a, b, c) {
            const da = [b.p[0] - a.p[0], b.p[1] - a.p[1], b.z - a.z];
            const db = [c.p[0] - b.p[0], c.p[1] - b.p[1], c.z - b.z];
            const la = Math.hypot(da[0], da[1], da[2]);
            const lb = Math.hypot(db[0], db[1], db[2]);

            return la > 0.001 && lb > 0.001 && (da[0] * db[0] + da[1] * db[1] + da[2] * db[2]) / (la * lb) > 0.9995;
          };

          for (let i = path.length - 2; i >= 1; i--) {
            const n = path[i];
            const next = path[i + 1];

            if (n.out && !next.out && len(sub(next.p, n.p)) > 0.02 && len(sub(next.p, n.p)) < 0.3 && inLine(path[i - 1], n, next)) path.splice(i, 1);
          }
          for (let i = 1; i < path.length - 1; i++) {
            const n = path[i];
            const prev = path[i - 1];

            if (n.out && !prev.out && len(sub(prev.p, n.p)) > 0.02 && len(sub(prev.p, n.p)) < 0.3 && inLine(prev, n, path[i + 1])) { path.splice(i, 1); i--; }
          }

          const last = path[path.length - 1];
          let link = null;

          guards.forEach(function (g) {
            const d = sub(g[1], g[0]);
            const l2 = dot(d, d);

            if (l2 < 1e-6 || Math.abs(last.z - 0.9 - topZ) > 0.05) return;

            const t = Math.max(0, Math.min(1, dot(sub(last.p, g[0]), d) / l2));
            const q = add(g[0], mul(d, t));
            const gap = len(sub(q, last.p));

            if (gap > 0.01 && gap < 0.16 && (!link || gap < len(sub(link, last.p)))) link = q;
          });
          if (link) path.push(Object.assign(node(link, last.z, last.base), { link: true }));

          const keep = [];

          for (let i = 1; i < path.length; i++) {
            const a = path[i - 1];
            const b = path[i];
            const flat = len(sub(b.p, a.p)) < 0.02;
            const out = a.out || b.out;
            const probe = out ? surfaceAt(add(mul(add(a.p, b.p), 0.5), mul(out, 0.2))) : null;
            const walled = (byWall(a.p) && byWall(b.p)) || (probe !== null && probe > Math.min(a.base, b.base) - 0.1);
            const guarded = !flat && !b.link && Math.abs(a.z - b.z) < 0.02 && Math.abs(a.z - 0.9 - topZ) < 0.05 && onGuard(mul(add(a.p, b.p), 0.5));

            keep.push(flat ? null : !walled && !guarded);
          }

          for (let i = 0; i < keep.length; i++) {
            if (keep[i] !== null) continue;

            let before = false;
            let after = false;

            for (let k = i - 1; k >= 0; k--) if (keep[k] !== null) { before = keep[k] === true; break; }
            for (let k = i + 1; k < keep.length; k++) if (keep[k] !== null && keep[k] !== "flat") { after = keep[k] === true; break; }
            keep[i] = before || after ? "flat" : false;
          }
          for (let i = 0; i < keep.length; i++) if (keep[i] === "flat") keep[i] = true;

          const stub = function (order) {
            const first = order.find(function (i) { return keep[i]; });

            if (first === undefined || first === order[0]) return;

            const run = [];
            let length = 0;

            for (let k = order.indexOf(first); k < order.length; k++) {
              const i = order[k];
              const a = path[i];
              const b = path[i + 1];

              if (!keep[i]) break;
              if (len(sub(b.p, a.p)) >= 0.02 && Math.abs(b.z - a.z) > 0.03) {
                if (length < 0.6) run.forEach(function (j) { keep[j] = false; });
                return;
              }

              length += len(sub(b.p, a.p));
              run.push(i);
            }
          };
          const forward = keep.map(function (v, i) { return i; });

          stub(forward);
          stub(forward.slice().reverse());

          const used = path.map(function (n, i) { return (i > 0 && keep[i - 1]) || (i < keep.length && keep[i]); });
          const tops = new Map();

          path.forEach(function (n, i) {
            if (!used[i]) return;

            const key = Math.round(n.p[0] * 50) + "," + Math.round(n.p[1] * 50);
            const was = tops.get(key);

            if (!was) tops.set(key, { p: n.p, base: n.base, top: n.z });
            else { was.top = Math.max(was.top, n.z); was.base = Math.min(was.base, n.base); }
          });
          tops.forEach(function (t) { newelAt(t.p, t.base, t.top); });

          let from = -1;

          for (let i = 1; i < path.length; i++) {
            const a = path[i - 1];
            const b = path[i];

            if (!keep[i - 1] || len(sub(b.p, a.p)) < 0.02) { from = -1; continue; }
            if (from < 0) from = i - 1;

            const next = path[i + 1];
            const straight = next && keep[i] && len(sub(next.p, b.p)) >= 0.02 && (function () {
              const da = [b.p[0] - a.p[0], b.p[1] - a.p[1], b.z - a.z];
              const db = [next.p[0] - b.p[0], next.p[1] - b.p[1], next.z - b.z];
              const la = Math.hypot(da[0], da[1], da[2]);
              const lb = Math.hypot(db[0], db[1], db[2]);

              return (da[0] * db[0] + da[1] * db[1] + da[2] * db[2]) / (la * lb) > 0.9995;
            })();

            if (straight) continue;

            barAt(path[from].p, path[from].z, b.p, b.z);
            from = -1;
          }
        });

        if (s.spiral && main) {
          const sp = s.spiral;
          const rayAt = function (deg) { return [Math.cos(deg * Math.PI / 180), Math.sin(deg * Math.PI / 180)]; };
          const edgeHit = function (dir) {
            const e = sub(openB, openA);
            const den = dir[0] * e[1] - dir[1] * e[0];

            if (Math.abs(den) < 1e-9) return null;

            const w = sub(openA, sp.centre);
            const r = (w[0] * e[1] - w[1] * e[0]) / den;
            const t = (w[0] * dir[1] - w[1] * dir[0]) / den;

            return r > 0 ? t : null;
          };
          const ta = edgeHit(rayAt(sp.exit - sp.sign * sp.angle));
          const tb = edgeHit(rayAt(sp.exit + sp.landing));
          const t0 = Math.max(0, Math.min(1, Math.min(ta === null ? 0 : ta, tb === null ? 1 : tb)));
          const t1 = Math.max(0, Math.min(1, Math.max(ta === null ? 0 : ta, tb === null ? 1 : tb)));
          const edge = sub(openB, openA);
          const railRun = function (a, b) {
            const dir = sub(b, a);

            if (len(dir) < 0.12) return;

            const count = Math.max(1, Math.ceil(len(dir) / 1.6));

            for (let k = 0; k <= count; k++) postAt(add(a, mul(dir, k / count)), topZ);
            barAt(a, topZ + 0.9, b, topZ + 0.9);
            barAt(a, topZ + 0.45, b, topZ + 0.45);
          };

          railSpans(openA, add(openA, mul(edge, t0))).forEach(function (span) { railRun(span[0], span[1]); });
          railSpans(add(openA, mul(edge, t1)), openB).forEach(function (span) { railRun(span[0], span[1]); });

          const far = rayAt(sp.exit + sp.landing);
          const sq = sp.square;
          const fu = dot(far, sq.ax);
          const fv = dot(far, sq.ay);
          const reach = sq.half / Math.max(Math.abs(fu), Math.abs(fv), 1e-6);

          railRun(add(sp.centre, mul(far, 0.12)), add(sp.centre, mul(far, reach - 0.04)));
        }

      }
    });

    derived.pools.forEach(function (pool) {
      const bottom = pool.z - pool.depth;
      const p = pool.points;
      const tile = note(pool.tile);

      for (let i = 0; i < 4; i++) {
        const a = p[i];
        const b = p[(i + 1) % 4];
        const d = norm(sub(b, a));

        emitFace(pieces, tile, a, d, bottom, 0, len(sub(b, a)), 0, pool.depth, prefix);
      }

      const co = 0.3;
      const ci = 0.035;
      const ax = pool.ax;
      const ay = pool.ay;
      const grow = function (k) { return [add(p[0], add(mul(ax, -k), mul(ay, -k))), add(p[1], add(mul(ax, k), mul(ay, -k))), add(p[2], add(mul(ax, k), mul(ay, k))), add(p[3], add(mul(ax, -k), mul(ay, k)))]; };
      const rim = grow(co);
      const lip = grow(-ci);
      const edgeMat = note(pool.edge);
      const top = pool.z + 0.045;
      const under = pool.z - 0.03;

      tileRoom(pieces, prefix, { points: rim, edges: [{ a: rim[0], b: rim[1], length: pool.w + 2 * co }], z: top, height: 0 }, [{ points: lip }], edgeMat, false);
      tileRoom(pieces, prefix, { points: p, edges: [{ a: p[0], b: p[1], length: pool.w }], z: under, height: 0 }, [{ points: lip }], edgeMat, true);

      for (let i = 0; i < 4; i++) {
        const a = lip[i];
        const b = lip[(i + 1) % 4];
        const ra = rim[(i + 1) % 4];
        const rb = rim[i];

        emitFace(pieces, edgeMat, a, norm(sub(b, a)), under, 0, len(sub(b, a)), 0, top - under, prefix);
        emitFace(pieces, edgeMat, ra, norm(sub(rb, ra)), pool.z - 0.01, 0, len(sub(rb, ra)), 0, top - pool.z + 0.01, prefix);
      }

      tileRoom(pieces, prefix, { points: p, edges: [{ a: p[0], b: p[1], length: pool.w }], z: bottom, height: 0 }, [], tile, false);

      if (pool.water) {
        const wc = mul(add(p[0], p[2]), 0.5).concat([pool.z - 0.14]);
        const right = function (v) { return [v[1], -v[0]]; };
        let wd = pool.ax;

        for (let k = 0; k < 4; k++) {
          emitTrim(pieces, prefix, "water", wc, 90, yaw(wd), k % 2 === 0 ? pool.w / 2 : pool.l / 2, k % 2 === 0 ? pool.l / 2 : pool.w / 2);
          wd = right(wd);
        }
      }

      if (pool.ladder) {
        const mid = add(mul(add(p[0], p[1]), 0.5), mul(pool.ay, 0.02));

        pieces.push([prefix + "pool_ladder", round(mid[0]), round(mid[1]), round(pool.z), 0, round(yaw(pool.ax), 2)]);
      }
    });

    derived.holes.filter(function (h) { return h.void; }).forEach(function (hole) {
      const level = levelOf(doc, hole.level);
      const below = hole.below ? levelOf(doc, hole.below) : null;
      const top = Number(level.z) || 0;
      const p = hole.points;
      const levelWalls = (doc.walls || []).filter(function (w) { return w.level === hole.level || (below && w.level === below.id && hole.fascia === false); });

      for (let i = 0; i < p.length; i++) {
        const a = p[i];
        const b = p[(i + 1) % p.length];
        const dir = norm(sub(b, a));
        const length = len(sub(b, a));
        const mid = mul(add(a, b), 0.5);
        const onWall = levelWalls.some(function (w) {
          if (w.level !== hole.level) return false;

          const wd = sub(w.b, w.a);
          const wl = len(wd);

          if (wl < 0.01) return false;

          const t = Math.max(0, Math.min(1, dot(sub(mid, w.a), wd) / (wl * wl)));
          const near = add(w.a, mul(wd, t));

          return len(sub(mid, near)) < (Number(w.thick) || 0.2) / 2 + 0.12 && Math.abs(dot(norm(wd), dir)) > 0.95;
        });

        if (hole.fascia && below) {
          const lowTop = (Number(below.z) || 0) + (Number(below.height) || 2.8);

          if (top - lowTop > 0.01) unwalledSpans(doc, below.id, a, b).forEach(function (raw) {
            const from = add(raw[0], mul(dir, len(sub(raw[0], a)) < 0.01 ? 0.026 : -0.026));
            const to = add(raw[1], mul(dir, len(sub(raw[1], b)) < 0.01 ? -0.026 : 0.026));

            if (dot(sub(to, from), dir) > 0.02) emitFace(pieces, note("white"), add(from, mul(left(dir), 0.026)), dir, lowTop, 0, len(sub(to, from)), 0, top - lowTop, prefix);
          });
        }

        if (hole.hatch && !onWall && length > 0.05) {
          const owner = (doc.details || []).find(function (dd) { return dd.id === hole.void; });
          const frameMat = note(owner && LADDER_WOODS.indexOf(owner.mat) >= 0 ? owner.mat : "steel");
          const centre = mul(p.reduce(function (acc, q) { return add(acc, q); }, [0, 0]), 1 / p.length);
          const inward = dot(sub(centre, mid), left(dir)) > 0;
          const fw = 0.07;
          const ext = 0.012;
          const start = add(a, mul(dir, -ext));
          const span = length + 2 * ext;
          const lip = inward ? add(start, mul(left(dir), -fw)) : start;

          boxPiece(pieces, prefix, frameMat, lip, dir, span, fw, top, 0.022);

          if (below) {
            const lowTop = (Number(below.z) || 0) + (Number(below.height) || 2.8);
            const casing = 0.09;

            if (top - lowTop > 0.01) boxPiece(pieces, prefix, frameMat, inward ? add(start, mul(left(dir), -0.05)) : start, dir, span, 0.05, lowTop - casing, casing);
          }
        }

        if (onWall || hole.rail === "none") continue;

        emitRailing(pieces, prefix, note, a, add(a, mul(dir, length)), top, hole.rail === "metal" ? "metal" : "glass", -1);
      }
    });

    derived.details.forEach(function (source, detIndex) {
      if (source.kind === "void") return;

      const detFrom = pieces.length;

      emitDetail(source, detIndex);

      for (let i = detFrom; i < pieces.length; i++) pieces[i].tag = "det:" + source.id;
    });

    function emitDetail(source, detIndex) {

      const e = ["pillar", "glassrail", "rail", "glasswall", "ladder", "floorpatch"].indexOf(source.kind) >= 0 ? 0 : 0.0012 * (1 + detIndex % 6);
      const full = (DETAILS[source.kind] || {}).h === 0;

      if (source.kind === "floorpatch") source = Object.assign({}, source, { patchLift: 0.003 * (detIndex % 5), cuts: derived.holes.filter(function (h) { return h.level === source.level && h.points && h.points.length > 2; }) });

      const det = e ? Object.assign({}, source, { d: source.d - 2 * e, h: full ? source.h : source.h - e, height: full ? source.height : source.height - e, points: rectOf(source, -source.w / 2, -source.d / 2 + e, source.w / 2, source.d / 2 - e) }) : source;
      const p = det.points;
      const mat = note(det.mat);
      const top = note(det.top);
      const H = det.height;
      const sides = function (z0, z1) {
        for (let i = 0; i < 4; i++) {
          const a = p[(i + 1) % 4];
          const b = p[i];

          emitFace(pieces, mat, a, norm(sub(b, a)), z0, 0, len(sub(b, a)), 0, z1 - z0, prefix);
        }
      };
      const cap = function (z, matKey, down) {
        tileRoom(pieces, prefix, { points: p, edges: [{ a: p[0], b: p[1], length: det.w }], z: z, height: 0 }, [], matKey, down);
      };
      const start = add(det.at, mul(det.ax, -det.w / 2));

      if (det.kind === "elevator") {
        const L = elevatorLayout(det);
        const allZ = (doc.levels || [{ z: 0 }]).map(function (l) { return round(Number(l.z) || 0, 3); }).sort(function (x, y) { return x - y; });
        const stops = allZ.filter(function (z) { return z >= det.z - 0.05; });
        const sorted = (doc.levels || []).slice().sort(function (x, y) { return (Number(x.z) || 0) - (Number(y.z) || 0); });
        const ownLevel = (doc.levels || []).find(function (l) { return l.id === det.level; }) || { height: 2.8 };
        const room = derived.rooms.find(function (r) { return Math.abs((Number(r.z) || 0) - det.z) < 0.3 && insidePolygon(det.at, r.points); });
        const outerMat = note(det.wall || (room && room.record && room.record.walls) || "white");
        const innerMat = note("concdark");
        const P = function (x, y) { return add(add(det.at, mul(det.ax, x)), mul(det.ay, y)); };
        const hw = det.w / 2;
        const hd = det.d / 2;
        const T = L.T;
        const iw = hw - T;
        const id = hd - T;
        const dh = L.door / 2;

        stops.forEach(function (z, i) {
          const above = sorted.filter(function (l) { return Math.abs((Number(l.z) || 0) - z) < 0.05; })[0] || ownLevel;
          const H = (i < stops.length - 1 ? stops[i + 1] : z + (Number(above.height) || 2.8)) - z;
          const top = Math.min(H, L.doorH);

          emitFace(pieces, outerMat, P(hw, -hd), mul(det.ax, -1), z, 0, hw - dh, 0, H, prefix);
          emitFace(pieces, outerMat, P(hw, -hd), mul(det.ax, -1), z, hw + dh, 2 * hw, 0, H, prefix);
          emitFace(pieces, outerMat, P(hw, -hd), mul(det.ax, -1), z, hw - dh, hw + dh, top, H, prefix);
          emitFace(pieces, outerMat, P(hw, hd), mul(det.ay, -1), z, 0, 2 * hd, 0, H, prefix);
          emitFace(pieces, outerMat, P(-hw, hd), mul(det.ax, 1), z, 0, 2 * hw, 0, H, prefix);
          emitFace(pieces, outerMat, P(-hw, -hd), mul(det.ay, 1), z, 0, 2 * hd, 0, H, prefix);

          emitFace(pieces, innerMat, P(-iw, -id), mul(det.ax, 1), z, 0, iw - dh, 0, H, prefix);
          emitFace(pieces, innerMat, P(-iw, -id), mul(det.ax, 1), z, iw + dh, 2 * iw, 0, H, prefix);
          emitFace(pieces, innerMat, P(-iw, -id), mul(det.ax, 1), z, iw - dh, iw + dh, top, H, prefix);
          emitFace(pieces, innerMat, P(iw, -id), mul(det.ay, 1), z, 0, 2 * id, 0, H, prefix);
          emitFace(pieces, innerMat, P(iw, id), mul(det.ax, -1), z, 0, 2 * iw, 0, H, prefix);
          emitFace(pieces, innerMat, P(-iw, id), mul(det.ay, -1), z, 0, 2 * id, 0, H, prefix);

          emitFace(pieces, outerMat, P(-dh, -id), mul(det.ay, -1), z, 0, T, 0, top, prefix);
          emitFace(pieces, outerMat, P(dh, -hd), mul(det.ay, 1), z, 0, T, 0, top, prefix);
          tileRoom(pieces, prefix, { points: [P(-dh, -hd), P(dh, -hd), P(dh, -id), P(-dh, -id)], edges: [{ a: P(-dh, -hd), b: P(dh, -hd), length: L.door }], z: z + top, height: 0 }, [], outerMat, true);

          if (colliderSizes) {
            const keep = colQueue;

            colQueue = null;
            [[-hw, -hd, -dh, -id], [dh, -hd, hw, -id], [-hw, id, hw, hd], [-hw, -id, -iw, id], [iw, -id, hw, id]].forEach(function (r) {
              const along = r[2] - r[0] >= r[3] - r[1];
              const o = along ? P(r[0], (r[1] + r[3]) / 2 + 0.05) : P((r[0] + r[2]) / 2 - 0.05, r[1]);

              emitCollider(pieces, prefix, { origin: [o[0], o[1], z], pitch: 0, yaw: round(yaw(along ? det.ax : det.ay), 2) + (along ? 0 : 0), roll: 0, x0: 0, x1: along ? r[2] - r[0] : r[3] - r[1], y0: -0.1, z0: 0, z1: H });
            });
            colQueue = keep;
          }
        });

        const labels = stops.map(function (z) {
          const index = allZ.findIndex(function (v) { return Math.abs(v - z) < 0.05; });
          const ground = allZ.findIndex(function (v) { return v >= -0.05; });

          return String(index - (ground < 0 ? 0 : ground));
        });
        const front = P(0, -hd + T / 2);

        L.buttons = copButtons(stops.length).map(function (b) { return [round(L.copX - b.cx / 256 * L.copW, 4), round(L.copZ0 + (1 - b.cy / 1024) * L.copH, 4), round((b.r + 5) / 256 * L.copW, 4)]; });

        elevators.push({
          id: det.id, x: round(det.at[0]), y: round(det.at[1]), h: round(((det.heading % 360) + 360) % 360, 2), w: round(det.w), d: round(det.d), door: round(L.door), stops: stops.map(function (z) { return round(z); }), labels: labels,
          fx: round(front[0]), fy: round(front[1]), nx: round(-det.ay[0]), ny: round(-det.ay[1]),
          inner: [round(-L.cwH + 0.04, 3), round(L.cy0 + 0.04, 3), round(L.cwH - 0.04, 3), round(L.cy1 - 0.04, 3)], height: L.CH, layout: L
        });
      } else if (det.kind === "ladder") {
        const key = LADDER_WOODS.indexOf(det.mat) >= 0 ? "wood" : "metal";
        const heights = (kit && kit.ladders && kit.ladders.heights) || LADDER_HEIGHTS;
        let index = heights.findIndex(function (hgt) { return hgt >= det.climb - 0.001; });

        if (index < 0) index = heights.length - 1;

        pieces.push([prefix + "ladder_" + key + "_" + index, round(det.at[0]), round(det.at[1]), round(det.z), 0, round(((det.heading + 180) % 360 + 360) % 360, 2)]);
        pieces[pieces.length - 1].noCol = true;

        const foot = add(det.at, mul(det.ay, -0.42));
        const exit = add(det.at, mul(det.ay, -1.25));

        ladders.push({ id: det.id, x: round(foot[0]), y: round(foot[1]), z: round(det.z), top: round(det.z + det.climb), ex: round(exit[0]), ey: round(exit[1]), h: round(((Math.atan2(det.ay[1], det.ay[0]) * 180 / Math.PI - 90) % 360 + 360) % 360, 2) });
      } else if (det.kind === "column") {
        sides(det.z, det.z + H);
      } else if (det.kind === "pillar") {
        const key = PILLAR_MATERIALS.indexOf(det.mat) >= 0 ? det.mat : "white";

        pieces.push([prefix + "col_" + key, round(det.at[0]), round(det.at[1]), round(det.z), 0, round(det.heading, 2), 1, round(H, 4)]);
      } else if (det.kind === "beam") {
        sides(det.z + H - det.h, det.z + H);
        cap(det.z + H - det.h, mat, true);
      } else if (det.kind === "glassrail") {
        emitRailing(pieces, prefix, note, add(start, mul(det.ay, -0.04)), add(add(start, mul(det.ax, det.w)), mul(det.ay, -0.04)), det.z, "glass");
      } else if (det.kind === "rail") {
        const railMat = ["steel", "blackm", "brass", "oak", "darkwood", "whitem"].indexOf(det.mat) >= 0 ? det.mat : "steel";
        const count = Math.max(1, Math.ceil(det.w / 1.2));

        for (let i = 0; i <= count; i++) {
          const at = add(start, mul(det.ax, Math.min(det.w - 0.02, Math.max(0.02, det.w * i / count))));

          pieces.push([prefix + "post_" + railMat, round(at[0]), round(at[1]), round(det.z), 0, 0, 1, round(det.h, 3)]);
        }
        const a0 = add(start, mul(det.ax, 0.02));
        const b0 = add(start, mul(det.ax, det.w - 0.02));

        [det.h, det.h * 0.5].forEach(function (hz) { barPiece(pieces, prefix, railMat, a0, det.z + hz, b0, det.z + hz); });
      } else {
        if (det.kind === "shower" || det.kind === "bathtub") det.walled = walledSides(det);
        detailExtra(pieces, prefix, note, det, H, lamps);
      }
    }

    function walledSides(det) {
      const sidesOf = [[mul(det.ax, -1), det.w / 2, det.d], [det.ax, det.w / 2, det.d], [mul(det.ay, -1), det.d / 2, det.w], [det.ay, det.d / 2, det.w]];

      return sidesOf.map(function (sd) {
        const n = sd[0];
        const c = add(det.at, mul(n, sd[1]));

        return (doc.walls || []).some(function (wl) {
          if (wl.level !== det.level || Math.abs(Number(wl.bend) || 0) > 0.02 || !wl.a || !wl.b) return false;

          const L = len(sub(wl.b, wl.a));

          if (L < 0.05) return false;

          const wd = mul(sub(wl.b, wl.a), 1 / L);

          if (Math.abs(dot(wd, n)) > 0.12) return false;

          const rel = sub(c, wl.a);
          const t = dot(rel, wd);
          const off = Math.abs(dot(rel, left(wd)));
          const th = Number(wl.thick) || settings.thick || 0.2;

          return off <= th / 2 + 0.12 && t > -th / 2 && t < L + th / 2;
        });
      });
    }

    (doc.lights || []).forEach(function (light) {
      if (!light.p) return;

      const shape = LAMP_SHAPES.indexOf(light.shape) >= 0 ? light.shape : "round";
      const hrad = (Number(light.h) || 0) * Math.PI / 180;
      const drop = shape === "pendant" ? 0.75 : shape === "chandelier" ? 0.7 : shape === "bulb" ? 0.45 : 0.25;
      const glow = shape === "sconce" ? [light.p[0] - Math.sin(hrad) * 0.25, light.p[1] + Math.cos(hrad) * 0.25, light.p[2] + 0.05] : [light.p[0], light.p[1], light.p[2] - drop];

      if (shape !== "none") pieces.push([prefix + "lamp_" + shape, round(light.p[0]), round(light.p[1]), round(light.p[2]), 0, round(Number(light.h) || 0, 2)]);

      lamps.push({ id: light.id, x: round(glow[0]), y: round(glow[1]), z: round(glow[2]), colour: light.colour || "#ffe2bd", range: Number(light.range) || 7, intensity: Number(light.intensity) || 6, shadow: light.shadow !== false });
    });

    if (settings.fill !== false) {
      derived.rooms.forEach(function (room) {
        const pts = room.points || [];

        if (pts.length < 3) return;

        let area = 0;
        let cx = 0;
        let cy = 0;

        for (let i = 0; i < pts.length; i++) {
          const a = pts[i];
          const b = pts[(i + 1) % pts.length];
          const cr = a[0] * b[1] - b[0] * a[1];

          area += cr;
          cx += (a[0] + b[0]) * cr;
          cy += (a[1] + b[1]) * cr;
        }

        if (Math.abs(area) < 3) return;

        const c = [cx / (3 * area), cy / (3 * area)];
        const centre = insidePolygon(c, pts) ? c : mul(pts.reduce(function (sum, q) { return add(sum, q); }, [0, 0]), 1 / pts.length);
        const reach = pts.reduce(function (m, q) { return Math.max(m, len(sub(q, centre))); }, 0);

        lamps.push({ id: room.id + "_fill", x: round(centre[0]), y: round(centre[1]), z: round(room.z + room.height * 0.6), colour: "#fff0db", range: round(Math.min(14, reach + 1.2), 2), intensity: 1.6, shadow: false, fill: true });
      });
      derived.details.forEach(function (det) {
        if (OUTDOOR_FLOORS.indexOf(det.kind) < 0 || !det.points || det.points.length < 3) return;

        const centre = mul(det.points.reduce(function (sum, q) { return add(sum, q); }, [0, 0]), 1 / det.points.length);

        if (derived.rooms.some(function (r) { return r.level === det.level && insidePolygon(centre, r.points); })) return;

        const reach = det.points.reduce(function (m, q) { return Math.max(m, len(sub(q, centre))); }, 0);

        lamps.push({ id: det.id + "_fill", x: round(centre[0]), y: round(centre[1]), z: round((Number(det.z) || 0) + 2.6), colour: "#fff0db", range: round(Math.min(14, reach + 2.5), 2), intensity: 2.4, shadow: false, fill: true });
      });
      derived.holes.forEach(function (hole, index) {
        if (hole.pool || !hole.points || hole.points.length < 3) return;

        const level = levelOf(doc, hole.level);
        const top = Number(level.z) || 0;
        const centre = mul(hole.points.reduce(function (sum, q) { return add(sum, q); }, [0, 0]), 1 / hole.points.length);
        const reach = hole.points.reduce(function (m, q) { return Math.max(m, len(sub(q, centre))); }, 0);

        lamps.push({ id: "hole" + index + "_fill", x: round(centre[0]), y: round(centre[1]), z: round(top - 0.35), colour: "#fff0db", range: round(Math.min(10, reach + 1.0), 2), intensity: 2.2, shadow: false, fill: true });
      });
    }

    spiralEnds.forEach(function (link) {
      let best = null;

      pieces.forEach(function (p) {
        if (!/_post_/.test(String(p[0])) || Math.abs(Number(p[3]) - link.floor) > 0.06) return;

        const q = [Number(p[1]), Number(p[2])];
        const dist = len(sub(q, [link.end[0], link.end[1]]));

        if (dist < 0.05 || dist > 1.2 || len(sub(q, link.centre)) < link.radius + 0.05) return;
        if (!best || dist < best.dist) best = { q: q, dist: dist, top: Number(p[3]) + (Number(p[7]) || 1) * 0.98 };
      });

      if (!best) return;

      const from = [link.end[0], link.end[1]];
      const high = Math.min(link.end[2], best.top - 0.02);

      barPiece(pieces, prefix, link.mat, from, link.end[2], best.q, high);
      barPiece(pieces, prefix, link.mat, from, link.floor + 0.45, best.q, link.floor + 0.45);
    });

    if (kit && kit.colliders) {
      const glassKeys = new Set(((kit.glass || []).map(function (g) { return g.key; })).concat(["mirror"]));
      const count = pieces.length;
      const floors = (doc.levels || [{ z: 0 }]).map(function (l) { return Number(l.z) || 0; }).sort(function (a, b) { return a - b; });
      const above = function (z) { let base = floors[0]; floors.forEach(function (f) { if (f <= z + 0.01) base = f; }); return z - base; };

      for (let i = 0; i < count; i++) {
        const p = pieces[i];

        if (p.noCol) continue;

        const name = String(p[0]).slice(prefix.length);

        if (above(Number(p[3])) >= 2.0 && !(/^bar_/.test(name) && (Math.abs(Number(p[8]) || 0) > 5 || above(Number(p[3])) < 4.6))) continue;
        const sx = p[6] === undefined ? 1 : Number(p[6]);
        const sz = p[7] === undefined ? 1 : Number(p[7]);
        const base = { origin: [p[1], p[2], p[3]], pitch: Number(p[4]) || 0, yaw: Number(p[5]) || 0, roll: Number(p[8]) || 0 };

        if (p.trim) {
          if (p.trim.mat === "water" || Number(p[4]) === -90 || Math.min(p.trim.sx, p.trim.sz) < 0.4) continue;

          colliders.push(Object.assign(base, { x0: 0, x1: p.trim.sx, y0: -0.1, z0: 0, z1: p.trim.sz }));
        } else if (/_dd$/.test(name) && glassKeys.has(name.slice(0, -3)) && (Math.abs(sx - 1) > 0.001 || Math.abs(sz - 1) > 0.001)) {
          if (Math.min(sx, sz) * 0.25 < 0.4) continue;

          colliders.push(Object.assign(base, { x0: 0, x1: sx * 0.25, y0: -0.05, z0: 0, z1: sz * 0.25 }));
        } else if (/^bar_/.test(name) && sx * (Number((/_l(\d+)$/.exec(name) || [0, 1])[1]) || 1) > 0.2) {
          const lift = above(Number(p[3]));
          const length = sx * (Number((/_l(\d+)$/.exec(name) || [0, 1])[1]) || 1);
          const pitched = Math.abs(Number(p[8]) || 0) > 5;

          if (lift > 0.6 || lift < 0 || pitched) colliders.push(Object.assign(base, { x0: 0, x1: length, y0: -0.05, z0: -(pitched ? 0.86 : Math.min(0.86, lift > 0 ? lift - 0.03 : 0.86)), z1: 0.02 }));
        } else if (/^rail_/.test(name) && sx > 0.2) {
          colliders.push(Object.assign(base, { x0: 0, x1: sx, y0: -0.05, z0: 0, z1: 1.0 }));
        }
      }

      if (kit.solidQuads === false && quadKit) quadColliders(pieces, count, colliders, above, derived.rooms);

      const queued = colQueue || [];

      colliders.forEach(function (c) { if (c.ramp || !c.low || above(Number(c.origin[2])) < 2.0) queued.push(c); });
      colQueue = null;
      pairWallColliders(mergeColliders(queued)).forEach(function (c) { emitCollider(pieces, prefix, c); });
    }

    faceCols = null;

    if (quadKit && !(buildOptions && buildOptions.exact) && settings.merge !== false) mergePlainQuads(pieces, prefix, (doc.levels || [{ z: 0 }]).map(function (l) { return Number(l.z) || 0; }));

    if (quadKit && !(buildOptions && buildOptions.exact)) overlapQuads(pieces);
    if (kit && kit.ringBase) bigRings(pieces, prefix, kit.ringBase);
    if (tintKit) tintPieces(pieces);

    let minx = Infinity, miny = Infinity, maxx = -Infinity, maxy = -Infinity, maxz = 0;

    derived.rooms.forEach(function (room) {
      room.points.forEach(function (p) {
        minx = Math.min(minx, p[0]); maxx = Math.max(maxx, p[0]);
        miny = Math.min(miny, p[1]); maxy = Math.max(maxy, p[1]);
      });
      maxz = Math.max(maxz, room.z + room.height);
    });
    (doc.walls || []).forEach(function (wall) {
      const level = levelOf(doc, wall.level);

      [wall.a, wall.b].forEach(function (p) {
        minx = Math.min(minx, p[0]); maxx = Math.max(maxx, p[0]);
        miny = Math.min(miny, p[1]); maxy = Math.max(maxy, p[1]);
      });
      maxz = Math.max(maxz, (Number(level.z) || 0) + (Number(level.height) || 2.8));
    });
    derived.pools.forEach(function (pool) {
      pool.points.forEach(function (p) {
        minx = Math.min(minx, p[0]); maxx = Math.max(maxx, p[0]);
        miny = Math.min(miny, p[1]); maxy = Math.max(maxy, p[1]);
      });
    });

    maxz = Math.max(maxz, roofTop);

    const minz = Math.min(0, Math.min.apply(null, (doc.levels || [{ z: 0 }]).map(function (l) { return Number(l.z) || 0; })), Math.min.apply(null, derived.pools.map(function (pl) { return pl.z - pl.depth; }).concat([0])));
    const bounds = isFinite(minx) ? { min: [round(minx - 0.5), round(miny - 0.5), round(minz - 0.5)], max: [round(maxx + 0.5), round(maxy + 0.5), round(maxz + 0.5)] } : { min: [-5, -5, -0.5], max: [5, 5, 3.5] };
    const zones = derived.rooms.map(function (room) {
      return { id: room.id, name: room.record.name || "", type: room.record.type || "living", z: room.z, height: room.height, points: room.points, inside: room.record.inside || "", hour: room.record.hour, weather: room.record.weather || "" };
    });

    const soffitMat = note((doc.settings && doc.settings.outside) || "white");

    derived.rooms.forEach(function (room) {
      if (!(room.z > 0.5) || !room.points || room.points.length < 3) return;

      const lower = derived.rooms.filter(function (r) { return r.z < room.z - 0.5 && r.z + (r.height || 2.8) > room.z - 1.2; });
      const STEP = 0.1;
      let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;

      const grow = Math.max(0.08, Number(settings.thick) || 0.2);

      room.points.forEach(function (p) { x0 = Math.min(x0, p[0] - grow); y0 = Math.min(y0, p[1] - grow); x1 = Math.max(x1, p[0] + grow); y1 = Math.max(y1, p[1] + grow); });

      const edgeDist = function (q, poly) {
        const pts = poly || room.points;
        let best = Infinity;

        for (let k = 0; k < pts.length; k++) {
          const a = pts[k];
          const b = pts[(k + 1) % pts.length];
          const ab = sub(b, a);
          const l2 = dot(ab, ab) || 1e-9;
          const t = Math.max(0, Math.min(1, dot(sub(q, a), ab) / l2));

          best = Math.min(best, len(sub(q, add(a, mul(ab, t)))));
        }

        return best;
      };
      const nx = Math.ceil((x1 - x0) / STEP);
      const ny = Math.ceil((y1 - y0) / STEP);

      if (nx * ny > 400000) return;

      const open = [];
      let any = false;

      for (let j = 0; j < ny; j++) {
        const row = new Uint8Array(nx);

        for (let i = 0; i < nx; i++) {
          const q = [x0 + (i + 0.5) * STEP, y0 + (j + 0.5) * STEP];

          if (!insidePolygon(q, room.points) && edgeDist(q) > grow) continue;
          if (lower.some(function (r) { return insidePolygon(q, r.points) || edgeDist(q, r.points) <= grow + 0.02; })) continue;

          row[i] = 1;
          any = true;
        }

        open.push(row);
      }

      if (!any) return;

      const runs = [];

      open.forEach(function (row, j) {
        let i = 0;

        while (i < nx) {
          if (!row[i]) { i++; continue; }

          const s = i;

          while (i < nx && row[i]) i++;

          const last = runs.find(function (r) { return r.a === s && r.b === i && r.j1 === j; });

          if (last) last.j1 = j + 1;
          else runs.push({ a: s, b: i, j0: j, j1: j + 1 });
        }
      });

      runs.forEach(function (r) {
        const pad = 0.02;
        const soffitFrom = pieces.length;

        boxPiece(pieces, prefix, soffitMat, [x0 + r.a * STEP - pad, y0 + r.j0 * STEP - pad], [1, 0], (r.b - r.a) * STEP + 2 * pad, (r.j1 - r.j0) * STEP + 2 * pad, room.z - 0.19, 0.178);
        markAbove(pieces, soffitFrom, room.z);
      });
    });

    const PIECE_DEFAULTS = [null, 0, 0, 0, 0, 0, 1, 1, 0, 1, false, false, false, false, false];

    pieces.forEach(function (p) {
      for (let i = 1; i < p.length; i++) {
        if (p[i] === null || p[i] === undefined || (typeof p[i] === "number" && !isFinite(p[i]))) p[i] = i < PIECE_DEFAULTS.length ? PIECE_DEFAULTS[i] : false;
      }
    });

    const levelZs = (doc.levels || [{ z: 0 }]).map(function (l) { return round(Number(l.z) || 0, 3); }).sort(function (a, b) { return a - b; });
    const voids = derived.holes.map(function (h) {
      const level = levelOf(doc, h.level);

      return { z: round(Number(level && level.z) || 0, 3), points: h.points.map(function (p) { return [round(p[0], 2), round(p[1], 2)]; }) };
    });

    return {
      derived: derived, pieces: pieces, doors: doors, lamps: lamps, ladders: ladders, elevators: elevators, slots: Array.from(usedSlots), bounds: bounds, zones: zones, levels: levelZs, voids: voids,
      stats: { pieces: pieces.length, doors: doors.length, rooms: derived.rooms.length, props: (doc.props || []).length, lights: lamps.length, area: round(derived.rooms.reduce(function (s, r) { return s + r.area; }, 0), 1) }
    };
  }

  function rectangleWalls(doc, level, x, y, w, h, thick) {
    const corners = [[x, y], [x + w, y], [x + w, y + h], [x, y + h]];
    const out = [];

    for (let i = 0; i < 4; i++) out.push({ id: uid("w"), level: level, a: corners[i], b: corners[(i + 1) % 4], thick: thick });

    return out;
  }

  function collinearMerge(walls) {
    const out = [];
    const sameLine = function (w, v) {
      if ((w.level || "l1") !== (v.level || "l1") || Math.abs(Number(w.bend) || 0) > 0.01 || Math.abs(Number(v.bend) || 0) > 0.01) return false;

      const d = norm(sub(w.b, w.a));
      const e = norm(sub(v.b, v.a));

      if (Math.abs(cross(d, e)) > 1e-3) return false;
      if (Math.abs(cross(d, sub(v.a, w.a))) > 0.01) return false;

      return true;
    };

    walls.forEach(function (wall) {
      const twin = out.find(function (o) {
        if (!sameLine(o, wall)) return false;

        const d = norm(sub(o.b, o.a));
        const a0 = 0;
        const a1 = dot(sub(o.b, o.a), d);
        const b0 = dot(sub(wall.a, o.a), d);
        const b1 = dot(sub(wall.b, o.a), d);

        return Math.min(b0, b1) < a1 - 0.01 && Math.max(b0, b1) > a0 + 0.01;
      });

      if (!twin) {
        out.push(wall);
        return;
      }

      const d = norm(sub(twin.b, twin.a));
      const values = [0, dot(sub(twin.b, twin.a), d), dot(sub(wall.a, twin.a), d), dot(sub(wall.b, twin.a), d)];
      const lo = Math.min.apply(null, values);
      const hi = Math.max.apply(null, values);
      const start = twin.a.slice();

      twin.a = add(start, mul(d, lo)).map(function (v) { return round(v, 4); });
      twin.b = add(start, mul(d, hi)).map(function (v) { return round(v, 4); });
    });

    return out;
  }

  function layout(choice, kit) {
    const c = choice || {};
    const type = LAYOUT_TYPES[c.type] ? c.type : "house";
    const floors = Math.max(1, Math.min(4, Math.round(Number(c.floors) || 1)));

    if (type === "house" && floors === 1) return houseLayout(c, kit);

    return planLayout(c, type, floors);
  }

  const LAYOUT_TYPES = { house: 1, apartment: 1, studio: 1, garage: 1, mechanic: 1, office: 1, shop: 1, warehouse: 1 };

  function planLayout(c, type, floors) {
    const scheme = SCHEMES[c.scheme] || SCHEMES.warm;
    const doc = blank(c.name || "Shell");
    const sizeKey = { s: 0, m: 1, l: 2 }[c.size || "m"];
    const bedrooms = Math.max(0, Math.min(6, Number(c.bedrooms === undefined ? 2 : c.bedrooms)));
    const baths = Math.max(1, Math.min(3, Number(c.baths) || 1));
    const bays = sizeKey + 1;
    const commercial = { garage: 1, mechanic: 1, warehouse: 1 };
    const WALLS = { garage: "blocks", mechanic: "blocks", warehouse: "concpan", shop: "white", office: "white" };
    const FLOORS = { garage: "concrete", storage: "concrete", hall: scheme.floors.hall || scheme.floors._, office: scheme.floors.office || scheme.floors._ };
    const H_LEVEL = 2.8;
    const walls = [];
    const rooms = [];
    const openings = [];
    const stairs = [];
    let W = 11.2;
    let H = 8.2;

    const addRoom = function (level, anchor, name, rtype) {
      const wallMat = WALLS[type] && rtype !== "bathroom" ? WALLS[type] : rtype === "bathroom" ? scheme.bathwalls : scheme.walls;
      const floorMat = commercial[type] && rtype !== "bathroom" && rtype !== "office" ? (type === "warehouse" ? "polished" : "concrete") : (FLOORS[rtype] || scheme.floors[rtype] || scheme.floors._);
      const r = { id: uid("r"), level: level.id, anchor: [round(anchor[0], 2), round(anchor[1], 2)], name: name, type: rtype, walls: wallMat, floor: floorMat, ceiling: scheme.ceiling };

      rooms.push(r);

      return r;
    };
    const wall = function (level, a, b, thick) {
      walls.push({ id: uid("w"), level: level.id, a: [round(a[0], 2), round(a[1], 2)], b: [round(b[0], 2), round(b[1], 2)], thick: thick || 0.15 });
    };
    const hole = function (level, kind, place, extra) {
      openings.push(Object.assign({ id: uid("o"), level: level.id, kind: kind, place: [round(place[0], 2), round(place[1], 2)] }, extra || {}));
    };
    const strip = function (level, x0, x1, y0, y1, cells, doorSide, windowSide) {
      const total = cells.reduce(function (sum, cell) { return sum + (cell.weight || 1); }, 0);
      let x = x0;

      cells.forEach(function (cell, index) {
        const width = (x1 - x0) * (cell.weight || 1) / total;

        if (index > 0) wall(level, [x, y0], [x, y1]);

        cell.room = addRoom(level, [x + width / 2, (y0 + y1) / 2], cell.name, cell.type);
        cell.x0 = x;
        cell.x1 = x + width;

        if (doorSide !== null && cell.door !== false) hole(level, cell.door || "door", [x + Math.min(0.9, width / 2), doorSide], { door: cell.type === "bathroom" ? "bath" : cell.doorStyle || "plain_white" });
        if (windowSide !== null && cell.window) hole(level, cell.window === true ? "window" : cell.window, [x + width / 2, windowSide]);

        x += width;
      });

      return cells;
    };
    const levelAt = function (i) {
      if (i === 0) return doc.levels[0];

      const lv = { id: uid("l"), name: "Floor " + (i + 1), z: round(i * (H_LEVEL + 0.2), 3), height: H_LEVEL };

      doc.levels.push(lv);

      return lv;
    };
    const outer = function (level, thick) {
      rectangleWalls(doc, level.id, 0, 0, W, H, thick || 0.2).forEach(function (w) { walls.push(w); });
    };
    const stairRun = function () {
      return Math.max(4, Math.round((H_LEVEL + 0.2) / 0.18)) * 0.28;
    };

    if (type === "house" || type === "office") {
      W = [9.6, 12.4, 15.2][sizeKey];
      H = [8.2, 9.2, 10.2][sizeKey];

      const back = Math.min(H * 0.5, 4.4);
      const split = H - back;
      const run = stairRun();
      const upper = floors - 1;
      const perFloor = upper > 0 ? Math.ceil(bedrooms / upper) : bedrooms;
      let left = bedrooms;

      for (let i = 0; i < floors; i++) {
        const lv = levelAt(i);

        outer(lv);
        wall(lv, [0, split], [W, split]);

        if (type === "office") {
          if (i === 0) {
            strip(lv, 0, W, split, H, [{ name: "Office", type: "office", weight: 3, window: true }, { name: "Meeting room", type: "office", weight: 3.4, window: true }, { name: "Toilet", type: "bathroom", weight: 1.6 }], split, H);
            addRoom(lv, [W / 2, split / 2], "Open office", "office");
            hole(lv, "glassdoor", [1.4, 0]);
            hole(lv, "picture", [W * 0.5, 0]);
            hole(lv, "picture", [W * 0.8, 0]);
          } else {
            strip(lv, 0, W, split, H, [{ name: "Office", type: "office", weight: 3, window: true }, { name: "Office", type: "office", weight: 3, window: true }, { name: "Kitchenette", type: "kitchen", weight: 2.2 }], split, H);
            addRoom(lv, [W / 2, split / 2], "Open office", "office");
            hole(lv, "picture", [W * 0.3, 0]);
            hole(lv, "picture", [W * 0.7, 0]);
          }
        } else if (i === 0) {
          const cells = [];

          if (floors === 1) {
            for (let b = 0; b < bedrooms; b++) cells.push({ name: "Bedroom" + (bedrooms > 1 ? " " + (b + 1) : ""), type: "bedroom", weight: 3.3, window: true });
            for (let b = 0; b < baths; b++) cells.push({ name: "Bathroom", type: "bathroom", weight: 2.2 });
          } else {
            cells.push({ name: "Bathroom", type: "bathroom", weight: 2 });
            cells.push({ name: c.kitchen === "closed" ? "Dining room" : "Utility", type: c.kitchen === "closed" ? "dining" : "laundry", weight: 3, window: true });
          }

          strip(lv, 0, W, split, H, cells, split, H);

          if (c.kitchen === "closed") {
            const kw = Math.min(3.6, W * 0.32);

            wall(lv, [W - kw, 0], [W - kw, split]);
            addRoom(lv, [W - kw / 2, split / 2], "Kitchen", "kitchen");
            hole(lv, "opening", [W - kw, split / 2]);
            hole(lv, "window", [W - kw / 2, 0]);
            addRoom(lv, [(W - kw) / 2, split / 2], "Living room", "living");
          } else {
            addRoom(lv, [W / 2, split / 2], "Living room", "living");
          }

          hole(lv, "door", [1.2, 0], { door: "front" });
          hole(lv, "window", [W * 0.45, 0]);
        } else {
          const count = Math.min(left, perFloor);
          const cells = [];

          left -= count;

          for (let b = 0; b < count; b++) cells.push({ name: "Bedroom", type: "bedroom", weight: 3.3, window: true });
          for (let b = 0; b < (i === 1 ? baths : 1); b++) cells.push({ name: "Bathroom", type: "bathroom", weight: 2.2 });

          strip(lv, 0, W, split, H, cells, split, H);
          addRoom(lv, [W * 0.35, split / 2], "Hall", "hall");
          hole(lv, "window", [W * 0.3, 0]);
          hole(lv, "window", [W * 0.7, 0]);
        }

        const odd = i % 2 === 1;
        const sx = odd ? 0.35 + run + 1.2 : 0.35;
        const sy = odd ? split - 0.62 - 1.1 : split - 0.62;
        const mirror = type !== "house";

        if (i < floors - 1) stairs.push({ id: uid("st"), level: lv.id, at: [round(mirror ? W - sx : sx, 2), round(sy, 2)], heading: (odd ? 90 : -90) * (mirror ? -1 : 1), width: 1, material: type === "office" ? "steel" : "oak", rail: true, closed: true, type: "straight" });
      }
    } else if (type === "apartment") {
      W = [8.6, 10.8, 13.2][sizeKey];
      H = [7.4, 8.4, 9.4][sizeKey];

      const lv = doc.levels[0];
      const back = Math.min(H * 0.48, 4.2);
      const split = H - back;
      const hallW = 2.2;
      const cells = [];

      outer(lv);
      wall(lv, [0, split], [W, split]);
      for (let b = 0; b < Math.max(1, Math.min(3, bedrooms)); b++) cells.push({ name: "Bedroom" + (bedrooms > 1 ? " " + (b + 1) : ""), type: "bedroom", weight: 3.2, window: true });
      cells.push({ name: "Bathroom", type: "bathroom", weight: 2.1 });
      strip(lv, 0, W, split, H, cells, split, H);
      wall(lv, [hallW, 0], [hallW, split]);
      addRoom(lv, [hallW / 2, split / 2], "Hall", "hall");
      hole(lv, "opening", [hallW, split * 0.55]);
      addRoom(lv, [(hallW + W) / 2, split / 2], "Living room", "living");
      hole(lv, "door", [hallW / 2, 0], { door: "front" });
      hole(lv, "picture", [(hallW + W) / 2, 0]);
    } else if (type === "studio") {
      W = [6.4, 7.6, 9.0][sizeKey];
      H = [5.4, 6.4, 7.2][sizeKey];

      const lv = doc.levels[0];
      const bw = 2.4;
      const bd = 2.2;

      outer(lv);
      wall(lv, [W - bw, H - bd], [W, H - bd]);
      wall(lv, [W - bw, H - bd], [W - bw, H]);
      addRoom(lv, [W - bw / 2, H - bd / 2], "Bathroom", "bathroom");
      hole(lv, "door", [W - bw, H - bd / 2], { door: "bath" });
      addRoom(lv, [W * 0.4, H * 0.45], "Studio", "living");
      hole(lv, "door", [1.2, 0], { door: "front" });
      hole(lv, "window", [W * 0.55, 0]);
      hole(lv, "window", [W * 0.3, H]);
    } else if (type === "garage") {
      W = 3.8 * bays + 0.8;
      H = 7.2;

      const lv = doc.levels[0];
      const store = 1.8;

      outer(lv);
      wall(lv, [0, H - store], [W, H - store]);
      addRoom(lv, [W / 2, (H - store) / 2], "Garage", "garage");
      strip(lv, 0, W, H - store, H, [{ name: "Storage", type: "storage", weight: 1, door: "opening" }], null, null);
      hole(lv, "opening", [W / 2, H - store]);

      for (let b = 0; b < bays; b++) hole(lv, "garage", [0.4 + 3.8 * b + 1.9, 0]);

      hole(lv, "door", [0, 1.4]);
    } else if (type === "mechanic") {
      const shopW = 4.6 * (bays + 1);
      const side = 4.4;

      W = shopW + side;
      H = 10.4;

      const lv = doc.levels[0];

      outer(lv);
      wall(lv, [shopW, 0], [shopW, H]);
      addRoom(lv, [shopW / 2, H / 2], "Workshop", "garage");

      for (let b = 0; b < bays + 1; b++) hole(lv, "garage", [4.6 * b + 2.3, 0]);

      const mid = H * 0.45;

      wall(lv, [shopW, mid], [W, mid]);
      addRoom(lv, [shopW + side / 2, mid / 2], "Reception", "office");
      hole(lv, "glassdoor", [shopW + side / 2, 0]);
      hole(lv, "door", [shopW, mid / 2]);
      strip(lv, shopW, W, mid, H, [{ name: "Office", type: "office", weight: 1.6, door: false, window: true }, { name: "Toilet", type: "bathroom", weight: 1, door: false }], null, H);
      rooms[rooms.length - 2].anchor = [round(shopW + side * 0.3, 2), round((mid + H) / 2, 2)];
      rooms[rooms.length - 1].anchor = [round(shopW + side * 0.8, 2), round((mid + H) / 2, 2)];
      hole(lv, "door", [shopW + side * 0.3, mid]);
      hole(lv, "door", [shopW + side * 0.8, mid], { door: "bath" });
      hole(lv, "door", [shopW, H - 1.4]);
    } else if (type === "shop") {
      W = [8.4, 11.2, 14.4][sizeKey];
      H = [8.4, 10.2, 12.2][sizeKey];

      const lv = doc.levels[0];
      const back = 3.2;
      const split = H - back;

      outer(lv);
      wall(lv, [0, split], [W, split]);
      strip(lv, 0, W, split, H, [{ name: "Storage", type: "storage", weight: 3, doorStyle: "plain_white" }, { name: "Staff room", type: "office", weight: 2.2 }, { name: "Toilet", type: "bathroom", weight: 1.4 }], split, null);
      addRoom(lv, [W / 2, split / 2], "Shop", "other");
      hole(lv, "glassdoor", [W / 2, 0]);
      hole(lv, "picture", [W * 0.2, 0]);
      hole(lv, "picture", [W * 0.8, 0]);
      hole(lv, "door", [W - 0.1, H - back / 2]);
    } else if (type === "warehouse") {
      W = [16, 22, 28][sizeKey];
      H = [12, 15, 18][sizeKey];

      const lv = doc.levels[0];
      const ow = 4.4;
      const od = 5.2;

      lv.height = 4.5;
      outer(lv, 0.3);
      wall(lv, [W - ow, H - od], [W, H - od]);
      wall(lv, [W - ow, H - od], [W - ow, H]);
      addRoom(lv, [(W - ow) / 2, H / 2], "Warehouse", "storage");
      strip(lv, W - ow, W, H - od, H, [{ name: "Office", type: "office", weight: 1.6, door: false, window: true }, { name: "Toilet", type: "bathroom", weight: 1, door: false }], null, H);
      rooms[rooms.length - 2].anchor = [round(W - ow + ow * 0.3, 2), round(H - od / 2, 2)];
      rooms[rooms.length - 1].anchor = [round(W - ow * 0.2, 2), round(H - od / 2, 2)];
      hole(lv, "door", [W - ow + ow * 0.3, H - od]);
      hole(lv, "door", [W - ow * 0.2, H - od], { door: "bath" });
      hole(lv, "garage", [W * 0.3, 0]);
      hole(lv, "garage", [W * 0.6, 0]);
      hole(lv, "door", [W - 1.4, 0]);
    }

    doc.walls = walls;
    doc.rooms = rooms;
    doc.stairs = stairs;
    doc.settings.skirting = commercial[type] ? "steel" : scheme.skirting;
    doc.openings = openings.map(function (o) {
      let best = null;
      let bestDistance = Infinity;

      walls.forEach(function (w) {
        if ((w.level || "l1") !== o.level) return;

        const d = norm(sub(w.b, w.a));
        const t = dot(sub(o.place, w.a), d);
        const along = len(sub(w.b, w.a));
        const half = (OPENINGS[o.kind] || OPENINGS.door).width / 2;

        if (t < half + 0.1 || t > along - half - 0.1) return;

        const dist = len(sub(o.place, add(w.a, mul(d, t))));

        if (dist < bestDistance) {
          bestDistance = dist;
          best = { wall: w.id, t: round(t, 3) };
        }
      });

      const out = { id: o.id, kind: o.kind, wall: best && bestDistance < 0.3 ? best.wall : null, t: best ? best.t : 1 };

      if (o.door) out.door = o.door;

      return out;
    }).filter(function (o) { return o.wall; });

    const area = W * H;

    doc.lights = rooms.map(function (r) {
      const lv = levelOf(doc, r.level);

      return { id: uid("li"), p: [r.anchor[0], r.anchor[1], round((Number(lv.z) || 0) + (Number(lv.height) || 2.8) - 0.01, 3)], shape: "round", colour: commercial[type] ? "#f4f7ff" : "#ffe2bd", range: commercial[type] ? 10 : 7, intensity: area > 80 ? 7 : 6 };
    });
    doc.points.exit = { p: [1.7, 0.9, 0], h: 180 };

    return doc;
  }

  function houseLayout(choice, kit) {
    const c = choice || {};
    const size = { s: [8.4, 6.4], m: [11.2, 8.2], l: [14.2, 10.2] }[c.size || "m"];
    const bedrooms = Math.max(0, Math.min(4, Number(c.bedrooms === undefined ? 1 : c.bedrooms)));
    const baths = Math.max(1, Math.min(2, Number(c.baths) || 1));
    const closedKitchen = c.kitchen === "closed";
    const scheme = SCHEMES[c.scheme] || SCHEMES.warm;
    const doc = blank(c.name || "Shell");
    const W = size[0];
    const H = size[1];
    const back = Math.min(H * 0.48, 4.2);
    const walls = rectangleWalls(doc, "l1", 0, 0, W, H, 0.2);
    const rooms = [];
    const openings = [];
    const room = function (anchor, name, type) {
      const floors = scheme.floors;
      const r = { id: uid("r"), level: "l1", anchor: anchor, name: name, type: type, walls: type === "bathroom" ? scheme.bathwalls : scheme.walls, floor: floors[type] || floors._, ceiling: scheme.ceiling };

      rooms.push(r);

      return r;
    };
    const split = H - back;

    walls.push({ id: uid("w"), level: "l1", a: [0, split], b: [W, split], thick: 0.15 });

    const cells = [];

    for (let i = 0; i < bedrooms; i++) cells.push({ type: "bedroom", weight: 3.3 });
    for (let i = 0; i < baths; i++) cells.push({ type: "bathroom", weight: 2.2 });

    const total = cells.reduce(function (s, x) { return s + x.weight; }, 0);
    let x = 0;

    cells.forEach(function (cell, index) {
      const width = W * cell.weight / total;

      if (index > 0) walls.push({ id: uid("w"), level: "l1", a: [round(x, 2), split], b: [round(x, 2), H], thick: 0.15 });

      const r = room([round(x + width / 2, 2), round(split + back / 2, 2)], cell.type === "bedroom" ? "Bedroom" + (bedrooms > 1 ? " " + (cells.slice(0, index + 1).filter(function (c2) { return c2.type === "bedroom"; }).length) : "") : "Bathroom", cell.type);
      const door = { id: uid("o"), wall: null, kind: "door", t: 0, door: cell.type === "bathroom" ? "bath" : "plain_white" };

      door.place = [round(x + Math.min(0.9, width / 2), 2), split];
      openings.push(door);

      if (cell.type === "bedroom") openings.push({ id: uid("o"), kind: "window", place: [round(x + width / 2, 2), H] });

      cell.room = r;
      x += width;
    });

    if (!cells.length) room([W / 2, split + back / 2], "Room", "bedroom");

    if (closedKitchen) {
      const kw = Math.min(3.4, W * 0.32);

      walls.push({ id: uid("w"), level: "l1", a: [round(W - kw, 2), 0], b: [round(W - kw, 2), split], thick: 0.15 });
      room([round(W - kw / 2, 2), round(split / 2, 2)], "Kitchen", "kitchen");
      openings.push({ id: uid("o"), kind: "opening", place: [round(W - kw, 2), round(split / 2, 2)] });
      openings.push({ id: uid("o"), kind: "window", place: [round(W - kw / 2, 2), 0] });
      room([round((W - kw) / 2, 2), round(split / 2, 2)], "Living room", "living");
    } else {
      room([round(W / 2, 2), round(split / 2, 2)], "Living room", "living");
    }

    openings.push({ id: uid("o"), kind: "door", place: [1.2, 0], door: "front" });
    openings.push({ id: uid("o"), kind: "window", place: [round(W * 0.45, 2), 0] });

    doc.walls = walls;
    doc.rooms = rooms;
    doc.settings.skirting = scheme.skirting;
    doc.openings = openings.map(function (o) {
      let best = null;
      let bestDistance = Infinity;

      walls.forEach(function (w) {
        const d = norm(sub(w.b, w.a));
        const t = dot(sub(o.place, w.a), d);
        const along = len(sub(w.b, w.a));

        if (t < 0.4 || t > along - 0.4) return;

        const dist = len(sub(o.place, add(w.a, mul(d, t))));

        if (dist < bestDistance) {
          bestDistance = dist;
          best = { wall: w.id, t: round(t, 3) };
        }
      });

      const out = { id: o.id, kind: o.kind, wall: best ? best.wall : null, t: best ? best.t : 1 };

      if (o.door) out.door = o.door;

      return out;
    }).filter(function (o) { return o.wall; });

    const area = W * H;

    doc.lights = rooms.map(function (r) { return { id: uid("li"), p: [r.anchor[0], r.anchor[1], 2.79], shape: "round", colour: "#ffe2bd", range: 7, intensity: area > 80 ? 7 : 6 }; });
    doc.points.exit = { p: [1.7, 0.9, 0], h: 180 };

    return doc;
  }

  function nearestRoom(built, p, level) {
    let best = null;
    let bestDistance = Infinity;

    built.derived.rooms.forEach(function (room) {
      if (level && room.level !== level) return;

      if (insidePolygon(p, room.points)) {
        best = room;
        bestDistance = 0;
        return;
      }

      const d = distanceToEdges(p, room.points);

      if (d < bestDistance) {
        bestDistance = d;
        best = room;
      }
    });

    return best;
  }

  function roomAt(built, p, z) {
    return built.derived.rooms.find(function (room) {
      return z >= room.z - 0.3 && z <= room.z + room.height + 0.2 && insidePolygon(p, room.points);
    }) || null;
  }

  function unwalledSpans(doc, levelId, a, b) {
    const dir = sub(b, a);
    const length = len(dir);

    if (length < 0.02) return [];

    const d = mul(dir, 1 / length);
    const out = right(d);
    const walls = (doc.walls || []).filter(function (w) { return w.level === levelId && w.a && w.b && Math.abs(Number(w.bend) || 0) < 0.02 && w.kind !== "rail" && w.kind !== "glass"; });
    const covered = function (q) {
      return walls.some(function (w) {
        const wd = sub(w.b, w.a);
        const wl = len(wd);

        if (wl < 0.05 || Math.abs(dot(mul(wd, 1 / wl), d)) < 0.995) return false;

        const t = dot(sub(q, w.a), wd) / (wl * wl);

        if (t < -0.002 || t > 1.002) return false;

        const face = dot(sub(add(w.a, mul(wd, t)), q), out) - Math.max(0.08, Number(w.thick) || 0.2) / 2;

        return face > -0.12 && face < 0.08;
      });
    };
    const n = Math.max(2, Math.ceil(length / 0.05));
    const spans = [];
    let start = null;

    for (let k = 0; k <= n; k++) {
      const t = k / n;
      const free = !covered(add(a, mul(dir, t)));

      if (free && start === null) start = t;
      if ((!free || k === n) && start !== null) {
        const end = free ? t : (k - 0.5) / n;

        if ((end - start) * length > 0.04) spans.push([add(a, mul(dir, start)), add(a, mul(dir, end))]);
        start = null;
      }
    }

    return spans;
  }

  function snapStairToWalls(doc, s, level, above) {
    if (s.type === "spiral" || !s.at) return s;

    const g = stairGeometry(s, level, above);
    const f = g.flights[0];

    if (!f) return s;

    const run = f.count * g.stepRun + (g.landings[0] && s.type === "landing" ? g.landings[0].depth + (g.flights[1] ? g.flights[1].count * g.stepRun : 0) : 0);
    const gaps = { "1": null, "-1": null };

    (doc.walls || []).forEach(function (w) {
      if ((w.level || "l1") !== level.id || Math.abs(Number(w.bend) || 0) >= 0.02 || !w.a || !w.b) return;

      const d = sub(w.b, w.a);
      const length = len(d);

      if (length < 0.3 || Math.abs(dot(mul(d, 1 / length), f.fwd)) < 0.995) return;

      const t0 = dot(sub(w.a, f.at), f.fwd);
      const t1 = dot(sub(w.b, f.at), f.fwd);

      if (Math.min(t0, t1) > run - 0.2 || Math.max(t0, t1) < 0.2) return;

      const thick = Math.max(0.08, Number(w.thick) || Number(doc.settings && doc.settings.thick) || 0.2);

      [1, -1].forEach(function (sign) {
        const gap = dot(sub(w.a, f.at), f.side) * sign - thick / 2 - g.width / 2;

        if (gap > 0.005 && gap < 0.3 && (gaps[sign] === null || gap < gaps[sign])) gaps[sign] = gap;
      });
    });

    if (gaps["1"] === null && gaps["-1"] === null) return s;

    const plus = gaps["1"] || 0;
    const minus = gaps["-1"] || 0;
    const at = add(s.at, mul(f.side, (plus - minus) / 2));
    const snapped = Object.assign({}, s, { at: [round(at[0], 4), round(at[1], 4)], width: g.width + plus + minus });

    if (snapped.width > 4 || stairHitsWall(doc, snapped) && !stairHitsWall(doc, s)) return s;

    return snapped;
  }

  function stairHitsWall(doc, s) {
    const level = levelOf(doc, s.level);
    const sorted = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
    const above = sorted.find(function (l) { return l.z > (Number(level.z) || 0) + 0.5; });

    if (!above) return false;

    const g = stairGeometry(s, level, above);
    const polys = g.spiral ? [g.footprint[0]] : g.footprint;
    let bx0 = Infinity, by0 = Infinity, bx1 = -Infinity, by1 = -Infinity;

    polys.forEach(function (poly) { (poly || []).forEach(function (q) { bx0 = Math.min(bx0, q[0]); by0 = Math.min(by0, q[1]); bx1 = Math.max(bx1, q[0]); by1 = Math.max(by1, q[1]); }); });

    const walls = (doc.walls || []).filter(function (w) {
      if ((w.level || "l1") !== level.id || Math.abs(Number(w.bend) || 0) >= 0.02) return false;

      return Math.max(w.a[0], w.b[0]) > bx0 - 0.3 && Math.min(w.a[0], w.b[0]) < bx1 + 0.3 && Math.max(w.a[1], w.b[1]) > by0 - 0.3 && Math.min(w.a[1], w.b[1]) < by1 + 0.3;
    });

    return walls.some(function (w) {
      const d = sub(w.b, w.a);
      const length = len(d);

      if (length < 0.05) return false;

      const dn = norm(d);
      const n = left(dn);
      const half = Math.max(0.04, (Number(w.thick) || Number(doc.settings && doc.settings.thick) || 0.2) / 2 - 0.02);
      const count = Math.ceil(length / 0.05);

      for (let k = 0; k <= count; k++) {
        const base = add(w.a, mul(dn, length * k / count));

        for (const off of [-half, 0, half]) {
          const q = add(base, mul(n, off));

          if (polys.some(function (poly) { return poly && poly.length > 2 && insidePolygon(q, poly) && distanceToEdges(q, poly) > 0.015; })) return true;
        }
      }

      return false;
    });
  }

  function fitStairs(doc, s, maxR) {
    if (!stairHitsWall(doc, s)) return s.at;

    const h = (Number(s.heading) || 0) * Math.PI / 180;
    const fwd = [Math.cos(h), Math.sin(h)];
    const side = left(fwd);

    for (let r = 0.05; r <= (maxR || 4.0) + 1e-6; r += 0.05) {
      const steps = Math.max(8, Math.round(r / 0.05) * 8);
      let best = null;

      for (let i = 0; i < steps; i++) {
        const a = i / steps * Math.PI * 2;
        const at = add(add(s.at, mul(fwd, Math.cos(a) * r)), mul(side, Math.sin(a) * r));
        const test = Object.assign({}, s, { at: [round(at[0], 3), round(at[1], 3)] });

        if (!stairHitsWall(doc, test)) {
          best = test.at;
          break;
        }
      }

      if (best) return best;
    }

    return null;
  }

  function checks(doc, built, budget) {
    const list = [];
    const d = built.derived;
    const push = function (code, level, text, fix, target) { list.push({ code: code, level: level, text: text, fix: fix || null, target: target || null }); };

    if (!d.rooms.length) push("no-rooms", "bad", "check_no_rooms", null);

    d.ends.forEach(function (end) { push("open-end", "warn", "check_open_end", "join", end.wall + ":" + end.end); });

    const p = doc.points || {};

    if (d.rooms.length) {
      if (!p.exit) push("no-exit", "bad", "check_no_exit", "exit");
      else if (!roomAt(built, p.exit.p, p.exit.p[2])) push("exit-outside", "bad", "check_exit_outside", "exit");

      ["management", "wardrobe", "storage"].forEach(function (name) {
        if (!p[name]) push("no-" + name, "warn", "check_no_" + name, "point:" + name);
      });
    }

    d.rooms.forEach(function (room) {
      const connected = d.openings.some(function (o) { return o.rooms.indexOf(room.id) >= 0 && o.kind !== "window"; }) || d.stairs.some(function (s) { return roomAt(built, s.at, s.z + 0.1) === room; });

      if (!connected && d.rooms.length > 1) push("closed-room", "warn", "check_closed_room", "door", room.id);
      if (!room.record.name) push("room-name", "info", "check_room_name", "name", room.id);
      if (!(doc.lights || []).some(function (l) { return l.p && insidePolygon(l.p, room.points) && Math.abs(l.p[2] - (room.z + room.height)) < 0.6; })) push("room-dark", "info", "check_room_dark", "light", room.id);
    });

    d.openings.forEach(function (o) {
      if (o.kind === "window" && !o.exterior) push("inner-window", "info", "check_inner_window", "opening", o.id);
    });

    const ids = new Map();

    (doc.openings || []).forEach(function (o) {
      const list2 = ids.get(o.wall) || [];

      list2.push(o);
      ids.set(o.wall, list2);
    });
    ids.forEach(function (list2) {
      const sorted = list2.slice().sort(function (a, b) { return (a.t || 0) - (b.t || 0); });

      for (let i = 1; i < sorted.length; i++) {
        const a = sorted[i - 1];
        const b = sorted[i];
        const aw = Number(a.width) || (OPENINGS[a.kind] || OPENINGS.door).width;
        const bw = Number(b.width) || (OPENINGS[b.kind] || OPENINGS.door).width;

        if ((a.t || 0) + aw / 2 + 0.1 > (b.t || 0) - bw / 2) push("overlap", "warn", "check_overlap", "spread", b.id);
      }
    });

    d.warnings.forEach(function (w) { if (w.code === "stairs-top") push("stairs-top", "bad", "check_stairs_top", "level", w.id); });

    (doc.stairs || []).forEach(function (st) { if (stairHitsWall(doc, st)) push("stairs-wall", "warn", "check_stairs_wall", "stairs-fit", st.id); });

    (doc.details || []).forEach(function (det) {
      if (det.kind !== "ladder") return;

      const level = levelOf(doc, det.level);
      const above = (doc.levels || []).some(function (l) { return (Number(l.z) || 0) > (Number(level.z) || 0) + 0.5; });

      if (!above) push("ladder-top", "warn", "check_ladder_top", "level", det.id);
    });

    (doc.props || []).forEach(function (prop) {
      if (!prop.p) return;
      if (!roomAt(built, prop.p, prop.p[2])) push("prop-outside", "warn", "check_prop_outside", "prop", prop.id);
    });

    const limit = Number(budget) || 800;

    if ((doc.props || []).length > limit) push("budget", "bad", "check_budget", "budget", String(limit));
    if (built.pieces.length > 2200) push("pieces", "warn", "check_pieces", null);

    return list;
  }

  function fix(doc, built, item) {
    const d = built.derived;
    const patch = { set: {}, del: {}, root: {} };
    const firstDoor = d.openings.find(function (o) { return o.exterior && (o.kind === "door" || o.kind === "double"); }) || d.openings.find(function (o) { return o.kind === "door"; });
    const roomByType = function (types) {
      return d.rooms.find(function (r) { return types.indexOf(r.record.type) >= 0; }) || d.rooms[0];
    };
    const spotIn = function (room, shift) {
      const a = room.record.anchor || interiorPoint(room.points);

      return [round(a[0] + (shift || 0), 3), round(a[1], 3), round(room.z, 3)];
    };

    if (!item || !item.fix) return null;

    if (item.fix === "exit") {
      let spot = null;
      let heading = 0;

      if (firstDoor) {
        const room = d.rooms.find(function (r) { return r.id === firstDoor.rooms[0]; });
        const edge = room && room.edges.find(function (e) { return e.wall === firstDoor.wall; });
        const inward = edge ? left(norm(sub(edge.b, edge.a))) : firstDoor.n;
        const at = add(firstDoor.c, mul(inward, firstDoor.depth / 2 + 0.7));

        spot = [round(at[0], 3), round(at[1], 3), round(room ? room.z : 0, 3)];
        heading = round(((yaw(inward) - 90) % 360 + 360) % 360, 1);
      } else if (d.rooms.length) {
        spot = spotIn(d.rooms[0]);
      }

      if (!spot) return null;

      patch.root.points = { exit: { p: spot, h: heading } };
    } else if (item.fix.indexOf("point:") === 0) {
      const name = item.fix.slice(6);
      const room = name === "wardrobe" ? roomByType(["bedroom", "kids"]) : name === "storage" ? roomByType(["storage", "hall", "kitchen"]) : roomByType(["living", "office", "hall"]);

      if (!room) return null;

      const value = {};

      value[name] = { p: spotIn(room, name === "wardrobe" ? -0.6 : name === "storage" ? 0.6 : 0), h: 0 };
      patch.root.points = value;
    } else if (item.fix === "join") {
      const parts = String(item.target).split(":");
      const wall = (doc.walls || []).find(function (w) { return w.id === parts[0]; });

      if (!wall) return null;

      const p = wall[parts[1]];
      let best = null;
      let bestDistance = 0.6;

      (doc.walls || []).forEach(function (other) {
        if (other.id === wall.id || (other.level || "l1") !== (wall.level || "l1")) return;

        [other.a, other.b].forEach(function (q) {
          const dist = len(sub(p, q));

          if (dist > 0.001 && dist < bestDistance) {
            bestDistance = dist;
            best = q;
          }
        });

        const dd = norm(sub(other.b, other.a));
        const t = Math.max(0, Math.min(len(sub(other.b, other.a)), dot(sub(p, other.a), dd)));
        const q = add(other.a, mul(dd, t));
        const dist = len(sub(p, q));

        if (dist > 0.001 && dist < bestDistance) {
          bestDistance = dist;
          best = q;
        }
      });

      const changed = clone(wall);

      if (best) {
        changed[parts[1]] = best.map(function (v) { return round(v, 4); });
        patch.set.walls = [changed];
      } else {
        patch.del.walls = [wall.id];
      }
    } else if (item.fix === "door") {
      const room = d.rooms.find(function (r) { return r.id === item.target; });

      if (!room) return null;

      let best = null;

      room.edges.forEach(function (edge) {
        const other = d.rooms.find(function (r) { return r !== room && r.edges.some(function (e) { return e.wall === edge.wall; }); });

        if (!other || edge.length < 1.4) return;
        if (!best || edge.length > best.edge.length) best = { edge: edge, other: other };
      });

      if (!best) return null;

      const wall = (doc.walls || []).find(function (w) { return w.id === best.edge.wall; });
      const wd = norm(sub(wall.b, wall.a));
      const mid = mul(add(best.edge.a, best.edge.b), 0.5);

      patch.set.openings = [{ id: uid("o"), wall: wall.id, kind: "door", t: round(dot(sub(mid, wall.a), wd), 3), door: "plain_white" }];
    } else if (item.fix === "name") {
      const room = d.rooms.find(function (r) { return r.id === item.target; });

      if (!room) return null;

      const changed = clone(room.record);

      changed.name = (changed.type || "room").charAt(0).toUpperCase() + (changed.type || "room").slice(1);
      patch.set.rooms = [changed];
    } else if (item.fix === "light") {
      const room = d.rooms.find(function (r) { return r.id === item.target; });

      if (!room) return null;

      const a = room.record.anchor || interiorPoint(room.points);

      patch.set.lights = [{ id: uid("li"), p: [round(a[0], 3), round(a[1], 3), round(room.z + room.height - 0.01, 3)], shape: "round", colour: "#ffe2bd", range: 7, intensity: 6 }];
    } else if (item.fix === "opening") {
      const o = (doc.openings || []).find(function (x) { return x.id === item.target; });

      if (!o) return null;

      patch.set.openings = [Object.assign(clone(o), { kind: "opening", sill: 0.9, height: 1.2 })];
    } else if (item.fix === "spread") {
      const o = (doc.openings || []).find(function (x) { return x.id === item.target; });

      if (!o) return null;

      const wall = (doc.walls || []).find(function (w) { return w.id === o.wall; });
      const total = wall ? len(sub(wall.b, wall.a)) : 0;
      const others = (doc.openings || []).filter(function (x) { return x.wall === o.wall && x.id !== o.id; });
      const width = Number(o.width) || (OPENINGS[o.kind] || OPENINGS.door).width;
      let best = null;

      for (let t = width / 2 + 0.1; t <= total - width / 2 - 0.1; t += 0.05) {
        const free = others.every(function (x) {
          const xw = Number(x.width) || (OPENINGS[x.kind] || OPENINGS.door).width;

          return Math.abs((x.t || 0) - t) > (xw + width) / 2 + 0.15;
        });

        if (free && (best === null || Math.abs(t - o.t) < Math.abs(best - o.t))) best = t;
      }

      if (best === null) patch.del.openings = [o.id];
      else patch.set.openings = [Object.assign(clone(o), { t: round(best, 3) })];
    } else if (item.fix === "level") {
      const levels = (doc.levels || []).slice().sort(function (a, b) { return a.z - b.z; });
      const top = levels[levels.length - 1];

      patch.set.levels = [{ id: uid("l"), name: "Floor " + (levels.length + 1), z: round(top.z + (top.height || 2.8) + 0.2, 3), height: top.height || 2.8 }];
    } else if (item.fix === "stairs-fit") {
      const st = (doc.stairs || []).find(function (x) { return x.id === item.target; });
      const at = st ? fitStairs(doc, st) : null;

      if (!st || !at) return null;

      patch.set.stairs = [Object.assign(clone(st), { at: at })];
    } else if (item.fix === "prop") {
      patch.del.props = [item.target];
    } else if (item.fix === "budget") {
      const limit = Number(item.target) || 800;
      const props = (doc.props || []).slice(limit);

      patch.del.props = props.map(function (x) { return x.id; });
    } else {
      return null;
    }

    return patch;
  }

  function scheme(doc, built, id) {
    const s = SCHEMES[id];

    if (!s) return null;

    const rooms = built.derived.rooms.map(function (room) {
      const record = clone(room.record);

      record.walls = record.type === "bathroom" ? s.bathwalls : s.walls;
      record.floor = s.floors[record.type] || s.floors._;
      record.ceiling = s.ceiling;

      return record;
    });

    return { set: { rooms: rooms }, root: { settings: { skirting: s.skirting } } };
  }

  function toProject(doc, kit, options) {
    const o = options || {};
    const built = build(doc, kit, { exact: true });
    const d = built.derived;
    const byKey = new Map(((kit && kit.materials) || []).map(function (m) { return [m.key, m]; }));
    const used = new Map();
    const materialId = function (key) {
      if (!key) return "walls";
      if (used.has(key)) return used.get(key).id;

      let entry;

      const kitMat = byKey.get(key) || {};

      const tint = tintOf(key);

      if (slotOf(key)) entry = { id: "m_" + key, source: "builtin", builtin: "plaster_white", colour: (doc.colours || {})[key] || "#d8d8d8" };
      else if (tint) entry = { id: "m_" + key, source: "builtin", builtin: tint.builtin, colour: tint.colour };
      else if (o.images && o.images[key]) entry = { id: "m_" + key, source: "image", image: "kit/" + key, builtin: kitMat.builtin || "plaster_white", scale: Number(kitMat.repeat) || 2, surface: kitMat.surface, shine: 0.15, bump: 0.6 };
      else entry = { id: "m_" + key, source: "builtin", builtin: kitMat.builtin || "plaster_white" };

      used.set(key, entry);

      return entry.id;
    };
    const p = {
      format: "rtx-mlo", version: 1, name: o.name || "rtx_shell", title: doc.name || "", output: o.output === "mlo" ? "mlo" : "shell",
      placement: { position: o.position || [0, 0, 0], heading: Number(o.heading) || 0 },
      settings: { wallThickness: Number(doc.settings && doc.settings.thick) || 0.2, slabThickness: 0.2, roomHeight: 2.8, exterior: o.output === "mlo", lod: o.output === "mlo", lodFar: 800, occlusion: false, shellParts: "single", lodDist: 200, grid: 0.25 },
      materials: [], exteriorMaterial: "", roofMaterial: "",
      rooms: [], openings: [], holes: [], stairs: [], blocks: [], objects: [], models: [], lights: [], decals: [], mirrors: [], entitySets: [], timecycles: [], extras: [], faces: {}, patches: [],
      housing: { label: doc.name || "", tags: ["RTX", "Toolkit"], points: [] }
    };
    const wallById = new Map((doc.walls || []).map(function (w) { return [w.id, w]; }));

    d.rooms.forEach(function (room, index) {
      const record = room.record;
      const edgeMaterials = {};

      room.edges.forEach(function (edge, i) {
        const wall = wallById.get(edge.wall) || {};
        const own = edge.side === "l" ? wall.ml : wall.mr;

        if (own) edgeMaterials[i] = materialId(own);
      });
      p.rooms.push({
        id: room.id, name: (record.name || record.type || "room_" + (index + 1)).toLowerCase().replace(/[^a-z0-9]+/g, "_").slice(0, 20) || "room_" + (index + 1),
        points: room.points.map(function (pt) { return [round(pt[0], 4), round(pt[1], 4)]; }), floor: room.z, height: room.height,
        wallMaterial: materialId(record.walls || "white"), floorMaterial: materialId(record.floor || "oak"), ceilingMaterial: materialId(record.ceiling || "ceil"),
        edgeMaterials: edgeMaterials, ceiling: record.ceilingOff !== true && !roofOf(doc, levelOf(doc, room.level)), timecycle: "", flags: 0
      });

      const tiles = record.tiles || {};
      const keys = Object.keys(tiles).filter(function (k) { return tiles[k] && tiles[k] !== (record.floor || "oak"); });

      if (keys.length) {
        const f = tileFrame(room);
        const mats = [];
        let maxI = 0;
        let maxJ = 0;
        let minI = Infinity;
        let minJ = Infinity;

        keys.forEach(function (k) {
          const ij = k.split(",").map(Number);

          minI = Math.min(minI, ij[0]); minJ = Math.min(minJ, ij[1]);
          maxI = Math.max(maxI, ij[0]); maxJ = Math.max(maxJ, ij[1]);
          if (mats.indexOf(tiles[k]) < 0) mats.push(tiles[k]);
        });

        const nx = maxI - minI + 1;
        const ny = maxJ - minJ + 1;
        const codes = new Int16Array(nx * ny);

        keys.forEach(function (k) {
          const ij = k.split(",").map(Number);

          codes[(ij[1] - minJ) * nx + (ij[0] - minI)] = 10 + mats.indexOf(tiles[k]);
        });

        largestRects(codes, nx, ny).forEach(function (r, n) {
          const x0 = f.minx + (r[0] + minI) * f.size;
          const y0 = f.miny + (r[1] + minJ) * f.size;
          const x1 = Math.min(f.maxx, f.minx + (r[2] + minI) * f.size);
          const y1 = Math.min(f.maxy, f.miny + (r[3] + minJ) * f.size);
          const pt = function (x, y) { const q = add(mul(f.ax, x), mul(f.ay, y)); return [round(q[0], 4), round(q[1], 4)]; };

          if (x1 - x0 < 0.01 || y1 - y0 < 0.01) return;

          p.patches.push({ id: "tile_" + room.id + "_" + n, room: room.id, on: "floor", points: [pt(x0, y0), pt(x1, y0), pt(x1, y1), pt(x0, y1)], material: materialId(mats[r[4] - 10]) });
        });
      }
    });

    const presets = { front: "door_wood", office: "door_oak", shop: "door_steel_dark", fire: "door_metal", plain_white: "door_white", plain_dark: "door_dark", plain_oak: "door_oak", bath: "door_white", warehouse: "door_metal", prison: "door_steel_dark", boarded: "door_wood", glass_full: "door_black", glass_half: "door_white", glass_small: "door_oak", glass_white: "door_white", panels6_white: "door_white", panels4_oak: "door_oak", panels2_dark: "door_dark", panels6_black: "door_black", planks: "door_wood", louvres: "door_white", stable: "door_green", red: "door_red", green: "door_green", blue: "door_blue", steel: "door_steel_dark", metal: "door_metal", oak_flat: "door_oak", walnut: "door_wood" };

    d.openings.forEach(function (op) {
      const room = d.rooms.find(function (r) { return r.id === op.rooms[0]; });

      if (!room) return;

      const edgeIndex = room.edges.findIndex(function (e) { return e.wall === op.wall && (e.holes || []).some(function (h) { return h.opening === op.id; }); });

      if (edgeIndex < 0) return;

      const edge = room.edges[edgeIndex];
      const hole = edge.holes.find(function (h) { return h.opening === op.id; });
      if (op.fake) return;

      const kind = DOOR_KINDS[op.kind] === 1 ? "door" : DOOR_KINDS[op.kind] === 2 ? "double" : WINDOW_KINDS.indexOf(op.kind) >= 0 ? "window" : "opening";
      const item = { id: op.id, kind: kind, room: room.id, edge: edgeIndex, offset: round((hole.u0 + hole.u1) / 2, 4), width: round(hole.u1 - hole.u0, 4), height: round(op.z1 - op.z0, 4), sill: round(op.z0, 4), glass: kind === "window" ? op.glass !== false && op.glass !== "none" : false, portal: true };

      if (op.shape && op.shape !== "rect") item.shape = op.shape;
      if (kind === "door" || kind === "double") item.leaf = { style: presets[op.door] || "door_white", hinge: op.flip ? "right" : "left" };
      if (kind === "window" && op.exterior) {
        const view = op.view === undefined ? doc.settings && doc.settings.view : op.view;

        if (view && view !== "none") item.fake = { kind: view };
        else if (op.glass === "frosted") item.fake = { kind: "frosted" };
      }

      p.openings.push(item);
    });

    d.stairs.forEach(function (s) {
      const mat = materialId(s.material === "steel" ? "steel" : s.material);

      if (s.spiral) {
        p.blocks.push({ id: s.id + "_spiral", kind: "spiral", position: [round(s.spiral.centre[0], 4), round(s.spiral.centre[1], 4), s.z], rotation: [0, 0, round(s.spiral.start, 2)], size: [round(s.spiral.radius * 2, 3), round(s.spiral.radius * 2, 3), round(s.rise, 4)], angle: s.spiral.count * s.spiral.angle, count: s.spiral.count, clockwise: s.spiral.sign < 0, railing: s.rail, material: mat });
        return;
      }

      s.flights.forEach(function (f, index) {
        const heading = round(Math.atan2(-f.fwd[0], f.fwd[1]) * 180 / Math.PI, 2);

        p.stairs.push({ id: s.id + (index ? "_" + index : ""), position: [round(f.at[0], 4), round(f.at[1], 4), round(s.z + f.first * s.stepRise, 4)], heading: heading, width: f.width || s.width, rise: round(f.count * s.stepRise, 4), run: round(f.count * s.stepRun, 4), steps: f.count, material: mat, railing: s.rail ? "both" : "" });
      });
      s.landings.forEach(function (landing, index) {
        const centre = add(landing.at, mul(landing.fwd, landing.depth / 2));

        p.blocks.push({ id: s.id + "_landing" + index, kind: "box", position: [round(centre[0], 4), round(centre[1], 4), round(s.z + landing.top - 0.2, 4)], rotation: [0, 0, round(Math.atan2(-landing.fwd[0], landing.fwd[1]) * 180 / Math.PI, 2)], size: [round(landing.width, 3), round(landing.depth, 3), 0.2], material: mat });
      });
    });

    const prefix = (kit && kit.prefix) || "rtx_tk_";
    const quadSizes = function (code) {
      const list = quadKit || (kit && kit.quads) || null;

      if (!list) return null;

      const u = list.u[list.code.indexOf(code[0])];
      const v = list.v[list.code.indexOf(code[1])];

      return u && v ? [u[0], v[0]] : null;
    };
    const asBlocks = function (list, idBase) {
      list.forEach(function (piece, index) {
        const name = String(piece[0]).slice(prefix.length);
        const pitch = Number(piece[4]) || 0;
        const roll = Number(piece[8]) || 0;
        const yw = Number(piece[5]) || 0;
        const ax = axesOf(pitch, roll, yw);
        const o = [Number(piece[1]), Number(piece[2]), Number(piece[3])];
        const at = function (x, y, z) { return [0, 1, 2].map(function (k) { return o[k] + ax[0][k] * x + ax[1][k] * y + ax[2][k] * z; }); };
        const id = idBase + "_" + index;
        let m;

        const beam = /^beam_(.+)_([ab])$/.exec(name);

        if (beam || (m = /^box_(.+)$/.exec(name))) {
          if (beam) m = beam;

          const bigBox = !beam && /_b$/.test(m[1]) && kit && kit.bigBoxes && kit.bigBoxes.materials.indexOf(m[1].slice(0, -2)) >= 0;

          if (bigBox) m = [m[0], m[1].slice(0, -2)];

          const boxBase = bigBox ? kit.bigBoxes.size : 1;
          const beamLength = beam ? ((kit && kit.beams && kit.beams.sizes || []).find(function (b) { return b.code === beam[2]; }) || { size: 1 }).size : boxBase;
          const section = beam ? (kit && kit.beams && kit.beams.section) || 0.1 : boxBase;
          const sx = (Number(piece[6]) || 1) * beamLength;
          const sz = (Number(piece[7]) || 1) * section;
          const sy = (Number(piece[9]) || 1) * section;
          const c = at(sx / 2, sy / 2, 0);

          p.blocks.push({ id: id, kind: "box", position: c.map(function (v) { return round(v, 4); }), rotation: [round(pitch, 3), round(roll, 3), round(yw, 3)], size: [round(sx, 4), round(sy, 4), round(sz, 4)], material: materialId(m[1]) });
          return;
        }

        let w = 0;
        let h = 0;
        let mat = "";

        if (piece.trim) {
          w = piece.trim.sx;
          h = piece.trim.sz;
          mat = piece.trim.mat;
        } else if ((m = /^(.+)_q([0-9a-j])([0-9a-j])$/.exec(name))) {
          const size = quadSizes(m[2] + m[3]);

          if (!size) return;

          w = size[0] * (Number(piece[6]) || 1);
          h = size[1] * (Number(piece[7]) || 1);
          mat = m[1];
        } else {
          return;
        }

        if (w < 0.004 || h < 0.004 || mat === "water") return;

        const c = at(w / 2, 0, h / 2);

        p.blocks.push({ id: id, kind: "plane", position: c.map(function (v) { return round(v, 4); }), rotation: [round(pitch - 90, 3), round(roll, 3), round(yw, 3)], size: [round(w, 4), round(h, 4), 0.01], material: materialId(mat) });
      });
    };
    const byTag = new Map();

    built.pieces.forEach(function (piece) {
      if (!piece.tag) return;
      if (!byTag.has(piece.tag)) byTag.set(piece.tag, []);
      byTag.get(piece.tag).push(piece);
    });

    asBlocks(byTag.get("roof") || [], "roof");
    asBlocks(byTag.get("mould") || [], "mould");

    d.details.forEach(function (det) {
      if (det.kind === "void") return;

      const heading = round(Math.atan2(det.ax[1], det.ax[0]) * 180 / Math.PI, 2);

      if (det.kind === "ladder") {
        p.extras.push({ id: det.id, kind: "ladder", position: [round(det.at[0], 4), round(det.at[1], 4), round(det.z, 4)], heading: round(((det.heading + 180) % 360 + 360) % 360, 2), height: round(det.climb, 3), width: 0.5, material: LADDER_WOODS.indexOf(det.mat) >= 0 ? "wood" : "metal", round: LADDER_WOODS.indexOf(det.mat) < 0, top: true, bottom: true });
        return;
      }

      if (["pergola", "glassrail", "rail", "pillar", "column"].indexOf(det.kind) < 0 && byTag.has("det:" + det.id)) {
        asBlocks(byTag.get("det:" + det.id), det.id);
        return;
      }

      const tall = det.h === 0 ? det.height - (det.lift || 0) : det.h;
      const z = det.kind === "beam" ? det.z + det.height - det.h : det.kind === "balcony" ? det.z - det.h : det.z + (det.lift || 0);

      if (det.kind === "pergola") {
        [[-1, -1], [1, -1], [1, 1], [-1, 1]].forEach(function (c, index) {
          const at = add(add(det.at, mul(det.ax, c[0] * (det.w / 2 - 0.07))), mul(det.ay, c[1] * (det.d / 2 - 0.07)));

          p.blocks.push({ id: det.id + "_post" + index, kind: "box", position: [round(at[0], 4), round(at[1], 4), round(z, 4)], rotation: [0, 0, heading], size: [0.14, 0.14, round(tall, 3)], material: materialId(det.mat) });
        });
        return;
      }

      if (det.kind === "shower" || det.kind === "mirror") return;

      if (det.kind === "glassrail" || det.kind === "rail") {
        p.blocks.push({ id: det.id, kind: "railing", position: [round(det.at[0], 4), round(det.at[1], 4), round(z, 4)], rotation: [0, 0, heading], size: [round(det.w, 3), 0.06, round(tall, 3)], material: materialId("steel") });
        return;
      }

      p.blocks.push({ id: det.id, kind: det.kind === "pillar" ? "cylinder" : "box", position: [round(det.at[0], 4), round(det.at[1], 4), round(z, 4)], rotation: [0, 0, heading], size: [round(det.w, 3), round(det.d, 3), round(tall, 3)], material: materialId(det.mat) });
    });

    d.pools.forEach(function (pool) {
      const tile = materialId(pool.tile);
      const heading = round(Math.atan2(pool.ax[1], pool.ax[0]) * 180 / Math.PI, 2);
      const bottom = pool.z - pool.depth;

      p.blocks.push({ id: pool.id + "_floor", kind: "box", position: [round(pool.at[0], 4), round(pool.at[1], 4), round(bottom - 0.2, 4)], rotation: [0, 0, heading], size: [pool.w + 0.4, pool.l + 0.4, 0.2], material: tile });
      [[0, pool.l / 2 + 0.1, pool.w + 0.4, 0.2], [0, -pool.l / 2 - 0.1, pool.w + 0.4, 0.2], [pool.w / 2 + 0.1, 0, 0.2, pool.l], [-pool.w / 2 - 0.1, 0, 0.2, pool.l]].forEach(function (side, index) {
        const at = add(add(pool.at, mul(pool.ax, side[0])), mul(pool.ay, side[1]));

        p.blocks.push({ id: pool.id + "_side" + index, kind: "box", position: [round(at[0], 4), round(at[1], 4), round(bottom, 4)], rotation: [0, 0, heading], size: [side[2], side[3], round(pool.depth, 3)], material: tile });
      });
    });

    d.holes.forEach(function (h, index) {
      const room = d.rooms.find(function (r) { return r.level === h.level && h.points.some(function (pt) { return insidePolygon(pt, r.points); }); });

      if (room) p.holes.push({ id: "hole_" + (h.stair || h.pool || "x") + "_" + index, room: room.id, points: h.points.map(function (pt) { return [round(pt[0], 4), round(pt[1], 4)]; }) });
    });

    (doc.lights || []).forEach(function (light, index) {
      if (!light.p) return;

      const hex = String(light.colour || "#ffe2bd").replace("#", "");

      p.lights.push({ id: light.id || "light" + (index + 1), position: [light.p[0], light.p[1], round(light.p[2] - 0.05, 3)], type: "point", color: [parseInt(hex.substr(0, 2), 16), parseInt(hex.substr(2, 2), 16), parseInt(hex.substr(4, 2), 16)], intensity: Number(light.intensity) || 6, falloff: Number(light.range) || 7 });
    });

    if (o.output === "mlo") {
      (doc.props || []).forEach(function (prop, index) {
        if (!prop.model || !prop.p) return;

        p.objects.push({ id: prop.id || "obj" + (index + 1), model: String(prop.model).toLowerCase(), position: prop.p, rotation: prop.r || [0, 0, 0] });
      });
    }

    p.materials = Array.from(used.values());

    if (!p.materials.some(function (m) { return m.id === "walls"; })) p.materials.push({ id: "walls", source: "builtin", builtin: "plaster_white" });

    return { project: p, built: built };
  }

  const API = {
    tileCell: tileCell, tileFrame: tileFrame, alignTiles: alignTiles, tilePoints: tilePoints, ROOF_TYPES: ROOF_TYPES, roofOf: roofOf, EPS: EPS, CELL: CELL, SIZES: SIZES, CODES: CODES, OPENINGS: OPENINGS, STAIR_TYPES: STAIR_TYPES, WINDOW_KINDS: WINDOW_KINDS, DOOR_KINDS: DOOR_KINDS, BAR_KINDS: BAR_KINDS, RING_MATERIALS: RING_MATERIALS, LAMP_SHAPES: LAMP_SHAPES, SPIRAL_SIZES: SPIRAL_SIZES, DETAILS: DETAILS, DETAIL_GROUPS: DETAIL_GROUPS, PILLAR_MATERIALS: PILLAR_MATERIALS, detailShape: detailShape, ROOM_TYPES: ROOM_TYPES, SCHEMES: SCHEMES, COLLECTIONS: COLLECTIONS,
    round: round, clone: clone, uid: uid, blank: blank, apply: apply, inverse: inverse, wallPoints: wallPoints, wallLength: wallLength,
    derive: derive, build: build, layout: layout, checks: checks, fix: fix, stairHitsWall: stairHitsWall, fitStairs: fitStairs, scheme: scheme, toProject: toProject, rectangleWalls: rectangleWalls, collinearMerge: collinearMerge,
    copButtons: copButtons, insidePolygon: insidePolygon, distanceToEdges: distanceToEdges, polygonArea: polygonArea, interiorPoint: interiorPoint, roomAt: roomAt, nearestRoom: nearestRoom, levelOf: levelOf,
    vec: { sub: sub, add: add, mul: mul, dot: dot, cross: cross, len: len, norm: norm, left: left, yaw: yaw },
    internals: { decompose: function (a, b, list, mat) { return decompose(a, b, list, mat); }, axesOf: axesOf, boxPiece: function (kitBeams, pieces, mat, p0, dir, w, d, z0, h) { beamKit = kitBeams; boxPiece(pieces, "rtx_tk_", mat, p0, dir, w, d, z0, h); beamKit = null; } }
  };

  root.RTX_SHELLGEO = API;

  if (typeof module !== "undefined" && module.exports) module.exports = API;
})(typeof globalThis !== "undefined" ? globalThis : this);
