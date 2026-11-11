'use strict';

const broadcast = document.getElementById('broadcast');
const mini = document.getElementById('mini');
const bigCountdown = document.getElementById('bigCountdown');
const miniCountdown = document.getElementById('miniCountdown');

let endsAt = 0;
let timer = null;
let toneStop = null;

function format(seconds) {
    const s = Math.max(0, Math.ceil(seconds));
    return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
}

// The emergency alert attention tone (two tones at 853 Hz and 960 Hz), made in the browser.
function playTone(seconds) {
    try {
        const ctx = new (window.AudioContext || window.webkitAudioContext)();
        const gain = ctx.createGain();
        gain.gain.value = 0;
        gain.connect(ctx.destination);
        [853, 960].forEach((freq) => {
            const osc = ctx.createOscillator();
            osc.type = 'sine';
            osc.frequency.value = freq;
            osc.connect(gain);
            osc.start();
            osc.stop(ctx.currentTime + seconds);
        });
        // Three bursts with short gaps, kept at a moderate volume.
        const now = ctx.currentTime;
        const burst = seconds / 3;
        for (let i = 0; i < 3; i++) {
            const start = now + i * burst;
            gain.gain.setValueAtTime(0.0, start);
            gain.gain.linearRampToValueAtTime(0.12, start + 0.05);
            gain.gain.setValueAtTime(0.12, start + burst - 0.45);
            gain.gain.linearRampToValueAtTime(0.0, start + burst - 0.35);
        }
        const close = setTimeout(() => ctx.close(), seconds * 1000 + 200);
        return () => { clearTimeout(close); ctx.close(); };
    } catch {
        return null;
    }
}

function clearAll() {
    clearInterval(timer);
    timer = null;
    if (toneStop) toneStop();
    toneStop = null;
    broadcast.hidden = true;
    broadcast.classList.remove('leaving');
    mini.hidden = true;
    mini.classList.remove('urgent');
}

function tick() {
    const left = (endsAt - Date.now()) / 1000;
    bigCountdown.textContent = format(left);
    miniCountdown.textContent = format(left);
    mini.classList.toggle('urgent', left <= 30);
    if (left <= 0) clearInterval(timer);
}

function warn({ seconds, broadcastSeconds, text, preview }) {
    clearAll();
    endsAt = Date.now() + seconds * 1000;

    document.getElementById('headline').textContent = text.headline;
    document.getElementById('bodyText').textContent = text.body;
    document.getElementById('ticker').textContent = text.ticker.repeat(3);
    document.getElementById('previewTag').hidden = !preview;

    broadcast.hidden = false;
    toneStop = playTone(8);
    tick();
    timer = setInterval(tick, 250);

    setTimeout(() => {
        broadcast.classList.add('leaving');
        setTimeout(() => {
            broadcast.hidden = true;
            broadcast.classList.remove('leaving');
            // A preview ends with the broadcast; the real thing keeps a countdown until the restart.
            if (preview) clearAll();
            else mini.hidden = false;
        }, 450);
    }, broadcastSeconds * 1000);
}

window.addEventListener('message', ({ data }) => {
    if (!data) return;
    if (data.action === 'warn') warn(data);
    else if (data.action === 'clear') clearAll();
});

// Browser preview only: index.html?demo
if (new URLSearchParams(location.search).has('demo')) {
    warn({
        seconds: 120,
        broadcastSeconds: 600,
        preview: false,
        text: {
            headline: 'Tsunami Warning',
            body: 'A tsunami is approaching Los Santos. Move to high ground and get to safety now. The city will be evacuated in two minutes.',
            ticker: 'EMERGENCY ALERT SYSTEM · NATIONAL WEATHER SERVICE · TSUNAMI WARNING IN EFFECT · ',
        },
    });
}
