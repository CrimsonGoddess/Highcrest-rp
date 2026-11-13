import { useCallback, useEffect, useState, type ComponentProps, type ReactNode } from 'react';
import { Alert, Paper, Text, type PaperProps } from '@mantine/core';
import { fetchNui } from './nui';
import { ConfirmButton as BaseConfirm, errorOf, failed } from './util';

// Extra helpers for the social apps (Pulse, Market, Spark, Darkweb). The shared ones are in util.tsx.

export { dateTime as timeAgo } from './util';

export type Result<T> = (T & { error?: string }) | false | null | undefined;

/** The error text for a failed call, or null when it worked. */
export function failure<T>(result: Result<T>, fallback = 'That did not work. Try again.'): string | null {
  return failed(result) ? errorOf(result, fallback) : null;
}

/** Load data from the game when the screen opens. `set` replaces it after an action; `reload` fetches again. */
export function useNuiData<T>(name: string, args: unknown, mock: T) {
  const [data, setData] = useState<T | null>(null);
  const key = JSON.stringify(args ?? null);
  const reload = useCallback(async () => {
    const result = await fetchNui<T | false>(name, args ?? {}, mock);
    if (result) setData(result);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [name, key]);
  useEffect(() => { reload(); }, [reload]);
  return { data, set: setData, reload };
}

export function ErrorText({ children }: { children?: string | null }) {
  if (!children) return null;
  return <Alert color="red" variant="light" py={6}>{children}</Alert>;
}

export function Card({ children, ...props }: { children: ReactNode; style?: React.CSSProperties } & PaperProps) {
  return <Paper className="glass" p="sm" radius="lg" {...props}>{children}</Paper>;
}

export function SectionTitle({ children }: { children: ReactNode }) {
  return <Text size="xs" tt="uppercase" fw={700} c="dimmed" mt="xs" style={{ letterSpacing: '0.08em' }}>{children}</Text>;
}

/** util.tsx's ConfirmButton, with the button text passed as `label`. */
export function ConfirmButton({ label, ...props }: Omit<ComponentProps<typeof BaseConfirm>, 'children'> & { label: ReactNode }) {
  return <BaseConfirm {...props}>{label}</BaseConfirm>;
}
