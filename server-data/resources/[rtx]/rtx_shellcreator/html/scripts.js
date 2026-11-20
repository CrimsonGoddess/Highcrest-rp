const STATE = {
  resource: "rtx_shellcreator",
  language: {},
  setup: {},
  menu: null,
  page: "home",
  tool: null,
  toolArgs: {},
  tokens: {},
  nextToken: 1,
  names: null,
  namesLoading: null,
  lists: {},
  favourites: [],
  recents: [],
  hoverTimer: 0,
  pointer: null,
  hud: {},
  home: {}
};

function T(key) {
  let text = STATE.language[key];

  if (text === undefined || text === null) return key;

  Array.prototype.slice.call(arguments, 1).forEach(function (arg) {
    text = text.replace("%s", arg);
  });

  return text;
}

function post(name, data) {
  return $.post("https://" + STATE.resource + "/" + name, JSON.stringify(data || {}));
}

function postJson(name, data) {
  return new Promise(function (resolve) {
    post(name, data).done(function (reply) {
      try {
        resolve(typeof reply === "string" ? JSON.parse(reply) : reply || {});
      } catch (error) {
        resolve({});
      }
    }).fail(function () {
      resolve({});
    });
  });
}

function token(callback) {
  const id = "t" + STATE.nextToken++;

  STATE.tokens[id] = callback;

  return id;
}

function store(action, kind, payload) {
  return new Promise(function (resolve) {
    post("store", { action: action, kind: kind, payload: payload, token: token(resolve) });
  });
}

function build(kind, record, options) {
  return new Promise(function (resolve) {
    post("build", { kind: kind, record: typeof record === "object" ? record : undefined, id: typeof record === "string" ? record : undefined, options: options || {}, token: token(resolve) });
  });
}

function design(action, payload) {
  return new Promise(function (resolve) {
    post("design", { action: action, payload: payload || {}, token: token(resolve) });
  });
}

function toolAction(action, value) {
  return postJson("toolAction", { tool: STATE.tool, action: action, value: value || {} });
}

function joaat(text) {
  const value = String(text || "").toLowerCase();
  let hash = 0;

  for (let i = 0; i < value.length; i++) {
    hash = (hash + value.charCodeAt(i)) >>> 0;
    hash = (hash + (hash << 10)) >>> 0;
    hash = (hash ^ (hash >>> 6)) >>> 0;
  }

  hash = (hash + (hash << 3)) >>> 0;
  hash = (hash ^ (hash >>> 11)) >>> 0;
  hash = (hash + (hash << 15)) >>> 0;

  return hash;
}

function unsigned(hash) {
  return Number(hash) >>> 0;
}

function loadList(name) {
  if (STATE.lists[name]) return Promise.resolve(STATE.lists[name]);

  return fetch("data/" + name + ".json").then(function (response) { return response.json(); }).then(function (data) {
    STATE.lists[name] = data;
    return data;
  }).catch(function () {
    STATE.lists[name] = [];
    return [];
  });
}

function loadNames() {
  if (STATE.names) return Promise.resolve(STATE.names);
  if (STATE.namesLoading) return STATE.namesLoading;

  STATE.namesLoading = Promise.all(["objects", "peds", "vehicles", "weapons"].map(loadList)).then(function (lists) {
    const map = new Map();

    lists.forEach(function (list) {
      (list || []).forEach(function (name) {
        map.set(joaat(name), name);
      });
    });

    STATE.names = map;

    return map;
  });

  return STATE.namesLoading;
}

function modelName(hash) {
  const value = unsigned(hash);

  if (STATE.names && STATE.names.has(value)) return STATE.names.get(value);

  return "0x" + value.toString(16).toUpperCase().padStart(8, "0");
}

function fmt(value, places) {
  const number = Number(value);

  if (!isFinite(number)) return "0";

  return number.toFixed(places === undefined ? 2 : places);
}

function v3(value, places) {
  const v = value || {};

  return "vector3(" + fmt(v.x, places) + ", " + fmt(v.y, places) + ", " + fmt(v.z, places) + ")";
}

function v4(value, heading, places) {
  const v = value || {};

  return "vector4(" + fmt(v.x, places) + ", " + fmt(v.y, places) + ", " + fmt(v.z, places) + ", " + fmt(heading === undefined ? v.w || v.h : heading, 2) + ")";
}

function timeAgo(stamp) {
  if (!stamp) return "";

  const seconds = Math.max(0, Math.floor(Date.now() / 1000) - stamp);

  if (seconds < 60) return T("ago_now");
  if (seconds < 3600) return T("ago_minutes", Math.floor(seconds / 60));
  if (seconds < 86400) return T("ago_hours", Math.floor(seconds / 3600));

  return T("ago_days", Math.floor(seconds / 86400));
}

function copyText(text, label) {
  const area = document.getElementById("clipboard");
  let done = false;

  area.value = text;
  area.focus();
  area.select();
  area.setSelectionRange(0, area.value.length);

  try {
    done = document.execCommand("copy");
  } catch (error) {
    done = false;
  }

  area.blur();

  if (!done && navigator.clipboard && navigator.clipboard.writeText) {
    return navigator.clipboard.writeText(text).then(function () {
      showNotify({ title: T("notify_title"), text: label || T("copied"), type: "success", timeout: 2500 });
      return true;
    }, function () {
      showNotify({ title: T("notify_title"), text: T("copy_failed"), type: "error", timeout: 3500 });
      return false;
    });
  }

  if (!done) {
    showNotify({ title: T("notify_title"), text: T("copy_failed"), type: "error", timeout: 3500 });
    return false;
  }

  showNotify({ title: T("notify_title"), text: label || T("copied"), type: "success", timeout: 2500 });

  return true;
}

function parseCoords(text) {
  const raw = String(text || "").toLowerCase();
  const named = {};
  const keyed = /([a-z_]+)["']?\s*[=:]\s*(-?\d*\.?\d+)/g;
  let match;
  let x, y, z, h;

  while ((match = keyed.exec(raw))) named[match[1]] = Number(match[2]);

  if (named.x !== undefined && named.y !== undefined) {
    x = named.x;
    y = named.y;
    z = named.z;
    h = named.w !== undefined ? named.w : named.h !== undefined ? named.h : named.heading;
  } else {
    const numbers = (raw.replace(/[a-z_][a-z0-9_]*/g, " ").match(/-?\d*\.?\d+/g) || []).map(Number);

    if (numbers.length < 2) return null;

    x = numbers[0];
    y = numbers[1];
    z = numbers[2];
    h = numbers[3];
  }

  if (!isFinite(x) || !isFinite(y) || Math.abs(x) > 20000 || Math.abs(y) > 20000) return null;
  if (z !== undefined && (!isFinite(z) || z < -500 || z > 5000)) return null;
  if (h !== undefined && !isFinite(h)) h = undefined;

  if (h !== undefined && (h < 0 || h >= 360)) h = Math.round((((h % 360) + 360) % 360) * 1000) / 1000;

  return { x: x, y: y, z: z, h: h };
}

function clipJob(item, job) {
  if (!item.clip) return job();

  setTimeout(function () {
    window.focus();
    Promise.resolve().then(job).catch(function () {}).then(function () { post("clipDone"); });
  }, 80);
}

function el(tag, cls, text) {
  const node = $("<" + tag + "></" + tag + ">");

  if (cls) node.addClass(cls);
  if (text !== undefined && text !== null) node.text(text);

  return node;
}

function icon(name) {
  return $('<i class="fa-solid"></i>').addClass(name);
}

function button(label, iconName, kind, onClick) {
  const node = el("button", "tk-btn" + (kind ? " " + kind : ""));

  if (iconName) node.append(icon(iconName));
  if (label) node.append($("<span></span>").text(label));
  if (onClick) node.on("click", function (event) { onClick(event, node); });

  return node;
}

function iconButton(iconName, onClick, title, cls) {
  const node = el("button", "tk-icon-btn small" + (cls ? " " + cls : "")).append(icon(iconName));

  if (title) node.attr("title", title);
  if (onClick) node.on("click", function (event) { event.stopPropagation(); onClick(event, node); });

  return node;
}

function field(label, control, hint, value) {
  const node = el("div", "tk-field");
  const head = el("div", "tk-field-label").append($("<span></span>").text(label));

  if (value !== undefined) head.append($("<b></b>").text(value));

  node.append(head, control);

  if (hint) node.append(el("div", "tk-hint", hint));

  return node;
}

function input(value, placeholder, onChange, options) {
  const o = options || {};
  const node = $('<input class="tk-input" spellcheck="false" autocomplete="off"/>');

  if (o.mono) node.addClass("mono");
  if (o.small) node.addClass("small");
  if (o.type) node.attr("type", o.type);

  node.val(value === undefined || value === null ? "" : value);

  if (placeholder) node.attr("placeholder", placeholder);
  if (onChange) node.on(o.live ? "input" : "change", function () { onChange(node.val(), node); });
  if (o.enter) node.on("keydown", function (event) { if (event.key === "Enter") o.enter(node.val(), node); });

  return node;
}

function select(options, value, onChange) {
  const node = $('<select class="tk-select"></select>');

  options.forEach(function (option) {
    const item = typeof option === "object" ? option : { value: option, label: option };

    node.append($("<option></option>").attr("value", item.value).text(item.label));
  });

  node.val(value);

  if (onChange) node.on("change", function () { onChange(node.val()); });

  return node;
}

function slider(min, max, step, value, onChange, options) {
  const o = options || {};
  const wrap = el("div", "tk-slider");
  const range = $('<input type="range" class="tk-range"/>').attr({ min: min, max: max, step: step }).val(value);
  const box = input(fmt(value, o.places === undefined ? 3 : o.places), "", null, { small: true });
  const paint = function () {
    const ratio = (Number(range.val()) - min) / (max - min || 1);

    range[0].style.setProperty("--fill", Math.max(0, Math.min(100, ratio * 100)) + "%");
  };
  let timer = 0;

  const fire = function (number, final) {
    clearTimeout(timer);

    if (final || !o.throttle) {
      if (onChange) onChange(number, final);
      return;
    }

    timer = setTimeout(function () { if (onChange) onChange(number, false); }, o.throttle);
  };

  range.on("input", function () {
    box.val(fmt(range.val(), o.places === undefined ? 3 : o.places));
    paint();
    fire(Number(range.val()), false);
  });
  range.on("change", function () { fire(Number(range.val()), true); });
  box.on("change", function () {
    const number = Number(box.val());

    if (!isFinite(number)) return;

    range.val(number);
    paint();
    fire(number, true);
  });
  paint();
  wrap.append(range, box);
  wrap.setValue = function (number) {
    range.val(number);
    box.val(fmt(number, o.places === undefined ? 3 : o.places));
    paint();
  };

  return wrap;
}

function segment(options, value, onChange, wide) {
  const node = el("div", "tk-segment" + (wide ? " wide" : ""));

  options.forEach(function (option) {
    const item = typeof option === "object" ? option : { value: option, label: option };
    const btn = el("button");

    if (item.icon) btn.append(icon(item.icon));
    if (item.label) btn.append($("<span></span>").text(item.label));
    if (item.value === value) btn.addClass("active");

    btn.on("click", function () {
      node.children().removeClass("active");
      btn.addClass("active");
      if (onChange) onChange(item.value);
    });
    node.append(btn);
  });

  if (wide && options.length > 4) {
    const labels = options.map(function (o) { return String(typeof o === "object" ? (o.label || "") : o) + (typeof o === "object" && o.icon ? "  " : ""); });
    const oneRow = labels.reduce(function (sum, l) { return sum + l.length * 6.4 + 26; }, 0);

    if (oneRow > 318) {
      const n = options.length;
      const longest = Math.max.apply(null, labels.map(function (l) { return Math.max.apply(null, l.split(" ").map(function (w) { return w.length; })); }));
      let cols = 3;

      for (let c = longest > 9 ? 3 : 4; c >= 2; c--) {
        if (n % c === 0 || n % c >= c - 1) { cols = c; break; }
      }

      node.addClass("grid").css("grid-template-columns", "repeat(" + cols + ", minmax(0, 1fr))");
    }
  }

  return node;
}

function toggle(on, onChange) {
  const node = el("button", "tk-switch" + (on ? " on" : ""));

  node.on("click", function () {
    node.toggleClass("on");
    if (onChange) onChange(node.hasClass("on"));
  });

  return node;
}

function switchRow(label, on, onChange, hint) {
  const row = el("div", "tk-row between");

  row.append($("<div></div>").append(el("div", "tk-tool-name", label), hint ? el("div", "tk-hint", hint) : null), toggle(on, onChange));

  return row;
}

function group(title, children, extra) {
  const node = el("div", "tk-group");
  const head = el("div", "tk-group-title").append($("<span></span>").text(title));

  if (extra) head.append(extra);

  node.append(head);
  (children || []).forEach(function (child) { if (child) node.append(child); });

  return node;
}

function codeBlock(text, labelText) {
  const wrap = el("div", "tk-stack tight");
  const box = el("div", "tk-code", text);
  const copyBtn = button(T("copy"), "fa-copy", "small", function () { copyText(box.text(), labelText); });

  wrap.append(box, el("div", "tk-row").append(copyBtn));
  wrap.setText = function (value) { box.text(value); };

  return wrap;
}

function modal(options) {
  const o = options || {};

  $("#modal-kicker").text(o.kicker || "");
  $("#modal-title").text(o.title || "");
  $("#modal-body").empty().append(o.body || []);
  $("#modal-actions").empty();
  $(".tk-modal-card").toggleClass("wide", o.wide === true);

  (o.actions || [{ label: T("close"), kind: "" }]).forEach(function (action) {
    $("#modal-actions").append(button(action.label, action.icon, action.kind, function () {
      if (action.run && action.run() === false) return;
      closeModal();
    }));
  });

  $("#modal").removeClass("hidden");
}

function closeModal() {
  $("#modal").addClass("hidden");
}

function askText(title, value, onDone, kicker) {
  const box = input(value || "", "", null, {});

  modal({
    kicker: kicker || T("notify_title"),
    title: title,
    body: [box],
    actions: [{ label: T("cancel") }, { label: T("ok"), kind: "primary", run: function () { onDone(String(box.val() || "").trim()); } }]
  });
  setTimeout(function () { box.trigger("focus").select(); }, 30);
}

function confirmBox(title, text, onYes, danger) {
  modal({
    kicker: T("notify_title"),
    title: title,
    body: [el("div", "", text)],
    actions: [{ label: T("cancel") }, { label: T("yes"), kind: danger ? "primary danger" : "primary", run: onYes }]
  });
}

function applyAccent(color) {
  if (!color || !/^#?[0-9a-fA-F]{6}$/.test(color)) return;

  const hex = color.replace("#", "");
  const r = parseInt(hex.substr(0, 2), 16);
  const g = parseInt(hex.substr(2, 2), 16);
  const b = parseInt(hex.substr(4, 2), 16);
  const root = document.documentElement.style;
  const mix = function (value) { return Math.min(255, Math.round(value + (255 - value) * 0.3)); };

  root.setProperty("--accent", "#" + hex);
  root.setProperty("--accent-2", "rgb(" + mix(r) + "," + mix(g) + "," + mix(b) + ")");
  root.setProperty("--accent-a10", "rgba(" + r + "," + g + "," + b + ",.10)");
  root.setProperty("--accent-a20", "rgba(" + r + "," + g + "," + b + ",.20)");
  root.setProperty("--accent-glow", "rgba(" + r + "," + g + "," + b + ",.28)");
}

function setHints(list) {
  const box = $("#hints").empty();

  if (!list || !list.length) {
    box.addClass("hidden");
    return;
  }

  const groups = [];

  list.forEach(function (item) {
    const name = item.group || "tool";
    let group = groups.find(function (g) { return g.name === name; });

    if (!group) {
      group = { name: name, items: [] };
      groups.push(group);
    }

    group.items.push(item);
  });

  groups.forEach(function (group) {
    const node = el("div", "tk-hint-group");

    if (groups.length > 1) node.append(el("div", "tk-hint-title", T(group.name === "camera" ? "hint_group_camera" : "hint_group_tool")));

    group.items.forEach(function (item) {
      const keys = el("div", "tk-hint-keys");

      item.keys.forEach(function (key, index) {
        if (index && item.keys.length === 2 && (item.or || item.plus)) keys.append(el("span", "tk-hint-or", item.plus ? "+" : "/"));
        keys.append(el("span", "tk-key", key));
      });

      node.append(el("div", "tk-hint-item").append(keys, el("span", "tk-hint-text", item.text)));
    });

    box.append(node);
  });

  box.removeClass("hidden");
}

function freecamHints(extra) {
  setHints([
    { keys: ["RMB"], text: T("hint_look"), group: "camera" },
    { keys: ["W", "A", "S", "D"], text: T("hint_fly"), group: "camera" },
    { keys: ["SPACE", "SHIFT"], text: T("hint_updown"), group: "camera", or: true },
    { keys: ["CTRL"], text: T("hint_fast"), group: "camera" },
    { keys: ["RMB", "SCROLL"], text: T("hint_speed"), group: "camera", plus: true }
  ].concat(extra || []));
}

function inPanel(target) {
  return $(target).closest("#dock, #menu, #modal, #designer, #shellplan, #hints, .tk-hud, #notify-stack, .sh-gd-card, .sh-walkbar, .sh-top, .sh-tools, .sh-side").length > 0;
}

document.addEventListener("pointerdown", function (event) {
  if (!STATE.tool || inPanel(event.target)) {
    STATE.pointer = null;
    return;
  }

  STATE.pointer = { x: event.clientX, y: event.clientY, at: Date.now(), button: event.button };

  if (event.button === 0 && STATE.tool === "shell" && typeof SHELL !== "undefined" && SHELL.open && !SHELL.walking && (SHELL.tool === "walls" || SHELL.tool === "room") && $(event.target).closest(".sh-canvas, .sh-side, .sh-top, .sh-tools").length === 0) {
    STATE.pointer.press = true;
    post("worldClick", { x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight, button: 0, shift: event.shiftKey, ctrl: event.ctrlKey, phase: "press" });
  }
});

document.addEventListener("pointerup", function (event) {
  const start = STATE.pointer;

  STATE.pointer = null;

  if (!start || !STATE.tool) return;

  if (start.press) {
    post("worldClick", { x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight, button: 0, shift: event.shiftKey, ctrl: event.ctrlKey, phase: "release" });
    return;
  }

  if (inPanel(event.target)) return;
  if (start.dragged) return;
  if (Math.abs(event.clientX - start.x) > 5 || Math.abs(event.clientY - start.y) > 5 || Date.now() - start.at > 450) return;
  if (start.button !== 0) return;

  post("worldClick", { x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight, button: 0, shift: event.shiftKey, ctrl: event.ctrlKey });
});

document.addEventListener("pointermove", function (event) {
  const press = STATE.pointer;

  if (press && press.button === 0 && STATE.tool === "shell" && typeof SHELL !== "undefined" && SHELL.open && SHELL.tool === "paint" && SHELL.paint && SHELL.paint.target !== "part" && SHELL.paint.target !== "tiles" && !inPanel(event.target)) {
    if (Math.abs(event.clientX - press.x) > 6 || Math.abs(event.clientY - press.y) > 6 || press.dragged) {
      if (!press.dragged) {
        press.dragged = true;
        post("worldClick", { x: press.x / window.innerWidth, y: press.y / window.innerHeight, button: 0, shift: event.shiftKey, ctrl: false });
      }

      if (Date.now() - (press.sent || 0) > 90) {
        press.sent = Date.now();
        post("worldClick", { x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight, button: 0, shift: event.shiftKey, ctrl: false });
      }
    }
  }

  if (!STATE.tool || !STATE.wantsHover || inPanel(event.target)) return;

  const now = Date.now();

  if (now - STATE.hoverTimer < 45) return;

  STATE.hoverTimer = now;
  post("worldHover", { x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight });
});

document.addEventListener("contextmenu", function (event) {
  event.preventDefault();
});

function stopLooking() {
  if (!STATE.looking) return;

  STATE.looking = false;
  $("#look-shield").remove();
  $("body").removeClass("looking");
}

document.addEventListener("mousedown", function (event) {
  if (event.button !== 2 || !STATE.tool || inPanel(event.target)) return;

  STATE.looking = true;
  $("body").addClass("looking");

  if (!$("#look-shield").length) $("body").append($('<div id="look-shield" class="tk-look-shield"></div>'));
}, true);

document.addEventListener("mouseup", function (event) {
  if (event.button === 2) stopLooking();
}, true);

window.addEventListener("blur", stopLooking);

function pressEscape(source) {
  const now = Date.now();

  if (now - (STATE.escapeAt || 0) < 350) return;

  STATE.escapeAt = now;

  if (STATE.looking) stopLooking();

  if (source !== "key" && document.activeElement && $(document.activeElement).is("input, textarea, select")) {
    document.activeElement.blur();
    return;
  }

  if (!$("#modal").hasClass("hidden")) {
    closeModal();
    return;
  }

  if (STATE.tool && typeof DOCK !== "undefined" && DOCK.escape) DOCK.escape();
}

document.addEventListener("keydown", function (event) {
  if (event.key === "Escape") {
    STATE.escapeDown = Date.now();
    pressEscape("key");
    return;
  }

  if (STATE.looking) {
    event.preventDefault();
    event.stopImmediatePropagation();
  }
});

document.addEventListener("keyup", function (event) {
  if (event.key === "Escape" && Date.now() - (STATE.escapeDown || 0) > 1500) pressEscape("keyup");
});

function onMessage(item) {
  switch (item.message) {
    case "Setup":
      STATE.resource = item.resource || STATE.resource;
      STATE.language = item.language || {};
      STATE.setup = item;
      applyAccent(item.color);
      document.documentElement.style.setProperty("--scale", item.scale || 1);
      try {
        STATE.favourites = JSON.parse(localStorage.getItem("rtxtk_favourites") || "[]");
        STATE.recents = JSON.parse(localStorage.getItem("rtxtk_recents") || "[]");
      } catch (error) {
        STATE.favourites = [];
        STATE.recents = [];
      }
      break;
    case "Home":
      STATE.home = item.data || {};
      break;
    case "Escape":
      pressEscape("game");
      break;
    case "ToolStart":
      if (document.activeElement && $(document.activeElement).is(TYPING_FIELDS)) document.activeElement.blur();
      STATE.typing = false;
      DOCK.start(item.tool, item.args || {});
      break;
    case "ToolStop":
      DOCK.stop(item.tool);
      break;
    case "Tool":
      DOCK.data(item.tool, item.data || {});
      break;
    case "ToolPanel":
      if (DOCK.ui && ["shell", "designer", "none"].indexOf(DOCK.ui.panel) < 0) {
        $("#dock").toggleClass("hidden", !item.show);
        $("body").toggleClass("dock-open", !!item.show);
      } else {
        $("#dock").addClass("hidden");
      }
      $("#hints").toggleClass("hidden", !item.show || !$("#hints").children().length);
      break;
    case "Store":
    case "Built":
    case "Dev":
    case "Design": {
      const callback = STATE.tokens[item.token];

      if (callback) {
        delete STATE.tokens[item.token];
        callback(item.message === "Store" ? item.reply : item.result, item.action);
      }

      break;
    }
    case "Copy":
      clipJob(item, function () { return copyText(item.text, item.label); });
      break;
    case "FreecamSpeed":
      if (DOCK.speed) DOCK.speed(item.speed);
      break;
    case "ShellReply":
    case "UploadReply": {
      const callback = typeof SHELL !== "undefined" ? SHELL.replies[item.token] : null;

      if (callback) {
        delete SHELL.replies[item.token];
        callback(item.reply, item.action);
      }

      break;
    }
    case "ShellWalk":
      if (typeof SHELL !== "undefined" && SHELL_UI.root) {
        SHELL.walking = item.on === true;
        SHELL_UI.root.toggleClass("walking", SHELL.walking);
        if (SHELL_UI.walkBar) SHELL_UI.walkBar.toggleClass("hidden", !SHELL.walking);
      }
      break;
    default:
      break;
  }
}

window.addEventListener("message", function (event) {
  const item = event.data || {};

  if (!item.message) return;

  try {
    onMessage(item);
  } catch (error) {
    console.log("RTX Shell Creator: " + (error && error.stack || error));
  }
});

const TYPING_FIELDS = "input:not([type=range]):not([type=checkbox]):not([type=radio]):not([type=button]):not([type=color]):not([type=file]), textarea, [contenteditable=true], [contenteditable='']";

function setTyping(on) {
  if (STATE.typing === on) return;

  STATE.typing = on;
  post("typing", { on: on });
}

$(document).on("focusin", TYPING_FIELDS, function () { setTyping(true); });
$(document).on("focusout", TYPING_FIELDS, function () {
  setTimeout(function () { setTyping(!!(document.activeElement && $(document.activeElement).is(TYPING_FIELDS))); }, 0);
});
