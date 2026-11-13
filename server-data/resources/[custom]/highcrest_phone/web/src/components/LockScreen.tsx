import { useEffect, useRef, useState } from 'react';
import { Badge, Group, Paper, Stack, Text } from '@mantine/core';
import { IconChevronUp, IconLock, IconMail, IconMessageCircle } from '@tabler/icons-react';
import { pad2, usePhone } from '../state/phone';

const DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/** Shown each time the phone comes out: big clock and notifications. Swipe up, click or press a key. */
export function LockScreen() {
  const { clock, unlock, phone } = usePhone();
  const [leaving, setLeaving] = useState(false);
  const startY = useRef<number | null>(null);
  const now = new Date();

  const go = () => {
    if (leaving) return;
    setLeaving(true);
    setTimeout(unlock, 260);
  };

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key !== 'Escape' && e.key !== 'Backspace') go();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  });

  return (
    <div
      className={`lock ${leaving ? 'leaving' : ''}`}
      onMouseDown={(e) => { startY.current = e.clientY; }}
      onMouseUp={(e) => {
        const dy = startY.current === null ? 0 : startY.current - e.clientY;
        startY.current = null;
        if (dy > 30 || Math.abs(dy) < 6) go();
      }}
    >
      <Stack align="center" gap={0} mt="12%">
        <IconLock size={18} opacity={0.8} />
        <Text className="lock-date" mt={6}>{DAYS[now.getDay()]}, {MONTHS[now.getMonth()]} {now.getDate()}</Text>
        <Text className="lock-clock">{pad2(clock.hours)}:{pad2(clock.minutes)}</Text>
      </Stack>

      <Stack gap={8} px="md" mt="lg">
        {!!phone?.unreadMessages && (
          <Paper className="glass notif" p="sm" radius="lg">
            <Group gap="sm" wrap="nowrap">
              <IconMessageCircle size={20} />
              <Text size="sm" fw={600} style={{ flex: 1 }}>Messages</Text>
              <Badge color="accent" size="sm" circle>{phone.unreadMessages}</Badge>
            </Group>
            <Text size="xs" c="dimmed" mt={2}>You have unread messages.</Text>
          </Paper>
        )}
        {!!phone?.unreadMail && (
          <Paper className="glass notif" p="sm" radius="lg">
            <Group gap="sm" wrap="nowrap">
              <IconMail size={20} />
              <Text size="sm" fw={600} style={{ flex: 1 }}>Mail</Text>
              <Badge color="accent" size="sm" circle>{phone.unreadMail}</Badge>
            </Group>
            <Text size="xs" c="dimmed" mt={2}>New mail is waiting.</Text>
          </Paper>
        )}
      </Stack>

      <Stack className="lock-hint" align="center" gap={2}>
        <IconChevronUp size={18} className="bob" />
        <Text size="xs" c="dimmed">Swipe up or click to unlock</Text>
      </Stack>
    </div>
  );
}
