import { useEffect, useRef } from 'react';

// True when the page runs in a normal browser (npm run dev) instead of inside FiveM.
export const isBrowser = !(window as unknown as { invokeNative?: unknown }).invokeNative;

const resourceName = (): string => {
  const fn = (window as unknown as { GetParentResourceName?: () => string }).GetParentResourceName;
  return fn ? fn() : 'highcrest_phone';
};

/**
 * Lua can't tell an empty list from an empty table, so FiveM sends empty lists (no photos,
 * no mail…) as {} instead of []. Turn every empty object into [] so `.map`/`.length` work.
 * Code reading a field from an "object" that came through empty just gets undefined, as before.
 */
export function fixLists<T>(value: T): T {
  if (Array.isArray(value)) return value.map(fixLists) as T;
  if (value && typeof value === 'object') {
    const keys = Object.keys(value as object);
    if (keys.length === 0) return [] as T;
    const out: Record<string, unknown> = {};
    for (const key of keys) out[key] = fixLists((value as Record<string, unknown>)[key]);
    return out as T;
  }
  return value;
}

/** Tell client Lua about a UI crash (printed in F8 and the client log). */
export function reportError(message: string) {
  if (isBrowser) return;
  fetch(`https://${resourceName()}/uiError`, { method: 'POST', body: JSON.stringify({ message: message.slice(0, 2000) }) }).catch(() => {});
}

/** Call a RegisterNUICallback in client Lua. In the browser preview, returns `mock` instead. */
export async function fetchNui<T = unknown>(name: string, data: unknown = {}, mock?: T): Promise<T> {
  if (isBrowser) return mock as T;
  try {
    const response = await fetch(`https://${resourceName()}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data),
    });
    return fixLists(await response.json()) as T;
  } catch {
    return false as T;
  }
}

export type NuiMessage = { action: string; [key: string]: unknown };

/** Run `handler` for every SendNUIMessage with this action. The whole message is passed. */
export function useNuiEvent<T extends NuiMessage = NuiMessage>(action: string, handler: (message: T) => void) {
  const saved = useRef(handler);
  saved.current = handler;
  useEffect(() => {
    const listener = (event: MessageEvent) => {
      const message = event.data as T;
      if (message && message.action === action) saved.current(fixLists(message));
    };
    window.addEventListener('message', listener);
    return () => window.removeEventListener('message', listener);
  }, [action]);
}

/** Pretend the game sent a message (browser preview only). */
export function mockMessage(message: NuiMessage, delay = 0) {
  setTimeout(() => window.dispatchEvent(new MessageEvent('message', { data: message })), delay);
}
