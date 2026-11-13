import { useEffect, useState } from 'react';
import { fetchNui, isBrowser } from './nui';
import type { Crop } from './types';

// Photos are fetched from the game one at a time (they are large) and kept for this session.
const TIMEOUT_MS = 20000;
const cache = new Map<number, string>();
const waiters = new Map<number, ((src: string | null) => void)[]>();
const queue: number[] = [];
let inFlight: number | null = null;
let timer: ReturnType<typeof setTimeout> | undefined;

function pump() {
  if (inFlight !== null || queue.length === 0) return;
  inFlight = queue.shift()!;
  if (isBrowser) {
    const id = inFlight;
    setTimeout(() => finishPhoto(id, `https://picsum.photos/seed/hc${id}/400/700`), 150);
    return;
  }
  fetchNui('getPhoto', { id: inFlight });
  timer = setTimeout(() => finishPhoto(inFlight!, null), TIMEOUT_MS);
}

export function requestPhoto(id: number): Promise<string | null> {
  const hit = cache.get(id);
  if (hit) return Promise.resolve(hit);
  return new Promise((resolve) => {
    if (!waiters.has(id)) {
      waiters.set(id, []);
      queue.push(id);
    }
    waiters.get(id)!.push(resolve);
    pump();
  });
}

export function finishPhoto(id: number, src: string | null) {
  clearTimeout(timer);
  if (src) cache.set(id, src);
  (waiters.get(id) || []).forEach((resolve) => resolve(src));
  waiters.delete(id);
  if (inFlight === id) inFlight = null;
  pump();
}

export function forgetPhoto(id: number) {
  cache.delete(id);
}

/** Photos are captured full screen, then cropped here to what the phone screen showed. */
export function cropPhoto(src: string, crop?: Crop | string | null): Promise<string> {
  if (!src || !crop) return Promise.resolve(src);
  const area: Crop = typeof crop === 'string' ? JSON.parse(crop) : crop;
  return new Promise((resolve) => {
    const image = new Image();
    image.onerror = () => resolve(src);
    image.onload = () => {
      const canvas = document.createElement('canvas');
      canvas.width = Math.round(image.naturalWidth * area.w);
      canvas.height = Math.round(image.naturalHeight * area.h);
      canvas.getContext('2d')!.drawImage(
        image,
        image.naturalWidth * area.x, image.naturalHeight * area.y, canvas.width, canvas.height,
        0, 0, canvas.width, canvas.height,
      );
      resolve(canvas.toDataURL('image/webp', 0.92));
    };
    image.src = src;
  });
}

/** React hook: the photo's data URL once loaded (null while loading or if it failed). */
export function usePhoto(id: number | null | undefined): string | null {
  const [src, setSrc] = useState<string | null>(id != null ? cache.get(id) ?? null : null);
  useEffect(() => {
    if (id == null) return setSrc(null);
    let alive = true;
    setSrc(cache.get(id) ?? null);
    requestPhoto(id).then((value) => { if (alive) setSrc(value); });
    return () => { alive = false; };
  }, [id]);
  return src;
}
