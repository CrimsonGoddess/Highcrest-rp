import { useEffect, useState } from 'react';
import { Alert, Autocomplete, Button, Group, Paper, SimpleGrid, Stack, Text } from '@mantine/core';
import { IconMapPin, IconMapPinOff, IconUsers } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { displayName } from '../state/comms';
import { usePhone } from '../state/phone';
import { Empty, SectionLabel, dateTime, errorOf, failed, setWaypoint } from '../util';

type Share = { number: string; name?: string | null; expiresAt?: number | null; online?: boolean };
type Data = { friends: Share[]; sharing: Share[] };

const MOCK: Data = {
  friends: [{ number: '5559876543', name: 'Jamie Cole', online: true, expiresAt: null }],
  sharing: [{ number: '5552223333', name: 'Rusty', expiresAt: 1763000000 }],
};

const until = (expiresAt?: number | null) => (expiresAt ? `Until ${dateTime(expiresAt)}` : 'Until you stop');

const DURATIONS = [
  { label: '1 hour', hours: 1 },
  { label: '8 hours', hours: 8 },
  { label: '24 hours', hours: 24 },
  { label: 'Forever', hours: null },
];

export function FindFriendsApp() {
  const { phone } = usePhone();
  const [data, setData] = useState<Data | null>(null);
  const [target, setTarget] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    fetchNui<Data | false>('locationGet', {}, MOCK).then((d) => d && setData(d));
  }, []);

  const contacts = phone?.contacts || [];
  // Accept either a saved contact's name or a typed number.
  const numberFor = (text: string) => contacts.find((c) => c.name === text)?.number || text.replace(/[^\d]/g, '');

  const share = async (hours: number | null) => {
    const number = numberFor(target.trim());
    if (!number) return setError('Choose a contact or type a number.');
    const result = await fetchNui<Data | { error: string } | false>('locationShare', { number, hours, forever: hours === null }, MOCK);
    if (failed(result)) return setError(errorOf(result, 'Your location could not be shared.'));
    setError('');
    setTarget('');
    setData(result as Data);
  };

  const find = async (number: string) => {
    const spot = await fetchNui<{ x: number; y: number } | { error: string } | false>('locationFind', number, { x: 0, y: 0 });
    if (failed(spot)) return setError(errorOf(spot, 'They could not be found.'));
    setError('');
    setWaypoint(spot as { x: number; y: number });
  };

  const update = async (callback: string, number: string) => {
    const result = await fetchNui<Data | false>(callback, number, MOCK);
    if (result) setData(result);
  };

  return (
    <AppPage title="Find Friends">
      <Stack gap="sm">
        <Paper className="glass" p="sm" radius="lg">
          <Stack gap="xs">
            <Text fw={700}>Share my location</Text>
            <Autocomplete placeholder="Contact name or number" value={target} onChange={setTarget}
              data={contacts.map((c) => c.name)} maxLength={40} />
            <SimpleGrid cols={4} spacing={6}>
              {DURATIONS.map((d) => (
                <Button key={d.label} size="xs" px={4} variant={d.hours === null ? 'filled' : 'light'} onClick={() => share(d.hours)}>{d.label}</Button>
              ))}
            </SimpleGrid>
          </Stack>
        </Paper>
        {error && <Alert color="red" variant="light" py={6}>{error}</Alert>}

        <SectionLabel>Friends sharing with you</SectionLabel>
        {data && data.friends.length === 0 && <Empty icon={<IconUsers size={36} />}>Nobody is sharing their location with you.</Empty>}
        {data?.friends.map((f) => (
          <Paper key={f.number} className="glass" p="sm" radius="lg">
            <Group justify="space-between" wrap="nowrap">
              <Text fw={700} truncate>{displayName(f.name, f.number)}</Text>
              <Text size="xs" c={f.online ? 'green.4' : 'dimmed'}>{f.online ? 'Online' : 'Offline'}</Text>
            </Group>
            <Text size="xs" c="dimmed">{until(f.expiresAt)}</Text>
            <Group gap="xs" mt="xs">
              <Button size="xs" variant="light" leftSection={<IconMapPin size={14} />} onClick={() => find(f.number)}>Find on map</Button>
              <Button size="xs" variant="subtle" color="gray" onClick={() => update('locationHide', f.number)}>Remove</Button>
            </Group>
          </Paper>
        ))}

        <SectionLabel>You are sharing with</SectionLabel>
        {data && data.sharing.length === 0 && <Text size="sm" c="dimmed">Nobody.</Text>}
        {data?.sharing.map((s) => (
          <Paper key={s.number} className="glass" p="sm" radius="lg">
            <Group justify="space-between" wrap="nowrap">
              <div style={{ minWidth: 0 }}>
                <Text fw={700} truncate>{displayName(s.name, s.number)}</Text>
                <Text size="xs" c="dimmed">{until(s.expiresAt)}</Text>
              </div>
              <Button size="xs" variant="light" color="red" leftSection={<IconMapPinOff size={14} />} onClick={() => update('locationStop', s.number)}>Stop</Button>
            </Group>
          </Paper>
        ))}
      </Stack>
    </AppPage>
  );
}
