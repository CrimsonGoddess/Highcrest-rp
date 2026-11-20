const HOME = {
  tab: "home",
  list: [],
  query: "",
  sort: "recent",
  pages: [
    { id: "home", icon: "fa-house" },
    { id: "houses", icon: "fa-layer-group" },
    { id: "templates", icon: "fa-bookmark" },
    { id: "help", icon: "fa-circle-question" }
  ],
  starts: [
    { id: "layout", index: 0, icon: "fa-table-cells-large" },
    { id: "empty", index: 1, icon: "fa-vector-square" },
    { id: "template", index: 2, icon: "fa-bookmark" },
    { id: "code", index: 4, icon: "fa-file-import" }
  ],
  render: function () {
    const root = SHELL_UI.root.empty().removeClass("editing");
    const shell = el("div", "sc-home");
    const side = el("aside", "sc-side");
    const nav = el("nav", "sc-nav");
    const who = STATE.home && STATE.home.name ? STATE.home.name : "";

    HOME.pages.forEach(function (page) {
      const item = el("button", "sc-nav-item" + (HOME.tab === page.id ? " active" : "")).append(icon(page.icon), $("<span></span>").text(T("sc_tab_" + page.id)));

      if (page.id === "houses") item.append(el("b", "sc-nav-count", String(HOME.list.length)));

      item.on("click", function () { HOME.go(page.id); });
      nav.append(item);
    });

    side.append(
      el("div", "sc-brand").append(
        el("div", "sc-brand-mark").append(icon("fa-house-chimney")),
        $("<div></div>").append(el("div", "sc-brand-title", T("sc_brand")), el("div", "sc-brand-sub", T("sc_brand_sub")))
      ),
      nav,
      el("div", "sc-side-foot").append(
        who ? el("div", "sc-who").append(el("span", "sc-who-badge", who.slice(0, 1).toUpperCase()), $("<div></div>").append(el("div", "sc-who-name", who), el("div", "sc-who-role", T("sc_who_role")))) : null,
        button(T("close"), "fa-xmark", "sc-close", function () { post("toolStop", { close: true }); }).append(el("span", "tk-key", "ESC"))
      )
    );

    HOME.main = el("main", "sc-main");
    shell.append(
      el("div", "sc-body").append(side, HOME.main),
      el("div", "sc-foot").append(
        $("<span></span>").text(T("sc_credit")),
        el("span", "sc-foot-links").append(icon("fa-brands fa-discord"), $("<span></span>").text("discord.gg/rtxdev"), icon("fa-store"), $("<span></span>").text("rtx.tebex.io"))
      )
    );
    root.append(shell);
    HOME.page();
  },
  go: function (tab) {
    HOME.tab = tab;
    SHELL_UI.root.find(".sc-nav-item").each(function (index) { $(this).toggleClass("active", HOME.pages[index].id === tab); });
    HOME.page();
  },
  page: function () {
    const main = HOME.main.empty();

    main.scrollTop(0);

    if (HOME.tab === "houses") return HOME.houses(main);
    if (HOME.tab === "templates") return HOME.templates(main);
    if (HOME.tab === "help") return HOME.help(main);

    return HOME.home(main);
  },
  load: function () {
    return shellRequest("list").then(function (reply) {
      HOME.list = (reply && reply.list) || [];
      SHELL.library = HOME.list;
      SHELL_UI.root.find(".sc-nav-count").text(String(HOME.list.length));

      return HOME.list;
    });
  },
  create: function (start) {
    SHELL_UI.newDialog();

    const item = HOME.starts.find(function (s) { return s.id === start; });

    if (item) $("#modal .sh-start-seg button").eq(item.index).trigger("click");
  },
  open: function (item) {
    SHELL_UI.loading();
    toolAction("open", { id: item.id });
  },
  head: function (title, text, actions) {
    return el("div", "sc-page-head").append(
      $("<div></div>").append(el("div", "sc-page-title", title), text ? el("div", "sc-page-text", text) : null),
      actions ? el("div", "sc-page-actions").append(actions) : null
    );
  },
  home: function (main) {
    const hero = el("section", "sc-hero");
    const last = HOME.list[0];
    const startRow = el("div", "sc-starts");
    const recent = el("div", "sc-recent");
    const fill = function () {
      const latest = HOME.list[0];

      hero.find(".sc-continue").remove();

      if (latest) {
        hero.find(".sc-hero-actions").append(button(T("sc_continue", latest.name), "fa-pen-ruler", "sc-continue", function () { HOME.open(latest); }));
      }

      recent.empty();

      if (!HOME.list.length) {
        recent.append(el("div", "sc-recent-empty").append(icon("fa-compass-drafting"), el("div", "", T("sc_recent_empty"))));
      } else {
        HOME.list.slice(0, 6).forEach(function (item) { recent.append(HOME.row(item)); });
      }
    };

    hero.append(
      el("div", "sc-hero-art").append($("<img/>").attr({ src: "img/home/shell.webp", alt: "", draggable: false })),
      el("div", "sc-hero-text").append(
        el("div", "sc-hero-title", T("sc_hero_title")),
        el("div", "sc-hero-sub", T("sc_hero_text")),
        el("div", "sc-hero-actions").append(button(T("sh_new"), "fa-plus", "primary sc-new", function () { HOME.create("layout"); }))
      )
    );

    HOME.starts.forEach(function (start) {
      startRow.append(el("button", "sc-start").append(
        el("span", "sc-start-icon").append(icon(start.icon)),
        el("span", "sc-start-title", T("sc_start_" + start.id)),
        el("span", "sc-start-text", T("sc_start_" + start.id + "_text")),
        el("span", "sc-start-go").append(icon("fa-arrow-right"))
      ).on("click", function () { HOME.create(start.id); }));
    });

    main.append(
      HOME.alert(),
      hero,
      el("div", "sc-section-title", T("sc_start_title")),
      startRow,
      el("div", "sc-panel").append(el("div", "sc-panel-head").append(el("div", "sc-panel-title", T("sc_recent_title")), button(T("sc_all_houses"), "fa-arrow-right", "small", function () { HOME.go("houses"); })), recent)
    );

    if (!last) fill();

    HOME.load().then(function () {
      if (HOME.tab === "home" && $.contains(document, main[0])) fill();
    });
  },
  row: function (item) {
    const art = el("canvas", "sc-row-art");
    const stats = item.stats || {};

    art.attr({ width: 168, height: 104 });
    SHELL_UI.cardArt(art[0], item);

    return el("div", "sc-row").append(
      art,
      el("div", "sc-row-text").append(
        el("div", "sc-row-name", item.name),
        el("div", "sc-row-meta").append(
          $("<span></span>").append(icon("fa-door-closed"), " " + (stats.rooms || 0)),
          $("<span></span>").append(icon("fa-ruler-combined"), " " + fmt(stats.area || 0, 0) + " m²"),
          $("<span></span>").text(timeAgo(item.updated))
        ),
        item.permanent ? el("span", "tk-badge good", T("sh_permanent_badge", item.permanent.resource)) : null
      ),
      button(T("sh_open"), "fa-pen-ruler", "small primary", function () { HOME.open(item); })
    ).on("dblclick", function () { HOME.open(item); });
  },
  alert: function () {
    const h = STATE.home || {};
    const box = el("div", "sc-alerts");
    const missing = Array.isArray(h.missingaces) ? h.missingaces : (h.ace ? [] : ["refresh", "ensure", "start", "stop"]);
    const card = function (kind, title, text, lines) {
      return el("div", "sc-alert " + kind).append(
        el("span", "sc-alert-icon").append(icon(kind === "bad" ? "fa-triangle-exclamation" : "fa-key")),
        $("<div></div>").append(el("div", "sc-alert-title", title), el("div", "sc-alert-text", text)),
        el("pre", "sc-code").text(lines.join("\n"))
      );
    };

    if (!h.assets) box.append(card("bad", T("sc_check_assets"), T("sc_check_assets_no"), ["ensure rtx_shellcreator_assets", "ensure rtx_shellcreator"]));

    if (missing.length) box.append(card("warn", T("sc_check_ace"), T("sc_check_ace_no"), missing.map(function (c) { return "add_ace resource." + STATE.resource + " command." + c + " allow"; })));

    return box.children().length ? box : null;
  },
  houses: function (main) {
    const grid = el("div", "sh-cards sc-grid");
    const search = input(HOME.query, T("sc_search"), null, { live: true, small: true });
    const draw = function () {
      const needle = HOME.query.toLowerCase();
      const list = HOME.list.filter(function (item) { return !needle || String(item.name || "").toLowerCase().indexOf(needle) >= 0; }).slice();

      if (HOME.sort === "name") list.sort(function (a, b) { return String(a.name).localeCompare(String(b.name)); });
      if (HOME.sort === "size") list.sort(function (a, b) { return ((b.stats || {}).area || 0) - ((a.stats || {}).area || 0); });

      grid.empty();
      list.forEach(function (item) { grid.append(SHELL_UI.card(item)); });

      if (!needle) grid.append(el("button", "sh-card sh-card-new").append(el("span", "sh-card-new-icon").append(icon("fa-plus")), el("span", "sh-card-new-title", T("sh_new")), el("span", "sh-card-new-text", T("sh_new_card_text"))).on("click", function () { HOME.create("layout"); }));
      if (needle && !list.length) grid.append(el("div", "sh-empty").append(icon("fa-magnifying-glass"), el("div", "", T("sc_search_none"))));
    };

    search.on("input", function () { HOME.query = String(search.val() || ""); draw(); });
    main.append(
      HOME.head(T("sh_library_title"), T("sh_library_text"), [
        el("div", "sc-search").append(icon("fa-magnifying-glass"), search),
        segment([{ value: "recent", label: T("sc_sort_recent") }, { value: "name", label: T("sc_sort_name") }, { value: "size", label: T("sc_sort_size") }], HOME.sort, function (value) { HOME.sort = value; draw(); }),
        button(T("sh_new"), "fa-plus", "primary", function () { HOME.create("layout"); })
      ]),
      grid
    );
    grid.append(el("div", "sh-empty", T("sh_loading")));
    HOME.load().then(function () {
      if (!$.contains(document, grid[0])) return;

      if (!HOME.list.length) {
        grid.empty().append(el("div", "sh-empty").append(icon("fa-house-chimney"), el("div", "", T("sh_library_empty")), button(T("sh_new"), "fa-plus", "primary small", function () { HOME.create("layout"); })));
        return;
      }

      draw();
    });
  },
  templates: function (main) {
    const grid = el("div", "sc-templates");
    const draw = function (list) {
      grid.empty();

      if (!list.length) {
        grid.append(el("div", "sc-empty-card").append(icon("fa-bookmark"), el("div", "sc-empty-title", T("sc_templates_empty")), el("div", "sc-page-text", T("sc_templates_empty_text"))));
        return;
      }

      list.forEach(function (t) {
        grid.append(el("div", "sc-template").append(
          el("span", "sc-template-icon").append(icon("fa-bookmark")),
          $("<div></div>").append(el("div", "sc-template-name", t.name), el("div", "sc-template-meta", T("sh_template_meta", t.floors || 1, t.rooms || 0))),
          el("div", "sc-template-actions").append(
            button(T("sc_template_use"), "fa-plus", "small primary", function () {
              askText(T("sh_new_title"), t.name, function (name) {
                SHELL_UI.loading();
                shellRequest("create", { name: name || t.name, choice: { template: t.id } }).then(function (reply) {
                  if (reply && reply.ok && reply.shell) toolAction("open", { id: reply.shell.id });
                  else {
                    if (reply && reply.message) showNotify({ title: T("notify_title"), text: reply.message, type: "error" });
                    HOME.render();
                  }
                });
              }, T("sh_kicker"));
            }),
            iconButton("fa-trash", function () {
              confirmBox(T("sc_template_delete"), T("sc_template_delete_text", t.name), function () {
                shellRequest("deletetemplate", { template: t.id }).then(function (reply) { draw((reply && reply.list) || []); });
              }, true);
            }, T("delete"))
          )
        ));
      });
    };

    main.append(HOME.head(T("sc_templates_title"), T("sc_templates_text")), grid, el("div", "sc-hint").append(icon("fa-lightbulb"), $("<span></span>").text(T("sc_templates_how"))));
    grid.append(el("div", "sh-empty", T("sh_loading")));
    shellRequest("templates", {}).then(function (reply) { if ($.contains(document, grid[0])) draw((reply && reply.list) || []); });
  },
  help: function (main) {
    const steps = el("div", "sc-steps");

    [1, 2, 3, 4].forEach(function (n) {
      steps.append(el("div", "sc-step").append(el("div", "sc-step-top").append(el("span", "sc-step-num", String(n)), el("span", "sc-step-line")), el("div", "sc-step-title", T("sc_step_" + n)), el("div", "sc-step-text", T("sc_step_" + n + "_text"))));
    });

    const keys = el("div", "sc-keys");
    const keyGroups = [
      ["sc_keys_plan", [[["LMB"], "sh_hint_select"], [["MMB"], "sh_hint_pan"], [["SCROLL"], "sh_hint_zoom"], [["SHIFT"], "sh_hint_free_angle"], [["ENTER"], "sh_hint_walls_end"], [["R"], "sh_hint_turn_90"], [["DEL"], "sh_hint_delete"], [["CTRL", "LMB"], "sh_hint_pick"], [["CTRL", "Z"], "sh_hint_undo"], [["ESC"], "sh_hint_cancel"]]],
      ["sc_keys_3d", [[["RMB"], "sh_hint_cam_look"], [["↑", "↓", "←", "→"], "sh_hint_cam_move"], [["Q", "E"], "sh_hint_cam_turn"], [["MMB"], "sh_hint_cam_orbit"], [["SCROLL"], "sh_hint_zoom"]]]
    ];

    keyGroups.forEach(function (g) {
      keys.append(el("div", "sc-keys-title", T(g[0])));
      g[1].forEach(function (row) {
        const combo = el("div", "sc-combo");

        row[0].forEach(function (k, i) {
          if (i) combo.append(el("span", "sc-plus", "+"));
          combo.append(el("kbd", "", k));
        });
        keys.append(el("div", "sc-key-row").append(el("span", "", T(row[1])), combo));
      });
    });

    const faq = el("div", "sc-faq");

    ["housing", "shellmlo", "notseen", "team", "history", "share", "textures", "where"].forEach(function (id, index) {
      const item = el("div", "sc-faq-item" + (index === 0 ? " open" : ""));

      item.append(
        el("button", "sc-faq-q").append($("<span></span>").text(T("sc_faq_" + id)), icon("fa-chevron-down")).on("click", function () { item.toggleClass("open"); }),
        el("div", "sc-faq-a", T("sc_faq_" + id + "_a"))
      );
      faq.append(item);
    });

    main.append(
      HOME.head(T("sc_help_title"), T("sc_help_text")),
      steps,
      el("div", "sc-help-grid").append(
        el("div", "sc-help-card").append(el("div", "sc-section-title", T("sc_faq_title")), faq),
        el("div", "sc-help-card").append(el("div", "sc-section-title", T("sc_keys_title")), keys)
      ),
      el("div", "sc-discord").append(
        el("span", "sc-discord-icon").append(icon("fa-brands fa-discord")),
        $("<div></div>").append(el("div", "sc-discord-title", T("sc_discord_title")), el("div", "sc-discord-text", T("sc_discord_text"))),
        el("span", "sc-discord-invite").append(icon("fa-brands fa-discord"), $("<span></span>").text("discord.gg/rtxdev"))
      )
    );
  }

};

SHELL_UI.library = function () {
  HOME.render();
};
