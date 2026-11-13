// Highcrest /coords panel. Holds the working point, sends every change to the game for the live
// preview, and builds the copy formats.

const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'highcrest_coords';
const post = (name, data = {}) =>
    fetch(`https://${resource}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data),
    }).then((r) => r.json()).catch(() => ({}));

const $ = (id) => document.getElementById(id);
const STEPS = [0.01, 0.05, 0.1, 0.5, 1, 5];
const HSTEPS = [1, 5, 15, 45, 90];

const state = {
    point: { x: 0, y: 0, z: 0, h: 0 },
    settings: { preview: 'marker', model: '', radius: 0 },
    step: 0.1,
    hstep: 15,
    relative: false,
    precision: 2,
    star: 'vec4',
    points: [],
    entity: null,
};

// Remember the panel's own preferences between uses.
try {
    const saved = JSON.parse(localStorage.getItem('hc_coords_prefs') || '{}');
    for (const key of ['step', 'hstep', 'relative', 'precision', 'star']) if (key in saved) state[key] = saved[key];
} catch (e) { /* storage unavailable */ }
const savePrefs = () => {
    try {
        const { step, hstep, relative, precision, star } = state;
        localStorage.setItem('hc_coords_prefs', JSON.stringify({ step, hstep, relative, precision, star }));
    } catch (e) { /* storage unavailable */ }
};

const fix = (n, p = state.precision) => Number(n).toFixed(p);
const wrapHeading = (h) => ((h % 360) + 360) % 360;

// ---------------------------------------------------------------- formats

const FORMATS = [
    { id: 'vec4', name: 'vec4', make: (p) => `vec4(${fix(p.x)}, ${fix(p.y)}, ${fix(p.z)}, ${fix(p.h)})` },
    { id: 'vec3', name: 'vec3', make: (p) => `vec3(${fix(p.x)}, ${fix(p.y)}, ${fix(p.z)})` },
    { id: 'zone', name: 'vec3 zone (+1 m)', make: (p) => `vec3(${fix(p.x)}, ${fix(p.y)}, ${fix(p.z + 1)})` },
    { id: 'vec2', name: 'vec2', make: (p) => `vec2(${fix(p.x)}, ${fix(p.y)})` },
    { id: 'vector4', name: 'vector4', make: (p) => `vector4(${fix(p.x)}, ${fix(p.y)}, ${fix(p.z)}, ${fix(p.h)})` },
    { id: 'vector3', name: 'vector3', make: (p) => `vector3(${fix(p.x)}, ${fix(p.y)}, ${fix(p.z)})` },
    { id: 'table', name: 'Lua table', make: (p) => `{ x = ${fix(p.x)}, y = ${fix(p.y)}, z = ${fix(p.z)}, w = ${fix(p.h)} }` },
    { id: 'json', name: 'JSON', make: (p) => JSON.stringify({ x: +fix(p.x), y: +fix(p.y), z: +fix(p.z), w: +fix(p.h) }) },
    { id: 'tp', name: '/tp line', make: (p) => `/tp ${fix(p.x)} ${fix(p.y)} ${fix(p.z)}` },
    { id: 'heading', name: 'Heading', make: (p) => fix(p.h) },
];

function copy(text, row) {
    post('copy', { text });
    if (row) {
        row.classList.add('flash');
        setTimeout(() => row.classList.remove('flash'), 350);
    }
}

function renderFormats() {
    const box = $('formats');
    box.innerHTML = '';
    for (const f of FORMATS) {
        const row = document.createElement('div');
        row.className = 'format';
        const star = document.createElement('span');
        star.className = 'star' + (state.star === f.id ? ' on' : '');
        star.textContent = '★';
        star.title = 'Copy this one with C';
        star.onclick = (e) => {
            e.stopPropagation();
            state.star = f.id;
            savePrefs();
            renderFormats();
        };
        const name = document.createElement('span');
        name.className = 'name';
        name.textContent = f.name;
        const code = document.createElement('code');
        code.textContent = f.make(state.point);
        row.append(star, name, code);
        row.onclick = () => copy(f.make(state.point), row);
        box.append(row);
    }
}

// ---------------------------------------------------------------- point editor

const AXES = [
    { key: 'x', label: 'X' },
    { key: 'y', label: 'Y' },
    { key: 'z', label: 'Z' },
    { key: 'h', label: 'H' },
];
const inputs = {};

function buildAxes() {
    const box = $('axes');
    for (const axis of AXES) {
        const row = document.createElement('div');
        row.className = `axis ${axis.key}`;
        const name = document.createElement('span');
        name.className = 'name';
        name.textContent = axis.label;
        const minus = document.createElement('button');
        minus.textContent = '−';
        const plus = document.createElement('button');
        plus.textContent = '+';
        const input = document.createElement('input');
        input.type = 'number';
        input.step = 'any';
        input.addEventListener('change', () => {
            const v = parseFloat(input.value);
            if (!Number.isNaN(v)) setPoint({ [axis.key]: v });
        });
        const nudgeAxis = (dir, e) => {
            const mult = e.shiftKey ? 10 : e.ctrlKey ? 0.1 : 1;
            const amount = (axis.key === 'h' ? state.hstep : state.step) * mult * dir;
            setPoint({ [axis.key]: state.point[axis.key] + amount });
        };
        minus.onclick = (e) => nudgeAxis(-1, e);
        plus.onclick = (e) => nudgeAxis(1, e);
        inputs[axis.key] = input;
        row.append(name, minus, input, plus);
        box.append(row);
    }
}

function buildChips(id, values, key, suffix) {
    const box = $(id);
    box.innerHTML = '';
    for (const v of values) {
        const b = document.createElement('button');
        b.textContent = v + (suffix || '');
        b.className = state[key] === v ? 'on' : '';
        b.onclick = () => {
            state[key] = v;
            savePrefs();
            buildChips(id, values, key, suffix);
        };
        box.append(b);
    }
}

let syncTimer = null;
function syncGame() {
    clearTimeout(syncTimer);
    syncTimer = setTimeout(async () => {
        const res = await post('update', { point: state.point, settings: state.settings });
        $('previewError').textContent = (res && res.error) || '';
    }, 30);
}

function render() {
    for (const axis of AXES) {
        if (document.activeElement !== inputs[axis.key]) inputs[axis.key].value = fix(state.point[axis.key], 4).replace(/\.?0+$/, '') || '0';
    }
    renderFormats();
}

function setPoint(changes, send = true) {
    const p = { ...state.point, ...changes };
    for (const k of ['x', 'y', 'z', 'h']) p[k] = Math.round(Number(p[k]) * 10000) / 10000;
    p.h = wrapHeading(p.h);
    state.point = p;
    render();
    if (send) syncGame();
}

// Move on the ground plane, either along the world axes or relative to the heading.
function move(dx, dy) {
    if (!state.relative) return setPoint({ x: state.point.x + dx, y: state.point.y + dy });
    const rad = (state.point.h * Math.PI) / 180;
    const forward = { x: -Math.sin(rad), y: Math.cos(rad) };
    const right = { x: Math.cos(rad), y: Math.sin(rad) };
    setPoint({
        x: state.point.x + right.x * dx + forward.x * dy,
        y: state.point.y + right.y * dx + forward.y * dy,
    });
}

// ---------------------------------------------------------------- actions

const actions = {
    raycast: () => post('raycast'),
    me: async () => setPoint(await post('me')),
    ground: async () => {
        const res = await post('ground', state.point);
        if (res && typeof res.z === 'number') setPoint({ z: res.z });
        else $('previewError').textContent = 'No ground found under the point (area not loaded?).';
    },
    faceMe: async () => {
        const res = await post('faceMe');
        if (res && typeof res.h === 'number') setPoint({ h: res.h });
    },
    waypoint: async () => {
        const res = await post('waypoint');
        if (res && res.error) $('previewError').textContent = res.error;
        else if (res && typeof res.x === 'number') setPoint({ x: res.x, y: res.y, z: res.z });
    },
    teleport: () => post('teleport'),
};

document.querySelectorAll('[data-act]').forEach((b) => (b.onclick = () => actions[b.dataset.act]()));

// ---------------------------------------------------------------- preview

function renderPreview() {
    document.querySelectorAll('#preview button').forEach((b) => b.classList.toggle('on', b.dataset.v === state.settings.preview));
    const needsModel = state.settings.preview === 'vehicle' || state.settings.preview === 'object';
    $('modelRow').classList.toggle('hidden', !needsModel);
    $('model').value = state.settings.model;
    $('radius').value = state.settings.radius;
}

document.querySelectorAll('#preview button').forEach((b) => {
    b.onclick = () => {
        state.settings.preview = b.dataset.v;
        $('previewError').textContent = '';
        renderPreview();
        syncGame();
    };
});
const applyModel = () => {
    state.settings.model = $('model').value.trim();
    syncGame();
};
$('loadModel').onclick = applyModel;
$('model').addEventListener('keydown', (e) => { if (e.key === 'Enter') applyModel(); });
$('radius').addEventListener('input', () => {
    state.settings.radius = Math.max(0, parseFloat($('radius').value) || 0);
    syncGame();
});

// ---------------------------------------------------------------- picked entity

function renderEntity() {
    const card = $('entityCard');
    const e = state.entity;
    card.classList.toggle('hidden', !e);
    if (!e) return;
    const rows = [
        ['Type', e.type],
        ['Model', e.model],
        ['Hash', String(e.hash)],
        ['Net ID', e.netId != null ? String(e.netId) : 'local only'],
        ['Origin', `vec4(${fix(e.x)}, ${fix(e.y)}, ${fix(e.z)}, ${fix(e.h)})`],
    ];
    const box = $('entityRows');
    box.innerHTML = '';
    for (const [name, value] of rows) {
        const row = document.createElement('div');
        row.className = 'format';
        row.innerHTML = '<span></span><span class="name"></span><code></code>';
        row.children[1].textContent = name;
        row.children[2].textContent = value;
        row.onclick = () => copy(value, row);
        box.append(row);
    }
}

// ---------------------------------------------------------------- saved points

function persistPoints() {
    post('savePoints', state.points);
}

function renderPoints() {
    const box = $('points');
    box.innerHTML = '';
    state.points.forEach((pt, i) => {
        const item = document.createElement('div');
        item.className = 'point-item';
        const text = document.createElement('div');
        const title = document.createElement('div');
        title.className = 'title';
        title.textContent = pt.label || `Point ${i + 1}`;
        const code = document.createElement('code');
        code.textContent = FORMATS[0].make(pt);
        text.append(title, code);
        const buttons = document.createElement('div');
        buttons.className = 'buttons';
        const mk = (label, fn, cls) => {
            const b = document.createElement('button');
            b.textContent = label;
            if (cls) b.className = cls;
            b.onclick = fn;
            buttons.append(b);
        };
        mk('Load', () => setPoint({ x: pt.x, y: pt.y, z: pt.z, h: pt.h }));
        mk('Copy', () => copy(FORMATS.find((f) => f.id === state.star).make(pt)));
        mk('✕', () => {
            state.points.splice(i, 1);
            persistPoints();
            renderPoints();
        }, 'danger');
        item.append(text, buttons);
        box.append(item);
    });
}

$('savePoint').onclick = () => {
    const label = $('label').value.trim();
    state.points.push({ label, ...state.point });
    $('label').value = '';
    persistPoints();
    renderPoints();
};
$('label').addEventListener('keydown', (e) => { if (e.key === 'Enter') $('savePoint').click(); });

$('copyAll').onclick = () => {
    if (!state.points.length) return;
    const f = FORMATS.find((x) => x.id === state.star);
    const lines = state.points.map((pt, i) => `    ${f.make(pt)}, -- ${pt.label || `Point ${i + 1}`}`);
    copy(`{\n${lines.join('\n')}\n}`);
};
$('clearAll').onclick = () => {
    if (!state.points.length) return;
    state.points = [];
    persistPoints();
    renderPoints();
};

// ---------------------------------------------------------------- settings widgets

$('relative').onchange = () => {
    state.relative = $('relative').checked;
    savePrefs();
};
$('precision').onchange = () => {
    state.precision = parseInt($('precision').value, 10) || 2;
    savePrefs();
    render();
    renderPoints();
};

// ---------------------------------------------------------------- open / close / keys

let isOpen = false;
let looking = false;

function close() {
    if (!isOpen) return;
    post('close');
}

$('close').onclick = close;

window.addEventListener('message', (event) => {
    const { action, data } = event.data || {};
    if (action === 'open') {
        isOpen = true;
        state.points = Array.isArray(data.points) ? data.points : [];
        state.settings = { ...state.settings, ...data.settings };
        state.entity = null;
        $('panel').classList.remove('hidden', 'looking');
        $('relative').checked = state.relative;
        $('precision').value = String(state.precision);
        buildChips('step', STEPS, 'step', ' m');
        buildChips('hstep', HSTEPS, 'hstep', '°');
        renderPreview();
        renderEntity();
        renderPoints();
        setPoint(data.point, false);
    } else if (action === 'close') {
        isOpen = false;
        looking = false;
        $('panel').classList.add('hidden');
        $('rayHint').classList.add('hidden');
    } else if (action === 'raycast') {
        $('panel').classList.toggle('hidden', !!data);
        $('rayHint').classList.toggle('hidden', !data);
    } else if (action === 'picked') {
        state.entity = data.entity || null;
        renderEntity();
        setPoint(data.point, false);
    }
});

const typing = (el) => el && (el.tagName === 'INPUT' || el.tagName === 'SELECT' || el.tagName === 'TEXTAREA');

window.addEventListener('keydown', (e) => {
    if (!isOpen) return;
    if (e.key === 'Escape') {
        e.preventDefault();
        if (typing(document.activeElement)) return document.activeElement.blur();
        return close();
    }
    if (typing(document.activeElement)) return;

    const mult = e.shiftKey ? 10 : e.ctrlKey ? 0.1 : 1;
    const s = state.step * mult;
    const hs = state.hstep * mult;
    const key = e.key.length === 1 ? e.key.toLowerCase() : e.key;

    switch (key) {
        case 'ArrowUp': move(0, s); break;
        case 'ArrowDown': move(0, -s); break;
        case 'ArrowLeft': move(-s, 0); break;
        case 'ArrowRight': move(s, 0); break;
        case 'PageUp': setPoint({ z: state.point.z + s }); break;
        case 'PageDown': setPoint({ z: state.point.z - s }); break;
        case 'q': setPoint({ h: state.point.h + hs }); break;
        case 'e': setPoint({ h: state.point.h - hs }); break;
        case 'r': actions.raycast(); break;
        case 'm': actions.me(); break;
        case 'g': actions.ground(); break;
        case 'f': actions.faceMe(); break;
        case 'w': actions.waypoint(); break;
        case 't': actions.teleport(); break;
        case 'c': copy(FORMATS.find((f) => f.id === state.star).make(state.point)); break;
        case ' ':
            if (!looking) {
                looking = true;
                $('panel').classList.add('looking');
                post('look', { on: true });
            }
            break;
        default: return;
    }
    e.preventDefault();
});

window.addEventListener('keyup', (e) => {
    if (e.key === ' ' && looking) {
        looking = false;
        $('panel').classList.remove('looking');
        post('look', { on: false });
    }
});

buildAxes();
