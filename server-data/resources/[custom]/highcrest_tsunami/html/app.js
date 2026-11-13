'use strict';

/* Tsunami emergency ticker. Shown from 'warn' until the countdown ends (or 'stop'). */

const $ = (id) => document.getElementById(id);
const SPEED = 9; // vh per second

let endsAt = 0;
let timer = null;
let frame = null;

function fmt(ms) {
    const s = Math.max(0, Math.ceil(ms / 1000));
    return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
}

function stop() {
    clearInterval(timer);
    cancelAnimationFrame(frame);
    timer = frame = null;
    $('ticker').hidden = true;
}

function startScroll(text) {
    const scroll = $('scroll');
    // Repeat the text so the strip is always longer than the screen.
    scroll.textContent = (text + '   ').repeat(6);
    const vh = window.innerHeight / 100;
    let x = $('scroll').parentElement.clientWidth;
    let last = performance.now();
    const step = (now) => {
        x -= SPEED * vh * ((now - last) / 1000);
        last = now;
        const half = scroll.scrollWidth / 2;
        if (x < -half) x += half;
        scroll.style.transform = `translateX(${x}px)`;
        frame = requestAnimationFrame(step);
    };
    cancelAnimationFrame(frame);
    frame = requestAnimationFrame(step);
}

window.addEventListener('message', ({ data }) => {
    if (!data) return;
    if (data.action === 'stop') return stop();
    if (data.action !== 'warn') return;

    endsAt = Date.now() + data.seconds * 1000;
    $('previewTag').hidden = !data.preview;
    $('countdown').textContent = fmt(endsAt - Date.now());
    $('ticker').hidden = false;
    startScroll(data.text.ticker);

    clearInterval(timer);
    timer = setInterval(() => {
        const left = endsAt - Date.now();
        $('countdown').textContent = fmt(left);
        if (left <= 0 && !data.preview) clearInterval(timer);
    }, 250);
});
