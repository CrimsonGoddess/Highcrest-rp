import { useRef, useState } from 'react';
import { Group, Text } from '@mantine/core';
import { IconAlertTriangle } from '@tabler/icons-react';
import { useNuiEvent } from '../nui';

/** Wireless emergency alert (tsunami etc.): slides up on its own, with no mouse focus. */
export function EmergencyAlert() {
  const [alert, setAlert] = useState<{ title: string; body: string } | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout>>(undefined);

  useNuiEvent<{ action: string; title?: string; body?: string; seconds?: number }>('emergency', (m) => {
    setAlert({ title: m.title || 'Emergency Alert', body: m.body || '' });
    clearTimeout(timer.current);
    timer.current = setTimeout(() => setAlert(null), (m.seconds || 15) * 1000);
  });

  if (!alert) return null;
  return (
    <div className="wea">
      <Group gap={6} className="wea-top"><IconAlertTriangle size={18} /> Emergency Alert</Group>
      <Text fw={700} size="xl" mt={6}>{alert.title}</Text>
      <Text size="sm" mt={6} style={{ whiteSpace: 'pre-line' }}>{alert.body}</Text>
      <Text size="xs" c="dimmed" mt="sm">Emergency Alert System · Los Santos</Text>
    </div>
  );
}
