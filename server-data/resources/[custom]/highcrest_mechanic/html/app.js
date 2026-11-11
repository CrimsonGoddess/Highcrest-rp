'use strict';

const $ = (id) => document.getElementById(id);
const money = (n) => `$${Math.round(Number(n) || 0).toLocaleString('en-US')}`;
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);

function post(name, data = {}) {
    if (typeof GetParentResourceName !== 'function') return Promise.resolve(null);
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data),
    }).then((r) => r.json()).catch(() => null);
}

function el(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
}

/* ---------------- Design bay ---------------- */
const design = { mode: 'design', tabs: [], items: {}, draft: {}, activeTab: null, openItem: null, finishes: [], work: null };
const FINISH_NAMES = ['Gloss', 'Metallic', 'Pearl', 'Matte', 'Metal', 'Chrome'];

const isCustom = (value) => Array.isArray(value) && value.length === 4;
const toHex = (rgb) => `#${rgb.slice(0, 3).map((n) => Number(n).toString(16).padStart(2, '0')).join('')}`;
const fromHex = (hex) => [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16));

function optionFor(item, value) {
    return item.options.find((o) => same(o.value, value));
}

function valueOf(item) {
    return item.key in design.draft ? design.draft[item.key] : item.current;
}

function labelFor(item, value) {
    const option = optionFor(item, value);
    if (option) return option.label;
    if (isCustom(value)) return `Custom ${toHex(value).toUpperCase()}, ${FINISH_NAMES[value[3]] || 'Gloss'}`;
    return 'Stock';
}

function priceOf(item, value) {
    const option = optionFor(item, value);
    if (option) return option.price;
    return isCustom(value) ? (item.customPrice || 0) : 0;
}

function renderTabs() {
    const nav = $('tabs');
    nav.textContent = '';
    nav.hidden = design.mode === 'work';
    if (design.mode === 'work') return;
    design.tabs.forEach((tab) => {
        const btn = el('button', tab.id === design.activeTab ? 'active' : '', tab.label);
        btn.addEventListener('click', () => { design.activeTab = tab.id; design.openItem = null; renderTabs(); renderItems(); });
        nav.appendChild(btn);
    });
}

function optionButton(item, option, selectedValue) {
    const btn = el('button', `option${same(option.value, selectedValue) ? ' selected' : ''}${option.illegal ? ' illegal' : ''}`);
    const name = el('span');
    if (option.swatch) {
        const dot = el('span', `swatch${option.finish === 5 || option.value === 120 ? ' chrome' : ''}`);
        dot.style.background = `rgb(${option.swatch.join(',')})`;
        name.appendChild(dot);
    }
    name.appendChild(document.createTextNode(option.label));
    const original = same(option.value, item.current);
    btn.append(name, el('span', 'price', original ? 'Current' : money(option.price)));
    btn.addEventListener('click', () => choose(item, option.value));
    return btn;
}

// Custom colour wheel: pick any colour and a finish; the car updates as you drag.
function customPicker(item) {
    const value = valueOf(item);
    const current = isCustom(value) ? value : [200, 16, 46, 0];
    const box = el('div', 'custom-paint');
    box.appendChild(el('p', 'group-label', `Custom colour · ${money(item.customPrice)}`));
    const row = el('div', 'custom-row');
    const input = el('input');
    input.type = 'color';
    input.value = toHex(current);
    const hex = el('span', 'hex', input.value.toUpperCase());
    row.append(input, hex);
    // Custom colours use a normal gloss finish; matte and chrome looks are in the groups below.
    const pick = () => {
        const rgb = fromHex(input.value);
        hex.textContent = input.value.toUpperCase();
        choose(item, [rgb[0], rgb[1], rgb[2], 0], true);
    };
    let timer = null;
    input.addEventListener('input', () => { clearTimeout(timer); timer = setTimeout(pick, 90); });
    box.appendChild(row);
    return box;
}

function renderItems() {
    const box = $('items');
    box.textContent = '';
    if (design.mode === 'work') { renderWork(); return; }
    const tab = design.tabs.find((t) => t.id === design.activeTab);
    if (!tab) return;

    tab.items.forEach((ref) => {
        const item = design.items[ref.key];
        const value = valueOf(item);
        const option = optionFor(item, value);
        const wrap = el('div', `item${item.key in design.draft ? ' changed' : ''}`);
        const head = el('button', 'item-head');
        const valueText = el('span', `value${option && option.illegal ? ' illegal-text' : ''}`, labelFor(item, value));
        head.append(el('span', 'label', item.label), valueText);
        head.addEventListener('click', () => {
            design.openItem = design.openItem === item.key ? null : item.key;
            renderItems();
        });
        wrap.appendChild(head);

        if (design.openItem === item.key) {
            const groups = [];
            item.options.forEach((o) => {
                const name = o.group || '';
                let group = groups.find((g) => g.name === name);
                if (!group) { group = { name, options: [] }; groups.push(group); }
                group.options.push(o);
            });
            if (item.kind === 'paint') wrap.appendChild(customPicker(item));
            groups.forEach((group) => {
                if (group.name) wrap.appendChild(el('p', 'group-label', group.name));
                const grid = el('div', 'options');
                group.options.forEach((o) => grid.appendChild(optionButton(item, o, value)));
                wrap.appendChild(grid);
            });
            if (item.options.some((o) => o.illegal)) {
                wrap.appendChild(el('p', 'illegal-note', 'Not street legal: police can pull you over for it.'));
            }
        }
        box.appendChild(wrap);
    });
}

function choose(item, value, keepOpen) {
    if (same(value, item.current)) {
        delete design.draft[item.key];
        post('reset', { key: item.key });
    } else {
        design.draft[item.key] = value;
        post('preview', { key: item.key, value });
    }
    if (item.key === 'wheels') delete design.draft.modFrontWheels;
    if (!keepOpen) renderItems();
    else {
        // Only refresh the header text so the colour picker keeps focus.
        const head = [...document.querySelectorAll('.item-head')].find((h) => h.firstChild.textContent === item.label);
        if (head) head.lastChild.textContent = labelFor(item, valueOf(item));
    }
    renderSummary();
}

function renderSummary() {
    if (design.mode === 'work') { renderWorkSummary(); return; }
    const list = $('changes');
    list.textContent = '';
    let total = 0;
    const keys = Object.keys(design.draft);
    keys.forEach((key) => {
        const item = design.items[key];
        if (!item) return;
        const price = priceOf(item, design.draft[key]);
        total += price;
        const li = el('li');
        li.append(el('span', '', `${item.label}: ${labelFor(item, design.draft[key])}`), el('span', '', money(price)));
        list.appendChild(li);
    });
    $('partsTotal').textContent = money(total);
    $('changeCount').textContent = keys.length ? `${keys.length} change${keys.length === 1 ? '' : 's'}` : 'No changes yet';
    $('submitBtn').disabled = keys.length === 0;
}

function setMode(mode) {
    design.mode = mode;
    const work = mode === 'work';
    $('submitBtn').hidden = work;
    $('finishBtn').hidden = !work;
    $('finishBtn').textContent = 'Finish & charge';
    $('cancelBtn').textContent = work ? 'Leave bay' : 'Cancel';
    document.querySelector('.summary-head span').textContent = work ? 'Work order' : 'Your build';
    document.querySelector('.total span').textContent = work ? 'Total' : 'Parts';
    $('designNote').textContent = work
        ? 'Click a part to fit it. When everything is fitted, finish to charge the customer. Leaving undoes unpaid work.'
        : 'A mechanic adds their labour fee. You approve the full price before any work starts.';
}

function openDesign(data) {
    setMode('design');
    design.tabs = data.tabs || [];
    design.items = {};
    design.tabs.forEach((tab) => tab.items.forEach((item) => { design.items[item.key] = item; }));
    design.draft = {};
    design.activeTab = design.tabs[0] ? design.tabs[0].id : null;
    design.openItem = null;
    $('shopName').textContent = data.shop || '';
    $('carName').textContent = data.vehicle || 'Your car';
    $('carPlate').textContent = data.plate || '';
    $('designMessage').hidden = true;
    renderTabs();
    renderItems();
    renderSummary();
    $('design').hidden = false;
}

function updateItem(item) {
    if (!item || !design.items[item.key]) return;
    Object.assign(design.items[item.key], item);
    renderItems();
    renderSummary();
}

async function submitDesign() {
    const btn = $('submitBtn');
    btn.disabled = true;
    const result = await post('submitDesign');
    if (result && !result.ok) {
        $('designMessage').textContent = result.message || 'Something went wrong.';
        $('designMessage').hidden = false;
        btn.disabled = false;
    }
}

/* ---------------- Work mode (mechanic) ---------------- */
function openWork(data) {
    setMode('work');
    design.work = { order: data.order, fitting: null, message: '' };
    $('shopName').textContent = `${data.shop || ''} · Order #${data.order.id}`;
    $('carName').textContent = data.vehicle || 'Car';
    $('carPlate').textContent = `${data.plate || ''} · ${data.order.customer}`;
    $('designMessage').hidden = true;
    renderTabs();
    renderItems();
    renderSummary();
    $('design').hidden = false;
}

function renderWork() {
    const box = $('items');
    const { order, fitting } = design.work;
    order.lines.forEach((line) => {
        const card = el('button', `work-item${line.fitted ? ' fitted' : ''}${fitting === line.key ? ' fitting' : ''}`);
        const text = el('div', 'work-text');
        text.append(el('span', 'label', line.label), el('span', 'value', line.value || ''));
        const state = el('span', 'work-state', line.fitted ? 'Fitted' : (fitting === line.key ? 'Fitting…' : `${line.seconds}s · Fit`));
        card.append(text, state);
        if (fitting === line.key) {
            const bar = el('div', 'work-bar');
            const fill = el('div', 'work-fill');
            fill.style.animationDuration = `${design.work.seconds}s`;
            bar.appendChild(fill);
            card.appendChild(bar);
        }
        card.disabled = line.fitted || !!fitting;
        card.addEventListener('click', () => fitPart(line));
        box.appendChild(card);
    });
    if (design.work.message) box.appendChild(el('p', 'message', design.work.message));
}

function renderWorkSummary() {
    const { order } = design.work;
    const list = $('changes');
    list.textContent = '';
    const row = (label, value) => { const li = el('li'); li.append(el('span', '', label), el('span', '', value)); list.appendChild(li); };
    const fitted = order.lines.filter((l) => l.fitted).length;
    row('Parts', money(order.parts));
    row('Labour', money(order.labour));
    row('Customer', order.customerOnline ? 'In the city' : 'Not in the city');
    $('partsTotal').textContent = money(order.parts + order.labour);
    $('changeCount').textContent = `${fitted} of ${order.lines.length} fitted`;
    $('finishBtn').disabled = fitted < order.lines.length || !!design.work.fitting;
}

async function fitPart(line) {
    if (line.fitted || design.work.fitting) return;
    design.work.message = '';
    const result = await post('fitPart', { key: line.key });
    if (!result || !result.ok) {
        design.work.message = (result && result.message) || 'Could not start on that part.';
        renderItems();
        return;
    }
    design.work.fitting = line.key;
    design.work.seconds = result.seconds;
    renderItems();
    renderSummary();
}

function partDone(data) {
    if (!design.work) return;
    const line = design.work.order.lines.find((l) => l.key === data.key);
    if (line && data.ok) line.fitted = true;
    design.work.fitting = null;
    design.work.message = data.ok ? '' : (data.message || 'That part did not go on.');
    renderItems();
    renderSummary();
}

async function finishWork() {
    const btn = $('finishBtn');
    btn.disabled = true;
    const result = await post('finishWork');
    if (result && result.ok) {
        btn.textContent = 'Done!';
        return;
    }
    $('designMessage').textContent = (result && result.message) || 'Something went wrong.';
    $('designMessage').hidden = false;
    btn.disabled = false;
}

// Drag to orbit the camera, scroll to zoom.
let dragging = null;
$('dragArea').addEventListener('mousedown', (e) => { dragging = { x: e.clientX, y: e.clientY }; });
window.addEventListener('mouseup', () => { dragging = null; });
window.addEventListener('mousemove', (e) => {
    if (!dragging) return;
    const dx = e.clientX - dragging.x;
    const dy = e.clientY - dragging.y;
    dragging = { x: e.clientX, y: e.clientY };
    if (dx || dy) post('camera', { dx, dy });
});
$('dragArea').addEventListener('wheel', (e) => post('camera', { zoom: e.deltaY }));

/* ---------------- Tablet ---------------- */
const tablet = { data: null, view: 'open', selected: null, confirmCancel: null, feedback: '' };

const STATUS_TEXT = {
    new: 'New', quoted: 'Quoted', approved: 'Approved', in_progress: 'In progress',
    declined: 'Declined', unpaid: 'Unpaid', done: 'Done', cancelled: 'Cancelled',
};

function orders() {
    if (!tablet.data) return [];
    return tablet.view === 'open' ? tablet.data.open : tablet.data.recent;
}

function renderOrderList() {
    const list = $('orderList');
    list.textContent = '';
    const items = orders();
    if (!items.length) {
        list.appendChild(el('li', 'empty', tablet.view === 'open' ? 'No open orders.' : 'Nothing finished yet.'));
        return;
    }
    items.forEach((order) => {
        const li = el('li', order.id === tablet.selected ? 'active' : '');
        const top = el('div', 'order-top');
        top.append(el('strong', '', `#${order.id} · ${order.plate}`), el('span', `status ${order.status}`, STATUS_TEXT[order.status] || order.status));
        li.append(top, el('p', 'order-sub', `${order.customer} · ${order.model || 'Car'} · parts ${money(order.parts)}`));
        li.addEventListener('click', () => { tablet.selected = order.id; tablet.confirmCancel = null; tablet.feedback = ''; renderTablet(); });
        list.appendChild(li);
    });
}

function renderDetail() {
    const box = $('orderDetail');
    box.textContent = '';
    const order = orders().find((o) => o.id === tablet.selected);
    if (!order) { box.appendChild(el('p', 'empty', 'Select an order.')); return; }

    const head = el('div', 'detail-head');
    const title = el('div');
    title.append(el('p', 'eyebrow', order.shopLabel || ''), el('h2', '', `Order #${order.id}`));
    head.append(title, el('span', `status ${order.status}`, STATUS_TEXT[order.status] || order.status));
    box.appendChild(head);

    const facts = el('dl', 'facts');
    const fact = (label, value, cls) => {
        const d = el('div');
        d.append(el('dt', '', label), el('dd', cls || '', value));
        facts.appendChild(d);
    };
    fact('Customer', order.customer);
    fact('Car', `${order.model || 'Car'} · ${order.plate}`);
    fact('In the city', order.customerOnline ? 'Yes' : 'No', order.customerOnline ? 'online' : 'offline');
    if (order.mechanic_name) fact('Mechanic', order.mechanic_name);
    box.appendChild(facts);

    const table = el('table', 'lines');
    const thead = el('tr');
    ['Part', 'Choice', 'Price'].forEach((t) => thead.appendChild(el('th', '', t)));
    table.appendChild(thead);
    (order.lines || []).forEach((line) => {
        const tr = el('tr');
        tr.append(el('td', '', line.label), el('td', '', line.value || ''), el('td', '', money(line.price)));
        table.appendChild(tr);
    });
    box.appendChild(table);

    const row = (label, value, big) => {
        const r = el('div', `money-row${big ? ' big' : ''}`);
        r.append(el('span', '', label), el('strong', '', value));
        box.appendChild(r);
    };
    row('Parts', money(order.parts));

    const canQuote = ['new', 'quoted', 'declined'].includes(order.status);
    const canWork = ['approved', 'in_progress', 'unpaid'].includes(order.status);
    const open = !['done', 'cancelled'].includes(order.status);

    if (canQuote) {
        const labour = el('div', 'labour');
        const input = el('input');
        input.type = 'number';
        input.min = '0';
        input.max = String(tablet.data.maxLabour);
        input.step = '50';
        input.placeholder = 'Labour fee';
        input.value = order.labour ? String(order.labour) : (order.suggestedLabour ? String(order.suggestedLabour) : '');
        const cutNote = el('span', 'muted', `Your cut: ${Math.round(tablet.data.cut * 100)}%`);
        labour.append(el('span', '', 'Labour $'), input, cutNote);
        box.appendChild(labour);
        row('Total', money(order.parts + (Number(input.value) || 0)), true);
        input.addEventListener('input', () => {
            const total = box.querySelector('.money-row.big strong');
            if (total) total.textContent = money(order.parts + (Number(input.value) || 0));
        });

        const actions = el('div', 'detail-actions');
        const send = el('button', 'btn primary', order.status === 'new' ? 'Send quote' : 'Send quote again');
        send.addEventListener('click', async () => {
            send.disabled = true;
            const result = await post('quote', { id: order.id, labour: Number(input.value) || 0 });
            tablet.feedback = result ? result.message || '' : '';
            if (result && result.data) tablet.data = result.data;
            renderTablet();
        });
        actions.appendChild(send);
        actions.appendChild(cancelButton(order));
        box.appendChild(actions);
    } else {
        row('Labour', money(order.labour));
        row('Total', money(order.parts + order.labour), true);
        const actions = el('div', 'detail-actions');
        if (open) actions.appendChild(cancelButton(order));
        if (actions.children.length) box.appendChild(actions);
        if (canWork) {
            box.appendChild(el('p', 'feedback ready', order.status === 'unpaid'
                ? 'The customer could not pay last time. Drive the car back into the bay and press E to try again.'
                : `Ready to work: drive ${order.plate} into the bay and press E.`));
        }
    }

    if (order.status === 'quoted') box.appendChild(el('p', 'feedback', 'Waiting for the customer to approve.'));
    if (tablet.feedback) box.appendChild(el('p', 'feedback', tablet.feedback));
}

function cancelButton(order) {
    const confirming = tablet.confirmCancel === order.id;
    const btn = el('button', 'btn danger', confirming ? 'Click again to cancel' : 'Cancel order');
    btn.addEventListener('click', async () => {
        if (!confirming) { tablet.confirmCancel = order.id; renderTablet(); return; }
        const result = await post('cancelOrder', { id: order.id });
        tablet.confirmCancel = null;
        if (result && result.data) tablet.data = result.data;
        renderTablet();
    });
    return btn;
}

/* Boss: price list editor */
function renderPrices() {
    const box = $('pricePanel');
    box.textContent = '';
    const sheet = tablet.prices;
    if (!sheet) { box.appendChild(el('p', 'empty', 'Loading prices…')); return; }
    const draft = tablet.priceDraft;
    const std = sheet.defaults;
    const lo = sheet.limits.min, hi = sheet.limits.max;

    box.append(el('p', 'eyebrow', sheet.shopLabel), el('h2', '', 'Shop prices'));
    box.appendChild(el('p', 'muted', `Prices can go from ${Math.round(lo * 100)}% to ${Math.round(hi * 100)}% of standard. Self-service LS Customs charges 150% of standard, so stay under that to win customers.`));

    const field = (label, value, standard, onInput, note) => {
        const wrap = el('label', `price-field${value !== standard ? ' changed' : ''}`);
        const input = el('input', 'price-input');
        input.type = 'number';
        input.min = '0';
        input.step = '50';
        input.value = String(value);
        input.addEventListener('input', () => {
            onInput(Number(input.value));
            wrap.classList.toggle('changed', Number(input.value) !== standard);
        });
        wrap.append(el('span', '', label), input, el('small', '', note || `Standard ${money(standard)}`));
        return wrap;
    };

    box.appendChild(el('h3', '', 'Labour'));
    const labourGrid = el('div', 'price-grid');
    labourGrid.appendChild(field('Suggested labour per part', draft.labourPerPart, std.labourPerPart,
        (v) => { draft.labourPerPart = v; }, `Fills in the quote box. Max ${money(sheet.maxLabour)}`));
    box.appendChild(labourGrid);

    box.appendChild(el('h3', '', 'Parts'));
    const partGrid = el('div', 'price-grid');
    [['cosmetic', 'Body part, wheels, lights, extras'], ['color', 'Paint colour'], ['customPaint', 'Custom and Wild paint'],
        ['illegalTint', 'Pure Black tint (not street legal)'], ['turbo', 'Turbo']].forEach(([key, label]) => {
        if (draft[key] === undefined) draft[key] = std[key];
        partGrid.appendChild(field(label, draft[key], std[key], (v) => { draft[key] = v; }));
    });
    box.appendChild(partGrid);

    box.appendChild(el('h3', '', 'Upgrades'));
    const table = el('table', 'price-table');
    const most = Math.max(...sheet.levelOrder.map((k) => std.levels[k].length - 1));
    const head = el('tr');
    head.appendChild(el('th', '', 'Part'));
    for (let i = 1; i <= most; i++) head.appendChild(el('th', '', `Level ${i}`));
    table.appendChild(head);
    sheet.levelOrder.forEach((key) => {
        const tr = el('tr');
        tr.appendChild(el('td', '', sheet.levelLabels[key] || key));
        for (let i = 1; i <= most; i++) {
            const td = el('td');
            if (i < std.levels[key].length) {
                const input = el('input');
                input.type = 'number';
                input.min = '0';
                input.step = '50';
                input.value = String(draft.levels[key][i]);
                input.title = `Standard ${money(std.levels[key][i])}`;
                input.classList.toggle('changed', draft.levels[key][i] !== std.levels[key][i]);
                input.addEventListener('input', () => {
                    draft.levels[key][i] = Number(input.value);
                    input.classList.toggle('changed', Number(input.value) !== std.levels[key][i]);
                });
                td.appendChild(input);
            }
            tr.appendChild(td);
        }
        table.appendChild(tr);
    });
    box.appendChild(table);

    const actions = el('div', 'detail-actions');
    const save = el('button', 'btn primary', 'Save prices');
    save.addEventListener('click', () => savePrices(draft));
    const reset = el('button', 'btn ghost', tablet.confirmReset ? 'Click again to reset' : 'Reset to standard');
    reset.addEventListener('click', () => {
        if (!tablet.confirmReset) { tablet.confirmReset = true; renderPrices(); return; }
        tablet.confirmReset = false;
        savePrices(null);
    });
    actions.append(save, reset);
    box.appendChild(actions);
    if (tablet.feedback) box.appendChild(el('p', 'feedback', tablet.feedback));
}

function setPriceSheet(sheet) {
    tablet.prices = sheet;
    tablet.priceDraft = sheet ? JSON.parse(JSON.stringify(sheet.prices)) : null;
}

async function savePrices(prices) {
    const result = await post('savePrices', { shop: tablet.prices.shop, prices });
    tablet.feedback = result ? result.message || '' : '';
    if (result && result.ok && result.sheet) setPriceSheet(result.sheet);
    renderPrices();
}

function renderTablet() {
    const data = tablet.data || {};
    if (!data.isBoss && tablet.view === 'prices') tablet.view = 'open';
    $('pricesTab').hidden = !data.isBoss;
    const duty = $('dutyBtn');
    duty.textContent = data.offDuty ? 'Clock in' : 'Clock out';
    duty.classList.toggle('off', !!data.offDuty);
    document.querySelectorAll('.tab-btn').forEach((b) => b.classList.toggle('active', b.dataset.view === tablet.view));

    const prices = tablet.view === 'prices';
    const offDuty = !prices && data.offDuty;
    $('pricePanel').hidden = !prices;
    $('offDuty').hidden = !offDuty;
    $('orderList').hidden = prices || offDuty;
    $('orderDetail').hidden = prices || offDuty;
    if (prices) renderPrices();
    else if (!offDuty) { renderOrderList(); renderDetail(); }
}

async function toggleDuty() {
    const data = await post('setDuty', { onDuty: !!(tablet.data && tablet.data.offDuty) });
    if (data) {
        tablet.data = data;
        if (tablet.view !== 'prices') {
            const list = orders();
            tablet.selected = list[0] ? list[0].id : null;
        }
        renderTablet();
    }
}

function openTablet(data) {
    tablet.data = data;
    tablet.prices = null;
    tablet.view = 'open';
    tablet.selected = data.open && data.open[0] ? data.open[0].id : null;
    tablet.feedback = '';
    $('tablet').hidden = false;
    renderTablet();
}

document.querySelectorAll('.tab-btn').forEach((btn) => btn.addEventListener('click', async () => {
    tablet.view = btn.dataset.view;
    tablet.feedback = '';
    tablet.confirmReset = false;
    if (tablet.view === 'prices') {
        renderTablet();
        const sheet = await post('getPrices', {});
        if (sheet) setPriceSheet(sheet);
        renderTablet();
        return;
    }
    const list = orders();
    tablet.selected = list[0] ? list[0].id : null;
    tablet.feedback = '';
    renderTablet();
}));

/* ---------------- Shared ---------------- */
document.addEventListener('click', async (e) => {
    const btn = e.target.closest('[data-action]');
    if (!btn) return;
    const action = btn.dataset.action;
    if (action === 'submitDesign') submitDesign();
    else if (action === 'cancelDesign') post('cancelDesign');
    else if (action === 'closeTablet') post('closeTablet');
    else if (action === 'toggleDuty') toggleDuty();
    else if (action === 'finishWork') finishWork();
    else if (action === 'refresh') {
        const data = await post('refresh');
        if (data) { tablet.data = data; renderTablet(); }
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key !== 'Escape') return;
    if (!$('design').hidden) post('cancelDesign');
    else if (!$('tablet').hidden) post('closeTablet');
});

window.addEventListener('message', ({ data }) => {
    if (!data) return;
    if (data.action === 'openDesign') openDesign(data);
    else if (data.action === 'closeDesign') $('design').hidden = true;
    else if (data.action === 'updateItem') updateItem(data.item);
    else if (data.action === 'openWork') openWork(data);
    else if (data.action === 'partDone') partDone(data);
    else if (data.action === 'openTablet') openTablet(data.data);
    else if (data.action === 'closeTablet') $('tablet').hidden = true;
});

/* Browser preview: index.html?design or index.html?tablet */
const params = new URLSearchParams(location.search);
if (params.has('design')) {
    openDesign({
        shop: 'Highcrest Motorworks', vehicle: 'Sultan RS', plate: 'HC 1234',
        tabs: [
            { id: 'performance', label: 'Performance', items: [
                { key: 'modEngine', label: 'Engine', kind: 'level', current: -1, options: [
                    { value: -1, label: 'Stock', price: 0 }, { value: 0, label: 'Level 1', price: 10000 },
                    { value: 1, label: 'Level 2', price: 20000 }, { value: 2, label: 'Level 3', price: 30000 }] },
                { key: 'modTurbo', label: 'Turbo', kind: 'toggle', current: false, options: [
                    { value: false, label: 'None', price: 0 }, { value: true, label: 'Fitted', price: 10000 }] },
            ] },
            { id: 'paint', label: 'Paint', items: [
                { key: 'color1', label: 'Primary colour', kind: 'paint', current: 0, customPrice: 2500, options: [
                    { value: 0, label: 'Black', price: 1000, group: 'Classic', swatch: [13, 17, 22] },
                    { value: 28, label: 'Torino Red', price: 1000, group: 'Classic', swatch: [218, 25, 24] },
                    { value: 70, label: 'Bright Blue', price: 1000, group: 'Classic', swatch: [11, 156, 241] },
                    { value: 12, label: 'Matte Black', price: 1000, group: 'Matte', swatch: [19, 24, 31] },
                    { value: 148, label: 'Matte Purple', price: 1000, group: 'Matte', swatch: [107, 31, 123] },
                    { value: 120, label: 'Chrome', price: 1000, group: 'Metals & Chrome', swatch: [201, 209, 217] },
                    { value: [255, 0, 170, 2], label: 'Hyper Magenta', price: 2500, group: 'Wild', swatch: [255, 0, 170] },
                    { value: [180, 0, 20, 5], label: 'Blood Chrome', price: 2500, group: 'Wild', swatch: [180, 0, 20], finish: 5 }] },
            ] },
            { id: 'lights', label: 'Lights & Glass', items: [
                { key: 'windowTint', label: 'Window tint', kind: 'list', current: 0, options: [
                    { value: 0, label: 'None', price: 500 }, { value: 2, label: 'Dark Smoke', price: 500 },
                    { value: 1, label: 'Pure Black (not street legal)', price: 5000, illegal: true }] },
                { key: 'neonColor', label: 'Underglow colour', kind: 'neoncolor', current: [255, 255, 255], options: [
                    { value: [255, 255, 255], label: 'White', price: 500, swatch: [255, 255, 255] },
                    { value: [200, 16, 46], label: 'Crimson', price: 500, swatch: [200, 16, 46] }] },
            ] },
        ],
    });
    design.draft = { modEngine: 2, color1: [255, 0, 170, 2], windowTint: 1 };
    design.activeTab = params.get('design') || 'paint';
    design.openItem = design.activeTab === 'lights' ? 'windowTint' : 'color1';
    renderTabs();
    renderItems();
    renderSummary();
}
if (params.has('work')) {
    openWork({
        shop: 'Highcrest Motorworks', vehicle: 'Sultan RS', plate: 'HC 1234',
        order: { id: 12, customer: 'Alex Mercer', parts: 33500, labour: 2000, customerOnline: true, lines: [
            { key: 'modEngine', label: 'Engine', value: 'Level 3', seconds: 8, fitted: true },
            { key: 'color1', label: 'Primary colour', value: 'Hyper Magenta', seconds: 5 },
            { key: 'windowTint', label: 'Window tint', value: 'Pure Black (not street legal)', seconds: 5 },
        ] },
    });
    design.work.fitting = 'color1';
    design.work.seconds = 5;
    renderItems();
    renderSummary();
}
if (params.has('tablet')) {
    openTablet({
        maxLabour: 25000, cut: 0.4,
        open: [
            { id: 12, plate: 'HC 1234', customer: 'Alex Mercer', model: 'SULTAN', status: 'new', parts: 31000, labour: 0, shopLabel: 'Highcrest Motorworks', customerOnline: true,
              lines: [{ label: 'Engine', value: 'Level 3', price: 30000 }, { label: 'Primary colour', value: 'Torino Red', price: 1000 }] },
            { id: 11, plate: 'GINA 22', customer: 'Gina Rossi', model: 'ELEGY', status: 'approved', parts: 12500, labour: 3000, mechanic_name: 'Crimson Johnson', shopLabel: 'Highcrest Motorworks', customerOnline: false, lines: [] },
        ],
        recent: [],
    });
}
if (params.has('prices')) {
    const lv = (a) => a.slice();
    const defaults = { cosmetic: 500, color: 1000, turbo: 10000, labourPerPart: 500, levels: {
        modEngine: [0, 10000, 20000, 30000, 40000], modBrakes: [0, 2500, 5000, 7500], modTransmission: [0, 5000, 10000, 15000, 20000],
        modSuspension: [0, 3000, 6000, 9000, 12000, 15000], modArmor: [0, 2500, 5000, 7500, 10000, 12500] } };
    const prices = JSON.parse(JSON.stringify(defaults));
    prices.levels.modEngine = lv([0, 9000, 18000, 30000, 40000]);
    openTablet({ isBoss: true, open: [], recent: [], maxLabour: 25000, cut: 0.4 });
    tablet.view = 'prices';
    setPriceSheet({ shop: 'vinewood', shopLabel: 'Highcrest Motorworks', prices, defaults, limits: { min: 0.5, max: 3 }, maxLabour: 25000,
        levelOrder: ['modEngine', 'modBrakes', 'modTransmission', 'modSuspension', 'modArmor'],
        levelLabels: { modEngine: 'Engine', modBrakes: 'Brakes', modTransmission: 'Transmission', modSuspension: 'Suspension', modArmor: 'Armour' } });
    renderTablet();
}
if (params.has('offduty')) openTablet({ offDuty: true, isBoss: true, open: [], recent: [], maxLabour: 25000, cut: 0.4 });
