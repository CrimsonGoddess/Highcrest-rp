import { useEffect, useState } from 'react';
import { Alert, Button, Group, Paper, SegmentedControl, Stack, Text, Textarea } from '@mantine/core';
import { IconAmbulance, IconMapPin, IconPhone, IconShieldCheck, IconUrgent } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { useComms } from '../state/comms';
import { Empty, SectionLabel, dateTime, errorOf, failed, setWaypoint } from '../util';

type Call911 = { name: string; number: string; message: string; time: number; x: number; y: number };
type Desk = { isResponder: boolean; calls: Call911[] };

const MOCK: Desk = {
  isResponder: true,
  calls: [{ name: 'Jamie Cole', number: '5559876543', message: 'Shots fired near the pier', time: 1762990000, x: 0, y: 0 }],
};

export function EmergencyApp() {
  const { startCall } = useComms();
  const [service, setService] = useState('police');
  const [message, setMessage] = useState('');
  const [sending, setSending] = useState(false);
  const [note, setNote] = useState<{ ok: boolean; text: string } | null>(null);
  const [desk, setDesk] = useState<Desk | null>(null);

  useEffect(() => {
    fetchNui<Desk | false>('emergencyGet', {}, MOCK).then((d) => d && setDesk(d));
  }, []);

  const send = async () => {
    setSending(true);
    const result = await fetchNui<{ units: number } | { error: string } | false>('emergencyCall', { service, message }, { units: 2 });
    setSending(false);
    if (failed(result)) return setNote({ ok: false, text: errorOf(result, 'Your call could not be sent.') });
    setMessage('');
    const units = (result as { units: number }).units;
    setNote({ ok: true, text: units > 0 ? `Sent with your location. ${units} on duty notified.` : 'Sent, but no one is on duty right now.' });
  };

  return (
    <AppPage title="911" subtitle="Your message and location go to on-duty responders">
      <Stack gap="sm">
        <Paper className="glass" p="sm" radius="lg">
          <Stack gap="sm">
            <SegmentedControl fullWidth value={service} onChange={setService} color="red" data={[
              { value: 'police', label: <Group gap={6} justify="center" wrap="nowrap"><IconShieldCheck size={16} />Police</Group> },
              { value: 'ems', label: <Group gap={6} justify="center" wrap="nowrap"><IconAmbulance size={16} />EMS</Group> },
            ]} />
            <Textarea placeholder="What is your emergency?" autosize minRows={3} maxLength={200}
              value={message} onChange={(e) => setMessage(e.currentTarget.value)} />
            {note && <Alert color={note.ok ? 'green' : 'red'} variant="light" py={6}>{note.text}</Alert>}
            <Button color="red" leftSection={<IconUrgent size={18} />} loading={sending} onClick={send}>Send to 911</Button>
          </Stack>
        </Paper>

        {desk?.isResponder && (
          <>
            <SectionLabel>Recent calls</SectionLabel>
            {desk.calls.length === 0 ? (
              <Empty icon={<IconUrgent size={36} />}>No calls right now.</Empty>
            ) : desk.calls.map((call, i) => (
              <Paper key={`${call.time}-${i}`} className="glass" p="sm" radius="lg">
                <Group justify="space-between" wrap="nowrap">
                  <Text fw={700} truncate>{call.name}</Text>
                  <Text size="xs" c="dimmed">{dateTime(call.time)}</Text>
                </Group>
                <Text size="sm" mt={4}>{call.message}</Text>
                <Group gap="xs" mt="xs">
                  <Button size="xs" variant="light" leftSection={<IconMapPin size={14} />} onClick={() => setWaypoint(call)}>Waypoint</Button>
                  <Button size="xs" variant="light" color="green" leftSection={<IconPhone size={14} />} onClick={() => startCall(call.number)}>Call</Button>
                </Group>
              </Paper>
            ))}
          </>
        )}
      </Stack>
    </AppPage>
  );
}
