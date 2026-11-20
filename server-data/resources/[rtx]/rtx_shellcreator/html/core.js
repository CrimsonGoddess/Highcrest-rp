const TOOL_UI = {};

const DOCK = {
  current: null,
  ui: null,
  start: function (tool, args) {
    const ui = TOOL_UI[tool];

    DOCK.current = tool;
    DOCK.ui = ui || null;
    STATE.tool = tool;
    STATE.toolArgs = args || {};
    STATE.wantsHover = !!(ui && ui.hover);
    $("#menu").addClass("hidden");

    if (!ui || ui.panel === "none") {
      $("#dock").addClass("hidden");
      $("body").removeClass("dock-open dock-left");
      setHints(ui && ui.hints ? ui.hints() : null);
      if (ui && ui.start) ui.start(args || {});
      return;
    }

    if (ui.panel === "designer" || ui.panel === "shell") {
      $("#dock").addClass("hidden");
      $("body").removeClass("dock-open dock-left");
      if (ui.start) ui.start(args || {});
      return;
    }

    $("#dock").removeClass("hidden left").toggleClass("wide", !!ui.wide);
    $("body").addClass("dock-open").removeClass("dock-left").toggleClass("dock-wide", !!ui.wide);
    $("#dock-kicker").text(T("dock_kicker_" + (ui.group || "build")));
    $("#dock-title").text(T("tool_" + tool));
    $("#dock-mark").empty().append(icon(((typeof CATALOGUE !== "undefined" && CATALOGUE.find(function (t) { return t.id === tool; })) || {}).icon || "fa-screwdriver-wrench"));
    $("#dock-body").empty();
    $("#dock-foot").empty();
    setHints(ui.hints ? ui.hints() : null);

    if (ui.start) ui.start(args || {}, $("#dock-body"), $("#dock-foot"));
  },
  stop: function (tool) {
    if (DOCK.ui && DOCK.ui.stop) DOCK.ui.stop();

    DOCK.current = null;
    DOCK.ui = null;
    STATE.tool = null;
    STATE.wantsHover = false;
    $("#dock").addClass("hidden").removeClass("wide");
    $("body").removeClass("dock-open dock-left dock-wide");
    $("#designer").addClass("hidden");
    $("#shellplan").addClass("hidden");
    setHints(null);
    $("#hud-timer").addClass("hidden");
    $("#letterbox").addClass("hidden");
  },
  data: function (tool, data) {
    if (DOCK.ui && DOCK.ui.data && tool === DOCK.current) DOCK.ui.data(data);
  },
  speed: function (value) {
    if (DOCK.ui && DOCK.ui.speed) DOCK.ui.speed(value);
  },
  escape: function () {
    if (DOCK.ui && DOCK.ui.escape) {
      DOCK.ui.escape();
      return;
    }

    post("toolStop");
  },
  body: function () {
    return $("#dock-body");
  },
  foot: function () {
    return $("#dock-foot");
  }
};

$("#dock-close").on("click", function () { post("toolStop"); });
$("#dock-back").on("click", function () { post("toolStop"); });

function remember(listName, value, max) {
  const list = STATE[listName].filter(function (item) { return item !== value; });

  list.unshift(value);
  STATE[listName] = list.slice(0, max || 40);

  try {
    localStorage.setItem("rtxtk_" + listName, JSON.stringify(STATE[listName]));
  } catch (error) {
    return null;
  }

  return null;
}

function isFavourite(model) {
  return STATE.favourites.indexOf(model) >= 0;
}

function toggleFavourite(model) {
  if (isFavourite(model)) {
    STATE.favourites = STATE.favourites.filter(function (item) { return item !== model; });
  } else {
    STATE.favourites.unshift(model);
  }

  try {
    localStorage.setItem("rtxtk_favourites", JSON.stringify(STATE.favourites));
  } catch (error) {
    return null;
  }

  return null;
}

function availableModels() {
  if (STATE.available !== undefined) return Promise.resolve(STATE.available);
  if (STATE.availableLoading) return STATE.availableLoading;

  STATE.availableLoading = loadList("furniture").then(function (items) {
    const models = Array.from(new Set((items || []).map(function (item) { return String(item.m).toLowerCase(); })));

    return postJson("modelsAvailable", { models: models });
  }).then(function (reply) {
    STATE.available = reply && Array.isArray(reply.available) ? new Set(reply.available.map(function (m) { return String(m).toLowerCase(); })) : null;
    return STATE.available;
  });

  return STATE.availableLoading;
}

propBrowser.memory = {};

function propBrowser(onPick, options) {
  const o = options || {};
  const wrap = el("div", "tk-stack tight" + (o.fill ? " tk-prop-fill" : ""));
  const tabs = el("div", "tk-chips");
  const search = input("", T("props_search"), null, { live: true });
  const grid = el("div", "tk-props");
  const memory = o.keep ? (propBrowser.memory[o.keep] = propBrowser.memory[o.keep] || {}) : {};
  const list = el("div", "tk-list tall");
  const roomChips = el("div", "tk-chips");
  const subChips = el("div", "tk-chips tk-sub-chips");
  let tab = memory.tab || (o.catalogue === false ? "all" : "catalogue");
  let room = memory.room || "";
  let sub = memory.sub || "";
  let timer = 0;

  const card = function (model, label) {
    const item = el("div", "tk-prop");
    const star = el("span", "tk-prop-star" + (isFavourite(model) ? " on" : "")).append(icon("fa-star"));
    const image = propImg($("<img loading=\"lazy\"/>"), model);

    image.on("error", function () {
      image.attr("src", "img/noimage.webp").off("error");
    });

    star.on("click", function (event) {
      event.stopPropagation();
      toggleFavourite(model);
      star.toggleClass("on", isFavourite(model));
    });
    item.append(star, image, el("div", "tk-prop-name", label || model));
    item.attr("title", model);
    item.on("click", function () {
      grid.children().removeClass("active");
      item.addClass("active");
      remember("recents", model, 40);
      onPick(model);
    });

    return item;
  };

  const row = function (model) {
    const item = el("div", "tk-item").append(icon("fa-cube"), $("<span></span>").text(model));
    const star = iconButton(isFavourite(model) ? "fa-star" : "fa-regular fa-star", function () {
      toggleFavourite(model);
      draw();
    });

    item.append(el("div", "tk-item-end").append(star));
    item.on("click", function () {
      remember("recents", model, 40);
      onPick(model);
    });

    return item;
  };

  const draw = function () {
    const needle = String(search.val() || "").trim().toLowerCase();

    grid.empty();
    list.empty();
    grid.toggleClass("hidden", tab === "all");
    list.toggleClass("hidden", tab !== "all");
    roomChips.toggleClass("hidden", tab !== "catalogue");
    subChips.toggleClass("hidden", tab !== "catalogue" || !room);

    memory.tab = tab;
    memory.room = room;
    memory.sub = sub;

    if (tab === "catalogue") {
      Promise.all([loadList("furniture"), availableModels()]).then(function (got) {
        const items = got[0];
        const available = got[1];
        const seen = new Set();
        const inRoom = (items || []).filter(function (item) { return room && item.c === room && (!available || available.has(String(item.m).toLowerCase())); });
        const subs = [];

        inRoom.forEach(function (item) { if (subs.indexOf(item.s) < 0) subs.push(item.s); });

        if (sub && subs.indexOf(sub) < 0) sub = "";

        subChips.empty();

        if (room && subs.length > 1) {
          subChips.append(el("button", "tk-chip small" + (sub ? "" : " active"), T("furn_sub_all")).on("click", function () { sub = ""; draw(); }));
          subs.forEach(function (name) {
            const label = T("furn_sub_" + name);

            subChips.append(el("button", "tk-chip small" + (sub === name ? " active" : ""), label !== "furn_sub_" + name ? label : name).on("click", function () { sub = name; draw(); }));
          });
        }

        const matches = (items || []).filter(function (item) {
          const key = String(item.m).toLowerCase();

          if (available && !available.has(key)) return false;
          if (room && item.c !== room) return false;
          if (room && sub && item.s !== sub) return false;
          if (needle && (item.m + " " + item.s + " " + item.c + " " + T("furn_sub_" + item.s)).toLowerCase().indexOf(needle) < 0) return false;
          if (seen.has(key)) return false;
          seen.add(key);
          return true;
        });
        let shown = 0;
        const more = function () {
          const stop = Math.min(matches.length, shown + 120);

          for (; shown < stop; shown++) grid.append(card(matches[shown].m));
        };

        grid.empty();
        grid.off("scroll.more").on("scroll.more", function () {
          if (shown < matches.length && grid[0].scrollTop + grid[0].clientHeight > grid[0].scrollHeight - 260) more();
        });
        more();

        if (!matches.length) grid.append(el("div", "tk-empty", T("props_none")));
      });
    } else if (tab === "favourites" || tab === "recents") {
      const source = tab === "favourites" ? STATE.favourites : STATE.recents;
      const shown = source.filter(function (model) { return !needle || model.toLowerCase().indexOf(needle) >= 0; });

      shown.forEach(function (model) { grid.append(card(model)); });

      if (!shown.length) grid.append(el("div", "tk-empty", T(tab === "favourites" ? "props_no_favourites" : "props_no_recents")));
    } else {
      loadList(o.list || "objects").then(function (items) {
        let shown = 0;

        list.empty();

        if (needle.length < 2) {
          list.append(el("div", "tk-empty", T("props_type_more")));
          return;
        }

        for (let i = 0; i < items.length && shown < 150; i++) {
          if (items[i].toLowerCase().indexOf(needle) >= 0) {
            list.append(row(items[i]));
            shown++;
          }
        }

        if (!shown) list.append(el("div", "tk-empty", T("props_none")));

        if (needle && !shown) {
          list.append(button(T("props_use_typed", needle), "fa-cube", "small", function () { onPick(needle); }));
        }
      });
    }
  };

  const tabList = [];

  if (o.catalogue !== false) tabList.push(["catalogue", T("props_tab_catalogue")]);
  tabList.push(["all", T("props_tab_all")], ["favourites", T("props_tab_favourites")], ["recents", T("props_tab_recents")]);
  tabList.forEach(function (pair) {
    const chip = el("button", "tk-chip" + (tab === pair[0] ? " active" : ""), pair[1]);

    chip.on("click", function () {
      tab = pair[0];
      tabs.children().removeClass("active");
      chip.addClass("active");
      draw();
    });
    tabs.append(chip);
  });

  if (o.catalogue !== false) {
    loadList("furniture").then(function (items) {
      const rooms = [];

      (items || []).forEach(function (item) { if (rooms.indexOf(item.c) < 0) rooms.push(item.c); });

      const all = el("button", "tk-chip" + (room ? "" : " active"), T("props_all_rooms"));

      all.on("click", function () { room = ""; sub = ""; roomChips.children().removeClass("active"); all.addClass("active"); draw(); });
      roomChips.append(all);
      rooms.forEach(function (name) {
        const chip = el("button", "tk-chip" + (room === name ? " active" : ""), T("room_" + name) !== "room_" + name ? T("room_" + name) : name);

        chip.on("click", function () { room = name; sub = ""; roomChips.children().removeClass("active"); chip.addClass("active"); draw(); });
        roomChips.append(chip);
      });
    });
  }

  search.on("input", function () {
    clearTimeout(timer);
    timer = setTimeout(draw, 160);
  });
  wrap.append(tabs, search, roomChips, subChips, grid, list);
  draw();

  return wrap;
}

const gizmoState = { mode: "translate", space: "world" };

function gizmoControls() {
  const wrap = el("div", "tk-stack tight");

  wrap.append(
    segment([{ value: "translate", label: T("gizmo_move"), icon: "fa-up-down-left-right" }, { value: "rotate", label: T("gizmo_rotate"), icon: "fa-rotate" }], gizmoState.mode, function (value) { gizmoState.mode = value; post("gizmoMode", { mode: value }); }, true),
    segment([{ value: "world", label: T("gizmo_world"), icon: "fa-globe" }, { value: "local", label: T("gizmo_local"), icon: "fa-cube" }], gizmoState.space, function (value) { gizmoState.space = value; post("gizmoSpace", { space: value }); }, true)
  );

  let move = 0;
  let rotate = 0;
  const send = function () { post("gizmoSnap", { move: move, rotate: rotate }); };

  wrap.append(
    el("div", "tk-grid2").append(
      field(T("gizmo_snap_move"), slider(0, 1, 0.05, 0, function (value) { move = value; send(); }, { places: 2 })),
      field(T("gizmo_snap_rotate"), slider(0, 45, 5, 0, function (value) { rotate = value; send(); }, { places: 0 }))
    )
  );

  return wrap;
}

function speedControl() {
  const control = slider(0.05, 8, 0.05, 1, function (value) { post("freecamSpeed", { speed: value }); }, { places: 2 });

  return { node: field(T("freecam_speed"), control), set: function (value) { control.setValue(value); } };
}

function vecInputs(values, onChange, places) {
  const grid = el("div", "tk-grid3");
  const boxes = {};

  ["x", "y", "z"].forEach(function (axis) {
    boxes[axis] = input(fmt(values[axis], places === undefined ? 3 : places), axis, function () {
      onChange({ x: Number(boxes.x.val()) || 0, y: Number(boxes.y.val()) || 0, z: Number(boxes.z.val()) || 0 });
    }, { small: true, mono: true });
    grid.append(boxes[axis]);
  });

  grid.setValues = function (next) {
    ["x", "y", "z"].forEach(function (axis) {
      if (document.activeElement !== boxes[axis][0]) boxes[axis].val(fmt(next[axis], places === undefined ? 3 : places));
    });
  };

  return grid;
}

function exportModal(title, sections, extraActions) {
  const body = [];
  let current = sections[0];
  const area = codeBlock(current.text(), T("copied"));
  const tabs = el("div", "tk-chips");
  const where = el("div", "tk-export-where");
  const showWhere = function (section) {
    where.empty().toggle(!!section.hint);
    if (section.hint) where.append(icon("fa-circle-info"), $("<span></span>").text(section.hint));
  };

  sections.forEach(function (section, index) {
    const chip = el("button", "tk-chip" + (index === 0 ? " active" : ""), section.label);

    chip.on("click", function () {
      current = section;
      tabs.children().removeClass("active");
      chip.addClass("active");
      area.setText(section.text());
      showWhere(section);
    });
    tabs.append(chip);
  });

  showWhere(current);
  body.push(tabs, where, area);

  if (extraActions) body.push(extraActions);

  modal({ kicker: T("export_kicker"), title: title, body: body, wide: true });
}

function luaString(value) {
  return "\"" + String(value === undefined || value === null ? "" : value).replace(/\\/g, "\\\\").replace(/"/g, "\\\"") + "\"";
}

function dzThree() {
  if (typeof THREE !== "undefined") return Promise.resolve();
  if (STATE.threeLoading) return STATE.threeLoading;

  STATE.threeLoading = new Promise(function (resolve) {
    const script = document.createElement("script");

    try {
      delete window.__THREE__;
    } catch (error) {
      window.__THREE__ = undefined;
    }

    script.src = "three.min.js";
    script.onload = function () { resolve(); };
    script.onerror = function () { resolve(); };
    document.head.appendChild(script);
  });

  return STATE.threeLoading;
}

const PROP_PACK = { index: null, buffer: null, urls: {}, loading: null };

function propPack() {
  if (!PROP_PACK.loading) {
    PROP_PACK.loading = Promise.all([
      fetch("img/props.json").then(function (r) { return r.json(); }),
      fetch("img/props.bin").then(function (r) { return r.arrayBuffer(); })
    ]).then(function (got) {
      PROP_PACK.index = got[0] || {};
      PROP_PACK.buffer = got[1];
    }).catch(function () {
      PROP_PACK.index = {};
    });
  }

  return PROP_PACK.loading;
}

function propUrl(model) {
  const key = String(model || "").toLowerCase();

  if (PROP_PACK.urls[key]) return PROP_PACK.urls[key];

  const spot = PROP_PACK.index && PROP_PACK.index[key];

  if (!spot || !PROP_PACK.buffer) return "img/noimage.webp";

  PROP_PACK.urls[key] = URL.createObjectURL(new Blob([PROP_PACK.buffer.slice(spot[0], spot[0] + spot[1])], { type: "image/webp" }));

  return PROP_PACK.urls[key];
}

function propImg(image, model) {
  if (PROP_PACK.index) return image.attr("src", propUrl(model));

  propPack().then(function () { image.attr("src", propUrl(model)); });

  return image;
}

propPack();
