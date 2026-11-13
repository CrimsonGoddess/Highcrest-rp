import { useEffect, useState } from 'react';
import { Alert, Button, Group, Loader, Paper, Stack, Text, Textarea } from '@mantine/core';
import { IconCheck, IconMapPin, IconPhone, IconSteeringWheel, IconX } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { formatNumber, useComms } from '../state/comms';
import { Empty, SectionLabel, errorOf, failed, setWaypoint } from '../util';

type Fare = { id: number; name: string; number: string; note?: string; x: number; y: number };
type Data = {
  request?: { state: 'waiting' | 'accepted'; driverName?: string; driverNumber?: string } | null;
  isDriver: boolean;
  job?: Fare | null;
  open?: Fare[];
};

const MOCK: Data = {
  request: null,
  isDriver: true,
  job: null,
  open: [{ id: 1, name: 'Jamie Cole', number: '5559876543', note: 'Legion Square to the airport', x: 0, y: 0 }],
};

export function TaxiApp() {
  const { startCall } = useComms();
  const [data, setData] = useState<Data | null>(null);
  const [note, setNote] = useState('');
  const [error, setError] = useState('');
  const [driverError, setDriverError] = useState('');

  const load = () => fetchNui<Data | false>('taxiGet', {}, MOCK).then((d) => d && setData(d));
  useEffect(() => {
    load();
    // Keep the screen current while it's open (driver accepting, new fares).
    const timer = setInterval(load, 5000);
    return () => clearInterval(timer);
  }, []);

  const request = async () => {
    const result = await fetchNui<Data | { error: string } | false>('taxiRequest', { note }, { ...MOCK, request: { state: 'waiting' } });
    if (failed(result)) return setError(errorOf(result, 'Your taxi could not be requested.'));
    setError('');
    setNote('');
    setData(result as Data);
  };
  const end = async () => {
    const result = await fetchNui<Data | false>('taxiEnd', {}, MOCK);
    if (result) setData(result);
  };
  const accept = async (id: number) => {
    const result = await fetchNui<(Data & { waypoint?: { x: number; y: number } }) | { error: string } | false>('taxiAccept', id, { ...MOCK, job: MOCK.open![0], open: [] });
    if (failed(result)) {
      setDriverError(errorOf(result, 'That fare is gone.'));
      return load();
    }
    setDriverError('');
    const next = result as Data & { waypoint?: { x: number; y: number } };
    if (next.waypoint) setWaypoint(next.waypoint);
    setData(next);
  };

  const r = data?.request;

  return (
    <AppPage title="Taxi">
      <Stack gap="sm">
        {r ? (
          <Paper className="glass" p="md" radius="lg">
            <Group wrap="nowrap" gap="sm">
              {r.state === 'accepted' ? <IconSteeringWheel size={28} color="var(--mantine-color-yellow-5)" /> : <Loader size="sm" color="yellow" />}
              <Text size="sm" style={{ flex: 1 }}>
                {r.state === 'accepted'
                  ? `${r.driverName} is on the way. Their number is ${formatNumber(r.driverNumber)}.`
                  : 'Waiting for a driver to accept…'}
              </Text>
            </Group>
            <Group grow mt="sm">
              {r.driverNumber && <Button variant="light" color="green" leftSection={<IconPhone size={16} />} onClick={() => startCall(r.driverNumber!)}>Call driver</Button>}
              <Button variant="light" color="red" leftSection={<IconX size={16} />} onClick={end}>Cancel</Button>
            </Group>
          </Paper>
        ) : (
          <Paper className="glass" p="sm" radius="lg">
            <Stack gap="xs">
              <Textarea placeholder="Where are you headed? (optional)" autosize minRows={2} maxLength={200}
                value={note} onChange={(e) => setNote(e.currentTarget.value)} />
              {error && <Alert color="red" variant="light" py={6}>{error}</Alert>}
              <Button color="yellow" c="dark" leftSection={<IconSteeringWheel size={18} />} onClick={request}>Call a taxi</Button>
            </Stack>
          </Paper>
        )}

        {data?.isDriver && (
          <>
            <SectionLabel>Driver desk</SectionLabel>
            {driverError && <Alert color="red" variant="light" py={6}>{driverError}</Alert>}
            {data.job && (
              <Paper className="glass" p="sm" radius="lg" style={{ borderColor: 'var(--mantine-color-yellow-6)' }}>
                <Text fw={700}>Current fare: {data.job.name}</Text>
                {data.job.note && <Text size="sm" mt={4}>{data.job.note}</Text>}
                <Group gap="xs" mt="xs">
                  <Button size="xs" variant="light" leftSection={<IconMapPin size={14} />} onClick={() => setWaypoint(data.job!)}>Waypoint</Button>
                  <Button size="xs" variant="light" color="green" leftSection={<IconPhone size={14} />} onClick={() => startCall(data.job!.number)}>Call</Button>
                  <Button size="xs" variant="light" color="yellow" leftSection={<IconCheck size={14} />} onClick={end}>Finish fare</Button>
                </Group>
              </Paper>
            )}
            {(data.open || []).length === 0 ? (
              <Empty icon={<IconSteeringWheel size={36} />}>No one is waiting for a ride.</Empty>
            ) : data.open!.map((fare) => (
              <Paper key={fare.id} className="glass" p="sm" radius="lg">
                <Group justify="space-between" wrap="nowrap">
                  <div style={{ minWidth: 0 }}>
                    <Text fw={700} truncate>{fare.name}</Text>
                    {fare.note && <Text size="sm" c="dimmed">{fare.note}</Text>}
                  </div>
                  <Button size="xs" color="yellow" c="dark" onClick={() => accept(fare.id)}>Accept</Button>
                </Group>
              </Paper>
            ))}
          </>
        )}
      </Stack>
    </AppPage>
  );
}
