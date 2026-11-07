'use strict';

/* Snake. It runs only on the phone, so it can't affect the economy. */

const SNAKE_COLUMNS = 12;
const SNAKE_ROWS = 15;
const SNAKE_START_DELAY_MS = 260;
const SNAKE_MIN_DELAY_MS = 110;
const SNAKE_SPEEDUP_MS = 5;
const SNAKE_BEST_KEY = 'highcrest_snake_best';

const SNAKE_DIRECTIONS = {
    up: { x: 0, y: -1 },
    down: { x: 0, y: 1 },
    left: { x: -1, y: 0 },
    right: { x: 1, y: 0 },
};

const SNAKE_KEYS = {
    ArrowUp: 'up', ArrowDown: 'down', ArrowLeft: 'left', ArrowRight: 'right',
    w: 'up', s: 'down', a: 'left', d: 'right',
    W: 'up', S: 'down', A: 'left', D: 'right',
};

let snake = null;
let snakeTimer = null;

// TEMPORARY: shows where Snake's input stops. Remove once steering is fixed.
const snakeDebug = { ticks: 0, paused: 0, pageKeys: 0, lastKey: '-', gameKeys: 0, turns: 0, beats: 0, ack: '-' };

function showSnakeDebug() {
    const line = $('snakeDebug');
    if (!line) return;
    const d = snakeDebug;
    line.textContent = `v0.6.2 tick ${d.ticks} pause ${d.paused} | page keys ${d.pageKeys} (${d.lastKey}) | game keys ${d.gameKeys} | client ${d.beats} ack ${d.ack} | turns ${d.turns} | dir ${snake ? snake.direction : '-'} q${snake ? snake.queue.length : 0} run ${snake ? snake.running : '-'}`;
}

window.addEventListener('keydown', (event) => {
    snakeDebug.pageKeys += 1;
    snakeDebug.lastKey = event.key;
    showSnakeDebug();
}, true);

function readSnakeBest() {
    try {
        return Number(localStorage.getItem(SNAKE_BEST_KEY)) || 0;
    } catch (error) {
        return 0;
    }
}

function saveSnakeBest(value) {
    try {
        localStorage.setItem(SNAKE_BEST_KEY, String(value));
    } catch (error) {
        // The score just won't be remembered next session.
    }
}

let snakeBest = readSnakeBest();

function placeSnakeFood(body) {
    const free = [];
    for (let y = 0; y < SNAKE_ROWS; y++) {
        for (let x = 0; x < SNAKE_COLUMNS; x++) {
            if (!body.some((part) => part.x === x && part.y === y)) free.push({ x, y });
        }
    }
    return free.length ? free[Math.floor(Math.random() * free.length)] : null;
}

function updateSnakeScore() {
    $('snakeScore').textContent = snake ? snake.score : 0;
    $('snakeBest').textContent = snakeBest;
}

function drawSnake() {
    const canvas = $('snakeBoard');
    const context = canvas.getContext('2d');
    const cell = canvas.width / SNAKE_COLUMNS;
    const styles = getComputedStyle(document.documentElement);

    context.fillStyle = '#0b0b0d';
    context.fillRect(0, 0, canvas.width, canvas.height);
    if (!snake) return;

    if (snake.food) {
        context.fillStyle = '#d4af37';
        context.beginPath();
        context.arc((snake.food.x + 0.5) * cell, (snake.food.y + 0.5) * cell, cell * 0.38, 0, Math.PI * 2);
        context.fill();
    }

    context.fillStyle = styles.getPropertyValue('--accent').trim() || '#c8102e';
    snake.body.forEach((part, index) => {
        const inset = index === 0 ? 0.5 : 1.5;
        context.fillRect(part.x * cell + inset, part.y * cell + inset, cell - inset * 2, cell - inset * 2);
    });
}

function stopSnakeTimer() {
    clearTimeout(snakeTimer);
    snakeTimer = null;
}

function finishSnake(won) {
    stopSnakeTimer();
    snake.running = false;
    if (snake.score > snakeBest) {
        snakeBest = snake.score;
        saveSnakeBest(snakeBest);
    }
    updateSnakeScore();
    $('snakeMessage').textContent = won ? 'You filled the board!' : 'Game over';
    $('snakeStart').textContent = 'Play again';
    $('snakeOverlay').hidden = false;
}

function stepSnake() {
    // Pause while the phone is closed or another screen is showing.
    if ($('phone').hidden || currentView() !== 'snake') {
        snakeDebug.paused += 1;
        snakeTimer = setTimeout(stepSnake, 300);
        return;
    }
    snakeDebug.ticks += 1;
    showSnakeDebug();

    if (snake.queue.length) snake.direction = snake.queue.shift();
    const move = SNAKE_DIRECTIONS[snake.direction];
    const head = { x: snake.body[0].x + move.x, y: snake.body[0].y + move.y };
    const eating = snake.food && head.x === snake.food.x && head.y === snake.food.y;

    // The tail moves away this step unless the snake is growing.
    const blocking = eating ? snake.body : snake.body.slice(0, -1);
    const hitWall = head.x < 0 || head.y < 0 || head.x >= SNAKE_COLUMNS || head.y >= SNAKE_ROWS;
    if (hitWall || blocking.some((part) => part.x === head.x && part.y === head.y)) {
        finishSnake(false);
        return;
    }

    snake.body.unshift(head);
    if (eating) {
        snake.score += 1;
        snake.food = placeSnakeFood(snake.body);
        updateSnakeScore();
        if (!snake.food) {
            drawSnake();
            finishSnake(true);
            return;
        }
    } else {
        snake.body.pop();
    }

    drawSnake();
    const delay = Math.max(SNAKE_MIN_DELAY_MS, SNAKE_START_DELAY_MS - snake.score * SNAKE_SPEEDUP_MS);
    snakeTimer = setTimeout(stepSnake, delay);
}

function startSnake() {
    stopSnakeTimer();
    const body = [{ x: 5, y: 7 }, { x: 4, y: 7 }, { x: 3, y: 7 }];
    snake = { body, direction: 'right', queue: [], score: 0, food: placeSnakeFood(body), running: true };
    $('snakeOverlay').hidden = true;
    updateSnakeScore();
    drawSnake();
    snakeTimer = setTimeout(stepSnake, SNAKE_START_DELAY_MS);
}

// Queued so two quick presses both count, and a reverse into the snake's own neck is ignored.
function turnSnake(direction) {
    snakeDebug.turns += 1;
    showSnakeDebug();
    if (!snake || !snake.running || snake.queue.length >= 2) return;
    const last = snake.queue.length ? snake.queue[snake.queue.length - 1] : snake.direction;
    const from = SNAKE_DIRECTIONS[last];
    const to = SNAKE_DIRECTIONS[direction];
    if (from.x + to.x === 0 && from.y + to.y === 0) return;
    if (last !== direction) snake.queue.push(direction);
}

let snakeInputActive = false;

function setSnakeInputActive(active) {
    if (active === snakeInputActive) return;
    snakeInputActive = active;
    post('snakeInput', { active }).then((reply) => {
        snakeDebug.ack = String(reply);
        showSnakeDebug();
    });
}

function showSnake() {
    show('snake');
    updateSnakeScore();
    drawSnake();
    setSnakeInputActive(true);
}

openers.snake = showSnake;

// Leaving the Snake screen gives the controls back.
onViewChange.push(() => {
    if (currentView() !== 'snake') setSnakeInputActive(false);
});

window.addEventListener('message', ({ data }) => {
    if (data.action === 'snakeTurn') {
        snakeDebug.gameKeys += 1;
        turnSnake(data.direction);
    }
    if (data.action === 'snakeBeat') {
        snakeDebug.beats += 1;
        showSnakeDebug();
    }
    if (data.action === 'open') snakeInputActive = false;
});

$('snakeStart').addEventListener('click', () => {
    $('snakeStart').blur();
    startSnake();
});
document.querySelectorAll('[data-snake-turn]').forEach((pad) => {
    pad.addEventListener('click', () => {
        turnSnake(pad.dataset.snakeTurn);
        pad.blur();
    });
});

document.addEventListener('keydown', (event) => {
    if (currentView() !== 'snake' || $('phone').hidden) return;
    const direction = SNAKE_KEYS[event.key];
    if (direction) {
        event.preventDefault();
        turnSnake(direction);
    } else if (event.key === 'Enter' && !$('snakeOverlay').hidden) {
        startSnake();
    }
});

/* Browser preview only: index.html?preview=snake */
if (PREVIEW === 'snake') {
    showSnake();
    $('snakeOverlay').hidden = true;
    snake = {
        body: [{ x: 9, y: 9 }, { x: 8, y: 9 }, { x: 7, y: 9 }, { x: 6, y: 9 }, { x: 6, y: 10 }],
        direction: 'right', queue: [], score: 12, food: { x: 12, y: 5 }, running: false,
    };
    updateSnakeScore();
    drawSnake();
}
