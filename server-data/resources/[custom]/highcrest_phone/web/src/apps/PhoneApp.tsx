import { useEffect, useState } from 'react';
import { ActionIcon, Alert, Avatar, Group, ScrollArea, SegmentedControl, Stack, Text, UnstyledButton } from '@mantine/core';
import { IconBackspace, IconPhone, IconPhoneOff } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { avatarColor, displayName, formatNumber, initials, useComms } from '../state/comms';
import { usePhone } from '../state/phone';

const KEYS = [
  ['1', ''], ['2', 'ABC'], ['3', 'DEF'], ['4', 'GHI'], ['5', 'JKL'], ['6', 'MNO'],
  ['7', 'PQRS'], ['8', 'TUV'], ['9', 'WXYZ'], ['*', ''], ['0', '+'], ['#', ''],
];

function Keypad() {
  const { startCall, callError } = useComms();
  const [number, setNumber] = useState('');

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.target as HTMLElement)?.tagName === 'INPUT') return;
      if (/^[0-9*#]$/.test(e.key)) setNumber((n) => (n + e.key).slice(0, 15));
      else if (e.key === 'Backspace') setNumber((n) => n.slice(0, -1));
      else if (e.key === 'Enter') startCall(number);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [number, startCall]);

  return (
    <Stack gap="md" align="center">
      <Text className="dial-number">{formatNumber(number) || ' '}</Text>
      {callError && <Alert color="red" variant="light" py={6} w="100%">{callError}</Alert>}
      <div className="keypad">
        {KEYS.map(([digit, letters]) => (
          <UnstyledButton key={digit} className="key" onClick={() => setNumber((n) => (n + digit).slice(0, 15))}>
            <span className="key-digit">{digit}</span>
            <span className="key-letters">{letters}</span>
          </UnstyledButton>
        ))}
      </div>
      <Group gap="xl">
        <span style={{ width: 44 }} />
        <ActionIcon size={64} radius="xl" color="green" onClick={() => startCall(number)} aria-label="Call">
          <IconPhone size={30} />
        </ActionIcon>
        <ActionIcon size={44} radius="xl" variant="subtle" color="gray" onClick={() => setNumber((n) => n.slice(0, -1))} aria-label="Delete">
          <IconBackspace size={24} />
        </ActionIcon>
      </Group>
    </Stack>
  );
}

function ContactPicker() {
  const { phone } = usePhone();
  const { startCall } = useComms();
  const contacts = [...(phone?.contacts || [])].sort((a, b) => a.name.localeCompare(b.name));
  if (contacts.length === 0) return <Text c="dimmed" ta="center" mt="xl" size="sm">No contacts yet. Add them in Contacts.</Text>;
  return (
    <Stack gap={4}>
      {contacts.map((c) => (
        <UnstyledButton key={c.id} className="list-row" onClick={() => startCall(c.number)}>
          <Avatar color={avatarColor(c.name)} radius="xl">{initials(c.name)}</Avatar>
          <div style={{ flex: 1, minWidth: 0 }}>
            <Text fw={600} truncate>{c.name}</Text>
            <Text size="xs" c="dimmed">{formatNumber(c.number)}</Text>
          </div>
          <IconPhone size={18} opacity={0.6} />
        </UnstyledButton>
      ))}
    </Stack>
  );
}

function CallScreen() {
  const { call } = useComms();
  const [seconds, setSeconds] = useState(0);

  useEffect(() => {
    if (call?.state !== 'active') return setSeconds(0);
    const timer = setInterval(() => setSeconds((s) => s + 1), 1000);
    return () => clearInterval(timer);
  }, [call?.state]);

  if (!call) return null;
  const name = displayName(call.name, call.number);
  const status = call.state === 'active'
    ? `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`
    : call.incoming ? 'Incoming call' : 'Calling...';

  return (
    <div className="call-screen">
      <Stack align="center" gap={6} mt="18%">
        <Avatar size={96} radius={48} color={avatarColor(name)} className={call.state === 'ringing' ? 'ring-pulse' : ''}>
          {initials(call.name || '')}
        </Avatar>
        <Text fw={700} size="1.9rem" mt="sm" ta="center">{name}</Text>
        {call.name && <Text c="dimmed" size="sm">{formatNumber(call.number)}</Text>}
        <Text c={call.state === 'active' ? 'green.4' : 'dimmed'} fw={600}>{status}</Text>
      </Stack>
      <Group className="call-actions" justify="center" gap={56}>
        <Stack align="center" gap={6}>
          <ActionIcon size={68} radius="xl" color="red" onClick={() => fetchNui('hangUp')} aria-label="Hang up">
            <IconPhoneOff size={30} />
          </ActionIcon>
          <Text size="xs">{call.incoming && call.state === 'ringing' ? 'Decline' : 'End'}</Text>
        </Stack>
        {call.incoming && call.state === 'ringing' && (
          <Stack align="center" gap={6}>
            <ActionIcon size={68} radius="xl" color="green" className="ring-pulse" onClick={() => fetchNui('answerCall')} aria-label="Answer">
              <IconPhone size={30} />
            </ActionIcon>
            <Text size="xs">Answer</Text>
          </Stack>
        )}
      </Group>
    </div>
  );
}

export function PhoneApp() {
  const { route } = usePhone();
  const [tab, setTab] = useState('keypad');
  if (route?.page === 'call') return <CallScreen />;
  return (
    <AppPage title="Phone">
      <SegmentedControl fullWidth radius="xl" mb="lg" value={tab} onChange={setTab}
        data={[{ label: 'Keypad', value: 'keypad' }, { label: 'Contacts', value: 'contacts' }]} />
      {tab === 'keypad' ? <Keypad /> : <ScrollArea.Autosize mah="55vh"><ContactPicker /></ScrollArea.Autosize>}
    </AppPage>
  );
}
