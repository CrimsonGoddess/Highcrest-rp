import { useState } from 'react';
import { Avatar, Button, Group, SegmentedControl, Select, Stack, Text, TextInput } from '@mantine/core';
import { IconMapPin, IconMapPinOff, IconShare } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { avatarColor, displayName, initials } from '../state/comms';
import { usePhone } from '../state/phone';
import { Card, Empty, ErrorText, SectionTitle, failure, setWaypoint, useNuiData, type Result } from '../util';

type Friend = { number: string; name?: string; online?: boolean; expiresAt?: number | null };
type Data = { friends: Friend[]; sharing: Friend[] };

const MOCK: Data = {
  friends: [{ number: '5559876543', name: 'Jamie Cole', online: true, expiresAt: null }],
  sharing: [{ number: '5552223333', name: 'Rusty', expiresAt: 1793000000 }],
};

function expiryText(expiresAt?: number | null) {
  if (!expiresAt) return 'Until you stop';
  return `Until ${new Date(expiresAt * 1000).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}`;
}

export function FindFriendsApp() {
  const { phone } = usePhone();
  const { data, set } = useNuiData<Data>('locationGet', {}, MOCK);
  const [error, setError] = useState<string | null>(null);
  const [shareError, setShareError] = useState<string | null>(null);
  const [contact, setContact] = useState<string | null>(null);
  const [number, setNumber] = useState('');
  const [duration, setDuration] = useState('forever');

  const share = async () => {
    const target = number.trim() || contact || '';
    const result = await fetchNui<Result<Data>>('locationShare', {
      number: target, hours: duration === 'forever' ? null : Number(duration), forever: duration === 'forever',
    }, MOCK);
    const err = failure(result);
    setShareError(err);
    if (!err && result) { setNumber(''); set(result as Data); }
  };

  return (
    <AppPage title="Find Friends">
      <Stack gap="sm">
        <SectionTitle>Friends sharing with you</SectionTitle>
        <ErrorText>{error}</ErrorText>
        {data && data.friends.length === 0 && <Empty icon={<IconMapPinOff size={36} />} text="Nobody is sharing their location with you." />}
        {(data?.friends || []).map((f) => (
          <Card key={f.number}>
            <Group wrap="nowrap">
              <Avatar color={avatarColor(f.name || f.number)} radius="xl">{initials(f.name)}</Avatar>
              <div style={{ flex: 1, minWidth: 0 }}>
                <Group gap={6}><Text fw={700} truncate>{displayName(f.name, f.number)}</Text><span className={`presence ${f.online ? 'on' : ''}`} /></Group>
                <Text size="xs" c="dimmed">{expiryText(f.expiresAt)}</Text>
              </div>
            </Group>
            <Group grow mt="sm" gap="xs">
              <Button size="xs" leftSection={<IconMapPin size={16} />} onClick={async () => {
                const spot = await fetchNui<Result<{ x: number; y: number }>>('locationFind', f.number, { x: 0, y: 0 });
                const err = failure(spot, 'They could not be found.');
                setError(err);
                if (!err && spot) setWaypoint(spot);
              }}>Find on map</Button>
              <Button size="xs" variant="subtle" color="gray" onClick={async () => {
                const result = await fetchNui<Data | false>('locationHide', f.number, MOCK);
                if (result) set(result);
              }}>Remove</Button>
            </Group>
          </Card>
        ))}

        <SectionTitle>You are sharing with</SectionTitle>
        {data && data.sharing.length === 0 && <Text size="sm" c="dimmed">Nobody.</Text>}
        {(data?.sharing || []).map((s) => (
          <Card key={s.number}>
            <Group wrap="nowrap">
              <div style={{ flex: 1, minWidth: 0 }}>
                <Text fw={700} truncate>{displayName(s.name, s.number)}</Text>
                <Text size="xs" c="dimmed">{expiryText(s.expiresAt)}</Text>
              </div>
              <Button size="xs" variant="light" color="red" onClick={async () => {
                const result = await fetchNui<Data | false>('locationStop', s.number, MOCK);
                if (result) set(result);
              }}>Stop</Button>
            </Group>
          </Card>
        ))}

        <SectionTitle>Share my location</SectionTitle>
        <Card>
          <Stack gap="xs">
            <Select placeholder="Choose a contact" value={contact} onChange={setContact} clearable
              data={(phone?.contacts || []).map((c) => ({ value: c.number, label: c.name }))} comboboxProps={{ withinPortal: false }} />
            <TextInput placeholder="...or type a number" value={number} onChange={(e) => setNumber(e.currentTarget.value.replace(/[^\d]/g, ''))} />
            <SegmentedControl size="xs" fullWidth value={duration} onChange={setDuration}
              data={[{ label: '1h', value: '1' }, { label: '8h', value: '8' }, { label: '24h', value: '24' }, { label: 'Forever', value: 'forever' }]} />
            <ErrorText>{shareError}</ErrorText>
            <Button leftSection={<IconShare size={18} />} onClick={share}>Share</Button>
          </Stack>
        </Card>
      </Stack>
    </AppPage>
  );
}
