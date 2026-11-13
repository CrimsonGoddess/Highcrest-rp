import { useCallback, useEffect, useState, type ReactNode } from 'react';
import { Alert, Button, Paper, Stack, Text, type ButtonProps, type PaperProps } from '@mantine/core';
import { fetchNui } from './nui';

export const timeAgo = (seconds: number) =>
  new Date(seconds * 1000).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });

export const dollars = (value: number | string) => `$${Number(value).toLocaleString('en-US')}`;

export const setWaypoint = (spot: { x: number; y: number }) => fetchNui('setWaypoint', { x: spot.x, y: spot.y });

export type Result<T> = (T & { error?: string }) | false | null | undefined;

/** The error text for a failed call, or null when it worked. */
export function failure<T>(result: Result<T>, fallback = 'That did not work. Try again.'): string | null {
  if (!result) return fallback;
  if ((result as { error?: string }).error) return (result as { error: string }).error;
  return null;
}

/** Load data from the game when the screen opens. `reload` fetches again; `set` replaces it after an action. */
export function useNuiData<T>(name: string, args: unknown, mock: T) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const key = JSON.stringify(args ?? null);
  const reload = useCallback(async () => {
    setLoading(true);
    const result = await fetchNui<T | false>(name, args ?? {}, mock);
    if (result) setData(result);
    setLoading(false);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [name, key]);
  useEffect(() => { reload(); }, [reload]);
  return { data, set: setData, reload, loading };
}

/** There are no confirm dialogs in-game, so the first press arms the button. */
export function ConfirmButton({ label, confirmLabel, onConfirm, ...props }: { label: ReactNode; confirmLabel: ReactNode; onConfirm: () => void } & ButtonProps) {
  const [armed, setArmed] = useState(false);
  useEffect(() => {
    if (!armed) return;
    const t = setTimeout(() => setArmed(false), 4000);
    return () => clearTimeout(t);
  }, [armed]);
  return (
    <Button {...props} color={armed ? 'red' : props.color} variant={armed ? 'filled' : props.variant}
      onClick={() => { if (armed) { setArmed(false); onConfirm(); } else setArmed(true); }}>
      {armed ? confirmLabel : label}
    </Button>
  );
}

export function ErrorText({ children }: { children?: string | null }) {
  if (!children) return null;
  return <Alert color="red" variant="light" py={6}>{children}</Alert>;
}

export function Empty({ icon, text }: { icon: ReactNode; text: string }) {
  return (
    <Stack align="center" gap={6} my="xl" opacity={0.75}>
      {icon}
      <Text c="dimmed" size="sm" ta="center">{text}</Text>
    </Stack>
  );
}

export function Card({ children, ...props }: { children: ReactNode; style?: React.CSSProperties } & PaperProps) {
  return <Paper className="glass" p="sm" radius="lg" {...props}>{children}</Paper>;
}

export function SectionTitle({ children }: { children: ReactNode }) {
  return <Text size="xs" tt="uppercase" fw={700} c="dimmed" mt="xs" style={{ letterSpacing: '0.08em' }}>{children}</Text>;
}
