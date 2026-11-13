import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react';
import { fetchNui, isBrowser } from '../nui';
import type { PhoneData, PhoneSettings } from '../types';

/** One screen in the navigation stack: an app and, optionally, a page inside it. */
export type Route = { app: string; page?: string; params?: Record<string, unknown> };

type PhoneState = {
  phone: PhoneData | null;
  setPhone: (update: (current: PhoneData) => PhoneData) => void;
  load: (data: PhoneData) => void;
  saveSettings: (changes: Partial<PhoneSettings>) => Promise<void>;

  locked: boolean;
  unlock: () => void;

  route: Route | null; // null = home screen
  open: (app: string, page?: string, params?: Record<string, unknown>) => void;
  push: (page: string, params?: Record<string, unknown>) => void;
  back: () => void;
  home: () => void;
  close: () => void;

  clock: { hours: number; minutes: number };
  setClock: (hours: number, minutes: number) => void;
};

const Ctx = createContext<PhoneState | null>(null);

export function PhoneProvider({ children, onClose }: { children: ReactNode; onClose: () => void }) {
  const [phone, setPhoneData] = useState<PhoneData | null>(null);
  const [locked, setLocked] = useState(true);
  const [stack, setStack] = useState<Route[]>([]);
  const [clock, setClockState] = useState({ hours: 12, minutes: 0 });

  const setPhone = useCallback((update: (current: PhoneData) => PhoneData) => {
    setPhoneData((current) => (current ? update(current) : current));
  }, []);

  const load = useCallback((data: PhoneData) => {
    setPhoneData(data);
    setStack([]);
    setLocked(true);
  }, []);

  const close = useCallback(() => {
    fetchNui('close');
    onClose();
  }, [onClose]);

  const saveSettings = useCallback(async (changes: Partial<PhoneSettings>) => {
    let previous: PhoneSettings | null = null;
    setPhoneData((current) => {
      if (!current) return current;
      previous = current.settings;
      return { ...current, settings: { ...current.settings, ...changes } };
    });
    const next = { ...(previous ?? {}), ...changes };
    const saved = await fetchNui<PhoneSettings | false>('saveSettings', next, next as PhoneSettings);
    setPhoneData((current) => {
      if (!current) return current;
      if (saved) return { ...current, settings: saved };
      return isBrowser || !previous ? current : { ...current, settings: previous };
    });
  }, []);

  const value = useMemo<PhoneState>(() => ({
    phone, setPhone, load, saveSettings,
    locked, unlock: () => setLocked(false),
    route: stack.length ? stack[stack.length - 1] : null,
    open: (app, page, params) => setStack([{ app, page, params }]),
    push: (page, params) => setStack((s) => (s.length ? [...s, { app: s[s.length - 1].app, page, params }] : s)),
    back: () => {
      if (locked) return close();
      if (stack.length === 0) return close();
      setStack((s) => s.slice(0, -1));
    },
    home: () => setStack([]),
    close,
    clock,
    setClock: (hours, minutes) => setClockState({ hours, minutes }),
  }), [phone, setPhone, load, saveSettings, locked, stack, close, clock]);

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function usePhone() {
  const value = useContext(Ctx);
  if (!value) throw new Error('usePhone outside PhoneProvider');
  return value;
}

export const pad2 = (n: number) => String(n).padStart(2, '0');
