import { useState } from 'react';
import { Button, Group, Stack, Text, Textarea } from '@mantine/core';
import { IconSpy, IconTrash } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { ConfirmButton, ErrorText, failure, timeAgo, useNuiData, type Result } from '../kit';
import { Empty } from '../util';

type Entry = { id: number; alias: string; body: string; createdAt: number; mine: number | boolean };
type Data = { alias?: string; posts: Entry[] };

const MOCK: Data = { alias: 'ghost_7731', posts: [
  { id: 1, alias: 'nullbyte', body: 'Need a driver for a job tonight. Clean record only.', createdAt: 1793000000, mine: 0 },
  { id: 2, alias: 'ghost_7731', body: 'Selling a laptop, no questions.', createdAt: 1792990000, mine: 1 },
] };

export function DarkwebApp() {
  const { data, set } = useNuiData<Data>('darkwebGet', {}, MOCK);
  const [body, setBody] = useState('');
  const [error, setError] = useState<string | null>(null);

  return (
    <AppPage title={<span className="mono">darkweb</span>} subtitle={data?.alias ? `connected as ${data.alias}` : 'connecting...'}>
      <div className="darkweb">
        <Stack gap="sm">
          <div className="dark-card">
            <Textarea variant="unstyled" className="mono" placeholder="> post anonymously_" value={body} maxLength={500} autosize minRows={2}
              onChange={(e) => setBody(e.currentTarget.value)} />
            <ErrorText>{error}</ErrorText>
            <Group justify="flex-end" mt={4}>
              <Button size="xs" color="lime" variant="outline" className="mono" onClick={async () => {
                const result = await fetchNui<Result<Data>>('darkwebPost', { body }, MOCK);
                const err = failure(result);
                setError(err);
                if (!err && result) { setBody(''); set(result as Data); }
              }}>send</Button>
            </Group>
          </div>
          {data && data.posts.length === 0 && <Empty icon={<IconSpy size={36} />}>Nothing here. Yet.</Empty>}
          {(data?.posts || []).map((e) => (
            <div key={e.id} className="dark-card">
              <Group justify="space-between" wrap="nowrap">
                <Text className="mono" c="lime.5" fw={700} size="sm">{e.alias}</Text>
                <Text className="mono" size="xs" c="dimmed">{timeAgo(e.createdAt)}</Text>
              </Group>
              <Text className="mono" size="sm" mt={4} style={{ whiteSpace: 'pre-line' }}>{e.body}</Text>
              {!!Number(e.mine) && (
                <Group justify="flex-end">
                  <ConfirmButton size="compact-xs" variant="subtle" color="gray" label={<IconTrash size={14} />} confirmLabel="wipe?"
                    onConfirm={async () => { const r = await fetchNui<Data | false>('darkwebDelete', e.id, MOCK); if (r) set(r); }} />
                </Group>
              )}
            </div>
          ))}
        </Stack>
      </div>
    </AppPage>
  );
}
