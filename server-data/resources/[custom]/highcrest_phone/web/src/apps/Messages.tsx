import { useEffect, useRef, useState } from 'react';
import { ActionIcon, Alert, Autocomplete, Avatar, Badge, Button, Group, ScrollArea, Stack, Text, TextInput, UnstyledButton } from '@mantine/core';
import { IconChevronLeft, IconMapPin, IconMessagePlus, IconPhone, IconSend } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { avatarColor, displayName, formatNumber, initials, timeOf, useComms, type ChatMessage } from '../state/comms';
import { usePhone } from '../state/phone';

type ConversationRow = { other: string; name?: string | null; body: string; unread: number; sentAt?: number };

const MOCK_ROWS: ConversationRow[] = [
  { other: '5559876543', name: 'Jamie Cole', body: 'See you at Legion in 10', unread: 2, sentAt: 1762990000 },
  { other: '5550001111', name: null, body: 'Is the car still for sale?', unread: 1, sentAt: 1762980000 },
];
const MOCK_CHAT: ChatMessage[] = [
  { body: 'Yo, you around?', mine: 0, sentAt: 1762989000 },
  { body: 'Yeah, just left the garage', mine: 1, sentAt: 1762989100 },
  { body: 'My location', mine: 1, sentAt: 1762989200, x: 100, y: 200 },
  { body: 'See you at Legion in 10', mine: 0, sentAt: 1762990000 },
];

function Chat({ number }: { number: string }) {
  const { back } = usePhone();
  const { startCall, setOpenChat, onChatMessage } = useComms();
  const [name, setName] = useState<string | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [text, setText] = useState('');
  const [error, setError] = useState('');
  const viewport = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let alive = true;
    setOpenChat(number);
    onChatMessage.current = (m) => setMessages((list) => [...list, m]);
    fetchNui<{ name?: string; messages: ChatMessage[] } | false>('getConversation', number,
      { name: 'Jamie Cole', messages: MOCK_CHAT }).then((result) => {
      if (!alive || !result) return;
      setName(result.name || null);
      setMessages(result.messages);
    });
    return () => {
      alive = false;
      setOpenChat(null);
      onChatMessage.current = null;
    };
  }, [number, setOpenChat, onChatMessage]);

  useEffect(() => {
    viewport.current?.scrollTo({ top: viewport.current.scrollHeight, behavior: 'smooth' });
  }, [messages]);

  const send = async (payload: { body?: string; location?: boolean }) => {
    const mock = { message: { body: payload.body || 'My location', mine: 1, sentAt: Date.now() / 1000, x: payload.location ? 1 : null, y: payload.location ? 1 : null } };
    const result = await fetchNui<{ message?: ChatMessage; error?: string } | false>('sendMessage', { number, ...payload }, mock);
    if (!result || result.error || !result.message) {
      return setError((result && result.error) || (payload.location ? 'Your location could not be sent.' : 'That message could not be sent.'));
    }
    setError('');
    if (payload.body) setText('');
    setMessages((list) => [...list, result.message!]);
  };

  const title = displayName(name, number);
  return (
    <div className="app-page">
      <Group className="app-header" gap={8} wrap="nowrap">
        <ActionIcon variant="subtle" color="gray" size="lg" radius="xl" onClick={back} aria-label="Back"><IconChevronLeft size={22} /></ActionIcon>
        <Avatar size="md" radius="xl" color={avatarColor(title)}>{initials(name || '')}</Avatar>
        <div style={{ flex: 1, minWidth: 0 }}>
          <Text fw={700} truncate>{title}</Text>
          {name && <Text size="xs" c="dimmed">{formatNumber(number)}</Text>}
        </div>
        <ActionIcon variant="light" color="green" radius="xl" size="lg" onClick={() => startCall(number)} aria-label="Call"><IconPhone size={18} /></ActionIcon>
      </Group>

      <ScrollArea className="app-body" viewportRef={viewport} type="never">
        <Stack gap={6} px="md" pb="md">
          {messages.map((m, i) => (
            <div key={m.id ?? i} className={`bubble ${m.mine ? 'mine' : ''}`}>
              {m.x != null ? (
                <Stack gap={4}>
                  <Group gap={6}><IconMapPin size={16} /><Text size="sm" fw={600}>Shared location</Text></Group>
                  <Button size="compact-xs" variant={m.mine ? 'white' : 'light'} color={m.mine ? 'dark' : undefined}
                    onClick={() => fetchNui('setWaypoint', { x: m.x, y: m.y })}>Set waypoint</Button>
                </Stack>
              ) : <span>{m.body}</span>}
              <small>{timeOf(m.sentAt)}</small>
            </div>
          ))}
          {messages.length === 0 && <Text c="dimmed" size="sm" ta="center" mt="xl">No messages yet. Say hi.</Text>}
        </Stack>
      </ScrollArea>

      {error && <Alert color="red" variant="light" mx="md" py={4}>{error}</Alert>}
      <Group className="composer" gap={6} wrap="nowrap">
        <ActionIcon variant="light" radius="xl" size="lg" onClick={() => send({ location: true })} aria-label="Send location"><IconMapPin size={18} /></ActionIcon>
        <TextInput style={{ flex: 1 }} radius="xl" placeholder="Message" value={text} maxLength={500} data-autofocus autoFocus
          onChange={(e) => setText(e.currentTarget.value)}
          onKeyDown={(e) => { if (e.key === 'Enter' && text.trim()) send({ body: text.trim() }); }} />
        <ActionIcon radius="xl" size="lg" disabled={!text.trim()} onClick={() => send({ body: text.trim() })} aria-label="Send"><IconSend size={18} /></ActionIcon>
      </Group>
    </div>
  );
}

function NewMessage({ onGo }: { onGo: (number: string) => void }) {
  const { phone } = usePhone();
  const [value, setValue] = useState('');
  const options = (phone?.contacts || []).map((c) => `${c.name} · ${c.number}`);
  const go = () => {
    const match = value.match(/(\d{3,15})\s*$/);
    if (match) onGo(match[1]);
  };
  return (
    <Group gap={6} wrap="nowrap">
      <Autocomplete style={{ flex: 1 }} radius="xl" placeholder="Number or contact" data={options} value={value}
        onChange={setValue} onOptionSubmit={(v) => { const m = v.match(/(\d+)$/); if (m) onGo(m[1]); }}
        onKeyDown={(e) => { if (e.key === 'Enter') go(); }} comboboxProps={{ withinPortal: false }} />
      <ActionIcon size="lg" radius="xl" onClick={go} aria-label="Start"><IconMessagePlus size={18} /></ActionIcon>
    </Group>
  );
}

export function MessagesApp() {
  const { route, push, setPhone } = usePhone();
  const [rows, setRows] = useState<ConversationRow[] | null>(null);

  useEffect(() => {
    if (route?.page === 'chat') return;
    let alive = true;
    fetchNui<ConversationRow[] | false>('listConversations', {}, MOCK_ROWS).then((list) => {
      if (!alive) return;
      setRows(list || []);
      setPhone((p) => ({ ...p, unreadMessages: 0 }));
    });
    return () => { alive = false; };
  }, [route?.page, setPhone]);

  if (route?.page === 'chat') return <Chat number={String(route.params?.number)} />;

  return (
    <AppPage title="Messages">
      <Stack gap="sm">
        <NewMessage onGo={(number) => push('chat', { number })} />
        {rows && rows.length === 0 && <Text c="dimmed" size="sm" ta="center" mt="xl">No conversations yet.</Text>}
        <Stack gap={2}>
          {(rows || []).map((row) => {
            const title = displayName(row.name, row.other);
            return (
              <UnstyledButton key={row.other} className="list-row" onClick={() => push('chat', { number: row.other })}>
                <Avatar color={avatarColor(title)} radius="xl">{initials(row.name || '')}</Avatar>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <Group justify="space-between" wrap="nowrap" gap={4}>
                    <Text fw={row.unread ? 700 : 600} truncate>{title}</Text>
                    {row.sentAt && <Text size="xs" c="dimmed">{timeOf(row.sentAt)}</Text>}
                  </Group>
                  <Group justify="space-between" wrap="nowrap" gap={4}>
                    <Text size="xs" c={row.unread ? undefined : 'dimmed'} truncate>{row.body}</Text>
                    {row.unread > 0 && <Badge size="xs" circle>{row.unread}</Badge>}
                  </Group>
                </div>
              </UnstyledButton>
            );
          })}
        </Stack>
      </Stack>
    </AppPage>
  );
}
