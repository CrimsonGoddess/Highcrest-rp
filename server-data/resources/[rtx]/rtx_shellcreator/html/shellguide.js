const SHELL_GUIDE = {
  open: false,
  steps: [],
  index: 0,
  timer: null,
  doneAt: 0,
  layer: null,
  ring: null,
  card: null,
  topic: "",
  rooms: function () { return SHELL.built ? SHELL.built.derived.rooms : []; },
  firstRoom: function () {
    const here = SHELL_GUIDE.rooms().filter(function (r) { return r.level === SHELL.level; });

    return here[0] || SHELL_GUIDE.rooms()[0] || null;
  },
  count: function (kind, test) {
    return ((SHELL.doc && SHELL.doc[kind]) || []).filter(test || function () { return true; }).length;
  },
  ensureRoom: function () {
    if (SHELL_GUIDE.firstRoom()) return SHELL_GUIDE.firstRoom();

    const b = SHELL.built && SHELL.built.bounds;
    const x = b ? Math.round((b.min[0] + b.max[0]) / 2) : 0;
    const y = b ? Math.round((b.min[1] + b.max[1]) / 2) : 0;

    SHELL.roomShape = "rect";
    SHELL_UI.addWalls(SHELL_UI.roomWalls([x - 3, y - 2.5], [x + 3, y + 2.5]));
    SHELL_UI.fit();

    return SHELL_GUIDE.firstRoom();
  },
  freeWall: function (need) {
    const room = SHELL_GUIDE.ensureRoom();

    if (!room) return null;

    const rooms = [room].concat(SHELL_GUIDE.rooms().filter(function (r) { return r !== room && r.level === room.level; }));

    for (const r of rooms) {
      const edges = r.edges.slice().sort(function (a, b) { return b.length - a.length; });

      for (const edge of edges) {
        const wall = shellFind("walls", edge.wall);

        if (!wall || Math.abs(Number(wall.bend) || 0) >= 0.02) continue;

        const total = SG.vec.len(SG.vec.sub(wall.b, wall.a));
        const taken = (SHELL.doc.openings || []).filter(function (o) { return o.wall === wall.id; }).map(function (o) {
          const w = Number(o.w) || (SG.OPENINGS[o.kind] || SG.OPENINGS.door).width;

          return [Number(o.t) - w / 2 - 0.3, Number(o.t) + w / 2 + 0.3];
        }).sort(function (a, b) { return a[0] - b[0]; });
        let from = 0.4;
        let best = null;

        taken.concat([[total - 0.4, total]]).forEach(function (span) {
          const gap = span[0] - from;

          if (gap >= need && (!best || gap > best.gap)) best = { gap: gap, t: from + gap / 2 };
          from = Math.max(from, span[1]);
        });

        if (best) return { wall: wall, total: total, room: r, edge: edge, t: SG.round(Math.round(best.t / 0.05) * 0.05, 3) };
      }
    }

    return null;
  },
  doDoor: function () {
    const spot = SHELL_GUIDE.freeWall(1.1);

    if (!spot) return;

    shellCommit({ set: { openings: [{ id: SG.uid("o"), wall: spot.wall.id, kind: "door", t: spot.t, door: SHELL.lastDoor || "plain_white" }] } });
  },
  doWindow: function () {
    const spot = SHELL_GUIDE.freeWall(1.5);

    if (!spot) return;

    shellCommit({ set: { openings: [{ id: SG.uid("o"), wall: spot.wall.id, kind: "window", t: spot.t }] } });
  },
  doFloor: function () {
    const room = SHELL_GUIDE.ensureRoom();

    if (!room) return;

    shellCommit({ set: { rooms: [Object.assign(SG.clone(room.record), { floor: room.record.floor === "herring" ? "parquet" : "herring" })] } });
  },
  doTiles: function () {
    const room = SHELL_GUIDE.ensureRoom();

    if (!room) return;

    const centre = room.record.anchor || SG.interiorPoint(room.points);
    const cell = SG.tileCell(room, centre);
    const tiles = Object.assign({}, room.record.tiles || {});

    for (let i = cell.i - 2; i < cell.i + 2; i++) {
      for (let j = cell.j - 2; j < cell.j + 2; j++) tiles[i + "," + j] = (i + j) % 2 === 0 ? "mblack" : "marble";
    }

    shellCommit({ set: { rooms: [Object.assign(SG.clone(room.record), { tiles: tiles })] } });
  },
  doKitchen: function () {
    const room = SHELL_GUIDE.ensureRoom();

    if (!room) return;

    const edge = room.edges.slice().filter(function (e) { return !e.curved; }).sort(function (a, b) { return b.length - a.length; })[0];

    if (!edge) return;

    const d = SG.vec.norm(SG.vec.sub(edge.b, edge.a));
    const w = Math.min(3, edge.length - 0.4);
    const depth = 0.62;
    const mid = SG.vec.add(SG.vec.mul(SG.vec.add(edge.a, edge.b), 0.5), SG.vec.mul(SG.vec.left(d), depth / 2 + 0.002));
    const ax = SG.vec.mul(d, -1);
    const heading = SG.round(Math.atan2(ax[1], ax[0]) * 180 / Math.PI, 2);

    shellCommit({ set: { details: [{ id: SG.uid("dt"), level: room.level, kind: "kitchen", at: [SG.round(mid[0], 3), SG.round(mid[1], 3)], heading: heading, w: SG.round(w, 2), d: depth, h: 0.9, mat: "white", top: "marble" }] } });
  },
  doLight: function () {
    const room = SHELL_GUIDE.ensureRoom();

    if (!room) return;

    const a = room.record.anchor || SG.interiorPoint(room.points);

    shellCommit({ set: { lights: [{ id: SG.uid("li"), p: [SG.round(a[0], 3), SG.round(a[1], 3), SG.round(room.z + room.height - 0.01, 3)], shape: "round", colour: "#ffe2bd", range: 7, intensity: 6 }] } });
  },
  tool: function (id) {
    return function () { if (SHELL.tool !== id) SHELL_UI.setTool(id); };
  },
  pickOpening: function (kind, kinds) {
    return function () {
      if (SHELL.tool !== "opening") SHELL_UI.setTool("opening");

      if (kinds.indexOf(SHELL.sub) < 0) {
        SHELL.sub = kind;
        SHELL_UI.drawSide();
      }

      const label = $(".sh-side .sh-palette-label").eq(kind === "window" ? 1 : 0);

      if (label.length) label[0].scrollIntoView({ block: "nearest" });
    };
  },
  topics: function () {
    const G = SHELL_GUIDE;
    const toolBtn = function (id) { return ".sh-tools [data-tool='" + id + "']"; };

    return [
      {
        id: "tour", icon: "fa-route", steps: [
          { id: "intro", target: [".sh-stage"], side: "center" },
          { id: "room", enter: G.tool("room"), target: [toolBtn("room")], side: "right", done: function () { return G.rooms().length > 0; }, act: function () { G.ensureRoom(); } },
          { id: "door", enter: G.pickOpening("door", ["door", "double", "glassdoor", "french", "sliding"]), target: [toolBtn("opening"), ".sh-side"], side: "right", count: function () { return G.count("openings", function (o) { return SG.WINDOW_KINDS.indexOf(o.kind) < 0; }); }, done: true, act: G.doDoor },
          { id: "window", enter: G.pickOpening("window", SG.WINDOW_KINDS), target: [".sh-side"], side: "left", count: function () { return G.count("openings", function (o) { return SG.WINDOW_KINDS.indexOf(o.kind) >= 0; }); }, done: true, act: G.doWindow },
          { id: "paint", enter: G.tool("paint"), target: [toolBtn("paint")], side: "right", done: function () { return G.rooms().some(function (r) { return r.record.floor && r.record.floor !== "oak"; }); }, act: G.doFloor },
          { id: "tiles", enter: function () { G.tool("paint")(); SHELL.paint.target = "tiles"; SHELL_UI.drawSide(); }, target: [".sh-side"], side: "left", done: function () { return G.rooms().some(function (r) { return r.record.tiles && Object.keys(r.record.tiles).length > 0; }); }, act: G.doTiles },
          { id: "kitchen", enter: function () { SHELL.detailGroup = "kitchen"; G.tool("details")(); }, target: [toolBtn("details"), ".sh-side"], side: "right", count: function () { return G.count("details", function (x) { return SG.DETAILS[x.kind] && SG.DETAILS[x.kind].group === "kitchen"; }); }, done: true, act: G.doKitchen },
          { id: "light", enter: G.tool("light"), target: [toolBtn("light")], side: "right", count: function () { return G.count("lights"); }, done: true, act: G.doLight },
          { id: "view", target: [".sh-modes"], side: "below", done: function () { return SHELL.mode !== "plan"; }, act: function () { SHELL_UI.setMode("split"); } },
          { id: "cut", target: [".sh-cut", ".sh-top-right"], side: "below" },
          { id: "parts", target: [".sh-parts"], side: "below" },
          { id: "finish", target: [".sh-finish-btn"], side: "below" }
        ]
      },
      { id: "walls", icon: "fa-pen-ruler", steps: [{ id: "walls1", enter: G.tool("walls"), target: [toolBtn("walls")], side: "right" }, { id: "walls2", enter: G.tool("walls"), target: [".sh-side"], side: "left" }, { id: "walls3", target: [".sh-stage"], side: "center" }] },
      { id: "rooms", icon: "fa-vector-square", steps: [{ id: "rooms1", enter: G.tool("room"), target: [toolBtn("room")], side: "right" }, { id: "rooms2", enter: G.tool("room"), target: [".sh-side"], side: "left" }, { id: "rooms3", enter: G.tool("select"), target: [".sh-stage"], side: "center" }] },
      { id: "openings", icon: "fa-door-open", steps: [{ id: "openings1", enter: G.tool("opening"), target: [".sh-side"], side: "left" }, { id: "openings2", target: [".sh-stage"], side: "center" }] },
      { id: "floors", icon: "fa-chess-board", steps: [{ id: "floors1", enter: G.tool("paint"), target: [".sh-side"], side: "left" }, { id: "floors2", enter: function () { G.tool("paint")(); SHELL.paint.target = "tiles"; SHELL_UI.drawSide(); }, target: [".sh-side"], side: "left" }, { id: "floors3", target: [".sh-stage"], side: "center" }] },
      { id: "mouldings", icon: "fa-grip-lines", steps: [{ id: "mouldings1", enter: function () { SHELL.panel = "house"; SHELL_UI.drawSide(); }, target: [".sh-side-panel", ".sh-side"], side: "left" }, { id: "mouldings2", target: [".sh-side"], side: "left" }] },
      { id: "kitchen", icon: "fa-kitchen-set", steps: [{ id: "kitchen1", enter: function () { SHELL.detailGroup = "kitchen"; G.tool("details")(); }, target: [".sh-side"], side: "left" }, { id: "kitchen2", target: [".sh-stage"], side: "center" }] },
      { id: "stairs", icon: "fa-stairs", steps: [{ id: "stairs1", enter: G.tool("stairs"), target: [".sh-side"], side: "left" }, { id: "stairs2", target: [".sh-levels"], side: "below" }] },
      { id: "floorsup", icon: "fa-building", steps: [{ id: "floorsup1", target: [".sh-levels"], side: "below" }, { id: "floorsup2", target: [".sh-levels"], side: "below" }] },
      { id: "view3d", icon: "fa-cube", steps: [{ id: "view3d1", target: [".sh-modes"], side: "below" }, { id: "view3d2", target: [".sh-cut", ".sh-top-right"], side: "below" }, { id: "view3d3", target: [".sh-top-right"], side: "below" }] },
      { id: "housing", icon: "fa-house-chimney", steps: [{ id: "housing1", target: [".sh-finish-btn"], side: "below" }, { id: "housing2", target: [".sh-parts"], side: "below" }, { id: "housing3", target: [".sh-stage"], side: "center" }] }
    ];
  },
  menu: function () {
    const list = el("div", "sh-gd-topics");

    SHELL_GUIDE.topics().forEach(function (topic) {
      const item = el("button", "sh-gd-topic" + (topic.id === "tour" ? " main" : "")).append(
        el("span", "sh-gd-topic-icon").append(icon(topic.icon)),
        el("span", "sh-gd-topic-body").append(el("span", "sh-gd-topic-title", T("sh_gd_" + topic.id)), el("span", "sh-gd-topic-text", T("sh_gd_" + topic.id + "_text"))),
        el("span", "sh-gd-topic-count", topic.id === "tour" ? T("sh_gd_steps", topic.steps.length) : T("sh_gd_steps", topic.steps.length))
      );

      item.on("click", function () {
        closeModal();
        SHELL_GUIDE.start(topic.id);
      });
      list.append(item);
    });
    modal({ kicker: T("sh_kicker"), title: T("sh_gd_title"), wide: true, body: [el("div", "tk-hint", T("sh_gd_intro")), list], actions: [{ label: T("close") }] });
  },
  start: function (id) {
    const topic = SHELL_GUIDE.topics().find(function (t) { return t.id === id; });

    if (!topic) return;

    SHELL_GUIDE.stop();
    SHELL_GUIDE.open = true;
    SHELL_GUIDE.topic = id;
    SHELL_GUIDE.steps = topic.steps;
    SHELL_GUIDE.index = 0;
    SHELL_GUIDE.shownIndex = -1;
    SHELL_GUIDE.build();
    SHELL_GUIDE.show();
    SHELL_GUIDE.timer = setInterval(SHELL_GUIDE.tick, 350);

    try { localStorage.setItem("rtx_shell_guide_seen", "1"); } catch (error) { return; }
  },
  stop: function () {
    clearInterval(SHELL_GUIDE.timer);
    SHELL_GUIDE.timer = null;
    SHELL_GUIDE.open = false;

    if (SHELL_GUIDE.layer) SHELL_GUIDE.layer.remove();

    SHELL_GUIDE.layer = null;
  },
  build: function () {
    SHELL_GUIDE.layer = el("div", "sh-gd-layer");
    SHELL_GUIDE.ring = el("div", "sh-gd-ring");
    SHELL_GUIDE.card = el("div", "sh-gd-card");
    SHELL_GUIDE.layer.append(SHELL_GUIDE.ring, SHELL_GUIDE.card);
    $("body").append(SHELL_GUIDE.layer);
  },
  current: function () {
    return SHELL_GUIDE.open ? SHELL_GUIDE.steps[SHELL_GUIDE.index] : null;
  },
  isDone: function (step) {
    try {
      if (step && step.count) return step.count() > (step.base || 0);

      return !!(step && step.done && step.done());
    } catch (error) {
      return false;
    }
  },
  show: function () {
    const G = SHELL_GUIDE;
    const step = G.current();

    if (!step) return;

    if (step.enter) {
      try { step.enter(); } catch (error) { console.log("[rtx shell guide]", error); }
    }

    if (step.count && G.shownIndex !== G.index) step.base = step.count();

    G.doneAt = 0;

    const total = G.steps.length;
    const done = G.isDone(step);

    if (G.shownIndex !== G.index) {
      G.shownIndex = G.index;
      G.startedDone = done;
    }
    const actions = el("div", "sh-gd-actions");

    if (G.index > 0) actions.append(button(T("sh_gd_back"), "fa-chevron-left", "small", function () { G.go(-1); }));
    if (step.act && !done) actions.append(button(T("sh_gd_do_it"), "fa-wand-magic-sparkles", "small", function () { step.act(); G.tick(); }));

    actions.append(el("div", "sh-gd-space"), button(G.index === total - 1 ? T("sh_gd_finish") : T("sh_gd_next"), G.index === total - 1 ? "fa-flag-checkered" : "fa-chevron-right", "small primary", function () { G.go(1); }));

    G.card.empty().append(
      el("div", "sh-gd-head").append(
        el("div", "tk-kicker accent", T("sh_gd_" + G.topic) + "  ·  " + (G.index + 1) + " / " + total),
        iconButton("fa-xmark", function () { G.stop(); }, T("close"), "small")
      ),
      el("div", "sh-gd-progress").append(el("div", "sh-gd-progress-fill").css("width", ((G.index + 1) / total * 100) + "%")),
      el("div", "sh-gd-title", T("sh_gd_" + step.id + "_title")),
      el("div", "sh-gd-text", T("sh_gd_" + step.id + "_text")),
      step.done ? el("div", "sh-gd-task" + (done ? " done" : "")).append(icon(done ? "fa-circle-check" : "fa-circle"), $("<span></span>").text(done ? T("sh_gd_task_done") : T("sh_gd_task_" + step.id))) : null,
      actions
    );
    G.place();
  },
  go: function (delta) {
    const G = SHELL_GUIDE;
    const next = G.index + delta;

    if (next >= G.steps.length) {
      G.stop();
      showNotify({ title: T("notify_title"), text: T("sh_gd_done"), type: "success", timeout: 3000 });
      return;
    }

    G.index = Math.max(0, next);
    G.show();
  },
  rectOf: function (step) {
    for (const selector of step.target || []) {
      const node = $(selector).filter(":visible").first();

      if (!node.length) continue;

      const box = node[0].getBoundingClientRect();

      if (box.width > 2 && box.height > 2) return { left: box.left, top: box.top, width: box.width, height: box.height, centre: step.side === "center" };
    }

    return null;
  },
  place: function () {
    const G = SHELL_GUIDE;
    const step = G.current();

    if (!step || !G.layer) return;

    const r = G.rectOf(step);
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const card = G.card[0];
    const cw = card.offsetWidth || 360;
    const ch = card.offsetHeight || 220;
    const pad = 6;

    if (!r || r.centre) {
      G.ring.toggleClass("soft", true).css(r ? { left: r.left + pad * 4, top: r.top + pad * 4, width: Math.max(0, r.width - pad * 8), height: Math.max(0, r.height - pad * 8) } : { left: vw / 2, top: vh / 2, width: 0, height: 0 });
      G.card.css({ left: Math.round((vw - cw) / 2), top: Math.round((vh - ch) / 2) });
      return;
    }

    G.ring.toggleClass("soft", false).css({ left: r.left - pad, top: r.top - pad, width: r.width + pad * 2, height: r.height + pad * 2 });

    const options = {
      right: { left: r.left + r.width + 18, top: r.top + r.height / 2 - ch / 2 },
      left: { left: r.left - cw - 18, top: r.top + r.height / 2 - ch / 2 },
      below: { left: r.left + r.width / 2 - cw / 2, top: r.top + r.height + 18 },
      above: { left: r.left + r.width / 2 - cw / 2, top: r.top - ch - 18 }
    };
    const order = [step.side || "right", "right", "left", "below", "above"];
    let spot = null;

    for (const side of order) {
      const o = options[side];

      if (!o) continue;
      if (o.left >= 8 && o.top >= 8 && o.left + cw <= vw - 8 && o.top + ch <= vh - 8) {
        spot = o;
        break;
      }
    }

    spot = spot || options[step.side] || options.right;
    G.card.css({ left: Math.round(Math.max(8, Math.min(vw - cw - 8, spot.left))), top: Math.round(Math.max(8, Math.min(vh - ch - 8, spot.top))) });
  },
  tick: function () {
    const G = SHELL_GUIDE;
    const step = G.current();

    if (!step || !SHELL.open) {
      if (!SHELL.open) G.stop();
      return;
    }

    G.place();

    if (!step.done) return;

    const done = G.isDone(step);
    const shown = G.card.find(".sh-gd-task").hasClass("done");

    if (done && !shown) {
      G.show();
      G.doneAt = Date.now();
    }

    if (done && !G.startedDone && G.doneAt && Date.now() - G.doneAt > 1500 && G.index < G.steps.length - 1) G.go(1);
  },
  offer: function () {
    let seen = false;

    try { seen = localStorage.getItem("rtx_shell_guide_seen") === "1"; } catch (error) { seen = true; }

    if (seen || SHELL_GUIDE.open || (SHELL.doc && (SHELL.doc.walls || []).length > 0)) return;

    try { localStorage.setItem("rtx_shell_guide_seen", "1"); } catch (error) { return; }

    modal({
      kicker: T("sh_kicker"),
      title: T("sh_gd_offer_title"),
      body: [el("div", "tk-hint", T("sh_gd_offer_text"))],
      actions: [{ label: T("sh_gd_offer_no") }, { label: T("sh_gd_offer_yes"), kind: "primary", icon: "fa-route", run: function () { setTimeout(function () { SHELL_GUIDE.start("tour"); }, 50); } }]
    });
  }
};

$(window).on("resize", function () { if (SHELL_GUIDE.open) SHELL_GUIDE.place(); });
