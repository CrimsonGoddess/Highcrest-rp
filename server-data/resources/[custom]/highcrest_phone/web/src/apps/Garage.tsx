import { useState } from 'react';
import { Badge, Button, Group, Progress, Stack, Text } from '@mantine/core';
import { IconCar, IconGasStation, IconMapPin, IconSteeringWheel } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { Card, ConfirmButton, Empty, ErrorText, dollars, failure, setWaypoint, useNuiData, type Result } from '../util';

type Vehicle = {
  name: string; brand?: string; plate: string; state: number; stateLabel: string; garage?: string;
  fuel: number; engine: number; body: number; depotPrice: number;
};

const MOCK = {
  valetFee: 250,
  vehicles: [
    { name: 'Adder', brand: 'Truffade', plate: 'CRIM 777', state: 1, stateLabel: 'In garage', garage: 'Legion Square', fuel: 88, engine: 100, body: 96, depotPrice: 0 },
    { name: 'Sultan', brand: 'Karin', plate: 'HIGHCRST', state: 0, stateLabel: 'Out', fuel: 42, engine: 74, body: 61, depotPrice: 0 },
    { name: 'Bati 801', brand: 'Pegassi', plate: 'NIGHT 01', state: 2, stateLabel: 'Impounded', fuel: 10, engine: 40, body: 22, depotPrice: 1500 },
  ],
};

const STATE_COLOR: Record<number, string> = { 0: 'green', 1: 'blue', 2: 'red' };
const barColor = (v: number) => (v > 60 ? 'green' : v > 30 ? 'yellow' : 'red');

function Meter({ label, value, icon }: { label: string; value: number; icon?: React.ReactNode }) {
  return (
    <div style={{ flex: 1 }}>
      <Group gap={4} justify="space-between"><Text size="xs" c="dimmed">{icon}{label}</Text><Text size="xs" fw={700}>{value}%</Text></Group>
      <Progress value={value} color={barColor(value)} size="sm" radius="xl" />
    </div>
  );
}

export function GarageApp() {
  const { data, reload } = useNuiData<{ vehicles: Vehicle[]; valetFee?: number }>('garageGet', {}, MOCK);
  const [error, setError] = useState<string | null>(null);

  return (
    <AppPage title="Garage" subtitle={data ? `${data.vehicles.length} vehicles` : undefined}>
      <Stack gap="sm">
        <ErrorText>{error}</ErrorText>
        {data && data.vehicles.length === 0 && <Empty icon={<IconCar size={40} />} text="You don't own any vehicles yet." />}
        {(data?.vehicles || []).map((v) => {
          const place = v.state === 2 && v.depotPrice > 0 ? `Impound fee ${dollars(v.depotPrice)}` : v.garage;
          return (
            <Card key={v.plate}>
              <Group justify="space-between" wrap="nowrap" align="flex-start">
                <div style={{ minWidth: 0 }}>
                  <Text fw={700} truncate>{v.brand ? `${v.brand} ${v.name}` : v.name}</Text>
                  <Group gap={6} mt={2}>
                    <Badge variant="outline" color="gray" radius="sm" className="plate">{v.plate}</Badge>
                    {place && <Text size="xs" c="dimmed" truncate>{place}</Text>}
                  </Group>
                </div>
                <Badge color={STATE_COLOR[v.state] || 'gray'} variant="light">{v.stateLabel}</Badge>
              </Group>
              <Group gap="sm" mt="sm" wrap="nowrap">
                <Meter label="Fuel" value={v.fuel} icon={<IconGasStation size={11} style={{ marginRight: 2 }} />} />
                <Meter label="Engine" value={v.engine} />
                <Meter label="Body" value={v.body} />
              </Group>
              {v.state === 0 && (
                <Button mt="sm" size="xs" variant="light" fullWidth leftSection={<IconMapPin size={16} />} onClick={async () => {
                  const spot = await fetchNui<Result<{ x: number; y: number }>>('garageLocate', v.plate, { x: 0, y: 0 });
                  const err = failure(spot, 'Your vehicle could not be located.');
                  setError(err);
                  if (!err && spot) setWaypoint(spot);
                }}>Find on map</Button>
              )}
              {v.state === 1 && (
                <ConfirmButton mt="sm" size="xs" variant="light" fullWidth leftSection={<IconSteeringWheel size={16} />}
                  label={`Bring to me${data?.valetFee ? ` (${dollars(data.valetFee)})` : ''}`} confirmLabel="Tap again to send a valet"
                  onConfirm={async () => {
                    const result = await fetchNui<Result<object>>('garageValet', v.plate, {});
                    const err = failure(result, 'The valet could not get your vehicle out.');
                    setError(err);
                    if (!err) reload();
                  }} />
              )}
            </Card>
          );
        })}
      </Stack>
    </AppPage>
  );
}
