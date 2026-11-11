'use strict';

const menu = document.getElementById('menu');
const confirmEl = document.getElementById('confirm');
const confirmTitle = document.getElementById('confirmTitle');
const confirmText = document.getElementById('confirmText');
const confirmGo = document.getElementById('confirmGo');
const storeButton = document.querySelector('[data-link="store"]');

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
    const storeReady = Boolean(links.store);
    storeButton.classList.toggle('disabled', !storeReady);
    storeButton.querySelector('.soon').hidden = storeReady;

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
    document.querySelector('.nav-btn.primary').focus();
}

function showInfo(info) {
    setText('online', info.online ?? '-');
    setText('maxPlayers', info.maxPlayers ? `/ ${info.maxPlayers}` : '');

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
});

document.addEventListener('click', (event) => {
    const button = event.target.closest('[data-action]');
    if (!button) return;
    const action = button.dataset.action;

    if (action === 'confirm') askConfirm(button.dataset.confirm);
    else if (action === 'cancel') cancelConfirm();
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
        character: { name: 'Alex Mercer', job: 'Gruppe Sechs', grade: 'Guard', onDuty: true, cash: 1250, bank: 48210, phone: '555-0142', citizenid: 'SJX39KSL' },
    });
}
