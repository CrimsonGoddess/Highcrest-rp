import { useState } from 'react';
import { Alert, Button, Group, SegmentedControl, Stack, Text, Textarea } from '@mantine/core';
import { IconAmbulance, IconMapPin, IconPhone, IconShieldCheck, IconUrgent } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { useComms } from '../state/comms';
import { Card, Empty, ErrorText, SectionTitle, failure, setWaypoint, timeAgo, useNuiData, type Result } from '../util';

type Call911 = { name: string; number: string; message: string; time: number; x: number; y: number };
type Data = { isResponder?: boolean; calls: Call911[] };

const MOCK: Data = {
  isResponder: true,
  calls: [{ name: 'Jamie Cole', number: '5559876543', message: 'Shots fired near the Vanilla Unicorn', time: 1793000000, x: 0, y: 0 }],
};

export function EmergencyApp() {
  const { startCall } = useComms();
  const { data } = useNuiData<Data>('emergencyGet', {}, MOCK);
  const [service, setService] = useState('police');
  const [message, setMessage] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState<string | null>(null);

  return (
    <AppPage title="911" subtitle="Emergency services">
      <Stack gap="sm">
        <Card style={{ borderColor: 'rgba(200,16,46,0.5)' }}>
          <SegmentedControl fullWidth value={service} onChange={setService} color={service === 'police' ? 'blue' : 'red'}
            data={[
              { value: 'police', label: <Group gap={6} justify="center" wrap="nowrap"><IconShieldCheck size={16} />Police</Group> },
              { value: 'ems', label: <Group gap={6} justify="center" wrap="nowrap"><IconAmbulance size={16} />EMS</Group> },
            ]} />
          <Textarea mt="sm" placeholder="What's happening?" value={message} maxLength={300} autosize minRows={3}
            onChange={(e) => setMessage(e.currentTarget.value)} />
          <ErrorText>{error}</ErrorText>
          {sent && <Alert color="green" variant="light" py={6} mt="xs">{sent}</Alert>}
          <Button mt="sm" fullWidth color="red" leftSection={<IconUrgent size={18} />} onClick={async () => {
            const result = await fetchNui<Result<{ units: number }>>('emergencyCall', { service, message }, { units: 2 });
            const err = failure(result);
            setError(err);
            if (err || !result) return setSent(null);
            setMessage('');
            setSent(result.units > 0 ? `Sent with your location. ${result.units} on duty notified.` : 'Sent, but no one is on duty right now.');
          }}>Send with my location</Button>
        </Card>

        {data?.isResponder && (
          <>
            <SectionTitle>Dispatch</SectionTitle>
            {data.calls.length === 0 && <Empty icon={<IconUrgent size={36} />} text="No open calls." />}
            {data.calls.map((call, i) => (
              <Card key={`${call.number}-${call.time}-${i}`}>
                <Group justify="space-between" wrap="nowrap">
                  <Text fw={700} truncate>{call.name}</Text>
                  <Text size="xs" c="dimmed">{timeAgo(call.time)}</Text>
                </Group>
                <Text size="sm" mt={4}>{call.message}</Text>
                <Group grow mt="sm" gap="xs">
                  <Button size="xs" variant="light" leftSection={<IconMapPin size={16} />} onClick={() => setWaypoint(call)}>Waypoint</Button>
                  <Button size="xs" variant="light" color="green" leftSection={<IconPhone size={16} />} onClick={() => startCall(call.number)}>Call</Button>
                </Group>
              </Card>
            ))}
          </>
        )}
      </Stack>
    </AppPage>
  );
}
