const NOTIFY_STATE = {
  nextId: 1,
  items: {},
  icons: {
    info: "fa-circle-dot",
    success: "fa-circle-check",
    error: "fa-circle-exclamation",
    warning: "fa-triangle-exclamation"
  }
};

function hideNotify(id) {
  const item = NOTIFY_STATE.items[id];

  if (!item) return;

  clearTimeout(item.timer);
  item.el.addClass("out");

  setTimeout(function () {
    item.el.remove();
  }, 260);

  delete NOTIFY_STATE.items[id];
}

function showNotify(data) {
  const id = NOTIFY_STATE.nextId++;
  const type = NOTIFY_STATE.icons[data.type] ? data.type : "info";
  const timeout = data.timeout || 5000;
  const el = $('<div class="notify-item"></div>').addClass(type);
  const icon = $('<div class="notify-icon"></div>').append($("<i></i>").addClass("fa-solid " + NOTIFY_STATE.icons[type]));
  const body = $('<div class="notify-body"></div>');

  body.append($('<div class="notify-title"></div>').text(data.title || ""));
  body.append($('<div class="notify-text"></div>').text(data.text || ""));

  const bar = $('<div class="notify-bar"></div>');

  el.append(icon, body, bar);
  $("#notify-stack").append(el);

  bar[0].animate([{ transform: "scaleX(1)" }, { transform: "scaleX(0)" }], { duration: timeout, easing: "linear" });

  NOTIFY_STATE.items[id] = {
    el: el,
    timer: setTimeout(function () {
      hideNotify(id);
    }, timeout)
  };

  const ids = Object.keys(NOTIFY_STATE.items);

  if (ids.length > 5) hideNotify(ids[0]);
}

window.addEventListener("message", function (event) {
  const item = event.data || {};

  if (item.message === "NotifyShow") showNotify(item);
});
