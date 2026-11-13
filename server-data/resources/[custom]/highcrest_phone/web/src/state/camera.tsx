import { createContext, useContext, useMemo, useState, type ReactNode } from 'react';

// The camera turns the whole phone into a viewfinder in the middle of the screen,
// so its state lives above the phone frame.
type CameraState = {
  active: boolean;
  landscape: boolean;
  message: string;
  pose: string | null;
  flashKey: number;
  set: (changes: Partial<Omit<CameraState, 'set' | 'flash'>>) => void;
  flash: () => void;
};

const Ctx = createContext<CameraState | null>(null);

export function CameraProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState({ active: false, landscape: false, message: '', pose: null as string | null, flashKey: 0 });
  const value = useMemo<CameraState>(() => ({
    ...state,
    set: (changes) => setState((s) => ({ ...s, ...changes })),
    flash: () => setState((s) => ({ ...s, flashKey: s.flashKey + 1 })),
  }), [state]);
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useCamera() {
  const value = useContext(Ctx);
  if (!value) throw new Error('useCamera outside CameraProvider');
  return value;
}
