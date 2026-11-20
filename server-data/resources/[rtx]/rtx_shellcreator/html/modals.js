$(function () {
  // unikátní "state" pro tyhle helpery
  const pcuiState = {
	keymapVisible: false,
	confirmVisible: false,
	confirmCallbacks: {
	  onConfirm: null,
	  onCancel: null
	},
	$els: {
	  keymap: null,
	  keymapAction: null,
	  keymapList: null,
	  confirmModal: null,
	  confirmHeader: null,
	  confirmText: null,
	  confirmAccept: null,
	  confirmCancel: null,
	  confirmClose: null
	}
  };

	function closeMain() {
		$("body").css("display", "none");
	}

	function openMain() {
		$("body").css("display", "block");
	}

  function pcuiEnsureElements () {
	const $e = pcuiState.$els;

	if (!$e.keymap) {
	  $e.keymap       = $('#pcui-keymap');
	  $e.keymapAction = $('#pcui-keymap-action');
	  $e.keymapList   = $('#pcui-keymap-list');
	}
	if (!$e.confirmModal) {
	  $e.confirmModal  = $('#pcui-confirm-modal');
	  $e.confirmHeader = $('#pcui-confirm-header');
	  $e.confirmText   = $('#pcui-confirm-text');
	  $e.confirmAccept = $('#pcui-confirm-accept');
	  $e.confirmCancel = $('#pcui-confirm-cancel');
	  $e.confirmClose  = $('#pcui-confirm-close');
	}
  }

  /* ============================= KEYMAP ============================= */

  function pcuiRenderKeymap (options) {
	pcuiEnsureElements();
	const $action = pcuiState.$els.keymapAction;
	const $list   = pcuiState.$els.keymapList;
	if (!$action || !$action.length || !$list || !$list.length) return;

	const actionLabel = options && options.actionLabel ? options.actionLabel : '';
	const keys = Array.isArray(options && options.keys) ? options.keys : [];

	$action.text(actionLabel || '');
	$list.empty();

	keys.forEach(function (item) {
	  if (!item) return;

	  const $row = $('<li/>', { class: 'pcui-key-row' });

	  const $pill = $('<span/>', {
		class: 'pcui-key-pill',
		text: String(item.key || '').toUpperCase()
	  });

	  const $label = $('<span/>', {
		class: 'pcui-key-label',
		text: item.label || ''
	  });

	  $row.append($pill).append($label);
	  $list.append($row);
	});
  }

  function pcuiShowKeymap (options) {
	pcuiEnsureElements();
	const $keymap = pcuiState.$els.keymap;
	if (!$keymap || !$keymap.length) return;

	pcuiRenderKeymap(options || {});
	$keymap.addClass('pcui-keymap-show');
	pcuiState.keymapVisible = true;

	// klávesy ESC / Backspace skryjí overlay
	$(document)
	  .off('keydown.pcuiKeymap')
	  .on('keydown.pcuiKeymap', function (ev) {
		if (ev.key === 'Escape' || ev.key === 'Backspace') {
		  pcuiHideKeymap();
		}
	  });
  }

  function pcuiHideKeymap () {
	pcuiEnsureElements();
	const $keymap = pcuiState.$els.keymap;
	const $list   = pcuiState.$els.keymapList;
	if (!$keymap || !$keymap.length) return;

	$keymap.removeClass('pcui-keymap-show');
	pcuiState.keymapVisible = false;

	if ($list && $list.length) {
	  $list.empty();
	}

	$(document).off('keydown.pcuiKeymap');
  }

  /* ============================= CONFIRM ============================ */

  function pcuiBuildButton ($button, config, fallbackLabel, fallbackIcon) {
	if (!$button || !$button.length) return;

	const label = (config && config.label) || fallbackLabel;
	const iconClass = config && config.icon ? config.icon : fallbackIcon;

	let html = '';
	if (iconClass) {
	  html += '<i class="fa-solid ' + iconClass + '"></i> ';
	}
	html += label || '';
	$button.html(html);
  }

  function pcuiShowConfirm (options) {
	pcuiEnsureElements();
	const $modal   = pcuiState.$els.confirmModal;
	const $header  = pcuiState.$els.confirmHeader;
	const $text    = pcuiState.$els.confirmText;
	const $accept  = pcuiState.$els.confirmAccept;
	const $cancel  = pcuiState.$els.confirmCancel;
	const $close   = pcuiState.$els.confirmClose;

	if (!$modal || !$modal.length) return;

	const opts       = options || {};
	const confirmCfg = opts.confirm || {};
	const cancelCfg  = opts.cancel || {};

	$header.text(opts.header || 'Confirm Action');
	$text.text(
	  (typeof opts.text === 'string')
		? opts.text
		: 'Do you really want to perform this action?'
	);

	pcuiBuildButton($accept, confirmCfg, 'Confirm', 'fa-check');
	pcuiBuildButton($cancel, cancelCfg, 'Cancel', 'fa-xmark');

	pcuiState.confirmCallbacks.onConfirm =
	  (typeof opts.onConfirm === 'function') ? opts.onConfirm : null;
	pcuiState.confirmCallbacks.onCancel =
	  (typeof opts.onCancel === 'function') ? opts.onCancel : null;

	const doConfirm = function () {
	  if (pcuiState.confirmCallbacks.onConfirm) {
		try { pcuiState.confirmCallbacks.onConfirm(); } catch (err) { console.error(err); }
	  }
	  pcuiHideConfirm();
	};

	const doCancel = function () {
	  if (pcuiState.confirmCallbacks.onCancel) {
		try { pcuiState.confirmCallbacks.onCancel(); } catch (err) { console.error(err); }
	  }
	  pcuiHideConfirm();
	};

	// button bindy přes jQuery
	if ($accept && $accept.length) {
	  $accept.off('click.pcuiConfirm').on('click.pcuiConfirm', function (e) {
		e.preventDefault();
		doConfirm();
	  });
	}

	if ($cancel && $cancel.length) {
	  $cancel.off('click.pcuiConfirm').on('click.pcuiConfirm', function (e) {
		e.preventDefault();
		doCancel();
	  });
	}

	if ($close && $close.length) {
	  $close.off('click.pcuiConfirm').on('click.pcuiConfirm', function (e) {
		e.preventDefault();
		doCancel();
	  });
	}

	// ESC / Enter
	$(document)
	  .off('keydown.pcuiConfirm')
	  .on('keydown.pcuiConfirm', function (ev) {
		if (ev.key === 'Escape') {
		  ev.preventDefault();
		  doCancel();
		} else if (ev.key === 'Enter') {
		  if (pcuiState.confirmVisible) {
			ev.preventDefault();
			doConfirm();
		  }
		}
	  });

	$modal.addClass('pcui-modal-show');
	pcuiState.confirmVisible = true;
  }

  function pcuiHideConfirm () {
	pcuiEnsureElements();
	const $modal  = pcuiState.$els.confirmModal;
	const $accept = pcuiState.$els.confirmAccept;
	const $cancel = pcuiState.$els.confirmCancel;
	const $close  = pcuiState.$els.confirmClose;

	if (!$modal || !$modal.length) return;

	$modal.removeClass('pcui-modal-show');
	pcuiState.confirmVisible = false;

	pcuiState.confirmCallbacks.onConfirm = null;
	pcuiState.confirmCallbacks.onCancel  = null;

	$(document).off('keydown.pcuiConfirm');

	if ($accept && $accept.length) $accept.off('click.pcuiConfirm');
	if ($cancel && $cancel.length) $cancel.off('click.pcuiConfirm');
	if ($close  && $close.length)  $close.off('click.pcuiConfirm');
  }

  // ====================== GLOBAL API (unikátní) ======================
  // můžeš volat z Fivem / jiného JS:
  // RTXHousingUI.showKeymap({ actionLabel: 'Enter Point', keys:[...] })
  // RTXHousingUI.showConfirm({ header, text, onConfirm, onCancel, ... })

  window.RTXHousingUI = {
	showKeymap: pcuiShowKeymap,
	hideKeymap: pcuiHideKeymap,
	showConfirm: pcuiShowConfirm,
	hideConfirm: pcuiHideConfirm
  };

  // ---------------------------- DEMO (zakomentovaný) -----------------
  /*
  RTXHousingUI.showKeymap({
	actionLabel: 'Enter Point',
	keys: [
	  { key: 'ENTER',     label: 'Select position' },
	  { key: 'SCROLL',    label: 'Rotate' },
	  { key: 'LEFT CTRL', label: 'Slow down' },
	  { key: 'BACKSPACE', label: 'Cancel' }
	]
  });

  RTXHousingUI.showConfirm({
	header: 'Confirm Purchase',
	text: 'Do you want to buy this house for $250,000?',
	confirm: { label: 'Yes', icon: 'fa-check' },
	cancel:  { label: 'No',  icon: 'fa-xmark' },
	onConfirm: () => console.log('Confirmed!'),
	onCancel:  () => console.log('Cancelled')
  });
  */
  
window.addEventListener("message", function (event) {
  const item = event.data;
  if (item.message === "showKeymap") {
   openMain();
   RTXHousingUI.showKeymap({
      actionLabel: item.actionLabel || "",
      keys: item.keys || []
    });
  }

  if (item.message === "hideKeymap") {
    RTXHousingUI.hideKeymap();
  }

  if (item.message === "showConfirm") {
    openMain();
   RTXHousingUI.showConfirm({
      header: item.header || "Confirm",
      text: item.text || "",
      confirm: item.confirm || { label: "Confirm", icon: "fa-check" },
      cancel: item.cancel || { label: "Cancel", icon: "fa-xmark" },

      onConfirm: () => {
        $.post(`https://${item.resource}/confirmResult`, JSON.stringify({
          result: true,
          uniqueId: item.uniqueId
        }));
      },

      onCancel: () => {
        $.post(`https://${item.resource}/confirmResult`, JSON.stringify({
          result: false,
          uniqueId: item.uniqueId
        }));
      }
    });
  }

  if (item.message === "hideConfirm") {
    RTXHousingUI.hideConfirm();
  }
});  
});