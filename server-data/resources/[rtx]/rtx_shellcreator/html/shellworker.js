importScripts("pako.min.js", "engine.js", "shellgeo.js", "shellbake.js");

onmessage = function (event) {
  const data = event.data || {};

  if (data.mode === "bake") {
    try {
      const km = self.RTX_SHELLBAKE.parse(data.km);
      const extra = data.extra || {};
      const parts = data.parts && data.parts.length ? data.parts : [{ name: data.name, built: data.built }];
      const files = [];
      const reports = [];

      parts.forEach(function (part, index) {
        if (parts.length > 1) postMessage({ progress: true, index: index, total: parts.length });

        const result = self.RTX_SHELLBAKE.bake(Object.assign({}, extra, part.textureSize ? { textureSize: part.textureSize } : {}, { MM: self.MM, kit: data.kit, km: km, built: part.built, images: data.images || {}, colours: data.colours || {}, name: part.name, collisionOnly: data.collisionOnly === true }));

        result.files.forEach(function (file) { files.push({ rel: file.rel, bytes: file.bytes instanceof Uint8Array ? file.bytes : new Uint8Array(file.bytes) }); });
        reports.push(result.report);
      });

      postMessage({ ok: true, files: files, report: reports[0], reports: reports, names: parts.map(function (p) { return p.name; }) }, files.map(function (f) { return f.bytes.buffer; }).filter(function (b, i, all) { return all.indexOf(b) === i; }));
    } catch (error) {
      postMessage({ ok: false, message: error && error.message ? error.message : String(error) });
    }

    return;
  }

  try {
    const converted = self.RTX_SHELLGEO.toProject(data.doc, data.kit, data.options || {});
    const images = data.images || {};
    const assets = Object.keys(images).length ? { images: images, detail: true, textureSize: 512, maxTextureSize: 512 } : {};
    const result = self.MM.mlobuild.build(converted.project, assets, {});
    const transfer = [];
    const files = result.files.map(function (file) {
      const bytes = file.bytes instanceof Uint8Array ? file.bytes : new Uint8Array(file.bytes);

      if (transfer.indexOf(bytes.buffer) < 0) transfer.push(bytes.buffer);

      return { rel: file.rel, bytes: bytes };
    });

    postMessage({ ok: true, files: files, warnings: result.warnings || [] }, transfer);
  } catch (error) {
    postMessage({ ok: false, code: error && error.code, message: error && error.message ? error.message : String(error) });
  }
};
