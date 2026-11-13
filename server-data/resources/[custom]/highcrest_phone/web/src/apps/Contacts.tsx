import { useState } from 'react';
import { ActionIcon, Alert, Avatar, Button, Group, Paper, Stack, Text, TextInput, UnstyledButton } from '@mantine/core';
import { IconMessageCircle, IconPhone, IconPlus, IconSearch, IconShare, IconTrash, IconUserPlus } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { avatarColor, formatNumber, initials, useComms } from '../state/comms';
import { usePhone } from '../state/phone';
import type { Contact } from '../types';

type SaveResult = { contacts?: Contact[]; error?: string } | false;

function ShareNumber() {
  const [nearby, setNearby] = useState<{ id: number; name: string; distance: number }[] | null>(null);
  const [note, setNote] = useState<{ ok: boolean; text: string } | null>(null);

  const find = async () => {
    setNote(null);
    const list = await fetchNui<{ id: number; name: string; distance: number }[] | false>('shareNearby', {}, [{ id: 2, name: 'Jamie Cole', distance: 1.4 }]);
    if (!list || list.length === 0) {
      setNearby(null);
      return setNote({ ok: false, text: 'Nobody is standing right next to you.' });
    }
    setNearby(list);
  };
  const send = async (id: number) => {
    const result = await fetchNui<{ error?: string } | false>('shareNumber', id, {});
    setNearby(null);
    setNote(!result || result.error ? { ok: false, text: (result && result.error) || 'Your number could not be shared.' } : { ok: true, text: 'Your number was sent.' });
  };

  return (
    <Paper className="glass" p="sm" radius="lg">
      <Button variant="light" fullWidth leftSection={<IconShare size={18} />} onClick={find}>Share my number</Button>
      {nearby && (
        <Stack gap={4} mt="xs">
          {nearby.map((p) => (
            <UnstyledButton key={p.id} className="list-row" onClick={() => send(p.id)}>
              <Avatar color={avatarColor(p.name)} radius="xl" size="sm">{initials(p.name)}</Avatar>
              <Text fw={600} style={{ flex: 1 }}>{p.name}</Text>
              <Text size="xs" c="dimmed">{p.distance} m</Text>
            </UnstyledButton>
          ))}
        </Stack>
      )}
      {note && <Text size="xs" mt="xs" c={note.ok ? 'green.4' : 'red.4'}>{note.text}</Text>}
    </Paper>
  );
}

function Received() {
  const { cards, dismissCard, setContacts } = useComms();
  const [error, setError] = useState('');
  if (cards.length === 0) return null;
  return (
    <Stack gap={6}>
      <Text size="xs" tt="uppercase" fw={700} c="dimmed">Numbers shared with you</Text>
      {cards.map((card) => (
        <Paper key={card.number} className="glass" p="sm" radius="lg">
          <Group wrap="nowrap">
            <Avatar color={avatarColor(card.name)} radius="xl">{initials(card.name)}</Avatar>
            <div style={{ flex: 1 }}>
              <Text fw={600}>{card.name}</Text>
              <Text size="xs" c="dimmed">{formatNumber(card.number)}</Text>
            </div>
            <Button size="xs" variant="subtle" color="gray" onClick={() => dismissCard(card)}>Dismiss</Button>
            <Button size="xs" onClick={async () => {
              const result = await fetchNui<SaveResult>('saveContact', { name: card.name, number: card.number });
              if (!result || result.error || !result.contacts) return setError((result && result.error) || 'That contact could not be saved.');
              setContacts(result.contacts);
              dismissCard(card);
            }}>Save</Button>
          </Group>
        </Paper>
      ))}
      {error && <Text size="xs" c="red.4">{error}</Text>}
    </Stack>
  );
}

function ContactForm({ contact, number }: { contact?: Contact; number?: string }) {
  const { back, open } = usePhone();
  const { startCall, setContacts } = useComms();
  const [name, setName] = useState(contact?.name || '');
  const [phoneNumber, setPhoneNumber] = useState(contact?.number || number || '');
  const [error, setError] = useState('');
  const [armed, setArmed] = useState(false);

  const save = async () => {
    const result = await fetchNui<SaveResult>('saveContact', { id: contact?.id, name, number: phoneNumber },
      { contacts: [{ id: contact?.id ?? Date.now(), name, number: phoneNumber }] });
    if (!result || result.error || !result.contacts) return setError((result && result.error) || 'That contact could not be saved.');
    setContacts(result.contacts);
    back();
  };
  const remove = async () => {
    if (!armed) return setArmed(true);
    const result = await fetchNui<SaveResult>('deleteContact', contact!.id, { contacts: [] });
    if (result && result.contacts) setContacts(result.contacts);
    back();
  };

  return (
    <AppPage title={contact ? contact.name : 'New contact'}>
      <Stack gap="md">
        <Group justify="center" mt="xs">
          <Avatar size={84} radius={42} color={avatarColor(name || 'new')}>{initials(name)}</Avatar>
        </Group>
        {contact && (
          <Group grow>
            <Button variant="light" color="green" leftSection={<IconPhone size={18} />} onClick={() => startCall(contact.number)}>Call</Button>
            <Button variant="light" leftSection={<IconMessageCircle size={18} />} onClick={() => open('messages', 'chat', { number: contact.number })}>Message</Button>
          </Group>
        )}
        <TextInput label="Name" value={name} onChange={(e) => setName(e.currentTarget.value)} maxLength={40} />
        <TextInput label="Number" value={phoneNumber} onChange={(e) => setPhoneNumber(e.currentTarget.value.replace(/[^\d]/g, ''))} maxLength={15} />
        {error && <Alert color="red" variant="light" py={6}>{error}</Alert>}
        <Button onClick={save}>Save</Button>
        {contact && (
          <Button variant={armed ? 'filled' : 'subtle'} color="red" leftSection={<IconTrash size={18} />} onClick={remove}>
            {armed ? 'Tap again to delete' : 'Delete contact'}
          </Button>
        )}
      </Stack>
    </AppPage>
  );
}

export function ContactsApp() {
  const { phone, route, push } = usePhone();
  const [search, setSearch] = useState('');
  if (!phone) return null;

  if (route?.page === 'edit') {
    const contact = phone.contacts.find((c) => c.id === route.params?.id);
    return <ContactForm contact={contact} number={route.params?.number as string | undefined} />;
  }

  const q = search.trim().toLowerCase();
  const list = [...phone.contacts]
    .filter((c) => !q || c.name.toLowerCase().includes(q) || c.number.includes(q))
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <AppPage title="Contacts" right={
      <ActionIcon size="lg" radius="xl" variant="light" onClick={() => push('edit')} aria-label="Add contact"><IconPlus size={20} /></ActionIcon>
    }>
      <Stack gap="sm">
        <TextInput leftSection={<IconSearch size={16} />} placeholder="Search" radius="xl" value={search} onChange={(e) => setSearch(e.currentTarget.value)} />
        <ShareNumber />
        <Received />
        {list.length === 0 ? (
          <Stack align="center" mt="lg" gap={6}>
            <IconUserPlus size={40} opacity={0.5} />
            <Text c="dimmed" size="sm">{q ? 'No matches.' : 'No contacts yet. Tap + to add one.'}</Text>
          </Stack>
        ) : (
          <Stack gap={2}>
            {list.map((c) => (
              <UnstyledButton key={c.id} className="list-row" onClick={() => push('edit', { id: c.id })}>
                <Avatar color={avatarColor(c.name)} radius="xl">{initials(c.name)}</Avatar>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <Text fw={600} truncate>{c.name}</Text>
                  <Text size="xs" c="dimmed">{formatNumber(c.number)}</Text>
                </div>
              </UnstyledButton>
            ))}
          </Stack>
        )}
      </Stack>
    </AppPage>
  );
}
