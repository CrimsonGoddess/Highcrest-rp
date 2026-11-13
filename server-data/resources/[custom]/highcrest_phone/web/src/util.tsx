import { useEffect, useState, type ReactNode } from 'react';
import { Button, Stack, Text, type ButtonProps } from '@mantine/core';
import { fetchNui } from './nui';

/** "Nov 12, 08:40" from a unix time in seconds. */
export const dateTime = (seconds: number) =>
  new Date(seconds * 1000).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });

export const dollars = (n: number) => `$${Math.round(n).toLocaleString('en-US')}`;

export const setWaypoint = (spot: { x: number; y: number }) => fetchNui('setWaypoint', { x: spot.x, y: spot.y });

/** A server reply that failed: false (no answer) or { error }. */
export const failed = (result: unknown): result is false | { error: string } =>
  !result || (typeof result === 'object' && 'error' in (result as object) && !!(result as { error?: string }).error);

export const errorOf = (result: unknown, fallback: string): string => {
  const error = result && typeof result === 'object' ? (result as { error?: unknown }).error : undefined;
  return typeof error === 'string' && error ? error : fallback;
};

/** First tap arms it ("Tap again to …"), second tap runs it. Disarms itself after 4 s. */
export function ConfirmButton({ onConfirm, confirmLabel, children, ...props }: ButtonProps & {
  onConfirm: () => void | Promise<void>;
  confirmLabel: string;
  children: ReactNode;
}) {
  const [armed, setArmed] = useState(false);
  const [busy, setBusy] = useState(false);
  useEffect(() => {
    if (!armed) return;
    const timer = setTimeout(() => setArmed(false), 4000);
    return () => clearTimeout(timer);
  }, [armed]);
  return (
    <Button
      {...props}
      loading={busy}
      color={armed ? 'red' : props.color}
      variant={armed ? 'filled' : props.variant}
      onClick={async () => {
        if (!armed) return setArmed(true);
        setArmed(false);
        setBusy(true);
        try { await onConfirm(); } finally { setBusy(false); }
      }}
    >
      {armed ? confirmLabel : children}
    </Button>
  );
}

export function Empty({ icon, children }: { icon: ReactNode; children: ReactNode }) {
  return (
    <Stack align="center" mt="lg" gap={6}>
      <div style={{ opacity: 0.5 }}>{icon}</div>
      <Text c="dimmed" size="sm" ta="center">{children}</Text>
    </Stack>
  );
}

export function SectionLabel({ children }: { children: ReactNode }) {
  return <Text size="xs" tt="uppercase" fw={700} c="dimmed" mt="xs">{children}</Text>;
}
