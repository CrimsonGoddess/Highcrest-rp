// Talks to the Lua side: POST to the resource's NUI callback, which relays to the server.
declare global {
  interface Window {
    GetParentResourceName?: () => string;
  }
}

const inGame = () => typeof window.GetParentResourceName === 'function';
const post = (name: string, body: unknown) =>
  fetch(`https://${window.GetParentResourceName!()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body),
  });

export async function call<T>(action: string, data?: unknown): Promise<T> {
  if (!inGame()) throw new Error('Only works inside the game.');
  const res = await post('request', { action, data });
  const out = (await res.json()) as { ok: boolean; data?: T; error?: string };
  if (!out.ok) throw new Error(out.error ?? 'Request failed.');
  return out.data as T;
}

export function closePanel() {
  if (inGame()) post('close', {});
}
