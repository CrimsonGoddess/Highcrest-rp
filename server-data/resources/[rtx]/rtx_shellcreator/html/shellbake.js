(function (root) {
  const SB = {};
  const POOL_TRIMS = { t: "q00", tab: "q03", tba: "q30", tbb: "q33" };
  const POOL_KINDS = { box: true, prism: true, beam: true, archfill: true, roundfill: true };
  const BOX_CHUNK = 2400;

  SB.parse = function (bytes) {
    const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    const magic = String.fromCharCode(bytes[0], bytes[1], bytes[2], bytes[3]);

    if (magic !== "RTXK") throw new Error("kitmesh.bin is damaged");

    const length = view.getUint32(4, true);
    const header = JSON.parse(new TextDecoder().decode(bytes.subarray(8, 8 + length)));
    let data = bytes.subarray(8 + length);

    if ((data.byteOffset & 3) !== 0) data = data.slice();

    header.data = data;
    header.cache = {};

    return header;
  };

  SB.texBytes = function (km, name) {
    const at = km.t[name];

    return at ? km.data.subarray(at[0], at[0] + at[1]) : null;
  };

  function geometry(km, index) {
    if (km.cache[index]) return km.cache[index];

    const g = km.g[index];
    const buf = km.data.buffer;
    const base = km.data.byteOffset;
    const f32 = function (o, l) { return l ? new Float32Array(buf, base + o, l / 4) : null; };
    const out = {
      positions: f32(g[0], g[1]),
      normals: f32(g[2], g[3]),
      uvs: f32(g[4], g[5]),
      colours: g[7] ? new Uint8Array(buf, base + g[6], g[7]) : null,
      indices: new Uint16Array(buf, base + g[8], g[9] / 2)
    };

    km.cache[index] = out;

    return out;
  }

  function poolSplit(kit, rest) {
    const P = kit.pool;

    if (!P) return null;

    let m;
    let mat = null;
    let shape = null;

    if ((m = /^([a-z0-9]+)_(q[a-z0-9]{2})$/.exec(rest))) { mat = m[1]; shape = m[2]; }
    else if ((m = /^([a-z0-9]+)_(t[a-z]?[a-z]?)$/.exec(rest))) { mat = m[1]; shape = POOL_TRIMS[m[2]] || m[2]; }
    else if ((m = /^([a-z]+)_([a-z0-9]+)_([a-z])$/.exec(rest)) && POOL_KINDS[m[1]]) { mat = m[2]; shape = m[1] + "_" + m[3]; }
    else if ((m = /^([a-z]+)_([a-z0-9]+)$/.exec(rest)) && (m[1] === "box" || m[1] === "prism" || m[1] === "bk")) { mat = m[2]; shape = m[1]; }
    else if ((m = /^curve_([a-z0-9]+)_([a-z0-9_]+)$/.exec(rest))) { mat = m[1]; shape = "curve_" + m[2]; }

    if (!mat || !P.mats[mat] || !P.shapes[shape]) return null;

    return { mat: mat, shape: shape, model: P.prefix.replace(/^rtx_tk_/, "") + P.shapes[shape][0] };
  }

  function resolve(kit, km, name) {
    const rest = String(name).replace(/^rtx_tk_/, "");
    const pool = poolSplit(kit, rest);

    if (pool && km.m[pool.model]) return { key: pool.model, model: km.m[pool.model], mat: pool.mat, flat: !!(kit.pool.flat && kit.pool.flat[pool.shape]) };
    if (km.m[rest]) return { key: rest, model: km.m[rest] };

    return null;
  }

  function hexColour(hex, fallback) {
    const h = String(hex || "").replace("#", "");

    if (!/^[0-9a-fA-F]{6}$/.test(h)) return fallback;

    return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
  }

  function partTextures(kit, km, part, hit, row, colours) {
    const tex = {};
    let shader = part[1];
    const params = Object.assign({}, part[3]);
    const names = part[2];

    Object.keys(names).forEach(function (sampler) {
      let t = names[sampler];
      const pool = /^x\d+([ns]?)$/.exec(t);

      if (pool && hit.mat && !hit.flat) {
        if (pool[1] === "") t = /^s[1-6]$/.test(hit.mat) ? "@slot:" + hit.mat : /^c[1-6]$/.test(hit.mat) ? "@custom:" + hit.mat : hit.mat;
        else t = hit.mat + "_" + pool[1];
      } else if (pool && hit.mat && hit.flat) {
        t = pool[1] === "" ? "@flat:" + hit.mat : km.poolAlias[t] || null;
      } else if (pool) {
        t = km.poolAlias[t] || null;
      }

      if (sampler === "TintPaletteSampler") return;
      if (shader === "normal_spec_tnt" && sampler === "DiffuseSampler") t = "@tint:" + t + ":" + (row || 0);
      if (t) tex[sampler] = t;
    });

    if (shader === "normal_spec_tnt") {
      shader = "normal_spec";
      delete params.tintPaletteSelector;
    }

    return { shader: shader, textures: tex, params: params };
  }

  SB.plan = function (kit, km, built, colours) {
    const server = new Set();
    const embedded = new Set();
    const missing = new Set();
    const add = function (t) {
      if (!t) return;

      if (t.indexOf("@custom:") === 0) server.add(t.slice(8));
      else if (t.indexOf("@tint:") === 0) embedded.add(t.split(":")[1]);
      else if (t.indexOf("@") === 0) return;
      else if (km.t[t]) embedded.add(t);
      else server.add(t);
    };
    const visit = function (name, row) {
      const rest = String(name).replace(/^rtx_tk_/, "");

      if (/^(fx|cx)_/.test(rest)) return;

      const hit = resolve(kit, km, name);

      if (!hit) { missing.add(rest); return; }

      hit.model.p.forEach(function (part) {
        const look = partTextures(kit, km, part, hit, row, colours);

        Object.keys(look.textures).forEach(function (s) { add(look.textures[s]); });
      });
    };

    (built.pieces || []).forEach(function (p) {
      if (typeof p[13] === "number") return;
      visit(p[0], p[11]);
    });


    return { server: Array.from(server), embedded: Array.from(embedded), missing: Array.from(missing) };
  };

  function axes(pitch, roll, yaw) {
    const r = Math.PI / 180;
    const p = (pitch || 0) * r;
    const ro = (roll || 0) * r;
    const y = (yaw || 0) * r;
    const cp = Math.cos(p), sp = Math.sin(p), cr = Math.cos(ro), sr = Math.sin(ro), cy = Math.cos(y), sy = Math.sin(y);
    const m = [[cr, 0, sr], [sp * sr, cp, -sp * cr], [-cp * sr, sp, cp * cr]];
    const z = [[cy, -sy, 0], [sy, cy, 0], [0, 0, 1]];
    const o = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];

    for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) o[i][j] = z[i][0] * m[0][j] + z[i][1] * m[1][j] + z[i][2] * m[2][j];

    return { right: [o[0][0], o[1][0], o[2][0]], fwd: [o[0][1], o[1][1], o[2][1]], up: [o[0][2], o[1][2], o[2][2]] };
  }

  function num(v, d) {
    const n = Number(v);

    return v === null || v === undefined || !isFinite(n) ? d : n;
  }

  function matrixOf(x, y, z, pitch, yaw, roll, sx, sy, sz) {
    const a = axes(pitch, roll, yaw);

    return { r: a.right, f: a.fwd, u: a.up, s: [sx, sy, sz], t: [x, y, z] };
  }

  function apply(M, x, y, z) {
    const X = x * M.s[0];
    const Y = y * M.s[1];
    const Z = z * M.s[2];

    return [M.t[0] + M.r[0] * X + M.f[0] * Y + M.u[0] * Z, M.t[1] + M.r[1] * X + M.f[1] * Y + M.u[1] * Z, M.t[2] + M.r[2] * X + M.f[2] * Y + M.u[2] * Z];
  }

  function makeImage(width, height, fill) {
    const rgba = new Uint8Array(width * height * 4);

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const c = fill(x, y);
        const i = (y * width + x) * 4;

        rgba[i] = c[0]; rgba[i + 1] = c[1]; rgba[i + 2] = c[2]; rgba[i + 3] = c[3] === undefined ? 255 : c[3];
      }
    }

    return { width: width, height: height, rgba: rgba };
  }

  function slotImage(colour) {
    return makeImage(32, 32, function (x, y) {
      const seed = Math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
      const noise = 0.95 + (seed - Math.floor(seed)) * 0.08;

      return [Math.min(255, Math.floor(colour[0] * noise)), Math.min(255, Math.floor(colour[1] * noise)), Math.min(255, Math.floor(colour[2] * noise))];
    });
  }

  function hasAlpha(img) {
    for (let i = 3; i < img.rgba.length; i += 4) if (img.rgba[i] < 250) return true;

    return false;
  }

  function fit(img, max) {
    let cur = img;

    while (cur.width > max || cur.height > max) {
      const w = Math.max(1, cur.width >> 1);
      const h = Math.max(1, cur.height >> 1);
      const out = new Uint8Array(w * h * 4);

      for (let y = 0; y < h; y++) {
        for (let x = 0; x < w; x++) {
          for (let k = 0; k < 4; k++) {
            const a = ((y * 2) * cur.width + x * 2) * 4 + k;
            const b = a + 4;
            const c = a + cur.width * 4;
            const d = c + 4;

            out[(y * w + x) * 4 + k] = (cur.rgba[a] + cur.rgba[b] + cur.rgba[c] + cur.rgba[d] + 2) >> 2;
          }
        }
      }

      cur = { width: w, height: h, rgba: out };
    }

    return cur;
  }

  function pow2(img) {
    const p = function (v) { let n = 4; while (n < v && n < 1024) n *= 2; return n; };
    const w = p(img.width);
    const h = p(img.height);

    if (w === img.width && h === img.height) return img;

    const out = new Uint8Array(w * h * 4);

    for (let y = 0; y < h; y++) {
      const sy = Math.min(img.height - 1, Math.floor(y * img.height / h));

      for (let x = 0; x < w; x++) {
        const sx = Math.min(img.width - 1, Math.floor(x * img.width / w));
        const s = (sy * img.width + sx) * 4;
        const d = (y * w + x) * 4;

        out[d] = img.rgba[s]; out[d + 1] = img.rgba[s + 1]; out[d + 2] = img.rgba[s + 2]; out[d + 3] = img.rgba[s + 3];
      }
    }

    return { width: w, height: h, rgba: out };
  }

  SB.bake = function (o) {
    const MM = o.MM || root.MM;
    const kit = o.kit;
    const km = o.km;
    const images = o.images || {};
    const colours = o.colours || {};
    const built = o.built;
    const name = String(o.name);
    const size = Number(o.textureSize) || 512;
    const buckets = new Map();
    const boxes = [];
    const missing = new Set();
    const report = { pieces: 0, skipped: 0, colliders: 0, boxes: 0, lights: 0, triangles: 0, materials: 0, textures: 0 };
    const sizes = (kit.colliders && kit.colliders.sizes) || [];
    const depth = (kit.colliders && kit.colliders.depth) || 0.1;

    const bucketOf = function (look) {
      const key = look.shader + "|" + JSON.stringify(look.textures) + "|" + JSON.stringify(look.params);
      let b = buckets.get(key);

      if (!b) {
        b = { look: look, positions: [], normals: [], uvs: [], colours: [], indices: [], count: 0 };
        buckets.set(key, b);
      }

      return b;
    };

    const addBox = function (M, min, max, mat, surface) {
      const C = mat || [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0];
      const corners = [];

      for (let i = 0; i < 8; i++) {
        const lx = i & 1 ? max[0] : min[0];
        const ly = i & 2 ? max[1] : min[1];
        const lz = i & 4 ? max[2] : min[2];
        const x = C[9] + lx * C[0] + ly * C[3] + lz * C[6];
        const y = C[10] + lx * C[1] + ly * C[4] + lz * C[7];
        const z = C[11] + lx * C[2] + ly * C[5] + lz * C[8];

        corners.push(apply(M, x, y, z));
      }

      boxes.push({ c: corners, surface: surface || 0 });
    };

    const addModel = function (hit, M, row, collide) {
      const det = M.s[0] * M.s[1] * M.s[2];
      const flip = det < 0;
      const inv = [1 / (Math.abs(M.s[0]) > 1e-6 ? M.s[0] : 1e-6), 1 / (Math.abs(M.s[1]) > 1e-6 ? M.s[1] : 1e-6), 1 / (Math.abs(M.s[2]) > 1e-6 ? M.s[2] : 1e-6)];

      hit.model.p.forEach(function (part) {
        let look = partTextures(kit, km, part, hit, row, colours);

        if (o.plain && look.textures.DiffuseSampler) look = { shader: "default", textures: { DiffuseSampler: look.textures.DiffuseSampler }, params: {} };

        const g = geometry(km, part[0]);
        const b = bucketOf(look);
        const n = g.positions.length / 3;
        const start = b.count;

        for (let i = 0; i < n; i++) {
          const p = apply(M, g.positions[i * 3], g.positions[i * 3 + 1], g.positions[i * 3 + 2]);
          const nx = g.normals[i * 3] * inv[0];
          const ny = g.normals[i * 3 + 1] * inv[1];
          const nz = g.normals[i * 3 + 2] * inv[2];
          let wx = M.r[0] * nx + M.f[0] * ny + M.u[0] * nz;
          let wy = M.r[1] * nx + M.f[1] * ny + M.u[1] * nz;
          let wz = M.r[2] * nx + M.f[2] * ny + M.u[2] * nz;
          const l = Math.hypot(wx, wy, wz) || 1;

          wx /= l; wy /= l; wz /= l;
          b.positions.push(p[0], p[1], p[2]);
          b.normals.push(wx, wy, wz);

          if (g.uvs) b.uvs.push(g.uvs[i * 2], g.uvs[i * 2 + 1]);
          else b.uvs.push(0, 0);

          if (g.colours) b.colours.push(g.colours[i * 4], g.colours[i * 4 + 1], g.colours[i * 4 + 2], g.colours[i * 4 + 3]);
          else b.colours.push(255, 255, 255, 255);
        }

        for (let i = 0; i < g.indices.length; i += 3) {
          if (flip) b.indices.push(start + g.indices[i], start + g.indices[i + 2], start + g.indices[i + 1]);
          else b.indices.push(start + g.indices[i], start + g.indices[i + 1], start + g.indices[i + 2]);
        }

        b.count += n;
        report.triangles += g.indices.length / 3;
      });

      if (collide && hit.model.b) {
        hit.model.b.forEach(function (box) {
          addBox(M, box.slice(0, 3), box.slice(3, 6), box.slice(6, 18), box[18]);
        });
      }
    };

    (built.pieces || []).forEach(function (p) {
      const pname = String(p[0]);
      const rest = pname.replace(/^rtx_tk_/, "");

      if (typeof p[13] === "number") { report.skipped++; return; }
      if (/^fx_/.test(rest)) return;

      const sx = num(p[6], 1);
      const sz = num(p[7], 1);
      const sy = num(p[9], 1);
      const M = matrixOf(num(p[1], 0), num(p[2], 0), num(p[3], 0), num(p[4], 0), num(p[5], 0), num(p[8], 0), sx, sy, sz);
      const cx = /^cx_(\d+)_(\d+)$/.exec(rest);

      if (cx) {
        const w = sizes[Number(cx[1])];
        const h = sizes[Number(cx[2])];

        if (w && h && Number(p[10]) !== 1) {
          addBox(M, [0, 0, 0], [w, depth, h], null, 1);
          report.colliders++;
        }

        return;
      }

      const hit = resolve(kit, km, pname);

      if (!hit) { missing.add(rest); return; }

      const scaled = Math.abs(sx - 1) > 0.0001 || Math.abs(sy - 1) > 0.0001 || Math.abs(sz - 1) > 0.0001;
      const noCol = Number(p[10]) === 1 || (scaled && (pname.indexOf("_bar_") >= 0 || pname.indexOf("_rail_") >= 0 || pname.slice(-3) === "_dd"));

      addModel(hit, M, p[11], !noCol);
      report.pieces++;
    });

    (built.meshes || []).forEach(function (m) {
      const look = { shader: m.shader, textures: m.textures, params: m.params || {} };
      const b = bucketOf(look);
      const n = m.positions.length / 3;
      const start = b.count;

      for (let i = 0; i < n; i++) {
        b.positions.push(m.positions[i * 3], m.positions[i * 3 + 1], m.positions[i * 3 + 2]);
        b.normals.push(m.normals[i * 3], m.normals[i * 3 + 1], m.normals[i * 3 + 2]);
        b.uvs.push(m.uvs[i * 2], m.uvs[i * 2 + 1]);
        b.colours.push(255, 255, 255, 255);
      }

      for (let i = 0; i < m.indices.length; i++) b.indices.push(start + m.indices[i]);

      b.count += n;
      report.triangles += m.indices.length / 3;
      report.pieces++;
    });

    (built.boxes || []).forEach(function (box) {
      addBox(matrixOf(0, 0, 0, 0, 0, 0, 1, 1, 1), box.min, box.max, null, box.surface || 56);
    });

    (built.doors || []).forEach(function (d) {
      if (d.garage || !(d.fixed === true || (d.locked === true && o.bakeDoors === true))) return;

      const hit = resolve(kit, km, d.model);

      if (!hit) { missing.add(String(d.model)); return; }

      addModel(hit, matrixOf(num(d.x, 0), num(d.y, 0), num(d.z, 0), 0, num(d.h, 0), 0, 1, 1, 1), null, true);
      report.pieces++;
    });

    const textures = [];
    const made = new Map();
    const T = MM.mlotextures;
    const textureFor = function (t, role) {
      if (made.has(t)) return made.get(t);

      let img = null;

      if (t.indexOf("@slot:") === 0) img = slotImage(hexColour(colours[t.slice(6)], [216, 216, 216]));
      else if (t.indexOf("@flat:") === 0) {
        const mat = t.slice(6);
        const slot = /^s[1-6]$/.test(mat) ? hexColour(colours[mat], null) : null;
        const c = slot || (kit.backing && kit.backing.colours && kit.backing.colours[mat]) || [200, 200, 200];

        img = makeImage(4, 4, function () { return [c[0], c[1], c[2]]; });
      } else if (t.indexOf("@custom:") === 0) {
        const own = images[t.slice(8)];

        img = own || slotImage([185, 185, 185]);
      } else if (t.indexOf("@tint:") === 0) {
        const parts = t.split(":");
        const grey = images[parts[1]];
        const hex = (kit.tints && kit.tints.colours && kit.tints.colours[Number(parts[2]) || 0]) || "#ffffff";
        const c = hexColour(hex, [255, 255, 255]);

        if (grey) {
          const src = fit(grey, size);
          const rgba = new Uint8Array(src.rgba.length);

          for (let i = 0; i < rgba.length; i += 4) {
            rgba[i] = src.rgba[i] * c[0] / 255;
            rgba[i + 1] = src.rgba[i + 1] * c[1] / 255;
            rgba[i + 2] = src.rgba[i + 2] * c[2] / 255;
            rgba[i + 3] = 255;
          }

          img = { width: src.width, height: src.height, rgba: rgba };
        } else img = makeImage(4, 4, function () { return c; });
      } else {
        img = images[t] || null;

        if (!img && role === "bump") img = makeImage(4, 4, function () { return [128, 128, 255]; });
        if (!img && role === "spec") img = makeImage(4, 4, function () { return [40, 40, 40]; });
        if (!img) img = makeImage(4, 4, function () { return [200, 200, 200]; });
      }

      img = pow2(fit(img, role === "diffuse" ? size : Math.min(256, size)));

      const texName = ("t" + made.size.toString(36) + "_" + t.replace(/[^a-z0-9_]/gi, "_")).slice(0, 30).toLowerCase();
      const alpha = role === "diffuse" && hasAlpha(img);

      textures.push(MM.texture.fromRgba({ name: texName, width: img.width, height: img.height, rgba: img.rgba, format: alpha ? "DXT5" : "DXT1", kind: role === "bump" ? "normal" : role === "spec" ? "specular" : undefined }));
      made.set(t, texName);

      return texName;
    };

    const ROLE = { DiffuseSampler: "diffuse", BumpSampler: "bump", SpecSampler: "spec" };
    const meshes = [];

    if (o.collisionOnly) {
      const first = Array.from(buckets.values()).find(function (b) { return b.indices.length >= 3; });

      buckets.clear();

      if (first) {
        const v = first.indices.slice(0, 3);
        const at = [first.positions[v[0] * 3], first.positions[v[0] * 3 + 1], first.positions[v[0] * 3 + 2]];
        const tiny = { look: first.look, positions: [], normals: [], uvs: [], colours: [], indices: [0, 1, 2], count: 3 };

        [[0, 0, 0], [0.001, 0, 0], [0, 0.001, 0]].forEach(function (d) {
          tiny.positions.push(at[0] + d[0], at[1] + d[1], at[2] + d[2]);
          tiny.normals.push(0, 0, 1);
          tiny.uvs.push(0, 0);
          tiny.colours.push(255, 255, 255, 255);
        });
        buckets.set("tiny", tiny);
      }
    }

    buckets.forEach(function (b) {
      const tex = {};

      Object.keys(b.look.textures).forEach(function (sampler) {
        tex[sampler] = textureFor(b.look.textures[sampler], ROLE[sampler] || "diffuse");
      });

      meshes.push({
        positions: new Float32Array(b.positions),
        normals: new Float32Array(b.normals),
        uvs: [new Float32Array(b.uvs)],
        colours: new Uint8Array(b.colours),
        indices: b.indices,
        material: { shader: b.look.shader, textures: tex, params: b.look.params }
      });
    });

    if (!meshes.length) throw new Error("The shell has nothing to bake");

    report.materials = meshes.length;
    report.textures = textures.length;

    const children = [];

    for (let start = 0; start < boxes.length; start += BOX_CHUNK) {
      const polygons = [];

      boxes.slice(start, start + BOX_CHUNK).forEach(function (box) {
        const c = box.c;
        const material = { type: box.surface & 0xFF };
        const quad = function (a, b2, c2, d) {
          polygons.push({ type: "triangle", vertices: [c[a], c[b2], c[c2]], material: material });
          polygons.push({ type: "triangle", vertices: [c[a], c[c2], c[d]], material: material });
        };

        quad(0, 2, 3, 1);
        quad(4, 5, 7, 6);
        quad(0, 1, 5, 4);
        quad(2, 6, 7, 3);
        quad(0, 4, 6, 2);
        quad(1, 3, 7, 5);
      });

      const geom = MM.bounds.createGeometry({ type: "bvh", margin: Math.fround(0.005) });

      MM.bounds.setPolygons(geom, polygons, { grid: "ideal" });
      children.push(geom);
    }

    report.boxes = boxes.length;

    const bound = children.length && !o.noBound ? MM.drawable.createCompositeBound(children) : null;
    const lights = [];

    (o.noLights ? [] : (built.lamps || [])).forEach(function (l) {
      lights.push(MM.mlobuild.lightOf({ position: [num(l.x, 0), num(l.y, 0), num(l.z, 0)], colour: l.colour || "#ffe2bd", type: "point", falloff: num(l.range, 7), falloffExponent: 8, intensity: Math.max(0.2, num(l.intensity, 6) / 3), shadows: "none" }));
    });
    report.lights = lights.length;

    const dictionary = MM.texture.createDictionary(textures);
    const drawable = MM.drawable.create({ name: name, lods: { high: meshes }, embeddedTextures: dictionary, bound: bound || undefined });

    drawable.lights = lights;

    const F = MM.mlofiles;

    if (o.collisionOnly && boxes.length) {
      const lo = [Infinity, Infinity, Infinity];
      const hi = [-Infinity, -Infinity, -Infinity];

      boxes.forEach(function (box) {
        box.c.forEach(function (c) {
          for (let k = 0; k < 3; k++) {
            lo[k] = Math.min(lo[k], c[k]);
            hi[k] = Math.max(hi[k], c[k]);
          }
        });
      });

      drawable.boundingBoxMin = lo;
      drawable.boundingBoxMax = hi;
      drawable.boundingCenter = [(lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2, (lo[2] + hi[2]) / 2];
      drawable.boundingSphereRadius = Math.hypot(hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2]) / 2;
    }

    const radius = drawable.boundingSphereRadius || 30;
    const lodDist = Math.round(Math.max(200, Math.min(600, radius * 3 + 60)));
    const archetype = F.archetype({
      name: name, lodDist: lodDist, flags: F.ARCHETYPE_FLAG.AMBIENT_SCALE, textureDictionary: name, physicsDictionary: bound ? name : "",
      bbMin: drawable.boundingBoxMin.slice(), bbMax: drawable.boundingBoxMax.slice(), bsCentre: drawable.boundingCenter.slice(), bsRadius: drawable.boundingSphereRadius
    });

    report.missing = Array.from(missing);

    return {
      files: [
        { rel: "stream/" + name + ".ydr", bytes: MM.drawable.write(drawable) },
        { rel: "stream/" + name + ".ytyp", bytes: F.buildTypes({ name: name, archetypes: [archetype] }) }
      ],
      report: report
    };
  };

  SB.meshes = function (kit, km, built, skip) {
    const buckets = new Map();

    (built.pieces || []).forEach(function (p, index) {
      const pname = String(p[0]);
      const rest = pname.replace(/^rtx_tk_/, "");

      if (typeof p[13] === "number" || /^fx_/.test(rest) || /^cx_/.test(rest)) return;
      if (skip && skip(p)) return;

      const hit = resolve(kit, km, pname);

      if (!hit) return;

      const sx = num(p[6], 1);
      const sz = num(p[7], 1);
      const sy = num(p[9], 1);
      const M = matrixOf(num(p[1], 0), num(p[2], 0), num(p[3], 0), num(p[4], 0), num(p[5], 0), num(p[8], 0), sx, sy, sz);
      const flip = M.s[0] * M.s[1] * M.s[2] < 0;
      const inv = [1 / (Math.abs(sx) > 1e-6 ? sx : 1e-6), 1 / (Math.abs(sy) > 1e-6 ? sy : 1e-6), 1 / (Math.abs(sz) > 1e-6 ? sz : 1e-6)];

      hit.model.p.forEach(function (part) {
        const look = partTextures(kit, km, part, hit, p[11], {});
        const key = String(look.textures.DiffuseSampler || "") + (/glass/.test(String(look.shader)) ? "|glass" : "");
        const g = geometry(km, part[0]);
        let b = buckets.get(key);

        if (!b) {
          b = { key: key, shader: look.shader, positions: [], normals: [], uvs: [], indices: [], count: 0 };
          buckets.set(key, b);
        }

        const n = g.positions.length / 3;
        const start = b.count;

        for (let i = 0; i < n; i++) {
          const q = apply(M, g.positions[i * 3], g.positions[i * 3 + 1], g.positions[i * 3 + 2]);
          const ax = g.normals[i * 3] * inv[0];
          const ay = g.normals[i * 3 + 1] * inv[1];
          const az = g.normals[i * 3 + 2] * inv[2];
          let wx = M.r[0] * ax + M.f[0] * ay + M.u[0] * az;
          let wy = M.r[1] * ax + M.f[1] * ay + M.u[1] * az;
          let wz = M.r[2] * ax + M.f[2] * ay + M.u[2] * az;
          const l = Math.hypot(wx, wy, wz) || 1;

          b.positions.push(q[0], q[1], q[2]);
          b.normals.push(wx / l, wy / l, wz / l);
          b.uvs.push(g.uvs ? g.uvs[i * 2] : 0, g.uvs ? g.uvs[i * 2 + 1] : 0);
        }

        for (let i = 0; i < g.indices.length; i += 3) {
          if (flip) b.indices.push(start + g.indices[i], start + g.indices[i + 2], start + g.indices[i + 1]);
          else b.indices.push(start + g.indices[i], start + g.indices[i + 1], start + g.indices[i + 2]);
        }

        b.count += n;
      });
    });

    return Array.from(buckets.values());
  };

  SB.scene = function (kit, km, built) {
    const tris = [];
    const info = [];

    (built.pieces || []).forEach(function (p, index) {
      const pname = String(p[0]);
      const rest = pname.replace(/^rtx_tk_/, "");

      if (typeof p[13] === "number" || /^fx_/.test(rest) || /^cx_/.test(rest)) return;

      const hit = resolve(kit, km, pname);

      if (!hit) return;

      const sx = num(p[6], 1);
      const sz = num(p[7], 1);
      const sy = num(p[9], 1);
      const M = matrixOf(num(p[1], 0), num(p[2], 0), num(p[3], 0), num(p[4], 0), num(p[5], 0), num(p[8], 0), sx, sy, sz);
      const inv = [1 / (Math.abs(sx) > 1e-6 ? sx : 1e-6), 1 / (Math.abs(sy) > 1e-6 ? sy : 1e-6), 1 / (Math.abs(sz) > 1e-6 ? sz : 1e-6)];

      hit.model.p.forEach(function (part) {
        const g = geometry(km, part[0]);
        const glass = /glass/.test(String(part[1])) ? 1 : 0;

        for (let i = 0; i < g.indices.length; i += 3) {
          const ids = [g.indices[i], g.indices[i + 1], g.indices[i + 2]];
          let nx = 0, ny = 0, nz = 0;

          ids.forEach(function (v) {
            const ax = g.normals[v * 3] * inv[0];
            const ay = g.normals[v * 3 + 1] * inv[1];
            const az = g.normals[v * 3 + 2] * inv[2];

            nx += M.r[0] * ax + M.f[0] * ay + M.u[0] * az;
            ny += M.r[1] * ax + M.f[1] * ay + M.u[1] * az;
            nz += M.r[2] * ax + M.f[2] * ay + M.u[2] * az;
          });

          const l = Math.hypot(nx, ny, nz) || 1;
          const pts = ids.map(function (v) { return apply(M, g.positions[v * 3], g.positions[v * 3 + 1], g.positions[v * 3 + 2]); });

          tris.push(pts[0][0], pts[0][1], pts[0][2], pts[1][0], pts[1][1], pts[1][2], pts[2][0], pts[2][1], pts[2][2]);
          info.push(index, glass, nx / l, ny / l, nz / l);
        }
      });
    });

    return { tris: new Float32Array(tris), info: info };
  };

  root.RTX_SHELLBAKE = SB;

  if (typeof module !== "undefined" && module.exports) module.exports = SB;
})(typeof globalThis !== "undefined" ? globalThis : this);
