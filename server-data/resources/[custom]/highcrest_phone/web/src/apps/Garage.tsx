import { useEffect, useState } from 'react';
import { Alert, Badge, Button, Group, Paper, Progress, Stack, Text } from '@mantine/core';
import { IconCar, IconMapPin, IconSteeringWheel } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { ConfirmButton, Empty, dollars, errorOf, failed, setWaypoint } from '../util';

type Vehicle = {
  name: string; brand?: string; plate: string;
  state: number; stateLabel: string; garage?: string;
  fuel: number; engine: number; body: number; depotPrice: number;
};
type Data = { vehicles: Vehicle[]; valetFee: number };

const MOCK: Data = {
  valetFee: 250,
  vehicles: [
    { name: 'Adder', brand: 'Truffade', plate: 'CRIM 777', state: 1, stateLabel: 'In garage', garage: 'Legion Square', fuel: 88, engine: 100, body: 96, depotPrice: 0 },
    { name: 'Sultan', brand: 'Karin', plate: 'HIGHCRST', state: 0, stateLabel: 'Out', fuel: 42, engine: 74, body: 61, depotPrice: 0 },
    { name: 'Bati 801', brand: 'Pegassi', plate: 'NIGHT 01', state: 2, stateLabel: 'Impounded', fuel: 10, engine: 40, body: 22, depotPrice: 1500 },
  ],
};

// qbx_garages states: 0 out, 1 in a garage, 2 impounded.
const STATE_COLOR: Record<number, string> = { 0: 'yellow', 1: 'green', 2: 'red' };
const barColor = (n: number) => (n > 60 ? 'green' : n > 30 ? 'yellow' : 'red');

function Meter({ label, value }: { label: string; value: number }) {
  return (
    <div style={{ flex: 1 }}>
      <Group justify="space-between" gap={0}>
        <Text size="xs" c="dimmed">{label}</Text>
        <Text size="xs" fw={600}>{value}%</Text>
      </Group>
      <Progress value={value} color={barColor(value)} size="sm" radius="xl" />
    </div>
  );
}

export function GarageApp() {
  const [data, setData] = useState<Data | null>(null);
  const [error, setError] = useState('');

  const load = () => fetchNui<Data | false>('garageGet', {}, MOCK).then((d) => d && setData(d));
  useEffect(() => { load(); }, []);

  const locate = async (plate: string) => {
    const spot = await fetchNui<{ x: number; y: number } | { error: string } | false>('garageLocate', plate, { x: 0, y: 0 });
    if (failed(spot)) return setError(errorOf(spot, 'Your vehicle could not be located.'));
    setError('');
    setWaypoint(spot as { x: number; y: number });
  };

  const valet = async (plate: string) => {
    const result = await fetchNui('garageValet', plate, { netId: 1 });
    if (failed(result)) return setError(errorOf(result, 'The valet could not get your vehicle out.'));
    setError('');
    load();
  };

  const fee = data && data.valetFee > 0 ? ` (${dollars(data.valetFee)})` : ' (free)';

  return (
    <AppPage title="Garage">
      <Stack gap="sm">
        {error && <Alert color="red" variant="light" py={6}>{error}</Alert>}
        {data && data.vehicles.length === 0 && <Empty icon={<IconCar size={40} />}>You don't own any vehicles yet.</Empty>}
        {data?.vehicles.map((v) => {
          const place = v.state === 2 && v.depotPrice > 0 ? `Impound fee ${dollars(v.depotPrice)}` : v.garage;
          return (
            <Paper key={v.plate} className="glass" p="sm" radius="lg">
              <Group justify="space-between" wrap="nowrap" align="flex-start">
                <div style={{ minWidth: 0 }}>
                  <Text fw={700} truncate>{v.brand ? `${v.brand} ${v.name}` : v.name}</Text>
                  <Text size="xs" c="dimmed" truncate>{v.plate}{place ? ` · ${place}` : ''}</Text>
                </div>
                <Badge color={STATE_COLOR[v.state] || 'gray'} variant="light">{v.stateLabel}</Badge>
              </Group>
              <Group gap="sm" mt="xs" wrap="nowrap">
                <Meter label="Fuel" value={v.fuel} />
                <Meter label="Engine" value={v.engine} />
                <Meter label="Body" value={v.body} />
              </Group>
              {v.state === 0 && (
                <Button mt="xs" size="xs" variant="light" leftSection={<IconMapPin size={14} />} onClick={() => locate(v.plate)}>Find on map</Button>
              )}
              {v.state === 1 && (
                <ConfirmButton mt="xs" size="xs" variant="light" leftSection={<IconSteeringWheel size={14} />}
                  confirmLabel="Tap again to send a valet" onConfirm={() => valet(v.plate)}>
                  {`Bring to me${fee}`}
                </ConfirmButton>
              )}
            </Paper>
          );
        })}
      </Stack>
    </AppPage>
  );
}
