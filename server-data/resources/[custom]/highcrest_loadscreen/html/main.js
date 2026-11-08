'use strict';

const MESSAGE_INTERVAL_MS = 7000;
const TICK_COUNT = 20;
const REDZONE_START = 85;

const MESSAGES = [
    'Your choices shape your future here.',
    'By day, build your career. By night, the city comes alive.',
    'From the red carpet to the underground, there is a place for you.',
    'Reputation is earned slowly and lost overnight.',
    'Every risk has a price. Every reward has a story.',
    'Build something worth protecting.',
];

const tach = document.getElementById('tach');
const fill = document.getElementById('fill');
const tip = document.getElementById('tip');
const percentEl = document.getElementById('percent');
const statusEl = document.getElementById('status');
const messageEl = document.getElementById('message');
const ticksEl = document.getElementById('ticks');

const ticks = [];
for (let i = 0; i <= TICK_COUNT; i++) {
    const value = (i / TICK_COUNT) * 100;
    const tick = document.createElement('i');
    tick.className = 'tick';
    if (i % 5 === 0) tick.classList.add('major');
    if (value >= REDZONE_START) tick.classList.add('red');
    tick.style.left = `${value}%`;
    ticksEl.appendChild(tick);
    ticks.push({ el: tick, value });
}

let progress = 0;
let complete = false;

// The game can report a lower fraction when it moves to a new loading stage,
// so the bar only ever moves forward.
function setProgress(fraction) {
    const next = Math.round(Math.min(Math.max(fraction, 0), 1) * 100);
    if (next <= progress) return;
    progress = next;

    fill.style.width = `${progress}%`;
    tip.style.left = `${progress}%`;
    percentEl.textContent = progress;
    tach.setAttribute('aria-valuenow', progress);
    ticks.forEach(({ el, value }) => el.classList.toggle('lit', value <= progress));

    if (progress === 100 && !complete) {
        complete = true;
        document.body.classList.add('complete');
        statusEl.textContent = 'Entering the city';
    }
}

function setStatus(text) {
    if (!complete && text) statusEl.textContent = text;
}

const handlers = {
    loadProgress: ({ loadFraction }) => setProgress(loadFraction),
    onLogLine: ({ message }) => setStatus(message),
    startInitFunction: () => setStatus('Preparing the city'),
    startDataFileEntries: () => setStatus('Loading city data'),
    performMapLoadFunction: () => setStatus('Building the map'),
};

window.addEventListener('message', ({ data }) => {
    const handler = data && handlers[data.eventName];
    if (handler) handler(data);
});

// Rotating welcome messages. The first one greets the player by name.
const playerName = window.nuiHandoverData && window.nuiHandoverData.playerName;
messageEl.textContent = playerName
    ? `Welcome to Highcrest, ${playerName}. ${MESSAGES[0]}`
    : `Welcome to Highcrest. ${MESSAGES[0]}`;

let messageIndex = 0;
setInterval(() => {
    messageIndex = (messageIndex + 1) % MESSAGES.length;
    messageEl.classList.add('hidden');
    setTimeout(() => {
        messageEl.textContent = MESSAGES[messageIndex];
        messageEl.classList.remove('hidden');
    }, 600);
}, MESSAGE_INTERVAL_MS);

// Browser preview only, for checking the design outside the game:
//   index.html?demo       plays a simulated load
//   index.html?demo=0.73  holds the bar at 73%
const demo = new URLSearchParams(location.search).get('demo');
if (demo !== null) {
    if (demo !== '') {
        setProgress(Number(demo));
        setStatus('Loading city data');
    } else {
        let simulated = 0;
        const timer = setInterval(() => {
            simulated += 0.015;
            setProgress(simulated);
            if (simulated >= 1) clearInterval(timer);
        }, 150);
    }
}

// Music. Starts at a moderate volume and remembers the player's choice for next time.
const DEFAULT_VOLUME = 30;
const music = document.getElementById('music');
const musicBox = document.querySelector('.music');
const musicToggle = document.getElementById('musicToggle');
const musicVolume = document.getElementById('musicVolume');

function loadSetting(key, fallback) {
    try {
        const value = localStorage.getItem(key);
        return value === null ? fallback : value;
    } catch {
        return fallback;
    }
}

function saveSetting(key, value) {
    try { localStorage.setItem(key, String(value)); } catch { /* storage unavailable */ }
}

let volume = Number(loadSetting('highcrest:musicVolume', DEFAULT_VOLUME));
let muted = loadSetting('highcrest:musicMuted', 'false') === 'true';

function applyMusic() {
    music.volume = Math.min(Math.max(volume, 0), 100) / 100;
    music.muted = muted || volume === 0;
    musicVolume.value = muted ? 0 : volume;
    musicBox.classList.toggle('muted', music.muted);
    musicToggle.setAttribute('aria-label', music.muted ? 'Unmute music' : 'Mute music');
}

musicToggle.addEventListener('click', () => {
    muted = !muted;
    if (!muted && volume === 0) volume = DEFAULT_VOLUME;
    saveSetting('highcrest:musicMuted', muted);
    saveSetting('highcrest:musicVolume', volume);
    applyMusic();
    music.play().catch(() => {});
});

musicVolume.addEventListener('input', () => {
    volume = Number(musicVolume.value);
    muted = volume === 0;
    saveSetting('highcrest:musicVolume', volume);
    saveSetting('highcrest:musicMuted', muted);
    applyMusic();
});

applyMusic();
music.play().catch(() => {
    // If the browser blocks autoplay, start on the first click instead.
    document.addEventListener('click', () => music.play().catch(() => {}), { once: true });
});

// Community links. Leave a link empty to hide its button.
const LINKS = {
    discord: 'https://discord.gg/Se7Sx7nnkv',
    store: '',
};

function openLink(url) {
    // FiveM opens links in the player's browser through invokeNative; a normal browser uses window.open.
    if (window.invokeNative) window.invokeNative('openUrl', url);
    else window.open(url, '_blank', 'noopener');
}

[['linkDiscord', LINKS.discord], ['linkStore', LINKS.store]].forEach(([id, url]) => {
    const button = document.getElementById(id);
    button.hidden = !url;
    button.addEventListener('click', (event) => {
        event.preventDefault();
        if (url) openLink(url);
    });
});
