import { useEffect, useState } from 'react';
import { Avatar, Badge, Button, Group, Stack, Text, UnstyledButton } from '@mantine/core';
import { IconBolt, IconMailOpened, IconTrash } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui, useNuiEvent } from '../nui';
import { avatarColor, initials } from '../state/comms';
import { usePhone } from '../state/phone';
import { Card, ConfirmButton, Empty, ErrorText, failure, timeAgo, useNuiData, type Result } from '../util';

type Mail = { id: number; sender?: string; subject?: string; message?: string; isRead: number | boolean; sentAt: number; hasAction?: boolean };

const MOCK = { mail: [
  { id: 1, sender: 'Maze Bank', subject: 'Your statement is ready', message: 'Thanks for banking with us.\n\nYour balance is attached.', isRead: 0, sentAt: 1793000000, hasAction: false },
  { id: 2, sender: 'Pawn Shop', subject: 'Your items are ready', message: 'Come collect them.', isRead: 1, sentAt: 1792990000, hasAction: true },
] };

function MailView({ mail, onChange }: { mail: Mail; onChange: () => void }) {
  const { back, setPhone } = usePhone();
  const [error, setError] = useState<string | null>(null);
  const [actionDone, setActionDone] = useState(false);

  useEffect(() => {
    if (Number(mail.isRead)) return;
    fetchNui<{ unread: number } | false>('mailRead', mail.id, { unread: 0 }).then((result) => {
      if (result) setPhone((p) => ({ ...p, unreadMail: result.unread }));
      onChange();
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mail.id]);

  return (
    <AppPage title={mail.subject || '(No subject)'}>
      <Stack gap="md">
        <Group wrap="nowrap">
          <Avatar color={avatarColor(mail.sender || '?')} radius="xl">{initials(mail.sender)}</Avatar>
          <div>
            <Text fw={700}>{mail.sender || 'Unknown'}</Text>
            <Text size="xs" c="dimmed">{timeAgo(mail.sentAt)}</Text>
          </div>
        </Group>
        <Card><Text size="sm" style={{ whiteSpace: 'pre-line', userSelect: 'text' }}>{mail.message || ''}</Text></Card>
        <ErrorText>{error}</ErrorText>
        {mail.hasAction && !actionDone && (
          <Button leftSection={<IconBolt size={18} />} onClick={async () => {
            const result = await fetchNui<Result<object>>('mailAction', mail.id, {});
            const err = failure(result, 'That action is no longer available.');
            setError(err);
            if (!err) setActionDone(true);
          }}>Do it</Button>
        )}
        <ConfirmButton label="Delete" confirmLabel="Tap again to delete" variant="subtle" color="red" leftSection={<IconTrash size={18} />}
          onConfirm={async () => { await fetchNui('mailDelete', mail.id, true); onChange(); back(); }} />
      </Stack>
    </AppPage>
  );
}

export function MailApp() {
  const { route, push, setPhone } = usePhone();
  const { data, reload } = useNuiData<{ mail: Mail[] }>('mailGet', {}, MOCK);
  useNuiEvent('newMail', () => reload());

  useEffect(() => {
    if (data) setPhone((p) => ({ ...p, unreadMail: data.mail.filter((m) => !Number(m.isRead)).length }));
  }, [data, setPhone]);

  if (route?.page === 'view') {
    const mail = data?.mail.find((m) => m.id === route.params?.id);
    if (mail) return <MailView mail={mail} onChange={reload} />;
  }

  const unread = data ? data.mail.filter((m) => !Number(m.isRead)).length : 0;
  return (
    <AppPage title="Mail" right={unread > 0 ? <Badge>{unread} new</Badge> : undefined}>
      {data && data.mail.length === 0 && <Empty icon={<IconMailOpened size={40} />} text="Your inbox is empty." />}
      <Stack gap={2}>
        {(data?.mail || []).map((mail) => {
          const isUnread = !Number(mail.isRead);
          return (
            <UnstyledButton key={mail.id} className="list-row" onClick={() => push('view', { id: mail.id })}>
              <Avatar color={avatarColor(mail.sender || '?')} radius="xl">{initials(mail.sender)}</Avatar>
              <div style={{ flex: 1, minWidth: 0 }}>
                <Group justify="space-between" wrap="nowrap" gap={4}>
                  <Text fw={isUnread ? 700 : 500} truncate>{mail.sender || 'Unknown'}</Text>
                  <Text size="xs" c="dimmed" style={{ flexShrink: 0 }}>{timeAgo(mail.sentAt)}</Text>
                </Group>
                <Text size="sm" truncate c={isUnread ? undefined : 'dimmed'}>{mail.subject || '(No subject)'}</Text>
              </div>
              {isUnread && <span className="dot" />}
            </UnstyledButton>
          );
        })}
      </Stack>
    </AppPage>
  );
}
