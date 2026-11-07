'use strict';

const $ = (id) => document.getElementById(id);
const PREVIEW = new URLSearchParams(location.search).get('preview');
const PHOTO_TIMEOUT_MS = 20000;

let phone = null;
let openPhotoId = null;
const photoCache = new Map();
const photoQueue = [];
const photoWaiters = new Map();
let photoInFlight = null;
let photoTimer = null;

function post(name, body = {}) {
    if (PREVIEW !== null) return Promise.resolve(false);
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
    }).then((response) => response.json());
}

/* Navigation */

const VIEWS = [
    'home', 'gallery', 'viewer', 'settings', 'dialer', 'call', 'contacts', 'contact', 'messages', 'conversation',
    'cameraView', 'picker', 'pulse', 'pulseProfile', 'pulseEdit', 'pulseThread', 'market', 'marketForm', 'spark', 'sparkForm', 'darkweb',
];

// Apps register themselves here so each one can live in its own file.
const openers = {};
const backTargets = { viewer: () => showGallery() };
const onViewChange = [];

function show(view) {
    VIEWS.forEach((name) => { $(name).hidden = name !== view; });
    onViewChange.forEach((callback) => callback());
}

function currentView() {
    return VIEWS.find((name) => !$(name).hidden);
}

function goBack() {
    const view = currentView();
    if (view === 'home' || view === 'call') closePhone();
    else if (backTargets[view]) backTargets[view]();
    else show('home');
}

function closePhone() {
    $('phone').hidden = true;
    post('close');
}

/* Photos are fetched one at a time and kept for this session. */

function requestPhoto(id) {
    if (photoCache.has(id)) return Promise.resolve(photoCache.get(id));
    return new Promise((resolve) => {
        if (!photoWaiters.has(id)) {
            photoWaiters.set(id, []);
            photoQueue.push(id);
        }
        photoWaiters.get(id).push(resolve);
        pumpPhotos();
    });
}

function pumpPhotos() {
    if (photoInFlight !== null || photoQueue.length === 0) return;
    photoInFlight = photoQueue.shift();
    post('getPhoto', { id: photoInFlight });
    photoTimer = setTimeout(() => finishPhoto(photoInFlight, null), PHOTO_TIMEOUT_MS);
}

// Photos are captured full screen, then cropped here to what the phone screen showed.
function cropPhoto(src, crop) {
    if (!src || !crop) return Promise.resolve(src);
    const area = typeof crop === 'string' ? JSON.parse(crop) : crop;
    return new Promise((resolve) => {
        const image = new Image();
        image.onerror = () => resolve(src);
        image.onload = () => {
            const canvas = document.createElement('canvas');
            canvas.width = Math.round(image.naturalWidth * area.w);
            canvas.height = Math.round(image.naturalHeight * area.h);
            canvas.getContext('2d').drawImage(
                image,
                image.naturalWidth * area.x, image.naturalHeight * area.y, canvas.width, canvas.height,
                0, 0, canvas.width, canvas.height,
            );
            resolve(canvas.toDataURL('image/webp', 0.92));
        };
        image.src = src;
    });
}

function finishPhoto(id, src) {
    clearTimeout(photoTimer);
    if (src) photoCache.set(id, src);
    (photoWaiters.get(id) || []).forEach((resolve) => resolve(src));
    photoWaiters.delete(id);
    if (photoInFlight === id) photoInFlight = null;
    pumpPhotos();
}

/* Appearance */

// Icons and button text switch to dark on a light accent so they stay readable.
function contrastColor(hex) {
    const channel = (start) => parseInt(hex.slice(start, start + 2), 16);
    const brightness = (channel(1) * 299 + channel(3) * 587 + channel(5) * 114) / 1000;
    return brightness > 150 ? '#0b0b0d' : '#f5f5f5';
}

function applyAppearance() {
    const { caseColor, accentColor, wallpaper } = phone.settings;
    const root = document.documentElement.style;
    root.setProperty('--case', caseColor);
    root.setProperty('--accent', accentColor);
    root.setProperty('--on-accent', contrastColor(accentColor));

    const [kind, value] = wallpaper.split(':');
    if (kind === 'photo') {
        requestPhoto(Number(value)).then((src) => {
            if (src && phone.settings.wallpaper === wallpaper) {
                root.setProperty('--wallpaper', `url("${src}")`);
            }
        });
    } else {
        const preset = phone.wallpapers.find((item) => item.id === value);
        root.setProperty('--wallpaper', preset ? preset.css : '#0b0b0d');
    }
}

async function saveSettings(changes) {
    const previous = phone.settings;
    phone.settings = { ...previous, ...changes };
    applyAppearance();
    renderSettings();

    const saved = await post('saveSettings', phone.settings);
    if (saved) {
        phone.settings = saved;
    } else if (PREVIEW === null) {
        phone.settings = previous;
    }
    applyAppearance();
    renderSettings();
}

/* Settings */

function renderSwatches(container, key) {
    container.replaceChildren(...phone.swatches.map((color) => {
        const swatch = document.createElement('button');
        swatch.className = 'swatch';
        swatch.style.background = color;
        swatch.setAttribute('aria-label', color);
        swatch.classList.toggle('selected', phone.settings[key].toLowerCase() === color.toLowerCase());
        swatch.addEventListener('click', () => saveSettings({ [key]: color }));
        return swatch;
    }));
}

function renderSettings() {
    $('phoneNumber').textContent = phone.phoneNumber || '';
    renderSwatches($('caseSwatches'), 'caseColor');
    renderSwatches($('accentSwatches'), 'accentColor');
    $('caseCustom').value = phone.settings.caseColor;
    $('accentCustom').value = phone.settings.accentColor;

    $('wallpapers').replaceChildren(...phone.wallpapers.map((item) => {
        const tile = document.createElement('button');
        tile.className = 'wallpaper';
        tile.style.background = item.css;
        tile.textContent = item.label;
        tile.classList.toggle('selected', phone.settings.wallpaper === `preset:${item.id}`);
        tile.addEventListener('click', () => saveSettings({ wallpaper: `preset:${item.id}` }));
        return tile;
    }));
}

/* Gallery */

function showGallery() {
    show('gallery');
    $('photoCount').textContent = `${phone.photos.length} / ${phone.maxPhotos}`;
    $('galleryEmpty').hidden = phone.photos.length > 0;

    $('photoGrid').replaceChildren(...phone.photos.map((photo) => {
        const tile = document.createElement('button');
        tile.className = 'photo';
        tile.setAttribute('aria-label', 'Open photo');
        requestPhoto(photo.id).then((src) => {
            if (src) tile.style.backgroundImage = `url("${src}")`;
        });
        tile.addEventListener('click', () => showViewer(photo));
        return tile;
    }));
}

function showViewer(photo) {
    openPhotoId = photo.id;
    show('viewer');
    $('viewerImage').removeAttribute('src');
    $('viewerDate').textContent = new Date(photo.takenAt * 1000).toLocaleString();
    resetDeleteButton();
    requestPhoto(photo.id).then((src) => {
        if (src && openPhotoId === photo.id) $('viewerImage').src = src;
    });
}

function resetDeleteButton() {
    const button = $('deletePhoto');
    button.textContent = 'Delete';
    button.classList.remove('danger');
    button.dataset.armed = '';
}

// There are no confirm dialogs in-game, so the first press arms the button.
async function onDeletePressed() {
    const button = $('deletePhoto');
    if (!button.dataset.armed) {
        button.dataset.armed = '1';
        button.textContent = 'Press again to delete';
        button.classList.add('danger');
        return;
    }

    const id = openPhotoId;
    const settings = await post('deletePhoto', { id });
    if (!settings && PREVIEW === null) {
        resetDeleteButton();
        return;
    }
    if (settings) phone.settings = settings;
    photoCache.delete(id);
    phone.photos = phone.photos.filter((photo) => photo.id !== id);
    applyAppearance();
    showGallery();
}

/* Camera */

function startCamera() {
    $('phone').classList.add('camera');
    show('cameraView');
    $('cameraMessage').textContent = '';

    // Wait for the phone to move into position, then send where its screen is.
    setTimeout(() => {
        const rect = $('screen').getBoundingClientRect();
        post('startCamera', {
            crop: {
                x: rect.left / window.innerWidth,
                y: rect.top / window.innerHeight,
                w: rect.width / window.innerWidth,
                h: rect.height / window.innerHeight,
            },
        });
    }, 50);
}

function onCaptured(result) {
    const message = $('cameraMessage');
    if (!result || result.error) {
        message.textContent = (result && result.error) || 'The photo could not be saved.';
        return;
    }
    phone.photos.unshift(result.photo);
    message.textContent = 'Saved to Gallery';
    const flash = $('flash');
    flash.classList.remove('go');
    void flash.offsetWidth;
    flash.classList.add('go');
}

/* Clock */

function setClock(hours, minutes) {
    const text = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
    $('clock').textContent = text;
    $('homeClock').textContent = text;
}

function openPhone(data) {
    phone = data;
    applyAppearance();
    renderSettings();
    show('home');
    $('phone').hidden = false;
}

/* Wiring */

openers.camera = startCamera;
openers.gallery = showGallery;
openers.settings = () => show('settings');

function wireAppButtons() {
    document.querySelectorAll('[data-open]').forEach((appButton) => {
        appButton.addEventListener('click', () => openers[appButton.dataset.open]());
    });
}

$('homeBar').addEventListener('click', () => show('home'));
$('deletePhoto').addEventListener('click', onDeletePressed);
$('setWallpaper').addEventListener('click', () => {
    saveSettings({ wallpaper: `photo:${openPhotoId}` });
    show('home');
});
$('caseCustom').addEventListener('change', (event) => saveSettings({ caseColor: event.target.value.toUpperCase() }));
$('accentCustom').addEventListener('change', (event) => saveSettings({ accentColor: event.target.value.toUpperCase() }));

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !$('phone').hidden) goBack();
});

window.addEventListener('message', ({ data }) => {
    switch (data.action) {
        case 'open': openPhone(data.data); break;
        case 'clock': setClock(data.hours, data.minutes); break;
        case 'photo': cropPhoto(data.src, data.crop).then((src) => finishPhoto(data.id, src)); break;
        case 'captured': onCaptured(data.result); break;
        case 'cameraClosed':
            $('phone').classList.remove('camera');
            show('home');
            break;
    }
});

/* Browser preview only: index.html?preview=home|settings|gallery */
if (PREVIEW !== null) {
    document.documentElement.style.background = '#6b7f8f';
    const swatches = ['#0B0B0D', '#1C1C22', '#F5F5F5', '#C8102E', '#D4AF37', '#1F4E8C', '#1E7A5A', '#6B2FA0', '#E0689A', '#E07A1F'];
    const wallpapers = [
        { id: 'crimson', label: 'Crimson', css: 'radial-gradient(circle at 30% 15%, #8a0b20, #2a060c 55%, #0b0b0d)' },
        { id: 'gold', label: 'Gold Leaf', css: 'linear-gradient(155deg, #5c4a12, #1c1c22 60%, #0b0b0d)' },
        { id: 'midnight', label: 'Midnight', css: 'linear-gradient(170deg, #12233f, #0b0b0d 70%)' },
    ];
    openPhone({
        settings: { caseColor: '#D4AF37', accentColor: '#C8102E', wallpaper: 'preset:crimson' },
        photos: [],
        phoneNumber: '5551234567',
        swatches,
        wallpapers,
        maxPhotos: 40,
    });
    setClock(21, 47);
    if (PREVIEW === 'gallery') showGallery();
    else if (PREVIEW === 'cameraView') { $('phone').classList.add('camera'); show('cameraView'); }
    else if (VIEWS.includes(PREVIEW)) show(PREVIEW);
}
