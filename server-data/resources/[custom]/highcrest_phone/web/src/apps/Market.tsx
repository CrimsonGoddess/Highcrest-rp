import { useState } from 'react';
import { ActionIcon, Button, Group, NumberInput, Stack, Text, TextInput, Textarea } from '@mantine/core';
import { IconMessageCircle, IconPhone, IconPlus, IconShoppingBag, IconTrash } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { PhotoField, PostPhoto } from '../components/PhotoPicker';
import { fetchNui } from '../nui';
import { useComms } from '../state/comms';
import { usePhone } from '../state/phone';
import { ConfirmButton, Card, ErrorText, failure, useNuiData, type Result } from '../kit';
import { Empty, dollars } from '../util';

type Listing = { id: number; title: string; price: number; description?: string; photoId?: number | null; phone: string; mine: number | boolean };
type Data = { listings: Listing[] };

const MOCK: Data = { listings: [
  { id: 1, title: '2019 Karin Sultan RS', price: 85000, description: 'Clean title, full upgrades. No lowballers.', photoId: 1, phone: '5559876543', mine: 0 },
  { id: 2, title: 'Studio apartment, Del Perro', price: 1200, description: 'Weekly rent, furnished.', phone: '5551234567', mine: 1 },
] };

// The form keeps the list it returns, so the list page shows the new listing straight away.
let latest: Data | null = null;

function NewListing() {
  const { back } = usePhone();
  const [title, setTitle] = useState('');
  const [price, setPrice] = useState<number | string>('');
  const [description, setDescription] = useState('');
  const [photo, setPhoto] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  return (
    <AppPage title="New listing">
      <Stack gap="sm">
        <TextInput label="Title" maxLength={60} value={title} onChange={(e) => setTitle(e.currentTarget.value)} />
        <NumberInput label="Price" prefix="$" min={0} thousandSeparator="," value={price} onChange={setPrice} hideControls />
        <Textarea label="Description" maxLength={500} autosize minRows={3} value={description} onChange={(e) => setDescription(e.currentTarget.value)} />
        <PhotoField value={photo} onChange={setPhoto} />
        <ErrorText>{error}</ErrorText>
        <Button onClick={async () => {
          const result = await fetchNui<Result<Data>>('marketCreate', { title, description, price, photoId: photo }, MOCK);
          const err = failure(result);
          setError(err);
          if (err || !result) return;
          latest = result as Data;
          back();
        }}>Post listing</Button>
      </Stack>
    </AppPage>
  );
}

export function MarketApp() {
  const { route, push, open } = usePhone();
  const { startCall } = useComms();
  const { data, set } = useNuiData<Data>('marketGet', { page: route?.page ?? 'list' }, MOCK);
  if (route?.page === 'new') return <NewListing />;
  const shown = latest || data;
  latest = null;

  return (
    <AppPage title="Market" right={<ActionIcon size="lg" radius="xl" variant="light" onClick={() => push('new')} aria-label="New listing"><IconPlus size={20} /></ActionIcon>}>
      <Stack gap="sm">
        {shown && shown.listings.length === 0 && <Empty icon={<IconShoppingBag size={36} />}>Nothing for sale right now.</Empty>}
        {(shown?.listings || []).map((l) => (
          <Card key={l.id}>
            <Group justify="space-between" wrap="nowrap" align="flex-start">
              <Text fw={700} style={{ minWidth: 0 }}>{l.title}</Text>
              <Text fw={700} c="green.4" style={{ flexShrink: 0 }}>{dollars(l.price)}</Text>
            </Group>
            {l.photoId ? <PostPhoto id={l.photoId} /> : null}
            {l.description && <Text size="sm" c="dimmed" mt={6} style={{ whiteSpace: 'pre-line' }}>{l.description}</Text>}
            <Group grow mt="sm" gap="xs">
              {Number(l.mine) ? (
                <ConfirmButton size="xs" variant="light" color="gray" leftSection={<IconTrash size={16} />} label="Remove listing" confirmLabel="Tap again to remove"
                  onConfirm={async () => { const r = await fetchNui<Data | false>('marketDelete', l.id, MOCK); if (r) set(r); }} />
              ) : (
                <>
                  <Button size="xs" variant="light" color="green" leftSection={<IconPhone size={16} />} onClick={() => startCall(l.phone)}>Call</Button>
                  <Button size="xs" variant="light" leftSection={<IconMessageCircle size={16} />} onClick={() => open('messages', 'chat', { number: l.phone })}>Message</Button>
                </>
              )}
            </Group>
          </Card>
        ))}
      </Stack>
    </AppPage>
  );
}
