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

// Gameplay tips, shown between the welcome messages with a red "Tip" label.
const TIPS = [
    'Type /hud to choose what your HUD shows, and /hudborder to line up the map frame.',
    'Type /postal and a number to set a GPS route to any postal code.',
    'Your phone can send a valet to bring a stored car to you.',
    'Browse, buy and rent homes in the Housing app on your phone.',
    'Gruppe Sechs is hiring. Visit their HQ in Pillbox Hill.',
    'Press Esc for the Highcrest menu: map, settings, your character and server info.',
];

// Messages and tips alternate: message, tip, message, tip...
const ROTATION = [];
for (let i = 0; i < Math.max(MESSAGES.length, TIPS.length); i++) {
    if (MESSAGES[i]) ROTATION.push({ text: MESSAGES[i] });
    if (TIPS[i]) ROTATION.push({ text: TIPS[i], tip: true });
}

function showMessage({ text, tip }) {
    messageEl.textContent = '';
    if (tip) {
        const label = document.createElement('span');
        label.className = 'tip-label';
        label.textContent = 'Tip';
        messageEl.appendChild(label);
    }
    messageEl.appendChild(document.createTextNode(text));
}

// The first message greets the player by name.
const playerName = window.nuiHandoverData && window.nuiHandoverData.playerName;
showMessage({
    text: playerName
        ? `Welcome to Highcrest, ${playerName}. ${MESSAGES[0]}`
        : `Welcome to Highcrest. ${MESSAGES[0]}`,
});

let messageIndex = 0;
setInterval(() => {
    messageIndex = (messageIndex + 1) % ROTATION.length;
    messageEl.classList.add('hidden');
    setTimeout(() => {
        showMessage(ROTATION[messageIndex]);
        messageEl.classList.remove('hidden');
    }, 600);
}, MESSAGE_INTERVAL_MS);

// Embers: small crimson and gold sparks drifting up the screen.
(function embers() {
    const canvas = document.getElementById('embers');
    if (!canvas || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    const ctx = canvas.getContext('2d');
    const COUNT = 70;
    const COLORS = ['200, 16, 46', '255, 60, 80', '212, 175, 55', '255, 214, 120'];
    let width = 0;
    let height = 0;
    const sparks = [];

    function resize() {
        width = canvas.width = window.innerWidth;
        height = canvas.height = window.innerHeight;
    }

    function spawn(spark, anywhere) {
        spark.x = Math.random() * width;
        spark.y = anywhere ? Math.random() * height : height + 10;
        spark.r = 0.6 + Math.random() * 2.2;
        spark.vy = 0.25 + Math.random() * 0.9;
        spark.sway = 0.4 + Math.random() * 1.2;
        spark.phase = Math.random() * Math.PI * 2;
        spark.life = 0.35 + Math.random() * 0.65;
        spark.color = COLORS[Math.floor(Math.random() * COLORS.length)];
        return spark;
    }

    resize();
    window.addEventListener('resize', resize);
    for (let i = 0; i < COUNT; i++) sparks.push(spawn({}, true));

    let last = performance.now();
    function frame(now) {
        const dt = Math.min((now - last) / 16.7, 3);
        last = now;
        ctx.clearRect(0, 0, width, height);
        ctx.globalCompositeOperation = 'lighter';
        for (const s of sparks) {
            s.y -= s.vy * dt;
            s.phase += 0.012 * dt;
            const x = s.x + Math.sin(s.phase) * s.sway * 12;
            // Sparks fade out as they rise towards the top of the screen.
            const alpha = Math.max(0, Math.min(1, s.y / height)) * s.life * (0.75 + Math.sin(s.phase * 3) * 0.25);
            if (s.y < -10 || alpha <= 0.01) { spawn(s, false); continue; }
            const glow = ctx.createRadialGradient(x, s.y, 0, x, s.y, s.r * 4);
            glow.addColorStop(0, `rgba(${s.color}, ${alpha})`);
            glow.addColorStop(1, `rgba(${s.color}, 0)`);
            ctx.fillStyle = glow;
            ctx.beginPath();
            ctx.arc(x, s.y, s.r * 4, 0, Math.PI * 2);
            ctx.fill();
        }
        requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
})();

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
