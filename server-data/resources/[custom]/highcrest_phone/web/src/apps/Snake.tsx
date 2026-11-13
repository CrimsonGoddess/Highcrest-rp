import { useCallback, useEffect, useRef, useState } from 'react';
import { ActionIcon, Button, Group, Stack, Text } from '@mantine/core';
import { IconChevronDown, IconChevronLeft, IconChevronRight, IconChevronUp } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';

/* Snake runs only on the phone, so it can't affect the economy. */

const COLS = 12;
const ROWS = 15;
const START_DELAY = 260;
const MIN_DELAY = 110;
const SPEEDUP = 5;
const BEST_KEY = 'highcrest_snake_best';

type Dir = 'up' | 'down' | 'left' | 'right';
type Pt = { x: number; y: number };
const MOVES: Record<Dir, Pt> = { up: { x: 0, y: -1 }, down: { x: 0, y: 1 }, left: { x: -1, y: 0 }, right: { x: 1, y: 0 } };
const KEYS: Record<string, Dir> = {
  ArrowUp: 'up', ArrowDown: 'down', ArrowLeft: 'left', ArrowRight: 'right',
  w: 'up', s: 'down', a: 'left', d: 'right', W: 'up', S: 'down', A: 'left', D: 'right',
};

type Game = { body: Pt[]; dir: Dir; queue: Dir[]; food: Pt | null; score: number; running: boolean };

const readBest = () => { try { return Number(localStorage.getItem(BEST_KEY)) || 0; } catch { return 0; } };
const saveBest = (n: number) => { try { localStorage.setItem(BEST_KEY, String(n)); } catch { /* not remembered */ } };

function placeFood(body: Pt[]): Pt | null {
  const free: Pt[] = [];
  for (let y = 0; y < ROWS; y++) for (let x = 0; x < COLS; x++) {
    if (!body.some((p) => p.x === x && p.y === y)) free.push({ x, y });
  }
  return free.length ? free[Math.floor(Math.random() * free.length)] : null;
}

export function SnakeApp() {
  const game = useRef<Game | null>(null);
  const timer = useRef<number>(0);
  const [, redraw] = useState(0);
  const [best, setBest] = useState(readBest);
  const [over, setOver] = useState<string | null>('Snake');

  const finish = useCallback((won: boolean) => {
    const g = game.current!;
    g.running = false;
    window.clearTimeout(timer.current);
    setBest((b) => {
      if (g.score <= b) return b;
      saveBest(g.score);
      return g.score;
    });
    setOver(won ? 'You filled the board!' : 'Game over');
  }, []);

  const step = useCallback(() => {
    const g = game.current;
    if (!g || !g.running) return;
    if (g.queue.length) g.dir = g.queue.shift()!;
    const move = MOVES[g.dir];
    const head = { x: g.body[0].x + move.x, y: g.body[0].y + move.y };
    const eating = !!g.food && head.x === g.food.x && head.y === g.food.y;
    // The tail moves away this step unless the snake is growing.
    const blocking = eating ? g.body : g.body.slice(0, -1);
    const hitWall = head.x < 0 || head.y < 0 || head.x >= COLS || head.y >= ROWS;
    if (hitWall || blocking.some((p) => p.x === head.x && p.y === head.y)) return finish(false);

    g.body.unshift(head);
    if (eating) {
      g.score += 1;
      g.food = placeFood(g.body);
      if (!g.food) { redraw((n) => n + 1); return finish(true); }
    } else {
      g.body.pop();
    }
    redraw((n) => n + 1);
    timer.current = window.setTimeout(step, Math.max(MIN_DELAY, START_DELAY - g.score * SPEEDUP));
  }, [finish]);

  const start = useCallback(() => {
    window.clearTimeout(timer.current);
    const body = [{ x: 5, y: 7 }, { x: 4, y: 7 }, { x: 3, y: 7 }];
    game.current = { body, dir: 'right', queue: [], food: placeFood(body), score: 0, running: true };
    setOver(null);
    redraw((n) => n + 1);
    timer.current = window.setTimeout(step, START_DELAY);
  }, [step]);

  // Queued so two quick presses both count; reversing into the neck is ignored.
  const turn = useCallback((dir: Dir) => {
    const g = game.current;
    if (!g || !g.running || g.queue.length >= 2) return;
    const last = g.queue.length ? g.queue[g.queue.length - 1] : g.dir;
    const from = MOVES[last], to = MOVES[dir];
    if (from.x + to.x === 0 && from.y + to.y === 0) return;
    if (last !== dir) g.queue.push(dir);
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const dir = KEYS[e.key];
      if (dir) { e.preventDefault(); turn(dir); }
      else if (e.key === 'Enter' && over) start();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [turn, start, over]);

  useEffect(() => () => window.clearTimeout(timer.current), []);

  const g = game.current;
  const cells: string[] = new Array(COLS * ROWS).fill('');
  if (g?.food) cells[g.food.y * COLS + g.food.x] = 'food';
  g?.body.forEach((p, i) => { cells[p.y * COLS + p.x] = i === 0 ? 'head' : 'body'; });

  const Pad = ({ dir, icon }: { dir: Dir; icon: React.ReactNode }) => (
    <ActionIcon size={48} radius="xl" variant="light" onClick={() => turn(dir)} aria-label={dir}>{icon}</ActionIcon>
  );

  return (
    <AppPage title="Snake" right={
      <Group gap="md" pr="xs">
        <Stack gap={0} align="center"><Text size="xs" c="dimmed">Score</Text><Text fw={700}>{g?.score ?? 0}</Text></Stack>
        <Stack gap={0} align="center"><Text size="xs" c="dimmed">Best</Text><Text fw={700} className="gold">{best}</Text></Stack>
      </Group>
    }>
      <Stack gap="md" align="center">
        <div className="snake-board" style={{ gridTemplateColumns: `repeat(${COLS}, 1fr)`, gridTemplateRows: `repeat(${ROWS}, 1fr)` }}>
          {cells.map((c, i) => <i key={i} className={c} />)}
          {over && (
            <div className="snake-overlay">
              <Text fw={700} size="xl">{over}</Text>
              <Button onClick={start}>{g ? 'Play again' : 'Start'}</Button>
              <Text size="xs" c="dimmed">Arrows or WASD to steer</Text>
            </div>
          )}
        </div>
        <Stack gap={4} align="center">
          <Pad dir="up" icon={<IconChevronUp />} />
          <Group gap={56}>
            <Pad dir="left" icon={<IconChevronLeft />} />
            <Pad dir="right" icon={<IconChevronRight />} />
          </Group>
          <Pad dir="down" icon={<IconChevronDown />} />
        </Stack>
      </Stack>
    </AppPage>
  );
}
