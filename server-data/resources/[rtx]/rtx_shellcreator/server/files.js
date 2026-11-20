globalThis.RTX_FILES = (function () {
  const crypto = require("crypto");
  const fs = require("fs");
  const path = require("path");

  const RESOURCE = GetCurrentResourceName();
  const ROOT = path.resolve(GetResourcePath(RESOURCE));
  const DATA = path.join(ROOT, "data");
  const INCOMING = path.join(DATA, "incoming");
  const BACKUPS = path.join(DATA, "backups");
  const MARKER = ".rtx_shellcreator.json";
  const TOOLKIT_MARKER = ".rtx_toolkit.json";
  const NAME_RE = /^[a-z0-9][a-z0-9_\-]{1,47}$/;
  const REL_RE = /^[A-Za-z0-9_\-\[\]\.\(\)+^ ]+(\/[A-Za-z0-9_\-\[\]\.\(\)+^ ]+)*$/;
  const CREDIT = ["Made by Kanikuly (Nina) for RTX Development", "https://discord.gg/rtxdev", "https://rtx.tebex.io/"];
  const sessions = new Map();
  let setupCache = null;

  function ensureDir(folder) {
    if (!fs.existsSync(folder)) fs.mkdirSync(folder, { recursive: true });
  }

  function setup() {
    if (!setupCache) {
      try {
        setupCache = exports[RESOURCE].GetJsSetup() || {};
      } catch (error) {
        setupCache = {};
      }
    }

    return setupCache;
  }

  function app(name, fallback) {
    const cfg = setup().config || {};
    const keys = { installfolder: "folder", maxupload: "maxupload", autostart: "autostart" };
    let value = cfg.Install ? cfg.Install[keys[name] || name] : undefined;

    if ((value === undefined || value === null) && cfg.App) value = cfg.App[name];

    return value === undefined || value === null ? fallback : value;
  }

  function text(key) {
    const lang = setup().language || {};
    let value = lang[key] || key;

    Array.prototype.slice.call(arguments, 1).forEach(function (arg) {
      value = value.replace(/%s/, String(arg));
    });

    return value;
  }

  function resourcesRoot() {
    let current = ROOT;

    for (let i = 0; i < 8; i++) {
      if (path.basename(current).toLowerCase() === "resources") return current;
      const parent = path.dirname(current);
      if (parent === current) break;
      current = parent;
    }

    const parent = path.dirname(ROOT);

    return /^\[.*\]$/.test(path.basename(parent)) ? path.dirname(parent) : parent;
  }

  const WALK_RESOURCE = "rtx_shellcreator_walk";

  function installRoot() {
    const folder = String(app("installfolder", "[rtx]")).replace(/[\\/]/g, "");

    return path.join(resourcesRoot(), folder || "[rtx]");
  }

  function cleanName(name) {
    return String(name || "").toLowerCase().replace(/[^a-z0-9_\-]/g, "_").replace(/_+/g, "_").replace(/^[_\-]+/, "").slice(0, 48);
  }

  function safeRel(rel) {
    const value = String(rel || "").replace(/\\/g, "/").replace(/^\/+/, "");

    if (!value || value.length > 200 || !REL_RE.test(value)) return null;
    if (value.split("/").some(function (part) { return part === ".." || part === "." || part === ""; })) return null;
    if (/^\.rtx_(shellcreator|toolkit)/i.test(value)) return null;

    return value;
  }

  function readMarker(file) {
    try {
      const value = JSON.parse(fs.readFileSync(file, "utf8"));

      return value && typeof value === "object" ? value : null;
    } catch (error) {
      return null;
    }
  }

  function markerOf(folder) {
    const own = readMarker(path.join(folder, MARKER));
    const toolkit = readMarker(path.join(folder, TOOLKIT_MARKER));

    if (!own) return toolkit;
    if (!toolkit) return own;

    return (Number(toolkit.updated || toolkit.created) || 0) > (Number(own.updated || own.created) || 0) ? toolkit : own;
  }

  function blockedError(error) {
    return !!error && (error.code === "ERR_ACCESS_DENIED" || /restricted|allow-fs/i.test(String(error.message || "")));
  }

  function sandboxResult(name) {
    console.log("^1[RTX SHELL CREATOR]^0 " + text("install_sandbox_console", name));
    console.log("^1[RTX SHELL CREATOR]^0     add_filesystem_permission " + RESOURCE + " write " + name);

    return { ok: false, code: "sandbox", message: text("install_sandbox", name, name, RESOURCE, name) };
  }

  function guard(name, run) {
    try {
      return run();
    } catch (error) {
      const clean = cleanName(typeof name === "function" ? name() : name) || RESOURCE;

      if (blockedError(error)) return sandboxResult(clean);

      console.log("^1[RTX SHELL CREATOR] " + clean + ": " + (error && error.message) + "^0");

      return { ok: false, code: "write", message: text("install_write_failed", clean) };
    }
  }

  function sessionName(data) {
    const session = sessions.get(String(data && data.session || ""));

    return session ? session.name : "";
  }

  function knownPath(name) {
    try {
      return GetResourceState(name) !== "missing" ? GetResourcePath(name) || "" : "";
    } catch (error) {
      return "";
    }
  }

  function ownedBy(folder) {
    if (markerOf(folder)) return true;

    try {
      return /made with RTX Shell Creator|made with RTX Toolkit|RTX Shell Creator walk mode/.test(fs.readFileSync(path.join(folder, "fxmanifest.lua"), "utf8"));
    } catch (error) {
      return false;
    }
  }

  function stamp() {
    const now = new Date();
    const pad = function (value) { return String(value).padStart(2, "0"); };

    return now.getFullYear() + pad(now.getMonth() + 1) + pad(now.getDate()) + "_" + pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds());
  }

  function copyFolder(from, to) {
    ensureDir(to);

    for (const entry of fs.readdirSync(from, { withFileTypes: true })) {
      const source = path.join(from, entry.name);
      const target = path.join(to, entry.name);

      if (entry.isDirectory()) copyFolder(source, target);
      else if (entry.isFile()) fs.copyFileSync(source, target);
    }
  }

  function removeFolder(folder) {
    if (fs.existsSync(folder)) fs.rmSync(folder, { recursive: true, force: true });
  }

  function emptyFolder(folder) {
    for (const entry of fs.readdirSync(folder)) fs.rmSync(path.join(folder, entry), { recursive: true, force: true });
  }

  function keepBackups(name) {
    const folder = path.join(BACKUPS, name);

    if (!fs.existsSync(folder)) return;

    const list = fs.readdirSync(folder).sort();

    while (list.length > 3) removeFolder(path.join(folder, list.shift()));
  }

  function targetCheck(name) {
    const clean = cleanName(name);

    if (!NAME_RE.test(clean)) return { ok: false, code: "name", message: text("install_bad_name") };
    if (clean === RESOURCE.toLowerCase()) return { ok: false, code: "name", message: text("install_own_name") };

    let target = path.join(installRoot(), clean);
    const existing = knownPath(clean);

    if (existing) {
      if (path.resolve(existing).toLowerCase() !== path.resolve(target).toLowerCase() && !ownedBy(existing)) return { ok: false, code: "foreign", message: text("install_elsewhere", clean) };

      target = path.resolve(existing);
    }

    let present = false;

    try {
      present = fs.existsSync(target);
    } catch (error) {
      if (!blockedError(error)) throw error;

      if (!existing) {
        ExecuteCommand("refresh");

        if (knownPath(clean)) return targetCheck(clean);

        console.log("^1[RTX SHELL CREATOR]^0 " + text("install_missing_console", clean, path.basename(installRoot())));

        return { ok: false, code: "sandbox", message: text("install_missing", clean, clean, path.basename(installRoot())) };
      }

      return sandboxResult(clean);
    }

    if (present && !ownedBy(target)) return { ok: false, code: "foreign", message: text("install_foreign", clean) };

    return { ok: true, name: clean, target: target };
  }

  function writePlan(name, files, from, options) {
    const checked = targetCheck(name);

    if (!checked.ok) return checked;

    const staging = path.join(INCOMING, "build_" + crypto.randomBytes(6).toString("hex"));
    let count = 0;

    try {
      ensureDir(staging);

      for (const file of files) {
        const rel = safeRel(file.rel);

        if (!rel) throw new Error("bad path " + file.rel);

        const target = path.join(staging, rel);

        ensureDir(path.dirname(target));

        if (file.bytes) fs.writeFileSync(target, Buffer.from(file.bytes.buffer ? Buffer.from(file.bytes.buffer, file.bytes.byteOffset, file.bytes.byteLength) : file.bytes));
        else fs.writeFileSync(target, String(file.text || ""), "utf8");

        count++;
      }

      fs.writeFileSync(path.join(staging, MARKER), JSON.stringify({ by: "rtx_shellcreator", from: from || "game", created: Math.floor(Date.now() / 1000), files: count, kind: options && options.kind || "" }, null, 1));
      place(checked, staging);
    } catch (error) {
      removeFolder(staging);
      if (blockedError(error)) return sandboxResult(checked.name);
      console.log("^1[RTX SHELL CREATOR] " + checked.name + ": " + (error && error.message) + "^0");
      return { ok: false, code: "write", message: text("install_write_failed", checked.name) };
    }

    return { ok: true, resource: checked.name, files: count, folder: path.relative(resourcesRoot(), checked.target).replace(/\\/g, "/") };
  }

  function place(checked, staging) {
    if (fs.existsSync(checked.target)) {
      if (checked.name !== WALK_RESOURCE && checked.name !== "rtx_shellcreator_livepreview") {
        const backup = path.join(BACKUPS, checked.name, stamp());

        copyFolder(checked.target, backup);
        keepBackups(checked.name);
      }

      emptyFolder(checked.target);
      copyFolder(staging, checked.target);
      removeFolder(staging);

      return;
    }

    ensureDir(path.dirname(checked.target));

    try {
      fs.renameSync(staging, checked.target);
    } catch (error) {
      copyFolder(staging, checked.target);
      removeFolder(staging);
    }
  }

  function beginInstall(data, from) {
    const checked = targetCheck(data.name);

    if (!checked.ok) return checked;

    const list = Array.isArray(data.files) ? data.files : [];
    const limit = Number(app("maxupload", 400)) * 1024 * 1024;
    let total = 0;
    const files = [];

    if (!list.length || list.length > 5000) return { ok: false, code: "files", message: text("install_no_files") };

    for (const item of list) {
      const rel = safeRel(item && item.path);
      const size = Number(item && item.size);

      if (!rel || !Number.isFinite(size) || size < 0 || !/^[0-9a-f]{64}$/.test(String(item.sha256 || ""))) return { ok: false, code: "files", message: text("install_bad_file", String(item && item.path)) };
      if (rel.toLowerCase() === MARKER) return { ok: false, code: "files", message: text("install_bad_file", rel) };

      total += size;
      files.push({ rel: rel, size: size, sha256: item.sha256, written: 0 });
    }

    if (total > limit) return { ok: false, code: "size", message: text("install_too_big", Math.ceil(total / 1048576), app("maxupload", 400)) };

    const collection = data.collection ? collectionSpec(data.collection) : null;

    if (data.collection && !collection) return { ok: false, code: "name", message: text("install_bad_item") };
    if (collection) {
      const known = collectionKind(checked.target);

      if (known === false) return { ok: false, code: "foreign", message: text("install_not_collection", checked.name) };
      if (known && known !== collection.kind) return { ok: false, code: "foreign", message: text("install_collection_kind", checked.name) };
    }
    if (!collection && !files.some(function (file) { return file.rel.toLowerCase() === "fxmanifest.lua"; })) return { ok: false, code: "manifest", message: text("install_no_manifest") };

    const id = crypto.randomBytes(12).toString("hex");
    const folder = path.join(INCOMING, id);

    ensureDir(folder);

    for (const file of files) {
      ensureDir(path.dirname(path.join(folder, file.rel)));
      fs.writeFileSync(path.join(folder, file.rel), Buffer.alloc(0));
    }

    sessions.set(id, { id: id, name: checked.name, folder: folder, files: files, from: from, at: Date.now(), collection: collection });

    return { ok: true, session: id, chunk: 2 * 1024 * 1024, replaces: collection ? collectionHas(checked.target, collection.item) : fs.existsSync(checked.target) };
  }

  function installChunk(data) {
    const session = sessions.get(String(data.session || ""));

    if (!session) return { ok: false, code: "session", message: text("install_session") };

    const file = session.files[Number(data.index)];
    const offset = Number(data.offset);

    if (!file || offset !== file.written) return { ok: false, code: "offset", message: text("install_offset"), written: file ? file.written : 0 };

    const bytes = Buffer.from(String(data.data || ""), "base64");

    if (file.written + bytes.length > file.size) return { ok: false, code: "size", message: text("install_bad_file", file.rel) };

    fs.appendFileSync(path.join(session.folder, file.rel), bytes);
    file.written += bytes.length;
    session.at = Date.now();

    return { ok: true, written: file.written };
  }

  function hashFile(file) {
    return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
  }

  function finishInstall(data) {
    const session = sessions.get(String(data.session || ""));

    if (!session) return { ok: false, code: "session", message: text("install_session") };

    sessions.delete(session.id);

    for (const file of session.files) {
      const full = path.join(session.folder, file.rel);

      if (file.written !== file.size || hashFile(full) !== file.sha256) {
        removeFolder(session.folder);
        return { ok: false, code: "hash", message: text("install_damaged", file.rel) };
      }
    }

    const checked = targetCheck(session.name);

    if (!checked.ok) {
      removeFolder(session.folder);
      return checked;
    }

    if (session.collection) {
      try {
        const merged = collectionMerge(checked, session.folder, session.files.map(function (file) { return file.rel; }), session.collection, String(session.from || "").indexOf("game:") === 0 ? "game" : "app");

        removeFolder(session.folder);

        return { ok: true, resource: checked.name, files: session.files.length, item: session.collection.item, items: merged.items, collection: session.collection.kind, folder: path.relative(resourcesRoot(), checked.target).replace(/\\/g, "/") };
      } catch (error) {
        removeFolder(session.folder);
        if (blockedError(error)) return sandboxResult(checked.name);
        console.log("^1[RTX SHELL CREATOR] " + checked.name + ": " + (error && error.message) + "^0");
        return { ok: false, code: "write", message: text("install_write_failed", session.name) };
      }
    }

    try {
      fs.writeFileSync(path.join(session.folder, MARKER), JSON.stringify({ by: "rtx_shellcreator", from: String(session.from || "").indexOf("game:") === 0 ? "game" : "app", pc: session.from, created: Math.floor(Date.now() / 1000), files: session.files.length }, null, 1));
      place(checked, session.folder);
    } catch (error) {
      removeFolder(session.folder);
      if (blockedError(error)) return sandboxResult(checked.name);
      return { ok: false, code: "write", message: text("install_write_failed", session.name) };
    }

    return { ok: true, resource: checked.name, files: session.files.length, folder: path.relative(resourcesRoot(), checked.target).replace(/\\/g, "/") };
  }

  const COLLECTION_KINDS = ["shells", "mlos", "clothes", "vehicles", "tattoos", "weapons"];

  function collectionSpec(raw) {
    const item = cleanName(raw && raw.item);
    const kind = String(raw && raw.kind || "");
    const list = function (value) { return (Array.isArray(value) ? value : []).map(safeRel).filter(Boolean).slice(0, 40); };

    if (!NAME_RE.test(item) || COLLECTION_KINDS.indexOf(kind) < 0) return null;

    return {
      item: item,
      kind: kind,
      label: String(raw.label || item).replace(/[\r\n'"\\]/g, " ").slice(0, 60),
      head: (Array.isArray(raw.head) ? raw.head : []).map(function (line) { return String(line).replace(/[\r\n]/g, " ").slice(0, 200); }).slice(0, 40),
      shared: list(raw.shared),
      keep: list(raw.keep),
      meta: raw.meta && typeof raw.meta === "object" && JSON.stringify(raw.meta).length < 4000 ? JSON.parse(JSON.stringify(raw.meta)) : null
    };
  }

  function collectionKind(target) {
    if (!fs.existsSync(target)) return null;

    const marker = markerOf(target);

    if (!marker && ownedBy(target)) return null;

    return marker && marker.collection ? marker.collection : false;
  }

  function collectionHas(target, item) {
    const marker = fs.existsSync(target) ? markerOf(target) : null;

    return !!(marker && marker.items && marker.items[item]);
  }

  function itemRel(rel, item, shared) {
    if (shared.indexOf(rel) >= 0) return rel;
    if (/^stream\//i.test(rel)) return "stream/" + item + "/" + rel.slice(7);

    return "items/" + item + "/" + rel;
  }

  function itemManifest(source, item, shared) {
    const textdata = String(source || "").replace(/--[^\n]*/g, "");
    const out = { data: [], files: [], map: /\bthis_is_a_map\s*\(?\s*['"]yes['"]/.test(textdata) };
    const quoted = /['"]([^'"]+)['"]/g;
    let match;
    const dataRe = /\bdata_file\s*\(?\s*['"]([A-Za-z0-9_]+)['"]\s*\)?\s*['"]([^'"]+)['"]/g;

    while ((match = dataRe.exec(textdata))) {
      if (safeRel(match[2])) out.data.push({ type: match[1], file: itemRel(match[2], item, shared) });
    }

    const blockRe = /\bfiles\s*\(?\s*\{([^}]*)\}/g;

    while ((match = blockRe.exec(textdata))) {
      let one;

      while ((one = quoted.exec(match[1]))) out.files.push(itemRel(one[1], item, shared));
    }

    const singleRe = /\bfile\s*\(?\s*['"]([^'"]+)['"]/g;

    while ((match = singleRe.exec(textdata))) out.files.push(itemRel(match[1], item, shared));

    return out;
  }

  function streamNames(folder, list, base) {
    if (!fs.existsSync(folder)) return list;

    for (const entry of fs.readdirSync(folder, { withFileTypes: true })) {
      const full = path.join(folder, entry.name);

      if (entry.isDirectory()) streamNames(full, list, base);
      else if (entry.isFile()) list.push({ full: full, name: entry.name.toLowerCase(), rel: path.relative(base, full).replace(/\\/g, "/") });
    }

    return list;
  }

  function countFiles(folder) {
    let count = 0;

    for (const entry of fs.readdirSync(folder, { withFileTypes: true })) {
      if (entry.isDirectory()) count += countFiles(path.join(folder, entry.name));
      else if (entry.isFile() && entry.name !== MARKER && entry.name !== TOOLKIT_MARKER) count++;
    }

    return count;
  }

  function quoteLua(value) {
    return "'" + String(value).replace(/\\/g, "/").replace(/'/g, "") + "'";
  }

  function collectionWrite(folder, name, marker) {
    const names = Object.keys(marker.items || {}).sort();
    const items = names.map(function (item) { const info = marker.items[item]; return { name: item, label: info.label || item, at: info.at || 0 }; });
    const files = ["items.json"];
    const data = [];
    const order = ["WEAPON_METADATA_FILE", "WEAPONCOMPONENTSINFO_FILE", "WEAPONINFO_FILE", "WEAPONINFO_FILE_PATCH"];
    let map = false;

    names.forEach(function (item) {
      const info = marker.items[item];

      (info.files || []).forEach(function (rel) { if (files.indexOf(rel) < 0) files.push(rel); });
      (info.data || []).forEach(function (entry) {
        const line = "data_file " + quoteLua(entry.type) + " " + quoteLua(entry.file);

        if (data.indexOf(line) < 0) data.push(line);
      });
      if (info.map) map = true;
    });
    data.sort(function (a, b) {
      const rank = function (line) { const i = order.indexOf((/^data_file '([^']+)'/.exec(line) || [])[1]); return i < 0 ? -1 : i; };

      return rank(a) - rank(b);
    });

    const lines = CREDIT.map(function (line) { return "-- " + line; }).concat([
      "",
      "fx_version 'cerulean'",
      "game 'gta5'",
      "lua54 'yes'"
    ], map ? ["this_is_a_map 'yes'"] : [], [
      "",
      "author 'RTX Development'",
      "description " + quoteLua(name + " - " + names.length + " made with RTX Shell Creator"),
      "version '1.0.0'",
      ""
    ], marker.head && marker.head.length ? marker.head.concat([""]) : [], [
      "files {",
      files.map(function (rel) { return "\t" + quoteLua(rel); }).join(",\r\n"),
      "}"
    ], data.length ? [""].concat(data) : [], [""]);

    fs.writeFileSync(path.join(folder, "fxmanifest.lua"), lines.join("\r\n"), "utf8");
    fs.writeFileSync(path.join(folder, "items.json"), JSON.stringify(items, null, 1) + "\r\n", "utf8");
    fs.writeFileSync(path.join(folder, "README.txt"), CREDIT.concat([
      "",
      text("collection_readme_title", name, names.length),
      "",
      text("collection_readme_ensure", name),
      text("collection_readme_more"),
      ""
    ], items.map(function (item) { return "- " + item.name + (item.label && item.label !== item.name ? "  (" + item.label + ")" : "") + (fs.existsSync(path.join(folder, "items", item.name, "README.txt")) ? "  ->  items/" + item.name + "/README.txt" : ""); }), [""]).join("\r\n"), "utf8");
    marker.files = countFiles(folder);
    fs.writeFileSync(path.join(folder, MARKER), JSON.stringify(Object.assign({}, marker, { by: "rtx_shellcreator" }), null, 1));

    if (fs.existsSync(path.join(folder, TOOLKIT_MARKER))) fs.writeFileSync(path.join(folder, TOOLKIT_MARKER), JSON.stringify(Object.assign({}, marker, { by: "rtx_toolkit" }), null, 1));
  }

  function collectionMerge(checked, incoming, rels, spec, from) {
    const staging = path.join(INCOMING, "col_" + crypto.randomBytes(6).toString("hex"));
    const old = fs.existsSync(checked.target) ? markerOf(checked.target) : null;
    const now = Math.floor(Date.now() / 1000);
    const item = spec.item;
    const fresh = [];

    try {
      if (old) copyFolder(checked.target, staging);
      else ensureDir(staging);

      removeFolder(path.join(staging, "stream", item));
      removeFolder(path.join(staging, "items", item));

      const info = { label: spec.label, at: now, files: [], data: [], map: false, meta: spec.meta || null };

      for (const rel of rels) {
        const source = path.join(incoming, rel);

        if (rel.toLowerCase() === "fxmanifest.lua") {
          const parsed = itemManifest(fs.readFileSync(source, "utf8"), item, spec.shared);

          info.files = parsed.files;
          info.data = parsed.data;
          info.map = parsed.map;
          continue;
        }

        const out = itemRel(rel, item, spec.shared);
        const target = path.join(staging, out);

        if (spec.keep.indexOf(rel) >= 0 && fs.existsSync(target)) continue;

        ensureDir(path.dirname(target));
        fs.copyFileSync(source, target);

        if (/^stream\//i.test(out)) fresh.push(path.basename(out).toLowerCase());
      }

      const own = path.join(staging, "stream", item);

      streamNames(path.join(staging, "stream"), [], staging).forEach(function (file) {
        if (file.full.indexOf(own + path.sep) === 0) return;
        if (fresh.indexOf(file.name) >= 0) fs.unlinkSync(file.full);
      });

      const marker = { by: "rtx_shellcreator", from: from || "game", created: old && old.created || now, updated: now, collection: spec.kind, head: spec.head.length ? spec.head : (old && old.head) || [], items: Object.assign({}, old && old.items || {}) };

      marker.items[item] = info;
      Object.keys(marker.items).forEach(function (name) {
        if (!fs.existsSync(path.join(staging, "stream", name)) && !fs.existsSync(path.join(staging, "items", name))) delete marker.items[name];
      });
      collectionWrite(staging, checked.name, marker);
      place(checked, staging);

      return { items: Object.keys(marker.items).length };
    } catch (error) {
      removeFolder(staging);
      throw error;
    }
  }

  function dropComponent(folder, meta) {
    const component = meta && typeof meta.component === "string" ? meta.component.replace(/[^A-Za-z0-9_]/g, "") : "";
    const patches = path.join(folder, "weapons");

    if (!component || !fs.existsSync(patches)) return;

    const pattern = new RegExp("[ \\t]*<Item>\\s*<Name>" + component + "</Name>\\s*<Default value=\"[^\"]*\"\\s*/>\\s*</Item>[ \\t]*\\r?\\n?", "gi");

    for (const entry of fs.readdirSync(patches)) {
      if (!/\.meta$/i.test(entry)) continue;

      const file = path.join(patches, entry);
      const before = fs.readFileSync(file, "utf8");
      const after = before.replace(pattern, "");

      if (after !== before) fs.writeFileSync(file, after, "utf8");
    }
  }

  function collectionRemove(name, item) {
    const checked = targetCheck(name);
    const clean = cleanName(item);

    if (!checked.ok) return checked;

    const marker = fs.existsSync(checked.target) ? markerOf(checked.target) : null;

    if (!marker || !marker.collection || !marker.items || !marker.items[clean]) return { ok: false, code: "missing" };

    const staging = path.join(INCOMING, "col_" + crypto.randomBytes(6).toString("hex"));

    try {
      copyFolder(checked.target, staging);
      removeFolder(path.join(staging, "stream", clean));
      removeFolder(path.join(staging, "items", clean));
      dropComponent(staging, marker.items[clean].meta);
      delete marker.items[clean];
      marker.updated = Math.floor(Date.now() / 1000);
      collectionWrite(staging, checked.name, marker);
      place(checked, staging);
    } catch (error) {
      removeFolder(staging);
      return { ok: false, code: "write", message: text("install_write_failed", checked.name) };
    }

    return { ok: true, resource: checked.name, items: Object.keys(marker.items).length };
  }

  function collectionItems(name) {
    const checked = targetCheck(name);
    const marker = checked.ok && fs.existsSync(checked.target) ? markerOf(checked.target) : null;

    if (!marker || !marker.collection) return [];

    return Object.keys(marker.items || {}).sort().map(function (item) { return { name: item, label: marker.items[item].label || item, at: marker.items[item].at || 0, meta: marker.items[item].meta || null }; });
  }

  function installedList() {
    const root = installRoot();
    const list = [];
    const seen = {};
    const add = function (name, folder) {
      const marker = markerOf(folder);

      if (!marker || seen[name]) return;

      seen[name] = true;
      list.push({ name: name, from: marker.from || "", created: marker.updated || marker.created || 0, files: marker.files || 0, items: marker.collection ? Object.keys(marker.items || {}).length : 0, collection: marker.collection || "", state: GetResourceState(name) });
    };

    try {
      if (fs.existsSync(root)) {
        for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
          if (entry.isDirectory()) add(entry.name, path.join(root, entry.name));
        }
      }
    } catch (error) {
      for (let i = 0; i < GetNumResources(); i++) {
        const name = GetResourceByFindIndex(i);

        if (name && name !== RESOURCE) {
          try {
            add(name, path.resolve(GetResourcePath(name)));
          } catch (inner) {
            continue;
          }
        }
      }
    }

    return list.sort(function (a, b) { return b.created - a.created; });
  }

  function removeInstalled(name) {
    const clean = cleanName(name);
    const checked = targetCheck(clean);

    if (!checked.ok) return checked;

    const target = checked.target;

    if (!fs.existsSync(target) || !markerOf(target)) return { ok: false, code: "foreign", message: text("install_foreign", clean) };

    ExecuteCommand("stop " + clean);
    copyFolder(target, path.join(BACKUPS, clean, stamp() + "_removed"));
    keepBackups(clean);
    removeFolder(target);
    ExecuteCommand("refresh");

    return { ok: true };
  }

  function creditLua() {
    return CREDIT.map(function (line) { return "-- " + line; }).join("\r\n") + "\r\n\r\n";
  }

  function manifest(spec) {
    return MM.fxmanifest.build(Object.assign({ author: "RTX Development", lua54: true }, spec)).replace(/^/, creditLua());
  }

  function luaValue(value, indent) {
    const pad = indent || "";

    if (value === null || value === undefined) return "nil";
    if (typeof value === "number") return Number.isInteger(value) ? String(value) : String(Math.round(value * 10000) / 10000);
    if (typeof value === "boolean") return value ? "true" : "false";
    if (typeof value === "string") return "\"" + value.replace(/\\/g, "\\\\").replace(/"/g, "\\\"").replace(/\r?\n/g, "\\n") + "\"";
    if (Array.isArray(value)) {
      if (!value.length) return "{}";
      return "{\r\n" + value.map(function (item) { return pad + "\t" + luaValue(item, pad + "\t"); }).join(",\r\n") + "\r\n" + pad + "}";
    }

    const keys = Object.keys(value);

    if (keys.length === 3 && keys.join() === "x,y,z") return "vector3(" + [value.x, value.y, value.z].map(function (n) { return luaValue(Number(n)); }).join(", ") + ")";
    if (keys.length === 4 && keys.join() === "x,y,z,w") return "vector4(" + [value.x, value.y, value.z, value.w].map(function (n) { return luaValue(Number(n)); }).join(", ") + ")";
    if (!keys.length) return "{}";

    return "{" + keys.map(function (key) { return (/^[A-Za-z_][A-Za-z0-9_]*$/.test(key) ? key : "[" + luaValue(key) + "]") + " = " + luaValue(value[key], pad); }).join(", ") + "}";
  }

  function vec(value) {
    const v = value || {};

    return [Number(v.x) || 0, Number(v.y) || 0, Number(v.z) || 0];
  }

  function buildMap(record, options) {
    const name = cleanName(options.resource || "rtx_map_" + record.name);
    const doc = MM.mapplace.create({ name: cleanName(record.name) || "rtx_map" });
    const sizes = options.sizes || {};

    for (const object of record.objects || []) {
      const rotation = vec(object.r);

      const numeric = typeof object.m === "number" || /^-?\d+$/.test(String(object.m));

      MM.mapplace.addItem(doc, {
        model: numeric ? undefined : String(object.m),
        hash: numeric ? (Number(object.m) >>> 0) : undefined,
        position: vec(object.p),
        rotation: rotation,
        lodDist: Number(options.lod) || 300,
        frozen: object.f !== false
      });
    }

    const plan = MM.mapplace.resourcePlan([doc], {
      name: name,
      archetypes: function (hash) {
        const size = sizes[String(hash >>> 0)] || sizes[String(hash | 0)];

        if (!size) return null;

        const min = vec(size.min);
        const max = vec(size.max);
        const centre = [(min[0] + max[0]) / 2, (min[1] + max[1]) / 2, (min[2] + max[2]) / 2];
        const radius = Math.sqrt(Math.pow(max[0] - min[0], 2) + Math.pow(max[1] - min[1], 2) + Math.pow(max[2] - min[2], 2)) / 2;

        return { bbMin: min, bbMax: max, bsCentre: centre, bsRadius: radius, lodDist: Number(options.lod) || 300 };
      },
      exportedBy: "RTX Shell Creator",
      owner: "RTX Development"
    });

    const files = plan.files.map(function (file) { return { rel: file.rel, bytes: file.bytes, text: file.text }; });

    files.push({ rel: "README.txt", text: CREDIT.join("\r\n") + "\r\n\r\n" + text("readme_map", record.name, (record.objects || []).length) + "\r\n" });

    const result = writePlan(name, files, "game", { kind: "map" });

    result.warnings = plan.warnings;

    return result;
  }

  function buildHandling(record, options) {
    const name = cleanName(options.resource || "rtx_handling_" + record.model);
    const lines = [];

    lines.push("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    lines.push("<!-- " + CREDIT.join(" | ") + " -->");
    lines.push("<CHandlingDataMgr>");
    lines.push("  <HandlingData>");
    lines.push("    <Item type=\"CHandlingData\">");
    lines.push("      <handlingName>" + String(record.handlingName || record.model || "").toUpperCase().replace(/[^A-Z0-9_]/g, "") + "</handlingName>");

    for (const field of record.fields || []) {
      if (!/^[a-zA-Z]+$/.test(String(field.name))) continue;
      if (field.vector) lines.push("      <" + field.name + " x=\"" + Number(field.x).toFixed(6) + "\" y=\"" + Number(field.y).toFixed(6) + "\" z=\"" + Number(field.z).toFixed(6) + "\" />");
      else lines.push("      <" + field.name + " value=\"" + (field.integer ? Math.round(Number(field.value)) : Number(field.value).toFixed(6)) + "\" />");
    }

    lines.push("    </Item>");
    lines.push("  </HandlingData>");
    lines.push("</CHandlingDataMgr>");

    const files = [
      { rel: "data/handling.meta", text: lines.join("\r\n") + "\r\n" },
      { rel: "fxmanifest.lua", text: manifest({ description: "Handling " + record.model, files: ["data/handling.meta"], dataFiles: [{ type: "HANDLING_FILE", path: "data/handling.meta" }] }) }
    ];

    return writePlan(name, files, "game", { kind: "handling" });
  }

  function buildPeds(record, options) {
    const name = cleanName(options.resource || "rtx_peds_" + record.name);
    const peds = (record.items || []).map(function (item) {
      return {
        model: item.model, coords: { x: item.x, y: item.y, z: item.z, w: item.h }, scenario: item.scenario || nil(), dict: item.dict || nil(), clip: item.clip || nil(),
        flag: item.flag || 1, frozen: item.frozen !== false, invincible: item.invincible !== false, components: item.components || nil(), props: item.props || nil()
      };
    });
    const config = "Peds = " + luaValue(peds) + "\r\n\r\nStreamDistance = " + (Number(options.distance) || 120.0) + "\r\n";
    const client = [
      "local spawned = {}",
      "",
      "local function LoadModel(hash)",
      "\tif not IsModelInCdimage(hash) then return false end",
      "\tRequestModel(hash)",
      "\tlocal timeout = GetGameTimer() + 8000",
      "\twhile not HasModelLoaded(hash) do",
      "\t\tif GetGameTimer() > timeout then return false end",
      "\t\tWait(0)",
      "\tend",
      "\treturn true",
      "end",
      "",
      "local function Spawn(index, data)",
      "\tlocal hash = type(data.model) == \"number\" and data.model or GetHashKey(data.model)",
      "\tif not LoadModel(hash) then return end",
      "\tlocal ped = CreatePed(4, hash, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, false)",
      "\tSetModelAsNoLongerNeeded(hash)",
      "\tSetEntityInvincible(ped, data.invincible)",
      "\tFreezeEntityPosition(ped, data.frozen)",
      "\tSetBlockingOfNonTemporaryEvents(ped, true)",
      "\tSetPedCanRagdoll(ped, false)",
      "\tif data.components then for _, c in ipairs(data.components) do SetPedComponentVariation(ped, c[1], c[2], c[3], 0) end end",
      "\tif data.props then for _, p in ipairs(data.props) do if p[2] < 0 then ClearPedProp(ped, p[1]) else SetPedPropIndex(ped, p[1], p[2], p[3], true) end end end",
      "\tif data.scenario then",
      "\t\tTaskStartScenarioInPlace(ped, data.scenario, 0, true)",
      "\telseif data.dict and data.clip then",
      "\t\tRequestAnimDict(data.dict)",
      "\t\tlocal timeout = GetGameTimer() + 5000",
      "\t\twhile not HasAnimDictLoaded(data.dict) and GetGameTimer() < timeout do Wait(0) end",
      "\t\tTaskPlayAnim(ped, data.dict, data.clip, 8.0, -8.0, -1, data.flag, 0.0, false, false, false)",
      "\tend",
      "\tspawned[index] = ped",
      "end",
      "",
      "CreateThread(function()",
      "\twhile true do",
      "\t\tlocal coords = GetEntityCoords(PlayerPedId())",
      "\t\tfor index, data in ipairs(Peds) do",
      "\t\t\tlocal near = #(coords - vector3(data.coords.x, data.coords.y, data.coords.z)) < StreamDistance",
      "\t\t\tif near and not spawned[index] then",
      "\t\t\t\tSpawn(index, data)",
      "\t\t\telseif not near and spawned[index] then",
      "\t\t\t\tDeleteEntity(spawned[index])",
      "\t\t\t\tspawned[index] = nil",
      "\t\t\tend",
      "\t\tend",
      "\t\tWait(1500)",
      "\tend",
      "end)",
      "",
      "AddEventHandler(\"onResourceStop\", function(name)",
      "\tif name ~= GetCurrentResourceName() then return end",
      "\tfor _, ped in pairs(spawned) do if DoesEntityExist(ped) then DeleteEntity(ped) end end",
      "end)"
    ].join("\r\n");
    const files = [
      { rel: "config.lua", text: creditLua() + config },
      { rel: "client.lua", text: creditLua() + client + "\r\n" },
      { rel: "fxmanifest.lua", text: manifest({ description: "Peds " + record.name, clientScripts: ["config.lua", "client.lua"] }) }
    ];

    return writePlan(name, files, "game", { kind: "peds" });
  }

  function nil() {
    return undefined;
  }

  function buildBlips(record, options) {
    const name = cleanName(options.resource || "rtx_blips_" + record.name);
    const items = record.items || [];
    const blips = items.filter(function (item) { return item.type !== "marker"; }).map(function (item) {
      return { name: item.label || "", coords: { x: item.x, y: item.y, z: item.z }, sprite: item.sprite || 1, colour: item.colour || 0, scale: item.scale || 0.8, display: item.display || 4, shortrange: item.shortrange !== false, radius: item.radius || nil(), alpha: item.radius ? item.alpha || 120 : nil() };
    });
    const markers = items.filter(function (item) { return item.type === "marker"; }).map(function (item) {
      const c = Array.isArray(item.colour) ? item.colour : [255, 102, 255, 160];

      return { name: item.label || nil(), type: item.marker || 1, coords: { x: item.x, y: item.y, z: (item.z || 0) + (item.oz || 0) }, size: { x: item.sx || 1, y: item.sy || 1, z: item.sz || 1 }, heading: item.h || 0, colour: { r: c[0], g: c[1], b: c[2], a: c[3] }, bob: item.bob === true, face: item.face === true, rotate: item.rotate === true, distance: item.distance || 30 };
    });
    const client = [
      "local created = {}",
      "",
      "CreateThread(function()",
      "\tfor _, data in ipairs(Blips) do",
      "\t\tif data.radius then",
      "\t\t\tlocal area = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)",
      "\t\t\tSetBlipColour(area, data.colour)",
      "\t\t\tSetBlipAlpha(area, data.alpha or 120)",
      "\t\t\tcreated[#created + 1] = area",
      "\t\tend",
      "\t\tlocal blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)",
      "\t\tSetBlipSprite(blip, data.sprite)",
      "\t\tSetBlipColour(blip, data.colour)",
      "\t\tSetBlipScale(blip, data.scale)",
      "\t\tSetBlipDisplay(blip, data.display)",
      "\t\tSetBlipAsShortRange(blip, data.shortrange)",
      "\t\tBeginTextCommandSetBlipName(\"STRING\")",
      "\t\tAddTextComponentSubstringPlayerName(data.name)",
      "\t\tEndTextCommandSetBlipName(blip)",
      "\t\tcreated[#created + 1] = blip",
      "\tend",
      "end)",
      "",
      "CreateThread(function()",
      "\twhile #Markers > 0 do",
      "\t\tlocal sleep = 1000",
      "\t\tlocal coords = GetEntityCoords(PlayerPedId())",
      "\t\tfor _, data in ipairs(Markers) do",
      "\t\t\tlocal distance = #(coords - vector3(data.coords.x, data.coords.y, data.coords.z))",
      "\t\t\tif distance < data.distance then",
      "\t\t\t\tsleep = 0",
      "\t\t\t\tDrawMarker(data.type, data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, data.heading, data.size.x, data.size.y, data.size.z, data.colour.r, data.colour.g, data.colour.b, data.colour.a, data.bob, data.face, 2, data.rotate, nil, nil, false)",
      "\t\t\telseif distance < data.distance + 60.0 and sleep > 250 then",
      "\t\t\t\tsleep = 250",
      "\t\t\tend",
      "\t\tend",
      "\t\tWait(sleep)",
      "\tend",
      "end)",
      "",
      "AddEventHandler(\"onResourceStop\", function(name)",
      "\tif name ~= GetCurrentResourceName() then return end",
      "\tfor _, blip in ipairs(created) do RemoveBlip(blip) end",
      "end)"
    ].join("\r\n");
    const files = [
      { rel: "config.lua", text: creditLua() + "Blips = " + luaValue(blips) + "\r\n\r\nMarkers = " + luaValue(markers) + "\r\n" },
      { rel: "client.lua", text: creditLua() + client + "\r\n" },
      { rel: "fxmanifest.lua", text: manifest({ description: "Blips " + record.name, clientScripts: ["config.lua", "client.lua"] }) }
    ];

    return writePlan(name, files, "game", { kind: "blips" });
  }

  function buildResource(kind, record, options, source) {
    const o = options || {};

    try {
      if (kind === "maps") return buildMap(record, o);
      if (kind === "handling") return buildHandling(record, o);
      if (kind === "peds") return buildPeds(record, o);
      if (kind === "blips") return buildBlips(record, o);
      if (kind === "shells" && globalThis.RTX_SHELL) return globalThis.RTX_SHELL.build(record, o, writePlan);
      if (kind === "designs" && globalThis.RTX_DESIGN) return globalThis.RTX_DESIGN.permanent(record, o, writePlan);
      if (kind === "icons" && globalThis.RTX_DESIGN) return globalThis.RTX_DESIGN.icons(record, o, writePlan);
    } catch (error) {
      console.log("^1[RTX SHELL CREATOR] " + kind + ": " + (error && error.stack || error) + "^0");
      return { ok: false, code: error && error.code || "build", message: error && error.code && error.message ? error.message : text("build_failed") };
    }

    return { ok: false, code: "kind", message: text("nothing_to_build") };
  }

  function dataFile(rel) {
    const clean = safeRel(rel);

    return clean ? path.join(DATA, clean) : null;
  }

  function saveDataFile(rel, base64) {
    const file = dataFile(rel);

    if (!file) return false;

    ensureDir(path.dirname(file));
    fs.writeFileSync(file, Buffer.from(String(base64 || ""), "base64"));

    return true;
  }

  function readDataFile(rel) {
    const file = dataFile(rel);

    if (!file || !fs.existsSync(file)) return null;

    return fs.readFileSync(file).toString("base64");
  }

  function removeDataFile(rel) {
    const file = dataFile(rel);

    if (file && fs.existsSync(file)) fs.unlinkSync(file);

    return true;
  }

  function cleanIncoming() {
    const now = Date.now();

    sessions.forEach(function (session, id) {
      if (now - session.at > 30 * 60 * 1000) {
        sessions.delete(id);
        removeFolder(session.folder);
      }
    });

    if (!fs.existsSync(INCOMING)) return;

    for (const entry of fs.readdirSync(INCOMING)) {
      const full = path.join(INCOMING, entry);
      const known = Array.from(sessions.values()).some(function (session) { return session.folder === full; });

      try {
        if (!known && now - fs.statSync(full).mtimeMs > 60 * 60 * 1000) removeFolder(full);
      } catch (error) {
        continue;
      }
    }
  }

  setInterval(cleanIncoming, 10 * 60 * 1000);

  exports("BuildResource", function (kind, record, options, source) { return buildResource(kind, record, options, source); });
  exports("RemoveDataFile", function (rel) { return removeDataFile(rel); });
  exports("SaveDataFile", function (rel, base64) { return saveDataFile(rel, base64); });
  exports("ReadDataFile", function (rel) { return readDataFile(rel); });
  exports("InstalledList", function () { try { return installedList(); } catch (error) { return []; } });
  exports("InstallBegin", function (data, from) { return guard(data && data.name, function () { return beginInstall(data || {}, from); }); });
  exports("InstallChunk", function (data) { return guard(sessionName(data), function () { return installChunk(data || {}); }); });
  exports("InstallFinish", function (data) { return guard(sessionName(data), function () { return finishInstall(data || {}); }); });
  exports("CollectionItems", function (name) { try { return collectionItems(name); } catch (error) { return []; } });
  exports("CollectionRemove", function (name, item) { return guard(name, function () { return collectionRemove(name, item); }); });

  return {
    setup: setup, text: text, resourcesRoot: resourcesRoot, installRoot: installRoot, writePlan: writePlan, beginInstall: beginInstall, installChunk: installChunk,
    finishInstall: finishInstall, installedList: installedList, collectionItems: collectionItems, collectionRemove: collectionRemove, removeInstalled: removeInstalled, luaValue: luaValue, creditLua: creditLua, manifest: manifest,
    cleanName: cleanName, saveDataFile: saveDataFile, readDataFile: readDataFile, removeDataFile: removeDataFile, safeRel: safeRel, CREDIT: CREDIT, DATA: DATA,
    recordSummaries: function () { return {}; }
  };
})();
