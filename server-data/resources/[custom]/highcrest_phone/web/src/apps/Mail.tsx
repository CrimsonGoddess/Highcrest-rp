import { useEffect, useState } from 'react';
import { Alert, Button, Group, Paper, Stack, Text, UnstyledButton } from '@mantine/core';
import { IconMailOpened, IconTrash } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { usePhone } from '../state/phone';
import { ConfirmButton, Empty, dateTime, errorOf, failed } from '../util';

type Mail = { id: number; sender?: string; subject?: string; message?: string; isRead: number | boolean; sentAt: number; hasAction?: boolean };

const MOCK: Mail[] = [
  { id: 1, sender: 'Maze Bank', subject: 'Your statement is ready', message: 'Thanks for banking with us.', isRead: 0, sentAt: 1762990000, hasAction: false },
  { id: 2, sender: 'Pawn Shop', subject: 'Your items are ready', message: 'Come collect them at the counter.', isRead: 1, sentAt: 1762980000, hasAction: true },
];

function MailView({ mail, onChanged }: { mail: Mail; onChanged: () => void }) {
  const { back, setPhone } = usePhone();
  const [error, setError] = useState('');
  const [actionDone, setActionDone] = useState(false);

  useEffect(() => {
    if (Number(mail.isRead)) return;
    fetchNui<{ unread: number } | false>('mailRead', mail.id, { unread: 0 }).then((result) => {
      if (result) setPhone((p) => ({ ...p, unreadMail: result.unread }));
      onChanged();
    });
  }, [mail.id]); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <AppPage title={mail.subject || '(No subject)'} subtitle={`${mail.sender || 'Unknown'} · ${dateTime(mail.sentAt)}`}>
      <Stack gap="md">
        <Paper className="glass" p="md" radius="lg">
          <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>{mail.message || ''}</Text>
        </Paper>
        {error && <Alert color="red" variant="light" py={6}>{error}</Alert>}
        {mail.hasAction && !actionDone && (
          <Button onClick={async () => {
            const result = await fetchNui('mailAction', mail.id, {});
            if (failed(result)) return setError(errorOf(result, 'That action is no longer available.'));
            setError('');
            setActionDone(true);
          }}>Set location</Button>
        )}
        <ConfirmButton variant="subtle" color="red" leftSection={<IconTrash size={18} />} confirmLabel="Tap again to delete"
          onConfirm={async () => {
            const result = await fetchNui<{ unread: number } | false>('mailDelete', mail.id, { unread: 0 });
            if (result) setPhone((p) => ({ ...p, unreadMail: result.unread }));
            onChanged();
            back();
          }}>Delete</ConfirmButton>
      </Stack>
    </AppPage>
  );
}

export function MailApp() {
  const { route, push, setPhone } = usePhone();
  const [mail, setMail] = useState<Mail[] | null>(null);

  const load = async () => {
    const result = await fetchNui<{ mail: Mail[] } | false>('mailGet', {}, { mail: MOCK });
    if (!result) return;
    setMail(result.mail);
    setPhone((p) => ({ ...p, unreadMail: result.mail.filter((m) => !Number(m.isRead)).length }));
  };
  useEffect(() => { load(); }, []); // eslint-disable-line react-hooks/exhaustive-deps

  if (route?.page === 'view') {
    const open = mail?.find((m) => m.id === route.params?.id);
    if (open) return <MailView mail={open} onChanged={load} />;
  }

  return (
    <AppPage title="Mail">
      {mail && mail.length === 0 ? (
        <Empty icon={<IconMailOpened size={40} />}>Your inbox is empty.</Empty>
      ) : (
        <Stack gap={2}>
          {(mail || []).map((m) => {
            const unread = !Number(m.isRead);
            return (
              <UnstyledButton key={m.id} className="list-row" onClick={() => push('view', { id: m.id })}>
                <div style={{ width: 8, height: 8, borderRadius: 4, flexShrink: 0, background: unread ? 'var(--mantine-primary-color-filled)' : 'transparent' }} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <Group justify="space-between" wrap="nowrap" gap="xs">
                    <Text fw={unread ? 700 : 500} truncate>{m.sender || 'Unknown'}</Text>
                    <Text size="xs" c="dimmed" style={{ flexShrink: 0 }}>{dateTime(m.sentAt)}</Text>
                  </Group>
                  <Text size="sm" c={unread ? undefined : 'dimmed'} truncate>{m.subject || '(No subject)'}</Text>
                </div>
              </UnstyledButton>
            );
          })}
        </Stack>
      )}
    </AppPage>
  );
}
