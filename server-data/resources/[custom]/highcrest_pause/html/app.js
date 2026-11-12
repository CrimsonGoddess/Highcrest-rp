'use strict';

const menu = document.getElementById('menu');
const confirmEl = document.getElementById('confirm');
const confirmTitle = document.getElementById('confirmTitle');
const confirmText = document.getElementById('confirmText');
const confirmGo = document.getElementById('confirmGo');
// Store: VIP tiers from config. "Get" copies the tier's Tebex link (done in client.lua).
function renderStore(store, vip) {
    const box = document.getElementById('tiers');
    box.textContent = '';
    const currency = store.currency || '$';
    (store.tiers || []).forEach((t) => {
        const current = vip && vip.tier === t.tier;
        const card = document.createElement('article');
        card.className = `tier${t.featured ? ' featured' : ''}${current ? ' current' : ''}`;
        card.style.setProperty('--tier', t.colour || '#d4af37');
        const ribbon = current ? 'Your tier' : (t.featured ? 'Most popular' : '');
        if (ribbon) { const r = document.createElement('span'); r.className = 'ribbon'; r.textContent = ribbon; card.appendChild(r); }
        const name = document.createElement('h3'); name.textContent = t.name;
        const price = document.createElement('p'); price.className = 'price';
        price.innerHTML = `<strong>${currency}${t.price}</strong><span>/ ${t.period || 'month'}</span>`;
        const list = document.createElement('ul');
        (t.perks || []).forEach((p) => { const li = document.createElement('li'); li.textContent = p; list.appendChild(li); });
        const buy = document.createElement('button');
        buy.className = 'btn tier-buy';
        buy.dataset.action = 'buy';
        buy.dataset.url = t.url || '';
        buy.textContent = current ? 'Renew' : `Get ${t.name}`;
        card.append(name, price, list, buy);
        box.appendChild(card);
    });
    document.getElementById('storeNote').textContent = store.note || '';
    const status = document.getElementById('storeStatus');
    const badge = document.getElementById('vipBadge');
    const nav = document.getElementById('vipNav');
    if (vip) {
        const until = vip.expires ? ` until ${new Date(vip.expires * 1000).toLocaleDateString()}` : '';
        status.textContent = `You are ${vip.label}${until}. Thank you!`;
        badge.textContent = vip.label;
        badge.style.setProperty('--tier', vip.colour || '#d4af37');
        nav.textContent = vip.label;
    } else {
        status.textContent = 'Every import stays available to everyone. VIP adds extras.';
    }
    badge.hidden = !vip;
    nav.hidden = !vip;
}

const CONFIRMS = {
    disconnect: {
        title: 'Leave Highcrest?',
        text: 'Your character is saved where you are standing.',
        button: 'Disconnect',
    },
    quit: {
        title: 'Quit the game?',
        text: 'This closes GTA V completely.',
        button: 'Quit game',
    },
};

const money = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 });

let pendingConfirm = null;
let links = {};

function post(name, data = {}) {
    // GetParentResourceName only exists inside FiveM.
    if (typeof GetParentResourceName !== 'function') return Promise.resolve();
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data),
    }).catch(() => {});
}

function setText(id, text) {
    document.getElementById(id).textContent = text;
}

function open(data) {
    links = data.links || {};
    renderStore(data.store || {}, data.vip || null);

    const rules = document.getElementById('rules');
    rules.textContent = '';
    (data.rules || []).forEach((rule) => {
        const li = document.createElement('li');
        li.textContent = rule;
        rules.appendChild(li);
    });

    confirmEl.hidden = true;
    pendingConfirm = null;
    menu.classList.remove('closing');
    menu.hidden = false;
    // Tell the game how wide the left panel is, so it knows when the cursor is over it.
    const side = document.querySelector('.side');
    post('layout', { panel: side.getBoundingClientRect().right / window.innerWidth });
}

// 'map': GTA's map shows on the right; 'info': the character / city / staff cards.
function setMode(mode) {
    menu.classList.toggle('map-mode', mode === 'map');
    menu.classList.toggle('store-mode', mode === 'store');
    document.getElementById('store').hidden = mode !== 'store';
    document.querySelectorAll('.nav-btn[data-action="map"], .nav-btn[data-action="info"], .nav-btn[data-action="store"]').forEach((btn) => {
        btn.classList.toggle('active', btn.dataset.action === mode);
    });
    // The panel is narrower in map view; tell the game its new width.
    requestAnimationFrame(() => {
        const side = document.querySelector('.side');
        post('layout', { panel: side.getBoundingClientRect().right / window.innerWidth });
    });
}

// While the map shows, leaving the panel hands the mouse back to the map.
document.querySelector('.side').addEventListener('mouseleave', () => {
    if (menu.classList.contains('map-mode') && confirmEl.hidden) post('releaseFocus');
});

function showStaff(staff) {
    const list = document.getElementById('staff');
    list.textContent = '';
    let online = 0;
    let tracked = 0;

    staff.forEach((member) => {
        const li = document.createElement('li');
        li.className = 'staff-member';

        const avatar = document.createElement('span');
        avatar.className = 'staff-avatar';
        avatar.textContent = (member.name || '?').charAt(0).toUpperCase();
        // Discord profile picture, falling back to the initial if it can't load.
        if (typeof member.avatar === 'string' && member.avatar.startsWith('https://cdn.discordapp.com/')) {
            const img = document.createElement('img');
            img.alt = '';
            img.src = member.avatar;
            img.addEventListener('load', () => { avatar.textContent = ''; avatar.appendChild(img); });
        }

        const text = document.createElement('div');
        text.className = 'staff-text';
        const name = document.createElement('p');
        name.className = 'staff-name';
        name.textContent = member.name;
        const role = document.createElement('p');
        role.className = 'staff-role';
        role.textContent = member.role || 'Staff';
        text.append(name, role);
        li.append(avatar, text);

        // Only staff with an identifier in the config get a status dot.
        if (typeof member.online === 'boolean') {
            tracked += 1;
            if (member.online) online += 1;
            const dot = document.createElement('span');
            dot.className = `staff-status${member.online ? ' online' : ''}`;
            dot.title = member.online ? 'In the city' : 'Away';
            li.appendChild(dot);
        }
        list.appendChild(li);
    });

    setText('staffOnline', tracked ? `${online} in the city` : '');
}

function showInfo(info) {
    setText('online', info.online ?? '-');
    setText('maxPlayers', info.maxPlayers ? `/ ${info.maxPlayers}` : '');
    showStaff(info.staff || []);

    const c = info.character;
    if (!c) return;
    setText('charName', c.name.trim() || 'Unknown');
    setText('charJob', c.grade ? `${c.job} · ${c.grade}` : c.job);
    setText('cash', money.format(c.cash || 0));
    setText('bank', money.format(c.bank || 0));
    setText('phone', c.phone || '-');
    setText('citizenid', c.citizenid || '-');
    document.getElementById('duty').hidden = !c.onDuty;
}

function close() {
    if (menu.hidden) return;
    menu.classList.add('closing');
    setTimeout(() => {
        menu.hidden = true;
        menu.classList.remove('closing');
    }, 200);
}

function askConfirm(kind) {
    const c = CONFIRMS[kind];
    if (!c) return;
    pendingConfirm = kind;
    confirmTitle.textContent = c.title;
    confirmText.textContent = c.text;
    confirmGo.textContent = c.button;
    confirmEl.hidden = false;
    confirmGo.focus();
}

function cancelConfirm() {
    pendingConfirm = null;
    confirmEl.hidden = true;
}

window.addEventListener('message', ({ data }) => {
    if (!data) return;
    if (data.action === 'open') open(data);
    else if (data.action === 'info') showInfo(data.info || {});
    else if (data.action === 'close') close();
    else if (data.action === 'mode') setMode(data.mode);
});

document.addEventListener('click', (event) => {
    const button = event.target.closest('[data-action]');
    if (!button) return;
    const action = button.dataset.action;

    if (action === 'confirm') askConfirm(button.dataset.confirm);
    else if (action === 'cancel') cancelConfirm();
    else if (action === 'buy') post('buy', { url: button.dataset.url || '' });
    else if (action === 'link') {
        if (links[button.dataset.link]) post('link', { name: button.dataset.link });
    } else post(action);
});

confirmGo.addEventListener('click', () => {
    if (pendingConfirm) post(pendingConfirm);
    cancelConfirm();
});

document.addEventListener('keydown', (event) => {
    if (menu.hidden) return;
    if (event.key === 'Escape' || event.key === 'p' || event.key === 'P') {
        event.preventDefault();
        if (pendingConfirm) cancelConfirm();
        else post('close');
    }
});

// Browser preview only: index.html?demo shows the menu with sample data.
if (new URLSearchParams(location.search).has('demo')) {
    open({
        links: { discord: 'https://discord.gg/example', store: '' },
        vip: { tier: 'vip', label: 'VIP', colour: '#d4af37', expires: 1795000000 },
        store: { currency: '$', note: 'All imports stay available to everyone for in-game money. VIP never includes in-game money.', tiers: [
            { tier: 'supporter', name: 'Supporter', price: '4.99', period: 'month', colour: '#c0c0c0', perks: ['Supporter role in Discord', 'Supporter badge on your pause menu', 'Keeps Highcrest running'] },
            { tier: 'vip', name: 'VIP', price: '9.99', period: 'month', colour: '#d4af37', featured: true, perks: ['Everything in Supporter', 'Early access to new imports', 'Buy VIP Collection cars', '1 custom licence plate (/vipplate)', 'Free "Bring to me" valet'] },
            { tier: 'elite', name: 'Elite', price: '19.99', period: 'month', colour: '#c8102e', perks: ['Everything in VIP', '3 custom licence plates', 'Free garage transfers', 'Elite role in Discord'] },
        ] },
        rules: [
            'Stay in character. Out-of-character talk goes in /ooc or Discord.',
            'No random deathmatch. Violence needs a roleplay reason.',
            'Value your life. Act like you have one to lose.',
            'No metagaming: use only what your character knows.',
        ],
    });
    showInfo({
        online: 12,
        maxPlayers: 48,
        staff: [
            { name: 'Crimson', role: 'Owner', online: true, avatar: 'https://cdn.discordapp.com/embed/avatars/0.png' },
            { name: 'Slug', role: 'Management', online: false, avatar: 'https://cdn.discordapp.com/embed/avatars/3.png' },
            { name: 'Gina', role: 'Management' },
        ],
        character: { name: 'Alex Mercer', job: 'Gruppe Sechs', grade: 'Guard', onDuty: true, cash: 1250, bank: 48210, phone: '555-0142', citizenid: 'SJX39KSL' },
    });
}
// Browser preview: index.html?demo&map shows the Map tab layout.
if (new URLSearchParams(location.search).has('map')) setMode('map');
else if (new URLSearchParams(location.search).has('store')) setMode('store');
else if (new URLSearchParams(location.search).has('demo')) setMode('info');
