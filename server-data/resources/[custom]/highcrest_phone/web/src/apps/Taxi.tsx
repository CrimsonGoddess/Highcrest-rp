import { useState } from 'react';
import { Button, Group, Loader, Stack, Text, Textarea, ThemeIcon } from '@mantine/core';
import { IconCheck, IconFlag, IconMapPin, IconPhone, IconSteeringWheel, IconX } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { formatNumber, useComms } from '../state/comms';
import { Card, Empty, ErrorText, SectionTitle, failure, setWaypoint, useNuiData, type Result } from '../util';

type Fare = { id: number; name: string; note?: string; number: string; x: number; y: number };
type Data = {
  request?: { state: 'waiting' | 'accepted'; driverName?: string; driverNumber?: string } | null;
  isDriver?: boolean;
  job?: Fare | null;
  open?: Fare[];
};

const MOCK: Data = {
  request: null,
  isDriver: true,
  job: null,
  open: [{ id: 1, name: 'Jamie Cole', note: 'Outside the Vanilla Unicorn, red jacket', number: '5559876543', x: 0, y: 0 }],
};

export function TaxiApp() {
  const { startCall } = useComms();
  const { data, set, reload } = useNuiData<Data>('taxiGet', {}, MOCK);
  const [note, setNote] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [driverError, setDriverError] = useState<string | null>(null);
  const request = data?.request;

  return (
    <AppPage title="Taxi" subtitle="Downtown Cab Co.">
      <Stack gap="sm">
        {!request ? (
          <Card>
            <Group gap="sm" mb="xs" wrap="nowrap">
              <ThemeIcon size={40} radius="md" color="yellow" variant="light"><IconSteeringWheel size={24} /></ThemeIcon>
              <div><Text fw={700}>Need a ride?</Text><Text size="xs" c="dimmed">Drivers on shift get your location.</Text></div>
            </Group>
            <Textarea placeholder="Where are you, what are you wearing? (optional)" value={note} maxLength={200} autosize minRows={2}
              onChange={(e) => setNote(e.currentTarget.value)} />
            <ErrorText>{error}</ErrorText>
            <Button mt="sm" fullWidth color="yellow" c="dark" onClick={async () => {
              const result = await fetchNui<Result<Data>>('taxiRequest', { note }, { ...MOCK, request: { state: 'waiting' } });
              const err = failure(result);
              setError(err);
              if (!err && result) { setNote(''); set(result as Data); }
            }}>Call a taxi</Button>
          </Card>
        ) : (
          <Card>
            <Group gap="sm" wrap="nowrap">
              {request.state === 'accepted'
                ? <ThemeIcon size={40} radius="xl" color="green"><IconCheck size={22} /></ThemeIcon>
                : <Loader color="yellow" size="md" />}
              <div style={{ flex: 1 }}>
                <Text fw={700}>{request.state === 'accepted' ? `${request.driverName} is on the way` : 'Finding a driver...'}</Text>
                {request.driverNumber && <Text size="xs" c="dimmed">{formatNumber(request.driverNumber)}</Text>}
              </div>
            </Group>
            <Group grow mt="sm" gap="xs">
              {request.driverNumber && (
                <Button size="xs" color="green" leftSection={<IconPhone size={16} />} onClick={() => startCall(request.driverNumber!)}>Call driver</Button>
              )}
              <Button size="xs" variant="light" color="red" leftSection={<IconX size={16} />} onClick={async () => {
                const result = await fetchNui<Data | false>('taxiEnd', {}, MOCK);
                if (result) set(result);
              }}>Cancel</Button>
            </Group>
          </Card>
        )}

        {data?.isDriver && (
          <>
            <SectionTitle>Driver</SectionTitle>
            <ErrorText>{driverError}</ErrorText>
            {data.job && (
              <Card style={{ borderColor: 'var(--mantine-color-yellow-6)' }}>
                <Text fw={700}>Current fare: {data.job.name}</Text>
                {data.job.note && <Text size="sm" c="dimmed" mt={2}>{data.job.note}</Text>}
                <Group grow mt="sm" gap="xs">
                  <Button size="xs" variant="light" leftSection={<IconMapPin size={16} />} onClick={() => setWaypoint(data.job!)}>Waypoint</Button>
                  <Button size="xs" variant="light" color="green" leftSection={<IconPhone size={16} />} onClick={() => startCall(data.job!.number)}>Call</Button>
                  <Button size="xs" color="yellow" c="dark" leftSection={<IconFlag size={16} />} onClick={async () => {
                    const result = await fetchNui<Data | false>('taxiEnd', {}, MOCK);
                    if (result) set(result);
                  }}>Finish</Button>
                </Group>
              </Card>
            )}
            {(data.open || []).length === 0 && !data.job && <Empty icon={<IconSteeringWheel size={36} />} text="No one is waiting for a ride." />}
            {(data.open || []).map((fare) => (
              <Card key={fare.id}>
                <Group justify="space-between" wrap="nowrap">
                  <div style={{ minWidth: 0 }}>
                    <Text fw={700} truncate>{fare.name}</Text>
                    {fare.note && <Text size="xs" c="dimmed">{fare.note}</Text>}
                  </div>
                  <Button size="xs" color="yellow" c="dark" onClick={async () => {
                    const result = await fetchNui<Result<Data & { waypoint?: { x: number; y: number } }>>('taxiAccept', fare.id, { ...MOCK, job: fare, open: [] });
                    const err = failure(result, 'That fare is gone.');
                    setDriverError(err);
                    if (err || !result) return reload();
                    if (result.waypoint) setWaypoint(result.waypoint);
                    set(result as Data);
                  }}>Accept</Button>
                </Group>
              </Card>
            ))}
          </>
        )}
      </Stack>
    </AppPage>
  );
}
