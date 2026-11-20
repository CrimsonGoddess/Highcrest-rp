importScripts("shellgeo.js");

let kit = null;

onmessage = function (event) {
  const data = event.data || {};

  if (data.kit) kit = data.kit;
  if (!data.doc || !kit) return;

  try {
    const built = self.RTX_SHELLGEO.build(data.doc, kit);

    postMessage({ id: data.id, ok: true, pieces: built.pieces, doors: built.doors, lamps: built.lamps, ladders: built.ladders, elevators: built.elevators, slots: built.slots });
  } catch (error) {
    postMessage({ id: data.id, ok: false });
  }
};
